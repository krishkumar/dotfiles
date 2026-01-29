--[[
================================================================================
Git Jump - Navigate to the latest commit changes in your current file
================================================================================

USAGE:
  <leader>gl  - Open popup showing latest commit info for current file
  <leader>gL  - Quick jump directly to first changed line (no popup)

POPUP KEYBINDINGS:
  j     - Jump to first changed line from this commit
  n     - Jump to next changed line (wraps around)
  p     - Jump to previous changed line (wraps around)
  d     - Show full diff for the commit
  b     - Open git blame for the file
  y     - Copy full commit hash to clipboard
  o     - Open commit in browser (GitHub/GitLab)
  l     - Show last 20 commits for this file
  q/Esc - Close popup

HOW IT WORKS:
  1. Finds the latest commit that modified the current file
  2. Uses git blame to identify which lines in the file came from that commit
  3. Lets you navigate through those specific lines

REQUIREMENTS:
  - tpope/vim-fugitive (for :Git commands)
  - File must be in a git repository
  - File must have git history

================================================================================
--]]

local M = {}

--- Get the latest commit info for a file
---@param file string absolute path to file
---@return table|nil commit info {hash, short_hash, author, date, message} or nil
local function get_latest_commit(file)
  local cmd = string.format("git log -1 --format='%%H|%%h|%%an|%%ar|%%s' -- %s", vim.fn.shellescape(file))
  local result = vim.fn.system(cmd):gsub("\n$", "")

  if vim.v.shell_error ~= 0 or result == "" then
    return nil
  end

  local hash, short_hash, author, date, message = result:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.+)")
  return {
    hash = hash,
    short_hash = short_hash,
    author = author,
    date = date,
    message = message,
  }
end

--- Find all line numbers in file that were introduced by a specific commit
---@param file string absolute path to file
---@param commit_hash string full commit hash to match
---@return table list of line numbers
local function get_changed_lines(file, commit_hash)
  local blame_cmd = string.format("git blame -l %s 2>/dev/null", vim.fn.shellescape(file))
  local blame_output = vim.fn.system(blame_cmd)
  local changed_lines = {}

  if vim.v.shell_error ~= 0 then
    return changed_lines
  end

  local line_num = 0
  for line in blame_output:gmatch("[^\n]+") do
    line_num = line_num + 1
    local line_hash = line:match("^(%x+)")
    if line_hash and commit_hash:sub(1, #line_hash) == line_hash then
      table.insert(changed_lines, line_num)
    end
  end

  return changed_lines
end

--- Create a centered floating window
---@param lines table content lines
---@return number buf buffer handle
---@return number win window handle
local function create_popup(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 62
  local height = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "none",
  })

  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  return buf, win
end

--- Open commit in browser (supports GitHub, GitLab, etc.)
---@param hash string commit hash
local function open_in_browser(hash)
  local remote = vim.fn.system("git remote get-url origin"):gsub("\n$", "")
  if vim.v.shell_error ~= 0 or remote == "" then
    vim.notify("No remote found", vim.log.levels.WARN)
    return
  end

  -- Convert SSH to HTTPS format
  remote = remote:gsub("git@([^:]+):", "https://%1/")
  remote = remote:gsub("%.git$", "")
  local url = remote .. "/commit/" .. hash

  vim.ui.open(url)
  vim.notify("Opening: " .. url, vim.log.levels.INFO)
end

--- Show the git jump popup with commit info and navigation options
local function show_popup()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file open", vim.log.levels.WARN)
    return
  end

  local commit = get_latest_commit(file)
  if not commit then
    vim.notify("No git history for this file", vim.log.levels.WARN)
    return
  end

  local changed_lines = get_changed_lines(file, commit.hash)

  -- Build popup content
  local lines = {
    "╭───────────────────────────────────────────────────────────╮",
    "│  Latest Commit for Current File                          │",
    "├───────────────────────────────────────────────────────────┤",
    string.format("│  %s  %s", commit.short_hash, commit.message:sub(1, 46)),
    string.format("│  by %s, %s", commit.author, commit.date),
    "├───────────────────────────────────────────────────────────┤",
  }

  if #changed_lines > 0 then
    local line_preview = table.concat(vim.list_slice(changed_lines, 1, math.min(8, #changed_lines)), ", ")
    if #changed_lines > 8 then
      line_preview = line_preview .. "..."
    end
    table.insert(lines, string.format("│  Changed lines (%d): %s", #changed_lines, line_preview))
    table.insert(lines, "├───────────────────────────────────────────────────────────┤")
    table.insert(lines, "│  [j] Jump to first   [n] Next change   [p] Prev change   │")
  end

  table.insert(lines, "│  [d] Diff   [b] Blame   [y] Copy hash   [o] Browser       │")
  table.insert(lines, "│  [l] Log    [q] Close                                     │")
  table.insert(lines, "╰───────────────────────────────────────────────────────────╯")

  local buf, win = create_popup(lines)

  -- Apply highlights
  vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "String", 3, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 4, 0, -1)
  if #changed_lines > 0 then
    vim.api.nvim_buf_add_highlight(buf, -1, "DiagnosticInfo", 6, 0, -1)
  end

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local opts = { buffer = buf, noremap = true, silent = true }

  -- Close mappings
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  -- Jump to first changed line
  vim.keymap.set("n", "j", function()
    if #changed_lines > 0 then
      close()
      vim.api.nvim_win_set_cursor(0, { changed_lines[1], 0 })
      vim.cmd("normal! zz")
      vim.notify(
        string.format("Line %d (1/%d changes from %s)", changed_lines[1], #changed_lines, commit.short_hash),
        vim.log.levels.INFO
      )
    else
      vim.notify("No changed lines found in current file", vim.log.levels.WARN)
    end
  end, opts)

  -- Next changed line
  vim.keymap.set("n", "n", function()
    if #changed_lines == 0 then
      vim.notify("No changed lines found", vim.log.levels.WARN)
      return
    end
    close()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local next_line = nil
    local next_idx = 1

    for i, ln in ipairs(changed_lines) do
      if ln > cursor_line then
        next_line = ln
        next_idx = i
        break
      end
    end

    -- Wrap around
    if not next_line then
      next_line = changed_lines[1]
      next_idx = 1
    end

    vim.api.nvim_win_set_cursor(0, { next_line, 0 })
    vim.cmd("normal! zz")
    vim.notify(string.format("Line %d (%d/%d changes)", next_line, next_idx, #changed_lines), vim.log.levels.INFO)
  end, opts)

  -- Previous changed line
  vim.keymap.set("n", "p", function()
    if #changed_lines == 0 then
      vim.notify("No changed lines found", vim.log.levels.WARN)
      return
    end
    close()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local prev_line = nil
    local prev_idx = #changed_lines

    for i = #changed_lines, 1, -1 do
      if changed_lines[i] < cursor_line then
        prev_line = changed_lines[i]
        prev_idx = i
        break
      end
    end

    -- Wrap around
    if not prev_line then
      prev_line = changed_lines[#changed_lines]
      prev_idx = #changed_lines
    end

    vim.api.nvim_win_set_cursor(0, { prev_line, 0 })
    vim.cmd("normal! zz")
    vim.notify(string.format("Line %d (%d/%d changes)", prev_line, prev_idx, #changed_lines), vim.log.levels.INFO)
  end, opts)

  -- Show diff
  vim.keymap.set("n", "d", function()
    close()
    vim.cmd("Git show " .. commit.hash .. " -- " .. vim.fn.fnameescape(file))
  end, opts)

  -- Git blame
  vim.keymap.set("n", "b", function()
    close()
    vim.cmd("Git blame")
  end, opts)

  -- Copy hash
  vim.keymap.set("n", "y", function()
    vim.fn.setreg("+", commit.hash)
    vim.notify("Copied: " .. commit.hash, vim.log.levels.INFO)
    close()
  end, opts)

  -- Open in browser
  vim.keymap.set("n", "o", function()
    close()
    open_in_browser(commit.hash)
  end, opts)

  -- Show log
  vim.keymap.set("n", "l", function()
    close()
    vim.cmd("Git log --oneline -20 -- " .. vim.fn.fnameescape(file))
  end, opts)
end

--- Quick jump to first changed line (no popup)
local function quick_jump()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file open", vim.log.levels.WARN)
    return
  end

  local commit = get_latest_commit(file)
  if not commit then
    vim.notify("No git history for this file", vim.log.levels.WARN)
    return
  end

  local changed_lines = get_changed_lines(file, commit.hash)
  if #changed_lines == 0 then
    vim.notify("No changed lines found from latest commit", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_win_set_cursor(0, { changed_lines[1], 0 })
  vim.cmd("normal! zz")
  vim.notify(
    string.format("Jumped to line %d (commit %s: %s)", changed_lines[1], commit.short_hash, commit.message:sub(1, 40)),
    vim.log.levels.INFO
  )
end

return {
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gl", show_popup, desc = "Git: Latest commit for file" },
      { "<leader>gL", quick_jump, desc = "Git: Jump to latest change" },
    },
  },
}
