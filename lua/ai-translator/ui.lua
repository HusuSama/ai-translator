local Popup = require "nui.popup"
local Config = require "ai-translator.config"
-- local config = Config.get_config()

---@class ai-translator.UIConfig
local M = {}

function M:new()
    local config = Config.get_config()
    local popup = Popup {
        ns_id = "ai-translator",
        enter = true,
        focusable = true,
        border = {
            style = "rounded",
            text = { top = "🤖 AI-Translator", top_align = "center" },
            padding = { 1, 1 },
        },
        relative = config.ui.relative,
        -- anchor = "NW",
        position = config.ui.position,
        size = { width = config.ui.width, height = config.ui.height },
        zindex = 50,
        buf_options = {
            filetype = "markdown",
        },
        win_options = {
            wrap = true,
            linebreak = true,
            breakindent = true,
        },
    }
    local obj = { popup = popup, animation_timer = nil, animation_count = 0 }

    setmetatable(obj, self)

    -- mount nui popup
    -- set popup mappings
    function obj:mount()
        if not self.popup.winid or vim.api.nvim_win_is_valid(self.popup.winid) then
            self.popup:mount()
            self.popup:map("n", "q", function()
                self.animation_count = 0
                if self.animation_timer then
                    vim.fn.timer_stop(self.animation_timer)
                    self.animation_timer = nil
                end
                self.popup:unmount()
            end, { noremap = true })
        end
    end

    -- start thinking animation
    function obj:start_thinking_animation()
        -- stop（if exist）
        if self.animation_timer then
            vim.fn.timer_stop(self.animation_timer)
            self.animation_timer = nil
        end

        -- start animation
        self.animation_timer = vim.fn.timer_start(300, function()
            self.animation_count = self.animation_count + 1
            local icons = { "🤯", "😶‍🌫️", "🤔", "🧠", "💭" }
            local icon = icons[(self.animation_count % #icons) + 1]

            if self.popup.winid and vim.api.nvim_win_is_valid(self.popup.winid) then
                self.popup.border:set_text("bottom", icon .. " thinking...", "center")
            end
        end, { ["repeat"] = -1 }) -- 无限重复
    end

    ---@param content string
    function obj:append_content(content)
        if not self.popup.winid then
            return
        end
        local lines = vim.api.nvim_buf_get_lines(self.popup.bufnr, 0, -1, false)
        local new_lines = vim.split(content, "\n")
        if #lines > 0 then
            lines[#lines] = lines[#lines] .. (new_lines[1] or "")
            table.remove(new_lines, 1)
        end
        for _, line in ipairs(new_lines) do
            table.insert(lines, line)
        end
        vim.api.nvim_buf_set_lines(self.popup.bufnr, 0, -1, false, lines)
        local last_line = math.max(1, #lines)
        vim.api.nvim_win_set_cursor(self.popup.winid, { last_line, 0 })
    end

    return obj
end

return M
