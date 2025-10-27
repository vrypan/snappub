# SnapPub

## Farcaster RSS Extension (fc:)

Defines a small RSS 2.0 extension that binds an RSS feed to a Farcaster identity (fname) and provides a canonical feed URL for use as a parentUrl in Farcaster casts.

Two namespaced elements MUST appear directly under the <channel> element:
- fc:fname — the publisher’s Farcaster fname
- fc:canonical — the canonical URL of the feed itself

When a new item is published, producers SHOULD emit an empty Farcaster cast whose parentUrl matches fc:canonical. Consumers SHOULD treat such casts—when authored by the declared fc:fname—as feed update notifications and re-fetch the feed.

Files:
- [Farcaster-RSS-Extension.md](Farcaster-RSS-Extension.md) — full specification and examples
- [fc-1.0.sch](fc-1.0.sch) — Schematron rules enforcing required semantics (placement, cardinality)
- [fc-1.0.xsd](fc-1.0.xsd) — XML Schema defining element types and namespace

All other fc: elements are reserved for future extension. Consumers MUST ignore unknown elements in the fc: namespace.

## Tools

[snappub-tools](https://github.com/vrypan/snappub-tools) is a set of tools to help testing and development of SnapPub apps.
