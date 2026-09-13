local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs / indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.copyindent = true
opt.preserveindent = true

opt.wrap = false
opt.sidescrolloff = 8
opt.sidescroll = 1

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

-- Keep persistent undo without leaving swap or backup files in projects.
opt.swapfile = false
opt.backup = false
local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir
opt.undofile = true

opt.scrolloff = 8
opt.updatetime = 50

opt.splitright = true
opt.splitbelow = true

opt.foldmethod = "marker"
opt.foldmarker = "#pragma region,#pragma endregion"

vim.filetype.add({
  extension = {
    gd = "gdscript",
    gdshader = "gdshader",
    gdshaderinc = "gdshaderinc",
    tres = "gdresource",
    tscn = "gdresource",
    h = "c",
    hpp = "cpp",
  },
  filename = {
    ["project.godot"] = "godot",
  },
})
