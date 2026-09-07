local M = {}

-- Safely render the HTTP response in a new vertical split window
local function display_response(body, status)
	-- Create a new unlisted scratch buffer
	local bufnr = vim.api.nvim_create_buf(false, true)

	-- Set filetype to json to enable syntax highlighting
	vim.bo[bufnr].filetype = "json"

	-- Prepare initial header metadata lines
	local lines = {
		"// Status: " .. tostring(status),
		"// ------------------------",
	}

	-- Try to format response body as pretty JSON, fallback to raw text if it fails
	local success, decoded = pcall(vim.json.decode, body)
	if success then
		local formatted = vim.json.encode(decoded)
		for line in string.gmatch(formatted, "[^\r\n]+") do
			table.insert(lines, line)
		end
	else
		for line in string.gmatch(body, "[^\r\n]+") do
			table.insert(lines, line)
		end
	end

	-- Populate the buffer with response text
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	-- Open a vertical split and attach the response buffer
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, bufnr)
end

-- Main function triggered by the user to parse and run the request under cursor
function M.run_request()
	-- Fetch the string content of the current cursor line
	local current_line = vim.api.nvim_get_current_line()

	-- Extract HTTP method and URL using Lua pattern matching
	local method, url = current_line:match("^(%A+)%s+(https?://%S+)")

	if not method or not url then
		vim.api.nvim_err_writeln("Error: Current line is not a valid HTTP request. Example: GET https://api.com")
		return
	end

	print("Sending [" .. method .. "] request to " .. url .. "...")

	-- Execute the native Neovim 0.12 network request async API
	vim.net.request({
		url = url,
		method = method:upper(),
		callback = function(err, response)
			if err then
				vim.schedule(function()
					vim.api.nvim_err_writeln("Request failed: " .. tostring(err))
				end)
				return
			end

			-- Schedule rendering to safely update UI on Neovim's main loop
			vim.schedule(function()
				display_response(response.body, response.status)
			end)
		end,
	})
end

return M
