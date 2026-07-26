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

    self.__style = {}
    self.__style.transparency = 1

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

    function self:update(dt)
        if _game.game_over then
            self.__style.transparency = utility.lerp(self.__style.transparency, 0, dt*5)
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
        love.graphics.setColor(1, 1, 1, self.__style.transparency)

        for i, tile in ipairs(self.tiles) do
            local tw = (tile.width or 32) * tile_size_mult
            local th = (tile.height or 32) * tile_size_mult

            local draw_x = tile.x * tile_size_mult + self.x
            local draw_y = tile.y * tile_size_mult + self.y - th

            local texture = images.floor  -- default

            love.graphics.setColor(1, 1, 1, self.__style.transparency)
            if tile.type == "floor" then
                texture = images.floor
            elseif tile.type == "coffee" then
                texture = images.coffee
            elseif tile.type == "desk" then
                texture = images.table
            elseif tile.type == "wall" then
                texture = images.wall
            end

            local img_width, img_height = texture:getWidth(), texture:getHeight()

            love.graphics.rectangle("fill", draw_x, draw_y, tw, th)

            local scale_x = tw / img_width
            local scale_y = th / img_height
            love.graphics.draw(texture, draw_x, draw_y, 0, scale_x, scale_y)

            love.graphics.setColor(0, 0, 0, 0.4)
            love.graphics.rectangle("line", draw_x, draw_y, tw, th)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
    
    return self
end

return tile