function love.load()
    utility = require("utility/utility")

    love.graphics.setDefaultFilter("nearest", "nearest")

    library = {}
    library = utility.load__library("library")

    images = {}
    images.airla = love.graphics.newImage("asset/image/airla/AnimationSheet.png")
    images.floor = love.graphics.newImage("asset/image/floor.jpg")
    images.table = love.graphics.newImage("asset/image/table.png")
    images.coffee = love.graphics.newImage("asset/image/coffee.jpg")
    images.wall = love.graphics.newImage("asset/image/wall.jpg")
    images.chat = love.graphics.newImage("asset/image/chat.png")
    images.hud = love.graphics.newImage("asset/image/hud.png")
    images.lives = love.graphics.newImage("asset/image/lives.png")
    images.logo = love.graphics.newImage("asset/image/logo.png")
    images.vignette = love.graphics.newImage("asset/image/vignette.png")

    fonts = {}
    fonts.rust = love.graphics.newFont("asset/font/rust.ttf", 30)
    fonts.valveit = love.graphics.newFont("asset/font/valveit.otf", 10)
    fonts.w95f = love.graphics.newFont("asset/font/w95f.otf", 30)

    -- __debug = true
    game_Width, game_Height = 1080, 720
    wind_Width, wind_Height = love.graphics.getDimensions()
    wind_scale = 1
    wind_Width, wind_Height = game_Width * wind_scale, game_Height * wind_scale

    middle_x, middle_y = game_Width / 2, game_Height / 2

    tile_size_mult = 2
    TICK = 0
    __vignette = 0

    _game = {}
    _game.total_time = 400
    _game.intitle = false

    _game.__times = {
        morning   = _game.total_time / 3,           -- 3
        afternoon = (_game.total_time / 3) * 2,     -- 6
        night     = _game.total_time,               -- 9
    }

    function _game.get_phase(time)
        if time < _game.__times.morning then
            return "morning"
        elseif time < _game.__times.afternoon then
            return "afternoon"
        else
            return "night"
        end
    end
    _game.time = 0
    _game.time_s = "morning"
    _game.attempt = 3
    _game.game_over = false

    fade_alpha = 0

    tile_data = utility.get_tile("tile_test") -- simpan biar bisa dipake ulang

    library.Push:setupScreen(game_Width, game_Height, wind_Width, wind_Height, {fullscreen = false, resizable = false})

    -- _start__session()
    _start__titlescreen()
end

function recenter_tiles()
    tile_width, tile_height = tile_data.tilewidth * tile_size_mult, tile_data.tileheight * tile_size_mult
    tilesWidth, tilesHeight = tile_data.width * tile_width, tile_data.height * tile_height

    tiles.x = middle_x - tilesWidth/2
    tiles.y = middle_y - tilesHeight/2 + tile_height
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "space" then
        _start__session()
    end

    if key == "up" then
        tile_size_mult = tile_size_mult + 0.1
        recenter_tiles()
    elseif key == "down" then
        tile_size_mult = tile_size_mult - 0.1
        recenter_tiles()
    end
    
    if player then
        player:began__input(key)
    end
end

function love.update(dt)
    TICK = TICK + dt
    if tiles and player then
        if not _game.game_over then
            if _game.time >= _game.total_time then
                _game.game_over = true
                player:set__status("finish")
            else
                _game.time = _game.time + dt
                _game.time_s = _game.get_phase(_game.time)
            end
        end

        tiles:update(dt)

        for i = #tiles.desks, 1, -1 do
            local desk = tiles.desks[i]
            desk:update(dt)
            if player:get__status() == "gameover" or _game.game_over then
                table.remove(tiles.desks, i)
            end
        end

        for i = #tiles.coffees, 1, -1 do
            local coffee = tiles.coffees[i]
            if player:get__status() == "gameover" or _game.game_over then
                table.remove(tiles.coffees, i)
            end
        end

        player:update(dt)

        __vignette = utility.lerp(__vignette, 0, dt*2)
        tile_size_mult = utility.lerp(tile_size_mult, 2, dt*2)
        recenter_tiles()
        if fade_alpha > 0 and _game.time > 0.5 then
            fade_alpha = math.max(0, fade_alpha - dt/2)
        end
    end
end

function love.draw()
    library.Push:start()
    if tiles and player then
        tiles:draw()
        player:draw()
        for _, coffee in pairs(tiles.coffees) do
            coffee:draw()
        end
        for _, desk in pairs(tiles.desks) do
            desk:draw()
            end
            love.graphics.setFont(fonts.rust)
            love.graphics.setColor(0,0,0,1)
            love.graphics.print(utility.time_to_clock(_game.time), 35, 65, 0, 1.4, 1.4)
            love.graphics.print(_game.time_s, 40, 105, 0, 0.8, 0.8)
            love.graphics.setColor(1,1,1,1)
        end

        if _game.intitle then
            local title_x,title_y = utility.shake(100, 100, -1, 1)
            love.graphics.draw(images.logo, title_x, title_y, 0, 0.5,0.5)
            love.graphics.setFont(fonts.w95f)
            if math.floor(TICK) % 2 == 0 then
                love.graphics.print("PRESS [SPACE] TO START", 140, images.logo:getHeight()-50)
            end
        end

        -- FIX: cuma ini doang overlay-nya, buat transisi start (hitam -> transparan)
        love.graphics.setColor(0, 0, 0, fade_alpha)
        love.graphics.rectangle("fill", 0, 0, game_Width, game_Height)


        love.graphics.setColor(1, 1, 1, 1)
    library.Push:finish()
end

--// CUSTOM FUNCTIONS
function _start__session()
    tiles = library.Tiler.new(0, 0, tile_data.layers[2].objects)
    recenter_tiles()

    _game.attempt = 3
    _game.game_over = false
    _game.intitle = false
    _game.time = 0
    _game.time_s = "morning"

    player = library.Player.new(5, 4, 100)

    fade_alpha = 1 -- FIX: mulai dari hitam penuh
end

function _start__titlescreen()
    _game.intitle = true
end