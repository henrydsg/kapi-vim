{
  description = "kapi-vim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, ... }:
        let
          nvimConfig = pkgs.stdenv.mkDerivation {
            name = "nvim-config";
            src = ./.;
            buildPhase = ''
              mkdir -p $out
              cp -r * $out
            '';
          };
        in
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;

          packages.default = with pkgs; symlinkJoin {
            name = "nvim";
            paths = [
              (pkgs.wrapNeovim
                pkgs.neovim-unwrapped
                {
                  viAlias = true;
                  vimAlias = true;
                  configure = {
                    customRC = ''
                      lua << EOF
                        vim.opt.rtp:append('${nvimConfig}')
                    ''
                    + builtins.readFile ./init.lua
                    + ''
                      EOF
                    '';
                    packages.kapi-vim = with pkgs.vimPlugins; {
                      start = [
                        nvim-lspconfig
                        none-ls-nvim
                        nvim-cmp
                        cmp-nvim-lsp
                        luasnip
                        nvim-treesitter.withAllGrammars
                        telescope-nvim
                        mini-nvim
                        dracula-vim
                        markdown-preview-nvim
                        vim-startuptime
                      ];
                      opt = [ ];
                    };
                  };
                })

              # runtime deps
              ripgrep
            ];
          };

          packages.lsp = with pkgs; buildEnv {
            name = "LSP";
            paths = [
              tokei

              # nix
              nixpkgs-fmt
              nixd

              # vim
              nodePackages.vim-language-server
              # lua
              lua
              lua-language-server
              stylua

              # shell
              nodePackages.bash-language-server
              shfmt
              shellcheck

              # toml, yaml
              taplo
              yaml-language-server
              codespell

              # rust
              rustup

              # go
              go
              gopls
              golangci-lint
              gotools
              govulncheck

              # haskell
              ghc
              haskell-language-server

              # C
              llvmPackages.clang
              clang-tools

              # python
              python3
              python311Packages.python-lsp-server

              # git commit
              commitlint
            ];
          };

          devShells.default = with pkgs; mkShellNoCC {
            packages = [
              tokei

              direnv
              nix-direnv

              nixpkgs-fmt
              nixd
              deadnix

              nodePackages.vim-language-server
              lua
              lua-language-server
              stylua

              taplo
              codespell
              commitlint
            ];

            shellHook = ''
              export PATH=$PWD/bin:$PATH
            '';
          };
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
