{ config, lib, ... }: let
	cfg = config.services.pombal;
	sslCertDir = config.security.acme.certs.${cfg.useACMEHost}.directory;
in {
	options.services.pombal = {
		enable = lib.mkEnableOption "Pombal mail server";

		hostname = lib.mkOption {
			type = lib.types.str;
		};

		useACMEHost = lib.mkOption {
			type = lib.types.nullOr lib.types.str;
			default = null;
		};
	};

	config = lib.mkIf cfg.enable {
		systemd.tmpfiles.rules = [ "d /var/spool/postfix/private 0700 postfix postfix -" ];
		security.acme.certs.${cfg.useACMEHost}.reloadServices = [ "postfix" "dovecot" ];

		networking.firewall.allowedTCPPorts = [
			# SMTP
			25
			# SMTP with opportunistic TLS (STARTTLS)
			587
			# SMTPS
			465
			# IMAPS
			993
		];

		services = {
			postfix = {
				enable = true;
				enableSubmission = true;
				enableSubmissions = true;

				settings.main = {
					myorigin = "$mydomain";
					myhostname = cfg.hostname;
					virtual_transport = "lmtp:unix:private/dovecot-lmtp";

					smtpd_tls_cert_file = "${sslCertDir}/fullchain.pem";
					smtpd_tls_key_file = "${sslCertDir}/key.pem";
					smtpd_tls_security_level = "may";

					smtpd_sasl_type = "dovecot";
					smtpd_sasl_path = "private/auth";
					smtpd_sasl_auth_enable = true;
				};
			};

			dovecot2 = {
				enable = true;

				settings = {
					# https://doc.dovecot.org/2.4.5/core/config/quick.html
					dovecot_config_version = "2.4.5";
					dovecot_storage_version = "2.4.5";

					protocols = {
						imap = true;
						lmtp = true;
					};

					mail_home = "/var/mail/%{user}";
					mail_driver = "sdbox";
					mail_path = "~/mail";

					mail_uid = "vmail";
					mail_gid = "vmail";

					"namespace inbox" = {
						inbox = true;
						separator = "/";
					};

					"passdb passwd-file" = {
						passwd_file_path = "/etc/dovecot/passwd";
					};

					ssl_server_cert_file = "${sslCertDir}/fullchain.pem";
					ssl_server_key_file = "${sslCertDir}/key.pem";

					# https://doc.dovecot.org/2.4.5/howto/lmtp/postfix.html
					"service lmtp"."unix_listener /var/spool/postfix/private/dovecot-lmtp" = {
						user = "postfix";
						mode = 0600;
						group = "postfix";
					};

					# https://doc.dovecot.org/2.4.5/howto/sasl/postfix.html
					"service auth" = {
						"unix_listener /var/spool/postfix/private/auth" = {
							mode = 0660;
							user = "postfix";
							group = "postfix";
						};
					};

					auth_mechanisms = ["plain" "login" ];
				};
			};
		};
	};
}
