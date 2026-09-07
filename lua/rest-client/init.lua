local M = {}

-- Custom safe function to pretty print raw JSON string with correct indentation
local function pretty_format_json(json_str)
	local success, decoded = pcall(vim.json.decode, json_str)
	if not success then
		return json_str
	end

	local raw_inspect = vim.inspect(decoded)
	local formatted_lines = {}

	for line in string.gmatch(raw_inspect, "[^\r\n]+") do
		line = line:gsub("=", ":")
		table.insert(formatted_lines, line)
	end

	return formatted_lines
end

-- Safely render the HTTP response in a new vertical split window
local function display_response(body, status)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.bo[bufnr].filetype = "json"

	local lines = {
		"// Status: " .. tostring(status),
		"// ------------------------",
	}

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

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, bufnr)
end

-- Main function triggered by the user to parse and run the request under cursor
function M.run_request()
	local current_line = vim.api.nvim_get_current_line()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_row = cursor_pos[1] -- 1-indexed row number of cursor

	-- Clean up any leading spaces, Lua comments (--), JS comments (//), or Bash comments (#)
	current_line = current_line:match("^%s*%-%-%s*(.*)") or current_line
	current_line = current_line:match("^%s*//%s*(.*)") or current_line
	current_line = current_line:match("^%s*#%s*(.*)") or current_line
	current_line = vim.trim(current_line)

	local method, url
	local potential_method, potential_url = current_line:match("^([A-Za-z]+)%s+(https?://%S+)")

	if potential_method and potential_url then
		method = potential_method
		url = potential_url
	elseif current_line:match("^https?://%S+") then
		method = "GET"
		url = current_line:match("^(https?://%S+)")
	end

	if not method or not url then
		vim.api.nvim_err_writeln("Error: Current line is not a valid HTTP request.")
		return
	end

	method = method:upper()

	-- Advanced Feature: Parse Headers and Body from lines below the request line
	local total_lines = vim.api.nvim_buf_count_lines or vim.api.nvim_buf_line_count(0)
	local headers = {}
	local body_lines = {}
	local is_parsing_body = false

	-- Default common headers
	headers["User-Agent"] = "Neovim-RestClient/0.12"

	-- Scan consecutive lines underneath the request line
	for i = current_row + 1, total_lines do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

		-- Stop parsing if we hit another request block or block delimiter (like ###)
		if line:match("^%A+%s+https?://") or line:match("^###") then
			break
		end

		if is_parsing_body then
			-- Collect body lines after the blank line separator
			table.insert(body_lines, line)
		else
			if line == "" then
				-- Blank line denotes the transition from Headers to Request Body
				is_parsing_body = true
			else
				-- Parse Headers (Format: Key: Value)
				local h_key, h_val = line:match("^([^:]+):%s*(.*)")
				if h_key and h_val then
					headers[vim.trim(h_key)] = vim.trim(h_val)
				end
			end
		end
	end

	local request_body = nil
	if #body_lines > 0 then
		request_body = table.concat(body_lines, "\n")
		-- Automatically append JSON content type if missing and body looks like JSON
		if request_body:match("^%s*{") and not headers["Content-Type"] then
			headers["Content-Type"] = "application/json"
		end
	end

	print("Sending [" .. method .. "] request to " .. url .. "...")

	-- Completion callback handler for the network api
	local on_response = function(err, response)
		if err then
			vim.schedule(function()
				vim.api.nvim_err_writeln("Request failed: " .. tostring(err))
			end)
			return
		end

		vim.schedule(function()
			if response and response.body then
				display_response(response.body, response.status)
			else
				vim.api.nvim_err_writeln("Error: Received an empty response from server.")
			end
		end)
	end

	-- Route calls into Neovim 0.12 native API parameters
	local opts = {
		headers = headers,
		body = request_body,
	}

	if method == "GET" then
		vim.net.request(url, opts, on_response)
	else
		vim.net.request(method, url, opts, on_response)
	end
end

return M
