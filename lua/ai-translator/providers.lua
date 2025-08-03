local Utils = require "ai-translator.utils"

---@class ai-translator.ProviderBody
---@field body {model: string, messages: table, stream: boolean}
---@field separator string
---@field end_mark string
local M = {}

---@param config ai-translator.Config
---@param words string
function M.setup(config, words)
    -- local words = Utils.get_word()
    if config.provider == "openai" then
        local messages = {
            {
                role = "system",
                content = string.format(
                    [[
**ROLE**: Professional translation engine
**TASK**: Convert ALL input to %s using strict Markdown formatting

**CORE RULES**:
1. 🚫 **NEVER OMIT ORIGINAL TERMS**
   - Preserve ALL embedded words/phrases matching: `[a-zA-Z0-9_]+`
   - Even non-technical terms like "choices" must be retained
   - Always wrap preserved terms in `backticks`

2. 🔒 **PURE TRANSLATION OUTPUT**
   - Output ONLY translated content - no prefixes/suffixes
   - NEVER add explanations, notes, or commentary
   - Empty input → Empty output

3. ✨ **SMART MARKDOWN HANDLING**
   ```markdown
   # Automatic formatting:
   - Single words: `choices` → `choices`
   - Multi-word: `ResNet 50` → `ResNet 50`
   - Code blocks: Maintain original spacing/newlines
                    ]],
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
