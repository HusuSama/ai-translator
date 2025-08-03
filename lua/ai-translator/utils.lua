---@class ai-translator.Utils
local M = {}

---@return string
function M._get_cursor_word()
    return vim.fn.expand "<cword>"
end

---@return string
function M._get_visual_text_from_register()
    local original_register = vim.fn.getreg '"'
    local original_register_type = vim.fn.getregtype '"'

    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- vim.cmd "silent normal! y"
    vim.cmd 'silent normal! gv""y'

    local selection = vim.fn.getreg '"'

    vim.fn.setreg('"', original_register, original_register_type)

    vim.api.nvim_win_set_cursor(0, cursor_pos)

    return selection
end

---@return string
function M._get_visual_text()
    local mode = vim.fn.mode()

    local start_pos = vim.fn.getpos "'<"
    local end_pos = vim.fn.getpos "'>"

    local buf_handle = 0

    local start_line = start_pos[2] - 1
    local start_col = start_pos[3] - 1
    local end_line = end_pos[2] - 1
    local end_col = end_pos[3]

    if mode == "v" then
        end_col = end_col + 1
    elseif mode == "V" then
        start_col = 0
        end_col = -1
    elseif mode == "^V" then
        local lines = {}
        for lnum = start_line, end_line do
            local line = vim.api.nvim_buf_get_lines(buf_handle, lnum, lnum + 1, true)[1]
            local seg_end = math.min(end_col, #line)
            local segment = line:sub(start_col + 1, seg_end)
            table.insert(lines, segment)
            return table.concat(lines, "\n")
        end
    end

    local lines = vim.api.nvim_buf_get_text(buf_handle, start_line, start_col, end_line, end_col, {})
    return table.concat(lines, "\n")
end

---@param mode string
---@return string
function M.get_word(mode)
    if mode == "n" then
        return M._get_cursor_word()
    else
        return M._get_visual_text_from_register()
    end
end

function M.get_line_diagnostic()
    local messages = {}
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line "." - 1 })
    for _, value in ipairs(diagnostics) do
        table.insert(messages, value.message)
    end
    return table.concat(messages)
end

return M
