local coffees = {}

function coffees.new(pos_x, pos_y)
    local self = setmetatable({}, { __index = coffees })
    self.x = pos_x
    self.y = pos_y
    self.cooldown = { active = true, duration = 10 } -- lagi cooldown atau enggak, lama cooldownnya berapa move

    return self
end

function coffees:move()
    if not self.cooldown.active then
        if self.cooldown.duration <= 1 then
            print("Coffee is ready to be drunk again at position: (" .. self.x .. ", " .. self.y .. ")")
            self.cooldown.active = true
        else
            print("Coffee is on cooldown. Please wait.")
            self.cooldown.duration = self.cooldown.duration - 1
            return
        end
    end
end

function coffees:draw()
    local width, height = tile_data.tilewidth * tile_size_mult, 
    tile_data.tileheight * tile_size_mult
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

    love.graphics.setColor(1, 1, 1, 1)
    local text = self.cooldown.active and "Ready" or tostring(self.cooldown.duration)
    love.graphics.print(text, draw_x, draw_y)
end

function coffees:drink()
    if not self.cooldown.active then
        print("Coffee is on cooldown. Please wait.")
        return
    end
    print("Minum kopi di posisi: (" .. self.x .. ", " .. self.y .. ")")
    player:add__energy(30)
    self.cooldown.active = false
    self.cooldown.duration = 20
end

return coffees