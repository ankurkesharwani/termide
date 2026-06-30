local M = {}

local variant_file = vim.fn.stdpath("data") .. "/theme_variants.json"
local state

local function read_json(path)
  if vim.fn.filereadable(path) ~= 1 then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  if ok and type(decoded) == "table" then
    return decoded
  end

  return {}
end

local function load_state()
  if state then
    return state
  end

  state = read_json(variant_file)

  local old_sonokai_file = vim.fn.stdpath("data") .. "/sonokai_style"
  if not state.sonokai and vim.fn.filereadable(old_sonokai_file) == 1 then
    state.sonokai = vim.fn.readfile(old_sonokai_file)[1]
  end

  return state
end

local function save_state()
  vim.fn.writefile({ vim.json.encode(load_state()) }, variant_file)
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Theme" })
end

local function colorscheme(name)
  vim.cmd("colorscheme " .. name)
end

local function clear_modules(prefix)
  for name in pairs(package.loaded) do
    if name == prefix or name:sub(1, #prefix + 1) == prefix .. "." then
      package.loaded[name] = nil
    end
  end
end

M.themes = {
  sonokai = {
    label = "Sonokai",
    colorscheme = "sonokai",
    default = "default",
    variants = { "default", "atlantis", "andromeda", "shusia", "maia", "espresso" },
    current = function()
      return vim.g.sonokai_style or "default"
    end,
    set = function(value)
      vim.g.sonokai_style = value
    end,
  },
  everforest = {
    label = "Everforest",
    colorscheme = "everforest",
    default = "medium",
    variants = { "hard", "medium", "soft" },
    current = function()
      return vim.g.everforest_background or "medium"
    end,
    set = function(value)
      vim.g.everforest_background = value
    end,
  },
  onedark = {
    label = "OneDark",
    colorscheme = "onedark",
    default = "dark",
    variants = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
    current = function()
      return vim.g.onedark_config and vim.g.onedark_config.style or "dark"
    end,
    set = function(value)
      require("onedark").setup({ style = value })
    end,
  },
  oldworld = {
    label = "Oldworld",
    colorscheme = "oldworld",
    default = "default",
    variants = { "default", "oled", "cooler" },
    current = function()
      local ok, config = pcall(require, "oldworld.config")
      return ok and config.variant or "default"
    end,
    set = function(value)
      clear_modules("oldworld")
      require("oldworld").setup({ variant = value })
    end,
  },
  material = {
    label = "Material",
    aliases = {
      "material-darker",
      "material-deep-ocean",
      "material-lighter",
      "material-oceanic",
      "material-palenight",
    },
    colorscheme = "material",
    default = "oceanic",
    variants = { "oceanic", "deep ocean", "palenight", "darker", "lighter" },
    current = function()
      return vim.g.material_style or "oceanic"
    end,
    set = function(value)
      vim.g.material_style = value
    end,
  },
  tokyonight = {
    label = "TokyoNight",
    aliases = { "tokyonight" },
    default = "night",
    variants = { "night", "storm", "moon", "day" },
    colorscheme = function(value)
      return "tokyonight-" .. value
    end,
  },
  catppuccin = {
    label = "Catppuccin",
    aliases = { "catppuccin" },
    default = "mocha",
    variants = { "mocha", "macchiato", "frappe", "latte" },
    colorscheme = function(value)
      return "catppuccin-" .. value
    end,
  },
  kanagawa = {
    label = "Kanagawa",
    aliases = { "kanagawa" },
    default = "wave",
    variants = { "wave", "dragon", "lotus" },
    colorscheme = function(value)
      return "kanagawa-" .. value
    end,
  },
  ["rose-pine"] = {
    label = "Rose Pine",
    aliases = { "rose-pine" },
    default = "main",
    variants = { "main", "moon", "dawn" },
    colorscheme = function(value)
      return "rose-pine-" .. value
    end,
  },
  nightfox = {
    label = "Nightfox",
    default = "nightfox",
    variants = { "nightfox", "dayfox", "dawnfox", "duskfox", "nordfox", "terafox", "carbonfox" },
    colorscheme = function(value)
      return value
    end,
  },
  github = {
    label = "GitHub",
    default = "dark",
    variants = {
      "dark",
      "dark_default",
      "dark_dimmed",
      "dark_high_contrast",
      "dark_colorblind",
      "dark_tritanopia",
      "light",
      "light_default",
      "light_high_contrast",
      "light_colorblind",
      "light_tritanopia",
    },
    colorscheme = function(value)
      return "github_" .. value
    end,
  },
  ayu = {
    label = "Ayu",
    aliases = { "ayu" },
    default = "dark",
    variants = { "dark", "light", "mirage" },
    colorscheme = function(value)
      return "ayu-" .. value
    end,
  },
  bluloco = {
    label = "Bluloco",
    aliases = { "bluloco" },
    default = "dark",
    variants = { "dark", "light" },
    colorscheme = function(value)
      return "bluloco-" .. value
    end,
  },
}

local function target_colorscheme(entry, value)
  if type(entry.colorscheme) == "function" then
    return entry.colorscheme(value)
  end

  return entry.colorscheme
end

local function has_variant(entry, value)
  return vim.tbl_contains(entry.variants, value)
end

local function family_for(colors_name)
  if not colors_name then
    return nil, nil
  end

  for family, entry in pairs(M.themes) do
    if colors_name == family or colors_name == entry.colorscheme then
      return family, entry
    end

    for _, alias in ipairs(entry.aliases or {}) do
      if colors_name == alias then
        return family, entry
      end
    end

    for _, variant in ipairs(entry.variants) do
      if colors_name == target_colorscheme(entry, variant) then
        return family, entry
      end
    end
  end

  return nil, nil
end

local function current_variant(family, entry)
  if entry.current then
    return entry.current()
  end

  local colors_name = vim.g.colors_name
  for _, variant in ipairs(entry.variants) do
    if colors_name == target_colorscheme(entry, variant) then
      return variant
    end
  end

  return load_state()[family] or entry.default
end

function M.apply_saved_variant(colors_name)
  local family, entry = family_for(colors_name)
  local value = family and load_state()[family]

  if value and entry and entry.set and has_variant(entry, value) then
    entry.set(value)
  end
end

function M.apply_variant(family, value)
  local entry = M.themes[family]
  if not entry then
    notify("No variants registered for current theme", vim.log.levels.WARN)
    return
  end

  if not has_variant(entry, value) then
    notify(("Unknown %s variant: %s"):format(entry.label or family, value), vim.log.levels.ERROR)
    return
  end

  local variants = load_state()
  local previous = variants[family]
  variants[family] = value

  if entry.set then
    entry.set(value)
  end

  local ok, err = pcall(colorscheme, target_colorscheme(entry, value))
  if not ok then
    variants[family] = previous
    notify(err, vim.log.levels.ERROR)
    return
  end

  save_state()
end

function M.select_theme()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    notify("Telescope is not available", vim.log.levels.ERROR)
    return
  end

  builtin.colorscheme({ enable_preview = true })
end

function M.select_variant()
  local family, entry = family_for(vim.g.colors_name)
  if not entry then
    notify(("No variants registered for current theme: %s"):format(vim.g.colors_name or "none"), vim.log.levels.WARN)
    return
  end

  local current = current_variant(family, entry)
  vim.ui.select(entry.variants, {
    prompt = ("%s variant%s:"):format(entry.label or family, current and " (" .. current .. ")" or ""),
  }, function(choice)
    if choice then
      M.apply_variant(family, choice)
    end
  end)
end

function M.complete_variants()
  local _, entry = family_for(vim.g.colors_name)
  return entry and entry.variants or {}
end

function M.setup()
  vim.api.nvim_create_user_command("ThemeSelect", M.select_theme, {
    desc = "Select colorscheme with preview",
  })

  vim.api.nvim_create_user_command("ThemeVariant", function(opts)
    if opts.args ~= "" then
      local family = family_for(vim.g.colors_name)
      M.apply_variant(family, opts.args)
    else
      M.select_variant()
    end
  end, {
    nargs = "*",
    complete = M.complete_variants,
    desc = "Select variant for current colorscheme",
  })

  vim.api.nvim_create_autocmd("ColorSchemePre", {
    callback = function(args)
      M.apply_saved_variant(args.match)
    end,
  })
end

return M
