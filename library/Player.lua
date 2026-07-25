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

    self.__game = {}
    self.__game.time = "morning" -- "morning":1, "afternoon":0.5, "night":0.2

    -- Properti dasar
    self.__status = "active" -- "active" | "gameover"

    return self
end

function Players:began__input(key)
    -- ketika input ditekan
    -- dan buat gerak jjuga bisa
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
        for _, coffee in ipairs(tiles.coffees) do
            coffee:move()
        end
    else
        print("Move out of bounds: (" .. newX .. ", " .. newY .. ")")
    end
    
end

function Players:set__status(status)
    if string.lower(status) == "gameover" then
        self.__status = "gameover"
    end
end

function Players:draw()
    if self.__status == "gameover" then
        love.graphics.print("Game Over", 10, 30, 0, 2, 2)
        return
    end
    -- ENERGY
    love.graphics.print("Energy: " .. self.energy, 10, 10, 0, 2, 2)

    local width, height = tile_data.tilewidth * tile_size_mult, tile_data.tileheight * tile_size_mult
    local size = math.min(width, height)
    love.graphics.setColor(1, 0, 0) -- Set color to red for the player
    love.graphics.rectangle("fill", (self.x)*size + tiles.x, (self.y-1)*size + tiles.y, size, size)
    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

return Players