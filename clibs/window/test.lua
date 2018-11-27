--dofile "libs/init.lua"

local native = require "window.native"

local window = require "window"
local bgfx = require "bgfx"

local width = 1024
local height = 768
local wnd = native.create(width,height,"Hello World")

local s_logo

bgfx.init {
	nwh = wnd,
--	renderer = "DIRECT3D9",
	renderer = "OPENGL",
	width = width,
	height = height,
	reset = "v",
}

bgfx.set_view_rect(0, 0, 0, width, height)
bgfx.set_view_clear(0, "CD", 0x303030ff, 1, 0)
bgfx.set_debug "ST"

local callback = {}

function callback.error(err)
	print(err)
end

function callback.move(x,y)
	print("MOVE", x, y)
end

function callback.mouse(what, press, x, y)
	print("mouse", what, press, x, y)
end

function callback.keypress(key, press, state)
	local ctrl = state & 0x01
	local alt = state & 0x02
	local shift = state & 0x04
	local sys = state & 0x08
	local leftOrright = state & 0x10
	print("KEYBOARD", key, "ctrl", ctrl, "alt", alt, "shift", shift, "sys", sys, "left|right", leftOrright, "is pressed", press)
end

local s_stats = {}
function callback.update()
	bgfx.touch(0)

	bgfx.dbg_text_clear()
	bgfx.dbg_text_image(math.max(width //2//8 , 20)-20
				, math.max(height//2//16, 6)-6
				, 40
				, 12
				, s_logo
				, 160
				)

	bgfx.dbg_text_print(0, 1, 0xf, "Color can be changed with ANSI \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.");
	local stats = bgfx.get_stats("sd",s_stats)
	bgfx.dbg_text_print(0, 2, 0x0f, string.format("Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters."
				, stats.width
				, stats.height
				, stats.textWidth
				, stats.textHeight
				))
	bgfx.frame()
end

function callback.exit()
	print("Exit")
	bgfx.shutdown()
end

window.register(callback)

local function init()
	s_logo = "\z
	\xdc\x03\xdc\x03\xdc\x03\xdc\x03\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdc\x08\z
	\xdc\x03\xdc\x07\xdc\x07\xdc\x08\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\xde\x03\xb0\x3b\xb1\x3b\xb2\x3b\xdb\x3b\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdc\x03\xb1\x3b\xb2\x3b\z
	\xdb\x3b\xdf\x03\xdf\x3b\xb2\x3f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb1\x3b\xb1\x3b\xb2\x3b\xb2\x3f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xb1\x3b\xb1\x3b\xb2\x3b\z
	\xb2\x3f\x20\x0f\x20\x0f\xdf\x03\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb1\x3b\xb1\x3b\xb1\x3b\xb1\x3f\xdc\x0b\xdc\x03\xdc\x03\z
	\xdc\x03\xdc\x03\x20\x0f\x20\x0f\xdc\x08\xdc\x03\xdc\x03\xdc\x03\z
	\xdc\x03\xdc\x03\xdc\x03\xdc\x08\x20\x0f\xb1\x3b\xb1\x3b\xb1\x3b\z
	\xb1\x3f\xb1\x3f\xb2\x0b\x20\x0f\x20\x0f\xdc\x03\xdc\x03\xdc\x03\z
	\x20\x0f\x20\x0f\xdc\x03\xdc\x03\xdc\x03\x20\x0f\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\x20\x0f\xde\x03\xb0\x3f\z
	\xb1\x3f\xb2\x3f\xdd\x03\xde\x03\xdb\x03\xdb\x03\xb2\x3f\x20\x0f\z
	\x20\x0f\xb0\x3f\xb1\x3f\xb2\x3f\xde\x38\xb2\x3b\xb1\x3b\xb0\x3b\z
	\xb0\x3f\x20\x0f\x20\x0f\x20\x0f\xb0\x3b\xb1\x3b\xb2\x3b\xb2\x3f\z
	\xdd\x03\xde\x03\xb0\x3f\xb1\x3f\xb2\x3f\xdd\x03\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\x20\x0f\x20\x0f\xdb\x03\z
	\xb0\x3f\xb1\x3f\xdd\x03\xb1\x3b\xb0\x3b\xdb\x03\xb1\x3f\x20\x0f\z
	\x20\x0f\x20\x3f\xb0\x3f\xb1\x3f\xb0\x3b\xb2\x3b\xb1\x3b\xb0\x3b\z
	\xb0\x3f\x20\x0f\x20\x0f\x20\x0f\xdc\x08\xdc\x3b\xb1\x3b\xb1\x3f\z
	\xb1\x3b\xb0\x3b\xb2\x3b\xb0\x3f\xdc\x03\x20\x0f\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\xdc\x0b\xdc\x07\xdb\x03\z
	\xdb\x03\xdc\x38\x20\x0f\xdf\x03\xb1\x3b\xb0\x3b\xb0\x3f\xdc\x03\z
	\xdc\x07\xb0\x3f\xb1\x3f\xb2\x3f\xdd\x3b\xb2\x3b\xb1\x3b\xdc\x78\z
	\xdf\x08\x20\x0f\x20\x0f\xde\x08\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\z
	\x20\x0f\xdf\x03\xb1\x3b\xb2\x3b\xdb\x03\xdd\x03\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdc\x08\xdc\x08\xdc\x08\x20\x0f\z
	\x20\x0f\xb0\x3f\xb0\x3f\xb1\x3f\xdd\x3b\xdb\x0b\xdf\x03\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdf\x08\xdf\x03\xdf\x03\xdf\x08\z
	\x20\x0f\x20\x0f\xdf\x08\xdf\x03\xdf\x03\x20\x0f\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdb\x08\xb2\x38\xb1\x38\xdc\x03\z
	\xdc\x07\xb0\x3b\xb1\x3b\xdf\x3b\xdf\x08\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x2d\x08\x3d\x08\x20\x0a\x43\x0b\x72\x0b\x6f\x0b\x73\x0b\x73\x0b\z
	\x2d\x0b\x70\x0b\x6c\x0b\x61\x0b\x74\x0b\x66\x0b\x6f\x0b\x72\x0b\z
	\x6d\x0b\x20\x0b\x72\x0b\x65\x0b\x6e\x0b\x64\x0b\x65\x0b\x72\x0b\z
	\x69\x0b\x6e\x0b\x67\x0b\x20\x0b\x6c\x0b\x69\x0b\x62\x0b\x72\x0b\z
	\x61\x0b\x72\x0b\x79\x0b\x20\x0f\x3d\x08\x2d\x08\x20\x01\x20\x0f\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
"
end

init()

native.mainloop()
