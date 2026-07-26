local desks = {}

local function random_next()
    return love.math.random(15,20) * utility.day_to_num(_game.time_s)
end

function desks.new(x,y)
    local self = setmetatable({}, {__index = desks})

    self.x, self.y = x, y
    
    self.requesting = false
    self.next_job = random_next()

    self.waiting_time = 0
    self.elapsed_time = 0

    return self
end

function desks:add__job()
    self.elapsed_time = 0
    self.waiting_time = 0
    self.requesting = true
    self.next_job = random_next()
end

function desks:update(dt)
    if player:get__status() == "gameover" then
        return
    end
        if not self.requesting then
            if self.elapsed_time > self.next_job then
                self:add__job()
            else
                self.elapsed_time = self.elapsed_time + dt
            end
        else
            self.elapsed_time = 0
            self.waiting_time = self.waiting_time + dt
            if self.waiting_time > 5 then
                
                if _game.attempt - 1 <= 0 then
                    player:set__status("gameover")
                end
                _game.attempt = _game.attempt - 1
                __vignette = 1
                tile_size_mult = 2.1

                local fail_sound = sounds.fail:clone()
                fail_sound:play()
                
                recenter_tiles()

                self.waiting_time = 0
                self.requesting = false
                -- self = nil
            end
    end
end

function desks:work()
    if self.requesting then
        player:add__energy(-2)
        local work_sound = sounds.work:clone()
        work_sound:play()
        self.requesting = false
        player.__job_completed = player.__job_completed + 1

        -- self = nil
    end
end

function desks:draw()
    if self.requesting then
        local width, height = tile_data.tilewidth * tile_size_mult, tile_data.tileheight * tile_size_mult
        local size = math.min(width, height)
        local draw_x, draw_y
        if self.x > tile_data.width then
            -- berarti masih pixel absolut dari Tiled, convert dulu ke grid
            draw_x = (self.x / tile_data.tilewidth) * size + tiles.x
            draw_y = (self.y / tile_data.tileheight-1) * size + tiles.y
        else
            -- udah grid index
            draw_x = self.x * size + tiles.x
            draw_y = self.y * size + tiles.y
        end
        love.graphics.draw(images.chat, draw_x-10, draw_y-10,nil, 0.12,0.12)
        -- Waiting bar
        love.graphics.setColor(0,0,0,1)
        local size = self.waiting_time / 5
        local shakingX,shakingY = utility.shake(draw_x,draw_y+2,-size/2,size/2)
        love.graphics.rectangle('line', shakingX, shakingY,40,10, 5)
        love.graphics.setColor(size/2,0,0,1)
        love.graphics.rectangle('fill', shakingX, shakingY,size*40,10,5)
        love.graphics.setColor(1,1,1,1)
    end
end

return desks