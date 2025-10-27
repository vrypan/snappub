# Farcaster RSS Extension (`fc:`) Mini-Spec — using `fname`

**Namespace:** `xmlns:fc="https://farcaster.xyz/ns/fc/1.0"`  
**Document Status:** Draft, Informational  
**Applies to:** RSS 2.0 feeds (channel-level metadata)

## 1. Purpose

The `fc:` namespace provides metadata that links an RSS feed to a Farcaster identity via its **fname**.  
It also establishes a canonical feed URL for reference in Farcaster casts (`parentUrl`).

## 2. Namespace Declaration

The namespace **MUST** be declared on the root `<rss>` element:

```xml
<rss version="2.0"
     xmlns:fc="https://farcaster.xyz/ns/fc/1.0">
```

## 3. Elements

### 3.1 `fc:fname` (REQUIRED)

Represents the publisher’s Farcaster **fname**.

- **Type:** string
- **Cardinality:** EXACTLY ONE per `<channel>`
- **Scope:** feed-level only
- **Example:** `alice` (without the `@` prefix)

Feeds **MUST** include this element.

#### Example usage:

```xml
<channel>
  <title>My Blog</title>
  <link>https://example.com/</link>
  <fc:fname>alice</fc:fname>
  …
</channel>
```

### 3.2 `fc:canonical` (REQUIRED)

Represents the **canonical URL of the feed itself**, used for Farcaster `parentUrl`.

- **Type:** absolute URL
- **Cardinality:** EXACTLY ONE per `<channel>`
- **Scope:** feed-level only

Feeds **MUST** include this element.

#### Example usage:

```xml
<channel>
  <title>My Blog</title>
  <link>https://example.com/</link>
  <fc:fname>alice</fc:fname>
  <fc:canonical>https://example.com/rss.xml</fc:canonical>
  …
</channel>
```

### Behavior

- Feed consumers **MUST** treat `fc:canonical` as the canonical reference for this feed.
- Generic RSS readers **MAY** ignore it.

## 4. Semantics

- `fc:fname` binds the feed to a Farcaster identity.
- `fc:canonical` binds the feed content to a canonical URL.
- Absence of either renders the feed **non-compliant** with this spec.
- Because fnames can change, consumers should treat them as *current*, not immutable.

## 5. Placement Rules

- `fc:fname` and `fc:canonical` **MUST** appear only as direct children of `<channel>`.
- They **MUST NOT** appear inside `<item>`.
- Only the **first** occurrence of each should be considered.

## 6. Processing Expectations

### Producers **MUST**:

- Include `fc:fname` and `fc:canonical`.
- Update `fc:fname` when the fname changes.
- Use the same values consistently.

### Consumers **MUST**:

- Reject or warn against feeds missing either element.
- Ignore unknown `fc:` elements.

## 7. Validation & Compatibility

This extension follows RSS 2.0’s extensibility rules.  
Unknown namespaced elements are ignored by standard RSS parsers.  
XML must remain valid.

## 8. Security Considerations

- This extension does **not** prove authorship cryptographically.
- Consumers **SHOULD** verify:
  - Farcaster fname ownership
  - canonical URL match
- Consumers **MAY** ignore casts posted by other fnames.

## 9. Versioning

The namespace URI encodes version `1.0`.  
Breaking changes require a new namespace URI (e.g., `…/2.0`).

## 10. Complete Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
     xmlns:fc="https://farcaster.xyz/ns/fc/1.0">
  <channel>
    <title>Example Blog</title>
    <link>https://example.com</link>
    <description>My thoughts and writing.</description>
    <fc:fname>alice</fc:fname>
    <fc:canonical>https://example.com/rss.xml</fc:canonical>

    <item>
      <title>Hello World</title>
      <link>https://example.com/post/hello</link>
      <pubDate>Mon, 01 Jan 2025 00:00:00 +0000</pubDate>
      <guid>https://example.com/post/hello</guid>
    </item>

  </channel>
</rss>
```

## 11. Reserved for Future Extensions

Additional `fc:` elements may be defined later.  
Consumers **MUST** ignore unknown `fc:` elements.

## 12. Feed Update Signaling (Farcaster Integration)

This section defines how feed updates **MUST** be signaled on Farcaster using casts referencing the canonical feed URL.

### 12.1 Producer Behavior

When the feed is updated (e.g., new item published):

Producers **SHOULD** publish a Farcaster cast:
- with `parentUrl` equal to the feed’s `fc:canonical` value
- with an **empty** text body

The cast **MUST** be posted by the Farcaster account whose `fname` is declared in `fc:fname`.

#### Example (on-chain message)

```json
{
  "data": {
    "castAddBody": {
      "parentUrl": "https://blog.vrypan.net/rss.xml",
      "text": ""
    },
    "fid": "280",
    "network": "FARCASTER_NETWORK_MAINNET",
    "timestamp": 151819607,
    "type": "MESSAGE_TYPE_CAST_ADD"
  },
  ...
}
```

### 12.2 Consumer Behavior

Consumers **MUST** treat casts as feed-update notifications when:

- `parentUrl` matches exactly the feed’s `fc:canonical`
- the cast’s author `fname` matches `fc:fname`
- the cast body is empty or whitespace-only

On detection, consumers:

- **SHOULD** fetch (or re-fetch) the feed
- **MAY** diff items
- **SHOULD** dedupe rapid update casts

### 12.3 Security Considerations

Consumers **MAY** ignore update casts from other fnames,
even if the `parentUrl` matches.

### 12.4 Rate & Etiquette

Producers:

- **SHOULD NOT** emit multiple update casts in rapid succession.
- **MAY** emit one update cast per feed update.

Consumers:

- **SHOULD** throttle re-fetch attempts (e.g., once per minute).

### 12.5 Extensibility

- Future versions MAY allow metadata in the cast body.
- Additional `fc:` elements MAY describe richer update protocols.

Consumers **MUST** ignore unknown fields.