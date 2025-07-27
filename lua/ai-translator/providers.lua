local Utils = require "ai-translator.utils"

---@class ProviderBody
---@field body {model: string, messages: table, stream: boolean}
---@field separator string
---@field end_mark string
local M = {}

---@param config ai-translator.Config
function M.setup(config)
    local words = Utils.get_word()
    if config.provider == "openai" then
        local messages = {
            {
                role = "system",
                content = string.format(
                    "Translate into %s, and return the result in beautifully formatted Markdown (output translation only)",
                    config.language
                ),
            },
            {
                role = "user",
                content = words or "",
            },
        }
        M.separator = "data:"
        M.body = {
            model = config.model.model_name,
            messages = messages,
            stream = true,
        }
        M.end_mark = "[DONE]"
        return M
    end
end

return M
