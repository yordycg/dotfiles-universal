return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Move to left window/pane" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Move to bottom window/pane" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Move to top window/pane" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Move to right window/pane" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Move to previous window/pane" },
    },
  },
}
