return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        -- Snippets
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
    },
    config = function()
        -- This function will be attached to each language server
        local on_attach = function(client, bufnr)
            -- Keymaps for LSP features
            local opts = { buffer = bufnr, noremap = true, silent = true }
            vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
            vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
            vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
            vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
            vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
            vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
            vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
            vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
            vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
            vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

            -- Auto-format on save for specific filetypes
            local autoformat_filetypes = { "lua", "go", "python" }
            if vim.tbl_contains(autoformat_filetypes, vim.bo[bufnr].filetype) then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end
                })
            end
        end

        -- Add borders to floating windows (hover, signature help)
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help,
            { border = 'rounded' })

        -- Configure diagnostic signs
        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = {
                style = 'minimal',
                border = 'rounded',
                header = '',
                prefix = '',
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '', -- Using different icons for clarity
                    [vim.diagnostic.severity.WARN] = '',
                    [vim.diagnostic.severity.HINT] = '',
                    [vim.diagnostic.severity.INFO] = '',
                },
            },
        })

        -- Setup nvim-cmp.
        local cmp = require('cmp')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- Setup Mason
        require('mason').setup({})

        -- Setup Mason-LSPConfig
        require('mason-lspconfig').setup({
            -- Ensure these servers are installed
            ensure_installed = {
                "lua_ls",
                "gopls",        -- FIX: Added Go language server
                "tsserver",     -- FIX: Corrected name for TypeScript
                "intelephense", -- For PHP
                "eslint",       -- For JavaScript/TypeScript linting
            },
            handlers = {
                -- This is the default handler that applies to all servers
                -- without a specific handler below.
                function(server_name)
                    require('lspconfig')[server_name].setup({
                        on_attach = on_attach,       -- Pass your keymaps and other on_attach logic
                        capabilities = capabilities, -- Pass completion capabilities
                    })
                end,

                -- Custom handler for lua_ls to add settings for Neovim development
                lua_ls = function()
                    require('lspconfig').lua_ls.setup({
                        on_attach = on_attach,
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = 'LuaJIT' },
                                diagnostics = {
                                    -- This is the fix for the "Undefined global `vim`" error
                                    globals = { 'vim' },
                                },
                                workspace = {
                                    library = { vim.env.VIMRUNTIME },
                                },
                            },
                        },
                    })
                end,
            },
        })

        -- Setup nvim-cmp autocompletion
        require('luasnip.loaders.from_vscode').lazy_load()
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'path' },
            }),
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif require('luasnip').expand_or_jumpable() then
                        require('luasnip').expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif require('luasnip').jumpable(-1) then
                        require('luasnip').jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
        })
    end
}
