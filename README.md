# SnapPub

> [!WARNING]
> This is currently a DRAFT. It may change considerably before it's stable.
>
> Linked files and tools may be outdated!

**SnapPub** is a lightweight, open protocol that enables publishers to announce updates to web resources.  
It leverages the **Snapchan** network (also known as **Farcaster**) to distribute update notifications through a single, global feed.  
Publishers broadcast once, and consumers can subscribe universally to discover updates across all participating sources.

---

## Why SnapPub Scales and Simplifies

- **No inboxes.** Subscribers don’t host servers or manage callbacks — they simply watch a shared global feed on Farcaster.  
- **No verification roundtrips.** Snapchain handles identity, signatures, and message authenticity at the protocol level.  
- **O(1) broadcast cost.** Each update is posted once, rather than to *n* subscribers or *m×n* peers.  
- **Global discoverability.** Because updates share a single transport and canonical namespace, consumers can discover all feed changes without coordination or federation.

---

## Architecture Overview

```
┌───────────────────────┐       ┌─────────────────────────┐       ┌────────────────────┐
│       Publisher       │──────▷│  Snapchain (Farcaster)  ├──────▷│    Subscribers     │
│ (blog, site, podcast, │       │    - Auth & Identity    │       │ (readers, bots,    │
│         etc)          │       │    - Signed messages    │       │  aggregators, apps)│
└───────────────────────┘       │    - Global feed        │       └────────────────────┘
                                └─────────────────────────┘
```

### How it works

1. **Publishers** post update notifications (e.g., “feed updated”) as **signed casts** to Snapchain, referencing their canonical feed URL (`fc:canonical`) and identity (`fc:fname`).  
2. The **Snapchain network** handles:
   - cryptographic authentication and signature verification  
   - message propagation across all peers  
   - maintaining the global, append-only feed of update events  
3. **Subscribers** don’t need inboxes or callbacks — they simply listen to the shared feed and filter updates matching the resources or publishers they care about.

---

## Identity and Openness

**Snapchain** is an open network — anyone can publish a cast referencing any public URL as its `parentUrl`.  
This openness allows updates, comments, and discussions to emerge organically across the web.

At the same time, Snapchain provides **built-in identity and verification**, allowing consumers to distinguish between *authoritative updates* and *community interactions*.

### Open participation

Any Farcaster user can publish a cast referencing a URL:

```json
{
  "parentUrl": "https://example.com/post/hello",
  "text": "Nice write-up on SnapPub!"
}
```

This mirrors the web: anyone can link to or comment on a page.

### Verified identity and trust

Each cast is signed and associated with a **Farcaster identity** (`fid` / `fname`).  
Consumers can make trust decisions based on that identity:

- accept updates only from the **authoritative publisher**  
- show comments, mentions, or reactions from known users  
- ignore spam or unknown accounts  

Because Snapchain identity is cryptographically backed, consumers don’t need extra verification roundtrips.

### Authoritative publisher

Resources (for example, RSS feeds) can declare which Farcaster identity is considered **authoritative** for their updates.  
In the SnapPub RSS extension (described below):

```xml
<fc:fname>alice</fc:fname>
```

Consumers treat casts referencing this feed and authored by `@alice` as canonical updates and may ignore others.

### Rich identity context

Farcaster identity includes metadata such as avatar, bio, and social graph.  
Consumers can use these properties to enhance *non-authoritative* updates like comments, mentions, or reactions.

#### Summary

| Property | SnapPub / Snapchain behavior |
|-----------|------------------------------|
| **Open publishing** | Anyone can post a cast referencing any URL |
| **Identity built-in** | Each cast is signed and linked to a Farcaster `fid` / `fname` |
| **Authoritative source** | Feeds and resources can declare the trusted `fname` for updates |
| **Social metadata** | Farcaster identity graph enables rich filtering, discovery, and reputation around resource discussions |

---

## Basic Principles

SnapPub uses Snapchain messages to inform the network about **updates**, **discussions**, **mentions**, and **reactions** related to a web resource.
In all cases, `parentUrl` is set to the resource URL.

| Intent | `type` |`embedUrl` | Meaning |
|--------|--------------|----------|----------|
| **ResourceUpdate** | cast | `snappub:update` | The resource itself has changed (e.g., a feed was updated). |
| **Comment** | cast | *any* | A message *about* the resource, such as a discussion or note. May include embedded media or links. |
| **Mention** | cast | `snappub:mention` + one more external URL | Another resource (`<url>` value) references or links to the resource identified by `parentUrl`. |
| **Reaction** | reaction | *(none)* | A Farcaster reaction (like or recast) referencing the resource directly. |

### Examples

#### Resource update
```json
{
  "parentUrl": "https://example.com/feed.xml",
  "embeds": [{ "url": "snappub:update" }],
  "text": ""
}
```
> The resource at `https://example.com/feed.xml` has been updated.

---

#### Comment
```json
{
  "parentUrl": "https://example.com/post/hello",
  "text": "Great post on static blogs!",
  "embeds": [{ "url": "https://images.example.com/thumb.jpg" }]
}
```
> A discussion or note *about* the resource at `https://example.com/post/hello`.

---

#### Mention
```json
{
  "parentUrl": "https://example.com/post/hello",
  "text": "Referenced in my latest blog post!",
  "embeds": [
    { "url": "https://anotherblog.net/posts/my-response" },
    { "url": "snappub:mention" }
  ]
}
```
> Another resource links to or references `https://example.com/post/hello`.

---

#### Reaction
Reactions are native to Farcaster and require **no SnapPub-specific embed**.  
They use `parentUrl=<resource>` and represent expressions like *likes* or *recasts*.

```json
{
  "type": "reaction",
  "reactionType": "like",
  "parentUrl": "https://example.com/post/hello"
}
```
> A reaction (like or recast) to the resource at `https://example.com/post/hello`.

---

### Summary

- **Resource updates** — signal a change to the resource itself.  
- **Comments** — discussions or feedback about the resource.  
- **Mentions** — link one resource to another.  
- **Reactions** — Farcaster-native likes or recasts referencing the resource directly.

---

### Integration Notes

- SnapPub **inherits** Farcaster’s first-class reaction system.  
- Consumers **SHOULD** display reactions alongside comments and mentions when `parentUrl` matches a known resource.  
- Since reactions are verified at the protocol layer, no SnapPub-specific syntax or embed is required.

---

## Protocol Comparison


| **Aspect** | **SnapPub** | **WebSub (PubSubHubbub)** | **ActivityPub** | **Webmention** |
|-------------|--------------|-----------------------------|-----------------|----------------|
| **Purpose** | Announce updates to web resources through a shared, global feed | Notify subscribers when a topic or feed updates | Exchange social activities between federated servers | Notify a target URL that it has been linked to |
| **Transport** | **Snapchan / Farcaster** — decentralized broadcast layer | HTTP POST via central hub | HTTP(S) with JSON-LD (ActivityStreams 2.0) | Direct HTTP POST |
| **Delivery model** | **Broadcast:** one update → all consumers | **Push:** hub → subscribers | **Federated:** server-to-server | **Point-to-point:** source → target |
| **Publisher requirements** | Publish one cast per update (`fc:canonical`) | Maintain hub + topic URLs | Host APIs and actor objects | POST notifications per link |
| **Subscriber requirements** | None — just listen to the global feed | Maintain callback endpoint | Maintain inbox | Receive POSTs |
| **Auth / Verification** | **Handled by Snapchain.** Built-in identity and signatures. | HTTP challenge-response | Signed JSON-LD | Optional manual verification |
| **Scalability** | **High.** Broadcast once; network handles propagation and authentication. | Limited by hub capacity | Grows linearly with peers | Poor beyond small networks |

---

## Applications

SnapPub can be used for any type of **public resource update** — for example:
- Blog posts  
- Podcasts  
- Open data feeds  
- Datasets or APIs  
- Even DNS or configuration changes  

However, this document focuses on its integration with RSS/Atom feeds.

---

## Farcaster RSS Extension (`fc:`)

The **Farcaster RSS Extension** defines a small RSS 2.0 extension that binds an RSS feed to a Farcaster identity (`fc:fname`) and provides a canonical feed URL (`fc:canonical`) for use as a `parentUrl` in SnapPub casts.

Two namespaced elements **MUST** appear directly under the `<channel>` element:

- `<fc:fname>` — the publisher’s Farcaster fname  
- `<fc:canonical>` — the canonical URL of the feed itself

When a new item is published, producers **SHOULD** post an empty cast whose `parentUrl` matches `fc:canonical` and set `embedUrl=snappub:update`.

Consumers **SHOULD** treat such casts — when authored by the declared `fc:fname` — as authoritative update notifications and re-fetch the feed.

**Files**

- [Farcaster-RSS-Extension.md](Farcaster-RSS-Extension.md) — full specification and examples  
- [fc-1.0.sch](fc-1.0.sch) — Schematron rules enforcing required semantics  
- [fc-1.0.xsd](fc-1.0.xsd) — XML Schema defining element types and namespace  

All other `fc:` elements are reserved for future extension.  
Consumers **MUST** ignore unknown elements in the `fc:` namespace.

---

## Tools

[`snappub-tools`](https://github.com/vrypan/snappub-tools) provides utilities for testing and developing SnapPub-compatible applications.

---

## Summary

SnapPub turns RSS and other web updates into **signed, verifiable broadcasts** on a **shared, decentralized network**.  
By offloading identity, authentication, and message distribution to **Snapchain**, it eliminates inbox management, reduces complexity, and scales linearly — enabling the open web to speak in real time.
