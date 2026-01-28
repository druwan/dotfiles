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
	},
}
