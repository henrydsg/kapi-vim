local fn = vim.fn

-- Install vim-plug if not found
local data_dir
if fn.has('nvim') then
    data_dir = fn.stdpath('data') .. '/site'
else
	data_dir = '~/.vim'
end

if fn.empty(fn.glob(data_dir .. '/autoload/plug.vim')) > 0 then
	print('Installing Vim Plug...')
	os.execute(
		'!curl -fLo'
			.. data_dir
			.. '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	)
else
	print('Vim Plug is installed.')
end

-- Run PlugInstall if there are missing plugins
vim.cmd([[
    augroup vim_plug_config
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | PlugUpdate
        autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) 
            \| PlugUpdate | source $MYVIMRC 
        \| endif
    augroup end
]])

local Plug = fn['plug#']
vim.call('plug#begin')

--Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  ' We recommend updating the parsers on update
Plug("nvim-lua/plenary.nvim") -- Useful lua functions used ny lots of plugins

--auto completion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/vim-vsnip')
Plug('hrsh7th/cmp-nvim-lsp')

-- LSP
Plug('neovim/nvim-lspconfig')
Plug('williamboman/nvim-lsp-installer')
Plug('jose-elias-alvarez/null-ls.nvim')

--Language specific
Plug('rust-lang/rust.vim')
--Plug 'simrat39/rust-tools.nvim'
Plug('Julian/lean.nvim')
Plug('neovimhaskell/haskell-vim')
Plug('iamcco/markdown-preview.nvim', { ['do'] = fn['cd app && yarn install'] })

--ui
Plug('vim-airline/vim-airline')
Plug('vim-airline/vim-airline-themes')
Plug('cocopon/iceberg.vim')

Plug('preservim/nerdcommenter')

Plug('junegunn/fzf', { ['do'] = fn['fzf#install'] })
Plug('junegunn/fzf.vim')

vim.call('plug#end')