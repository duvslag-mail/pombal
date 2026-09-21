# Pombal

A NixOS module that configures Postfix and Dovecot for a mail server.

## Setup

You'll need some DNS records (these are examples, replace the IP address and domain with your own):

- A: `198.51.100.0`
- [PTR](https://www.cloudflare.com/learning/dns/dns-records/dns-ptr-record/): `mail.example.com.`
- MX: `mail.example.com`
- TXT: `"v=spf1 mx ~all"` (for [SPF](https://www.cloudflare.com/learning/dns/dns-records/dns-spf-record/))

Add the module to your NixOS configuration and configure the service:

```nix
# flake.nix
inputs.pombal.url = "github:duvslag-mail/pombal";
...
pombal.nixosModules.default

# configuration.nix, see "example-configuration.nix" a detailed example
services.pombal = {
	enable = true;
	hostname = "mail.example.com";
	# Issue this first
	useACMEHost = "mail.example.com";
};
```

I've tested receiving and sending to both work with Thunderbird and Geary.

## Conventions

- Use capitalized [imperative mood](https://en.wikipedia.org/wiki/Imperative_mood) for commit messages

## Resources

- [Postfix documentation](https://www.postfix.org/documentation.html) ([NixOS Wiki article](https://wiki.nixos.org/wiki/Postfix))
- [Dovecot documentation](https://doc.dovecot.org/2.4.5/) ([NixOS Wiki article](https://wiki.nixos.org/wiki/Dovecot))

---

_If you actually want to self-host your mail on NixOS — [Simple NixOS Mailserver](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver) is probably a better option._
