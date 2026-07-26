local utility = {}
utility.Enum = {
    MoveDirection = {
        up = {0,1},
        down = {0,-1},
        left = {-1,0},
        right = {1,0}
    }
}

--[=[
    Mendapatkan format sebuah file.
    @param filename: string
    @return Format: string
]=]
function utility.get_format(filename)
    local extension = filename:match("^.+%.(.+)$")
    local name = filename:match("(.+)%..+")
    return extension, name
end

--[=[
    Mengkorvesi input WASD dalam bentuk arah gerak
    Enum.MoveDirection
    @param key: string
]=]
function utility.get_move_direction(key)
    if key == "w" then
        return utility.Enum.MoveDirection.up
    elseif key == "s" then
        return utility.Enum.MoveDirection.down
    elseif key == "a" then
        return utility.Enum.MoveDirection.left
    elseif key == "d" then
        return utility.Enum.MoveDirection.right
    else
        return nil
    end
end

--[=[
    Merubah waktu dari string
    menjadi bentuk angkanya.

    @param time: string
    @return time: number
]=]
function utility.day_to_num(time)
    time = string.lower(time)
    return time == "morning" and 1 or time == "afternoon" and 0.75 or time == "night" and 0.5
end

--[=[
    getarkan dua nilai.

    @param x: number
    @param y: number
    @param rang_min: number
    @param rang_max: number

    @return x, y: number, number
]=]
function utility.shake(x,y, rang_min, rang_max)
    return math.random(rang_min, rang_max) + x, math.random(rang_min, rang_max) + y
end

--[=[
    Ubah total_time jadi format
    jam palsu, mulai dari 07:00
    sampai ke 20:00
]=]
function utility.time_to_clock(time)

    --// CONFIGURATIONS \\ --
    local start_hour = 7
    local end_hour = 22
    --// \\ // \\ // \\ \\--

    local progress = time / _game.total_time              -- 0.0 - 1.0
    progress = math.clamp and math.clamp(progress, 0, 1) or math.min(math.max(progress, 0), 1)

    local total_minutes_range = (end_hour - start_hour) * 60  -- 13 jam = 780 menit
    local current_minutes = (start_hour * 60) + (progress * total_minutes_range)

    local hour = math.floor(current_minutes / 60)
    local minute = math.floor(current_minutes % 60)

    return string.format("%02d:%02d", hour, minute)
end

--[=[
    Ngebagi terus dua nilai
    berulang kali. Buat tween
    atau memperhalus aja....
]=]
function utility.lerp(a, b, t)
    return a + (b - a) * t
end

--[=[
    Ambil sebuah file tile hanya
    lewat nama.

    @param tile_name: string
    @return tile_file: {}
]=]
function utility.get_tile(tile_name)
    local tile_file = require("asset/maps/"..tile_name)
    return tile_file
end

--[=[
    Cek semua library
    dan load semuanya.

    @param library_location: string
    @return libraries: {}
]=]
function utility.load__library(library_location)
    local libraries = {}
    if type(library_location) ~= "string" or not love.filesystem.getInfo(library_location) then error("Library not found in: ".. (library_location or "NO_LOCATION_INTENDED")) end -- Jangan mulai (ERROR) karena library gak ada, waduh bahaya nih
    for _, library in pairs(love.filesystem.getDirectoryItems(library_location)) do
        local ext,nam = utility.get_format(library)
        if ext == "lua" then
            libraries[nam] = require(library_location.."/"..nam)
        end
    end
    return libraries
end

return utility