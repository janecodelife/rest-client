-- Create a custom user command `:RestRun` available globally in Neovim
vim.api.nvim_create_user_command("RestRun", function()
	require("rest-client").run_request()
end, {})

-- FIX: Use a direct Lua function execution instead of string command to prevent E499 errors
vim.keymap.set("n", "<leader>r", function()
	require("rest-client").run_request()
end, { desc = "Run HTTP request under cursor" })
