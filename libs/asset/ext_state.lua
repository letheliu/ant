local require = import and import(...) or require

local rawtable = require "rawtable"
local assetmgr = require "asset"

return function (filename)
	local fn = assetmgr.find_depiction_path(filename)
	return rawtable(fn)
end