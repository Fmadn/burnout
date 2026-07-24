local tile = {}

function tile.new(x, y, width, height, size)
    local self = {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.tile_size = size
    
    self.tiles = {}

    for y = 1, self.height do
        for x = 1, self.width do
            local t = { x=x, y=y, data={type="nothing",ec=1}}  -- type = "nothing" | "coffee" | "table", ec: energy consumtion, 
            table.insert(self.tiles, t)
        end
    end

    if __debug then
        for i, tile in ipairs(self.tiles) do
            print("Tile "..i.." : "..tile.x..","..tile.y)
        end
    end

    function self:draw()
        local size = self.tile_size
        for i, tile in ipairs(self.tiles) do
            love.graphics.rectangle("line", (tile.x-1)*size, (tile.y-1)*size, size, size)
        end
    end

    return self
end

return tile