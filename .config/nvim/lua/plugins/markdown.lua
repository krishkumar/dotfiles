return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      -- Custom "Modern / Refined" light theme. CSS lives in ~/.config/nvim/assets.
      -- Pin the preview to light so it never follows macOS dark appearance.
      vim.g.mkdp_theme = "light"
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/assets/markdown.css")
      vim.g.mkdp_highlight_css = vim.fn.expand("~/.config/nvim/assets/highlight.css")
      vim.g.mkdp_page_title = "  ${name}"
      -- keep the browser preview in sync without needing focus
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_combine_preview_auto_refresh = 1
    end,
    -- The plugin exposes no JS hook, so inject our per-heading "copy section"
    -- script (assets/mkdp-copy.js) inline into the served index.html. Runs on
    -- every load, so a plugin rebuild that regenerates index.html can't kill it.
    config = function()
      local html_path = vim.fn.expand(
        "~/.local/share/nvim/lazy/markdown-preview.nvim/app/out/index.html"
      )
      local js_path = vim.fn.expand("~/.config/nvim/assets/mkdp-copy.js")
      if vim.fn.filereadable(html_path) == 0 or vim.fn.filereadable(js_path) == 0 then
        return
      end

      local html = table.concat(vim.fn.readfile(html_path), "\n")
      local js = table.concat(vim.fn.readfile(js_path), "\n")
      local START, STOP = "<!--mkdp-copy-->", "<!--/mkdp-copy-->"

      -- strip any previously injected block (plain find; no pattern magic)
      local s = html:find(START, 1, true)
      if s then
        local e = html:find(STOP, s, true)
        if e then
          html = html:sub(1, s - 1) .. html:sub(e + #STOP)
        end
      end

      local body = html:find("</body>", 1, true)
      if not body then
        return
      end
      local block = START .. "\n<script>\n" .. js .. "\n</script>\n" .. STOP
      local out = html:sub(1, body - 1) .. block .. html:sub(body)

      -- only rewrite when something actually changed
      if out ~= table.concat(vim.fn.readfile(html_path), "\n") then
        vim.fn.writefile(vim.split(out, "\n", { plain = true }), html_path)
      end
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle", ft = "markdown" },
      { "<leader>ms", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview Start", ft = "markdown" },
      { "<leader>me", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop", ft = "markdown" },
    },
  }
}
