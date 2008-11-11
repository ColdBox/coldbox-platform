<?xml version="1.0" encoding="UTF-8"?>
<!-- 
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Ernst van der Linden ( evdlinden@gmail.com | http://evdlinden.behindthe.net )
Date     :	08/09/2008
Description : Default properties of the SideBar. 
		
Modification History:
08/12/2008 evdlinden : isScroll property implemented. SideBar changed to ColdBoxSideBar: css, image
08/14/2008 evdlinden : imgPath,cssPAth and jsPath now in interceptor.
10/13/2008 evdlinden : added waitTimeBeforeOpen
-->
<Sidebar>
	<Properties>
			
			<!-- Enable, true/false -->
			<Property name="isEnabled">false</Property> 
			
			<!-- Y offset -->
			<Property name="yOffset">50</Property>

			<!-- Slide Speed -->
			<Property name="slideSpeed">15</Property>

			<!-- Wait Time Before Open -->
			<Property name="waitTimeBeforeOpen">0</Property>
						
			<!-- Wait Time Before Close -->
			<Property name="waitTimeBeforeClose">250</Property>

			<!-- Static -->
			<Property name="isScroll">false</Property>
			
			<!-- Links (JSON array of objects) -->
			<Property name="links">
				<![CDATA[
					[
					{"desc":"ColdBox API","href":"http:\/\/www.coldboxframework.com\/api\/"}
				    ,{"desc":"ColdBox SideBar Help","href":"http:\/\/ortus.svnrepository.com\/coldbox\/trac.cgi\/wiki\/cbSideBar"}
					,{"desc":"ColdBox Credits","href":"http:\/\/ortus.svnrepository.com\/coldbox\/trac.cgi\/wiki\/cbCredits"}
					]
				]]>
			</Property>
			
			<!-- Width of the sidebar including visible width -->
			<Property name="width">200</Property>
			
			<!-- Visible width  -->
			<Property name="visibleWidth">10</Property>
			
			<!-- Vertical alignment of the image: top,middle or bottom  -->
			<Property name="imageVAlign">middle</Property>
			
			<!-- includes directory: normally /coldbox/includes/coldboxsidebar/ -->
			<Property name="includesDirectory">/coldbox/system/includes/coldboxsidebar/</Property>
			
	</Properties>
</Sidebar>