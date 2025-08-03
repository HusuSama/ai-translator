local Menu = require "nui.menu"
local Config = require "ai-translator.config"
local event = require("nui.utils.autocmd").event
local M = {}

local options = {
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
            top = "[Choose language]",
            top_align = "center",
        },
    },
}

---@param config ai-translator.Config
local function get_items(config)
    if config == nil or config.choices == nil or config.choices == {} then
        return {}
    end
    local menu_items = {}
    for _, value in ipairs(config.choices) do
        table.insert(menu_items, Menu.item(value))
    end
    return menu_items
end

function M:new(callback)
    local config = Config.get_config()
    local menu = Menu(options, {
        lines = get_items(config),
        max_width = 50,
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(item)
            callback(item.text)
        end,
    })

    local obj = { menu = menu, config = config }
    setmetatable(obj, self)

    function obj:mount()
        if self.config.choices == nil or self.config.choices == {} then
            vim.notify "no choices config"
            return
        end
        self.menu:mount()
        self.menu:map("n", { "<Esc>", "q" }, function()
            self.menu:unmount()
        end, { noremap = true })
        self.menu:on(event.BufLeave, function()
            self.menu:unmount()
        end)
    end

    return obj
end

return M
