local config = require "ai-translator.config"
local api = require "ai-translator.api"
local M = {}

M.config = nil

function M.trans()
  api.send_request()
end

function M.setup(opts)
  M.config = config.merge(opts)
  -- return if config is nil
  if M.config == nil then
    vim.notify "config is nil"
    return
  end
end

return M
