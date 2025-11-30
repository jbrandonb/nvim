return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Mason (install LSPs automatically)
    { "williamboman/mason.nvim", opts = {} },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- LSP progress UI
    { "j-hui/fidget.nvim", opts = {} },

    -- Completion capabilities
    "saghen/blink.cmp",

    -- Lazydev (Lua type definitions for Neovim config)
    "folke/lazydev.nvim",
  },

  config = function()
    -------------------------------------------------------
    -- LSP ON ATTACH
    -------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),

      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        -- LSP Keymaps (copied exactly from your init.lua)
        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
        map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("gO", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
        map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
        map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

        -------------------------------------------------------
        -- HIGHLIGHT REFERENCES
        -------------------------------------------------------
        local function client_supports_method(client, method, bufnr)
          if vim.fn.has("nvim-0.11") == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client_supports_method(
          client,
          vim.lsp.protocol.Methods.textDocument_documentHighlight,
          event.buf
        ) then

          local group = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })

          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = group,
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = group,
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds {
                group = "kickstart-lsp-highlight",
                buffer = event2.buf
              }
            end,
          })
        end

        -------------------------------------------------------
        -- INLAY HINTS
        -------------------------------------------------------
        if client and client_supports_method(
          client,
          vim.lsp.protocol.Methods.textDocument_inlayHint,
          event.buf
        ) then

          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
            )
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    -------------------------------------------------------
    -- DIAGNOSTICS
    -------------------------------------------------------
    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN]  = "󰀪 ",
          [vim.diagnostic.severity.INFO]  = "󰋽 ",
          [vim.diagnostic.severity.HINT]  = "󰌶 ",
        },
      } or {},
      virtual_text = {
        source = "if_many",
        spacing = 2,
        format = function(diag)
          return diag.message
        end,
      },
    })

    -------------------------------------------------------
    -- CAPABILITIES FROM blink.cmp
    -------------------------------------------------------
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -------------------------------------------------------
    -- LSP SERVERS
    -------------------------------------------------------
    local servers = {
      clangd = {},
      pyright = {},
      rust_analyzer = {},
      ts_ls = {},
      html = {
        filetypes = { "html", "handlebars" },
      },
      lua_ls = {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
          },
        },
      },
    }

    -------------------------------------------------------
    -- MASON INSTALLATION
    -------------------------------------------------------
    local ensure = vim.tbl_keys(servers)
    vim.list_extend(ensure, { "stylua" })

    require("mason-tool-installer").setup({ ensure_installed = ensure })

    -------------------------------------------------------
    -- MASON-LSPCONFIG SETUP
    -------------------------------------------------------
    require("mason-lspconfig").setup({
      ensure_installed = {},
      automatic_installation = false,

      handlers = {
        function(server_name)
          local opts = servers[server_name] or {}
          opts.capabilities =
            vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})

          require("lspconfig")[server_name].setup(opts)
        end,
      },
    })
  end,
}

