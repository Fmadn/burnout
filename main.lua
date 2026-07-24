function love.load()
    --// SERVICES \\--
    utility = require("utility/utility")
    
    --// VARIABLES \\--
    library = {}
    __debug = true

    --// INITIALIZATION \\--
    library = utility.load__library("library")

    --// TEST DOANG \\--
    tile = library.Tile.new(20,20,10,10,50)
end

function love.update()
    
end

function love.draw()
    tile:draw()
end