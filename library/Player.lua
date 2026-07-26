local Players = {}

local function is_inside(x, y, width, height, px, py)
    return px >= x and px <= x + width and py >= y and py <= y + height
end

local function get_coffee_at_position(x, y)
    for i, coffee in ipairs(tiles.coffees) do
        local coffee_width = tile_data.tilewidth or 32
        local coffee_height = tile_data.tileheight or 32
        local coffee_x = coffee.x / coffee_width
        local coffee_y = coffee.y / coffee_height

        if coffee_x == x and coffee_y == y then
            return coffee
        end
    end
    return nil
end

local function get_desk_at_position(x, y)
    for i, desk in ipairs(tiles.desks) do
        local desk_width = tile_data.tileWidth or 32
        local desk_height = tile_data.tileHeight or 32
        local desk_x, desk_y = desk.x / desk_width,  desk.y / desk_height
        
        
        if desk_x == x and desk_y == y then
            return desk
        end
    end
    return nil
end

--[=[
    Bikin player di grid tertentu.
    x atau y gak boleh lebih dari width grid, height grid atau kurang dari 0.
    @param x number
    @param y number
]=]
function Players.new(x,y, energy)
    local self = setmetatable({}, {__index = Players})

    if not tiles then
        error("Tile not found. Make sure to create a tile before creating a player.")
    end

    if is_inside(0, 0, tile_data.width, tile_data.height-1, x, y) == false then
        error("Player position out of bounds. x and y must be within the grid dimensions.")
    end

    -- Initialize player properties
    self.x = x or 0
    self.y = y or 0
    self.energy = energy or 100

    self.cooldown = {0,false}

    self.__game = {}
    self.__game.time = "morning" -- "morning":1, "afternoon":0.5, "night":0.2

    -- Properti dasar
    self.__status = "active" -- "active" | "gameover"
    self.__job_completed = 0
    self.__tile_moved = 0
    self.__coffee_drunk = 0

    self.__style = {}
    self.__style.x = self.x
    self.__style.y = self.y
    self.__style.width = images.airla:getWidth()
    self.__style.height = images.airla:getHeight()
    self.__style.grids = {
        airla = library.Anim8.newGrid(128,128,images.airla:getWidth(), images.airla:getHeight())
    }
    self.__style.animations = {
        idle = library.Anim8.newAnimation(self.__style.grids.airla('1-2',1),0.2),
        died = library.Anim8.newAnimation(self.__style.grids.airla('1-2',2), 0.2)
    }

    return self
end

function Players:update(dt)
    for _, anim in pairs(self.__style.animations) do
        anim:update(dt)
    end

    if self.__status == "gameover" or self.__status == "finish" then
        local target_x = (game_Width - 128*0.5) / 2
        local target_y = (game_Height - 128*0.5) / 2
        self.__style.x = utility.lerp(self.__style.x, target_x, dt*5)
        self.__style.y = utility.lerp(self.__style.y, target_y, dt*5)
        return
    end

    self.__style.x = utility.lerp(self.__style.x, self.x, dt*10)
    self.__style.y = utility.lerp(self.__style.y, self.y, dt*10)

    if self.cooldown[2] then
        if self.cooldown[1] > (0.15 * utility.day_to_num(_game.time_s)) then
            self.cooldown[1] = 0
            self.cooldown[2] = false
        else
            self.cooldown[1] = self.cooldown[1] + dt
        end
    else
        self.cooldown[1] = 0
    end
end

function Players:began__input(key)
    -- ketika input ditekan
    -- dan buat gerak jjuga bisa
    if self.__status == "gameover" or self.__status == "finish" then
        return end
    local move_direction = utility.get_move_direction(key)
    if move_direction then
        local dx, dy = move_direction[1], move_direction[2]
        self:move(dx, -dy)
    end
end

function Players:get__Position()
    return self.x, self.y
end

function Players:add__energy(amount)
    -- pastikan nilainya gak lebih dari 100 dan kurang dari 0
    if self.__status == "gameover" or self.__status == "finish" then
        return end
    if self.energy + amount > 100 then
        self.energy = 100
    elseif self.energy + amount < 0 then
        self.energy = 0
    else
        self.energy = self.energy + amount
    end
end

function Players:move(dx, dy)
    local newX = self.x + dx
    local newY = self.y + dy

    if self.__status == "gameover" or self.__status == "finish" then
        return end

    if self.cooldown[2] then
        return
    end

    -- Check energy
    if self.energy <= 1 then
        print("Player has no energy left to move.")
        self:set__status("Gameover")
        return
    end

    -- Check next tile type
    local coffee = get_coffee_at_position(newX, newY)
    local desk = get_desk_at_position(newX, newY)
    local next_tile_type = tiles:get_TileType(newX, newY)
    if next_tile_type == "wall" then
        print("Cannot move to a wall tile at: (" .. newX .. ", " .. newY .. ")")
        return
    elseif next_tile_type == "coffee" then
        if coffee then
            coffee:drink()
            
        end
        return
    elseif next_tile_type == "desk" then
        if desk then
            desk:work()
        end
        return
    end 
    -- Check bounds
    if is_inside(0, 0, tile_data.width-1, tile_data.height-1, newX, newY) then
        self.energy = self.energy - 1
        self.x = newX
        self.y = newY
        self.__tile_moved = self.__tile_moved + 1
        self.cooldown[2] = true
        for _, coffee in ipairs(tiles.coffees) do
            coffee:move()
        end
        if TUTORIAL then
            TUTORIAL = false
        end
    else
        print("Move out of bounds: (" .. newX .. ", " .. newY .. ")")
    end
    
end

function Players:get__status()
    return self.__status
end

function Players:set__status(status)
    if string.lower(status) == "gameover" then
        self.__status = "gameover"
        _game.game_over = true

        local width, height = tile_data.tilewidth * tile_size_mult, tile_data.tileheight * tile_size_mult
        local size = math.min(width, height)

        self.__style.x = (self.__style.x) * size + tiles.x
        self.__style.y = (self.__style.y - 1) * size + tiles.y

        
        for name, music in pairs(musics) do
            if name ~= "gameover" then
                if music[2] then
                    music[1]:stop()
                    music[2] = false
                end
            end
        end

        for name, music in pairs(musics) do
            if name ~= "gameover" then
                music.target = 0 -- FIX: fade out, bukan stop()
            end
        end

        musics.gameover[1]:setVolume(1)
        musics.gameover[1]:play()
        musics.gameover[2] = true
        musics.gameover.target = 1
        musics.gameover.volume = 0
    elseif string.lower(status) == "finish" then
        self.__status = "finish"
    end
end

function Players:draw()
    local game_state = (_game.game_over and 0 or 1)
    local width, height = tile_data.tilewidth * tile_size_mult, tile_data.tileheight * tile_size_mult
    local size = math.min(width, height)
    local drawX = (self.__style.x)*size + (tiles.x * game_state)
    local drawY = (self.__style.y-1)*size + (tiles.y* game_state)

    local frame_width, frame_height = 128, 128  -- sesuai grid Anim8 kamu
    local scale = 0.5

    local scaled_width  = frame_width * scale
    local scaled_height = frame_height * scale

    -- center di tengah tile (X dan Y)
    local offsetX = (size - scaled_width) / 2
    local offsetY = (size - scaled_height) / 2

    local finalX = drawX + offsetX * game_state
    local finalY = drawY + offsetY * game_state

    if self.__status == "finish" then return end
    if self.__status == "gameover" then
        -- MATI DISINI
        self.__style.animations.died:draw(images.airla, self.__style.x, self.__style.y, nil, scale, scale)
        love.graphics.setFont(fonts.w95f)
        if _game.gameover_time > 3.7 then
            love.graphics.print("[SPACE] TO RESTART", utility.shake(50,600,-2,2))
        end
        if _game.gameover_time > 1.5 then
            local logo_size = 0.3
            local logo_scaled_width = images.logo:getWidth() * logo_size
            local logo_drawX = (game_Width - logo_scaled_width) / 2
    
            local logo_drawX, logo_drawY = utility.shake(logo_drawX, 150, -2, 2)
            
            love.graphics.draw(images.logo, logo_drawX, logo_drawY, nil, logo_size, logo_size)
        end
        return
    end

    love.graphics.setColor(1, 0, 0)
    if __debug then
        love.graphics.rectangle("line", drawX, drawY, size, size)
    end
    love.graphics.setColor(1, 1, 1)

    self.__style.animations.idle:draw(images.airla, finalX, finalY, nil, scale, scale)

    -- Energy
    local scale_text = 2
    local energy_width = fonts.valveit:getWidth(self.energy) * scale_text  -- FIX: ikutin scale

    local energy_x = drawX + (size - energy_width) / 2

    -- ENERGY_STROKE
    local stroke_size = 2  -- ini tetep dalam pixel MENTAH (sebelum di-scale)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(fonts.valveit)

    for ox = -stroke_size, stroke_size do
        for oy = -stroke_size, stroke_size do
            if ox ~= 0 or oy ~= 0 then
                love.graphics.print(self.energy, energy_x + ox, finalY + oy +-20, nil, scale_text, scale_text)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.energy, energy_x, finalY+-20, nil, scale_text, scale_text)

    love.graphics.setColor(1,0,0, __vignette)
    love.graphics.draw(images.vignette,0,0, nil, 0.56,0.7)
    love.graphics.setColor(1,1,1,1)

    -- Hud
    love.graphics.draw(images.hud,0,0,nil, 1.9,1.9)

    -- Lives
    local attempt_size = 0.7
    local width = images.wall:getWidth() * attempt_size
    for i = 1, _game.attempt do
        local urgency = ((3 - _game.attempt) + 1)
        local individual_y = math.sin(_game.time*i) * 5
        local individual_r = math.cos(_game.time*i) * 0.05
        local shake_x, shake_y = utility.shake((i/20)*width-60, 170+individual_y, -urgency, urgency)
        love.graphics.draw(images.lives, shake_x, shake_y, individual_r, attempt_size)
    end
end

return Players