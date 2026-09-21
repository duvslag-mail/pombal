# Pombal

A NixOS module that configures Postfix and Dovecot for a mail server.

## Setup

You'll need some DNS records:

- PTR: `mail.example.com.`
- SPF: `"v=spf1 a:mail.example.com -all"`

Add the module to your NixOS configuration and configure the service:

```nix
# flake.nix
inputs.pombal.url = "github:duvslag-mail/pombal";
...
pombal.nixosModules.default

# configuration.nix
services.pombal = {
	enable = true;
	hostname = "mail.example.com";
	# Issue this first
	useACMEHost = "mail.example.com";
};
```

You'll also need to fill out "/etc/dovecot/passwd" [like this](https://doc.dovecot.org/2.4.5/core/config/quick.html#virtual-users).

## Conventions

- Use capitalized [imperative mood](https://en.wikipedia.org/wiki/Imperative_mood) for commit messages

---

- [Postfix documentation](https://www.postfix.org/documentation.html)
- [Dovecot documentation](https://doc.dovecot.org/2.4.5/)
