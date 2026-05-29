require "plugins"

for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/config")) do
	if file:match("%.lua$") and file ~= "init.lua" then
    	local module = "config." .. file:gsub("%.lua$", "")
    	require(module)
  	end
end
