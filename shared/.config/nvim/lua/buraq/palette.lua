local M = {}

M.colors = {
  -- Base Backgrounds
  bg_dark = "#0b1015",       -- Sidebar, statusline, tabline background
  bg = "#10151a",            -- Main editor buffer background
  bg_float = "#15191f",      -- Floating windows, popups, inputs, widgets
  bg_highlight = "#15191f",  -- Current line highlight, hover background
  bg_visual = "#1e2328",     -- Selection, active item background
  bg_search = "#199054",     -- Find match highlight background

  -- Borders and Guides
  border = "#1e2328",        -- Window splits, popup borders, indent guides
  border_focus = "#199054",  -- Active border, focus border

  -- Foregrounds
  fg_bright = "#eceff1",     -- Active list text, statusline active, titlebar
  fg = "#abb2bf",            -- Standard editor text
  fg_muted = "#76858c",      -- Line numbers, inactive items, scrollbar thumb
  fg_comment = "#5c6370",    -- Comments
  fg_subtle = "#3e4451",     -- Non-text characters, delimiters, subtle markers

  -- Core Accents
  accent = "#199054",        -- Signature Buraq emerald
  green = "#98c379",         -- Functions, embedded strings, tag attributes
  cyan = "#56b6c2",          -- Constants, types, JSON properties, tags class/id
  blue = "#61afef",          -- Variables, class names, links, identifiers
  yellow = "#e5c07b",        -- Strings, template strings
  orange = "#d19a66",        -- Parameters, function arguments
  purple = "#c678dd",        -- Numbers, booleans, CSS units
  red = "#e06c75",           -- Keywords, storage, tag names, heading markdown

  -- Diagnostics
  diag_error = "#dc3016",
  diag_warn = "#ffab23",
  diag_info = "#6796e6",
  diag_hint = "#56b6c2",
  diag_ok = "#98c379",

  -- Diagnostic Virtual Text Backgrounds
  diag_error_bg = "#231518",
  diag_warn_bg = "#231e15",
  diag_info_bg = "#151e24",
  diag_hint_bg = "#142023",

  -- Git / Diff
  git_add = "#98c379",
  git_change = "#e5c07b",
  git_delete = "#dc3016",
  diff_add_bg = "#15271d",
  diff_change_bg = "#25251a",
  diff_delete_bg = "#2a1719",
  diff_text_bg = "#194a2e",
}

return M
