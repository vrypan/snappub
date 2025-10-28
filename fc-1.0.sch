<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:fc="https://farcaster.xyz/ns/fc/1.0">

  <title>Farcaster RSS Extension (fc:) — Schematron 1.0</title>
  <ns prefix="fc" uri="https://farcaster.xyz/ns/fc/1.0"/>

  <pattern id="fc-elements">
    <title>Required fc: elements in RSS channel</title>

    <!-- fc:fname must exist once -->
    <rule context="channel">
      <assert test="count(fc:fname) = 1">
        The <fc:fname> element MUST appear exactly once under <channel>.
      </assert>
    </rule>

    <!-- fc:canonical must exist once -->
    <rule context="channel">
      <assert test="count(fc:canonical) = 1">
        The <fc:canonical> element MUST appear exactly once under <channel>.
      </assert>
    </rule>

    <!-- fc:canonical must be an absolute URL -->
    <rule context="fc:canonical">
      <assert test="matches(normalize-space(.), '^(https?|ipfs)://')">
        <fc:canonical> MUST contain an absolute URL (e.g., https://example.com/rss.xml).
      </assert>
    </rule>
  </pattern>

</schema>
