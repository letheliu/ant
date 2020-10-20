local ecs = ...
local world = ecs.world
local fbmgr 	= require "framebuffer_mgr"
local viewidmgr = require "viewid_mgr"

local vp_detect_sys = ecs.system "viewport_detect_system"

local icamera	= world:interface "ant.camera|camera"
local irq		= world:interface "ant.render|irenderqueue"
local eventResize = world:sub {"resize"}

local function resize_framebuffer(w, h, fbidx)
	if fbidx then
		local fb = fbmgr.get(fbidx)
		local changed = false
		local rbs = {}
		local ownerships = fb.ownerships
		for _, rbidx in ipairs(fb)do
			rbs[#rbs+1] = rbidx
			if ownerships == nil or (not ownerships[rbidx]) then
				changed = fbmgr.resize_rb(w, h, rbidx) or changed
			end
		end
		
		if changed then
			fbmgr.recreate(fbidx, {render_buffers = rbs, manager_buffer = fb.manager_buffer})
		end
	end
end

local function update_render_queue(q, viewsize)
	local rt = q.render_target
	local vr = rt.view_rect
	if viewsize then
		vr.w, vr.h = viewsize.w, viewsize.h
	end

	icamera.set_frustum_aspect(q.camera_eid, vr.w/vr.h)
	resize_framebuffer(vr.w, vr.h, rt.fb_idx)
end

local function rebind_uiruntime()
	local uiviewid = viewidmgr.get "uiruntime"

	local mq_eid = world:singleton_entity_id "main_queue"
	local fbidx = irq.frame_buffer(mq_eid)
	fbmgr.bind(uiviewid, fbidx)
end

local irq = world:interface "ant.render|irenderqueue"
local function rebind_viewid()
	for _, eid in world:each "render_target" do
		irq.update_rendertarget(world[eid].render_target)
	end

	rebind_uiruntime()
end

local function update_camera_viewrect(viewsize)
	local pdq = world:singleton_entity "pre_depth_queue"
	if pdq then
		update_render_queue(pdq, viewsize)
	end

	local mq = world:singleton_entity "main_queue"
	update_render_queue(mq, viewsize)

	local bq = world:singleton_entity "blit_queue"
	if bq then
		update_render_queue(bq, viewsize)
	end

	rebind_viewid()
end

function vp_detect_sys:post_init()
	update_camera_viewrect()
end

function vp_detect_sys:data_changed()
	local new_fbw, new_fbh
	for _, w, h in eventResize:unpack() do
		if w ~= 0 and h ~= 0 then
			new_fbw, new_fbh = w, h
		end
	end

	if new_fbw then
		update_camera_viewrect{w=new_fbw, h=new_fbh}
	end
end
