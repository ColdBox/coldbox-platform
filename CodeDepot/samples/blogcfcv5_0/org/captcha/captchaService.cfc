<!---
Copyright: (c) 2006 Maestro Publishing - Peter J. Farrell
Author: Peter J. Farrell (pjf@maestropublishing.com)
Package: Lyla Captcha - http://lyla.maestropublishing.com
Based On the Work Of: Mark Mandel (mark@compoundtheory.com) - http://www.compoundtheory.com
Version: 0.1 Alpha
License:
	(c) 2006 Maestro Publishing - Peter J. Farrell
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at 
	
	http://www.apache.org/licenses/LICENSE-2.0 
	
	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
	
	This software MAY consist of voluntary contributions made by other individuals.

Other Restrictions In Addition to the Apache 2.0 License:
	- The "LylaCaptcha" attribution text must be displayed in the generated Captcha 
	image. Please do not comment out or otherwise change the the source code to 
	defeat this request.
	- You may distribute Lyla Captcha within/embedded your application.
	- Please to not sell the Lyla Captcha package by itself as this against the
	spirit of this open source project.

$Id$

N.B.:
**********************************************************************************
* This license may differ from the license of the program that uses LylaCaptcha. *
**********************************************************************************

Shameless Begging:
	If LylaCaptcha proves to be a useful captcha for you, please consider gifting me 
	something on my Amazon Wishlist: http://www.amazon.com/gp/registry/2NDKJIPDUYE9W
	
	Or you may make a donation with PayPal: pjf@maestropublishing.com
	
	Your generosity is greatly appreciated and thank you for supporting Open Source 
	Software authors.
--->
<cfcomponent
	displayname="captchaService"
	output="false"
	hint="Performs captcha functionality.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="captchaService" output="false"
		hint="Initializes the service.">
		<cfargument name="configBean" type="captchaServiceConfigBean" required="false"
			default="#CreateObject("component", "captchaServiceConfigBean").init()#" />
		<cfargument name="configFile" type="string" required="false"
			default="" />
		
		<!--- Set arguments --->
		<cfset setConfigBean(arguments.configBean) />
		<cfif Len(arguments.configFile)>
			<cfset setConfigFile(arguments.configFile) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setup" access="public" returntype="void" output="false"
		hint="Setups the service after dependencies have been injected.">

		<!--- Load the XML if configFile is not NULL --->
		<cfif Len(getConfigFile())>
			<cfset loadXML() />
		</cfif>

		<!--- Setup the hash reference cache --->
		<cfset  setupHashReferenceCache() />

		<!--- Setup the salt --->
		<cfset setupSalt() />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS - GENERAL
	--->
	<cffunction name="createHashReference" access="public" returntype="struct" output="false"
		hint="Creates a hash reference in the service and returns the results.">
		<cfargument name="text" type="string" required="false" default="#getRandString()#"
			hint="Text to create Captcha with. Defaults random string as defined in config file." />
		
		<cfset var results = StructNew() />

		<!--- Create the results struct --->
		<cfset results.type = "hash" />
		<cfset results.text = arguments.text />
		<cfset results.hash = getHash(arguments.text) />
		<cfset results.width = getConfigBean().getWidth() />
		<cfset results.height = getConfigBean().getHeight() />
		
		<!--- Set the hash reference to the cache --->
		<cfset setHashReference(results.hash, results.text) />

		<cfreturn results />		
	</cffunction>

	<cffunction name="createCaptchaFromHashReference" access="public" returntype="struct" output="false"
		hint="Creates a captcha to the desired from a hash reference.">
		<cfargument name="type" type="string" required="true"
			hint="Captcah output type. Accepts file or stream." />
		<cfargument name="hash" type="string" required="true"
			hint="Hash reference to retrieve from cache." />
		<cfreturn createCaptcha(arguments.type, getHashReference(arguments.hash)) />		
	</cffunction>

	<cffunction name="createCaptcha" access="public" returntype="struct" output="false"
		hint="Creates a captcha to the desired stream.">
		<cfargument name="type" type="string" required="true"
			hint="Captcah output type. Accepts file or stream." />
		<cfargument name="text" type="string" required="false" default="#getRandString()#"
			hint="Text to create Captcha with. Defaults random string as defined in config file." />

		<cfset var stream = "" />
		<cfset var results = StructNew() />
		<cfset var tempFileLocation = "" />

		<cfset results.text = arguments.text />
		<cfset results.hash = getHash(arguments.text) />
		<cfset results.width = getConfigBean().getWidth() />
		<cfset results.height = getConfigBean().getHeight() />

		<!--- Create the results struct --->
		<cfif arguments.type IS "stream">
			<cfset stream = createObject("java", "java.io.ByteArrayOutputStream").init() />
			<cfset results.type = "stream" />
		<cfelseif arguments.type IS "file">
			<cfset tempFileLocation = getFileLocation() />
			<cfset stream = createObject("java", "java.io.FileOutputStream").init(tempFileLocation) />
			<cfset results.type = "file" />
			<cfset results.fileLocation = tempFileLocation />
			<cfset results.fileDirectory = GetDirectoryFromPath(tempFileLocation) />
			<cfset results.fileName = GetFileFromPath(tempFileLocation) />
		<cfelse>
			<cfthrow type="captchaService.invalidType"
				message="The argument type must be stream or file."
				detail="Passed type=#arguments.type#" />
		</cfif>
		
		<!--- Write the captcha with the selected stream --->
		<cfset writeToStream(stream, arguments.text) />

		<cfif arguments.type IS "stream">
			<cfset results.stream = stream.toByteArray() />
		<cfelseif arguments.type IS "file">
			<cfset stream.flush() />
			<cfset stream.close() />
		</cfif>
		
		<cfreturn results />
	</cffunction>

	<cffunction name="validateCaptcha" access="public" returntype="boolean" output="false"
		hint="Validates a captcha by hash and user response text.">
		<cfargument name="hash" type="string" required="true" />
		<cfargument name="text" type="string" required="true" />
		<cfreturn NOT Compare(arguments.hash, getHash(arguments.text)) />
	</cffunction>
		
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getAvailableFontNames" access="public" returntype="array" output="false"
		hint="Returns an array of all available system fonts. This is useful when deciding on fonts to use for captcha configuration.">
		<cfset var allFonts = CreateObject("java", "java.awt.GraphicsEnvironment").getLocalGraphicsEnvironment().getAllFonts() />
		<cfset var fontArray = ArrayNew(1) />
		<cfset var i = "" />
				
		<cfloop from="1" to="#ArrayLen(allFonts)#" index="i">
			<cfset ArrayAppend(fontArray, allFonts[i].getName()) />
		</cfloop>

		<cfreturn fontArray />
	</cffunction>
	
	<!---
	PROTECTED FUNCTIONS - GENERAL
	--->
	<cffunction name="writeToStream" access="private" returntype="void" output="false"
		hint="Writes a captcha to an outputStream.">
		<cfargument name="outputStream" type="any" required="true" />
		<cfargument name="text" type="string" required="true" />

		<cfset var i = "" />
		<cfset var characters = arguments.text.toCharArray() />
		<cfset var charactersArrayLen = ArrayLen(characters) />
		<cfset var top = getConfigBean().getHeight() / 3 />
		<cfset var left = (RandRange(50, 125) / 100) * getConfigBean().getLeftOffset() />
		<cfset var definedFonts = getConfigBean().getDefinedFonts() />	
		<cfset var char = "" />

		<!--- Create utils --->
		<cfset var staticCollections = createObject("java", "java.util.Collections") />

		<!--- Create basic graphic objects --->
		<cfset var dimension = CreateObject("java", "java.awt.Dimension").init(getConfigBean().getWidth(), getConfigBean().getHeight()) />
		<cfset var imageType = CreateObject("java", "java.awt.image.BufferedImage").TYPE_INT_RGB />
		<cfset var bufferedImage = CreateObject("java", "java.awt.image.BufferedImage").init(JavaCast("int", dimension.getWidth()), JavaCast("int", dimension.getHeight()), imageType) />
		<cfset var renderingHints = CreateObject("java", "java.awt.RenderingHints") />
		<cfset var graphics = bufferedImage.createGraphics() />

		<!--- Set anti-alias setting --->
		<cfif getConfigBean().getUseAntiAlias()>
			<cfset graphics.setRenderingHint(renderingHints.KEY_ANTIALIASING, renderingHints.VALUE_ANTIALIAS_ON) />
		</cfif>

		<!--- If text exists --->
		<cfif charactersArrayLen>
			<!--- Draw background --->
			<cfset drawBackground(graphics, dimension) />
	
			<!--- Draw background ovals --->
			<cfif getConfigBean().getUseOvals()>
				<cfloop from="1" to="#RandRange(getConfigBean().getMinOvals(), getConfigBean().getMaxOvals())#" index="i">
					<cfset drawRandomOval(graphics, dimension, getConfigBean().getOvalColor()) />
				</cfloop>
			</cfif>
	
			<!--- Draw background lines --->
			<cfif getConfigBean().getUseBackgroundLines()>
				<cfloop from="1" to="#RandRange(getConfigBean().getBackgroundMinLines(), getConfigBean().getBackgroundMaxLines())#" index="i">
					<cfset drawRandomLine(graphics, dimension, getConfigBean().getBackgroundLineColor()) />
				</cfloop>
			</cfif>

			<!--- Draw captcha text --->
			<cfloop from="1" to="#charactersArrayLen#" index="i">
				<!--- Get text character to draw --->
				<cfset char = characters[i] />
				
				<cfset staticCollections.shuffle(definedFonts) />
				
				<cfset setFont(graphics, definedFonts) />
				<cfset graphics.setColor(getColorByType(getConfigBean().getFontColor())) />
			
				<!--- Check if font can display current character --->
				<cfloop condition="NOT graphics.getFont().canDisplay(char)">
					<cfset setFont(graphics, definedFonts) />			
				</cfloop>
				
				<!--- Compute the top character position --->
				<cfset top = RandRange(graphics.getFontMetrics().getAscent(), getConfigBean().getHeight() - ((getConfigBean().getHeight() - graphics.getFontMetrics().getHeight()) / 2)) />
				
				<!--- Draw character text --->
				<cfset graphics.drawString(JavaCast("string", char), JavaCast("int", left), JavaCast("int", top)) />
				
				<!--- Compute the next character lef tposition --->
				<cfset left = left + ((RandRange(150, 200) / 100) * graphics.getFontMetrics().charWidth(char)) />
			</cfloop>

			<!--- Draw foreground lines --->
			<cfif getConfigBean().getUseForegroundLines()>
				<cfloop from="1" to="#RandRange(getConfigBean().getForegroundMinLines(), getConfigBean().getForegroundMaxLines())#" index="i">
					<cfset drawRandomLine(graphics, dimension, getConfigBean().getForegroundLineColor()) />
				</cfloop>
			</cfif>

		<cfelse>
			<!--- If no texts exists, then write "Captcha Not Available" text --->
			<cfset staticCollections.shuffle(definedFonts) />
			<cfset graphics.setFont(definedFonts[1].deriveFont(JavaCast("float", 18))) />
			<cfset graphics.setColor(getColorByType(getConfigBean().getFontColor())) />
			<cfset graphics.drawString(JavaCast("string", "Captcha Not Available"), JavaCast("int", left), JavaCast("int", top)) >
		</cfif>

		<!--- Draw attribution (please do not removed or comment out this code per the additional license restrictions) --->
		<cfset staticCollections.shuffle(definedFonts) />
		<cfset graphics.setFont(definedFonts[1].deriveFont(JavaCast("float", 10))) />
		<cfset graphics.setColor(getColorByType(getConfigBean().getBackgroundColor())) />
		<cfset top = getConfigBean().getHeight() - 4 />
		<cfset graphics.drawString(JavaCast("string", "LylaCaptcha"), JavaCast("int", 4), JavaCast("int", top)) />

		<!--- Encode the captcha into an image based on the output stream --->
		<cfset encodeImage(arguments.outputStream, bufferedImage) />
	</cffunction>
	
	<cffunction name="encodeImage" access="private" returntype="void" output="false"
		hint="Encodes a buffered image to the desired output stream.">
		<cfargument name="outputStream" type="any" required="true"
			hint="The output stream." />
		<cfargument name="bufferedImage" type="any" required="true"
			hint="The buffered image." />

		<!--- Create an encoder and get the default encoder params --->
		<cfset var encoder = createObject("java", "com.sun.image.codec.jpeg.JPEGCodec").createJPEGEncoder(arguments.outputstream) />
	 	<cfset var encoderParam = encoder.getDefaultJPEGEncodeParam(arguments.bufferedImage) />

		<!--- Set the quality of the jpeg --->
	 	<cfset encoderParam.setQuality(JavaCast("float", getConfigBean().getJpegQuality()), getConfigBean().getJpegUseBaseline()) />
	    <cfset encoder.setJPEGEncodeParam(encoderParam) />
	    
	    <!--- Encode the bufference image --->
	    <cfset encoder.encode(arguments.bufferedImage) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - DRAW
	--->
	<cffunction name="drawBackground" access="private" returntype="void" output="false"
		hint="Draws a background.">
		<cfargument name="graphics" type="any" required="true"
			hint="The graphics." />
		<cfargument name="dimension" type="any" required="true"
			hint="The dimension object." />

		<cfset var startColor = getColorByType(getConfigBean().getBackgroundColor()) />
		<cfset var endColor =  getColorByType(getConfigBean().getBackgroundColor()) />
		<cfset var gradientPaint = "" />
		<cfset var background = "" />
		
		<cfif getConfigBean().getUseGradientBackground()>
			<cfset gradientPaint = CreateObject("java", "java.awt.GradientPaint").init(getRandomPointOnBorder(arguments.dimension), 
																					startColor, 
																					getRandomPointOnBorder(arguments.dimension),  
																					endColor.brighter(), 
																					getConfigBean().getBackgroundColorUseCyclic()) />
			<cfset arguments.graphics.setPaint(gradientPaint) />
		<cfelse>
			<cfset arguments.graphics.setColor(startColor) />
		</cfif>

		<cfset background = CreateObject("java", "java.awt.Rectangle").init(dimension) />
		<cfset arguments.graphics.fill(background) />
	</cffunction>

	<cffunction name="drawRandomLine" access="private" returntype="void" output="false"
		hint="Draws a random line.">
		<cfargument name="graphics" type="any" required="true"
			hint="The graphics." />
		<cfargument name="dimension" type="any" required="true"
			hint="The dimension object." />
		<cfargument name="lineColorType" type="any" required="true"
			hint="The dimension object." />

		<cfset var point1 = getRandomPointOnBorder(arguments.dimension) />
		<cfset var point2 = getRandomPointOnBorder(arguments.dimension) />
		
		<cfset arguments.graphics.setStroke(getRandomStroke()) />	
		<cfset arguments.graphics.setColor(getColorByType(arguments.lineColorType, getConfigBean().getBackgroundLineUseTransparency())) />
			
		<cfset arguments.graphics.drawLine(
				JavaCast("int", point1.getX()), 
				JavaCast("int", point1.getY()), 
				JavaCast("int", point2.getX()), 
				JavaCast("int", point2.getY())) />
	</cffunction>
	
	<cffunction name="drawRandomOval" access="private" returntype="void" output="false"
		hint="Draws a random oval.">
		<cfargument name="graphics" type="any" required="true"
			hint="The graphics." />
		<cfargument name="dimension" type="any" required="true"
			hint="The dimension object." />
		<cfargument name="ovalColorType" type="any" required="true"
			hint="The dimension object." />
		
		<cfset var point = getRandomPoint(arguments.dimension) />
		<cfset var height = arguments.dimension.getHeight() />
		<cfset var width = arguments.dimension.getWidth() />
		<cfset var minOval =  height * .10 />
		<cfset var maxOval =  height * .75 />
		<cfset var choice = RandRange(1, 3) />
		
		<cfset arguments.graphics.setColor(getColorByType(arguments.ovalColorType, getConfigBean().getOvalUseTransparency())) />
		
		<cfswitch expression="#choice#">
			<cfcase value="1">
				<cfset arguments.graphics.setStroke(getRandomStroke()) />
				<cfset arguments.graphics.drawOval(
						JavaCast("int", point.getX()), 
						JavaCast("int", point.getY()), 
						JavaCast("int", RandRange(minOval, maxOval)), 
						JavaCast("int", RandRange(minOval, maxOval))) />
			</cfcase>
			<cfcase value="2,3">
				<cfset arguments.graphics.fillOval(
						JavaCast("int", point.getX()), 
						JavaCast("int", point.getY()), 
						JavaCast("int", RandRange(minOval, maxOval)), 
						JavaCast("int", RandRange(minOval, maxOval))) />
			</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getRandomPointOnBorder" access="private" returntype="any" output="false"
		hint="Gets a random java.awt.Point on the border.">
		<cfargument name="dimension" type="any" required="true"
			hint="The dimension object.">

		<cfset var point = CreateObject("java", "java.awt.Point") />
		<cfset var height = Javacast("int", arguments.dimension.getHeight()) />
		<cfset var width = JavaCast("int", arguments.dimension.getWidth()) />
		<cfset var choice = RandRange(1, 4) />

		<cfswitch expression="#choice#">
			<!--- left side --->
			<cfcase value="1">
				<cfset point.setLocation(JavaCast("int", 0), JavaCast("int", RandRange(0, height))) />
			</cfcase>
			<!--- right side --->
			<cfcase value="2">
				<cfset point.setLocation(width, RandRange(0, height)) />
			</cfcase>
			<!--- top side --->
			<cfcase value="3">
				<cfset point.setLocation(JavaCast("int", RandRange(0, width)), JavaCast("int", 0)) />
			</cfcase>
			<!--- bottom side --->
			<cfcase value="4">
				<cfset point.setLocation(RandRange(0, width), height) />
			</cfcase>
		</cfswitch>
			
		<cfreturn point />
	</cffunction>

	<cffunction name="getRandomPoint" access="private" returntype="any" output="false"
		hint="Gets a random java.awt.Point in within the dimensions.">
		<cfargument name="dimension" type="any" required="true"
			hint="The dimension object.">

		<cfset var point = CreateObject("java", "java.awt.Point") />
		<cfset var height = Javacast("int", arguments.dimension.getHeight()) />
		<cfset var width = JavaCast("int", arguments.dimension.getWidth()) />

		<cfset point.setLocation(JavaCast("int", RandRange(0, width)), JavaCast("int", RandRange(0, height))) />
			
		<cfreturn point />
	</cffunction>	

	<cffunction name="getRandomTransformation" access="private" returntype="any" output="false"
		hint="Gets a random transformation.">
		<cfargument name="shearXRange" type="numeric" required="true"
			hint="The shear x range." />
		<cfargument name="shearYRange" type="numeric" required="true"
			hint="The shear y range." />

		<!--- create a slightly random affine transform --->
		<cfset var transformation = CreateObject("java", "java.awt.geom.AffineTransform").init() />
		<cfset var shearX = RandRange(-1 * (arguments.shearXRange * (RandRange(50, 150) / 100)), (arguments.shearXRange* (RandRange(50, 150) / 100))) / 100 />
		<cfset var shearY = RandRange(-1 * (arguments.shearYRange * (RandRange(50, 150) / 100)), (arguments.shearYRange * (RandRange(50, 150) / 100))) / 100 />
		
		<cfset transformation.shear(shearX, shearY) />
			
		<cfreturn transformation />
	</cffunction>

	<cffunction name="getRandomStroke" access="private" returntype="any" output="false"
		hint="Gets a random stroke.">
		<cfreturn CreateObject("java", "java.awt.BasicStroke").init(JavaCast("float", RandRange(1, 3))) />
	</cffunction>

	<cffunction name="setFont" access="private" returntype="void" output="false"
		hint="Sets a new font in the graphics lib.">
		<cfargument name="graphics" type="any" required="true"
			hint="The graphics." />
		<cfargument name="fontCollection" type="any" required="true"
			hint="The current font collection." />
		
		<cfset var font = "" />
		<cfset var fontSize = Fix((RandRange(80, 120) / 100) * getConfigBean().getFontSize()) />
		<cfset var staticCollections = createObject("java", "java.util.Collections") />					
		<cfset var trans1 = getRandomTransformation(getConfigBean().getShearXRange(), getConfigBean().getShearYRange()) />
		<cfset var trans2 = getRandomTransformation(getConfigBean().getShearXRange(), getConfigBean().getShearYRange()) />
		
		<cfset staticCollections.rotate(arguments.fontCollection, 1) />
		
		<!--- apply transform , just for fun --->
		<cfset font = arguments.fontCollection[1].deriveFont(JavaCast("float", fontSize)).deriveFont(trans1).deriveFont(trans2) />
		
		<cfset arguments.graphics.setFont(font) />
	</cffunction>

	<cffunction name="getColorByType" access="private" returntype="any" output="false"
		hint="Get a color by type name.">
		<cfargument name="colorType" type="string" required="true">
		<cfargument name="useTransparency" type="boolean" required="false" default="false" />
		
		<cfset var shade1 = "" />
		<cfset var shade2 = "" />
		<cfset var shade3 = "" />
		<cfset var alpha = 255 />
		
		<!--- Flag for transparency --->
		<cfif arguments.UseTransparency>
			<cfset alpha = RandRange(25, 255) />
		</cfif>

		<cfswitch expression="#arguments.colorType#">
			<cfcase value="light">
				<cfset shade1 = JavaCast("int", RandRange(170, 255)) />
				<cfset shade2 = JavaCast("int", RandRange(170, 255)) />
				<cfset shade3 = JavaCast("int", RandRange(170, 255)) />
			</cfcase>
			<cfcase value="medium">
				<cfset shade1 = JavaCast("int", RandRange(85, 170)) />
				<cfset shade2 = JavaCast("int", RandRange(85, 170)) />
				<cfset shade3 = JavaCast("int", RandRange(85, 170)) />
			</cfcase>
			<cfcase value="dark">
				<cfset shade1 = JavaCast("int", RandRange(0, 85)) />
				<cfset shade2 = JavaCast("int", RandRange(0, 85)) />
				<cfset shade3 = JavaCast("int", RandRange(0, 85)) />
			</cfcase>	
			<cfcase value="lightGray">
				<cfset shade1 = JavaCast("int", RandRange(170, 255)) />
				<cfset shade2 = shade1 />
				<cfset shade3 = shade1 />
			</cfcase>
			<cfcase value="mediumGray">
				<cfset shade1 = JavaCast("int", RandRange(85, 170)) />
				<cfset shade2 = shade1 />
				<cfset shade3 = shade1 />
			</cfcase>
			<cfcase value="darkGray">
				<cfset shade1 = JavaCast("int", RandRange(0, 85)) />
				<cfset shade2 = shade1 />
				<cfset shade3 = shade1 />
			</cfcase>
			<cfdefaultcase>
				<cfthrow type="captchaService.invalidColorType"
					message="The chosen color type is invalid. Please select from light, medium, dark, lightGray, mediumGray or darkGray."
					detail="Passed colorType=#arguments.colorType#" />
			</cfdefaultcase>
		</cfswitch>
			
		<cfreturn CreateObject("java", "java.awt.Color").init(shade1, shade2, shade3, JavaCast("int", alpha)) />
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - UTILS
	--->
	<cffunction name="loadXML" access="private" returntype="void" output="false"
		hint="Loads the config file.<br/>
		Throws: captchaService.cannotFindConfigFile if provider cannot find the config file.<br/>
				captchaService.notXML if the config file is not an XML file.">
		<cfset var configFile = "" />
		<cfset var rawXML = "" />
		<cfset var nodes = "" />
		<cfset var i = "" />
		<cfset var tempName = "" />
		<cfset var configNodes = StructNew() />
		<cfset var fontNodes = StructNew() />
		<cfset var fontArray = ArrayNew(1) />
		<cfset var allFontNames = getAvailableFontNames() />
		<cfset var allFonts = createObject("java", "java.awt.GraphicsEnvironment").getLocalGraphicsEnvironment().getAllFonts() />
		<cfset var definedFonts = ArrayNew(1) />
		<cfset var location = "" />
		<cfset var memento = StructNew() />

		<!--- Read the xml file --->
		<cftry>
			<cffile
				action="READ"
				file="#getConfigFile()#"
				variable="configFile" />
			<cfcatch type="application">
				<cfthrow
					type="captchaService.cannotFindConfigFile"
					message="Cannot find the config file."
					detail="configFile=#getConfigFile()#">
			</cfcatch>
		</cftry>

		<!--- Parse the xml file --->
		<cfset rawXML = XmlParse(configFile) />
		<!--- Commented out by Raymond till Peter releases a cfmx6 compat version
		<cfif NOT IsXML(rawXML)>
			<cfthrow
				type="captchaService.notXML"
				message="The config file is not an XML file."/>
		</cfif>
		--->
		<!--- Search for the configs --->
		<cfset configNodes = XMLSearch(rawXML, "//captcha/configs/config/") />
		
		<cfloop from="1" to="#ArrayLen(configNodes)#" index="i">
			<cfset memento[configNodes[i].XmlAttributes['name']] = configNodes[i].XmlAttributes['value'] />
		</cfloop>
		
		<!--- Search for the fonts --->
		<cfset fontNodes = XMLSearch(rawXML, "//captcha/fonts/font/") />
		
		<cfloop from="1" to="#ArrayLen(fontNodes)#" index="i">
			<cfif fontNodes[i].XmlAttributes['use']>
				<!--- Get the font name --->
				<cfset tempName = fontNodes[i].XmlAttributes['name'] />

				<!--- Get array node of desired font --->
				<cfset location = arrayFind(allFontNames, tempName) />
				
				<!--- Use the font if it is available on the system --->
				<cfif location>
					<cfset ArrayAppend(definedFonts, allFonts[location]) />
				</cfif>
			</cfif>
		</cfloop>

		<!--- Set defined fonts --->
		<cfset memento.definedFonts = definedFonts />
		
		<!--- Set the memento to the config bean --->
		<cfset getConfigBean().setMemento(memento) />
	</cffunction>

	<cffunction name="getRandString" access="private" returntype="string" output="false"
		hint="Gets a random string based on the configuration.">
		<cfreturn randString(getConfigBean().getRandStrType(), RandRange((getConfigBean().getRandStrLen() - 1), (getConfigBean().getRandStrLen() + 1))) />
	</cffunction>
	
	<cffunction name="getFileLocation" access="private" returntype="string" output="false"
		hint="Gets a file location.">
		<cfset var fileName = CreateUUID() & ".jpg" />
		<cfset var fileLocation = "" />

		<cfif getConfigBean().getOutputDirectoryIsRelative()>
			<cfset fileLocation = ExpandPath(getConfigBean().getOutputDirectory()) & fileName />
		<cfelse>
			<cfset fileLocation = getConfigBean().getOutputDirectory() & fileName />
		</cfif>

		<cfreturn fileLocation />
	</cffunction>

	<cffunction name="getHash" access="private" returntype="string" output="false"
		hint="Gets a hash from the salt and text.">
		<cfargument name="text" type="string" required="true" />
		<cfreturn sha1(getConfigBean().getSaltValue() & UCase(arguments.text)) />
	</cffunction>

	<cffunction name="setHashReference" access="private" returntype="void" output="false"
		hint="Sets captcha text by hash reference.">
		<cfargument name="hash" type="string" required="true" />
		<cfargument name="text" type="string" required="true" />
		
		<cfset variables.instance.hashReferenceCache[1][arguments.hash] = arguments.text />
	</cffunction>

	<cffunction name="getHashReference" access="private" returntype="string" output="false"
		hint="Gets captcha text by hash reference.">
		<cfargument name="hash" type="string" required="true" />
		
		<cfset var text = "" />
		<cfset cleanupHashReferenceCache() />
		
		<!--- Search through the LRU cache starting with the first (and most likely) node --->
		<cfif StructKeyExists(variables.instance.hashReferenceCache[1], arguments.hash)>
			<cfset text = variables.instance.hashReferenceCache[1][arguments.hash]>
			<cfset StructDelete(variables.instance.hashReferenceCache[1], arguments.hash, FALSE) />
		<cfelseif StructKeyExists(variables.instance.hashReferenceCache[2], arguments.hash)>
			<cfset text = variables.instance.hashReferenceCache[2][arguments.hash]>
			<cfset StructDelete(variables.instance.hashReferenceCache[2], arguments.hash, FALSE) />
		<cfelse>
			<cfset text = "" />
		</cfif>
		
		<cfreturn text />
	</cffunction>

	<cffunction name="cleanupHashReferenceCache" access="private" returntype="void" output="false"
		hint="Cleans up expired elements in the hash reference LRU cache.">
		<cfset var tick = getTickCount() />
		
		<!--- Check if cleanup is required and perform double-checked locking pattern --->
		<cfif tick - getHashReferenceCacheTimestamp() GTE 30000>
			<!--- Obtain named lock --->
			<cflock name="captchaServiceHashReferenceCache" timeout="1" throwontimeout="false">
				<cfif tick - getHashReferenceCacheTimestamp() GTE 30000>
					<cfset ArrayPrepend(variables.instance.hashReferenceCache, StructNew()) />
					<cfset ArrayDeleteAt(variables.instance.hashReferenceCache, 3) />
					<cfset setHashReferenceCacheTimestamp(tick) />
				</cfif>
			</cflock>
		</cfif>
	</cffunction>

	<cffunction name="setupHashReferenceCache" access="private" returntype="void" output="false"
		hint="Setups the hash reference cache.">
		<cfset var tempHashReferenceCache = ArrayNew(1) />
		
		<!--- Setup inital hash reference cache --->
		<cfset ArrayPrepend(tempHashReferenceCache, StructNew()) />
		<cfset ArrayPrepend(tempHashReferenceCache, StructNew()) />
		<cfset setHashReferenceCache(tempHashReferenceCache) />
		<cfset setHashReferenceCacheTimestamp(getTickCount()) />
	</cffunction>

	<cffunction name="setupSalt" access="private" returntype="void" output="false"
		hint="Setups the salt.">
		<cfif getConfigBean().getSaltType() IS "auto">
			<cfset getConfigBean().setSaltValue(CreateUUID()) />
		<cfelseif getConfigBean().getSaltType() IS "defined" AND Len(getConfigBean().getSaltValue()) LT 10>
			<cfthrow type="captchaService.invalidSaltValue"
				message="Invalid salt value specified. This value cannot be shorter than 10 characters."
				detail="Passed saltValue=#getConfigBean().getSaltValue()#" />
		<cfelse>
			<cfthrow type="captchaService.invalidSaltType"
				message="Invalid salt type specified. This attribute can only take auto or defined."
				detail="Passed saltType=#getConfigBean().getSaltType()#" />
		</cfif>
	</cffunction>

	<!---
	PROTECTED FUNCTIONS - UDFs
	--->
	<cffunction name="randString" access="private" returntype="string" output="false"
		hint="Returns a random string according to the type.">
		<cfargument name="type" type="string" required="true" />
		<cfargument name="count" type="numeric" required="true" />

		<cfset var randStr = "" />
		<cfset var alpha_lcase = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z" />
		<cfset var alpha_ucase = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z" />
		<cfset var num = "0,1,2,3,4,5,6,7,8,9" />
		<cfset var secure = "!,@,$,%,&,*,-,_,=,+,?,~" />
		<cfset var rangeMax = "" />
		<cfset var useList = "" />
		<cfset var i = "" />
				
		<cfswitch expression="#arguments.type#">
			<cfcase value="alpha">
				<cfset useList = alpha_lcase & "," & alpha_ucase />
				<cfset rangeMax = ListLen(useList) />
			</cfcase>
			<cfcase value="alphaLCase">
				<cfset useList = alpha_lcase />
				<cfset rangeMax = ListLen(useList) />
			</cfcase>
			<cfcase value="alphaUCase">
				<cfset useList = alpha_ucase />
				<cfset rangeMax = ListLen(useList) />
			</cfcase>
			<cfcase value="alphaNum">
				<cfset useList = alpha_lcase & "," & alpha_ucase & "," & num />
				<cfset rangeMax = ListLen(useList) />
			</cfcase>
			<cfcase value="alphaNumLCase">
				<cfset useList = alpha_lcase & "," & "," & num />
				<cfset rangeMax = ListLen(useList) />
			</cfcase>
			<cfcase value="secure">
				<cfset useList = alpha_lcase & "," & alpha_ucase & "," & num & "," & secure />
				<cfset rangeMax = ListLen(useList) />
			</cfcase>
			<cfdefaultcase>
				<cfset useList = num />
				<cfset rangeMax = ListLen(useList) />
			</cfdefaultcase>
		</cfswitch>

		<cfloop from="1" to="#arguments.count#" index="i">
			<cfset randStr = randStr & ListGetAt(useList, RandRange(1, rangeMax)) />
		</cfloop>

		<cfreturn randStr />
	</cffunction>

	<cffunction name="arrayFind" access="private" returntype="numeric" output="false"
		hint="Like listFind(), except with an array.">
		<cfargument name="searchArray" type="array" required="true" />
		<cfargument name="value" type="string" required="true" />
		<!--- Rewritten UDF from cflib.org Author: Nathan Dintenfass (nathan@changemedia.com) --->
		<cfset var i = "" />
		<cfset var result = 0 />
		
		<cfloop from="1" to="#ArrayLen(arguments.searchArray)#" index="i">
			<cfif NOT compareNoCase(arguments.searchArray[i], arguments.value)>
				<cfset result = i />
				<cfbreak />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="sha1" access="private" returntype="string" output="false"
		hint="Computes a SHA1 message digest.">
		<cfargument name="message" type="string" required="true" />
		<!--- Rewritten/Updated UDF from cflib.org Author: author Rob Brooks-Bilson (rbils@amkor.com) --->
		<cfset var hex_msg = "" />
		<cfset var hex_msg_len = 0 />
		<cfset var padded_hex_msg = "" />
		<cfset var msg_block = "" />
		<cfset var num = 0 />
		<cfset var temp = "" />
		<cfset var h = ArrayNew(1) />
		<cfset var w = ArrayNew(1) />
		<cfset var a = "" />
		<cfset var b = "" />
		<cfset var c = "" />
		<cfset var d = "" />
		<cfset var e = "" />
		<cfset var f = "" />
		<cfset var i = 0 />
		<cfset var k = "" />
		<cfset var n = 0 />
		<cfset var t = 0 />
		
		<!--- Convert the msg to ASCII binary-coded form --->
		<cfloop from="1" to="#Len(arguments.message)#" index="i">
			<cfset hex_msg = hex_msg & Right("0" & FormatBaseN(Asc(Mid(message, i , 1)), 16), 2)>
		</cfloop>

		<!--- Compute the msg length in bits --->
		<cfset hex_msg_len = FormatBaseN(8 * Len(message), 16) />
		
		<!--- Pad the msg to make it a multiple of 512 bits long --->
		<cfset padded_hex_msg = hex_msg & "80" & RepeatString("0", 128 - ((Len(hex_msg) + 2 + 16) Mod 128)) & RepeatString("0", 16 - Len(hex_msg_len)) & hex_msg_len />

		<!--- Initialize the buffers --->
		<cfset h[1] = InputBaseN("0x67452301", 16) />
		<cfset h[2] = InputBaseN("0xefcdab89", 16) />
		<cfset h[3] = InputBaseN("0x98badcfe", 16) />
		<cfset h[4] = InputBaseN("0x10325476", 16) />
		<cfset h[5] = InputBaseN("0xc3d2e1f0", 16) />

		<!--- Process the msg 512 bits at a time --->
		<cfloop from="1" to="#Evaluate(Len(padded_hex_msg)/128)#" index="n">
			<cfset msg_block = Mid(padded_hex_msg, 128 * (n-1) + 1, 128) />
			
			<cfset a = h[1] />
			<cfset b = h[2] />
			<cfset c = h[3] />
			<cfset d = h[4] />
			<cfset e = h[5] />
			
			<cfloop from="0" to="79" index="t">
				<!--- nonlinear functions and constants --->
				<cfif t LTE 19>
					<cfset f = BitOr(BitAnd(b, c), BitAnd(BitNot(b), d)) />
					<cfset k = InputBaseN("0x5a827999", 16) />
				<cfelseif t LTE 39>
					<cfset f = BitXor(BitXor(b, c), d) />
					<cfset k = InputBaseN("0x6ed9eba1", 16) />
				<cfelseif t LTE 59>
					<cfset f = BitOr(BitOr(BitAnd(b, c), BitAnd(b, d)), BitAnd(c, d)) />
					<cfset k = InputBaseN("0x8f1bbcdc", 16) />
				<cfelse>
					<cfset f = BitXor(BitXor(b, c), d) />
					<cfset k = InputBaseN("0xca62c1d6", 16) />
				</cfif>
				
				<!--- Transform the msg block from 16 32-bit words to 80 32-bit words --->
				<cfif t LTE 15>
					<cfset w[t + 1] = InputBaseN(Mid(msg_block, 8 * t + 1, 8), 16) />
				<cfelse>
					<cfset num = BitXor(BitXor(BitXor(w[t - 3 + 1], w[t - 8 + 1]), w[t -14 + 1]), w[t - 16 + 1]) />
					<cfset w[t + 1] = BitOr(BitSHLN(num, 1), BitSHRN(num, 32 - 1)) />
				</cfif>
				
				<cfset temp = BitOr(BitSHLN(a, 5), BitSHRN(a, 32 - 5)) + f + e + w[t + 1] + k />
				<cfset e = d />
				<cfset d = c />
				<cfset c = BitOr(BitSHLN(b, 30), BitSHRN(b, 32 - 30)) />
				<cfset b = a />
				<cfset a = temp />
				<cfset num = a />
				
				<cfloop condition="(num LT -2^31) OR (num GE 2^31)">
					<cfset num = num - Sgn(num) * 2 ^ 32 />
				</cfloop>
				
				<cfset a = num />
			</cfloop>
			
			<cfset h[1] = h[1] + a />
			<cfset h[2] = h[2] + b />
			<cfset h[3] = h[3] + c />
			<cfset h[4] = h[4] + d />
			<cfset h[5] = h[5] + e />
			
			<cfloop from="1" to="5" index="i">
				<cfloop condition="(h[i] LT -2 ^ 31) OR (h[i] GTE 2 ^ 31)">
					<cfset h[i] = h[i] - Sgn(h[i])* 2 ^ 32 />
				</cfloop>
			</cfloop>
		</cfloop>
		
		<cfloop from="1" to="5" index="i">
			<cfset h[i] = RepeatString("0", 8 - Len(FormatBaseN(h[i], 16))) & UCase(FormatBaseN(h[i], 16)) />
		</cfloop>
		
		<cfreturn h[1] & h[2] & h[3] & h[4] & h[5] />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="getMemento" access="public" returntype="struct" output="false">
		<cfreturn variables.instance />
	</cffunction>

	<cffunction name="setConfigFile" access="private" returntype="void" output="false">
		<cfargument name="configFile" type="string" required="true" />
		<cfset variables.instance.configFile = ExpandPath(arguments.configFile) />
	</cffunction>
	<cffunction name="getConfigFile" access="public" returntype="string" output="false">
		<cfreturn variables.instance.configFile />
	</cffunction>
	
	<cffunction name="setConfigBean" access="private" returntype="void" output="false">
		<cfargument name="configBean" type="captchaServiceConfigBean" required="true" />
		<cfset variables.instance.configBean = arguments.configBean />
	</cffunction>
	<cffunction name="getConfigBean" access="public" returntype="captchaServiceConfigBean" output="false">
		<cfreturn variables.instance.configBean />
	</cffunction>

	<cffunction name="setHashReferenceCache" access="private" returntype="void" output="false">
		<cfargument name="hashReferenceCache" type="array" required="true" />
		<cfset variables.instance.hashReferenceCache = arguments.hashReferenceCache />
	</cffunction>
	<cffunction name="getHashReferenceCache" access="public" returntype="array" output="false">
		<cfreturn variables.instance.hashReferenceCache />
	</cffunction>

	<cffunction name="setHashReferenceCacheTimestamp" access="private" returntype="void" output="false">
		<cfargument name="hashReferenceCacheTimestamp" type="numeric" required="true" />
		<cfset variables.instance.hashReferenceCacheTimestamp = arguments.hashReferenceCacheTimestamp />
	</cffunction>
	<cffunction name="getHashReferenceCacheTimestamp" access="public" returntype="numeric" output="false">
		<cfreturn variables.instance.hashReferenceCacheTimestamp />
	</cffunction>
	
</cfcomponent>