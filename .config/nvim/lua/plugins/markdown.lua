return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle", ft = "markdown" },
      { "<leader>ms", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview Start", ft = "markdown" },
      { "<leader>me", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop", ft = "markdown" },
    },
  }
}
