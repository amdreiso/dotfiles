-- Tokenizer for GameMaker Language.
-- Produces a flat, ordered list of tokens:
--   { t = type, line = 0-based, col = 0-based, ecol = exclusive end col, text = ?, prio = ? }
-- Types: keyword constant ident punct number string escape comment doccomment
--        doctag preproc regionname eventid tdelim

local M = {}

local function set(str)
  local t = {}
  for w in str:gmatch("%S+") do t[w] = true end
  return t
end

local KEYWORDS = set [[
  and begin break case catch constructor continue default delete div do else end
  enum exit finally for function globalvar if mod new not or other repeat return
  self static switch then throw try until var while with xor global
]]

local CONSTANTS = set [[
  true false undefined noone all pi NaN infinity pointer_null pointer_invalid
]]

function M.lex(lines)
  local toks, nt = {}, 0
  local block = false -- inside /* ... */

  for ln = 1, #lines do
    local line = lines[ln]
    local lnum = ln - 1
    local n = #line

    local function emit(t, s, e, text, prio)
      nt = nt + 1
      toks[nt] = { t = t, line = lnum, col = s - 1, ecol = e, text = text, prio = prio }
    end

    local scan_string, scan_code

    -- start: first char of the literal (incl. $ or @ prefix); q: index of the opening quote
    scan_string = function(start, q, quote, escapes, template)
      local seg = start
      local i = q + 1
      while i <= n do
        local c = line:sub(i, i)
        if escapes and c == "\\" then
          local e = math.min(i + 1, n)
          emit("escape", i, e, nil, 1)
          i = e + 1
        elseif c == quote then
          emit("string", seg, i)
          return i + 1
        elseif template and c == "{" then
          if i > seg then emit("string", seg, i - 1) end
          emit("tdelim", i, i)
          local close = scan_code(i + 1, true)
          if close > n then return n + 1 end
          emit("tdelim", close, close)
          i = close + 1
          seg = i
        else
          i = i + 1
        end
      end
      if seg <= n then emit("string", seg, n) end
      return n + 1
    end

    -- Scans code from i. In template mode returns the index of the closing "}".
    scan_code = function(i, in_tpl)
      local depth = 0
      while i <= n do
        if block then
          local _, e = line:find("*/", i, true)
          if e then
            emit("comment", i, e)
            i = e + 1
            block = false
          else
            emit("comment", i, n)
            return n + 1
          end
        else
          local s = line:find("%S", i)
          if not s then return n + 1 end
          i = s
          local c = line:sub(i, i)
          local c2 = line:sub(i, i + 1)

          if c2 == "//" then
            local doc = line:sub(i, i + 2) == "///" and line:sub(i + 3, i + 3) ~= "/"
            emit(doc and "doccomment" or "comment", i, n)
            if doc then
              local p = i
              while true do
                local ts, te = line:find("@[%a_]+", p)
                if not ts then break end
                emit("doctag", ts, te, nil, 1)
                p = te + 1
              end
            end
            return n + 1
          elseif c2 == "/*" then
            block = true
            emit("comment", i, i + 1)
            i = i + 2
          elseif c == '"' or c == "'" then
            i = scan_string(i, i, c, true, false)
          elseif (c == "@" or c == "$") and line:find("^[\"']", i + 1) then
            local template = c == "$"
            i = scan_string(i, i + 1, line:sub(i + 1, i + 1), template, template)
          elseif c == "$" and line:find("^%$%x", i) then
            local _, e = line:find("^%$%x+", i)
            emit("number", i, e)
            i = e + 1
          elseif c:find("%d")
              or (c == "." and line:find("^%.%d", i) and not line:sub(i - 1, i - 1):find("[%w_%)%]]")) then
            local s2, e = line:find("^0[xX][%x_]+", i)
            if not s2 then s2, e = line:find("^0[bB][01_]+", i) end
            if not s2 then
              s2, e = line:find("^%d[%d_]*%.?[%d_]*", i)
              if not s2 then s2, e = line:find("^%.%d[%d_]*", i) end
              local _, ee = line:find("^[eE][%+%-]?%d+", e + 1)
              if ee then e = ee end
            end
            emit("number", i, e)
            i = e + 1
          elseif c:find("[%a_]") then
            local _, e = line:find("^[%a_][%w_]*", i)
            local w = line:sub(i, e)
            if KEYWORDS[w] then
              emit("keyword", i, e, w)
            elseif CONSTANTS[w] then
              emit("constant", i, e, w)
            else
              emit("ident", i, e, w)
            end
            i = e + 1
          elseif c == "#" and line:find("^#%a", i) then
            local w = line:match("^#(%a+)", i)
            local _, e = line:find("^#%a+", i)
            if w == "macro" or w == "region" or w == "endregion" then
              emit("preproc", i, e, "#" .. w)
              i = e + 1
              if w ~= "macro" then
                if i <= n then emit("regionname", i, n) end
                return n + 1
              end
            else
              emit("punct", i, i, c)
              i = i + 1
            end
          elseif c == "{" then
            depth = depth + 1
            emit("punct", i, i, c)
            i = i + 1
          elseif c == "}" then
            if in_tpl and depth == 0 then return i end
            depth = depth - 1
            emit("punct", i, i, c)
            i = i + 1
          else
            emit("punct", i, i, c)
            i = i + 1
          end
        end
      end
      return n + 1
    end

    if not block and line:sub(1, 1) == "@" and not line:find("^@[\"']") then
      -- event header line such as "@create" (glim-style single-file objects)
      emit("eventid", 1, n, line)
    elseif n > 0 then
      scan_code(1, false)
    end
  end

  return toks
end

return M
