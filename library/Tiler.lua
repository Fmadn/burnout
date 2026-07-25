local tile = {}

function tile.new(pos_x, pos_y, tiles)
    local self = {}
    self.x = pos_x
    self.y = pos_y

    self.tiles = tiles or {}
    if #self.tiles == 0 then
        error("No tiles provided for the tile map.")
    end

    self.desks = {}
    self.coffees = {}
    for i, tile in ipairs(self.tiles) do
        if tile.type == "coffee" then
            table.insert(self.coffees, library.Coffee.new(tile.x, tile.y))
        elseif tile.type == "desk" then
            table.insert(self.desks, library.Table.new(tile.x, tile.y))
        end
    end

    if __debug then
        for i, tile in ipairs(self.tiles) do
            print("Tile_ID "..i.." : "..tile.x..","..tile.y.." | type: "..tile.type)
        end
    end

    function self:get_TileType(x, y)
        for i, tile in ipairs(self.tiles) do
            local tile_width = tile.width or 32
            local tile_height = tile.height or 32
            local tile_x = tile.x / tile_width
            local tile_y = tile.y / tile_height
            if tile_x == x and tile_y == y then
                return tile.type
            end
        end
        return "nil" -- Return nil if no tile is found at the given coordinates
    end

    function self:draw()
        love.graphics.setColor(1, 1, 1, 1)

        for i, tile in ipairs(self.tiles) do
            local tw = (tile.width or 32) * tile_size_mult
            local th = (tile.height or 32) * tile_size_mult

            local draw_x = tile.x * tile_size_mult + self.x
            local draw_y = tile.y * tile_size_mult + self.y - th  -- anchor bottom-left di Tiled

            if tile.type == "floor" then
                love.graphics.setColor(0.5, 0.5, 0.5)
            elseif tile.type == "coffee" then
                love.graphics.setColor(0.6, 0.3, 0)
            elseif tile.type == "desk" then
                love.graphics.setColor(0.3, 0.2, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end

            love.graphics.rectangle("fill", draw_x, draw_y, tw, th)

            love.graphics.setColor(0, 0, 0, 0.4)
            love.graphics.rectangle("line", draw_x, draw_y, tw, th)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
    
    return self
end

return tile