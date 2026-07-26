function love.load()
    utility = require("utility/utility")

    love.graphics.setDefaultFilter("nearest", "nearest")

    library = {}
    library = utility.load__library("library")


    --// DONT BE SHOCKED.... PLS.. :(
    images = {}
    images.airla = love.graphics.newImage("asset/image/airla/spritesheet (1).png")
    images.floor = love.graphics.newImage("asset/image/floor.jpg")
    images.table = love.graphics.newImage("asset/image/table.png")
    images.coffee = love.graphics.newImage("asset/image/coffee.jpg")
    images.wall = love.graphics.newImage("asset/image/wall.jpg")
    images.chat = love.graphics.newImage("asset/image/chat.png")
    images.hud = love.graphics.newImage("asset/image/hud.png")
    images.lives = love.graphics.newImage("asset/image/lives.png")
    images.logo = love.graphics.newImage("asset/image/logo.png")
    images.vignette = love.graphics.newImage("asset/image/vignette.png")
    images.tutorial = love.graphics.newImage("asset/image/tutorial.png")

    fonts = {}
    fonts.rust = love.graphics.newFont("asset/font/rust.ttf", 30)
    fonts.valveit = love.graphics.newFont("asset/font/valveit.otf", 10)
    fonts.w95f = love.graphics.newFont("asset/font/w95f.otf", 30)

    sounds = {}
    sounds.drink = love.audio.newSource("asset/sounds/drink.wav", "static")
    sounds.work = love.audio.newSource("asset/sounds/work.wav", "static")
    sounds.fail = love.audio.newSource("asset/sounds/fail.wav", "static")
    sounds.notification = love.audio.newSource("asset/sounds/notification.wav", "static")
    sounds.win = love.audio.newSource("asset/sounds/win.mp3", "static")

    musics = {}
    musics.gameover  = {love.audio.newSource("asset/music/gameover.mp3", "stream"), false, volume = 0, target = 0}
    musics.morning   = {love.audio.newSource("asset/music/morning.mp3", "stream"), false, volume = 0, target = 0}
    musics.afternoon = {love.audio.newSource("asset/music/afternoon.mp3", "stream"), false, volume = 0, target = 0}
    musics.night     = {love.audio.newSource("asset/music/night.mp3", "stream"), false, volume = 0, target = 0}
    

    -- __debug = true
    game_Width, game_Height = 1080, 720
    wind_Width, wind_Height = love.graphics.getDimensions()
    wind_scale = 1
    wind_Width, wind_Height = game_Width * wind_scale, game_Height * wind_scale

    middle_x, middle_y = game_Width / 2, game_Height / 2

    tile_size_mult = 2
    TICK = 0
    __vignette = 0
    TUTORIAL = true

    _game = {}
    _game.finish_time = 0
    _game.total_time = 200
    _game.intitle = false

    _game.__win_texts = {
        {time = 1, text = "YOU WIN!",              played = false},
        {time = 2, text = "TOTAL MOVED",            played = false},
        {time = 3, text = "TOTAL JOB",              played = false},
        {time = 4, text = "TOTAL COFFEE",           played = false},
    }

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

    function _game.play_BGM()
        local target_name = _game.time_s -- "morning"/"afternoon"/"night"

        for name, music in pairs(musics) do
            if name ~= "gameover" then
                if name == target_name then
                    if not music[2] then
                        music[1]:setLooping(true)
                        music[1]:setVolume(0)
                        music[1]:play()
                        music[2] = true
                    end
                    music.target = 1 
                else
                    music.target = 0 
                end
            end
        end
    end

    function _game.update_music_fade(dt)
        local fade_speed = 1 -- makin gede, makin cepet transisinya (1 = ~1 detik)

        for name, music in pairs(musics) do
            if name ~= "gameover" then
                music.volume = utility.lerp(music.volume, music.target, dt * fade_speed)
                music[1]:setVolume(music.volume)

                -- kalau target 0 dan volume udah nyaris 0, baru bener2 stop
                if music.target == 0 and music.volume < 0.01 and music[2] then
                    music[1]:stop()
                    music[2] = false
                end
            end
        end
    end

    _game.time = 0
    _game.time_s = "morning"
    _game.gameover_time = 0
    _game.attempt = 3
    _game.game_over = false

    finish_sound = false

    fade_alpha = 0

    -- tile_data = utility.get_tile("tile_test") -- simpan biar bisa dipake ulang
    tile_data = utility.get_random_tile()

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

    if __debug then
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
    else
        if key == "space" and _game.game_over or _game.intitle then
            _start__session()
        end
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
                if not finish_sound then
                    finish_sound = true
                    sounds.win:play()
                end

                for name, music in pairs(musics) do
                    if name ~= "gameover" then
                        music.target = 0
                    end
                end
            else
                local prev_phase = _game.time_s
                _game.time = _game.time + dt
                _game.time_s = _game.get_phase(_game.time)

                if _game.time_s ~= prev_phase then
                    _game.play_BGM()
                end
            end
        else
            _game.gameover_time = _game.gameover_time + dt
        end

        _game.update_music_fade(dt) 

        if player:get__status() == "finish" then
            _game.finish_time = _game.finish_time + dt
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

        if player:get__status() == "finish" then
            love.graphics.setFont(fonts.valveit)

            local labels = {
                "YOU WIN!",
                "TOTAL MOVED | "..(player.__tile_moved or 0),
                "TOTAL JOB | "..(player.__job_completed or 0),
                "TOTAL COFFEE | "..(player.__coffee_drunk or 0),
            }

            for i, entry in ipairs(_game.__win_texts) do
                if _game.finish_time > entry.time then
                    love.graphics.print(labels[i], 20, 20 + (i-1)*80, nil, i == 1 and 6 or 5, i == 1 and 6 or 5)

                    if not entry.played then
                        local s = sounds.work:clone()
                        s:play()
                        entry.played = true
                    end
                end
            end

            if _game.finish_time > 6 then
                love.graphics.print("PRESS [SPACE] TO PLAY AGAIN", 20, 600, nil, 4, 4)
            end
        end

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
            if player:get__status() == "active" then
                love.graphics.print(utility.time_to_clock(_game.time), 35, 65, 0, 1.4, 1.4)
                love.graphics.print(_game.time_s, 40, 105, 0, 0.8, 0.8)
            end

            love.graphics.setColor(1,1,1,1)
        end

        if _game.intitle then
            love.graphics.rectangle('fill',0,0,game_Width,game_Height)
            local title_x,title_y = utility.shake(100, 100, -1, 1)
            love.graphics.draw(images.logo, title_x, title_y, 0, 0.5,0.5)
            love.graphics.setFont(fonts.w95f)
            love.graphics.setColor(0.25,0.25,0.25,1)
            if math.floor(TICK) % 2 == 0 then
                love.graphics.print("PRESS [ANY] TO START", 140, images.logo:getHeight()-50)
            end
        end

        

        if not _game.intitle and TUTORIAL and player:get__status() == "active" then
            local tutorial_image = images.tutorial

            local tutorial_scale = 0.34
            local tutorial_width, tutorial_height = tutorial_image:getWidth(), tutorial_image:getHeight()

            local tutorial_drawX = (game_Width - (tutorial_width * tutorial_scale)) / 2
            local tutorial_drawY = (game_Height - (tutorial_height * tutorial_scale)) / 2

            love.graphics.setColor(1,1,1,0.9)
            love.graphics.draw(tutorial_image, tutorial_drawX, tutorial_drawY, 0, tutorial_scale, tutorial_scale) -- FIX: scale ditambahin di sini
        end

        love.graphics.setColor(0, 0, 0, fade_alpha)
        love.graphics.rectangle("fill", 0, 0, game_Width, game_Height)
        

        love.graphics.setColor(1, 1, 1, 1)
    library.Push:finish()
end

--// CUSTOM FUNCTIONS
function _start__session()
    tiles = library.Tiler.new(0, 0, tile_data.layers[2].objects)
    recenter_tiles()

    finish_sound = false

    tile_data = utility.get_random_tile()

    _game.attempt = 3
    _game.game_over = false
    _game.intitle = false
    _game.time = 0
    _game.time_s = "morning"
    _game.gameover_time = 0
    _game.finish_time = 0

    if musics.gameover[2] then
        musics.gameover[1]:stop()
        musics.gameover[2] = false
    end
 
    for _, entry in ipairs(_game.__win_texts) do
        entry.played = false
    end

    local spawnX, spawnY = tile_data.spawnX or 1, tile_data.spawnY or 1
    player = library.Player.new(spawnX, spawnY, 100)

    fade_alpha = 1

    _game.play_BGM()
end

function _start__titlescreen()
    _game.intitle = true
end