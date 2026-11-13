-- Scope-aware classification of identifier tokens.
--
-- Pass 1 walks the token stream tracking function scopes, `var`/`static`/`globalvar`
-- declarations, function parameters, enums and macros declared in this buffer.
-- Pass 2 classifies every remaining identifier (local, param, call, property, ...).
-- Results are written to `tok.kind`.

local M = {}

local SKIP = {
  comment = true, doccomment = true, doctag = true, string = true,
  escape = true, number = true, regionname = true, tdelim = true,
}

-- punctuation that means "this statement continues on the next line"
local OPCHARS = {}
for c in ("=+-*/%&|^?:<>!([{,."):gmatch(".") do OPCHARS[c] = true end

local EMPTY = {}

function M.run(toks, env)
  local project = env.project or EMPTY
  local builtins = env.builtins
  local n = #toks

  local scope = { names = {} }
  local stack = {}          -- open function bodies: { parent = scope, depth = brace depth }
  local depth, nest = 0, 0  -- brace depth / any-bracket depth
  local pending             -- function header being parsed
  local declaring           -- active var/static/globalvar list
  local enum_st             -- enum declaration being parsed
  local catch_st            -- `catch (e)` tracking
  local prev                -- previous significant token
  local items, ni = {}, 0
  local file = { fns = {}, enums = {}, macros = {}, globals = {} }

  local function next_sig(i)
    for j = i + 1, math.min(n, i + 6) do
      if not SKIP[toks[j].t] then return toks[j] end
    end
  end

  ---------------------------------------------------------------- pass 1
  for i = 1, n do
    local tk = toks[i]
    local t = tk.t

    if not SKIP[t] then
      -- a var list without a trailing comma/operator ends at the end of the line
      if declaring and prev and prev.line < tk.line and nest == declaring.base
          and not (prev.t == "punct" and OPCHARS[prev.text])
          and not (prev.t == "keyword"
            and (prev.text == "var" or prev.text == "static" or prev.text == "globalvar")) then
        declaring = nil
      end

      if t == "eventid" then
        scope = { names = {} }
        stack = {}
        depth, nest = 0, 0
        pending, declaring, enum_st, catch_st = nil, nil, nil, nil

      elseif t == "keyword" then
        local w = tk.text
        if w == "function" then
          local fs = { names = {} }
          pending = { scope = fs, parent = scope, stage = "name", pn = 0, expect = false }
          scope = fs
        elseif w == "var" then
          declaring = { kind = "local", base = nest, expect = true }
        elseif w == "static" then
          declaring = { kind = "static", base = nest, expect = true }
        elseif w == "globalvar" then
          declaring = { kind = "globalvar", base = nest, expect = true }
        elseif w == "enum" then
          enum_st = { stage = "name" }
        elseif w == "catch" then
          catch_st = true
        end

      elseif t == "punct" then
        local c = tk.text
        if c == "(" or c == "[" then
          nest = nest + 1
          if pending then
            if pending.stage == "name" and c == "(" then
              pending.stage = "params"
              pending.pn = 1
              pending.expect = true
            elseif pending.stage == "params" then
              pending.pn = pending.pn + 1
            end
          end
          if catch_st == true and c == "(" then catch_st = "expect" end

        elseif c == ")" or c == "]" then
          nest = nest - 1
          if pending and pending.stage == "params" then
            pending.pn = pending.pn - 1
            if pending.pn == 0 then pending.stage = "after" end
          end

        elseif c == "{" then
          if pending and pending.stage == "after" then
            stack[#stack + 1] = { parent = pending.parent, depth = depth }
            pending = nil
          elseif enum_st and enum_st.stage == "before" then
            enum_st.stage = "body"
            enum_st.depth = depth
            enum_st.expect = true
            enum_st.nest = nest + 1
          end
          depth = depth + 1
          nest = nest + 1

        elseif c == "}" then
          nest = nest - 1
          depth = depth - 1
          local top = stack[#stack]
          if top and depth == top.depth then
            scope = top.parent
            stack[#stack] = nil
          end
          if enum_st and enum_st.stage == "body" and depth == enum_st.depth then
            enum_st = nil
          end

        elseif c == "," then
          if pending and pending.stage == "params" and pending.pn == 1 then
            pending.expect = true
          end
          if declaring and nest == declaring.base then declaring.expect = true end
          if enum_st and enum_st.stage == "body" and nest == enum_st.nest then
            enum_st.expect = true
          end

        elseif c == ";" then
          if declaring and nest <= declaring.base then declaring = nil end
        end

        if declaring and nest < declaring.base then declaring = nil end

      elseif t == "ident" then
        local name = tk.text
        local handled = false

        if prev and prev.t == "punct" and prev.text == "." then
          -- member access is never a declaration

        elseif prev and prev.t == "preproc" and prev.text == "#macro" then
          tk.kind = "macro"
          file.macros[name] = true
          handled = true

        elseif enum_st and enum_st.stage == "name" then
          tk.kind = "enumname"
          file.enums[name] = true
          enum_st.stage = "before"
          handled = true

        elseif enum_st and enum_st.stage == "body" and enum_st.expect and nest == enum_st.nest then
          tk.kind = "enumvalue"
          enum_st.expect = false
          handled = true

        elseif pending and pending.stage == "name" then
          local nx = next_sig(i)
          if nx and nx.t == "punct" and nx.text == "(" then
            tk.kind = "fndecl"
            file.fns[name] = true
            handled = true
          end

        elseif pending and pending.stage == "params" and pending.pn == 1 and pending.expect then
          pending.scope.names[name] = "param"
          tk.kind = "param"
          pending.expect = false
          handled = true

        elseif declaring and declaring.expect and nest == declaring.base then
          if declaring.kind == "globalvar" then
            file.globals[name] = true
          else
            scope.names[name] = declaring.kind
          end
          tk.kind = declaring.kind
          declaring.expect = false
          handled = true

        elseif catch_st == "expect" then
          scope.names[name] = "local"
          tk.kind = "local"
          catch_st = nil
          handled = true
        end

        if not handled then
          ni = ni + 1
          items[ni] = { i = i, scope = scope }
        end
      end

      prev = tk
    end
  end

  ---------------------------------------------------------------- pass 2
  local p_fns = project.functions or EMPTY
  local p_ctors = project.constructors or EMPTY
  local p_enums = project.enums or EMPTY
  local p_macros = project.macros or EMPTY
  local p_assets = project.assets or EMPTY

  for k = 1, ni do
    local it = items[k]
    local i = it.i
    local tk = toks[i]
    local name = tk.text
    local p1, p2, nx = toks[i - 1], toks[i - 2], toks[i + 1]
    local after_dot = p1 and p1.t == "punct" and p1.text == "."
    local call = nx and nx.t == "punct" and nx.text == "(" and nx.line == tk.line
    local kind

    if after_dot then
      if p2 and p2.t == "ident" and (p_enums[p2.text] or file.enums[p2.text]) then
        kind = "enumvalue"
      elseif p2 and p2.t == "keyword" and p2.text == "global" then
        kind = "globalvar"
      elseif call then
        kind = "method"
      else
        kind = "property"
      end
    elseif p1 and p1.t == "keyword" and p1.text == "new" then
      kind = "constructor"
    elseif nx and nx.t == "punct" and nx.text == ":" and nx.line == tk.line
        and p1 and p1.t == "punct" and (p1.text == "{" or p1.text == ",") then
      kind = "property" -- struct literal key
    elseif it.scope.names[name] then
      kind = it.scope.names[name]
    elseif call then
      if p_ctors[name] then
        kind = "constructor"
      elseif file.fns[name] or p_fns[name] then
        kind = "projfn"
      elseif builtins.is_function(name) then
        kind = "builtinfn"
      else
        kind = "call"
      end
    elseif p_enums[name] or file.enums[name] then
      kind = "enumname"
    elseif p_macros[name] or file.macros[name] then
      kind = "macro"
    elseif file.fns[name] or p_fns[name] then
      kind = "projfn"
    elseif file.globals[name] then
      kind = "globalvar"
    elseif p_assets[name] then
      kind = "asset"
    elseif builtins.is_variable(name) then
      kind = "builtinvar"
    elseif builtins.is_constant(name) then
      kind = "builtinconst"
    elseif builtins.is_function_name(name) then
      kind = "builtinfn"
    else
      kind = "variable"
    end

    tk.kind = kind
  end

  return file
end

return M
