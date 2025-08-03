local config = require "ai-translator.config"
local api = require "ai-translator.api"
local Input = require "ai-translator.components.input"
local Menu = require "ai-translator.components.menu"
local Providers = require "ai-translator.providers"
local Utils = require "ai-translator.utils"
local M = {}

M.config = nil

---@param language string
---@param mode string
local function normal_callback(language, mode)
    local words = Utils.get_word(mode)
    if language == nil or language == "" then
        return
    end
    local origin_config = M.config
    if origin_config == nil then
        vim.notify "config is nil"
        return
    end
    local cp_config = vim.deepcopy(origin_config)
    cp_config.language = language
    api.send_request(words, cp_config)
end

-- 翻译当前光标或者选择的文字
-- Translate the text at the current cursor position or the selected text
function M.trans_word()
    local mode = vim.api.nvim_get_mode()
    local words = Utils.get_word(mode.mode)
    api.send_request(words)
end

-- 自定义输入翻译的目标语言
-- Customize the target language for input translation
function M.trans_input_other_language()
    local mode = vim.api.nvim_get_mode()
    local input = Input:new(function(language)
        normal_callback(language, mode.mode)
    end)
    input:mount()
end

-- 选择choices配置的语言为目标语言
-- Select target language
function M.trans_select_other_language()
    local mode = vim.api.nvim_get_mode()
    local menu = Menu:new(function(language)
        normal_callback(language, mode.mode)
    end)
    menu:mount()
end

-- 翻译当前错误
-- translate diagnostic of line
function M.trans_line_diagnoctis()
    local words = Utils.get_line_diagnostic()
    api.send_request(words)
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
