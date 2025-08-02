return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = {
                    "lua",
                    "typescript",
                    "go",
                    "tsx",
                    "vim",
                },
                auto_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
        'windwp/nvim-ts-autotag',
    },
}
