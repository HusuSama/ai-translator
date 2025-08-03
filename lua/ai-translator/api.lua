local Config = require "ai-translator.config"
local Provider = require "ai-translator.providers"
local Popup = require "ai-translator.components.popup"
local Curl = require "plenary.curl"
local M = {}

---@param str string
---@return string
function M.trim(str)
    if not str then
        return ""
    end
    local trim_str = str:gsub("^[ ]*(.-)[ ]*$", "%1")
    return trim_str
end

---@param words string
---@param config? ai-translator.Config
function M.send_request(words, config)
    -- local config = Config.get_config()
    if config == nil then
        config = Config.get_config()
    end
    if words == nil or words == "" then
        vim.notify("[ai-translator] No message", vim.log.levels.ERROR)
        return
    end
    local provider = Provider.setup(config, words)
    local ui = Popup:new(config)
    ui:mount()
    ui:start_thinking_animation()
    local body = vim.json.encode(provider.body)
    Curl.post(config.model.base_url, {
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. config.model.api_key,
        },
        body = body,
        stream = function(_, chunk, _)
            local chunk_strings = vim.split(chunk, "\n\n")
            local llm_messages = vim.split(chunk_strings[1], provider.separator)
            for _, value in ipairs(llm_messages) do
                local message = M.trim(value)
                if message ~= provider.end_mark then
                    local ok, msg_table = pcall(vim.json.decode, message)
                    if
                        ok
                        and msg_table.choices
                        and msg_table.choices[1]
                        and msg_table.choices[1].delta
                        and msg_table.choices[1].delta.content
                    then
                        local content = msg_table.choices[1].delta.content
                        vim.schedule(function()
                            -- M.append_content(content)
                            if not ui.popup.winid then
                                return
                            end
                            ui:append_content(content)
                        end)
                    end
                else
                    vim.schedule(function()
                        if ui.animation_timer then
                            vim.fn.timer_stop(ui.animation_timer)
                            ui.animation_timer = nil
                            ui.animation_count = 0
                        end
                        if not ui.popup.winid then
                            return
                        end
                        ui.popup.border:set_text("bottom", "😊Complate!", "center")
                    end)
                end
            end
        end,
        callback = function(response)
            if response.status ~= 200 then
                vim.notify(response.body, vim.log.levels.ERROR)
                vim.schedule(function()
                    if ui.animation_timer then
                        vim.fn.timer_stop(ui.animation_timer)
                        ui.animation_timer = nil
                        ui.animation_count = 0
                    end
                    if not ui.popup.winid then
                        return
                    end
                    ui.popup.border:set_text("bottom", "❌Error " .. response.status, "center")
                end)
            end
        end,
    })
end

return M
