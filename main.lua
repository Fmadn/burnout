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
    local size = 60

    local width, height = 10, 10
    local tileWidth  = size * width
    local tileHeight = size * height
    tile = library.Tile.new(middle_x - tileWidth/2, middle_y - tileHeight/2, width, height, size)

    --// WINDOW \\--
    library.Push:setupScreen(game_Width, game_Height, wind_Width, wind_Height, {fullscreen = false, resizable = false})
end

function love.update()
    
end

function love.draw()
    library.Push:start()
        tile:draw()
    library.Push:finish()
end