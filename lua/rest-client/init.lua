local M = {}

-- Custom safe function to pretty print raw JSON string with correct indentation
local function pretty_format_json(json_str)
	local success, decoded = pcall(vim.json.decode, json_str)
	if not success then
		return json_str
	end

	-- Use Neovim's robust formatting utility to generate readable output lines
	local raw_inspect = vim.inspect(decoded)
	local formatted_lines = {}

	-- Convert the inspect structure into a clean readable view line by line
	for line in string.gmatch(raw_inspect, "[^\r\n]+") do
		-- Replace lua table syntax artifacts with clean formatting syntax if needed
		line = line:gsub("=", ":")
		table.insert(formatted_lines, line)
	end

	return formatted_lines
end

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

	-- Format JSON output safely via inspect fallback wrapper
	local formatted = pretty_format_json(body)
	if type(formatted) == "table" then
		for _, line in ipairs(formatted) do
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

	-- Clean up any leading spaces, Lua comments (--), JS comments (//), or Bash comments (#)
	current_line = current_line:match("^%s*%-%-%s*(.*)") or current_line
	current_line = current_line:match("^%s*//%s*(.*)") or current_line
	current_line = current_line:match("^%s*#%s*(.*)") or current_line

	-- Trim leading/trailing whitespace using native Neovim utility
	current_line = vim.trim(current_line)

	local method, url

	-- Check if line explicitly specifies a method followed by a space and URL
	local potential_method, potential_url = current_line:match("^([A-Za-z]+)%s+(https?://%S+)")

	if potential_method and potential_url then
		method = potential_method
		url = potential_url
	elseif current_line:match("^https?://%S+") then
		-- Fallback: If no explicit method is written, default to GET
		method = "GET"
		url = current_line:match("^(https?://%S+)")
	end

	-- If parsing fails entirely, abort with a clear user error
	if not method or not url then
		vim.api.nvim_err_writeln("Error: Current line is not a valid HTTP request.")
		return
	end

	method = method:upper()

	print("Sending [" .. method .. "] request to " .. url .. "...")

	-- Completion callback handler for the network api
	local on_response = function(err, response)
		if err then
			vim.schedule(function()
				vim.api.nvim_err_writeln("Request failed: " .. tostring(err))
			end)
			return
		end

		-- Schedule rendering to safely update UI on Neovim's main loop
		vim.schedule(function()
			if response and response.body then
				display_response(response.body, response.status)
			else
				vim.api.nvim_err_writeln("Error: Received an empty response from server.")
			end
		end)
	end

	-- Route calls based on method signature criteria for Neovim's API
	if method == "GET" then
		vim.net.request(url, {}, on_response)
	else
		vim.net.request(method, url, {}, on_response)
	end
end

return M
