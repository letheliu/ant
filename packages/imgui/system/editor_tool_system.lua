local ecs = ...
local world = ecs.world
local HubEvent = require "hub_event"
local serialize = import_package 'ant.serialize'
local fs = require "filesystem"

local editor_tool_system = ecs.system "editor_tool_system"

local function run_script(str,env)
    local fun_str = str
    local fun = load(str,str,"bt",env)
    return fun()
end

local function on_receive_script(str)
    log.trace(str)
    local env = setmetatable( {ecs=ecs,world=world},{__index = _ENV} )
    local status,ret_val = xpcall(run_script, debug.traceback, str, env)
    log.trace("Run script result:",status,ret_val)
end

function editor_tool_system:init()
    local hub = world.args.hub
    hub.subscribe(HubEvent.RunScript,on_receive_script)
end
