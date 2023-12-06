require("copilot").setup {
  suggestion = { enabled = false },
  panel = { enabled = false },
  server_opts_overrides = {
    settings = {
      advanced = {
        debug = {
          overridePrxoyUrl = "https://copilot-proxy-sg1.dengqi.org",
        },
      },
    },
  },
}
