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
		-- FIX: Use indent option in vim.json.encode to format JSON beautifully on multiple lines
		local formatted = vim.json.encode(decoded, { indent = "  " })
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
