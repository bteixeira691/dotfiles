return {
  -- C# / Razor language server.
  -- roslyn.nvim passes --daemon-mode to the server (>= 5.12), so every Neovim
  -- instance shares one Roslyn process instead of starting its own.
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {
      broad_search = false,
      -- Keep the target per instance (one nvim per repo); change with :Roslyn target
      lock_target = false,
      ---Pick a target deterministically when a repo has several solutions.
      ---A manual `:Roslyn target` wins from then on.
      choose_target = function(targets)
        if #targets == 0 then
          return nil
        end

        local selected = vim.g.roslyn_nvim_selected_solution
        if selected and vim.tbl_contains(targets, selected) then
          return selected
        end

        -- Prefer a solution named like the repo, the cwd, or the file's project.
        local names = {}
        local cwd = vim.uv.cwd()
        local git = vim.fs.root(cwd, { ".git" })
        if git then
          names[#names + 1] = vim.fs.basename(git)
        end
        names[#names + 1] = vim.fs.basename(cwd)
        local buf = vim.api.nvim_buf_get_name(0)
        if buf ~= "" then
          names[#names + 1] = vim.fs.basename(vim.fs.dirname(buf))
        end

        for _, name in ipairs(names) do
          for _, target in ipairs(targets) do
            local base = vim.fs.basename(target):gsub("%.slnx?$", "")
            if base:lower() == name:lower() then
              return target
            end
          end
        end

        -- Otherwise let the user pick once; the selection is remembered above.
        return nil
      end,
    },
    init = function()
      vim.lsp.config("roslyn", {
        -- roslyn.nvim calls on_dir(nil) when it sees a buffer before the file
        -- name is set, which starts a second, rootless client next to the real
        -- one. Only activate once a solution/project root was resolved.
        root_dir = function(bufnr, on_dir)
          local target = require("roslyn.target")
          local decision = target.resolve(bufnr)
          target.notify_if_needed(decision)
          target.remember(decision)
          if decision and decision.root_dir then
            on_dir(decision.root_dir)
          end
        end,
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
          },
          -- Big solutions: analyze open files instead of the whole solution.
          -- Switch to "fullSolution" if you want solution-wide diagnostics.
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ["csharp|formatting"] = {
            dotnet_organize_imports_on_format = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = true,
          },
        },
      })
    end,
  },

  {
    "leblocks/hopcsharp.nvim",
    ft = { "cs" },
    config = function()
      pcall(require, "hopcsharp")
    end,
  },

  -- Build / run / debug / test / EF / secrets.
  -- LSP is intentionally disabled here: roslyn.nvim owns it so that daemon
  -- mode keeps a single server for all Neovim instances.
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp" },
    cmd = { "Dotnet" },
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap", "folke/snacks.nvim" },
    config = function(_, opts)
      require("easy-dotnet").setup(opts)
    end,
    opts = {
      lsp = { enabled = false },
      projx_lsp = { enabled = true },
      debugger = {
        -- Registers the "easy-dotnet" adapter. Every run uses
        -- dap.run(..., { new = true }), so sessions can run in parallel.
        auto_register_dap = true,
        engine = "netcoredbg",
        console = "integratedTerminal",
        apply_value_converters = true,
        mem_cpu_usage = true,
        mappings = {
          open_variable_viewer = { lhs = "T", desc = "Open variable viewer" },
        },
      },
      test_runner = {
        -- neotest owns signs/keymaps (see lua/plugins/test.lua)
        neotest_integration = true,
        auto_start_testrunner = true,
        viewmode = "float",
      },
      diagnostics = {
        default_severity = "warning",
        setqflist = false,
      },
      managed_terminal = {
        auto_hide = true,
        auto_hide_delay = 5000,
      },
      picker = "snacks",
    },
  },
}
