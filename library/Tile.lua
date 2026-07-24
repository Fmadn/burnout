local tile = {}

function tile.new(x, y, width, height, size, tiles)
    local self = {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.tile_size = size
    
    self.tiles = tiles or {}

    if #self.tiles == 0 then -- gak ada tile? buat baru
        for y = 1, self.height do
            for x = 1, self.width do
                local t = { x=x, y=y, data={type="nothing",ec=1} }  -- type = "nothing" | "coffee" | "table", ec: energy consumtion, 
                table.insert(self.tiles, t)
            end
        end
    end

        if __debug then
        for i, tile in ipairs(self.tiles) do
            print("Tile_ID "..i.." : "..tile.x..","..tile.y.." | type: "..tile.data.type.." | ec: "..tile.data.ec)
        end
    end

    function self:draw()
        local size = self.tile_size
        for i, tile in ipairs(self.tiles) do
            love.graphics.rectangle("line", (tile.x-1)*size+self.x, (tile.y-1)*size+self.y, size, size)
        end
    end

    return self
end

return tile