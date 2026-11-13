-- Project-wide symbol index: functions, constructors, enums, macros and asset names.
-- Scanning is incremental (files are re-parsed only when their mtime/size changes).

local M = {}
local uv = vim.uv or vim.loop

local cfg = {
  required_dirs = { "objects", "scripts" }, -- a directory with all of these is a project root
  markers = { ".gm" },                      -- ...or one containing any of these
  source_dirs = { "objects", "scripts", "rooms" },
  asset_dirs = {
    "objects", "sprites", "sounds", "rooms", "scripts", "tilesets", "paths",
    "fonts", "shaders", "timelines", "sequences", "animcurves",
  },
}

local EMPTY = { functions = {}, constructors = {}, enums = {}, macros = {}, assets = {} }
local roots = {}    -- root -> { files = {}, index = {}, last = ms }
local bufroots = {} -- buf -> { name = , root = }

function M.setup(opts)
  for k, v in pairs(opts or {}) do cfg[k] = v end
end

local function isdir(p)
  local st = uv.fs_stat(p)
  return st ~= nil and st.type == "directory"
end

local function is_root(dir)
  for _, m in ipairs(cfg.markers) do
    if uv.fs_stat(dir .. "/" .. m) then return true end
  end
  if #cfg.required_dirs > 0 then
    local ok = true
    for _, d in ipairs(cfg.required_dirs) do
      if not isdir(dir .. "/" .. d) then ok = false break end
    end
    if ok then return true end
  end
  return #vim.fn.glob(dir .. "/*.yyp", false, true) > 0
end

function M.find_root(path)
  if not path or path == "" then return nil end
  for dir in vim.fs.parents(path) do
    if is_root(dir) then return dir end
  end
  return nil
end

function M.root_for(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local c = bufroots[buf]
  if c and c.name == name then return c.root end
  local root = M.find_root(name)
  bufroots[buf] = { name = name, root = root }
  return root
end

function M.forget_buffer(buf)
  bufroots[buf] = nil
end

---------------------------------------------------------------- parsing
local function parse_file(path)
  local out = { functions = {}, constructors = {}, enums = {}, macros = {} }
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return out end

  local src = table.concat(lines, "\n")
  src = src:gsub("/%*.-%*/", " "):gsub("//[^\n]*", "")

  for name in src:gmatch("enum%s+([%a_][%w_]*)%s*%b{}") do
    out.enums[name] = true
  end

  for name, tail in src:gmatch("function%s+([%a_][%w_]*)%s*%b()([^{}]-){") do
    out.functions[name] = true
    if tail:find("constructor", 1, true) then out.constructors[name] = true end
  end

  for name in ("\n" .. src):gmatch("\n%s*#macro%s+([%a_][%w_]*)") do
    out.macros[name] = true
  end

  return out
end

local function list_sources(root)
  local files = {}
  for _, dir in ipairs(cfg.source_dirs) do
    local p = root .. "/" .. dir
    if isdir(p) then
      vim.list_extend(files, vim.fn.globpath(p, "**/*.gml", true, true))
    end
  end
  return files
end

---------------------------------------------------------------- index
function M.refresh(root, force)
  local entry = roots[root]
  if not entry then
    entry = { files = {}, index = EMPTY, last = 0 }
    roots[root] = entry
  end

  local seen = {}
  for _, f in ipairs(list_sources(root)) do
    seen[f] = true
    local st = uv.fs_stat(f)
    if st then
      local stamp = st.mtime.sec .. ":" .. st.mtime.nsec .. ":" .. st.size
      local c = entry.files[f]
      if force or not c or c.stamp ~= stamp then
        c = parse_file(f)
        c.stamp = stamp
        entry.files[f] = c
      end
    end
  end
  for f in pairs(entry.files) do
    if not seen[f] then entry.files[f] = nil end
  end

  local idx = { functions = {}, constructors = {}, enums = {}, macros = {}, assets = {} }
  for _, d in pairs(entry.files) do
    for k in pairs(d.functions) do idx.functions[k] = true end
    for k in pairs(d.constructors) do idx.constructors[k] = true end
    for k in pairs(d.enums) do idx.enums[k] = true end
    for k in pairs(d.macros) do idx.macros[k] = true end
  end

  for _, dir in ipairs(cfg.asset_dirs) do
    local p = root .. "/" .. dir
    if isdir(p) then
      for _, name in ipairs(vim.fn.readdir(p)) do
        local base = name:gsub("%.[^.]*$", "")
        if base ~= "" then idx.assets[base] = true end
      end
    end
  end

  entry.index = idx
  entry.last = uv.now()
  return idx
end

function M.get(root)
  local entry = roots[root]
  if not entry then return M.refresh(root) end
  return entry.index
end

-- milliseconds since the last scan of this root
function M.age(root)
  local entry = roots[root]
  if not entry then return math.huge end
  return uv.now() - entry.last
end

function M.for_buffer(buf)
  local root = M.root_for(buf)
  if not root then return EMPTY end
  return M.get(root)
end

return M
