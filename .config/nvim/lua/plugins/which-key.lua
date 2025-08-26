return {
  "folke/which-key.nvim",
  optional = true,
  opts = function(_, opts)
    opts.spec = opts.spec or {}
    
    -- Add markdown-specific keybindings using buffer-local setup
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(event)
        local wk = require("which-key")
        wk.add({
          { "<leader>m", group = "markdown", buffer = event.buf },
          { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Preview Toggle", buffer = event.buf },
          { "<leader>ms", "<cmd>MarkdownPreview<cr>", desc = "Preview Start", buffer = event.buf },
          { "<leader>me", "<cmd>MarkdownPreviewStop<cr>", desc = "Preview Stop", buffer = event.buf },
        })
      end,
    })
  end,
}