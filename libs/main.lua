dofile "libs/init.lua"

local editor_mainwindow = require "editor.window"
local rhwi = require "render.hardware_interface"
local bgfx = require "bgfx"
local scene = require "scene.util"

editor_mainwindow.run {
	init_op = function (nwh, fbw, fbh, iq)
		rhwi.init(nwh, fbw, fbh)
		scene.start_new_world(iq, fbw, fbh, "test_world.module")
	end,
	shutdown_op = function ()
		bgfx.shutdown()
	end,

	fbw=1280, fbh=720,
}