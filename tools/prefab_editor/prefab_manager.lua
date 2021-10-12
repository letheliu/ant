local ecs = ...
local world = ecs.world
local w = world.w
local worldedit     = import_package "ant.editor".worldedit(world)
local assetmgr      = import_package "ant.asset"
local stringify     = import_package "ant.serialize".stringify
local iom           = ecs.import.interface "ant.objcontroller|obj_motion"
local ies           = ecs.import.interface "ant.scene|ientity_state"
local ilight        = ecs.import.interface "ant.render|light"
local imaterial     = ecs.import.interface "ant.asset|imaterial"
local camera_mgr    = ecs.require "camera_manager"
local light_gizmo   = ecs.require "gizmo.light"
local gizmo         = ecs.require "gizmo.gizmo"
local geo_utils     = ecs.require "editor.geometry_utils"
local logger        = require "widget.log"
local math3d 		= require "math3d"
local fs            = require "filesystem"
local lfs           = require "filesystem.local"
local vfs           = require "vfs"
local hierarchy     = require "hierarchy_edit"
local widget_utils  = require "widget.utils"
local bgfx          = require "bgfx"
local gd            = require "common.global_data"
local utils         = require "common.utils"
local effekseer     = require "effekseer"
local subprocess    = import_package "ant.compile_resource".subprocess

local m = {
    entities = {}
}
local aabb_color_i <const> = 0x6060ffff
local aabb_color <const> = {1.0, 0.38, 0.38, 1.0}
local highlight_aabb_eid
function m:update_current_aabb(eid)
    if not eid then return end

    if not highlight_aabb_eid then
        highlight_aabb_eid = geo_utils.create_dynamic_aabb({}, "highlight_aabb", aabb_color, true)
    end
    w:sync("camera?in", eid)
    w:sync("light?in", eid)
    if eid.camera or eid.light then
        return
    end
    local aabb = nil
    w:sync("mesh?in", eid)
    local e = eid
    if e.mesh and e.mesh.bounding then
        local w = iom.worldmat(eid)
        aabb = math3d.aabb_transform(w, e.mesh.bounding.aabb)
    else
        local adaptee = hierarchy:get_select_adaptee(eid)
        for _, e in ipairs(adaptee) do
            if e.mesh and e.mesh.bounding then
                local newaabb = math3d.aabb_transform(iom.worldmat(e), e.mesh.bounding.aabb)
                aabb = aabb and math3d.aabb_merge(aabb, newaabb) or newaabb
            end
        end
    end

    if aabb then
        local v = math3d.tovalue(aabb)
        local aabb_shape = {min={v[1],v[2],v[3]}, max={v[5],v[6],v[7]}}
        local vb, ib = geo_utils.get_aabb_vb_ib(aabb_shape, aabb_color_i)
        local rc = world[highlight_aabb_eid]._rendercache
        local vbdesc, ibdesc = rc.vb, rc.ib
        bgfx.update(vbdesc.handles[1], 0, bgfx.memory_buffer("fffd", vb))
        ies.set_state(highlight_aabb_eid, "visible", true)
    end
end

function m:normalize_aabb()
    local aabb
    for _, e in ipairs(self.entities) do
        if e.mesh and e.mesh.bounding then
            local newaabb = math3d.aabb_transform(iom.worldmat(e), e.mesh.bounding.aabb)
            aabb = aabb and math3d.aabb_merge(aabb, newaabb) or newaabb
        end
    end

    if not aabb then return end

    local aabb_mat = math3d.tovalue(aabb)
    local min_x, min_y, min_z = aabb_mat[1], aabb_mat[2], aabb_mat[3]
    local max_x, max_y, max_z = aabb_mat[5], aabb_mat[6], aabb_mat[7]
    local s = 1/math.max(max_x - min_x, max_y - min_y, max_z - min_z)
    local t = {-(max_x+min_x)/2,-min_y,-(max_z+min_z)/2}
    local transform = math3d.mul(math3d.matrix{ s = s }, { t = t })
    iom.set_srt(self.root, math3d.mul(transform, iom.srt(self.root)))
end

local recorderidx = 0
local function gen_camera_recorder_name() recorderidx = recorderidx + 1 return "recorder" .. recorderidx end

local lightidx = 0
local function gen_light_id() lightidx = lightidx + 1 return lightidx end

local geometricidx = 0
local function gen_geometry_id() geometricidx = geometricidx + 1 return geometricidx end

local function create_light_billboard(light_eid)
    -- local bb_eid = world:deprecated_create_entity{
    --     policy = {
    --         "ant.render|render",
    --         "ant.effect|billboard",
    --         "ant.general|name"
    --     },
    --     data = {
    --         name = "billboard_light",
    --         transform = {},
    --         billboard = {lock = "camera"},
    --         state = 1,
    --         scene_entity = true,
    --         material = gd.editor_package_path .. "res/materials/billboard.material"
    --     },
    --     action = {
    --         bind_billboard_camera = "camera"
    --     }
    -- }
    -- local icons = require "common.icons"(assetmgr)
    -- local light_type = world[light_eid].light_type
    -- local light_icons = {
    --     spot = "ICON_SPOTLIGHT",
    --     point = "ICON_POINTLIGHT",
    --     directional = "ICON_DIRECTIONALLIGHT",
    -- }
    -- local tex = icons[light_icons[light_type]].handle
    -- imaterial.set_property(bb_eid, "s_basecolor", {stage = 0, texture = {handle = tex}})
    -- iom.set_scale(bb_eid, 0.2)
    -- ies.set_state(bb_eid, "auxgeom", true)
    -- iom.set_position(bb_eid, iom.get_position(light_eid))
    -- world[bb_eid].parent = world[light_eid].parent
    -- light_gizmo.billboard[light_eid] = bb_eid
end

local geom_mesh_file = {
    ["cube"] = "/pkg/ant.resources.binary/meshes/base/cube.glb|meshes/pCube1_P1.meshbin",
    ["cone"] = "/pkg/ant.resources.binary/meshes/base/cone.glb|meshes/pCone1_P1.meshbin",
    ["cylinder"] = "/pkg/ant.resources.binary/meshes/base/cylinder.glb|meshes/pCylinder1_P1.meshbin",
    ["sphere"] = "/pkg/ant.resources.binary/meshes/base/sphere.glb|meshes/pSphere1_P1.meshbin",
    ["torus"] = "/pkg/ant.resources.binary/meshes/base/torus.glb|meshes/pTorus1_P1.meshbin"
}

local default_collider_define = {
    ["sphere"] = {{origin = {0, 0, 0, 1}, radius = 0.1}},
    ["box"] = {{origin = {0, 0, 0, 1}, size = {0.05, 0.05, 0.05} }},
    ["capsule"] = {{origin = {0, 0, 0, 1}, height = 1.0, radius = 0.25}}
}

local function get_local_transform(tran, parent_eid)
    if not parent_eid then return tran end
    local parent_worldmat = iom.worldmat(parent_eid)
    local worldmat = math3d.matrix(tran)
    local s, r, t = math3d.srt(math3d.mul(math3d.inverse(parent_worldmat), worldmat))
    local ts, tr, tt = math3d.totable(s), math3d.totable(r), math3d.totable(t)
    return {s = {ts[1], ts[2], ts[3]}, r = {tr[1], tr[2], tr[3], tr[4]}, t = {tt[1], tt[2], tt[3]}}
end

local slot_entity_id = 1
function m:create_slot()
    --if not gizmo.target_eid then return end
    local auto_name = "empty" .. slot_entity_id
    local parent_eid = gizmo.target_eid or self.root
    local new_entity, temp = ecs.create_entity {
        policy = {
            "ant.general|name",
            "ant.general|tag",
            "ant.scene|slot",
            "ant.scene|scene_object",
        },
        data = {
            reference = true,
            scene = {srt = get_local_transform({}, parent_eid)},
            slot = true,
            follow_joint = "None",
            follow_flag = 1,
            name = auto_name,
            tag = {auto_name},
        }
    }
    slot_entity_id = slot_entity_id + 1
    self:add_entity(new_entity, parent_eid, temp)
    hierarchy:update_slot_list(world)
end

function m:create_collider(config)
    if config.type ~= "sphere" and config.type ~= "box" then return end
    local scale = {}
    local define = config.define or default_collider_define[config.type]
    if config.type == "sphere" then
        scale = define[1].radius * 100
    elseif config.type == "box" then
        local size = define[1].size
        scale = {size[1] * 200, size[2] * 200, size[3] * 200}
    elseif config.type == "capsule" then
    end
    local template = {
        policy = {
            "ant.general|name",
            "ant.render|render",
            "ant.scene|scene_object",
            "ant.general|tag",
        },
        data = {
            eid = 0,
            reference = true,
            name = "collider" .. gen_geometry_id(),
            tag = config.tag or {"collider"},
            scene = {srt = {s = scale}, parent = self.root},
            --color = {1, 0.5, 0.5, 0.5},
            state = ies.create_state "visible|selectable",
            material = "/pkg/ant.resources/materials/singlecolor_translucent.material",
            mesh = (config.type == "box") and geom_mesh_file["cube"] or geom_mesh_file[config.type],
            render_object = {},
            filter_material = {},
            -- on_init = function (e)
            -- end,
            -- on_ready = function (e)
            -- end
        }
    }
    local new_entity = ecs.create_entity(template)
    -- world[new_entity].collider = { [config.type] = define }
    -- imaterial.set_property(new_entity, "u_color", {1, 0.5, 0.5, 0.8})
    return new_entity, {__class = {template}}
end

local function create_simple_entity(name)
    local template = {
		policy = {
            "ant.general|name",
            "ant.scene|scene_object",
		},
		data = {
            reference = true,
            name = name,
            scene = {srt = {}}
		},
    }
    return ecs.create_entity(template), {__class = {template}}
end

function m:add_entity(new_entity, parent, temp, no_hierarchy)
    self.entities[#self.entities+1] = new_entity
    ecs.method.set_parent(new_entity, parent or self.root)
    if not no_hierarchy then
        hierarchy:add(new_entity, {template = temp.__class[1]}, parent)--world[new_entity].parent)
    end
end

function m:create(what, config)
    if not self.root then
        self:reset_prefab()
    end
    if what == "slot" then
        self:create_slot()
    elseif what == "camera" then
        local new_camera = camera_mgr.ceate_camera()
        self.new_camera[#self.new_camera + 1] = new_camera
    elseif what == "empty" then
        local new_entity, temp = create_simple_entity("empty" .. gen_geometry_id())
        self:add_entity(new_entity, gizmo.target_eid, temp)
    elseif what == "geometry" then
        if config.type == "cube"
            or config.type == "cone"
            or config.type == "cylinder"
            or config.type == "sphere"
            or config.type == "torus" then
            local parent_eid = config.parent or gizmo.target_eid
            local template = {
                policy = {
                    "ant.render|render",
                    "ant.general|name",
                    "ant.scene|scene_object",
                },
                data = {
                    eid = 0,
                    reference = true,
                    scene = {srt = get_local_transform({s = 50}, parent_eid)},
                    state = ies.create_state "visible|selectable",
                    material = "/pkg/ant.resources/materials/pbr_default.material",
                    mesh = geom_mesh_file[config.type],
                    render_object = {},
                    filter_material = {},
                    name = config.type .. gen_geometry_id()
                }
            }
            local new_entity = ecs.create_entity(template)

            --imaterial.set_property(new_entity, "u_color", {1, 1, 1, 1})
            self:add_entity(new_entity, parent_eid, {__class = {template}})
            return new_entity
        elseif config.type == "cube(prefab)" then
            m:add_prefab(gd.editor_package_path .. "res/cube.prefab")
        elseif config.type == "cone(prefab)" then
            m:add_prefab(gd.editor_package_path .. "res/cone.prefab")
        elseif config.type == "cylinder(prefab)" then
            m:add_prefab(gd.editor_package_path .. "res/cylinder.prefab")
        elseif config.type == "sphere(prefab)" then
            m:add_prefab(gd.editor_package_path .. "res/sphere.prefab")
        elseif config.type == "torus(prefab)" then
            m:add_prefab(gd.editor_package_path .. "res/torus.prefab")
        end
    elseif what == "enable_default_light" then
        if not self.default_light then
            local ilight = ecs.import.interface "ant.render|light" 
            local _, newlight = ilight.create({
                transform = {t = {0, 5, 0}, r = {math.rad(130), 0, 0}},
                name = "directional" .. gen_light_id(),
                light_type = "directional",
                color = {1, 1, 1, 1},
                intensity = 2,
                range = 1,
                make_shadow = false,
                motion_type = "dynamic",
                inner_radian = math.rad(45),
                outter_radian = math.rad(45)
            })
            self.default_light = newlight
        end
    elseif what == "disable_default_light" then
        if self.default_light then
            world:remove_entity(self.default_light[1])
            self.default_light = nil
        end
    elseif what == "light" then
        if config.type == "directional" or config.type == "point" or config.type == "spot" then      
            local ilight = ecs.import.interface "ant.render|light" 
            local _, newlight = ilight.create({
                transform = {t = {0, 3, 0},r = {math.rad(130), 0, 0}},
                name = config.type .. gen_light_id(),
                light_type = config.type,
                color = {1, 1, 1, 1},
                intensity = 2,
                range = 1,
                inner_radian = math.rad(45),
                outter_radian = math.rad(45),
                make_shadow = true
            })
            self:add_entity(newlight[1], self.root, newlight)
            create_light_billboard(newlight[1])
        end
    elseif what == "collider" then
        local new_entity, temp = self:create_collider(config)
        self:add_entity(new_entity, self.root, temp, not config.add_to_hierarchy)
        hierarchy:update_collider_list(world)
        return new_entity
    elseif what == "particle" then
        local entities = ecs.create_instance(gd.editor_package_path .. "res/particle.prefab")
        self:add_entity(entities[1], gizmo.target_eid, entities)
    end
end

function m:internal_remove(eid)
    for idx, e in ipairs(self.entities) do
        if e == eid then
            table.remove(self.entities, idx)
            return
        end
    end
end

local function set_select_adapter(entity_set, mount_root)
    for _, eid in ipairs(entity_set) do
        if type(eid) == "table" then
            set_select_adapter(eid, mount_root)
        else
            hierarchy:add_select_adapter(eid, mount_root)
        end
    end
end

local function remove_entitys(entities)
    for _, eid in ipairs(entities) do
        if type(eid) == "table" then
            remove_entitys(eid)
        else
            world:remove_entity(eid)
        end
    end
end

local function get_prefab(filename)
    assetmgr.unload(filename)
    return worldedit:prefab_template(filename)
end

local FBXTOGLB
function m:open_fbx(filename)
    if not FBXTOGLB then
        local f = assert(lfs.open(fs.path("editor.settings"):localpath()))
        local data = f:read "a"
        f:close()
        local datalist = require "datalist"
        local settings = datalist.parse(data)
        if lfs.exists(lfs.path(settings.BlenderPath .. "/blender.exe")) then
            FBXTOGLB = subprocess.tool_exe_path(settings.BlenderPath .. "/blender")
        else
            print("Can not find blender.")
            return
        end
    end

    local fullpath = tostring(lfs.current_path() / fs.path(filename):localpath())
    local scriptpath = tostring(lfs.current_path()) .. "/tools/prefab_editor/Export.GLB.py"
    local commands = {
		FBXTOGLB,
        "--background",
        "--python",
        scriptpath,
        "--",
        fullpath
	}
    local ok, msg = subprocess.spawn_process(commands)
	if ok then
		local INFO = msg:upper()
		for _, term in ipairs {
			"ERROR",
			"FAILED TO CONVERT FBX FILE"
		} do
			if INFO:find(term, 1, true) then
				ok = false
				break
			end
		end
	end
	if not ok then
		return false, msg
	end
    local prefabFilename = string.sub(filename, 1, string.find(filename, ".fbx")) .. "glb|mesh.prefab"
    self:open(prefabFilename)
end

local function split(str)
    local r = {}
    str:gsub('[^|]*', function (w) r[#r+1] = w end)
    return r
end

local function get_filename(pathname)
    pathname = pathname:lower()
    return pathname:match "[/]?([^/]*)$"
end

local function convert_path(path, glb_filename)
    if fs.path(path):is_absolute() then return path end
    local new_path
    if glb_filename then
        local pretty = tostring(lfs.path(path))
        if string.sub(path, 1, 2) == "./" then
            pretty = string.sub(path, 3)
        end
        new_path = glb_filename .. "|" .. pretty
    else
        -- local op_path = path
        -- local spec = string.find(path, '|')
        -- if spec then
        --     op_path = string.sub(path, 1, spec - 1)
        -- end
        -- new_path = tostring(lfs.relative(current_dir / lfs.path(op_path), new_dir))
        -- if spec then
        --     new_path = new_path .. string.sub(path, spec)
        -- end
    end
    return new_path
end

function m:open(filename)
    world:pub {"PreOpenPrefab", filename}
    local prefab = get_prefab(filename)
    local path_list = split(filename)
    local glb_filename
    if #path_list > 1 then
        glb_filename = path_list[1]
        for _, t in ipairs(prefab.__class) do
            if t.prefab then
                t.prefab = convert_path(t.prefab, glb_filename)
            else
                if t.data.material then
                    t.data.material = convert_path(t.data.material, glb_filename)
                end
                if t.data.mesh then
                    t.data.mesh = convert_path(t.data.mesh, glb_filename)
                end
                if t.data.meshskin then
                    t.data.meshskin = convert_path(t.data.meshskin, glb_filename)
                end
                if t.data.skeleton then
                    t.data.skeleton = convert_path(t.data.skeleton, glb_filename)
                end
                if t.data.animation then
                    local animation = t.data.animation
                    for k, v in pairs(t.data.animation) do
                        animation[k] = convert_path(v, glb_filename)
                    end
                end
            end
        end
    end
    self:open_prefab(prefab)
    world:pub {"WindowTitle", filename}
end

local function do_remove_entity(eid)
    if world[eid].light_type then
        light_gizmo.on_remove_light(eid)
    end
    if world[eid].skeleton_eid then
        world:remove_entity(world[eid].skeleton_eid)
    end
    local teml = hierarchy:get_template(eid)
    if teml and teml.children then
        remove_entitys(teml.children)
        -- for _, e in ipairs(teml.children) do
        --     world:remove_entity(e)
        -- end
    end
end

function m:reset_prefab()
    camera_mgr.clear()
    for _, eid in ipairs(self.entities) do
        if type(eid) == "table" then
            --camera
            camera_mgr.remove_camera(eid)
            world.w:remove(eid)
        else
            do_remove_entity(eid)
            world:remove_entity(eid)
        end
    end
    light_gizmo.clear()
    hierarchy:clear()
    anim_view.clear()
    self.root = create_simple_entity("scene root")
    self.prefab_script = ""
    self.entities = {}
    world:pub {"WindowTitle", ""}
    world:pub {"ResetEditor", ""}
    hierarchy:set_root(self.root)

    self.post_init_camera = {}
    self.new_camera = {}
end

function m:init_camera()
    if self.new_camera and #self.new_camera >= 1 then
        for _, eid in ipairs(self.new_camera) do
            if #eid == 0 then return end
            local t = iom.get_position(camera_mgr.main_camera)
            local r = iom.get_rotation(camera_mgr.main_camera)
            iom.set_position(eid, t)
            iom.set_rotation(eid, r)
            camera_mgr.update_frustrum(eid)
            camera_mgr.set_second_camera(eid, false)

            eid.template.data.transform = {s = {1,1,1}, r = {math3d.index(r, 1, 2, 3, 4)}, t = {math3d.index(t, 1, 2, 3)}}

            local recorder = icamera_recorder.start(gen_camera_recorder_name())
            camera_mgr.bind_recorder(eid, recorder)
            camera_mgr.add_recorder_frame(eid)
            local node = hierarchy:add(eid, {template = {
                policy = {
                    "ant.general|name",
                    "ant.general|tag",
                    "ant.camera|camera"
                },
                data = {
                    camera  = true,
                    frustum = eid.template.data.camera.frustum,
                    name    = eid.template.data.name,
                    scene   = {srt = {s = {1,1,1}, r = tr, t = tt}},
                    updir   = {0, 1, 0},
                    tag     = {"camera"}
                }
            }}, self.root)
            node.camera = true
            self.entities[#self.entities+1] = eid
        end
        self.new_camera = {}
    end
    if self.post_init_camera and #self.post_init_camera >= 1 then
        for _, eid in ipairs(self.post_init_camera) do
            if #eid == 0 then return end 
            camera_mgr.update_frustrum(eid)
            camera_mgr.show_frustum(eid, false)
        end
        self.post_init_camera = {}
    end
end

function m:open_prefab(prefab)
    self:reset_prefab()
    self.prefab = prefab
    local entities = worldedit:prefab_instance(prefab)
    self.entities = entities
    local template_class = prefab.__class
    for _, c in ipairs(template_class) do
        if c.script then
            self.prefab_script = c.script
            break
        end
    end
    local remove_entity = {}
    local add_entity = {}
    local last_camera
    for i, entity in ipairs(entities) do
        if type(entity) == "table" then
            if entity.root then
                local templ = hierarchy:get_template(entity.root)
                templ.filename = template_class[i].prefab
                set_select_adapter(entity, entity.root)
                templ.children = entity
                remove_entity[#remove_entity+1] = entity
            elseif #entity == 0 then
                -- camera
                hierarchy:add(entity, {template = template_class[i]}, self.root)
                self.post_init_camera[#self.post_init_camera + 1] = entity
            end
        else
            local keyframes = template_class[i].data.frames
            if keyframes and last_camera then
                local templ = hierarchy:get_template(last_camera)
                templ.keyframe = template_class[i]
                camera_mgr.bind_recorder(last_camera, entity)
                remove_entity[#remove_entity+1] = entity
            else
                if world[entity].collider then
                    local collider = world[entity].collider
                    local config = {}
                    if collider.sphere then
                        config.type = "sphere"
                        config.define = collider.sphere
                    elseif collider.box then
                        config.type = "box"
                        config.define = collider.box
                    end
                    local new_entity, temp = self:create_collider(config)
                    
                    if world[entity].parent and world[world[entity].parent].slot then
                        world[new_entity].slot_name = world[world[entity].parent].name
                    end
                    --world[new_entity].parent = world[entity].parent or self.root
                    ecs.method.set_parent(new_entity, world[entity].parent or self.root)
                    
                    hierarchy:add(new_entity, {template = temp.__class[1]}, world[new_entity].parent)
                    add_entity[#add_entity + 1] = new_entity
                    remove_entity[#remove_entity+1] = entity
                else
                    if world[entity].mesh then
                        ies.set_state(entity, "selectable", true)
                    end
                    hierarchy:add(entity, {template = template_class[i]}, world[entity].parent or self.root)
                end
            end
            if world[entity].camera then
                camera_mgr.update_frustrum(entity)
                camera_mgr.show_frustum(entity, false)
                last_camera = entity
            elseif world[entity].light_type then
                create_light_billboard(entity)
                light_gizmo.bind(entity)
                light_gizmo.show(false)
            elseif world[entity].collider then
                world:remove_entity(entity)
            end
        end
    end
    for _, e in ipairs(remove_entity) do
        self:internal_remove(e)
    end
    for _, e in ipairs(add_entity) do
        self.entities[#self.entities + 1] = e
    end

    anim_view.load_clips()
    camera_mgr.bind_main_camera()
end

function m:reload()
    -- local new_template = hierarchy:update_prefab_template()
    -- new_template[1].script = (#self.prefab_script > 0) and self.prefab_script or "/pkg/ant.prefab/default_script.lua"
    -- local prefab = utils.deep_copy(self.prefab)
    -- prefab.__class = new_template
    -- self:open_prefab(prefab)
    local filename = tostring(self.prefab)
    if filename == 'nil' then
        self:save_prefab(tostring(gd.project_root) .. "/res/__temp__.prefab")
    else
        self:open(filename)
    end
end

local nameidx = 0
local function gen_prefab_name() nameidx = nameidx + 1 return "prefab" .. nameidx end

function m:add_effect(filename)
    if not self.root then
        self:reset_prefab()
    end
    local tpl = {
		policy = {
            "ant.general|name",
            "ant.scene|scene_object",
            "ant.effekseer|effekseer",
            "ant.general|tag"
		},
		data = {
            reference = true,
            name = "root",
            tag = {"effect"},
            scene = {srt = {}},
            effekseer = filename,
            effect_instance = {},
            -- speed = 1.0,
            -- auto_play = false,
            -- loop = true
		},
    }
    local effect = ecs.create_entity(tpl)
    -- if world[effect].effect_instance.handle == -1 then
    --     print("create effect faild : ", filename)
    -- -- else
    -- --     local inst = world[effect].effect_instance
    -- --     inst.playid = effekseer.play(inst.handle, inst.playid)
    -- end
    self.entities[#self.entities+1] = effect
    local parent = gizmo.target_eid or self.root
    --world[effect].parent = gizmo.target_eid or self.root
    ecs.method.set_parent(effect, parent)
    hierarchy:add(effect, {template = tpl}, parent)
end

function m:add_prefab(filename)
    local prefab_filename = filename
    if string.sub(filename,-4) == ".glb" then
        prefab_filename = filename .. "|mesh.prefab"
    end
    
    if not self.root then
        self:reset_prefab()
    end
    local mount_root, temp = create_simple_entity(gen_prefab_name())
    self.entities[#self.entities+1] = mount_root
    local entities = ecs.create_instance(prefab_filename)
    ecs.method.set_parent(entities[1], mount_root)
    ecs.method.set_parent(mount_root, gizmo.target_eid or self.root)
    set_select_adapter(entities, mount_root)
    hierarchy:add(mount_root, {filename = prefab_filename, template = temp.__class[1], children = entities}, world[mount_root].parent)
end

function m:recreate_entity(eid)
    local prefab = hierarchy:get_template(eid)
    world:rebuild_entity(eid, prefab.template)
    
    -- local copy_prefab = utils.deep_copy(prefab)
    -- local new_eid = world:deprecated_create_entity(copy_prefab.template)
    -- iom.set_srt(new_eid, iom.srt(eid))
    local scale = 1
    local col = world[eid].collider
    if col then
        if col.sphere then
            scale = col.sphere[1].radius * 100
        elseif col.box then
            local size = col.box[1].size
            scale = {size[1] * 200, size[2] * 200, size[3] * 200}
        else
        end
        imaterial.set_property(eid, "u_color", {1, 0.5, 0.5, 0.5})
    end
    -- iom.set_scale(new_eid, scale)
    -- local new_node = hierarchy:replace(eid, new_eid)
    -- world[new_eid].parent = new_node.parent
    -- for _, v in ipairs(new_node.children) do
    --     world[v.eid].parent = new_eid
    -- end
    -- local idx
    -- for i, e in ipairs(self.entities) do
    --     if e == eid then
    --         idx = i
    --         break
    --     end
    -- end
    -- self.entities[idx] = new_eid
    -- world:remove_entity(eid)
    -- local gizmo = require "gizmo.gizmo"(world)
    -- gizmo:set_target(new_eid)
    world:pub {"EntityRecreate", eid}
    -- return new_eid
end

function m:update_material(eid, mtl)
    local prefab = hierarchy:get_template(eid)
    prefab.template.data.material = mtl
    self:save_prefab()
    self:reload()
end

local utils = require "common.utils"

function m:save_prefab(path)
    local filename
    if not path then
        if not self.prefab or (string.find(tostring(self.prefab), "__temp__")) then
            filename = widget_utils.get_saveas_path("Prefab", "prefab")
            if not filename then return end
        end
    end
    if path then
        filename = string.gsub(path, "\\", "/")
        local pos = string.find(filename, "%.prefab")
        if #filename > pos + 6 then
            filename = string.sub(filename, 1, pos + 6)
        end
    end
    local prefab_filename = self.prefab and tostring(self.prefab) or ""
    filename = filename or prefab_filename
    local saveas = (lfs.path(filename) ~= lfs.path(prefab_filename))

    local new_template = hierarchy:update_prefab_template(world)
    new_template[1].script = (#self.prefab_script > 0) and self.prefab_script or "/pkg/ant.prefab/default_script.lua"
    
    if not saveas then
        local path_list = split(prefab_filename)
        local glb_filename
        if #path_list > 1 then
            glb_filename = path_list[1]
        end
        if glb_filename then
            local msg = "cann't save glb file, please save as prefab"
            logger.error({tag = "Editor", message = msg})
            widget_utils.message_box({title = "SaveError", info = msg})
        else
            utils.write_file(filename, stringify(new_template))
            anim_view.save_clip()
        end
        return
    end
    utils.write_file(filename, stringify(new_template))
    anim_view.save_clip(string.sub(filename, 1, -8) .. ".clips")
    self:open(filename)
    world:pub {"ResourceBrowser", "dirty"}
end

function m:remove_entity(eid)
    if not eid then return end
    do_remove_entity(eid)
    world:remove_entity(eid)
    hierarchy:del(eid)
    hierarchy:update_slot_list(world)
    hierarchy:update_collider_list(world)
    self:internal_remove(eid)
    gizmo.target_eid = nil
end

function m:get_current_filename()
    return tostring(self.prefab)
end

function m.set_anim_view(aview)
    anim_view = aview
end

return m