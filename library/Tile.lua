local tile = {}

function tile.new(x, y, width, height, tile_width, tile_height, tiles)
    local self = {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.tile_width = tile_width
    self.tile_height = tile_height

    self.tiles = tiles or {}

    if #self.tiles == 0 then -- gak ada tile? buat baru
        for y = 1, self.height do
            for x = 1, self.width do
                local t = { x=x, y=y,type="floor" }  -- type = "nothing" | "coffee" | "table"
                table.insert(self.tiles, t)
            end
        end
    else
    local converted = {}
    for i, obj in ipairs(self.tiles) do
        -- convert dari koordinat piksel ke grid
        local gx = math.floor(obj.x / self.tile_width) + 1
        local gy = math.floor(obj.y / self.tile_height) + 1

        local t = {
            x = gx,
            y = gy,
            type = (obj.type ~= nil and obj.type ~= "" and obj.type) or "floor"
        }
        table.insert(converted, t)
    end
    self.tiles = converted
end

        if __debug then
        for i, tile in ipairs(self.tiles) do
            print("Tile_ID "..i.." : "..tile.x..","..tile.y.." | type: "..tile.type)
        end
    end

    function self:draw()
        local tile_width = self.tile_width
        local tile_height = self.tile_height
        for i, tile in ipairs(self.tiles) do
            if tile.type == "floor" then
                love.graphics.setColor(0.5, 0.5, 0.5) -- Grey for floor
            elseif tile.type == "coffee" then
                love.graphics.setColor(0.6, 0.3, 0) -- Brown for coffee
            elseif tile.type == "table" then
                love.graphics.setColor(0.3, 0.2, 0) -- Dark brown for table
            else
                love.graphics.setColor(0,0,0) -- Default to white for unknown types
            end

            love.graphics.rectangle("line", (tile.x-1)*tile_width+self.x, (tile.y-1)*tile_height+self.y, tile_width, tile_height)
        end
    end

    return self
end

return tile