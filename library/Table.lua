local desks = {}

local function random_next()
    return love.math.random(7, 20) * 1
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
    self.requesting = true
    self.next_job = random_next()
end

function desks:update(dt)
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
            self.requesting = false
        end
    end
end

function desks:work()
    if self.requesting then
        print("Kerja!")
        self.requesting = false
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
        love.graphics.print("Hello", draw_x, draw_y)
    end
end

return desks