return {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- optional, for icons
        'MunifTanjim/nui.nvim',
    },
    config = function()
        -- Set the leader key to the spacebar (ensure this is set only once in your config)
        vim.g.mapleader = ' '

        vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

        -- Smart toggle keymap: opens, reveals, and closes neo-tree
        vim.keymap.set('n', '<leader>e', function()
            if vim.fn.bufwinid('neo-tree') ~= -1 then
                vim.cmd('Neotree close')
            else
                vim.cmd('Neotree reveal')
            end
        end, { desc = 'Toggle/Reveal Neo-tree' })

        -- Basic setup
        require('neo-tree').setup({
            close_if_last_window = true,
            popup_border_style = 'rounded',
            filesystem = {
                follow_current_file = {
                    enabled = true,
                },
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = true,
                    hide_hidden = true,
                },
            },
            window = {
                -- Set a consistent position
                position = 'right',
                mappings = {
                    -- Use 'gr' for a non-conflicting refresh keymap
                    ['gr'] = 'reveal_refresh',
                    -- Note: 'r' for rename and other defaults still work
                },
            },
        })
    end,
}
