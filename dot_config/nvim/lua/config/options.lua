vim.g.lazyvim_check_order = false

vim.opt.autoindent = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

-- Highlight trailing whitespace
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*",
	command = [[match ErrorMsg /\s\+$/]],
})
