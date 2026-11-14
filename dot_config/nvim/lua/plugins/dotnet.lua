return {
  -- C# / Razor language server.
  -- roslyn.nvim passes --daemon-mode to the server (>= 5.12), so every Neovim
  -- instance shares one Roslyn process instead of starting its own.
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {
      -- Search the whole repo for .sln/.slnx, not only the buffer's ancestors.
      -- `false` makes any buffer outside the solution directory resolve to its
      -- own .csproj, i.e. a single-project Roslyn workspace: references and
      -- usages from sibling projects are then invisible ("No results found").
      broad_search = true,
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
      ---Solution in the buffer's repo that contains the buffer's project.
      ---`broad_search` only takes effect once the plugin's opts are applied,
      ---which can be after the first client start (`nvim some/file.cs`); that
      ---window otherwise leaves the buffer in a single-project workspace where
      ---cross-project references do not exist.
      ---@param bufnr number
      ---@return string?
      local function repo_solution(bufnr)
        local discovery = require("roslyn.sln.discovery")
        local api = require("roslyn.sln.api")
        local csproj = discovery.find_project(bufnr)
        local root = vim.fs.root(bufnr, ".git")
        if not csproj or not root then
          return nil
        end

        local skip = function(name)
          local base = vim.fs.basename(name)
          return base ~= "obj" and base ~= "bin" and base ~= ".git" and base ~= "node_modules"
        end
        local matches = {}
        for path, kind in vim.fs.dir(root, { depth = 8, skip = skip }) do
          local is_solution = kind == "file" and (path:match("%.slnx?$") ~= nil or path:match("%.slnf$") ~= nil)
          if is_solution then
            local solution = vim.fs.joinpath(root, path)
            if api.exists_in_target(solution, csproj) then
              matches[#matches + 1] = solution
            end
          end
        end

        if #matches == 1 then
          return matches[1]
        end
        local choose_target = require("roslyn.config").get().choose_target
        return choose_target and choose_target(matches) or nil
      end

      vim.lsp.config("roslyn", {
        -- roslyn.nvim calls on_dir(nil) when it sees a buffer before the file
        -- name is set, which starts a second, rootless client next to the real
        -- one. Only activate once a solution/project root was resolved.
        root_dir = function(bufnr, on_dir)
          local target = require("roslyn.target")
          local decision = target.resolve(bufnr)
          if decision and decision.kind ~= "solution" then
            local solution = repo_solution(bufnr)
            if solution then
              decision = { kind = "solution", root_dir = target.target_root_dir(solution), target = solution }
            end
          end
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
            -- Reference lenses force a solution-wide reference search for every
            -- visible file. Test lenses are cheap and useful, so keep those.
            dotnet_enable_references_code_lens = false,
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

  -- Roslyn answers `textDocument/references` with an empty list until it has
  -- finished loading the solution (several seconds, even with the daemon warm).
  -- Snacks closes `lsp_references` the moment a finder yields nothing, which is
  -- why `gr` on a freshly opened repo reported "No results found" for symbols
  -- that do have usages. Keep asking while the client is still loading.
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      local source = require("snacks.picker.source.lsp")
      local async = require("snacks.picker.util.async")
      local uv = vim.uv or vim.loop

      ---@type table<number, integer> client id -> attach time (ms)
      local attached = {}
      ---@type table<number, boolean> client id -> solution loaded
      local ready = {}

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("roslyn_refs", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "roslyn" then
            return
          end
          attached[client.id] = uv.now()
          -- Roslyn's "the solution is loaded" notification; bound the wait by
          -- WAIT_MS in case a future server version stops sending it.
          client.handlers["workspace/projectInitializationComplete"] = function()
            ready[client.id] = true
          end
        end,
      })

      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.lsp_references = {
        finder = function(o, ctx)
          local find = source.references(o, ctx)
          local bufnr = ctx.filter.current_buf
          return function(cb)
            ---@return table[], vim.lsp.Client?
            local function collect()
              local items = {}
              find(function(item)
                items[#items + 1] = item
              end)
              return items, vim.lsp.get_clients({ name = "roslyn", bufnr = bufnr })[1]
            end

            -- While the solution is still loading the server answers with an
            -- empty or partial list, so results only mean something once
            -- `projectInitializationComplete` arrived (or the bound expires).
            local waited = false
            local items, client = collect()
            while client and attached[client.id] and not ready[client.id] and uv.now() - attached[client.id] < 30000 do
              waited = true
              async.sleep(250)
              items, client = collect()
            end
            if waited and client and not client:is_stopped() then
              items = collect()
            end
            for _, item in ipairs(items) do
              cb(item)
            end
          end
        end,
      }
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
        -- quick_discover runs `dotnet test --list-tests` on every C# buffer,
        -- which is the main reason opening a file in a large solution stalls.
        -- Open the runner with <leader>kt when you actually need it.
        auto_start_testrunner = false,
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
