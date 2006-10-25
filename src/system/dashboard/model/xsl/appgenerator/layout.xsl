<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" indent="no"  />
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
                <title>Welcome to Coldbox!!</title>
            </head>
            <body>
                &lt;!--- Render The View. This is set wherever you want to render the view in your Layout. ---&gt;
                <cfoutput>#renderView()#</cfoutput>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
