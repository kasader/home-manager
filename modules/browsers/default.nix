{ ... }:

{
  # Aggregator for per-browser modules. Each browser defines its own
  # `custom.browsers.<name>.enable` toggle and is off by default, so hosts
  # opt in to exactly the browsers they want.
  imports = [
    ./firefox
    ./librewolf
  ];
}
