vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? LazyVimConfig
function M.setup(opts)
  require("lazylite.config").setup(opts)
end

return M
