# Farcaster RSS Extension (`fc:`) Mini-Spec — using `fname`

**Namespace:** `xmlns:fc="https://farcaster.xyz/ns/fc/1.0"`
**Document Status:** Draft, Informational
**Applies to:** RSS 2.0 feeds (channel-level metadata)

## 1. Purpose

The `fc:` namespace provides metadata that links an RSS feed to a Farcaster identity via its **fname** (human-readable Farcaster name).  
It also enables specification of a canonical feed URL for reference in casts (e.g., as a `parentUrl`).

## 2. Namespace Declaration

The namespace **MUST** be declared on the root `<rss>` element:

```xml
<rss version="2.0"
     xmlns:fc="https://farcaster.xyz/ns/fc/1.0">
```

## 3. Elements

### 3.1 `fc:fname`

Represents the publisher’s Farcaster **fname**.

- **Type:** string  
- **Cardinality:** `0–1` per `<channel>`  
- **Scope:** feed-level only  
- **Example:** `alice` (without the `@` prefix)

#### Example usage:

```xml
<channel>
  <title>My Blog</title>
  <link>https://example.com/</link>
  <fc:fname>alice</fc:fname>
  …
</channel>
```

### 3.2 `fc:canonical`

Represents the **canonical URL of the feed itself**.

- **Intended usage:** as a `parentUrl` reference for Farcaster casts
- **Type:** absolute URL  
- **Cardinality:** `0–1` per `<channel>`  
- **Scope:** feed-level only

#### Example usage:

```xml
<channel>
  <title>My Blog</title>
  <link>https://example.com/</link>
  <fc:fname>alice</fc:fname>
  <fc:canonical>https://example.com/feed.rss</fc:canonical>
  …
</channel>
```

### Behavior

- Feed consumers **SHOULD** treat `fc:canonical` as the canonical reference to this feed.
- Producers **SHOULD** include `fc:canonical` when possible.
- Only the first `fc:canonical` occurrence should be used if multiple are present.
- Generic RSS readers may ignore it.

## 4. Semantics

- Presence of `fc:fname` asserts that the feed’s publisher uses that Farcaster name.  
- `fc:canonical` asserts the canonical identity of the RSS document.  
- Absence of these fields makes no claim.  
- Because fnames can change, consumers should treat them as *current*, not immutable.

## 5. Placement Rules

- `fc:fname` and `fc:canonical` **MUST** appear only as direct children of `<channel>`.  
- They **MUST NOT** appear inside `<item>`.  
- If multiple occurrences appear, consumers should use the **first**.

## 6. Processing Expectations

### Producers **SHOULD**:

- Include `fc:fname` if a canonical Farcaster name exists.
- Include `fc:canonical` if a canonical feed URL exists.
- Update `fc:fname` if the fname changes.

### Consumers **SHOULD**:

- Read and surface `fc:fname` and `fc:canonical` when present.
- Ignore unknown elements in the `fc:` namespace.

## 7. Validation & Compatibility

- This extension follows RSS 2.0’s extensibility rules.  
- Unknown namespaced elements are ignored by standard RSS parsers.  
- XML validity must be preserved.

## 8. Security Considerations

- These elements do **not** cryptographically prove ownership.
- Consumers may perform additional verification if trust is relevant.

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
    <fc:canonical>https://example.com/feed.rss</fc:canonical>

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

Additional `fc:` elements may be defined later (e.g., key material, signatures, profile hints).  
Consumers **MUST** ignore unknown `fc:` elements.

## 12. Feed Update Signaling (Farcaster Integration)

This section defines how feed updates **may** be signaled on Farcaster using casts referencing the canonical feed URL.

### 12.1 Producer Behavior

When the feed is updated (e.g., new item published):

- Producers **SHOULD** publish a Farcaster cast:
  - with `parentUrl` equal to the feed’s `fc:canonical` value, and
  - with an **empty cast body** (i.e., no text content).

- The cast **MUST** be posted by the Farcaster account whose `fname` is declared in the feed (`fc:fname`).

#### Example

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

Consumers **SHOULD** treat casts that meet *all* of the following conditions as feed-update notifications:

- The cast’s `parentUrl` **matches exactly** the feed’s `fc:canonical` value.
- The cast’s author `fname` **matches** the feed’s `fc:fname` value.
- The cast’s text body is empty or whitespace-only.

When such a cast is detected, consumers:

- **SHOULD** fetch (or re-fetch) the feed.
- **MAY** trigger item-level diff logic.
- **SHOULD** de-duplicate multiple update casts within a short time window.

### 12.3 Security Considerations

- This mechanism is **not** cryptographic proof of authorship.
- Consumers **SHOULD** rely on:
  - Farcaster account ownership (`fname`)
  - canonical feed URL match
- Consumers **MAY** ignore update casts from other accounts, even if the `parentUrl` matches.

### 12.4 Rate & Etiquette Guidelines

Producers:

- **SHOULD NOT** emit multiple update casts in rapid succession.
- **MAY** emit one update cast per feed refresh cycle.

Consumers:

- **SHOULD** implement throttling (e.g., max one re-fetch attempt per minute per feed).

### 12.5 Extensibility

In future versions:

- The update cast’s body MAY include metadata (e.g., item GUIDs).
- Additional `fc:` elements MAY indicate richer update protocols.

Consumers **MUST** ignore unknown fields.