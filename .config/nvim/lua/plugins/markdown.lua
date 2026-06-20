return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      -- Custom "Modern / Refined" light theme. CSS lives in ~/.config/nvim/assets.
      vim.g.mkdp_theme = "light"
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/assets/markdown.css")
      vim.g.mkdp_highlight_css = vim.fn.expand("~/.config/nvim/assets/highlight.css")
      vim.g.mkdp_page_title = "  ${name}"
      -- keep the browser preview in sync without needing focus
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_combine_preview_auto_refresh = 1
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle", ft = "markdown" },
      { "<leader>ms", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview Start", ft = "markdown" },
      { "<leader>me", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop", ft = "markdown" },
    },
  }
}
