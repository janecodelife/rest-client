-- Create a custom user command `:RestRun` available globally in Neovim
vim.api.nvim_create_user_command("RestRun", function()
	require("rest-client").run_request()
end, {})

-- Bind <leader>r shortcut to execute the HTTP client plugin quickly
vim.keymap.set("n", "<leader>r", ":RestRun<CR>", { desc = "Run HTTP request under cursor" })
