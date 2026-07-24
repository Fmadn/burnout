local utility = {}

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