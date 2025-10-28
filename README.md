# SnapPub

> [!WARNING]
> This is currently a DRAFT. It may change considerably before it's stable.
>
> Linked files and tools may be outdated!

**SnapPub** is a lightweight, open protocol that enables publishers to announce updates to web resources.
It leverages the **Snapchan** network (also known as **Farcaster**) to distribute update notifications through a single, global feed.
This means publishers broadcast once, while consumers can subscribe universally to discover updates across all participating sources.

## Why SnapPub Scales and Simplifies

- **No inboxes.** Subscribers don’t host servers or manage callbacks — they simply watch a single, open feed on Farcaster.  
- **No verification roundtrips.** Snapchain handles identity, signatures, and message authenticity at the protocol level. Publishers and subscribers don’t need to negotiate trust.  
- **O(1) broadcast cost.** Each update is posted once, rather than to *n* subscribers or *m×n* peers.  
- **Global discoverability.** Because updates share a single transport and canonical namespace, consumers can universally discover all feed changes without coordination or federation.

## Architecture Overview

```
┌───────────────────────┐       ┌─────────────────────────┐       ┌────────────────────┐
│                       │       │  Snapchain (Farcaster)  │       │    Subscribers     │
│       Publisher       │       │    - Auth & Identity    │       │   (Feed readers,   │
│ (blog, site, podcast, │──────▷│    - Signed messages    ├──────▷│ aggregators, blog  │
│         etc)          │       │      - Global feed      │       │  backends, apps)   │
│                       │       │                         │       │                    │
└───────────────────────┘       └─────────────────────────┘       └────────────────────┘
```

### How it works

1. **Publishers** post update notifications (e.g., “feed updated”) as **signed casts** to Snapchain, referencing their canonical feed URL (`fc:canonical`) and identity (`fc:fname`).  
2. The **Snapchain network** (Farcaster's blockchain) handles:
   - cryptographic **authentication** and **signature verification**  
   - **message propagation** across all participating peers  
   - maintaining the **global, append-only feed** of update events  
3. **Subscribers** don’t need inboxes or callback endpoints — they simply **listen** to the shared feed and filter updates matching the feeds or publishers they care about.

> This design separates **trust** (handled by Snapchain’s identity layer) from **transport** (the broadcast feed), enabling global fan-out without any direct publisher–subscriber coordination.

## Identity and Openness

**Snapchain**, the underlying transport used by SnapPub, is an **open network** — anyone can publish a cast referencing any public URL as its `parentUrl`.  
This openness makes it possible for updates, comments, and discussions to emerge organically across the web.

However, Snapchain also provides **built-in identity and verification**, which allows consumers to distinguish between *authoritative updates* and *community interactions*.

### 1. Open participation

Any Farcaster user can publish a cast referencing a URL:

```json
{
  "parentUrl": "https://example.com/post/hello",
  "text": "Nice write-up on SnapPub!"
}
```

This openness mirrors the web itself: anyone can link to or comment on a page.

### 2. Verified identity

Each cast on Snapchain is **signed** by its publisher and associated with a **Farcaster identity** (`fid` / `fname`).  
This means consumers can make trust decisions based on identity, such as:

- only process updates from the **authoritative publisher**
- include comments from users they follow
- ignore spam or unknown accounts

Because Snapchain identity is cryptographically backed, consumers don’t need extra verification roundtrips.

### 3. Authoritative publisher

A resource (for example, an RSS feed) can declare which Farcaster identity is considered **authoritative** for its updates.

In the SnapPub RSS extension (described later), this is indicated by:

```xml
<fc:fname>alice</fc:fname>
```

When a cast references this feed via `parentUrl`, consumers **SHOULD** treat casts from `@alice` as authoritative resource updates — and **MAY** ignore others.

### 4. Rich identity context

Farcaster identity includes a **rich metadata graph**, such as:

- display name, avatar, bio, verification badges  
- follow graph (who follows whom)  
- reputation and history of interactions

Consumers can leverage these properties to improve the experience around *non-authoritative* casts — such as displaying comments, mentions, or reactions from trusted users or known communities.

#### Summary

| Property | SnapPub / Snapchain behavior |
|-----------|------------------------------|
| **Open publishing** | Anyone can post a cast referencing any URL |
| **Identity built-in** | Each cast is signed and linked to a Farcaster `fid` / `fname` |
| **Authoritative source** | Feeds and resources can declare the trusted `fname` for updates |
| **Social metadata** | Farcaster identity graph enables rich filtering, discovery, and reputation around resource discussions |



## Protocol Comparison

| **Aspect** | **SnapPub** | **WebSub (PubSubHubbub)** | **ActivityPub** | **Webmention** |
|-------------|--------------|-----------------------------|-----------------|----------------|
| **Purpose** | Announce updates to web resources through a shared, global feed | Notify subscribers when a topic or feed updates | Exchange activities (posts, likes, follows) between federated servers | Notify a target URL that it has been linked to |
| **Transport** | **Snapchan / Farcaster** — decentralized broadcast layer | HTTP POST via central hub and subscriber endpoints | HTTP(S) with JSON-LD (ActivityStreams 2.0) | Direct HTTP POST between sites |
| **Delivery model** | **Broadcast:** one update → visible to all consumers via global feed | **Push:** publisher → hub → subscriber(s) | **Federated:** peer servers deliver to inbox/outbox | **Point-to-point:** source → target |
| **Publisher requirements** | Publish one cast per update, referencing canonical URL (`fc:canonical`) | Must advertise a hub and topic URL; verify and notify hubs | Maintain a federated server with APIs, actor objects, and signatures | Must send POST notifications per linked target |
| **Subscriber requirements** | **None.** No inbox or callback endpoint; consumers simply read from the shared feed | Must maintain an HTTP endpoint and verify subscription | **Inbox required**; must store and handle messages | Must expose an HTTP endpoint to receive mentions |
| **Authentication / Verification** | **Handled by Snapchain/Farcaster.** Identities and signatures are built into the transport layer — no extra verification required. | Requires HTTP challenge/response to verify subscriber ownership | Uses signed JSON-LD activities (per user and server) | Optional manual verification of source content |
| **Scalability** | **Highly scalable:** broadcast once; global visibility. P2P complexity and auth handled by Snapchain, avoiding exponential peer growth. | Scales with hub capacity; limited by per-subscriber push load | Scales linearly with number of federated peers; grows exponentially in dense networks | Uncoordinated; scales poorly as connections multiply |

### Summary

- **SnapPub** uses **broadcast semantics** — publish once, reach everyone — removing the need for per-subscriber coordination.  
- **WebSub** relies on **hubs** for scaling subscriptions.  
- **ActivityPub** builds **federated** social graphs with heavier server logic.  
- **Webmention** works **peer-to-peer**, suitable for backlinks and micro-interactions.

# Applications

SnapPub can be used for any type of **public** resource update (for example, DNS record changes), but we focus on RSS/Atom feeds for now.

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
