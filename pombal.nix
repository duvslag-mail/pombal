{ config, lib, ... }: let
	cfg = config.services.pombal;
in {
	options.services.pombal = {
		enable = lib.mkEnableOption "Pombal mail server";

		fqdn = lib.mkOption {
			type = lib.types.str;
		};
	};

	config = lib.mkIf cfg.enable {
		networking.firewall.allowedTCPPorts = [
			# SMTP
			25
			# SMTP with opportunistic TLS (STARTTLS)
			587
			# SMTPS
			465
		];

		services = {
			postfix = {
				enable = true;
				enableSubmission = true;
				enableSubmissions = true;

				settings.main = {
					myorigin = "$mydomain";
					myhostname = cfg.fqdn;
				};
			};

			dovecot2.enable = true;
		};
	};
}
