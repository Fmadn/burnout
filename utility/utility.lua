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