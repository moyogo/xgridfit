<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:math="http://exslt.org/math"
		exclude-result-prefixes="xsl math"
		version="1.0">

  <xsl:variable name="newline">
    <xsl:text>
    </xsl:text>
  </xsl:variable>

  <xsl:template match="/" priority="0">
    <xsl:if test="//asm">
      <xsl:message terminate="yes">
	<xsl:text>
	  The &lt;asm&gt; element is no longer permitted in Xgridfit
	  programs. Please convert your program using the the sed script
	  convert-asm.sed (in the utils directory) and then run this
	  converter again.
	</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="node()|@*" priority="-0.5">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="control-values" priority="0">
    <xsl:apply-templates select="control-value"/>
  </xsl:template>

  <xsl:template match="control-value" priority="0">
    <xsl:choose>
      <xsl:when test="@id">
	<xsl:copy>
	  <xsl:attribute name="name">
	    <xsl:value-of select="@id"/>
	  </xsl:attribute>
	  <xsl:apply-templates select="@value"/>
	</xsl:copy>
	<xsl:value-of select="$newline"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="functions" priority="0">
    <xsl:apply-templates select="function"/>
  </xsl:template>

  <xsl:template match="function" priority="0">
    <xsl:choose>
      <xsl:when test="@id">
	<xsl:copy>
	  <xsl:attribute name="name">
	    <xsl:value-of select="@id"/>
	  </xsl:attribute>
	  <xsl:apply-templates select="@return|@num|@xml:id|node()"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="macros" priority="0">
    <xsl:apply-templates select="macro"/>
  </xsl:template>

  <xsl:template match="macro" priority="0">
    <xsl:choose>
      <xsl:when test="@id">
	<xsl:copy>
	  <xsl:attribute name="name">
	    <xsl:value-of select="@id"/>
	  </xsl:attribute>
	  <xsl:apply-templates select="node()"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="params" priority="0">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="variables" priority="0">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="variable" priority="0">
    <xsl:choose>
      <xsl:when test="@id">
	<xsl:copy>
	  <xsl:attribute name="name">
	    <xsl:value-of select="@id"/>
	  </xsl:attribute>
	  <xsl:apply-templates select="@value"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="declarations" priority="0">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="constant" priority="0">
    <xsl:choose>
      <xsl:when test="@num">
	<xsl:copy>
	  <xsl:apply-templates select="@name"/>
	  <xsl:attribute name="value">
	    <xsl:value-of select="@num"/>
	  </xsl:attribute>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="legacy-functions">
    <xsl:choose>
      <xsl:when test="@highest">
	<xsl:copy>
	  <xsl:attribute name="max-function-defs">
	    <xsl:value-of select="@highest"/>
	  </xsl:attribute>
	  <xsl:apply-templates/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="diagonal-stem" priority="0">
    <xsl:copy>
      <xsl:if test="@min-distance or @min-amount">
	<xsl:attribute name="min-distance">
	  <xsl:choose>
	    <xsl:when test="@min-amount">
	      <xsl:value-of select="@min-amount"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="@min-distance"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@distance|@round|@cut-in|@freedom-vector|@save-vectors|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="combine-offset-and-num">
    <xsl:param name="offset"/>
    <xsl:param name="num"/>
    <xsl:variable name="nn" select="normalize-space($num)"/>
    <xsl:variable name="n">
      <xsl:choose>
	<xsl:when test="contains($nn,' ')">
	  <xsl:value-of select="concat('(',$nn,')')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$nn"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="no" select="normalize-space(@offset)"/>
    <xsl:variable name="o">
      <xsl:choose>
	<xsl:when test="contains($no,' ')">
	  <xsl:value-of select="concat('(',$no,')')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$no"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="number($o) = 0">
	<xsl:value-of select="$num"/>
      </xsl:when>
      <xsl:when test="number($o) &lt; 0">
	<xsl:value-of select="concat($n,' - ',math:abs($o))"/>
      </xsl:when>
      <xsl:otherwise>
	<!-- covers both situation where $o is greater than zero and
	     that where it does not evaluate to a number. -->
	<xsl:value-of select="concat($n,' + ',$o)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="point" priority="0">
    <xsl:choose>
      <xsl:when test="@offset">
	<xsl:copy>
	  <xsl:attribute name="num">
	    <xsl:call-template name="combine-offset-and-num">
	      <xsl:with-param name="offset" select="@offset"/>
	      <xsl:with-param name="num" select="@num"/>
	    </xsl:call-template>
	  </xsl:attribute>
	  <xsl:apply-templates select="@zone"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="with-param" priority="0">
    <xsl:param name="with-newline" select="false()"/>
    <xsl:copy>
      <xsl:attribute name="name">
	<xsl:choose>
	  <xsl:when test="@param-id">
	    <xsl:value-of select="@param-id"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="@name"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="value">
	<xsl:choose>
	  <xsl:when test="@offset">
	    <xsl:call-template name="combine-offset-and-num">
	      <xsl:with-param name="offset" select="@offset"/>
	      <xsl:with-param name="num" select="@value"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="@value"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
    <xsl:if test="$with-newline">
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="call-function" priority="0">
    <xsl:choose>
      <xsl:when test="@function-id">
	<xsl:copy>
	  <xsl:attribute name="name">
	    <xsl:value-of select="@function-id"/>
	  </xsl:attribute>
	  <xsl:apply-templates select="@result-to"/>
	  <xsl:choose>
	    <xsl:when test="count(param-set) = 1">
	      <xsl:value-of select="$newline"/>
	      <xsl:apply-templates select="param-set/with-param">
		<xsl:with-param name="with-newline" select="true()"/>
	      </xsl:apply-templates>
	    </xsl:when>
	    <xsl:when test="count(param-set) &gt; 1">
	      <xsl:value-of select="$newline"/>
	      <xsl:apply-templates select="param-set"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$newline"/>
	      <xsl:apply-templates select="node()">
		<xsl:with-param name="with-newline" select="true()"/>
	      </xsl:apply-templates>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="call-macro" priority="0">
    <xsl:choose>
      <xsl:when test="@macro-id">
	<xsl:copy>
	  <xsl:attribute name="name">
	    <xsl:value-of select="@macro-id"/>
	  </xsl:attribute>
	  <xsl:choose>
	    <xsl:when test="count(param-set) = 1">
	      <xsl:value-of select="$newline"/>
	      <xsl:apply-templates select="param-set/with-param">
		<xsl:with-param name="with-newline" select="true()"/>
	      </xsl:apply-templates>
	    </xsl:when>
	    <xsl:when test="count(param-set) &gt; 1">
	      <xsl:value-of select="$newline"/>
	      <xsl:apply-templates select="param-set"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$newline"/>
	      <xsl:apply-templates select="node()">
		<xsl:with-param name="with-newline" select="true()"/>
	      </xsl:apply-templates>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="profile" priority="0">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="default" priority="0">
    <xsl:if test="@type != 'max-instructions'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="to-stack">
    <push><xsl:value-of select="."/></push>
  </xsl:template>

</xsl:stylesheet>
