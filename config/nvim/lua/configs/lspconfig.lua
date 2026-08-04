require("nvchad.configs.lspconfig").defaults()

local servers = {
      -- html = {},
      -- cssls = {},
      clangd = {},
      marksman = {}, -- markdown lsp
      bashls = {},
      -- start nixd config
      nixd = {
        settings = {
          nixd = {
            nixpkgs = { expr = "import <nixpkgs> { }", },
            formatting = { command = { "nixfmt" }, },
            options = {
              nix_darwin = {
                expr = '(builtins.getFlake (toString ./.)).darwinConfigurations.Luna.options',
              },
              home_manager = {
                expr = '(builtins.getFlake (toString ./.)).darwinConfigurations.Luna.options.home-manager.users.type.getSubOptions []',
              },
            },
          },
        },
      },
      -- end nixd config
      rust_analyzer = {},
      basedpyright = {},
}

-- read :h vim.lsp.config for changing options of lsp servers 

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
