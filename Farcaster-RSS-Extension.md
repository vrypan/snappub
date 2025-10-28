# Farcaster RSS Extension (`fc:`) Mini-Spec

**Namespace:** `xmlns:fc="https://farcaster.xyz/ns/fc/1.0"`  
**Document Status:** Draft, Informational  
**Applies to:** RSS 2.0 feeds (channel-level metadata)

## 1. Purpose

The `fc:` namespace links an RSS feed to a Farcaster identity via its **fname**, and establishes the feed’s **canonical URL** for reference as a Farcaster/Snapchain `parentUrl`.  
This enables:  
(a) authoritative feed update signaling, and  
(b) discovery/attribution of casts (comments, mentions, reactions) attached to the feed’s URL.

## 2. Namespace Declaration

Declare the namespace on the root `<rss>` element:

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
- **Example:** `alice` (no `@` prefix)

#### Example

```xml
<channel>
  <title>My Blog</title>
  <link>https://example.com/</link>
  <fc:fname>alice</fc:fname>
  …
</channel>
```

### 3.2 `fc:canonical` (REQUIRED)

Represents the **canonical URL of the feed** (the URL that casts should reference via `parentUrl`).

- **Type:** absolute URL  
- **Cardinality:** EXACTLY ONE per `<channel>`  
- **Scope:** feed-level only

#### Example

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

- Consumers **MUST** treat `fc:canonical` as the canonical reference for this feed.  
- Generic RSS readers **MAY** ignore `fc:` elements they do not understand.

## 4. Semantics

- `fc:fname` binds the feed to a Farcaster identity.  
- `fc:canonical` binds the feed document to a single canonical URL.  
- Absence of either element renders the feed **non-compliant** with this spec.  
- Because fnames can change, consumers should treat them as *current*, not immutable.

## 5. Placement Rules

- `fc:fname` and `fc:canonical` **MUST** appear only as direct children of `<channel>`.  
- They **MUST NOT** appear inside `<item>`.  
- If duplicated, consumers **SHOULD** use only the **first** occurrence of each.

## 6. Processing Expectations

### Producers **MUST**:
- Include `fc:fname` and `fc:canonical`.  
- Keep values consistent and update `fc:fname` if the fname changes.

### Consumers **MUST**:
- Warn or reject when either element is missing.  
- Ignore unknown `fc:` elements.

## 7. Validation & Compatibility

- Conforms to RSS 2.0 extensibility.  
- Unknown namespaced elements are ignored by baseline parsers.  
- XML must remain well-formed.

## 8. Security Considerations

- This extension alone does **not** prove ownership.  
- Consumers **SHOULD** rely on Farcaster identity (fname/fid) and exact `parentUrl` match for authority checks.  
- Consumers **MAY** ignore casts from non-authoritative fnames for this feed.

## 9. Versioning

Namespace URI encodes version `1.0`. Breaking changes require a new URI (e.g., `…/2.0`).

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

Additional `fc:` elements may be defined later; consumers **MUST** ignore unknown `fc:` elements.

## 12. SnapPub Integration

To enable SnapPub-compatible update signaling, implementations **MUST** observe the following:

- **Producer requirement:** When the feed updates, publish a Farcaster cast authored by `fc:fname` **with**:
  - `parentUrl` = the feed’s `fc:canonical`
  - an embed whose URL is exactly `snappub:update`
  - an empty or whitespace-only text body

- **Consumer requirement:** Treat a cast as a feed-update notification iff **all** hold:
  - `parentUrl` exactly matches `fc:canonical`
  - author identity matches `fc:fname`
  - the cast includes an embed with URL `snappub:update`

Other Farcaster events referencing `fc:canonical` (e.g., comments, mentions, reactions) are out of scope for this document and **MAY** be surfaced by applications; see the README for semantics and examples.

**Informative references:**  
- Basic Principles (updates, comments, mentions, reactions) — see README.md  
- Rationale, examples, and UI guidance — see README.md
