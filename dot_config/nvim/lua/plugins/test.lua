return {
  {
    -- neotest is configured by LazyVim's test.core extra.
    -- easy-dotnet ships the adapter: discovery is shared with its own test
    -- runner and it supports VSTest + Microsoft.Testing.Platform, which covers
    -- xUnit v2/v3 and NUnit across services.
    "nvim-neotest/neotest",
    dependencies = { "GustavEikaas/easy-dotnet.nvim" },
    opts = {
      adapters = {
        -- LazyVim's dotnet extra adds neotest-vstest; running two adapters
        -- would discover and run every test twice.
        ["neotest-vstest"] = false,
        ["easy-dotnet.neotest"] = {},
      },
    },
  },
}
