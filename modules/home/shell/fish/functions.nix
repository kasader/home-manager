# fish functions; imported by ./default.nix.
{
  # Run the nix-declarative Makefile from any directory: `mknix fmt`, `mknix gc`,
  # `mknix israfel`, `mknix switch`, ... NIX_FLAKE is set above. Named `mknix`
  # (not `mk`) because `mk` is already a program on PATH.
  mknix = # fish
    ''
      make -C $NIX_FLAKE $argv
    '';

  y = # fish
    ''
      set tmp (mktemp -t "yazi-cwd.XXXXXX")
      yazi $argv --cwd-file="$tmp"
      if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "cwd" != "$pwd" ]
      	builtin cd -- "$cwd"
      end
      rm -f -- "$tmp"
    '';

  # Scaffold a Nix devShell + direnv into the current directory from
  # the-nix-way/dev-templates. Bare `devinit` uses the minimal `empty`
  # template; pass a language for a batteries-included one. Refs are unpinned
  # (they pull the repo's current template); the flake.lock each template
  # copies in still pins the scaffolded project's own dependencies. `lua` is
  # the exception — it's served from this flake's own templates.lua output.
  devinit = # fish
    ''
      set -l repo github:the-nix-way/dev-templates
      set -l template empty
      switch "$argv[1]"
        case ""
        case python python3
          set template python
        case go golang
          set template go
        case rust
          set template rust
        case c cpp c++ c-cpp
          set template c-cpp
        case lua
          # Not in the-nix-way; served from this flake's own templates output.
          set repo "$NIX_FLAKE"
          set template lua
        case '*'
          echo "devinit: unknown target '$argv[1]' (try: python, go, rust, c, lua, or no arg)" >&2
          return 1
      end

      nix flake init -t "$repo#$template"; or return 1

      # direnv's `use flake` cache; the templates handle their own .gitignore.
      if not test -e .gitignore; or not grep -qxF '.direnv/' .gitignore
        echo '.direnv/' >> .gitignore
        echo "devinit: added .direnv/ to .gitignore"
      end

      if type -q direnv
        direnv allow
      end
    '';
}
