<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:param name="processor"/>
  <xsl:param name="processor-jar"/>
  <xsl:param name="processor-executable"/>
  <xsl:param name="param-template"/>
  <xsl:param name="outfile-template"/>
  <xsl:param name="validator"/>
  <xsl:param name="validator-jar"/>
  <xsl:param name="validator-executable"/>
  <xsl:param name="list"/>
  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$list">
	<xsl:value-of select="$newline"/>
	<xsl:text>Processors:</xsl:text>
	<xsl:value-of select="$newline"/>
	<xsl:apply-templates select="xgf-defaults/compiler-engine" mode="list"/>
	<xsl:value-of select="$newline"/>
	<xsl:text>Validators:</xsl:text>
	<xsl:value-of select="$newline"/>
	<xsl:apply-templates select="xgf-defaults/validator" mode="list"/>
	<xsl:value-of select="$newline"/>
      </xsl:when>
      <xsl:when test="$processor">
	<xsl:apply-templates
	    select="xgf-defaults/compiler-engine[@name=$processor]/template"/>
      </xsl:when>
      <xsl:when test="$processor-executable">
	<xsl:apply-templates
	    select="xgf-defaults/compiler-engine[@name=$processor-executable]/executable"/>
      </xsl:when>
      <xsl:when test="$processor-jar">
	<xsl:choose>
	  <xsl:when test="xgf-defaults/compiler-engine[@name=$processor-jar]">
	    <xsl:apply-templates
		select="xgf-defaults/compiler-engine[@name=$processor-jar]/jar"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="normalize-space($processor-jar)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$param-template">
	<xsl:apply-templates
	    select="xgf-defaults/compiler-engine[@name=$param-template]/param-template"/>
      </xsl:when>
      <xsl:when test="$outfile-template">
	<xsl:apply-templates
	    select="xgf-defaults/compiler-engine[@name=$outfile-template]/outfile-template"/>
      </xsl:when>
      <xsl:when test="$validator">
	<xsl:apply-templates
	    select="xgf-defaults/validator[@name=$validator]/template"/>
      </xsl:when>
      <xsl:when test="$validator-executable">
	<xsl:apply-templates
	    select="xgf-defaults/validator[@name=$validator-executable]/executable"/>
      </xsl:when>
      <xsl:when test="$validator-jar">
	<xsl:choose>
	  <xsl:when test="xgf-defaults/validator[@name=$validator-jar]">
	    <xsl:apply-templates
		select="xgf-defaults/validator[@name=$validator-jar]/jar"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="normalize-space($validator-jar)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$schema-type">
	<xsl:apply-templates
	    select="xgf-defaults/validator[@name=$schema-type]/schema-type"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="validator" mode="list">
    <xsl:text>  </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="normalize-space(description)"/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="compiler-engine" mode="list">
    <xsl:text>  </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="normalize-space(description)"/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="template|param-template|outfile-template|executable|jar|schema-type">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

</xsl:stylesheet>
