<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml"/>

  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:template match="/">
    <xgridfit>
      <xsl:value-of select="$newline"/>
      <xsl:for-each select="node()">
	<xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:value-of select="$newline"/>
    </xgridfit>
  </xsl:template>

</xsl:stylesheet>