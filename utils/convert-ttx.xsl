<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <!--
     This script, called by ttx2xgf, converts a TTX file (an XML
     representation of a font) into an Xgridfit script *almost* ready
     to be compiled in TTX mode (final fixup is done in a Python
     script).
-->

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:variable name="newline-two">
    <xsl:text>
  </xsl:text>
  </xsl:variable>

  <xsl:variable name="newline-four">
    <xsl:text>
    </xsl:text>
  </xsl:variable>

  <xsl:variable name="newline-six">
    <xsl:text>
      </xsl:text>
  </xsl:variable>

  <xsl:variable name="two-space">
    <xsl:text>  </xsl:text>
  </xsl:variable>

  <xsl:variable name="four-space">
    <xsl:text>    </xsl:text>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="ttFont">
    <xsl:element name="xgridfit" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="default" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="type">max-twilight-points</xsl:attribute>
	<xsl:attribute name="value">
	  <xsl:value-of select="maxp/maxTwilightPoints/@value"/>
	</xsl:attribute>
      </xsl:element>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="default" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="type">legacy-storage</xsl:attribute>
	<xsl:attribute name="value">
	  <xsl:value-of select="number(maxp/maxStorage/@value) + 64"/>
	</xsl:attribute>
      </xsl:element>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="default" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="type">max-stack</xsl:attribute>
	<xsl:attribute name="value">
	  <xsl:value-of select="maxp/maxStackElements/@value"/>
	</xsl:attribute>
      </xsl:element>
      <!-- Here are some handy values thrown in for free -->
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="constant" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="name">left-sidebearing</xsl:attribute>
	<xsl:attribute name="value">last + 1</xsl:attribute>
      </xsl:element>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="constant" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="name">right-sidebearing</xsl:attribute>
	<xsl:attribute name="value">last + 2</xsl:attribute>
      </xsl:element>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="constant" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="name">vertical</xsl:attribute>
	<xsl:attribute name="value">0</xsl:attribute>
      </xsl:element>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="constant" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="name">horizontal</xsl:attribute>
	<xsl:attribute name="value">1</xsl:attribute>
      </xsl:element>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="constant" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="name">false</xsl:attribute>
	<xsl:attribute name="value">0</xsl:attribute>
      </xsl:element>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="constant" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="name">true</xsl:attribute>
	<xsl:attribute name="value">1</xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="cvt"/>
      <xsl:value-of select="$newline"/>
      <xsl:apply-templates select="fpgm"/>
      <xsl:value-of select="$newline"/>
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="pre-program" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:value-of select="$newline"/>
	<xsl:apply-templates select="prep"/>
	<xsl:value-of select="$newline"/>
      </xsl:element>
      <xsl:value-of select="$newline"/>
      <xsl:apply-templates select="glyf"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="cvt">
    <xsl:value-of select="$two-space"/>
    <xsl:for-each select="cv">
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="control-value" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="name">
	  <xsl:value-of select="concat('cv-',@index)"/>
	</xsl:attribute>
	<xsl:attribute name="value">
	  <xsl:value-of select="@value"/>
	</xsl:attribute>
      </xsl:element>
    </xsl:for-each>
    <xsl:value-of select="$newline-two"/>
    <xsl:comment>
      <xsl:text>
	Do not add, subtract or reorder above this point.
	You may change the id but not the value of any of
	these control-value elements.
      </xsl:text>
    </xsl:comment>
    <xsl:value-of select="$newline-two"/>
  </xsl:template>

  <xsl:template match="fpgm">
    <xsl:if test="assembly">
      <xsl:value-of select="$newline-two"/>
      <xsl:element name="legacy-functions"  namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	<xsl:attribute name="max-function-defs">
	  <xsl:value-of select="/ttFont/maxp/maxFunctionDefs/@value"/>
	</xsl:attribute>
	<xsl:value-of select="$newline-six"/>
	<xsl:value-of select="assembly"/>
	<xsl:value-of select="$newline-two"/>
      </xsl:element>
      <xsl:value-of select="$newline"/>
      <xsl:value-of select="$newline"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="prep">
    <xsl:if test="assembly">
      <xsl:value-of select="$newline-two"/>
      <xsl:value-of select="assembly"/>
    </xsl:if>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="glyf">
    <xsl:for-each select="TTGlyph">
      <xsl:if test="instructions/assembly and
		    string-length(normalize-space(instructions/assembly))">
	<xsl:value-of select="$newline-two"/>
	<xsl:variable name="n">
	  <xsl:value-of select="./@name"/>
	</xsl:variable>
	<xsl:element name="glyph" namespace="http://xgridfit.sourceforge.net/Xgridfit2">
	  <xsl:attribute name="ps-name">
	    <xsl:value-of select="$n"/>
	  </xsl:attribute>
	  <xsl:attribute name="xml:id">
	    <xsl:choose>
	      <xsl:when test="$n = '.notdef'">
		<xsl:text>notdef-glyph</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$n"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  <xsl:attribute name="init-graphics">
	    <xsl:value-of select="'no'"/>
	  </xsl:attribute>
	  <xsl:value-of select="$newline-four"/>
	    <xsl:value-of select="instructions/assembly"/>
	  <xsl:value-of select="$newline-two"/>
	</xsl:element>
	<xsl:value-of select="$newline"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
