return {
    "hrs7th/cmp-nvim-lsp",
    dependencies = { 'nvim-telescope/telescope.nvim' },
    init = function ()
        -- Keyboard Shortcuts
        ------------------------------------------------------------------------------------ keyboard shortcut configs
        vim.api.nvim_create_autocmd('LspAttach', {
            desc = "LSP Actions",
            callback = function (event)
                local tsc = require('telescope.builtin')
                local map = function (keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: '..desc})
                end

                map('gd', tsc.lsp_definitions, '[G]oto [D]efinition')
                map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                map('<leader>ds', tsc.lsp_document_symbols, '[D]ocument [S]ymbols')
                map('<leader>rn', vim.lsp.buf.rename, '[R]ename')
                map('K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'Hover Documentation')

            end
        });

        -- Activate LSPs
        local abilities = require('cmp_nvim_lsp').default_capabilities()
        local lsp = require('lspconfig')
        local base = { capabilities = abilities }
        ------------------------------------------------------------------------------------ oneline configs
        local to_setup = {
            "clangd",
            "yamlls",
            "cmake",
            "ts_ls",
            "tailwindcss",
            "marksman",
        }

        for _, value in ipairs(to_setup) do
            lsp[value].setup{base}
        end
        -- lsp.clangd.setup{base}      -- C/C++
        -- lsp.yamlls.setup{base}      -- YAML
        -- lsp.cmake.setup{base}       -- CMake
        -- lsp.tsserver.setup{base}    -- TypeScript
        -- lsp.tailwindcss.setup{base} -- Tailwind
        -- lsp.marksman.setup{base}    -- Marksman
        ------------------------------------------------------------------------------------ lua_ls
        lsp.lua_ls.setup{
            base,
            on_init = function (client)
                local path = client.workspace_folders[1].name
                if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
                    return
                end

                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    runtime = { version = 'LuaJIT' },
                    workspace = {
                        checkThirdParty = false,
                        -- Make the server aware of Neovim runtime files
                        library = {
                            vim.env.VIMRUNTIME,
                            -- Depending on the usage, you might want to add additional paths here.
                            "${3rd}/luv/library"
                            -- "${3rd}/busted/library",
                    },
                    diagnostics = { globals = {'vim'} }
                    -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                    -- library = vim.api.nvim_get_runtime_file("", true)
                }
            })
            end,
            settings = { Lua = {} }
        }


    end

}
