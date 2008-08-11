<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- 
Author 	 :	Ernst van der Linden (evdlinden@gmail.com)
Date     :	08/09/2008
Description : Default properties of the SideBar. 
		
Modification History:
-->
<Sidebar>
	<Properties>
			
			<!-- Enable, true/false -->
			<Property name="isEnabled">false</Property> 
			
			<!-- Y offset -->
			<Property name="yOffset">50</Property>
			
			<!-- Links (JSON array of objects) -->
			<Property name="links">
				<![CDATA[
					[
					{"desc":"ColdBox API","href":"http:\/\/www.coldboxframework.com\/api\/"}
					,{"desc":"ColdBox Credits","href":"http:\/\/ortus.svnrepository.com\/coldbox\/trac.cgi\/wiki\/cbCredits"}
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