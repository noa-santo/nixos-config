vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.cursorline = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }

local undodir = vim.fn.stdpath("state") .. "/undo"

if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.undodir = undodir
vim.opt.undofile = true

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
})

local ok, lualine = pcall(require, "lualine")

if ok then
	lualine.setup({
		options = {
			theme = "auto",
			globalstatus = true,
			section_separators = "",
			component_separators = "",
		},
	})
end

local ok_treesitter, treesitter = pcall(require, "nvim-treesitter")

if ok_treesitter then
	treesitter.setup()

	vim.api.nvim_create_autocmd("FileType", {
		pattern = {
			"bash",
			"c",
			"cpp",
			"css",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"nix",
			"python",
			"query",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		},
		callback = function(args)
			pcall(vim.treesitter.start, args.buf)
		end,
	})

end

local ok_ibl, ibl = pcall(require, "ibl")

if ok_ibl then
	ibl.setup()
end

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")

if ok_gitsigns then
	gitsigns.setup()
end

local ok_autopairs, autopairs = pcall(require, "nvim-autopairs")

if ok_autopairs then
	autopairs.setup({})
end

local ok_comment, comment = pcall(require, "Comment")

if ok_comment then
	comment.setup()
end

local ok_which_key, which_key = pcall(require, "which-key")

if ok_which_key then
	which_key.setup()
end

local ok_tree, nvim_tree = pcall(require, "nvim-tree")

if ok_tree then
	nvim_tree.setup({
		filters = {
			dotfiles = false,
		},
		view = {
			width = 30,
		},
		renderer = {
			group_empty = true,
		},
	})
end

vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", {
	desc = "Toggle File Explorer",
})

local ok_telescope, telescope = pcall(require, "telescope")

if ok_telescope then
	telescope.setup({
		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown({}),
			},
		},
	})

	pcall(telescope.load_extension, "ui-select")

	local builtin = require("telescope.builtin")

	vim.keymap.set("n", "<leader>ff", builtin.find_files, {
		desc = "Find Files",
	})

	vim.keymap.set("n", "<leader>fg", builtin.live_grep, {
		desc = "Live Grep",
	})

	vim.keymap.set("n", "<leader>fb", builtin.buffers, {
		desc = "Find Buffers",
	})

	vim.keymap.set("n", "<leader>fh", builtin.help_tags, {
		desc = "Find Help",
	})

end

local ok_bufferline, bufferline = pcall(require, "bufferline")

if ok_bufferline then
	bufferline.setup({
		options = {
			mode = "buffers",
			diagnostics = "nvim_lsp",
			separator_style = "slant",
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					text_align = "left",
					separator = true,
				},
			},
		},
	})

	vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", {
		silent = true,
		desc = "Next Buffer",
	})

	vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", {
		silent = true,
		desc = "Previous Buffer",
	})

	vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>", {
		silent = true,
		desc = "Close Buffer",
	})

end

local ok_cmp, cmp = pcall(require, "cmp")
local ok_luasnip, luasnip = pcall(require, "luasnip")

if ok_cmp and ok_luasnip then
	require("luasnip.loaders.from_vscode").lazy_load()

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},

		mapping = cmp.mapping.preset.insert({
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-p>"] = cmp.mapping.select_prev_item(),
			["<C-d>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),

			["<CR>"] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			}),

			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),

			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
		}),

		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
		}, {
			{ name = "buffer" },
			{ name = "path" },
		}),
	})

	cmp.setup.cmdline("/", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' },
			{ name = 'buffer' },
			{ name = 'path' },
		},
	})

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
	})

end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if ok_cmp_lsp then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

vim.lsp.config("*", {
	capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
				},
			},
			workspace = {
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.config("pyright", {})

vim.lsp.config("nil_ls", {})

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"nil_ls",
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = {
			buffer = args.buf,
			silent = true,
		}

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
			buffer = args.buf,
			desc = "Go to Definition",
		})

		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {
			buffer = args.buf,
			desc = "Go to Declaration",
		})

		vim.keymap.set("n", "gr", vim.lsp.buf.references, {
			buffer = args.buf,
			desc = "Find References",
		})

		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {
			buffer = args.buf,
			desc = "Go to Implementation",
		})

		vim.keymap.set("n", "K", vim.lsp.buf.hover, {
			buffer = args.buf,
			desc = "Hover Documentation",
		})

		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
			buffer = args.buf,
			desc = "Rename Symbol",
		})

		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
			buffer = args.buf,
			desc = "Code Action",
		})

		vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
			buffer = args.buf,
			desc = "Line Diagnostics",
		})

		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({
				count = -1,
				float = true,
			})
		end, {
			buffer = args.buf,
			desc = "Previous Diagnostic",
		})

		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({
				count = 1,
				float = true,
			})
		end, {
			buffer = args.buf,
			desc = "Next Diagnostic",
		})
	end,

})

local ok_base16, base16 = pcall(require, "mini.base16")

if ok_base16 then
	base16.setup({
		palette = {
			base00 = "#1e1e2e",
			base01 = "#181825",
			base02 = "#313244",
			base03 = "#45475a",
			base04 = "#585b70",
			base05 = "#cdd6f4",
			base06 = "#f5f5f5",
			base07 = "#ffffff",
			base08 = "#f38ba8",
			base09 = "#fab387",
			base0A = "#f9e2af",
			base0B = "#a6e3a1",
			base0C = "#94e2d5",
			base0D = "#89b4fa",
			base0E = "#cba6f7",
			base0F = "#f5e0dc",
		},
	})
end

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", {
	desc = "Clear Search Highlight",
})

vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", {
	desc = "Save",
})

vim.keymap.set("n", "<leader>q", "<cmd>quit<CR>", {
	desc = "Quit",
})

vim.keymap.set("n", "<C-h>", "<C-w>h", {
	desc = "Move to Left Window",
})

vim.keymap.set("n", "<C-j>", "<C-w>j", {
	desc = "Move to Lower Window",
})

vim.keymap.set("n", "<C-k>", "<C-w>k", {
	desc = "Move to Upper Window",
})

vim.keymap.set("n", "<C-l>", "<C-w>l", {
	desc = "Move to Right Window",
})

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", {
	desc = "Move Selection Down",
})

vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", {
	desc = "Move Selection Up",
})

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')

		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
