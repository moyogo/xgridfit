<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:param name="file-a"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="xi:include" xmlns:xi="http://www.w3.org/2001/XInclude">
    <xsl:variable name="h">
      <xsl:choose>
	<xsl:when test="contains(@href,'#')">
	  <xsl:value-of select="substring-before(@href,'#')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@href"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$h != $file-a">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="node()|@*" priority="-0.5">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
