-- Main function triggered by the user to parse and run the request under cursor
function M.run_request()
	-- Fetch the string content of the current cursor line
	local current_line = vim.api.nvim_get_current_line()

	-- Remove code comments at the beginning of the line (e.g., --, //, #)
	current_line = current_line:gsub("^%s*%-%-+%s*", "") -- Strips Lua comments '--'
	current_line = current_line:gsub("^%s*//+%s*", "") -- Strips JS/C comments '//'
	current_line = current_line:gsub("^%s*#+%s*", "") -- Strips Python/Bash comments '#'

	-- Trim leading and trailing whitespace from the cleaned line
	current_line = vim.trim(current_line)

	local method, url

	-- Try to match custom format first: METHOD https://url.com
	method, url = current_line:match("^(%A+)%s+(https?://%S+)")

	-- Fallback: If no explicit method is found, but it starts with http, default to GET
	if not method and current_line:match("^https?://%S+") then
		method = "GET"
		url = current_line:match("^(https?://%S+)")
	end

	-- If still no valid URL is found, trigger an error
	if not method or not url then
		vim.api.nvim_err_writeln(
			"Error: Current line is not a valid HTTP request. Example: GET https://api.com or just https://api.com"
		)
		return
	end

	method = method:upper()

	print("Sending [" .. method .. "] request to " .. url .. "...")

	-- Execute the native Neovim 0.12 network request async API
	vim.net.request({
		url = url,
		method = method,
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
