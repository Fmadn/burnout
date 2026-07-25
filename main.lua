function love.conf(t)
    t.window.width = 1080
    t.window.height = 720
end

function love.load()
    --// SERVICES \\--
    utility = require("utility/utility")

    --// INITIALIZATION \\--
    library = {}
    library = utility.load__library("library")
    
    --// VARIABLES \\--
    __debug = true
    game_Width, game_Height = 1080, 720 --fixed game resolution
    wind_Width, wind_Height = love.graphics.getDimensions()
    wind_scale = 0.9
    wind_Width, wind_Height = game_Width * wind_scale, game_Height * wind_scale

    --// TEST DOANG \\--
    middle_x, middle_y = game_Width / 2, game_Height / 2 -- pakai game_Width/game_Height, bukan wind_

    local size = 2
    
    local tile_width, tile_height = 32, 32
    local width, height = 10, 10
    local tilesWidth  = tile_width * width
    local tilesHeight = tile_height * height
    tile = library.Tile.new(middle_x - tilesWidth/2, middle_y - tilesHeight/2, width, height, tile_width, tile_height, utility.get_tile("tile_test").layers[2].objects)
    player = library.Player.new(5, 5) -- Contoh pembuatan player di posisi (5, 5)

    --// WINDOW \\--
    library.Push:setupScreen(game_Width, game_Height, wind_Width, wind_Height, {fullscreen = false, resizable = false})
end

function love.keypressed(key)
    -- // QUIT \\--
    if key == "escape" then
        love.event.quit()
    end

    --// LIBRARIES \\--
    player:began__input(key)
end

function love.update()
    
end

function love.draw()
    library.Push:start()
        tile:draw()
        player:draw()
    library.Push:finish()
end