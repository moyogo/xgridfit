<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
		exclude-result-prefixes="xgf"
		version="1.0">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:param name="file-b"/>
  <xsl:param name="prep-mode" select="'merge'"/>
  <xsl:param name="skip-b-no-compile" select="'yes'"/>
  <xsl:param name="use-compile-globals" select="'no'"/>
  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>
  <xsl:variable name="ubg">
    <xsl:choose>
      <xsl:when test="$use-compile-globals = 'yes'">
	<xsl:choose>
	  <xsl:when test="document($file-b)/xgf:xgridfit/xgf:default[@type='compile-globals' and @value='no']">
	    <xsl:text>no</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>yes</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>yes</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="use-b-globals" select="$ubg='yes'"/>

  <xsl:template match="/">
    <xsl:apply-templates select="xgf:xgridfit"/>
  </xsl:template>

  <xsl:template match="xgf:xgridfit">
    <xgridfit xmlns="http://xgridfit.sourceforge.net/Xgridfit2">
      <xsl:value-of select="$newline"/>
      <xsl:choose>
	<xsl:when test="document($file-b)/xgf:xgridfit/xgf:glyph-select">
	  <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:glyph-select" mode="add-newline"/>
	</xsl:when>
	<xsl:when test="xgf:glyph-select">
	  <xsl:apply-templates select="xgf:glyph-select" mode="add-newline"/>
	</xsl:when>
      </xsl:choose>
      <xsl:choose>
	<xsl:when test="document($file-b)/xgf:xgridfit/xgf:infile">
	  <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:infile" mode="add-newline"/>
	</xsl:when>
	<xsl:when test="xgf:infile">
	  <xsl:apply-templates select="xgf:infile" mode="add-newline"/>
	</xsl:when>
      </xsl:choose>
      <xsl:choose>
	<xsl:when test="document($file-b)/xgf:xgridfit/xgf:outfile">
	  <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:outfile" mode="add-newline"/>
	</xsl:when>
	<xsl:when test="xgf:outfile">
	  <xsl:apply-templates select="xgf:outfile" mode="add-newline"/>
	</xsl:when>
      </xsl:choose>
      <xsl:choose>
	<xsl:when test="document($file-b)/xgf:xgridfit/xgf:outfile-base">
	  <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:outfile-base"
			       mode="add-newline"/>
	</xsl:when>
	<xsl:when test="xgf:outfile-base">
	  <xsl:apply-templates select="xgf:outfile-base" mode="add-newline"/>
	</xsl:when>
      </xsl:choose>
      <xsl:choose>
	<xsl:when test="document($file-b)/xgf:xgridfit/xgf:outfile-script-name">
	  <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:outfile-script-name"
			       mode="add-newline"/>
	</xsl:when>
	<xsl:when test="xgf:outfile-script-name">
	  <xsl:apply-templates select="xgf:outfile-script-name" mode="add-newline"/>
	</xsl:when>
      </xsl:choose>
      <xsl:if test="$skip-b-no-compile = 'no'">
	<xsl:choose>
	  <xsl:when test="xgf:no-compile">
	    <xsl:apply-templates select="xgf:no-compile" mode="global-a"/>
	  </xsl:when>
	  <xsl:when test="$use-b-globals">
	    <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:no-compile" mode="global-b"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:if>
      <xsl:call-template name="make-storage-default"/>
      <xsl:call-template name="make-stack-default"/>
      <xsl:apply-templates select="xgf:default[@type != 'max-storage' and @type != 'max-stack']"
			   mode="global-a"/>
      <xsl:if test="$use-b-globals">
	<xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:default[@type != 'max-storage'
				     and @type != 'max-stack' and @type != 'compile-globals']"
			     mode="add-newline"/>
      </xsl:if>
      <xsl:apply-templates select="xgf:constant" mode="global-a"/>
      <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:constant" mode="add-newline"/>
      <xsl:apply-templates select="xgf:alias" mode="global-a"/>
      <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:alias" mode="add-newline"/>
      <xsl:apply-templates select="xgf:variable" mode="global-a"/>
      <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:variable" mode="add-newline"/>
      <xsl:apply-templates select="xgf:round-state" mode="global-a"/>
      <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:round-state" mode="add-newline"/>
      <xsl:apply-templates select="xgf:control-value" mode="global-a"/>
      <xsl:comment>
<xsl:text>
  Warning: control values above this point should not be added,
  deleted or reordered. They may be renamed and their values
  changed.
</xsl:text>
      </xsl:comment>
      <xsl:value-of select="$newline"/>
      <xsl:if test="$use-b-globals">
	<xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:control-value" mode="global-b">
	  <xsl:with-param name="xg" select="."/>
	</xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates select="xgf:legacy-functions"/>
      <xsl:value-of select="$newline"/>
      <xsl:apply-templates select="xgf:function" mode="global-a"/>
      <xsl:if test="$use-b-globals">
	<xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:function" mode="add-newline"/>
      </xsl:if>
      <xsl:apply-templates select="xgf:macro" mode="global-a"/>
      <xsl:if test="$use-b-globals">
	<xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:macro" mode="add-newline"/>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="$use-b-globals and xgf:pre-program and $prep-mode='merge'">
	  <xsl:apply-templates select="xgf:pre-program"/>
	</xsl:when>
	<xsl:when test="xgf:pre-program and $prep-mode='priority'">
	  <xsl:choose>
	    <xsl:when test="$use-b-globals and document($file-b)/xgf:xgridfit/xgf:pre-program">
	      <xsl:copy-of select="document($file-b)/xgf:xgridfit/xgf:pre-program"/>
	    </xsl:when>
	    <xsl:when test="xgf:pre-program">
	      <xsl:copy-of select="xgf:pre-program"/>
	    </xsl:when>
	  </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select="xgf:pre-program"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="xgf:glyph" mode="global-a"/>
      <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:glyph" mode="add-newline"/>
    </xgridfit>
  </xsl:template>

  <xsl:template name="make-storage-default">
    <xsl:variable name="local-max">
      <xsl:variable name="m">
	<xsl:choose>
	  <xsl:when test="xgf:default[@type='max-storage']">
	    <xsl:value-of select="xgf:default[@type='max-storage']/@value"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="64"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="l">
	<xsl:choose>
	  <xsl:when test="xgf:default[@type='legacy-storage']">
	    <xsl:value-of select="xgf:default[@type='legacy-storage']/@value"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="64"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:choose>
	<xsl:when test="number($m) &gt; number($l)">
	  <xsl:value-of select="$m"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$l"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="other-max">
      <xsl:choose>
	<xsl:when test="document($file-b)/xgf:xgridfit/xgf:default[@type='max-storage']">
	  <xsl:value-of select="document($file-b)/xgf:xgridfit/xgf:default[@type='max-storage']/@value"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="64"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="default"
		 namespace="http://xgridfit.sourceforge.net/Xgridfit2">
      <xsl:attribute name="type">
	<xsl:value-of select="'max-storage'"/>
      </xsl:attribute>
      <xsl:attribute name="value">
	<xsl:value-of select="number($local-max) + number($other-max)"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template name="make-stack-default">
    <xsl:variable name="local-val">
      <xsl:choose>
	<xsl:when test="xgf:default[@type='max-stack']">
	  <xsl:value-of select="xgf:default[@type='max-stack']/@value"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="256"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="other-val">
      <xsl:choose>
	<xsl:when test="document($file-b)/xgf:xgridfit/xgf:default[@type='max-stack']">
	  <xsl:value-of select="document($file-b)/xgf:xgridfit/xgf:default[@type='max-stack']/@value"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="256"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="larger-val">
      <xsl:choose>
	<xsl:when test="number($local-val) &gt; number($other-val)">
	  <xsl:value-of select="$local-val"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$other-val"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="number($larger-val) != 256">
      <default>
	<xsl:attribute name="type">
	  <xsl:text>max-stack</xsl:text>
	</xsl:attribute>
	<xsl:attribute name="value">
	  <xsl:value-of select="$larger-val"/>
	</xsl:attribute>
      </default>
    </xsl:if>
  </xsl:template>

  <xsl:template match="node()|@*" priority="-0.5">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node()|@*" priority="-0.5" mode="add-newline">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="constant" mode="global-a">
    <xsl:variable name="n" select="@name"/>
    <xsl:if test="not(document($file-b)/xgf:xgridfit/xgf:constant[@name=$n])">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="alias" mode="global-a">
    <xsl:variable name="n" select="@name"/>
    <xsl:if test="not(document($file-b)/xgf:xgridfit/xgf:alias[@name=$n])">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:variable" mode="global-a">
    <xsl:variable name="n" select="@name"/>
    <xsl:if test="not(document($file-b)/xgf:xgridfit/xgf:variable[@name=$n])">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:round-state" mode="global-a">
    <xsl:variable name="n" select="@name"/>
    <xsl:if test="not(document($file-b)/xgf:xgridfit/xgf:round-state[@name=$n])">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:default" mode="global-a">
    <xsl:variable name="t" select="@type"/>
    <xsl:if test="not(use-b-globals) or
		  ($use-b-globals and not(document($file-b)/xgf:xgridfit/xgf:default[@type=$t]))">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:control-value" mode="global-a">
    <xsl:variable name="n" select="@name"/>
    <xsl:choose>
      <xsl:when test="$use-b-globals and document($file-b)/xgf:xgridfit/xgf:control-value[@name=$n]">
	<control-value>
	  <xsl:attribute name="name">
	    <xsl:value-of select="$n"/>
	  </xsl:attribute>
	  <xsl:attribute name="value">
	    <xsl:value-of select="document($file-b)/xgf:xgridfit/xgf:control-value/@value"/>
	  </xsl:attribute>
	</control-value>
	<xsl:value-of select="$newline"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="." mode="add-newline"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xgf:control-value" mode="global-b">
    <xsl:param name="xg"/>
    <xsl:variable name="n" select="@name"/>
    <xsl:if test="not($xg/xgf:control-value[@name=$n])">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:no-compile" mode="global-a">
    <no-compile>
      <xsl:choose>
	<xsl:when test="$use-b-globals">
	  <xsl:for-each select="xgf:glyph">
	    <xsl:variable name="n" select="@ps-name"/>
	    <xsl:if test="not(document($file-b)/xgf:xgridfit/xgf:no-compile/xgf:glyph[@ps-name=$n])">
	      <xsl:apply-templates select="." mode="add-newline"/>
	    </xsl:if>
	  </xsl:for-each>
	  <xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:no-compile/xgf:glyph" mode="add-newline"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="xgf:glyph" mode="add-newline"/>
	</xsl:otherwise>
      </xsl:choose>
    </no-compile>
  </xsl:template>

  <xsl:template match="no-compile" mode="global-b">
    <no-compile>
      <xsl:apply-templates select="xgf:glyph" mode="add-newline"/>
    </no-compile>
  </xsl:template>

  <xsl:template match="function" mode="global-a">
    <xsl:variable name="n" select="@name"/>
    <xsl:if test="not($use-b-globals) or
		  ($use-b-globals and not(document($file-b)/xgf:xgridfit/xgf:function[@name=$n]))">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="macro" mode="global-a">
    <xsl:variable name="n" select="@name"/>
    <xsl:if test="not($use-b-globals) or
		  ($use-b-globals and not(document($file-b)/xgf:xgridfit/macro[@name=$n]))">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xgf:pre-program">
    <xgf:pre-program>
      <xsl:if test="document($file-b)/xgf:xgridfit/xgf:pre-program/@xml:id">
	<xsl:attribute name="xml:id">
	  <xsl:value-of select="document($file-b)/xgf:xgridfit/xgf:pre-program/@xml:id"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$newline"/>
      <xsl:if test="variable|alias">
	<xsl:apply-templates select="xgf:variable|xgf:alias" mode="add-newline"/>
      </xsl:if>
      <xsl:if test="document($file-b)/xgf:xgridfit/xgf:pre-program/xgf:variable |
		    document($file-b)/xgf:xgridfit/xgf:pre-program/xgf:alias">
	<xsl:apply-templates select="document($file-b)/xgf:xgridfit/xgf:pre-program/xgf:variable |
				     document($file-b)/xgf:xgridfit/xgf:pre-program/xgf:alias"
			     mode="add-newline"/>
      </xsl:if>
      <xsl:apply-templates select="./*[local-name() != 'variable' and local-name() != 'alias']"
			   mode="add-newline"/>
      <xsl:if test="document($file-b)/xgf:xgridfit/xgf:pre-program">
	<xsl:apply-templates
	    select="document($file-b)/xgf:xgridfit/xgf:pre-program/*[local-name() != 'variable' and
		    local-name() != 'alias']"
		    mode="add-newline"/>
      </xsl:if>
    </xgf:pre-program>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="xgf:glyph" mode="global-a">
    <xsl:variable name="p" select="@ps-name"/>
    <xsl:if test="not(document($file-b)/xgf:xgridfit/xgf:glyph[@ps-name=$p])">
      <xsl:apply-templates select="." mode="add-newline"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
