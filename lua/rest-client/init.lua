local M = {}

M.config = {
	keymap = "<leader>hr",
	mapping_desc = "Execute REST client request under cursor",
}

local function display_response(req_info, status_line, response_raw, origin_win)
	local clean_response = response_raw:gsub("\r", "")
	local split_index = clean_response:find("\n\n")
	local resp_headers = ""
	local resp_body = clean_response

	if split_index then
		resp_headers = vim.trim(clean_response:sub(1, split_index - 1))
		resp_body = vim.trim(clean_response:sub(split_index + 2))
	end

	local json_success, decoded = pcall(vim.json.decode, resp_body)
	local formatted_resp_body = resp_body
	local filetype = "json"

	if json_success then
		formatted_resp_body = vim.json.encode(decoded, { indent = "  " })
	else
		filetype = "text"
		local body_start = resp_body:lower()
		if body_start:find("<!doctype html") or body_start:find("<html") then
			filetype = "html"
		end
	end

	vim.cmd("vsplit")
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)

	local content_lines = {}
	table.insert(content_lines, "========================================")
	table.insert(content_lines, "             REQUEST DETAILS            ")
	table.insert(content_lines, "========================================")
	table.insert(content_lines, "URL:    " .. req_info.url)
	table.insert(content_lines, "METHOD: " .. req_info.method)
	table.insert(content_lines, "HEADERS:")

	local has_headers = false
	for k, v in pairs(req_info.headers) do
		has_headers = true
		table.insert(content_lines, string.format("  %s: %s", k, v))
	end
	if not has_headers then
		table.insert(content_lines, "  (None)")
	end

	table.insert(content_lines, "BODY:")
	if req_info.body and req_info.body ~= "" then
		local req_json_ok, req_json_dec = pcall(vim.json.decode, req_info.body)
		if req_json_ok then
			local req_body_lines = vim.split(vim.json.encode(req_json_dec, { indent = "  " }), "\n")
			for _, l in ipairs(req_body_lines) do
				table.insert(content_lines, "  " .. l)
			end
		else
			table.insert(content_lines, "  " .. req_info.body)
		end
	else
		table.insert(content_lines, "  (Empty)")
	end

	-- table.insert(content_lines, "")
	-- table.insert(content_lines, "----------------------------------------")
	-- table.insert(content_lines, " --- REQUEST / RESPONSE BOUNDARY --- ")
	-- table.insert(content_lines, "----------------------------------------")
	-- table.insert(content_lines, "")
	--
	table.insert(content_lines, "========================================")
	table.insert(content_lines, " RESPONSE: " .. string.upper(status_line))
	table.insert(content_lines, "========================================")

	table.insert(content_lines, "RESPONSE BODY:")
	local body_lines = vim.split(formatted_resp_body, "\n")
	for _, line in ipairs(body_lines) do
		table.insert(content_lines, line)
	end

	table.insert(content_lines, "")
	table.insert(content_lines, "----------------------------------------")

	table.insert(content_lines, "RESPONSE HEADERS:")
	local resp_header_lines = vim.split(resp_headers, "\n")
	for _, line in ipairs(resp_header_lines) do
		table.insert(content_lines, "  " .. line)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)

	vim.bo[buf].filetype = filetype
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"

	if filetype == "json" then
		vim.cmd("setlocal syntax=json")
	elseif filetype == "html" then
		vim.cmd("setlocal syntax=html")
		vim.cmd("normal! gg=G")
	end

	local map_opts = { buffer = buf, silent = true, noremap = true }
	vim.keymap.set("n", "q", ":close<CR>", map_opts)
	vim.keymap.set("n", "<Esc>", ":close<CR>", map_opts)

	if origin_win and vim.api.nvim_win_is_valid(origin_win) then
		vim.api.nvim_set_current_win(origin_win)
	end
end

local function parse_http_block()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local total_lines = vim.api.nvim_buf_line_count(bufnr)

	local start_line = cursor_pos[1]

	while start_line > 1 do
		local raw_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)
		local raw_line = (raw_lines and raw_lines[1]) or ""
		local line = vim.trim(raw_line)

		if line:match("^[A-Z]+%s+https?://") then
			break
		end
		start_line = start_line - 1
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, total_lines, false)
	if #lines == 0 then
		return nil, "Empty buffer block context."
	end

	local first_line = vim.trim(lines[1] or "")
	local method, url = first_line:match("^(%S+)%s+(%S+)")

	if not method or not url then
		return nil, "Invalid HTTP format. Position cursor inside or below a 'METHOD URL' block."
	end

	local headers = {}
	local body_parts = {}
	local parsing_body = false

	-- Keep track of curly brackets to know exactly where the JSON object ends
	local open_brackets = 0
	local close_brackets = 0

	for i = 2, #lines do
		local line = vim.trim(lines[i] or "")

		-- Stop if we hit a brand new request block header line
		if line:match("^[A-Z]+%s+https?://") then
			break
		end

		if parsing_body then
			if line ~= "" then
				table.insert(body_parts, line)

				-- Count brackets on this current body string line
				for _ in line:gmatch("{") do
					open_brackets = open_brackets + 1
				end
				for _ in line:gmatch("}") do
					close_brackets = close_brackets + 1
				end

				-- FIX: If balanced, we have parsed the complete standalone JSON object! Stop right here.
				if open_brackets > 0 and open_brackets == close_brackets then
					break
				end
			end
		elseif line:lower():match("^header:%s*") then
			local json_str = line:gsub("^header:%s*", "")
			local ok, decoded = pcall(vim.json.decode, json_str)
			if ok and type(decoded) == "table" then
				for k, v in pairs(decoded) do
					headers[k] = tostring(v)
				end
			end
		elseif line:lower():match("^body:%s*") then
			parsing_body = true
			local rest = line:gsub("^body:%s*", "")
			if rest ~= "" then
				table.insert(body_parts, rest)
				for _ in rest:gmatch("{") do
					open_brackets = open_brackets + 1
				end
				for _ in rest:gmatch("}") do
					close_brackets = close_brackets + 1
				end

				if open_brackets > 0 and open_brackets == close_brackets then
					break
				end
			end
		end
	end

	local final_body = nil
	if #body_parts > 0 then
		final_body = table.concat(body_parts, " ")
		final_body = final_body:gsub("([{,])%s*([a-zA-Z0-9_]+)%s*:", '%1"%2":')
		final_body = final_body:gsub("'%s*([a-zA-Z0-9_-]+)%s*'", '"%1"')
	end

	return {
		method = method:upper(),
		url = url,
		headers = headers,
		body = final_body,
	}
end

function M.run_request()
	local req, err = parse_http_block()
	if err or not req then
		print("Parser Error: " .. tostring(err or "Failed to read target block context."))
		return
	end

	local origin_win = vim.api.nvim_get_current_win()
	print(string.format("Executing secure HTTP call [%s] -> %s", req.method, req.url))

	local cmd = { "curl", "-s", "-i", "-X", req.method, req.url }

	if req.body and not req.headers["Content-Type"] then
		req.headers["Content-Type"] = "application/json"
	end

	for k, v in pairs(req.headers) do
		table.insert(cmd, "-H")
		table.insert(cmd, string.format("%s: %s", k, v))
	end

	if req.body then
		table.insert(cmd, "--data-raw")
		table.insert(cmd, req.body)
	end

	vim.system(cmd, { text = true }, function(obj)
		local raw_response = obj.stdout or ""
		local first_break = raw_response:find("\r?\n")
		local status_line = "HTTP RESPONSE | STATUS: " .. tostring(obj.code)

		if first_break then
			status_line = vim.trim(raw_response:sub(1, first_break - 1))
		end

		vim.schedule(function()
			display_response(req, status_line, raw_response, origin_win)
		end)
	end)
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	if M.config.keymap then
		vim.keymap.set("n", M.config.keymap, function()
			M.run_request()
		end, { desc = M.config.mapping_desc, silent = true, noremap = true })
	end
end

return M
