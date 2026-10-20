local lexer = require("gml.lexer")
local analyze = require("gml.analyze")
local builtins = require("gml.builtins")
local project = require("gml.project")

local M = {}

local uv = vim.uv or vim.loop
local ns = vim.api.nvim_create_namespace("gml_highlight")
local state = {} -- buf -> { toks = , timer = }

local defaults = {
  priority = 120,       -- extmark priority of the highlights
  debounce = 60,        -- ms to wait after an edit before re-highlighting
  max_lines = 20000,    -- skip highlighting for huge buffers
  commentstring = true, -- set commentstring to "// %s" for gml buffers
  highlights = {},      -- { GmlGroup = { fg = "#rrggbb", ... } | "LinkTarget" }
  project = {},         -- see lua/gml/project.lua (source_dirs, asset_dirs, ...)
  builtins = {},        -- { functions = {}, variables = {}, constants = {}, *_prefixes = {} }
}

M.config = vim.deepcopy(defaults)

-- token kind -> highlight group
local GROUP = {
  keyword = "GmlKeyword",
  constant = "GmlConstant",
  number = "GmlNumber",
  string = "GmlString",
  escape = "GmlEscape",
  comment = "GmlComment",
  doccomment = "GmlDocComment",
  doctag = "GmlDocTag",
  preproc = "GmlPreproc",
  regionname = "GmlRegion",
  eventid = "GmlID",
  tdelim = "GmlTemplateDelim",
  -- identifiers
  ["local"] = "GmlLocalVariable",
  param = "GmlParameter",
  static = "GmlStaticVariable",
  variable = "GmlVariable",
  property = "GmlProperty",
  globalvar = "GmlGlobalVariable",
  call = "GmlFunction",
  method = "GmlMethod",
  projfn = "GmlProjectFunction",
  builtinfn = "GmlBuiltinFunction",
  fndecl = "GmlFunctionDecl",
  constructor = "GmlConstructor",
  enumname = "GmlEnumName",
  enumvalue = "GmlEnumValue",
  macro = "GmlMacro",
  asset = "GmlAsset",
  builtinvar = "GmlBuiltinVariable",
  builtinconst = "GmlBuiltinConstant",
}

-- default links; override any of them through `highlights` in setup()
local LINKS = {
  GmlKeyword = "Keyword",
  GmlConstant = "Constant",
  GmlNumber = "Number",
  GmlString = "String",
  GmlEscape = "SpecialChar",
  GmlComment = "Comment",
  GmlDocComment = "Comment",
  GmlDocTag = "Special",
  GmlPreproc = "PreProc",
  GmlRegion = "Title",
  GmlID = "Title",
  GmlTemplateDelim = "Delimiter",
  GmlVariable = "Identifier",
  GmlProperty = "GmlVariable",
  GmlGlobalVariable = "GmlVariable",
  GmlLocalVariable = "Special",
  GmlParameter = "GmlLocalVariable",
  GmlStaticVariable = "GmlLocalVariable",
  GmlBuiltinVariable = "Type",
  GmlFunction = "Function",
  GmlMethod = "GmlFunction",
  GmlProjectFunction = "GmlFunction",
  GmlBuiltinFunction = "GmlFunction",
  GmlFunctionDecl = "GmlFunction",
  GmlConstructor = "Type",
  GmlEnumName = "Type",
  GmlEnumValue = "Constant",
  GmlMacro = "Macro",
  GmlAsset = "Structure",
  GmlBuiltinConstant = "Constant",
}

local function apply_highlights()
  for group, target in pairs(LINKS) do
    vim.api.nvim_set_hl(0, group, { link = target, default = true })
  end
  for group, spec in pairs(M.config.highlights) do
    if type(spec) == "string" then
      vim.api.nvim_set_hl(0, group, { link = spec })
    else
      vim.api.nvim_set_hl(0, group, spec)
    end
  end
end

---------------------------------------------------------------- highlighting
function M.update(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.api.nvim_buf_line_count(buf) > M.config.max_lines then return end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local ok, toks = pcall(function()
    local t = lexer.lex(lines)
    analyze.run(t, { project = project.for_buffer(buf), builtins = builtins })
    return t
  end)
  if not ok then
    vim.notify_once("gml.nvim: " .. tostring(toks), vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local base = M.config.priority
  for i = 1, #toks do
    local tk = toks[i]
    local group = GROUP[tk.kind or tk.t]
    if group then
      vim.api.nvim_buf_set_extmark(buf, ns, tk.line, tk.col, {
        end_col = tk.ecol,
        hl_group = group,
        priority = base + (tk.prio or 0),
        strict = false,
      })
    end
  end

  state[buf] = state[buf] or {}
  state[buf].toks = toks
end

local function schedule(buf)
  local st = state[buf]
  if not st then return end
  if not st.timer then st.timer = uv.new_timer() end
  st.timer:stop()
  st.timer:start(M.config.debounce, 0, vim.schedule_wrap(function()
    M.update(buf)
  end))
end

local function detach(buf)
  local st = state[buf]
  if st and st.timer then
    st.timer:stop()
    if not st.timer:is_closing() then st.timer:close() end
  end
  state[buf] = nil
  project.forget_buffer(buf)
  pcall(vim.api.nvim_del_augroup_by_name, "GmlHighlight" .. buf)
end

local function attach(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  state[buf] = state[buf] or {}

  local group = vim.api.nvim_create_augroup("GmlHighlight" .. buf, { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = buf,
    callback = function() schedule(buf) end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    buffer = buf,
    callback = function() vim.schedule(function() M.refresh() end) end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function() detach(buf) end,
  })

  if M.config.commentstring then
    vim.bo[buf].commentstring = "// %s"
  end

  M.update(buf)
end

-- Re-scan project symbols (incrementally) and re-highlight every gml buffer.
function M.refresh(force)
  local done = {}
  for buf in pairs(state) do
    local root = project.root_for(buf)
    if root and not done[root] then
      project.refresh(root, force)
      done[root] = true
    end
  end
  for buf in pairs(state) do M.update(buf) end
end

---------------------------------------------------------------- setup
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  builtins.configure(M.config.builtins)
  project.setup(M.config.project)

  vim.filetype.add({ extension = { gml = "gml" } })
  apply_highlights()

  local aug = vim.api.nvim_create_augroup("Gml", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = aug,
    pattern = "gml",
    callback = function(args) attach(args.buf) end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = aug,
    callback = function()
      apply_highlights()
    end,
  })

  -- pick up changes made outside of Neovim (git, `glim sync`, GameMaker itself)
  vim.api.nvim_create_autocmd("FocusGained", {
    group = aug,
    callback = function() M.refresh() end,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = aug,
    pattern = "*.gml",
    callback = function(args)
      local root = project.root_for(args.buf)
      if root and project.age(root) > 3000 then
        project.refresh(root)
        M.update(args.buf)
      end
    end,
  })

  vim.api.nvim_create_user_command("GmlRefresh", function()
    M.refresh(true)
  end, { desc = "Re-scan the GameMaker project and re-highlight" })

  vim.api.nvim_create_user_command("GmlInspect", function()
    local buf = vim.api.nvim_get_current_buf()
    local st = state[buf]
    if not st or not st.toks then
      print("gml.nvim: buffer is not highlighted")
      return
    end
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1] - 1, pos[2]
    for _, tk in ipairs(st.toks) do
      if tk.line == row and col >= tk.col and col < tk.ecol then
        local key = tk.kind or tk.t
        print(("%s  ->  %s"):format(key, GROUP[key] or "(no group)"))
        return
      end
    end
    print("gml.nvim: no token under cursor")
  end, { desc = "Show how gml.nvim classified the token under the cursor" })

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "gml" then
      attach(buf)
    end
  end
end

return M
