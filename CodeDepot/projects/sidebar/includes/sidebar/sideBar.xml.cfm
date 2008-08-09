<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
Author 	 :	Ernst van der Linden
Date     :	08/09/2008
Description : Default properties of the SideBar. 
		
Modification History:
-->
<Sidebar>
	<Properties>
			
			<!-- Enable, true/false -->
			<Property name="isEnabled">true</Property> 
			
			<!-- Y offset -->
			<Property name="yOffset">100</Property>
			
			<!-- Links (JSON array of objects) -->
			<Property name="links">
				<![CDATA[
					[
					{"desc":"ColdBox Live Docs","href":"http:\/\/ortus.svnrepository.com\/coldbox\/trac.cgi"}
					,{"desc":"ColdBox API","href":"http:\/\/www.coldboxframework.com\/api\/"}
					,{"desc":"ColdBox Forums","href":"http:\/\/groups.google.com\/group\/coldbox"}
					,{"desc":"My API","href":"http:\/\/localhost\/myApi/"}
					,{"desc":"My Database Schema","href":"http:\/\/localhost\/myDatabaseSchema.pdf"}
					,{"desc":"My Batch File","href":"C:\/\/Batch Files\/myBatch.bat"}
					,{"desc":"My Program","href":"C:\/\/Program Files\/My Program.exe"}
					]
				]]>
			</Property>
			
			<!-- Width of the sidebar including visible width -->
			<Property name="width">200</Property>
			
			<!-- Visible width  -->
			<Property name="visibleWidth">12</Property>
			
			<!--Full path from the application's root. -->
			<Property name="imagePath">includes/sideBar/sideBar.png</Property>
			
			<!-- Vertical alignment of the image: top,middle or bottom  -->
			<Property name="imageVAlign">middle</Property>
			
			<!--Full path from the application's root -->
			<Property name="cssPath">includes/sidebar/sideBar.css</Property>

	</Properties>
</Sidebar>