<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
        xmlns:fc="https://farcaster.xyz/ns/fc/1.0"
        queryBinding="xslt2">

  <!-- ============================
       Required extension elements
       ============================ -->
  <pattern id="fc-required">
    <rule context="channel">
      <assert test="count(fc:fname)=1">
        A compliant fc feed MUST contain exactly one fc:fname element under channel.
      </assert>
      <assert test="count(fc:canonical)=1">
        A compliant fc feed MUST contain exactly one fc:canonical element under channel.
      </assert>
    </rule>
  </pattern>

  <!-- ============================
       Placement rules
       ============================ -->
  <pattern id="fc-placement">
    <rule context="item">
      <assert test="count(fc:fname)=0">
        fc:fname MUST NOT appear inside item.
      </assert>
      <assert test="count(fc:canonical)=0">
        fc:canonical MUST NOT appear inside item.
      </assert>
    </rule>
  </pattern>

  <!-- ============================
       No duplicates anywhere
       ============================ -->
  <pattern id="fc-no-duplicates">
    <rule context="channel">
      <assert test="count(fc:fname)=1">
        fc:fname MUST appear exactly once.
      </assert>
      <assert test="count(fc:canonical)=1">
        fc:canonical MUST appear exactly once.
      </assert>
    </rule>
  </pattern>

</schema>
