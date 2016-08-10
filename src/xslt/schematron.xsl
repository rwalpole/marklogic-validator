<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:lnb-leg="http://www.lexisnexis.com/namespace/sslrp/lnb-leg" exclude-result-prefixes="xs" version="3.0">
    <xsl:param name="collection"/>
    <xsl:template match="/reports">
        <html>
            <head>
                <title>
                    <xsl:value-of select="'Schematron Report'"/>
                </title>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"/>
                <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
            </head>
            <body>
                <div class="container">
                    <h1>
                        <xsl:value-of select="'Schematron Report'"/>
                    </h1>
                    <p><strong><xsl:value-of select="concat('Collection: ',$collection)"/></strong></p>
                    <xsl:apply-templates/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="report">
        <xsl:variable name="doc" select="@doc/string()"/>
        <xsl:choose>
            <xsl:when test="svrl:schematron-output/svrl:failed-assert">
                <div class="alert alert-warning">
                    <xsl:value-of select="concat('Filename: ',tokenize($doc,'/')[last()])"/>
                    <ul class="list-group">
                        <xsl:for-each select="svrl:schematron-output/svrl:failed-assert">
                            <xsl:variable name="type" select="@role"/>
                            <xsl:variable name="location" select="@location/string()"/>
                            <li class="{concat('list-group-item list-group-item-',if($type='error')then('danger')else('warning'))}">
                                <a href="{concat('default.xqy?doc=',$doc,'&amp;xpath=',$location)}">
                                    <xsl:value-of select="svrl:text"/>
                                </a>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="alert alert-success">
                    <xsl:value-of select="concat('Filename: ',tokenize($doc,'/')[last()])"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>