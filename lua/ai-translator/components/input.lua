local Input = require "nui.input"
local event = require("nui.utils.autocmd").event

---@class ai-translator.Components.Input
local M = {}

---@param callback function
function M:new(callback)
    local input = Input({
        relative = "cursor",
        position = {
            row = 2,
            col = 2,
        },
        size = {
            width = 20,
        },
        border = {
            style = "rounded",
            text = {
                top = "[language]",
                top_align = "center",
            },
        },
    }, {
        prompt = "> ",
        -- default_value = config.language,
        on_submit = function(value)
            callback(value)
        end,
    })

    local obj = { input = input }

    setmetatable(obj, self)

    function obj:mount()
        self.input:mount()
        self.input:map("n", "<Esc>", function()
            self.input:unmount()
        end, { noremap = true })
        self.input:on(event.BufLeave, function()
            self.input:unmount()
        end)
    end

    return obj
end

return M
