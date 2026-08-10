local opt = vim.opt

opt.number = true
opt.relativenumber = true

-- 2-space indent, matching the rest of this repo's config.
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

opt.wrap = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.scrolloff = 8

opt.ignorecase = true
opt.smartcase = true

opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300

opt.splitright = true
opt.splitbelow = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
