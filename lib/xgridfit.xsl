<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xgf="http://xgridfit.sourceforge.net/Xgridfit2"
                xmlns:xgfd="http://www.engl.virginia.edu/OE/xgridfit-data"
		xmlns:excom="http://exslt.org/common"
                version="1.0"
                exclude-result-prefixes="xgf"
		extension-element-prefixes="excom">


  <!--
      xgridfit, an XML-based language for instructing TrueType fonts

      Copyright (c) 2006-11 by Peter S. Baker

      Issued under the GNU Public License, v. 2.

      No warranty here! Back up your fonts!
  -->

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="glyph_select">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:glyph-select">
	<xsl:value-of select="/xgf:xgridfit/xgf:glyph-select"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="compile_globals">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='compile-globals']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='compile-globals']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="init_graphics">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='init-graphics']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='init-graphics']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- How many points permitted in the twilight zone. This is generous,
       I think. -->
  <xsl:param name="max_twilight_points">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='max-twilight-points']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
			      'max-twilight-points']/@value"/>
      </xsl:when>
      <xsl:otherwise>25</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- How many storage spaces to allocate. These are used for variables.
       Increase the number if you use variables a lot. -->
  <xsl:param name="max_storage">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='max-storage']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
			      'max-storage']/@value"/>
      </xsl:when>
      <xsl:otherwise>64</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="max_stack">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='max-stack']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
			      'max-stack']/@value"/>
      </xsl:when>
      <xsl:otherwise>256</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="delta_break">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='delta-break']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
			      'delta-break']/@value"/>
      </xsl:when>
      <xsl:otherwise>10</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="push_break">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='push-break']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
			      'push-break']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="number($delta_break) * 2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="color">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='color']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
			      'color']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'gray'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="infile">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:infile">
        <xsl:value-of select="/xgf:xgridfit/xgf:infile"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="outfile">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:outfile">
        <xsl:value-of select="/xgf:xgridfit/xgf:outfile"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="outfile_base">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:outfile-base">
	<xsl:value-of select="/xgf:xgridfit/xgf:outfile-base"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="outfile_script_name">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:outfile-script-name">
	<xsl:value-of select="/xgf:xgridfit/xgf:outfile-script-name"/>
      </xsl:when>
      <xsl:when test="$outfile_base != '!!nofile!!'">
	<xsl:value-of select="concat($outfile_base,'_outfile.pe')"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="mp-containers"
	     select="//xgf:call-macro[not(param-set)]|
		     //xgf:call-macro/xgf:param-set|
		     //xgf:call-glyph"/>

  <xsl:variable name="merge-mode" select="false()"/>

  <xsl:key name="cvt" match="xgf:control-value" use="@name"/>
  <xsl:key name="function-index" match="xgf:function" use="@name"/>
  <xsl:key name="macro-index" match="xgf:macro" use="@name"/>
  <xsl:key name="glyph-index" match="xgf:glyph|xgf:no-compile/xgf:glyph"
	   use="@ps-name"/>

  <!-- We'll do our own formatting of all TT instructions, providing all
       line breaks and spacing. So no space or line breaks kept from source
       file. -->
  <xsl:strip-space elements="*"/>

  <xsl:variable name="newline">
    <xsl:text>\n</xsl:text>
  </xsl:variable>

  <xsl:variable name="inst-newline">
    <xsl:text>\n</xsl:text>
  </xsl:variable>

  <xsl:variable name="push-num-separator">
    <xsl:text>\n</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="text-newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:variable name="leading-newline"
		select="concat($inst-newline,'&#34;+\',$text-newline)"/>

  <xsl:variable name="cv-num-in-compile-if" select="'yes'"/>

  <xsl:variable name="file-extension" select="'.pe'"/>

  <!-- These will be found in func-predef.xsl. -->
  <xsl:variable name="predefined-functions" select="4"/>
  
  <xsl:variable name="auto-function-base">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type = 'function-base']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type = 'function-base-num']/@value"/>
      </xsl:when>
      <xsl:when test="/xgf:xgridfit/xgf:function[@num]">
        <xsl:variable name="n">
          <xsl:call-template name="get-highest-function-number">
            <xsl:with-param name="current-function"
                            select="/xgf:xgridfit/xgf:function[@num][1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="number($n) + 1"/>
      </xsl:when>
      <xsl:when test="/xgf:xgridfit/xgf:legacy-functions/@max-function-defs">
	<xsl:value-of select="/xgf:xgridfit/xgf:legacy-functions/@max-function-defs"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="var-legacy-storage">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type = 'legacy-storage']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type = 'legacy-storage']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="function-round-restore"
		select="$auto-function-base"/>
  
  <xsl:variable name="function-glyph-prolog"
		select="number($auto-function-base) + 1"/>
  
  <xsl:variable name="function-push-range"
		select="number($auto-function-base) + 2"/>

  <xsl:variable name="function-order-range"
		select="number($auto-function-base) + 3"/>
  
  <xsl:include href="std-vars.xsl"/>
  <xsl:include href="numbers.xsl"/>
  <xsl:include href="expressions.xsl"/>
  <xsl:include href="arithmetic.xsl"/>
  <xsl:include href="points.xsl"/>
  <xsl:include href="flow.xsl"/>
  <xsl:include href="function.xsl"/>
  <xsl:include href="func-predef.xsl"/>
  <xsl:include href="prep.xsl"/>
  <xsl:include href="graphics.xsl"/>
  <xsl:include href="measure.xsl"/>
  <xsl:include href="primitives.xsl"/>
  <xsl:include href="delta.xsl"/>
  <xsl:include href="move-lib.xsl"/>
  <xsl:include href="move-els.xsl"/>
  <xsl:include href="messages.xsl"/>
  <xsl:include href="misc.xsl"/>
  

  <!--

       simple-command

       A very simple, one-line command, with optional modifier.
  -->
  <xsl:template name="simple-command">
    <xsl:param name="cmd"/>
    <xsl:param name="modifier"/>
    <xsl:value-of select="$leading-newline"/>
<!--
    <xsl:value-of select="$inst-newline"/>
    <xsl:text>"+\</xsl:text>
    <xsl:value-of select="$text-newline"/>
-->
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$cmd"/>
    <xsl:if test="$modifier">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$modifier"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <!--

       push-command

       Generates the command for a PUSH instruction.
  -->
  <xsl:template name="push-command">
    <xsl:param name="size" select="'B'"/>
    <xsl:param name="count" select="1"/>
    <xsl:variable name="cmd">
      <xsl:choose>
        <xsl:when test="number($count) &lt;= 8">
          <xsl:value-of select="concat('PUSH',$size,'_',$count)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="number($count) &gt; 255">
            <xsl:call-template name="error-message">
              <xsl:with-param name="msg">
                <xsl:text>You may not push more than 255 numbers at one time.</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:value-of select="concat('NPUSH',$size)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="simple-command">
      <xsl:with-param name="cmd" select="$cmd"/>
    </xsl:call-template>
    <xsl:if test="number($count) &gt; 8">
      <xsl:value-of select="$inst-newline"/>
      <xsl:value-of select="$count"/>
    </xsl:if>
  </xsl:template>

  <!-- The following templates are for the bit-flags that accompany
       certain instructions. -->

  <xsl:template name="color-bits">
    <xsl:param name="l-color"/>
    <xsl:choose>
      <xsl:when test="$l-color='black'">
        <xsl:text>01</xsl:text>
      </xsl:when>
      <xsl:when test="$l-color='white'">
        <xsl:text>10</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>00</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="to-line-bit">
    <xsl:param name="tlb"/>
    <xsl:choose>
      <xsl:when test="$tlb='orthogonal'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="axis-bit">
    <xsl:param name="axis"/>
    <xsl:choose>
      <xsl:when test="$axis='x'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="$axis='y'">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error-message">
          <xsl:with-param name="msg">
            <xsl:text>When setting a vector, the "axis" </xsl:text>
            <xsl:text>attribute must be either "x" or "y."</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="round-and-cut-in-bit">
    <xsl:param name="b" select="true()"/>
    <xsl:choose>
      <xsl:when test="$b">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="rp0-bit">
    <xsl:param name="set-rp0"/>
    <xsl:choose>
      <xsl:when test="$set-rp0">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="mirp-mdrp-bits">
    <xsl:param name="set-rp0"/>
    <xsl:param name="min-distance"/>
    <xsl:param name="round-cut-in"/>
    <xsl:param name="l-color"/>
    <xsl:call-template name="rp0-bit">
      <xsl:with-param name="set-rp0" select="$set-rp0"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$min-distance">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="round-and-cut-in-bit">
      <xsl:with-param name="b" select="$round-cut-in"/>
    </xsl:call-template>
    <xsl:call-template name="color-bits">
      <xsl:with-param name="l-color" select="$l-color"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="ref-ptr-bit">
    <xsl:param name="ref-ptr"/>
    <xsl:choose>
      <xsl:when test="$ref-ptr='1'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="grid-fitted-bit">
    <xsl:param name="grid-fitted"/>
    <xsl:choose>
      <xsl:when test="$grid-fitted">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-std-variable-loc">
    <xsl:param name="n"/>
    <xsl:param name="add" select="0"/>
    <xsl:choose>
      <xsl:when test="number($n) or number($n) = 0">
	<xsl:value-of select="number($n) + number($var-legacy-storage) + $add"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="number(document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name=$n]/@val) +
			      number($var-legacy-storage) + $add"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-cvt-index">
    <xsl:param name="name"/>
    <xsl:param name="need-number-now"/>
    <xsl:value-of
	select="count(key('cvt',$name)/preceding-sibling::xgf:control-value)"/>
  </xsl:template>

  <xsl:template name="debug-start"></xsl:template>

  <xsl:template name="debug-end"></xsl:template>

<!-- ========================================================================= -->
<!-- ============== TOP-LEVEL ELEMENTS OF THE INSTRUCTION FILE =============== -->
<!-- ========================================================================= -->
  

  <xsl:template match="/">
    <xsl:if test="not(xgf:xgridfit)">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg" select="$no-namespace-error"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="xgf:xgridfit">
    <xsl:param name="all-functions" select="/xgf:xgridfit/xgf:function"/>
    <xsl:param name="leg"
	       select="/xgf:xgridfit/xgf:legacy-functions"/>
    <xsl:if test="not(xgf:pre-program) and $compile_globals='yes'">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>A &lt;pre-program&gt; element must be present, even if empty.</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$infile != '!!nofile!!'">
        <xsl:text>Open("</xsl:text>
        <xsl:value-of select="$infile"/>
        <xsl:text>")</xsl:text>
        <xsl:value-of select="$text-newline"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:if test="$compile_globals='yes'">
	  <xsl:call-template name="warning">
	    <xsl:with-param name="msg">
	      <xsl:text>No font file specified. You may have to edit the script or</xsl:text>
	      <xsl:text> run it in the FontForge GUI.</xsl:text>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$compile_globals='yes'">
      <xsl:text>ClearTable("cvt")</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:text>i=0</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:text>while ( i&lt;</xsl:text>
      <xsl:value-of select="count(xgf:control-value)"/>
      <xsl:text> )</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:text>    FindOrAddCvtIndex( 2*i )</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:text>    ++i</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:text>endloop</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:for-each select="xgf:control-value">
	<xsl:text>ReplaceCvtAt(</xsl:text>
	<xsl:value-of select="position() - 1"/>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text>)</xsl:text>
	<xsl:value-of select="$text-newline"/>
      </xsl:for-each>
      <!--
	  We need an fpgm table with our predefined functions even if
	  user has defined no functions.
      -->
      <xsl:text>AddInstrs("fpgm",1,</xsl:text>
      <xsl:variable name="current-inst">
	<xsl:choose>
	  <xsl:when test="$all-functions[@num]">
	    <xsl:apply-templates select="$all-functions[@num]"/>
	  </xsl:when>
	  <xsl:when test="$leg[@max-function-defs]">
	    <xsl:apply-templates select="$leg"/>
	  </xsl:when>
	</xsl:choose>
	<xsl:call-template name="function-zero"/>
	<xsl:call-template name="function-one"/>
	<xsl:call-template name="function-two"/>
	<xsl:call-template name="function-three"/>
	<xsl:apply-templates select="$all-functions[not(@num) and not(xgf:variant)]"/>
      </xsl:variable>
      <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
      <xsl:text>")</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:apply-templates select="xgf:pre-program"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="string-length($glyph_select)">
	<xsl:call-template name="glyph-list">
	  <xsl:with-param name="list" select="$glyph_select"/>
	  <xsl:with-param name="separator">
	    <xsl:choose>
	      <xsl:when test="contains($glyph_select,'+')">
		<xsl:value-of select="'+'"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="' '"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="$outfile_base = '!!nofile!!'">
	    <xsl:apply-templates select="xgf:glyph"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:choose>
	      <xsl:when test="element-available('excom:document')">
		<xsl:for-each select="xgf:glyph">
		  <xsl:variable name="new-filename"
				select="concat($outfile_base,'_',@ps-name,$file-extension)"/>
		  <xsl:call-template name="display-message">
		    <xsl:with-param name="msg">
		      <xsl:text>Saving to file </xsl:text>
		      <xsl:value-of select="$new-filename"/>
		    </xsl:with-param>
		  </xsl:call-template>
<!--
		  <excom:document excom:href="{$new-filename}" excom:method="text">
-->
		  <excom:document href="{$new-filename}" method="text">
		    <xsl:apply-templates select="."/>
		  </excom:document>
		</xsl:for-each>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="error-message">
		  <xsl:with-param name="msg">
		    <xsl:text>Your XSLT engine does not support -S (outfile_base)</xsl:text>
		  </xsl:with-param>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$compile_globals='yes'">
      <!-- maxTwilightPoints -->
      <xsl:text>SetMaxpValue("TwilightPntCnt",</xsl:text>
      <xsl:value-of select="$max_twilight_points"/>    
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <!-- maxStorage -->
      <xsl:text>SetMaxpValue("StorageCnt",</xsl:text>
      <xsl:variable name="gvb">
	<xsl:call-template name="resolve-std-variable-loc">
	  <xsl:with-param name="n" select="$global-variable-base"/>
	  <xsl:with-param name="add" select="1"/>
	</xsl:call-template>
      </xsl:variable>
      <xsl:choose>
	<xsl:when test="number($max_storage) &gt;= number($gvb)">
	  <xsl:value-of select="$max_storage"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$gvb"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <xsl:text>SetMaxpValue("MaxStackDepth",</xsl:text>
      <xsl:value-of select="$max_stack"/>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <!-- maxFunctionDefs -->
      <xsl:variable name="v-legacy-functions">
	<xsl:choose>
	  <xsl:when test="xgf:legacy-functions">
	    <xsl:value-of select="xgf:legacy-functions/@max-function-defs"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>0</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:text>SetMaxpValue("FDEFs",</xsl:text>
      <xsl:value-of select="number($v-legacy-functions) +
			    number($predefined-functions) +
			    count(/xgf:xgridfit/xgf:function)"/>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$text-newline"/>
    </xsl:if>
    <xsl:if test="$outfile != '!!nofile!!'">
      <xsl:variable name="o" select="normalize-space($outfile)"/>
      <xsl:variable name="ext" select="substring($o,string-length($o)-3)"/>
      <xsl:choose>
	<xsl:when test="$outfile_base = '!!nofile!!'">
	  <xsl:call-template name="do-outfile">
	    <xsl:with-param name="o" select="$o"/>
	    <xsl:with-param name="ext" select="$ext"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:choose>
	    <xsl:when test="element-available('excom:document')">
	      <xsl:call-template name="display-message">
		<xsl:with-param name="msg">
		  <xsl:text>Saving to file </xsl:text>
		  <xsl:value-of select="$outfile_script_name"/>
		</xsl:with-param>
	      </xsl:call-template>
<!--
	      <excom:document excom:href="{$outfile_script_name}" excom:method="text">
-->
	      <excom:document href="{$outfile_script_name}" method="text">
		<xsl:call-template name="do-outfile">
		  <xsl:with-param name="o" select="$o"/>
		  <xsl:with-param name="ext" select="$ext"/>
		</xsl:call-template>
	      </excom:document>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="error-message">
		<xsl:with-param name="msg">
		  <xsl:text>Your XSLT engine does not support -S (outfile_base)</xsl:text>
		</xsl:with-param>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="do-outfile">
    <xsl:param name="o"/>
    <xsl:param name="ext"/>
    <xsl:choose>
      <xsl:when test="not(string-length($o))">
	<xsl:text>Save()</xsl:text>
      </xsl:when>
      <xsl:when test="$ext = '.sfd'">
	<xsl:text>Save("</xsl:text>
	<xsl:value-of select="$o"/>
	<xsl:text>")</xsl:text>
      </xsl:when>
      <xsl:when test="$ext = '.ttf'">
	<xsl:text>Generate("</xsl:text>
	<xsl:value-of select="$o"/>
	<xsl:text>"</xsl:text>
	<xsl:if test="/xgf:xgridfit/xgf:outfile/@fmflags">
	  <xsl:text>,"",</xsl:text>
	  <xsl:value-of select="/xgf:xgridfit/xgf:outfile/@fmflags"/>
	</xsl:if>
	<xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="warning">
	  <xsl:with-param name="msg">
	    <xsl:text>Unrecognized file extension </xsl:text>
	    <xsl:value-of select="$ext"/>
	    <xsl:text>. No file will be saved.</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$text-newline"/>
  </xsl:template>

  <xsl:template match="xgf:pre-program">
    <xsl:text>AddInstrs("prep",1,</xsl:text>
    <xsl:variable name="current-inst">
      <xsl:call-template name="pre-program-instructions"/>
    </xsl:variable>
    <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
    <xsl:text>")</xsl:text>
    <xsl:value-of select="$text-newline"/>
  </xsl:template>

  <!--
      N.B. template "glyph" with mode "called" will be in
      function.xsl.  There will be nothing non-portable in it, and we
      don't want to write it twice.
  -->

  <xsl:template match="xgf:glyph">
    <xsl:variable name="var-string">
      <xsl:text>x</xsl:text>
      <xsl:apply-templates select="." mode="survey-vars"/>
    </xsl:variable>
    <xsl:variable name="need-variable-frame" select="contains($var-string,'v')"/>
    <xsl:variable name="init-g">
      <xsl:choose>
	<xsl:when test="@init-graphics">
	  <xsl:value-of select="@init-graphics"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$init_graphics"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="display-message">
      <xsl:with-param name="msg">
	<xsl:text>Compiling glyph </xsl:text>
	<xsl:value-of select="@ps-name"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>AddInstrs("</xsl:text>
    <xsl:value-of select="@ps-name"/>
    <xsl:text>",1,</xsl:text>
    <xsl:variable name="current-inst">
      <xsl:if test="$need-variable-frame">
	<xsl:call-template name="set-up-variable-frame"/>
	<xsl:apply-templates select="xgf:variable" mode="initialize"/>
      </xsl:if>
      <xsl:if test="$init-g = 'yes'">
	<xsl:call-template name="number-command">
	  <xsl:with-param name="num" select="$function-glyph-prolog"/>
	  <xsl:with-param name="cmd" select="'CALL'"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
    <xsl:text>")</xsl:text>
    <xsl:value-of select="$text-newline"/>
  </xsl:template>

  <!-- The following elements are declarations, read only
       by this script and never converted to code. -->

  <xsl:template match="xgf:no-compile"></xsl:template>

</xsl:stylesheet>
