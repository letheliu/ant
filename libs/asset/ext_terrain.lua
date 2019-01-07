local assetmgr = require "asset"
local rawtable = require "asset.rawtable"

-- terrain loader protocal 
return function (filename, param)
    local mesh = rawtable(assetmgr.find_depiction_path(filename))
    -- todo: terrain struct 
    -- or use extension file format outside
    return mesh
end
