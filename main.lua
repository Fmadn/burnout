function love.conf(t)
    t.window.width = 1080
    t.window.height = 720
end

function love.load()
    utility = require("utility/utility")

    library = {}
    library = utility.load__library("library")

    __debug = true
    game_Width, game_Height = 1080, 720
    wind_Width, wind_Height = love.graphics.getDimensions()
    wind_scale = 0.9
    wind_Width, wind_Height = game_Width * wind_scale, game_Height * wind_scale

    middle_x, middle_y = game_Width / 2, game_Height / 2

    tile_size_mult = 2
    tile_data = utility.get_tile("tile_test") -- simpan biar bisa dipake ulang

    tiles = library.Tiler.new(0, 0, tile_data.layers[2].objects)
    recenter_tiles()

    library.Push:setupScreen(game_Width, game_Height, wind_Width, wind_Height, {fullscreen = false, resizable = false})
end

function recenter_tiles()
    local tile_width, tile_height = tile_data.tilewidth * tile_size_mult, tile_data.tileheight * tile_size_mult
    local tilesWidth, tilesHeight = tile_data.width * tile_width, tile_data.height * tile_height

    tiles.x = middle_x - tilesWidth/2
    tiles.y = middle_y - tilesHeight/2 + tile_height
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "up" then
        tile_size_mult = tile_size_mult + 0.1
        recenter_tiles()
    elseif key == "down" then
        tile_size_mult = tile_size_mult - 0.1
        recenter_tiles()
    end
end

function love.update()
    
end

function love.draw()
    library.Push:start()
        tiles:draw()
        -- player:draw()
    library.Push:finish()
end