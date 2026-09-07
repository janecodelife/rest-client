-- Create a custom user command `:RestRun` available globally in Neovim
vim.api.nvim_create_user_command("RestRun", function()
	require("rest-client").run_request()
end, {})

-- FIX: Simplified keymap definition to prevent Neovim 0.12 boolean indexing errors
vim.keymap.set("n", "<leader>r", function()
	require("rest-client").run_request()
end)
