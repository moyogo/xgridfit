<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xi="http://www.w3.org/2001/XInclude"
		exclude-result-prefixes="xsl"
		version="1.0">

  <xsl:output method="xml"/>

  <xsl:template match="/">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="xgridfit">
    <xsl:choose>
      <xsl:when test="descendant::xi:include">
	<xgridfit xmlns="http://xgridfit.sourceforge.net/Xgridfit2"
		  xmlns:xi="http://www.w3.org/2001/XInclude">
	  <xsl:apply-templates select="node()"/>
	</xgridfit>
      </xsl:when>
      <xsl:otherwise>
	<xgridfit xmlns="http://xgridfit.sourceforge.net/Xgridfit2">
	  <xsl:apply-templates select="node()"/>
	</xgridfit>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="replace">
    <!--
	Recurse until $targ is no longer found.
    -->
    <xsl:param name="s"/>
    <xsl:param name="targ"/>
    <xsl:param name="repl"/>
    <xsl:choose>
      <xsl:when test="contains($s,$targ)">
	<xsl:call-template name="replace">
	  <xsl:with-param name="s">
	    <xsl:value-of
		select="concat(substring-before($s,$targ),$repl,substring-after($s,$targ))"/>
	  </xsl:with-param>
	  <xsl:with-param name="targ" select="$targ"/>
	  <xsl:with-param name="repl" select="$repl"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="fixup-xpath">
    <!--
	1. sub // - {d}
	2. sub / = {s}
	3. sub {s} - /x:
	4. sub {d} - //x:
    -->
    <xsl:param name="x"/>
    <xsl:variable name="no-slash-string">
      <xsl:call-template name="replace">
	<xsl:with-param name="s">
	  <xsl:call-template name="replace">
	    <xsl:with-param name="s" select="$x"/>
	    <xsl:with-param name="targ" select="'//'"/>
	    <xsl:with-param name="repl" select="'{d}'"/>
	  </xsl:call-template>
	</xsl:with-param>
	<xsl:with-param name="targ" select="'/'"/>
	<xsl:with-param name="repl" select="'{s}'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="replace">
      <xsl:with-param name="s">
	<xsl:call-template name="replace">
	  <xsl:with-param name="s" select="$no-slash-string"/>
	  <xsl:with-param name="targ" select="'{s}'"/>
	  <xsl:with-param name="repl" select="'/x:'"/>
	</xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="targ" select="'{d}'"/>
      <xsl:with-param name="repl" select="'//x:'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xi:include">
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:variable name="h" select="@href"/>
      <xsl:variable name="x">
	<xsl:choose>
	  <xsl:when test="@xpointer">
	    <xsl:value-of select="@xpointer"/>
	  </xsl:when>
	  <xsl:when test="contains($h,'#')">
	    <xsl:value-of select="substring-after($h,'#')"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message terminate="yes">
	      Can't find an xpointer for this xi:include
	    </xsl:message>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:attribute name="href">
	<xsl:choose>
	  <xsl:when test="contains($h,'#')">
	    <xsl:value-of select="substring-before($h,'#')"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$h"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="xpointer">
	<xsl:choose>
	  <xsl:when test="contains($x,'/')">
	    <xsl:variable name="noxp">
	      <xsl:choose>
		<xsl:when test="contains($x,'xpointer(')">
		  <xsl:value-of
		      select="substring-before(substring-after($x,'xpointer('),')')"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$x"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:variable>
	    <xsl:variable name="fixed-xpath">
	      <xsl:call-template name="fixup-xpath">
		<xsl:with-param name="x" select="$noxp"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <xsl:text>xmlns(x=http://xgridfit.sourceforge.net/Xgridfit2)xpointer(</xsl:text>
	    <xsl:value-of select="$fixed-xpath"/>
	    <xsl:text>)</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$x"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()|@*" priority="-0.5">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" priority="-0.25">
    <xsl:element name="{local-name()}"
		 namespace="http://xgridfit.sourceforge.net/Xgridfit2">
      <xsl:for-each select="@*">
	<xsl:attribute name="{name()}">
	  <xsl:value-of select="."/>
	</xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
