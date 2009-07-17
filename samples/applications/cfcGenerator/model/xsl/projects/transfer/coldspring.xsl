<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
		<xsl:template match="/">
&lt;?xml version="1.0" encoding="UTF-8"?&gt;

&lt;beans&gt;
	&lt;bean id="<xsl:value-of select="//bean/@name"/>Gateway" class="<xsl:value-of select="//bean/@path"/>Gateway"&gt;
		&lt;constructor-arg name="dsn"&gt;&lt;value&gt;${dsn}&lt;/value&gt;&lt;/constructor-arg&gt;
	&lt;/bean&gt;
	&lt;bean id="<xsl:value-of select="//bean/@name"/>Service" class="<xsl:value-of select="//bean/@path"/>Service"&gt;
		&lt;constructor-arg name="transfer"&gt;
			&lt;ref bean="transfer"/&gt;
		&lt;/constructor-arg&gt;
		&lt;constructor-arg name="<xsl:value-of select="//bean/@name"/>Gateway"&gt;
			&lt;ref bean="<xsl:value-of select="//bean/@name"/>Gateway"/&gt;
		&lt;/constructor-arg&gt;
	&lt;/bean&gt;
&lt;/beans&gt;</xsl:template>
</xsl:stylesheet>