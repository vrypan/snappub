# Farcaster RSS Extension (`fc:`) Mini-Spec — using `fname`

**Namespace:** `xmlns:fc="https://farcaster.xyz/ns/fc/1.0"`  
**Document Status:** Draft, Informational  
**Applies to:** RSS 2.0 feeds (channel-level metadata)

## 1. Purpose

The `fc:` namespace provides metadata that links an RSS feed to a Farcaster identity via its **fname** (human-readable Farcaster name).  
This enables feed readers or aggregators to automatically detect the publisher’s Farcaster username.

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

## 4. Semantics

- Presence of `fc:fname` asserts that the feed’s publisher uses that Farcaster name.  
- Absence makes no claim.  
- Because fnames can change, consumers should treat them as *current*, not immutable.

## 5. Placement Rules

- `fc:fname` **MUST** appear only as a direct child of `<channel>`.  
- It **MUST NOT** appear inside `<item>`.  
- If multiple `fc:fname` elements appear, consumers should use the **first**.

## 6. Processing Expectations

### Producers **SHOULD**:

- Include `fc:fname` when a canonical Farcaster name exists.  
- Update it if the fname changes.

### Consumers **SHOULD**:

- Read and surface `fc:fname` when present.  
- Gracefully ignore feeds without it.  
- Ignore unknown elements in the `fc:` namespace.

## 7. Validation & Compatibility

- This extension follows RSS 2.0’s extensibility rules.  
- Unknown namespaced elements are ignored by standard RSS parsers.  
- XML validity must be preserved (well-formed tags, correct namespace declaration).

## 8. Security Considerations

- `fc:fname` does **not** cryptographically prove ownership.  
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
