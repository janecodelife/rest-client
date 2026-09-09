local M = {}

-- Function to create a floating window using native Neovim API
local function show_in_float(title_text, content)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

	-- Calculate dimensions for the floating window
	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = title_text,
		title_pos = "center",
	}

	-- Open the UI window and apply JSON highlighting
	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.bo[buf].filetype = "json"

	-- Allow closing the window quickly by pressing 'q'
	vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, silent = true, nowait = true })
end

-- Main execution function to execute the HTTP request from current line
function M.run_current_line()
	-- Get text from the current line where the cursor is positioned
	local line = vim.api.nvim_get_current_line()

	-- Parse Method and URL using Lua pattern matching
	local method, url = line:match("^([A-Z]+)%s+(https?://[%w%-_%.%?%s%/%%%=%&]+)")

	-- Fallback to GET if only a raw URL is provided without a method prefix
	if not method or not url then
		url = line:match("(https?://[%w%-_%.%?%s%/%%%=%&]+)")
		method = "GET"
	end

	if not url then
		vim.notify("No valid URL found on this line!", vim.log.levels.WARN)
		return
	end

	vim.notify(string.format("[Native] Sending %s to %s...", method, url), vim.log.levels.INFO)

	-- STRICTLY NATIVE: Utilizing Neovim 0.12 built-in async network request
	vim.net.request(method, url, {}, function(err, res)
		-- Schedule the UI update back to the main Neovim thread safely
		vim.schedule(function()
			if err then
				show_in_float(" Network Error ", { "Error details:", vim.inspect(err) })
				return
			end

			-- Split raw response body string into lines table for the buffer
			local lines = vim.split(res.body, "\n")
			local title = string.format(" HTTP Status: %d ", res.status)
			show_in_float(title, lines)
		end)
	end)
end

-- The setup function that exposes commands and keymaps to the user's config
function M.setup(opts)
	-- Merge user options if any are provided in the future
	opts = opts or {}

	-- Create the user command :HttpRun
	vim.api.nvim_create_user_command("HttpRun", M.run_current_line, {})

	-- Bind to a default shortcut shortcut (e.g., <leader>hr)
	vim.keymap.set("n", "<leader>hr", M.run_current_line, { desc = "Run native HTTP request" })
end

return M
