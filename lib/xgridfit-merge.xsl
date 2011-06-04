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

  <xsl:param name="delete_all">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='delete-all']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='delete-all']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'no'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="combine_prep">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='combine-prep']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='combine-prep']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="auto_instr">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='auto-instr']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='auto-instr']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'no'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="auto-hint">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='auto-hint']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='auto-hint']/@value"/>
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

  <xsl:param name="push_break">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='push-break']">
        <xsl:value-of select="/xgf:xgridfit/xgf:default[@type=
			      'push-break']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="255"/>
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

  <xsl:param name="datafile">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:datafile">
        <xsl:value-of select="normalize-space(/xgf:xgridfit/xgf:datafile)"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

<!--
  <xsl:param name="outfile_base">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:outfile-base">
	<xsl:value-of select="/xgf:xgridfit/xgf:outfile-base"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
-->

  <xsl:param name="mp-containers"
	     select="//xgf:call-macro[not(param-set)]|
		     //xgf:call-macro/xgf:param-set|
		     //xgf:call-glyph"/>

  <xsl:variable name="outfile_base" select="'!!nofile!!'"/>

<!--
  <xsl:param name="outfile_script_name">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:outfile-script-name">
	<xsl:value-of select="/xgf:xgridfit/xgf:outfile-script-name"/>
      </xsl:when>
      <xsl:when test="$outfile_base != '!!nofile!!'">
	<xsl:value-of select="concat($outfile_base,'_outfile.py')"/>
      </xsl:when>
      <xsl:otherwise>!!nofile!!</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
-->

  <xsl:variable name="merge-mode" select="true()"/>

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
    <xsl:text>\n\
</xsl:text>
  </xsl:variable>

  <xsl:variable name="push-num-separator" select="$inst-newline"/>
  
  <xsl:variable name="text-newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:variable name="leading-newline" select="$inst-newline"/>

  <xsl:variable name="cv-num-in-compile-if">
    <xsl:choose>
      <xsl:when test="/xgf:xgridfit/xgf:default[@type='cv-num-in-compile-if']">
	<xsl:value-of select="/xgf:xgridfit/xgf:default[@type='cv-num-in-compile-if']/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="'no'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="file-extension" select="'.py'"/>

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

  <xsl:variable name="function-round-restore"
		select="'%__fn0__%'"/>
  
  <xsl:variable name="function-glyph-prolog"
		select="'%__fn1__%'"/>
  
  <xsl:variable name="function-push-range"
		select="'%__fn2__%'"/>

  <xsl:variable name="function-order-range"
		select="'%__fn3__%'"/>

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

       In merge-mode this is a meta-command, to be resolved into a
       PUSH instruction by the generated Python script.
  -->
  <xsl:template name="push-command">
    <xsl:param name="size" select="'M'"/>
    <xsl:param name="count" select="1"/>
    <xsl:if test="$count &gt; 255">
      <xsl:call-template name="error-message">
	<xsl:with-param name="msg">
	  <xsl:text>You may not push more than 255 numbers at one time.</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="$leading-newline"/>
    <xsl:text>push(</xsl:text>
    <xsl:value-of select="$count"/>
    <xsl:text>)</xsl:text>
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
    <xsl:text>{</xsl:text>
    <xsl:choose>
      <xsl:when test="number($n) or number($n) = 0">
	<xsl:value-of select="number($n) + $add"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="number(document('xgfdata.xml')/*/xgfd:var-locations/xgfd:loc[@name=$n]/@val) +
			      $add"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template name="get-cvt-index">
    <xsl:param name="name"/>
    <xsl:param name="need-number-now" select="false()"/>
    <xsl:choose>
      <xsl:when test="$need-number-now">
	<!--
	    A compile-if element that evaluates a control-value index
	    will typically just test for validity (&gt;= 0) or
	    equality (cv0 = cv1). In merge-mode we *can* get a number
	    that is good for those purposes, even though it is not the
	    same number that the programming in the font will use.
	-->
	<xsl:value-of
	    select="count(key('cvt',$name)/preceding-sibling::xgf:control-value)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>^</xsl:text>
	<xsl:value-of select="$name"/>
	<xsl:text>^</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="debug-start"></xsl:template>

  <xsl:template name="debug-end"></xsl:template>

  <xsl:template match="/xgf:xgridfit/xgf:ps-private/xgf:entry">
    <xsl:value-of select="$text-newline"/>
    <xsl:text>CURRENT_FONT.private['</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>'] = </xsl:text>
    <xsl:choose>
      <xsl:when test="@name = 'BlueFuzz'">
	<xsl:choose>
	  <xsl:when test="number(@value) or number(@value) = 0">
	    <xsl:value-of select="@value"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="error-message">
	      <xsl:with-param name="msg">
		<xsl:value-of select="@value"/>
		<xsl:text>, the BlueFuzz value, is not a number</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="make-tuple">
	  <xsl:with-param name="s" select="@value"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pyOpenFile">
    <xsl:choose>
      <xsl:when test="$infile != '!!nofile!!'">
	<xsl:text>CURRENT_FONT = fontforge.open("</xsl:text>
	<xsl:value-of select="$infile"/>
	<xsl:text>")</xsl:text>
        <xsl:value-of select="$text-newline"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="warning">
	  <xsl:with-param name="msg">
	    <xsl:text>No font file specified. You must do so before</xsl:text>
	    <xsl:text> running this script.</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pyRetrieveFontInfo">
    <xsl:choose>
      <xsl:when test="$compile_globals='yes'">
	<xsl:if test="$datafile = '!!nofile!!'">
	  <xsl:text>
if CURRENT_FONT.persistent == None:
    CURRENT_FONT.persistent = dict()</xsl:text>
	</xsl:if>
        <xsl:text>
XGRIDFIT_DICTIONARY = dict()
MAXP_DICTIONARY = dict()
if DELETE_ALL or AUTO_INSTR:
    # Remove all existing instructions, including fpgm and prep.
    # Zero out all maxp entries, and build an empty xgridfit
    # dictionary.
    XGRIDFIT_DICTIONARY = dict()
    for g in CURRENT_FONT.glyphs():
        g.ttinstrs = ""
    CURRENT_FONT.setTableData('cvt', None)
    CURRENT_FONT.setTableData('fpgm', None)
    CURRENT_FONT.setTableData('prep', None)
    CURRENT_FONT.maxp_FDEFs = 0
    CURRENT_FONT.maxp_storageCnt = 0
    CURRENT_FONT.maxp_twilightPtCnt = 0
    CURRENT_FONT.maxp_maxStackDepth = 0
    extract_font_globals()
    XGF_DICT_ALTERED = True
else:
    # We may be working with a clean font, but assume we're not.
    # Get the xgridfit dictionary, if one exists; if not, build it</xsl:text>
        <xsl:choose>
          <xsl:when test="$datafile != '!!nofile!!'">
	    <xsl:text>
    try:
        XGRIDFIT_DICTIONARY = pickle.load(open('</xsl:text>
	    <xsl:value-of select="$datafile"/>
	    <xsl:text>', 'r'))
    except IOError:</xsl:text>
          </xsl:when>
          <xsl:otherwise>
        <xsl:text>
    try:
        XGRIDFIT_DICTIONARY = CURRENT_FONT.persistent['xgridfit']
    except (KeyError, TypeError):</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
	<xsl:text>
        XGRIDFIT_DICTIONARY = dict()
        extract_font_globals()
        XGF_DICT_ALTERED = True</xsl:text>
	<xsl:apply-templates select="/xgf:xgridfit/xgf:ps-private/xgf:entry"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>
try:
    XGRIDFIT_DICTIONARY = </xsl:text>
        <xsl:choose>
	  <xsl:when test="$datafile != '!!nofile!!'">
	    <xsl:text>pickle.load(open('</xsl:text>
	    <xsl:value-of select="$datafile"/>
	    <xsl:text>', 'r'))</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>CURRENT_FONT.persistent['xgridfit']</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:text>
    XGRIDFIT_FUNCTION_NUMS = XGRIDFIT_DICTIONARY['xgffunc']
    CVT_DICTIONARY = XGRIDFIT_DICTIONARY['cvt']
    MAXP_DICTIONARY = XGRIDFIT_DICTIONARY['omaxp']</xsl:text>
        <xsl:choose>
	  <xsl:when test="$datafile != '!!nofile!!'">
	    <xsl:text>
except IOError:</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	      <xsl:text>
except (KeyError, TypeError):</xsl:text>
          </xsl:otherwise>
	</xsl:choose>
	<xsl:text>
    print "There is no Xgridfit dictionary for this font, but this script"
    print "requires one. Try first using Xgridfit's merge-mode to compile"
    print "an Xgridfit program containing functions, control-values and"
    print "pre-program, run that Python script, and then try this again."
    sys.exit(1)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pyAutoInstruct">
    <xsl:if test="$compile_globals='yes'">
      <xsl:text>
if AUTO_INSTR:
    # If autohint, we've already cleaned out the font. Autohint
    # those glyphs for which we do not have Xgridfit instructions
    # and populate the Xgridfit dictionary.
    for g in CURRENT_FONT.glyphs():
        if g.glyphname not in GLYPH_DICT:
            auto_instr_glyph(g.glyphname)
    extract_font_globals()
</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="pyFunctionDefs">
    <xsl:text>
def extract_font_globals():
    # Set up the private xgridfit dictionary, which stores the
    # original state of the font's programming. If we get a
    # chance, we'll store this in the sfd file.
    global MAXP_DICTIONARY
    XGRIDFIT_DICTIONARY['oprep'] = CURRENT_FONT.getTableData("prep")
    XGRIDFIT_DICTIONARY['ofunc'] = CURRENT_FONT.getTableData("fpgm")
    if XGRIDFIT_DICTIONARY['oprep'] == None:
        del XGRIDFIT_DICTIONARY['oprep']
    if XGRIDFIT_DICTIONARY['ofunc'] == None:
        del XGRIDFIT_DICTIONARY['ofunc']
    XGRIDFIT_DICTIONARY['omaxp'] = MAXP_DICTIONARY = dict()
    MAXP_DICTIONARY['fdefs'] = CURRENT_FONT.maxp_FDEFs
    MAXP_DICTIONARY['storage'] = CURRENT_FONT.maxp_storageCnt
    MAXP_DICTIONARY['twilight'] = CURRENT_FONT.maxp_twilightPtCnt
    MAXP_DICTIONARY['stack'] = CURRENT_FONT.maxp_maxStackDepth
def get_xgridfit_dictionary(dict_key):
    try:
        this_dict = XGRIDFIT_DICTIONARY[dict_key]
    except KeyError:
        XGRIDFIT_DICTIONARY[dict_key] = this_dict = dict()
    return this_dict
def find_cvt_value(val):
    if len(CURRENT_FONT.cvt) == 0:
        return(-1)
    else:
        return(CURRENT_FONT.cvt.find(val))
def install_cvt(name, value, index):
    try:
        index = int(index)
    except ValueError:
        pass
    tmpindex = -1
    try:
        tmpindex = CVT_DICTIONARY[name]
    except KeyError:
        if isinstance(index, int):
            if index &gt;= len(CURRENT_FONT.cvt):
                index = 'append'
            else:
                tmpindex = index
        if index == 'auto':
            tmpindex = find_cvt_value(value)
        if tmpindex &lt; 0:
            tmpindex = len(CURRENT_FONT.cvt)
            CURRENT_FONT.cvt += (value,)
        CVT_DICTIONARY[name] = tmpindex
    if CURRENT_FONT.cvt[tmpindex] != value:
        print "The value of control-value", name, "does not match that in the"
        print "control-value table in the FontForge file. Updating the value."
        print "old value: ", CURRENT_FONT.cvt[tmpindex]
        print "new value: ", value
        CURRENT_FONT.cvt[tmpindex] = value
def replace_from_dict(target_string, delimiter, dicty):
    for thiskey in dicty.keys():
        keystring = delimiter + thiskey + delimiter
        if target_string.find(keystring) >= 0:
            try:
                target_string = \
                    target_string.replace(keystring, str(dicty[thiskey]))
            except KeyError:
                print "Cannot resolve value ", thiskey, "."
                print "Have you run the script that would install functions"
                print "and control-values in this font?"
                sys.exit(1)
    return target_string
def replace_with_add(source, dea, deb, addn):
    while source.find(dea) >= 0:
        target = source[source.find(dea):source.find(deb) + 1]
        nums = target[1:len(target) - 1]
        source = source.replace(target, str(int(nums) + addn))
    return source
def make_push_string(push_list, push_type):
    push_string = "PUSH" + push_type
    if len(push_list) &lt;= 8:
        push_string = push_string + "_" + str(len(push_list))
    else:
        push_string = "N" + push_string + INST_NEWLINE + str(len(push_list))
    for num in push_list:
        push_string = push_string + INST_NEWLINE + str(num)
    return push_string
def fix_pushes(pstr):
    while pstr.find("push(") >= 0:
        op_start = pstr.find("push(")
        string_before = pstr[:op_start]
        string_after = pstr[op_start:]
        op_end = string_after.find(")")
        push_count = int(string_after[5:op_end])
        string_after = string_after[op_end+2:]
        push_type = "I"
        push_list = list()
        push_string = ""
        while push_count > 0:
            sep_loc = string_after.find(INST_NEWLINE)
            if (sep_loc >= 0):
                this_num = int(string_after[:sep_loc])
                string_after = string_after[sep_loc+1:]
            else:
                this_num = int(string_after)
                string_after = ""
            if (this_num >= 0 and this_num &lt;= 255):
                new_type = "B"
            else:
                new_type = "W"
            if push_type != new_type:
                if len(push_list) > 0:
                    push_string += \
                        make_push_string(push_list, push_type) + INST_NEWLINE
                    push_list = list()
                push_type = new_type
            push_list.append(this_num)
            push_count = push_count - 1
        if len(push_list) > 0:
            push_string += make_push_string(push_list, push_type)
        if not push_string.endswith(INST_NEWLINE):
            push_string += INST_NEWLINE
        pstr = string_before + push_string + string_after
    if pstr.endswith(INST_NEWLINE):
        pstr = pstr[:len(pstr)-1]
    return pstr
def legacy_twi_pts():
    try:
        return MAXP_DICTIONARY['twilight']
    except (KeyError, TypeError):
        return 0
def legacy_stack():
    try:
        return MAXP_DICTIONARY['stack']
    except (KeyError, TypeError):
        return 256
def legacy_storage():
    try:
        return MAXP_DICTIONARY['storage']
    except (KeyError, TypeError):
        return 0
def fix_instructions(instrs):
    return fix_pushes(replace_from_dict(replace_from_dict(\
        replace_with_add(instrs, "{", "}", legacy_storage()), \
        "%", XGRIDFIT_FUNCTION_NUMS), "^", CVT_DICTIONARY))
def auto_instr_glyph(name):
    if AUTO_HINT:
        CURRENT_FONT[name].autoHint()
    CURRENT_FONT[name].autoInstr()
def install_glyph_program(name, instrs):
    try:
        CURRENT_FONT[name].ttinstrs = \
            fontforge.parseTTInstrs(fix_instructions(instrs))
    except TypeError as detail:
        print "Warning: can't install instructions for glyph ", name
        print detail
    except ValueError as detail:
        print "Warning: can't install instructions for glyph ", name
        print detail
</xsl:text>
    <xsl:value-of select="$text-newline"/>
  </xsl:template>

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
    <xsl:text>import fontforge</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>import sys</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:if test="$datafile != '!!nofile!!'">
      <xsl:text>import pickle</xsl:text>
      <xsl:value-of select="$text-newline"/>
    </xsl:if>
    <xsl:value-of select="$py-start-message"/>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>INST_NEWLINE = "</xsl:text>
    <xsl:value-of select="$inst-newline"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>DELETE_ALL = </xsl:text>
    <xsl:choose>
      <xsl:when test="$delete_all='yes' and $compile_globals='yes'">
	<xsl:text>True</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>False</xsl:text>
	<xsl:if test="$delete_all='yes'">
	  <xsl:text>
# In merge-mode delete_all works only when compile_globals=yes</xsl:text>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>AUTO_INSTR = </xsl:text>
    <xsl:choose>
      <xsl:when test="$auto_instr='yes' and $compile_globals='yes'">
	<xsl:text>True</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>False</xsl:text>
	<xsl:if test="$auto_instr='yes'">
	  <xsl:text>
# In merge-mode auto_instr works only when compile_globals=yes</xsl:text>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>AUTO_HINT = </xsl:text>
    <xsl:choose>
      <xsl:when test="$auto-hint='yes'">
	<xsl:text>True</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>False</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>COMBINE_PREP = </xsl:text>
    <xsl:choose>
      <xsl:when test="$combine_prep='yes'">
	<xsl:text>True</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>False</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>XGF_DICT_ALTERED = False</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:call-template name="pyFunctionDefs"/>
    <xsl:call-template name="pyOpenFile"/>
    <xsl:call-template name="pyRetrieveFontInfo"/>
    <xsl:value-of select="$text-newline"/>
    <xsl:text># These are the instructions for the glyphs in this font.</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>GLYPH_DICT = {</xsl:text>
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
	<xsl:for-each select="xgf:glyph">
	  <xsl:if test="position() &gt; 1">
	    <xsl:text>, \</xsl:text>
	    <xsl:value-of select="$text-newline"/>
	  </xsl:if>
	  <xsl:apply-templates select="."/>
	</xsl:for-each>	
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}</xsl:text>
    <xsl:call-template name="pyAutoInstruct"/>
    <xsl:if test="$compile_globals='yes'">
      <xsl:text>CVT_DICTIONARY = get_xgridfit_dictionary('cvt')</xsl:text>
    </xsl:if>
    <xsl:value-of select="$text-newline"/>
    <xsl:if test="$compile_globals='yes'">
      <xsl:text>XGF_CVT = (</xsl:text>
      <xsl:for-each select="xgf:control-value">
	<xsl:if test="position() &gt; 1">
	  <xsl:text>,
</xsl:text>
	</xsl:if>
	<xsl:text>("</xsl:text>
	<xsl:value-of select="@name"/>
	<xsl:text>", </xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text>, "</xsl:text>
	<xsl:choose>
	  <xsl:when test="@index">
	    <xsl:value-of select="@index"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>auto</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:text>")</xsl:text>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
<xsl:text>
for n, v, f in XGF_CVT:
    install_cvt(n, v, f)
XGRIDFIT_DICTIONARY['cvt'] = CVT_DICTIONARY
</xsl:text>
      <!--
	  We need an fpgm table with our predefined functions even if
	  user has defined no functions.
      -->
      <xsl:text>XGF_FUNCTIONS = (("__fn0__","</xsl:text>
      <xsl:variable name="pf-a">
	<xsl:call-template name="function-zero"/>
      </xsl:variable>
      <xsl:value-of select="substring-after($pf-a,$leading-newline)"/>
      <xsl:text>"), ("__fn1__","</xsl:text>
      <xsl:variable name="pf-b">
	<xsl:call-template name="function-one"/>
      </xsl:variable>
      <xsl:value-of select="substring-after($pf-b,$leading-newline)"/>
      <xsl:text>"), ("__fn2__","</xsl:text>
      <xsl:variable name="pf-c">
	<xsl:call-template name="function-two"/>
      </xsl:variable>
      <xsl:value-of select="substring-after($pf-c,$leading-newline)"/>
      <xsl:text>"), ("__fn3__","</xsl:text>
      <xsl:variable name="pf-d">
	<xsl:call-template name="function-three"/>
      </xsl:variable>
      <xsl:value-of select="substring-after($pf-d,$leading-newline)"/>
      <xsl:text>")</xsl:text>
      <xsl:for-each select="$all-functions[not(@num) and not(xgf:variant)]">
	<xsl:variable name="fv">
	  <xsl:apply-templates select="."/>
	</xsl:variable>
	<xsl:text>, ("</xsl:text>
	<xsl:value-of select="./@name"/>
	<xsl:text>", "</xsl:text>
	<xsl:value-of select="substring-after($fv,$leading-newline)"/>
	<xsl:text>")</xsl:text>
      </xsl:for-each>
      <xsl:text>)
# functions with variants: we do not install them in fpgm
XGF_VAR_FUNCTIONS = </xsl:text>
      <xsl:choose>
	<xsl:when test="$all-functions[not(@num) and xgf:variant]">
	  <xsl:text>(</xsl:text>
	  <xsl:for-each select="$all-functions[not(@num) and xgf:variant]">
	    <xsl:text>("</xsl:text>
	    <xsl:value-of select="./@name"/>
	    <xsl:text>", "."), </xsl:text>
	  </xsl:for-each>
	  <xsl:text>)</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>None</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
<xsl:text>
# try to get legacy or auto-generated function code.
try:
    CURRENT_FUNCTION = MAXP_DICTIONARY['fdefs']
except KeyError:
    CURRENT_FUNCTION = 0
try:
    ALL_FUNCTION_CODE = fontforge.unParseTTInstrs(XGRIDFIT_DICTIONARY['ofunc'])
except KeyError:
    ALL_FUNCTION_CODE = ""
# Assign numbers to Xgridfit functions.
XGRIDFIT_FUNCTION_NUMS = dict()
for fname, finstrs in XGF_FUNCTIONS:
    XGRIDFIT_FUNCTION_NUMS[fname] = CURRENT_FUNCTION
    CURRENT_FUNCTION += 1
if XGF_VAR_FUNCTIONS != None:
    for fvname, fvinstrs in XGF_VAR_FUNCTIONS:
        XGRIDFIT_FUNCTION_NUMS[fvname] = CURRENT_FUNCTION
        CURRENT_FUNCTION += 1
# Done with populating XGRIDFIT_FUNCTION_NUMS dictionary. Keep it
# in Xgridfit dictionary.
XGRIDFIT_DICTIONARY['xgffunc'] = XGRIDFIT_FUNCTION_NUMS
# fix up and install the functions that go in the fpgm table.
for finame, fiinstrs in XGF_FUNCTIONS:
    if len(ALL_FUNCTION_CODE) == 0:
        ALL_FUNCTION_CODE = fix_instructions(fiinstrs)
    else:
        ALL_FUNCTION_CODE = ALL_FUNCTION_CODE + INST_NEWLINE + \
            fix_instructions(fiinstrs)
if len(ALL_FUNCTION_CODE) > 0:
    CURRENT_FONT.setTableData("fpgm", \
        fontforge.parseTTInstrs(ALL_FUNCTION_CODE))
CURRENT_FONT.maxp_FDEFs = CURRENT_FUNCTION
</xsl:text>
      <xsl:apply-templates select="xgf:pre-program"/>
<xsl:text>
# try to get legacy or auto-generated prep code.
try:
    OLD_PREP_CODE = fontforge.unParseTTInstrs(XGRIDFIT_DICTIONARY['oprep'])
except KeyError:
    OLD_PREP_CODE = ""
if COMBINE_PREP and (len(OLD_PREP_CODE) > 0):
    ALL_PREP_CODE = OLD_PREP_CODE + INST_NEWLINE + fix_instructions(XGF_PREP)
else:
    ALL_PREP_CODE = fix_instructions(XGF_PREP)
CURRENT_FONT.setTableData("prep", fontforge.parseTTInstrs(ALL_PREP_CODE))
</xsl:text>
    </xsl:if> <!-- end of "if compile_globals" -->
    <xsl:text>
# Install the Xgridfit glyph programs.</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>for ps_name, instrs in GLYPH_DICT.iteritems():</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:text>    install_glyph_program(ps_name, instrs)</xsl:text>
    <xsl:value-of select="$text-newline"/>
    <xsl:if test="$compile_globals='yes'">
      <xsl:text># Our maxp entries.</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <!-- maxTwilightPoints -->
      <xsl:text>if legacy_twi_pts() &gt; </xsl:text>
      <xsl:value-of select="$max_twilight_points"/>
      <xsl:text>:
    CURRENT_FONT.maxp_twilightPtCnt = legacy_twi_pts()
else:
    CURRENT_FONT.maxp_twilightPtCnt = </xsl:text>
      <xsl:value-of select="$max_twilight_points"/>
      <xsl:value-of select="$text-newline"/>
      <!-- maxStorage -->
      <xsl:text>CURRENT_FONT.maxp_storageCnt = </xsl:text>
      <xsl:choose>
	<xsl:when test="number($max_storage) &gt;= $global-variable-base + 1">
	  <xsl:value-of select="$max_storage"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$global-variable-base + 1"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text> + legacy_storage()</xsl:text>
      <xsl:value-of select="$text-newline"/>
      <!-- depth of stack -->
      <xsl:text>if legacy_stack() &gt; </xsl:text>
      <xsl:value-of select="$max_stack"/>
      <xsl:text>:
    CURRENT_FONT.maxp_maxStackDepth = legacy_stack()
else:
    CURRENT_FONT.maxp_maxStackDepth = </xsl:text>
      <xsl:value-of select="$max_stack"/>
      <xsl:value-of select="$text-newline"/>
    </xsl:if>
    <xsl:if test="$outfile != '!!nofile!!'">
      <xsl:variable name="o" select="normalize-space($outfile)"/>
      <xsl:variable name="ext" select="substring($o,string-length($o)-3)"/>
<!--
      <xsl:choose>
	<xsl:when test="$outfile_base = '!!nofile!!'">
-->
	  <xsl:call-template name="do-outfile">
	    <xsl:with-param name="o" select="$o"/>
	    <xsl:with-param name="ext" select="$ext"/>
	  </xsl:call-template>
<!--
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
-->
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-tuple">
    <xsl:param name="s"/>
    <xsl:param name="count" select="0"/>
    <xsl:param name="as-strings" select="false()"/>
    <xsl:variable name="qu">
      <xsl:choose>
	<xsl:when test="$as-strings">
	  <xsl:text>'</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="''"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sn" select="normalize-space($s)"/>
    <xsl:variable name="current-val">
      <xsl:choose>
	<xsl:when test="contains($sn,' ')">
	  <xsl:value-of select="substring-before($sn,' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$sn"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="remaining-vals">
      <xsl:choose>
	<xsl:when test="contains($sn,' ')">
	  <xsl:value-of select="substring-after($sn,' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="''"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$count = 0">
	<xsl:text>(</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$qu"/>
    <xsl:value-of select="$current-val"/>
    <xsl:value-of select="$qu"/>
    <xsl:choose>
      <xsl:when test="string-length($remaining-vals) = 0">
	<xsl:if test="$count = 0">
	  <xsl:text>,</xsl:text>
	</xsl:if>
	<xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="make-tuple">
	  <xsl:with-param name="s" select="$remaining-vals"/>
	  <xsl:with-param name="count" select="$count + 1"/>
	  <xsl:with-param name="as-strings" select="$as-strings"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make-flags-tuple">
    <xsl:param name="f"/>
    <xsl:call-template name="make-tuple">
      <xsl:with-param name="s" select="$f"/>
      <xsl:with-param name="as-strings" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="do-outfile">
    <xsl:param name="o"/>
    <xsl:param name="ext"/>
    <xsl:if test="$compile_globals='yes' and $datafile != '!!nofile!!'">
      <xsl:text>
if XGF_DICT_ALTERED:
    try:
        pickle.dump(XGRIDFIT_DICTIONARY, open('</xsl:text>
	<xsl:value-of select="$datafile"/>
	<xsl:text>', 'w'))
    except IOError:
        print "Couldn't write the data file!"</xsl:text>
	<xsl:value-of select="$text-newline"/>
    </xsl:if>
    <xsl:if test="not(string-length($o)) or $ext = '.sfd'">
      <xsl:if test="$compile_globals='yes' and $datafile = '!!nofile!!'">
	<xsl:text>
if XGF_DICT_ALTERED:
    try:
        CURRENT_FONT.persistent['xgridfit'] = XGRIDFIT_DICTIONARY
    except TypeError:
        print "Warning: font.persistent is not a dictionary, so I can't"
        print "store any data there. Names of control-values and the"
        print "font's original fpgm, prep and other data will be lost"
        print "after this run. To save this data in a separate file,"
        print "use the datafile element or the -F option."</xsl:text>
      </xsl:if>
      <xsl:value-of select="$text-newline"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not(string-length($o))">
	<xsl:text>CURRENT_FONT.save()</xsl:text>
      </xsl:when>
      <xsl:when test="$ext = '.sfd'">
	<xsl:text>CURRENT_FONT.save("</xsl:text>
	<xsl:value-of select="$o"/>
	<xsl:text>")</xsl:text>
      </xsl:when>
      <xsl:when test="$ext = '.ttf'">
	<xsl:text>CURRENT_FONT.generate("</xsl:text>
	<xsl:value-of select="$o"/>
	<xsl:text>"</xsl:text>
	<xsl:if test="/xgf:xgridfit/xgf:outfile/@pyflags">
	  <xsl:text>,flags=</xsl:text>
	  <xsl:call-template name="make-flags-tuple">
	    <xsl:with-param name="f" select="/xgf:xgridfit/xgf:outfile/@pyflags"/>
	  </xsl:call-template>
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
    <xsl:text>XGF_PREP = "</xsl:text>
    <xsl:variable name="current-inst">
      <xsl:call-template name="pre-program-instructions"/>
    </xsl:variable>
    <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
    <xsl:text>"</xsl:text>
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
    <!-- For making a dictionary -->
    <xsl:text>'</xsl:text>
    <xsl:value-of select="@ps-name"/>
    <xsl:text>': '</xsl:text>
    <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
    <xsl:text>'</xsl:text>
<!--
    <xsl:text>install_glyph_program("</xsl:text>
    <xsl:value-of select="@ps-name"/>
    <xsl:text>", "</xsl:text>
    <xsl:value-of select="substring-after($current-inst,$leading-newline)"/>
    <xsl:text>")</xsl:text>
-->
<!--    <xsl:value-of select="$text-newline"/> -->
  </xsl:template>

  <!-- The following elements are declarations, read only
       by this script and never converted to code. -->

  <xsl:template match="xgf:no-compile"></xsl:template>

</xsl:stylesheet>
