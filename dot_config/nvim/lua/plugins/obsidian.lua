local uv = vim.uv or vim.loop

local function iso_local(t)
	local ts = t and os.date("*t", t) or os.date("*t")
	return string.format("%04d-%02d-%02dT%02d:%02d:%02d", ts.year, ts.month, ts.day, ts.hour, ts.min, ts.sec)
end

local function slugify(s)
	if not s or s == "" then
		return ""
	end
	return s:lower():gsub("[^a-z0-9]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
end

local function update_frontmatter_on_save()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local in_frontmatter = false
	local frontmatter_start = nil
	local frontmatter_end = nil

	for i, line in ipairs(lines) do
		if i == 1 and line == "---" then
			in_frontmatter = true
			frontmatter_start = i
		elseif in_frontmatter and line == "---" then
			frontmatter_end = i
			break
		end
	end

	if not frontmatter_start or not frontmatter_end then
		return
	end

	-- Find and update the 'modified' line while also sorting the tags-list
	local now = iso_local()
	local tags = {}
	local tags_start = nil
	local tags_end = nil
	local modified_line = nil

	-- Parse frontmatter
	for i = frontmatter_start + 1, frontmatter_end - 1 do
		local line = lines[i]

		-- Track modified line
		if line:match("^modified:") then
			modified_line = i
		end

		-- Track tags array
		if line:match("^tags:%s*$") or line:match("^tags:%s*%[") then
			tags_start = i
			if line:match("%]") then
				tags_end = i
			end
		elseif tags_start and not tags_end then
			if line:match("^%s*-%s*(.+)") then
				local tag = line:match("^%s*-%s*(.+)")
				table.insert(tags, tag)
			elseif not line:match("^%s") then
				tags_end = i - 1
			end
		end
	end

	-- Update modified
	if modified_line then
		lines[modified_line] = "modified: " .. now
	else
		table.insert(lines, frontmatter_end, "modified: " .. now)
		frontmatter_end = frontmatter_end + 1
	end

	-- Sort and rewrite tags if found
	if tags_start and #tags > 0 then
		table.sort(tags)

		-- Remove old tag lines (if tags_end exists and is valid)
		if tags_end and tags_end >= tags_start + 1 then
			for i = tags_end, tags_start + 1, -1 do
				table.remove(lines, i)
			end
		end

		-- Insert sorted tags
		lines[tags_start] = "tags:"
		for i, tag in ipairs(tags) do
			table.insert(lines, tags_start + i, "  - " .. tag)
		end
	end
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.modified = false
end

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	ft = "markdown",
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		workspaces = {
			{ name = "personal", path = vim.fn.expand(os.getenv("NOTES")) },
		},

		-- Disable default frontmatter
		frontmatter = { enabled = false },

		templates = {
			folder = "Templates",
			substitutions = {
				title = function()
					return vim.env.NVIM_TITLE or "Untitled"
				end,
				slug = function()
					return vim.env.NVIM_SLUG or slugify(vim.env.NVIM_TITLE) or "untitled"
				end,
				created = function()
					return iso_local()
				end,
				modified = function()
					return iso_local()
				end,
			},
		},

		callbacks = {
			post_setup = function()
				vim.api.nvim_create_autocmd("BufNewFile", {
					pattern = vim.fn.expand(os.getenv("NOTES")) .. "/Inbox/*.md",
					callback = function()
						vim.defer_fn(function()
							vim.cmd("ObsidianTemplate shell-note")
						end, 50)
					end,
				})
			end,

			pre_write_note = function()
				if vim.bo.modified then
					update_frontmatter_on_save()
				end
			end,
		},
	},
}
