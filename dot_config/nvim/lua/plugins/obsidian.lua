local function iso_local()
	return os.date("%Y-%m-%dT%H:%M:%S") .. string.format(".%03d", math.floor(vim.loop.hrtime() / 1e6) % 1000)
end

---@class ObsidianFrontmatter
---@field title string
---@field alias string
---@field created string
---@field edited string
---@field status boolean
---@field tags string[]

---@param note obsidian.Note
---@return ObsidianFrontmatter
local function custom_frontmatter(note)
	-- Preserve titles
	local title = "Untitled"
	if note.metadata and note.metadata.title and note.metadata.title ~= "Untitled" then
		title = note.metadata.title
	elseif vim.env.NVIM_TITLE and vim.env.NVIM_TITLE ~= "" then
		title = vim.env.NVIM_TITLE
	elseif note.title then
		title = note.title
	end

	local alias = vim.env.NVIM_ALIAS
		or (note.metadata and note.metadata.alias)
		or (note.aliases and note.aliases[1])
		or (os.date("%Y-%m-%d") .. "-" .. title:lower():gsub("%s+", "-"))

	local tags = { "SortMe" }
	if note.tags and #note.tags > 0 then
		tags = note.tags
	elseif note.metadata and note.metadata.tags and #note.metadata.tags > 0 then
		tags = note.metadata.tags
	end

	return {
		title = title,
		alias = alias,
		created = (note.metadata and note.metadata.created) or iso_local(),
		edited = iso_local(),
		status = (note.metadata and note.metadata.status) or false,
		tags = tags,
	}
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
		},

		frontmatter = {
			enabled = true,
			func = custom_frontmatter,
			sort = { "title", "alias", "created", "edited", "status", "tags" },
		},

		callbacks = {
			pre_write_note = function(note)
				---@type ObsidianFrontmatter
				note.metadata = note.metadata or {}
				note.metadata.edited = iso_local()
			end,
		},
	},
}
