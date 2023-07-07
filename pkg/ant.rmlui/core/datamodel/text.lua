local rmlui = require "rmlui"
local console = require "core.sandbox.console"

local m = {}

local function eval(data)
    return data.script:gsub('{%d+}', function(key)
        local code = data.code[key]
        if not code then
            return key
        end
        return code()
    end)
end

local function refresh(data, node)
    local res = eval(data)
    rmlui.TextSetText(node, res)
end


function m.load(datamodel, node, value)
    local n = 0
    local code = {}
    local variables
    local script = value:gsub('{{[^}]*}}', function(str)
        n = n + 1
        if not variables then
            local api = require "core.datamodel.api"
            variables = api.compileVariables(datamodel, node)
        end
        local key = ('{%d}'):format(n)
        local script = variables.."\nreturn "..str:sub(3, -3)
        local compiled, err = load(script, script, "t", datamodel.model)
        if not compiled then
            console.warn(err)
            return str
        end
        code[key] = compiled
        return key
    end)
    if n == 0 then
        datamodel.texts[node] = nil
        return
    end
    local data = {
        script = script,
        code = code,
    }
    datamodel.texts[node] = data
    refresh(data, node)
end

function m.refresh(datamodel)
    for node, data in pairs(datamodel.texts) do
        refresh(data, node)
    end
end

return m
