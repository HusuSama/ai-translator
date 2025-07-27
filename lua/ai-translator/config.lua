---@class ai-translator.CoreConfig: ai-translator.Config
local M = {}

---@class ai-translator.Config
M._default = {
    ---@alias ai-translator.Language string
    language = "Chinese",
    ---@alias ai-translator.ProviderName "openai" | string
    provider = "openai",
    -- If the api_key is not set, the environment variable API_KEY will be used. You can change it by configuring env_key.
    ---@alias ai-translator.ModelOpts {base_url: string, api_key?: string, env_key: string, model_name: string}
    model = {
        base_url = "https://api.deepseek.com/chat/completions",
        model_name = "deepseek-chat",
        env_key = "API_KEY",
    },
    ---@alias ai-translator.UIOptions {width: number, height: number, relative: string, position: table}
    ui = {
        width = 40,
        height = 20,
        relative = "cursor",
        position = { row = 3, col = 2 },
    },
    thinking_icons = { "🤯", "😶‍🌫️", "🤔", "🧠", "💭" },
}

---@private
---@param opts? ai-translator.Config
---@return ai-translator.Config
function M._merge_config(opts)
    local function deep_merge(default, user)
        if type(default) ~= "table" or type(user) ~= "table" then
            return user or default
        end

        local merged = {}
        for k, v in pairs(default) do
            if user[k] == nil then
                merged[k] = v
            else
                merged[k] = deep_merge(v, user[k])
            end
        end

        for k, v in pairs(user) do
            if merged[k] == nil then
                merged[k] = v
            end
        end
        return merged
    end

    return deep_merge(M._default, opts or {})
end

---@private
---@type ai-translator.Config
M._options = {}

---@param opts ai-translator.Config
---@return ai-translator.Config?
function M.merge(opts)
    local ok, merged = pcall(vim.tbl_deep_extend, "force", M._default, opts)
    if not ok then
        merged = M._merge_config(opts)
    end
    local check_opts = M.check_and_fill_config(merged)
    if check_opts == nil then
        vim.notify("check opts is nil", vim.log.levels.ERROR)
        return nil
    end
    M._options = check_opts
    return check_opts
end

---@return ai-translator.Config
function M.get_config()
    if M._options == {} then
        vim.notify("options is {}", vim.log.levels.ERROR)
    end
    return M._options
end

---@param config ai-translator.Config
---@return ai-translator.Config?
function M.check_and_fill_config(config)
    if not config.model.model_name or config.model.model_name == "" then
        vim.notify("model name not exist", vim.log.levels.ERROR)
        return nil
    end
    if not config.model.api_key or config.model.api_key == "" then
        if config.model.env_key then
            local api_key = os.getenv(config.model.env_key)
            if api_key ~= nil and api_key ~= "" then
                config.model.api_key = api_key
            else
                vim.notify("[ai-tranlator]api_key and env_key not exist", vim.log.levels.ERROR)
                return nil
            end
        else
            vim.notify("[ai-translator]api_key and env_key not exist", vim.log.levels.ERROR)
            return nil
        end
    end
    return config
end

return M
