local c = require("buraq.palette").colors

local buraq = {
  normal = {
    a = { fg = "#ffffff", bg = c.accent, gui = "bold" },
    b = { fg = c.fg_bright, bg = c.bg_visual },
    c = { fg = c.fg_muted, bg = c.bg_dark },
    x = { fg = c.fg_muted, bg = c.bg_dark },
    y = { fg = c.fg_bright, bg = c.bg_visual },
    z = { fg = "#ffffff", bg = c.accent, gui = "bold" },
  },
  insert = {
    a = { fg = c.bg, bg = c.blue, gui = "bold" },
    b = { fg = c.fg_bright, bg = c.bg_visual },
    c = { fg = c.fg_muted, bg = c.bg_dark },
    z = { fg = c.bg, bg = c.blue, gui = "bold" },
  },
  visual = {
    a = { fg = c.bg, bg = c.purple, gui = "bold" },
    b = { fg = c.fg_bright, bg = c.bg_visual },
    c = { fg = c.fg_muted, bg = c.bg_dark },
    z = { fg = c.bg, bg = c.purple, gui = "bold" },
  },
  replace = {
    a = { fg = "#ffffff", bg = c.diag_error, gui = "bold" },
    b = { fg = c.fg_bright, bg = c.bg_visual },
    c = { fg = c.fg_muted, bg = c.bg_dark },
    z = { fg = "#ffffff", bg = c.diag_error, gui = "bold" },
  },
  command = {
    a = { fg = c.bg, bg = c.yellow, gui = "bold" },
    b = { fg = c.fg_bright, bg = c.bg_visual },
    c = { fg = c.fg_muted, bg = c.bg_dark },
    z = { fg = c.bg, bg = c.yellow, gui = "bold" },
  },
  inactive = {
    a = { fg = c.fg_muted, bg = c.bg_dark, gui = "bold" },
    b = { fg = c.fg_muted, bg = c.bg_dark },
    c = { fg = c.fg_comment, bg = c.bg_dark },
    z = { fg = c.fg_muted, bg = c.bg_dark },
  },
}

return buraq
