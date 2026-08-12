# NixOS host targets. Included by the root Makefile.
.PHONY: ramiel ramiel-build ramiel-test nixbox nixbox-build nixbox-test nixos nixos-build nixos-test

ramiel: ## NixOS ramiel: activate system + home in one shot (nixos-rebuild, needs sudo)
	sudo nixos-rebuild switch --flake $(FLAKE)#ramiel

ramiel-build: ## Build ramiel system into ./result without activating
	nixos-rebuild build --flake $(FLAKE)#ramiel

ramiel-test: ## Activate ramiel now but DON'T make it the boot default (reverts on reboot)
	sudo nixos-rebuild test --flake $(FLAKE)#ramiel

nixbox: ## NixOS nixbox: activate system + home in one shot (nixos-rebuild, needs sudo)
	sudo nixos-rebuild switch --flake $(FLAKE)#nixbox

nixbox-build: ## Build nixbox system into ./result without activating
	nixos-rebuild build --flake $(FLAKE)#nixbox

nixbox-test: ## Activate nixbox now but DON'T make it the boot default (reverts on reboot)
	sudo nixos-rebuild test --flake $(FLAKE)#nixbox

nixos: ## NixOS nixos (X220): activate system + home in one shot (nixos-rebuild, needs sudo)
	sudo nixos-rebuild switch --flake $(FLAKE)#nixos

nixos-build: ## Build nixos system into ./result without activating
	nixos-rebuild build --flake $(FLAKE)#nixos

nixos-test: ## Activate nixos now but DON'T make it the boot default (reverts on reboot)
	sudo nixos-rebuild test --flake $(FLAKE)#nixos
