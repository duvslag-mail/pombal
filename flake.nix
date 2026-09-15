{
	outputs = { ... }: {
		nixosModules.default = import ./pombal.nix;
	};
}
