local keymap = vim.keymap.set

local function keymap_setup(bufnr)
    local opts = { noremap = true, silent = true }

    keymap("n", "[d", function()
        vim.diagnostic.goto_prev({ border = "rounded" })
    end, opts)
    keymap("n", "]d", function()
        vim.diagnostic.goto_next({ border = "rounded" })
    end, opts)
    keymap("n", "<Leader>e", vim.diagnostic.open_float, opts)
    keymap("n", "<Leader>q", vim.diagnostic.setloclist, opts)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    keymap("n", "gd", vim.lsp.buf.declaration, bufopts)
    keymap("n", "gD", vim.lsp.buf.definition, bufopts)
    keymap("n", "gi", vim.lsp.buf.implementation, bufopts)
    keymap("n", "gr", vim.lsp.buf.references, bufopts)
    keymap("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    keymap("n", "<Leader>k", vim.lsp.buf.hover, bufopts)
    keymap("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    keymap("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    keymap("n", "<Leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    keymap("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts)
    keymap("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
    keymap("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
    keymap("n", "<Leader>f", function()
        vim.lsp.buf.format({ bufnr = bufnr })
    end, bufopts)
end

local function highlighter_setup(client)
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec(
            [[
                augroup lsp_document_highlight
                    autocmd! * <buffer>
                    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                augroup END
        ]],
            false
        )
    end
end

local function format_setup(client, bufnr)
    local enable = true
    client.server_capabilities.documentFormattingProvider = enable
    client.server_capabilities.documentRangeFormattingProvider = enable

    if client.server_capabilities.documentFormattingProvider then
        local lsp_format_grp = vim.api.nvim_create_augroup("LspFormat", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
            group = lsp_format_grp,
            buffer = bufnr,
        })
    end
end

local opts = {
    on_attach = function(client, bufnr)
        -- Enable completion triggered by <C-X><C-O>
        -- See `:help omnifunc` and `:help ins-completion` for more information.
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Use LSP as the handler for formatexpr.
        -- See `:help formatexpr` for more information.
        vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")

        -- Configure key mappings
        keymap_setup(bufnr)

        -- Configure highlighting
        highlighter_setup(client)

        -- Configure formatting
        format_setup(client, bufnr)
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
    flags = {
        debounce_text_changes = 150,
    },
}

-- Setup LSP config
require("lsp.handler").setup()

local servers = {
    "lua_ls",
    "bashls",
    "rust_analyzer",
    "gopls",
    "hls",
    "pylsp",
    "taplo",
    "yamlls",
    "jsonls",
    "dockerls",
    "nixd",
}

local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    vim.notify("lspconfig is not loaded", vim.log.Error)
    return
end

for _, server in ipairs(servers) do
    local require_ok, conf_opts = pcall(require, "lsp.settings." .. server)
    if require_ok then
        opts = vim.tbl_deep_extend("force", conf_opts, opts)
    end
    lspconfig[server].setup(opts)
end

require("lsp.none-ls").setup(opts)
