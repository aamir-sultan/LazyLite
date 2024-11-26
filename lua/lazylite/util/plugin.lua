local Plugin = require("lazy.core.plugin")

---@class lazylite.util.plugin
local M = {}

---@type string[]
M.core_imports = {}

M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

---@type table<string, string>
M.deprecated_extras = {
  ["lazylite.plugins.extras.formatting.conform"] = "`conform.nvim` is now the default **LazyLite** formatter.",
  ["lazylite.plugins.extras.linting.nvim-lint"] = "`nvim-lint` is now the default **LazyLite** linter.",
  ["lazylite.plugins.extras.ui.dashboard"] = "`dashboard.nvim` is now the default **LazyLite** starter.",
  ["lazylite.plugins.extras.coding.native_snippets"] = "Native snippets are now the default for **Neovim >= 0.10**",
  ["lazylite.plugins.extras.ui.treesitter-rewrite"] = "Disabled `treesitter-rewrite` extra for now. Not ready yet.",
  ["lazylite.plugins.extras.coding.mini-ai"] = "`mini.ai` is now a core LazyLite plugin (again)",
  ["lazylite.plugins.extras.lazyrc"] = "local spec files are now a lazy.nvim feature",
  ["lazylite.plugins.extras.editor.trouble-v3"] = "Trouble v3 has been merged in main",
  ["lazylite.plugins.extras.lang.python-semshi"] = [[The python-semshi extra has been removed,
  because it's causing too many issues.
  Either use `basedpyright`, or copy the [old extra](https://github.com/LazyLite/LazyLite/blob/c1f5fcf9c7ed2659c9d5ac41b3bb8a93e0a3c6a0/lua/lazylite/plugins/extras/lang/python-semshi.lua#L1) to your own config.
  ]],
}

M.deprecated_modules = {}

---@type table<string, string>
M.renames = {
  ["windwp/nvim-spectre"] = "nvim-pack/nvim-spectre",
  ["jose-elias-alvarez/null-ls.nvim"] = "nvimtools/none-ls.nvim",
  ["null-ls.nvim"] = "none-ls.nvim",
  ["romgrk/nvim-treesitter-context"] = "nvim-treesitter/nvim-treesitter-context",
  ["glepnir/dashboard-nvim"] = "nvimdev/dashboard-nvim",
  ["markdown.nvim"] = "render-markdown.nvim",
}

function M.save_core()
  if vim.v.vim_did_enter == 1 then
    return
  end
  M.core_imports = vim.deepcopy(require("lazy.core.config").spec.modules)
end

function M.setup()
  M.fix_imports()
  M.fix_renames()
  M.lazy_file()
  table.insert(package.loaders, function(module)
    if M.deprecated_modules[module] then
      LazyLite.warn(
        ("`%s` is no longer included by default in **LazyLite**.\nPlease install the `%s` extra if you still want to use it."):format(
          module,
          M.deprecated_modules[module]
        ),
        { title = "LazyLite" }
      )
      return function() end
    end
  end)
end

function M.extra_idx(name)
  local Config = require("lazy.core.config")
  for i, extra in ipairs(Config.spec.modules) do
    if extra == "lazylite.plugins.extras." .. name then
      return i
    end
  end
end

function M.lazy_file()
  -- Add support for the LazyFile event
  local Event = require("lazy.core.handler.event")

  Event.mappings.LazyFile = { id = "LazyFile", event = M.lazy_file_events }
  Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end

function M.fix_imports()
  Plugin.Spec.import = LazyLite.inject.args(Plugin.Spec.import, function(_, spec)
    local dep = M.deprecated_extras[spec and spec.import]
    if dep then
      dep = dep .. "\n" .. "Please remove the extra from `lazylite.json` to hide this warning."
      LazyLite.warn(dep, { title = "LazyLite", once = true, stacktrace = true, stacklevel = 6 })
      return false
    end
  end)
end

function M.fix_renames()
  Plugin.Spec.add = LazyLite.inject.args(Plugin.Spec.add, function(self, plugin)
    if type(plugin) == "table" then
      if M.renames[plugin[1]] then
        LazyLite.warn(
          ("Plugin `%s` was renamed to `%s`.\nPlease update your config for `%s`"):format(
            plugin[1],
            M.renames[plugin[1]],
            self.importing or "LazyLite"
          ),
          { title = "LazyLite" }
        )
        plugin[1] = M.renames[plugin[1]]
      end
    end
  end)
end

return M
