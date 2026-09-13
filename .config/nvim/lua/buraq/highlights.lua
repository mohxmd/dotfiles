local M = {}

function M.get(c)
  return {
    ---------------------------------------------------------------------------
    -- Editor & UI Highlights
    ---------------------------------------------------------------------------
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg_bright, bg = c.bg_float },
    FloatBorder = { fg = c.border, bg = c.bg_float },
    FloatTitle = { fg = c.accent, bg = c.bg_float, bold = true },
    FloatFooter = { fg = c.fg_muted, bg = c.bg_float },

    Cursor = { fg = c.bg, bg = c.accent },
    CursorLine = { bg = c.bg_highlight },
    CursorColumn = { bg = c.bg_highlight },
    ColorColumn = { bg = c.bg_highlight },

    LineNr = { fg = c.fg_muted, bg = c.bg },
    CursorLineNr = { fg = c.accent, bg = c.bg_highlight, bold = true },

    Visual = { bg = c.bg_visual },
    VisualNOS = { bg = c.bg_visual },

    Search = { fg = c.fg_bright, bg = "#145e3a" },
    IncSearch = { fg = c.bg, bg = c.green, bold = true },
    CurSearch = { fg = c.bg, bg = c.accent, bold = true },

    StatusLine = { fg = c.fg_bright, bg = c.bg_dark },
    StatusLineNC = { fg = c.fg_muted, bg = c.bg_dark },

    WinSeparator = { fg = c.border, bg = "NONE" },
    VertSplit = { fg = c.border, bg = "NONE" },

    SignColumn = { fg = c.fg_muted, bg = c.bg },
    Folded = { fg = c.fg_muted, bg = c.bg_float },
    FoldColumn = { fg = c.fg_muted, bg = c.bg },

    Pmenu = { fg = c.fg, bg = c.bg_float },
    PmenuSel = { fg = c.fg_bright, bg = c.bg_visual, bold = true },
    PmenuSbar = { bg = c.bg_float },
    PmenuThumb = { bg = c.fg_muted },
    PmenuBorder = { fg = c.border, bg = c.bg_float },

    TabLine = { fg = c.fg_muted, bg = c.bg_dark },
    TabLineFill = { bg = c.bg_dark },
    TabLineSel = { fg = c.fg_bright, bg = c.bg, bold = true },

    MatchParen = { fg = c.accent, bg = c.bg_visual, bold = true },

    Title = { fg = c.accent, bold = true },
    Directory = { fg = c.blue },
    Conceal = { fg = c.fg_muted },
    SpecialKey = { fg = c.fg_subtle },
    NonText = { fg = c.fg_subtle },
    Whitespace = { fg = c.border },

    Question = { fg = c.green },
    MoreMsg = { fg = c.green },
    ModeMsg = { fg = c.fg_bright, bold = true },
    WarningMsg = { fg = c.diag_warn },
    ErrorMsg = { fg = c.diag_error, bold = true },
    WildMenu = { fg = c.bg, bg = c.accent, bold = true },

    ---------------------------------------------------------------------------
    -- Standard Syntax
    ---------------------------------------------------------------------------
    Comment = { fg = c.fg_comment, italic = true },

    Constant = { fg = c.cyan },
    String = { fg = c.yellow },
    Character = { fg = c.cyan },
    Number = { fg = c.purple },
    Boolean = { fg = c.purple },
    Float = { fg = c.purple },

    Identifier = { fg = c.blue },
    Function = { fg = c.green },

    Statement = { fg = c.red },
    Conditional = { fg = c.red },
    Repeat = { fg = c.red },
    Label = { fg = c.red },
    Operator = { fg = c.red },
    Keyword = { fg = c.red },
    Exception = { fg = c.red },

    PreProc = { fg = c.red },
    Include = { fg = c.red },
    Define = { fg = c.red },
    Macro = { fg = c.red },
    PreCondit = { fg = c.red },

    Type = { fg = c.blue },
    StorageClass = { fg = c.red },
    Structure = { fg = c.blue },
    Typedef = { fg = c.cyan },

    Special = { fg = c.cyan },
    SpecialChar = { fg = c.purple },
    Tag = { fg = c.red },
    Delimiter = { fg = c.fg },
    SpecialComment = { fg = c.fg_comment, italic = true },
    Debug = { fg = c.purple },

    Underlined = { underline = true },
    Ignore = { fg = c.fg_comment },
    Error = { fg = c.diag_error, bold = true },
    Todo = { fg = c.bg, bg = c.diag_warn, bold = true },

    ---------------------------------------------------------------------------
    -- Treesitter Standard Groups
    ---------------------------------------------------------------------------
    ["@variable"] = { fg = c.blue },
    ["@variable.builtin"] = { fg = c.red },
    ["@variable.parameter"] = { fg = c.orange, italic = true },
    ["@variable.member"] = { fg = c.fg },

    ["@constant"] = { fg = c.cyan },
    ["@constant.builtin"] = { fg = c.cyan },
    ["@constant.macro"] = { fg = c.cyan },

    ["@module"] = { fg = c.blue },
    ["@module.builtin"] = { fg = c.blue },
    ["@label"] = { fg = c.red },

    ["@string"] = { fg = c.yellow },
    ["@string.documentation"] = { fg = c.fg_comment, italic = true },
    ["@string.regexp"] = { fg = c.cyan },
    ["@string.escape"] = { fg = c.purple },
    ["@string.special"] = { fg = c.green },
    ["@string.special.url"] = { fg = c.blue, underline = true },

    ["@character"] = { fg = c.cyan },
    ["@character.special"] = { fg = c.purple },

    ["@number"] = { fg = c.purple },
    ["@number.float"] = { fg = c.purple },
    ["@boolean"] = { fg = c.purple },

    ["@type"] = { fg = c.blue },
    ["@type.builtin"] = { fg = c.cyan },
    ["@type.definition"] = { fg = c.blue },
    ["@type.qualifier"] = { fg = c.red },

    ["@attribute"] = { fg = c.green },
    ["@property"] = { fg = c.fg },

    ["@function"] = { fg = c.green },
    ["@function.builtin"] = { fg = c.green },
    ["@function.call"] = { fg = c.green },
    ["@function.macro"] = { fg = c.green },
    ["@function.method"] = { fg = c.green },
    ["@function.method.call"] = { fg = c.green },

    ["@constructor"] = { fg = c.blue },
    ["@operator"] = { fg = c.red },

    ["@keyword"] = { fg = c.red },
    ["@keyword.coroutine"] = { fg = c.red },
    ["@keyword.function"] = { fg = c.red },
    ["@keyword.operator"] = { fg = c.red },
    ["@keyword.import"] = { fg = c.red },
    ["@keyword.type"] = { fg = c.cyan },
    ["@keyword.modifier"] = { fg = c.red },
    ["@keyword.repeat"] = { fg = c.red },
    ["@keyword.return"] = { fg = c.red },
    ["@keyword.exception"] = { fg = c.red },
    ["@keyword.conditional"] = { fg = c.red },
    ["@keyword.directive"] = { fg = c.red },

    ["@punctuation.delimiter"] = { fg = c.fg },
    ["@punctuation.bracket"] = { fg = c.fg },
    ["@punctuation.special"] = { fg = c.purple },

    ["@comment"] = { fg = c.fg_comment, italic = true },
    ["@comment.documentation"] = { fg = c.fg_comment, italic = true },
    ["@comment.error"] = { fg = c.diag_error, bold = true },
    ["@comment.warning"] = { fg = c.diag_warn, bold = true },
    ["@comment.todo"] = { fg = c.bg, bg = c.diag_warn, bold = true },
    ["@comment.note"] = { fg = c.diag_hint, bold = true },

    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },

    ["@markup.heading"] = { fg = c.red, bold = true },
    ["@markup.heading.1"] = { fg = c.red, bold = true },
    ["@markup.heading.2"] = { fg = c.yellow, bold = true },
    ["@markup.heading.3"] = { fg = c.green, bold = true },
    ["@markup.heading.4"] = { fg = c.cyan, bold = true },
    ["@markup.heading.5"] = { fg = c.blue, bold = true },
    ["@markup.heading.6"] = { fg = c.purple, bold = true },

    ["@markup.quote"] = { fg = c.green },
    ["@markup.math"] = { fg = c.cyan },
    ["@markup.environment"] = { fg = c.purple },
    ["@markup.link"] = { fg = c.blue, underline = true },
    ["@markup.link.label"] = { fg = c.blue },
    ["@markup.link.url"] = { fg = c.cyan, underline = true },
    ["@markup.raw"] = { fg = c.cyan },
    ["@markup.raw.block"] = { fg = c.fg },
    ["@markup.list"] = { fg = c.fg_bright },
    ["@markup.list.checked"] = { fg = c.green },
    ["@markup.list.unchecked"] = { fg = c.fg_muted },

    ["@tag"] = { fg = c.red },
    ["@tag.attribute"] = { fg = c.green },
    ["@tag.delimiter"] = { fg = c.fg_comment },

    ---------------------------------------------------------------------------
    -- LSP Diagnostics
    ---------------------------------------------------------------------------
    DiagnosticError = { fg = c.diag_error },
    DiagnosticWarn = { fg = c.diag_warn },
    DiagnosticInfo = { fg = c.diag_info },
    DiagnosticHint = { fg = c.diag_hint },
    DiagnosticOk = { fg = c.diag_ok },

    DiagnosticUnderlineError = { sp = c.diag_error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.diag_warn, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.diag_info, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.diag_hint, undercurl = true },
    DiagnosticUnderlineOk = { sp = c.diag_ok, undercurl = true },

    DiagnosticVirtualTextError = { fg = c.diag_error, bg = c.diag_error_bg },
    DiagnosticVirtualTextWarn = { fg = c.diag_warn, bg = c.diag_warn_bg },
    DiagnosticVirtualTextInfo = { fg = c.diag_info, bg = c.diag_info_bg },
    DiagnosticVirtualTextHint = { fg = c.diag_hint, bg = c.diag_hint_bg },
    DiagnosticVirtualTextOk = { fg = c.diag_ok, bg = c.diff_add_bg },

    DiagnosticFloatingError = { fg = c.diag_error },
    DiagnosticFloatingWarn = { fg = c.diag_warn },
    DiagnosticFloatingInfo = { fg = c.diag_info },
    DiagnosticFloatingHint = { fg = c.diag_hint },
    DiagnosticFloatingOk = { fg = c.diag_ok },

    DiagnosticSignError = { fg = c.diag_error },
    DiagnosticSignWarn = { fg = c.diag_warn },
    DiagnosticSignInfo = { fg = c.diag_info },
    DiagnosticSignHint = { fg = c.diag_hint },
    DiagnosticSignOk = { fg = c.diag_ok },

    ---------------------------------------------------------------------------
    -- LSP Semantic Tokens
    ---------------------------------------------------------------------------
    ["@lsp.type.class"] = { fg = c.blue },
    ["@lsp.type.comment"] = { fg = c.fg_comment, italic = true },
    ["@lsp.type.decorator"] = { fg = c.green },
    ["@lsp.type.enum"] = { fg = c.blue },
    ["@lsp.type.enumMember"] = { fg = c.cyan },
    ["@lsp.type.function"] = { fg = c.green },
    ["@lsp.type.interface"] = { fg = c.blue },
    ["@lsp.type.macro"] = { fg = c.cyan },
    ["@lsp.type.method"] = { fg = c.green },
    ["@lsp.type.namespace"] = { fg = c.blue },
    ["@lsp.type.parameter"] = { fg = c.orange, italic = true },
    ["@lsp.type.property"] = { fg = c.fg },
    ["@lsp.type.struct"] = { fg = c.blue },
    ["@lsp.type.type"] = { fg = c.blue },
    ["@lsp.type.typeParameter"] = { fg = c.cyan },
    ["@lsp.type.variable"] = { fg = c.blue },

    ---------------------------------------------------------------------------
    -- Git / Diff
    ---------------------------------------------------------------------------
    DiffAdd = { fg = c.git_add, bg = c.diff_add_bg },
    DiffChange = { fg = c.git_change, bg = c.diff_change_bg },
    DiffDelete = { fg = c.git_delete, bg = c.diff_delete_bg },
    DiffText = { fg = c.fg_bright, bg = c.diff_text_bg, bold = true },

    diffAdded = { fg = c.git_add },
    diffRemoved = { fg = c.git_delete },
    diffChanged = { fg = c.git_change },
    diffOldFile = { fg = c.yellow },
    diffNewFile = { fg = c.green },
    diffFile = { fg = c.blue },
    diffLine = { fg = c.fg_muted },
    diffIndexLine = { fg = c.purple },

    GitSignsAdd = { fg = c.git_add },
    GitSignsChange = { fg = c.git_change },
    GitSignsDelete = { fg = c.git_delete },

    ---------------------------------------------------------------------------
    -- Plugin: Telescope
    ---------------------------------------------------------------------------
    TelescopeNormal = { fg = c.fg, bg = c.bg_float },
    TelescopeBorder = { fg = c.border, bg = c.bg_float },
    TelescopeTitle = { fg = c.bg, bg = c.accent, bold = true },

    TelescopePromptNormal = { fg = c.fg_bright, bg = c.bg_visual },
    TelescopePromptBorder = { fg = c.accent, bg = c.bg_visual },
    TelescopePromptTitle = { fg = c.bg, bg = c.accent, bold = true },
    TelescopePromptPrefix = { fg = c.accent, bg = c.bg_visual, bold = true },
    TelescopePromptCounter = { fg = c.fg_muted, bg = c.bg_visual },

    TelescopeResultsNormal = { fg = c.fg, bg = c.bg_float },
    TelescopeResultsBorder = { fg = c.border, bg = c.bg_float },
    TelescopeResultsTitle = { fg = c.bg, bg = c.cyan, bold = true },

    TelescopePreviewNormal = { fg = c.fg, bg = c.bg_dark },
    TelescopePreviewBorder = { fg = c.border, bg = c.bg_dark },
    TelescopePreviewTitle = { fg = c.bg, bg = c.green, bold = true },

    TelescopeSelection = { fg = c.fg_bright, bg = c.bg_visual, bold = true },
    TelescopeSelectionCaret = { fg = c.accent, bg = c.bg_visual, bold = true },
    TelescopeMatching = { fg = c.accent, bold = true },

    ---------------------------------------------------------------------------
    -- Plugin: NvimTree
    ---------------------------------------------------------------------------
    NvimTreeNormal = { fg = c.fg, bg = c.bg_dark },
    NvimTreeNormalNC = { fg = c.fg_muted, bg = c.bg_dark },
    NvimTreeWinSeparator = { fg = c.border, bg = c.bg_dark },
    NvimTreeRootFolder = { fg = c.accent, bold = true },
    NvimTreeFolderName = { fg = c.blue },
    NvimTreeFolderIcon = { fg = c.accent },
    NvimTreeOpenedFolderName = { fg = c.blue, bold = true },
    NvimTreeEmptyFolderName = { fg = c.fg_muted },
    NvimTreeIndentMarker = { fg = c.border },

    NvimTreeGitDirty = { fg = c.git_change },
    NvimTreeGitStaged = { fg = c.git_add },
    NvimTreeGitMerge = { fg = c.purple },
    NvimTreeGitRenamed = { fg = c.yellow },
    NvimTreeGitNew = { fg = c.accent },
    NvimTreeGitDeleted = { fg = c.git_delete },

    NvimTreeSpecialFile = { fg = c.yellow, underline = true },
    NvimTreeExecFile = { fg = c.green, bold = true },
    NvimTreeImageFile = { fg = c.purple },
    NvimTreeWindowPicker = { fg = c.bg, bg = c.accent, bold = true },
    NvimTreeCursorLine = { bg = c.bg_visual },

    ---------------------------------------------------------------------------
    -- Plugin: nvim-cmp
    ---------------------------------------------------------------------------
    CmpItemAbbr = { fg = c.fg },
    CmpItemAbbrDeprecated = { fg = c.fg_comment, strikethrough = true },
    CmpItemAbbrMatch = { fg = c.accent, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = c.accent, bold = true },
    CmpItemMenu = { fg = c.fg_muted, italic = true },

    CmpItemKindDefault = { fg = c.fg },
    CmpItemKindFunction = { fg = c.green },
    CmpItemKindMethod = { fg = c.green },
    CmpItemKindConstructor = { fg = c.blue },
    CmpItemKindClass = { fg = c.blue },
    CmpItemKindInterface = { fg = c.blue },
    CmpItemKindStruct = { fg = c.blue },
    CmpItemKindVariable = { fg = c.blue },
    CmpItemKindField = { fg = c.fg },
    CmpItemKindProperty = { fg = c.fg },
    CmpItemKindEnum = { fg = c.blue },
    CmpItemKindEnumMember = { fg = c.cyan },
    CmpItemKindKeyword = { fg = c.red },
    CmpItemKindConstant = { fg = c.cyan },
    CmpItemKindSnippet = { fg = c.purple },
    CmpItemKindText = { fg = c.fg },
    CmpItemKindFile = { fg = c.blue },
    CmpItemKindFolder = { fg = c.accent },
    CmpItemKindUnit = { fg = c.purple },
    CmpItemKindValue = { fg = c.cyan },
    CmpItemKindEvent = { fg = c.yellow },
    CmpItemKindOperator = { fg = c.red },
    CmpItemKindTypeParameter = { fg = c.cyan },

    ---------------------------------------------------------------------------
    -- Plugin: Bufferline
    ---------------------------------------------------------------------------
    BufferLineFill = { bg = c.bg_dark },
    BufferLineBackground = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineBufferVisible = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineBufferSelected = { fg = c.fg_bright, bg = c.bg, bold = true },
    BufferLineDuplicate = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineDuplicateVisible = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineDuplicateSelected = { fg = c.fg_bright, bg = c.bg, bold = true },
    BufferLineIndicatorSelected = { fg = c.accent, bg = c.bg },
    BufferLineSeparator = { fg = c.bg_dark, bg = c.bg_dark },
    BufferLineSeparatorVisible = { fg = c.bg_dark, bg = c.bg_dark },
    BufferLineSeparatorSelected = { fg = c.bg_dark, bg = c.bg },
    BufferLineModified = { fg = c.diag_warn, bg = c.bg_dark },
    BufferLineModifiedVisible = { fg = c.diag_warn, bg = c.bg_dark },
    BufferLineModifiedSelected = { fg = c.diag_warn, bg = c.bg },

    ---------------------------------------------------------------------------
    -- Plugin: Trouble
    ---------------------------------------------------------------------------
    TroubleNormal = { fg = c.fg, bg = c.bg_dark },
    TroubleText = { fg = c.fg },
    TroubleCount = { fg = c.purple, bold = true },
    TroubleCode = { fg = c.cyan },
    TroubleSource = { fg = c.fg_muted },
    TroubleDirectory = { fg = c.blue },

    ---------------------------------------------------------------------------
    -- Plugin: Todo Comments
    ---------------------------------------------------------------------------
    TodoBgTODO = { fg = c.bg, bg = c.diag_warn, bold = true },
    TodoFgTODO = { fg = c.diag_warn },
    TodoBgWARN = { fg = c.bg, bg = c.diag_warn, bold = true },
    TodoFgWARN = { fg = c.diag_warn },
    TodoBgFIX = { fg = c.bg, bg = c.diag_error, bold = true },
    TodoFgFIX = { fg = c.diag_error },
    TodoBgNOTE = { fg = c.bg, bg = c.diag_hint, bold = true },
    TodoFgNOTE = { fg = c.diag_hint },
    TodoBgPERF = { fg = c.bg, bg = c.purple, bold = true },
    TodoFgPERF = { fg = c.purple },

    ---------------------------------------------------------------------------
    -- Plugin: Render Markdown
    ---------------------------------------------------------------------------
    RenderMarkdownH1 = { fg = c.red, bold = true },
    RenderMarkdownH2 = { fg = c.yellow, bold = true },
    RenderMarkdownH3 = { fg = c.green, bold = true },
    RenderMarkdownH4 = { fg = c.cyan, bold = true },
    RenderMarkdownH5 = { fg = c.blue, bold = true },
    RenderMarkdownH6 = { fg = c.purple, bold = true },
    RenderMarkdownH1Bg = { bg = c.bg_float },
    RenderMarkdownH2Bg = { bg = c.bg_float },
    RenderMarkdownH3Bg = { bg = c.bg_float },
    RenderMarkdownH4Bg = { bg = c.bg_float },
    RenderMarkdownH5Bg = { bg = c.bg_float },
    RenderMarkdownH6Bg = { bg = c.bg_float },
    RenderMarkdownCode = { bg = c.bg_float },
    RenderMarkdownCodeInline = { fg = c.cyan, bg = c.bg_float },
    RenderMarkdownBullet = { fg = c.fg_bright, bold = true },
    RenderMarkdownQuote = { fg = c.green },
    RenderMarkdownTableHead = { fg = c.fg_bright, bold = true },
    RenderMarkdownTableRow = { fg = c.fg },

    ---------------------------------------------------------------------------
    -- Plugin: DAP UI
    ---------------------------------------------------------------------------
    DapUIScope = { fg = c.blue, bold = true },
    DapUIType = { fg = c.cyan },
    DapUIValue = { fg = c.fg_bright },
    DapUIVariable = { fg = c.fg },
    DapUIModifiedValue = { fg = c.accent, bold = true },
    DapUIDecoration = { fg = c.accent },
    DapUIThread = { fg = c.green },
    DapUIStoppedThread = { fg = c.accent },
    DapUISource = { fg = c.blue },
    DapUILineNumber = { fg = c.fg_muted },
    DapUIFloatBorder = { fg = c.border, bg = c.bg_float },
    DapUIWatchesEmpty = { fg = c.fg_muted },
    DapUIWatchesValue = { fg = c.green },
    DapUIWatchesError = { fg = c.diag_error },
    DapUIBreakpointsPath = { fg = c.blue },
    DapUIBreakpointsInfo = { fg = c.cyan },
    DapUIBreakpointsCurrentLine = { fg = c.accent, bold = true },
    DapStopped = { fg = c.accent, bold = true },
    DapBreakpoint = { fg = c.diag_error },
    DapBreakpointCondition = { fg = c.diag_warn },
    DapBreakpointRejected = { fg = c.fg_muted },

    ---------------------------------------------------------------------------
    -- Plugin: Alpha Dashboard
    ---------------------------------------------------------------------------
    AlphaHeader = { fg = c.accent, bold = true },
    AlphaButtons = { fg = c.blue },
    AlphaShortcut = { fg = c.yellow, bold = true },
    AlphaFooter = { fg = c.fg_comment, italic = true },

    ---------------------------------------------------------------------------
    -- Plugin: Satellite (Scrollbar)
    ---------------------------------------------------------------------------
    SatelliteBar = { bg = c.bg_visual },
    SatelliteSearch = { fg = c.accent },
    SatelliteDiagnosticError = { fg = c.diag_error },
    SatelliteDiagnosticWarn = { fg = c.diag_warn },
    SatelliteDiagnosticInfo = { fg = c.diag_info },
    SatelliteDiagnosticHint = { fg = c.diag_hint },

    ---------------------------------------------------------------------------
    -- Dressing / General UI Floats
    ---------------------------------------------------------------------------
    DressingSelectText = { fg = c.fg_bright },
  }
end

return M
