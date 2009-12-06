<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
		version="1.0">
  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="xgf:xgridfit"/>
  </xsl:template>

  <xsl:template match="xgf:xgridfit">
    <xgridfit>
      <xsl:attribute name="xmlns">http://xgridfit.sourceforge.net/Xgridfit2</xsl:attribute>
      <xsl:value-of select="$newline"/>
      <xsl:for-each select="*[local-name() != 'glyph']">
	<xsl:copy-of select="."/>
	<xsl:value-of select="$newline"/>
      </xsl:for-each>
      <xsl:for-each select="xgf:glyph">
	<xsl:sort select="@ps-name" order="ascending"/>
	<xsl:copy-of select="."/>
	<xsl:value-of select="$newline"/>
      </xsl:for-each>
    </xgridfit>
  </xsl:template>

  <xsl:template match="node()|@*">
      <xsl:copy>
	<xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
