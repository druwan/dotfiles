local function iso_local()
	return os.date("%Y-%m-%dT%H:%M:%S") .. string.format(".%03d", math.floor(vim.loop.hrtime() / 1e6) % 1000)
end

local function custom_frontmatter(note)
	-- Check if ENVs are set
	local nice_title = vim.env.NVIM_TITLE or note.title or "Untitled"
	local alias_slug = vim.env.NVIM_ALIAS or note.title or "untitled"

	return {
		title = nice_title,
		alias = os.date("%Y-%m-%d") .. "-" .. alias_slug,
		created = note.metadata and note.metadata.created or iso_local(),
		edited = note.metadata and note.metadata.edited or iso_local(),
		status = false,
		tags = { "SortMe" },
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
			folder = nil,
			-- folder = "Templates",
			-- date_format = "%Y-%m-%d",
			-- time_format = "%H:%M:%S",
		},

		frontmatter = {
			enabled = true,
			func = custom_frontmatter,
			sort = { "title", "alias", "created", "edited", "status", "tags" },
		},

		callbacks = {
			pre_write_note = function(note)
				note.metadata = note.metadata or {}
				note.metadata.edited = iso_local()
			end,
		},
	},
}
