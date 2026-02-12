local uv = vim.uv or vim.loop

local function iso_local(t)
	local ts = t and os.date("*t", t) or os.date("*t")
	return string.format("%04d-%02d-%02dT%02d:%02d:%02d", ts.year, ts.month, ts.day, ts.hour, ts.min, ts.sec)
end

-- File creation
local function file_times()
	local path = vim.api.nvim_buf_get_name(0)
	if path and path ~= "" then
		local stat = uv.fs_stat(path)
		if stat then
			return iso_local(stat.birthtime.sec), iso_local(stat.mtime.sec)
		end
	end
	local now = iso_local()
	return now, now
end

local function slugify(s)
	if not s or s == "" then
		return "untitled"
	end
	return s:lower():gsub("%s+", "-"):gsub("[^%a%d%-]", "")
end

local function resolve_title()
	if vim.env.NVIM_TITLE and vim.env.NVIM_TITLE ~= "" then
		return vim.env.NVIM_TITLE
	end
	local stem = vim.fn.expand("%:t:r")
	if stem and stem ~= "" then
		-- de-slug: replace hyphens/underscores with spaces, then capitalize each word
		local words = {}
		for word in stem:gsub("[-_]+", " "):gmatch("%S+") do
			table.insert(words, word:sub(1, 1):upper() .. word:sub(2):lower())
		end
		return table.concat(words, " ")
	end
	return "Untitled"
end

local function read_frontmatter_field(field)
	local lines = vim.api.nvim_buf_get_lines(0, 0, 30, false)
	local in_frontmatter = false
	for i, line in ipairs(lines) do
		if i == 1 and line == "---" then
			in_frontmatter = true
		elseif in_frontmatter and line == "---" then
			break
		elseif in_frontmatter then
			local val = line:match("^" .. field .. "%s*:%s*(.+)$")
			if val then
				return val
			end
		end
	end
	return nil
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

		templates = {
			folder = "Templates",
			substitutions = {
				iso_created = function()
					return read_frontmatter_field("created") or (file_times())
				end,

				iso_modified = function()
					local _, modified = file_times()
					return modified
				end,

				alias = function()
					local stem = vim.fn.expand("%:t:r")
					local base = (stem and stem ~= "") and stem or vim.env.NVIM_TITLE or "untitled"
					return os.date("%Y-%m-%d") .. "-" .. slugify(base)
				end,

				notetitle = resolve_title,
			},
		},

		frontmatter = {
			enabled = true,
			func = function(note)
				-- Preserve existing,
				local meta = note.metadata or {}
				local created, modified = file_times()
				local title = meta.title and meta.title ~= "Untitled" and meta.title or resolve_title()
				return {
					title = title,
					alias = meta.alias or (os.date("%Y%m%d") .. "-" .. slugify(title)),
					created = meta.created or created,
					edited = meta.modified or modified,
					tags = (note.tags and #note.tags > 0) and note.tags
						or (meta.tags and #meta.tags > 0) and meta.tags
						or {},
				}
			end,
			sort = { "title", "alias", "created", "edited", "tags" },
		},

		callbacks = {
			pre_write_note = function(note)
				note.metadata = note.metadata or {}
				local _, modified = file_times()
				note.metadata.modified = modified
			end,
		},
	},
}
