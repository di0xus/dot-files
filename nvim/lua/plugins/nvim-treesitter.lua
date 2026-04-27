return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
      require('nvim-treesitter').setup({
	  highlight = { enable = true },
	  indent = { enable = true },
      })
      require('nvim-treesitter').install { 'rust', 'python', 'lua', 'markdown', 'nix' }
  end
}
