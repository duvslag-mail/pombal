{ config, ... }: let
	hostname = "mail.pombal.ayoreis.com";
in {
	# https://doc.dovecot.org/2.4.5/core/config/quick.html#virtual-users
	environment.etc."dovecot/passwd".source = ./dovecot-passwd;

	security.acme = {
		acceptTerms = true;

		defaults = {
			email = "admin@example.com";
			webroot = "/var/lib/acme/acme-challenge";
		};

		certs.${hostname}.group = "caddy";
	};

	services = {
		caddy.virtualHosts.${hostname}.extraConfig = ''
			root ${config.security.acme.defaults.webroot}
			file_server
		'';

		pombal = {
			enable = true;
			inherit hostname;
			useACMEHost = hostname;
		};
	};
}
