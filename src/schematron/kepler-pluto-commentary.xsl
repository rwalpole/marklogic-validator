<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:core="http://www.lexisnexis.com/namespace/sslrp/core"
                xmlns:fn="http://www.lexisnexis.com/namespace/sslrp/fn"
                xmlns:header="http://www.lexisnexis.com/namespace/sslrp/header"
                xmlns:lnb-leg="http://www.lexisnexis.com/namespace/sslrp/lnb-leg"
                xmlns:local="local-function"
                xmlns:se="http://www.lexisnexis.com/namespace/sslrp/se"
                xmlns:tr="http://www.lexisnexis.com/namespace/sslrp/tr"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


   <!--KEYS AND FUNCTIONS-->
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron"
                 name="local:get-xpath"
                 as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="xpath">  
            <xsl:for-each select="$node/ancestor-or-self::*">
                <xsl:variable name="name" select="name()"/>
                <xsl:variable name="position"
                          select="count(current()/preceding-sibling::*[name()=$name]) + 1"/>
                <xsl:value-of select="concat('/',$name,'[', $position ,']')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$xpath"/>
    </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron"
                 name="local:makeCopy"
                 as="xs:string">
        <xsl:param name="path"/>
        <xsl:copy-of select="$path"/>       
    </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron"
                 name="local:length-valid"
                 as="xs:boolean">
        <xsl:param name="sect-num"/>
        <xsl:param name="section"/>
        <xsl:variable name="sect-num-len">
            <xsl:choose>
                <xsl:when test="$sect-num">
                    <xsl:value-of select="string-length(replace($sect-num,'\[',''))"/>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="following-sect-num">
            <xsl:value-of select="$section/following-sibling::lnb-leg:provision[1]/core:desig[1]/@value/string()"/>
        </xsl:variable>
        <xsl:variable name="following-sect-num-len">
            <xsl:value-of select="string-length(replace($following-sect-num,'\[',''))"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="(($sect-num-len - 1) = $following-sect-num-len) and local:ends-with-pattern($sect-num,(                 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'))">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$sect-num-len &gt; $following-sect-num-len">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron"
                 name="local:ends-with-pattern"
                 as="xs:boolean">
        <xsl:param name="text"/>
        <xsl:param name="patterns"/>
        <xsl:variable name="result">
            <xsl:for-each select="$patterns">
                <xsl:value-of select="ends-with($text,.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="contains($result,'true')"/>
    </xsl:function>

   <!--DEFAULT RULES-->


   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.lexisnexis.com/namespace/sslrp/core" prefix="core"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.lexisnexis.com/namespace/sslrp/fn" prefix="fn"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.lexisnexis.com/namespace/sslrp/header" prefix="header"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.lexisnexis.com/namespace/sslrp/lnb-leg"
                                             prefix="lnb-leg"/>
         <svrl:ns-prefix-in-attribute-values uri="local-function" prefix="local"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.lexisnexis.com/namespace/sslrp/se" prefix="se"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.lexisnexis.com/namespace/sslrp/tr" prefix="tr"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">legislation-structure</xsl:attribute>
            <xsl:attribute name="name">legislation-structure</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">invalid-normcite</xsl:attribute>
            <xsl:attribute name="name">invalid-normcite</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">section-numbering</xsl:attribute>
            <xsl:attribute name="name">section-numbering</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">no-title</xsl:attribute>
            <xsl:attribute name="name">no-title</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">footnotes</xsl:attribute>
            <xsl:attribute name="name">footnotes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">bad-nesting</xsl:attribute>
            <xsl:attribute name="name">bad-nesting</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">invalid-content</xsl:attribute>
            <xsl:attribute name="name">invalid-content</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


   <!--PATTERN legislation-structure-->


	  <!--RULE -->
   <xsl:template match="lnb-leg:legislation/lnb-leg:*[self::lnb-leg:act or self::lnb-leg:si][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]"
                 priority="1001"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="lnb-leg:legislation/lnb-leg:*[self::lnb-leg:act or self::lnb-leg:si][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(header:metadata) &gt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(header:metadata) &gt;= 1">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: MISSING NORMCITE] <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> element must have a normcite <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(ancestor::lnb-leg:legislation) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ancestor::lnb-leg:legislation) = 1">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: NESTED LEGISLATION] <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> element is nested within more than one lnb-leg:legislation element</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="lnb-leg:main[parent::*/parent::lnb-leg:legislation][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]"
                 priority="1000"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="lnb-leg:main[parent::*/parent::lnb-leg:legislation][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(child::*[not(name()='lnb-leg:heading' or name()='lnb-leg:provision')])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(child::*[not(name()='lnb-leg:heading' or name()='lnb-leg:provision')])">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: INVALID STRUCTURE] lnb-leg:main should have no content other than 'lnb-leg:heading' or 'lnb-leg:provision'; 
                element found is '<xsl:text/>
                  <xsl:value-of select="name(child::*[not(name()='lnb-leg:heading' or name()='lnb-leg:provision')][1])"/>
                  <xsl:text/>'
                at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>                
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN invalid-normcite-->


	  <!--RULE -->
   <xsl:template match="lnb-leg:*[self::lnb-leg:act or self::lnb-leg:si][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]/header:metadata"
                 priority="1000"
                 mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="lnb-leg:*[self::lnb-leg:act or self::lnb-leg:si][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]/header:metadata"
                       role="error"/>
      <xsl:variable name="normcite"
                    select="header:metadata-item[@name='normcite'][1]/@value"/>
      <xsl:variable name="normcite-regex" select="'[0-9]{4}_[0-9a-z]{2,5}'"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches($normcite,$normcite-regex)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches($normcite,$normcite-regex)">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: INVALID NORMCITE] normcite value should match regular expression <xsl:text/>
                  <xsl:value-of select="$normcite-regex"/>
                  <xsl:text/> at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="header:metadata-item[@name='normcite']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="header:metadata-item[@name='normcite']">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: MISSING NORMCITE] there should be a normcite header:metadata-item at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN section-numbering-->


	  <!--RULE -->
   <xsl:template match="lnb-leg:*[self::lnb-leg:act or self::lnb-leg:si][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]//lnb-leg:provision[not(ancestor::lnb-leg:amending-text)][not(ancestor::core:comment)]"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="lnb-leg:*[self::lnb-leg:act or self::lnb-leg:si][not(ancestor::core:comment)][not(ancestor::fn:endnotes)][not(ancestor::se:sources)]//lnb-leg:provision[not(ancestor::lnb-leg:amending-text)][not(ancestor::core:comment)]"
                       role="error"/>
      <xsl:variable name="sect-num" select="core:desig[1]/@value/string()"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(parent::*/child::lnb-leg:provision[core:desig/@value = $sect-num]) &lt; 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(parent::*/child::lnb-leg:provision[core:desig/@value = $sect-num]) &lt; 2">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: DUPLICATE SECTION NUMBER] lnb-leg:provision should have a unique core:desig attribute value at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$sect-num!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$sect-num!=''">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: MISSING SECTION NUMBER] lnb-leg:provision should have a core:desig element with a non-empty value attribute at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(following-sibling::lnb-leg:provision) or (following-sibling::lnb-leg:provision and local:length-valid($sect-num, .))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(following-sibling::lnb-leg:provision) or (following-sibling::lnb-leg:provision and local:length-valid($sect-num, .))">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[WARNING: SECTION NUMBERING] core:desig value may be out of sequence at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(contains($sect-num,',')) and not(contains($sect-num,'-'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(contains($sect-num,',')) and not(contains($sect-num,'-'))">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[WARNING: SECTION NUMBERING] core:desig value may contain more than one number at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN no-title-->


	  <!--RULE -->
   <xsl:template match="tr:secmain" priority="1000" mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="tr:secmain"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="core:title[node()]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="core:title[node()]">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: NO TITLE] tr:secmain elements must have a core:title child with content at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="local:makeCopy(local:get-xpath(.))"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN footnotes-->


	  <!--RULE -->
   <xsl:template match="fn:endnote-id" priority="1001" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="fn:endnote-id"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="following::fn:endnote[(@ID = current()/@idref)                  or (normalize-space(@er)  !=''                  and translate(@er,' ()','')=translate(current()/@er,' ()','')                 )]                 (: DELETE BELOW IF FTK GIVES ERRORS :)                 or                  preceding::fn:endnote[(@ID = current()/@idref)                  or (normalize-space(@er)  !=''                  and translate(@er,' ()','')=translate(current()/@er,' ()','')                 )]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="following::fn:endnote[(@ID = current()/@idref) or (normalize-space(@er) !='' and translate(@er,' ()','')=translate(current()/@er,' ()','') )] (: DELETE BELOW IF FTK GIVES ERRORS :) or preceding::fn:endnote[(@ID = current()/@idref) or (normalize-space(@er) !='' and translate(@er,' ()','')=translate(current()/@er,' ()','') )]">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ERROR: MISSING ENDNOTE]
                endnote reference <xsl:text/>
                  <xsl:value-of select="@er"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="@idref"/>
                  <xsl:text/> without matching endnote  
                at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="fn:footnote-id" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="fn:footnote-id"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="following::fn:footnote[(@ID = current()/@idref)                  or (normalize-space(@fr)  !=''                  and translate(@fr,' ()','')=translate(current()/@fr,' ()','')                 )]                 or                  preceding::fn:footnote[(@ID and current()/@idref) or (@fr=current()/@fr)]                 "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="following::fn:footnote[(@ID = current()/@idref) or (normalize-space(@fr) !='' and translate(@fr,' ()','')=translate(current()/@fr,' ()','') )] or preceding::fn:footnote[(@ID and current()/@idref) or (@fr=current()/@fr)]">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ERROR: MISSING FOOTNOTE]
                footnote reference <xsl:text/>
                  <xsl:value-of select="@fr"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="@idref"/>
                  <xsl:text/> without matching footnote                 
                at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN bad-nesting-->


	  <!--RULE -->
   <xsl:template match="se:structure[@leveltype='secmain']"
                 priority="1002"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="se:structure[@leveltype='secmain']"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(se:structure[@leveltype='secmain'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(se:structure[@leveltype='secmain'])">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: INVALID STRUCTURE] se:structure[@leveltype='secmain'] must not have child se:structure[@leveltype='secmain']
                at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>                
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="se:structure[@leveltype='secsub1']"
                 priority="1001"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="se:structure[@leveltype='secsub1']"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(se:structure[@leveltype='secsub1'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(se:structure[@leveltype='secsub1'])">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: INVALID STRUCTURE] se:structure[@leveltype='secsub1'] must not have child se:structure[@leveltype='secsub1']
                at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>                
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="se:structure[@leveltype='secsub1']"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="se:structure[@leveltype='secsub1']"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(se:structure[@leveltype='secmain'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(se:structure[@leveltype='secmain'])">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: INVALID STRUCTURE] se:structure[@leveltype='secsub1'] must not have child se:structure[@leveltype='secmain']
                at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN invalid-content-->


	  <!--RULE -->
   <xsl:template match="lnb-leg:act|lnb-leg:si" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="lnb-leg:act|lnb-leg:si"
                       role="error"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(contains(@acronym,'&amp;'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(contains(@acronym,'&amp;'))">
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ERROR: INVALID CONTENT] acronym attribute value must not include ampersand at <xsl:text/>
                  <xsl:value-of select="local:get-xpath(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
</xsl:stylesheet>
