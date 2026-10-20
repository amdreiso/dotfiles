-- Heuristic knowledge about GameMaker built-ins. Not exhaustive on purpose:
-- functions are recognised by name prefix, so new runtime functions work automatically.

local M = {}

local function set(str)
  local t = {}
  for w in str:gmatch("%S+") do t[w] = true end
  return t
end

local function copy(t)
  local c = {}
  for k, v in pairs(t) do c[k] = v end
  return c
end

local function copy_list(t)
  local c = {}
  for i = 1, #t do c[i] = t[i] end
  return c
end

local BASE = {}

-- first segment (before the first "_") of built-in function names
BASE.function_prefixes = set [[
  draw ds instance array string audio sprite surface buffer layer room part physics
  file json os window display game gamepad keyboard mouse collision path tilemap
  camera view shader gpu matrix vertex font event network http async variable ini
  date steam time call method script asset object sequence animcurve timeline
  external skeleton texture virtual gesture clipboard weak is mp motion move place
  position point lengthdir distance make merge color colour show get sound
  background tile d3d base64 sha1 md5 random irandom alarm application screen
  gc debug parameter environment exception code
]]

BASE.functions = set [[
  abs ceil floor round sign sqrt sqr power exp ln log2 log10 logn min max mean
  median clamp lerp sin cos tan arcsin arccos arctan arctan2 dsin dcos dtan
  darcsin darccos darctan darctan2 degtorad radtodeg frac real string int64 bool
  ptr chr ord typeof instanceof method nameof randomize randomise choose
  angle_difference static_get static_set sleep
]]

BASE.variables = set [[
  x y id speed hspeed vspeed direction friction gravity gravity_direction
  image_index image_speed image_xscale image_yscale image_angle image_alpha
  image_blend image_number sprite_index sprite_width sprite_height
  sprite_xoffset sprite_yoffset mask_index depth visible solid persistent
  object_index xstart ystart xprevious yprevious bbox_left bbox_right bbox_top
  bbox_bottom layer alarm path_index path_position path_positionprevious
  path_speed path_scale path_orientation path_endaction timeline_index
  timeline_running timeline_speed timeline_position timeline_loop
  room room_width room_height room_speed room_persistent room_first room_last
  fps fps_real delta_time current_time current_year current_month current_day
  current_weekday current_hour current_minute current_second
  mouse_x mouse_y mouse_button mouse_lastbutton keyboard_key keyboard_lastkey
  keyboard_lastchar keyboard_string argument argument_count async_load event_data
  event_type event_number event_object view_current view_camera view_visible
  view_xport view_yport view_wport view_hport view_surface_id
  application_surface os_type os_device os_browser os_version working_directory
  program_directory temp_directory game_id game_display_name game_project_name
  game_save_id debug_mode error_occurred error_last cursor_sprite score lives
  health instance_count instance_id browser_width browser_height
  GM_build_date GM_version GM_runtime_version GM_build_type
]]

BASE.constant_prefixes = {
  "c_", "vk_", "mb_", "fa_", "bm_", "ev_", "gp_", "cr_", "pr_", "lb_", "tf_",
  "cull_", "cmpfunc_", "ds_type_", "buffer_", "audio_", "display_", "os_",
  "browser_", "layerelementtype_", "spritespeed_", "timesource_", "time_source_",
  "asset_", "ty_", "seqtracktype_", "seqplay_",
}

BASE.variable_prefixes = { "phy_" }

local active = {}

function M.configure(extra)
  extra = extra or {}
  active.function_prefixes = copy(BASE.function_prefixes)
  active.functions = copy(BASE.functions)
  active.variables = copy(BASE.variables)
  active.constants = {}
  active.constant_prefixes = copy_list(BASE.constant_prefixes)
  active.variable_prefixes = copy_list(BASE.variable_prefixes)

  for _, n in ipairs(extra.functions or {}) do active.functions[n] = true end
  for _, n in ipairs(extra.variables or {}) do active.variables[n] = true end
  for _, n in ipairs(extra.constants or {}) do active.constants[n] = true end
  for _, n in ipairs(extra.function_prefixes or {}) do active.function_prefixes[n] = true end
  for _, n in ipairs(extra.constant_prefixes or {}) do
    active.constant_prefixes[#active.constant_prefixes + 1] = n
  end
  for _, n in ipairs(extra.variable_prefixes or {}) do
    active.variable_prefixes[#active.variable_prefixes + 1] = n
  end
end

-- called with an identifier that is followed by "("
function M.is_function(name)
  if active.functions[name] then return true end
  local seg = name:match("^([%a%d]+)_")
  return seg ~= nil and active.function_prefixes[seg] == true
end

-- exact-name builtin functions only (used for bare references like callbacks)
function M.is_function_name(name)
  return active.functions[name] == true
end

local function has_prefix(list, name)
  for i = 1, #list do
    local p = list[i]
    if name:sub(1, #p) == p then return true end
  end
  return false
end

function M.is_variable(name)
  if active.variables[name] then return true end
  if name:find("^argument%d+$") then return true end
  return has_prefix(active.variable_prefixes, name)
end

function M.is_constant(name)
  if active.constants[name] then return true end
  return has_prefix(active.constant_prefixes, name)
end

M.configure()

return M
