<cfcomponent name="spry" hint="Plugin for building spry 1.6 based views" extends="coldbox.system.plugin" cache="false" output="false">
<!--- 
License: Apache 2
Created by: Ernst van der Linden (evdlinden@gmail.com)
Created on: 23 january 2008 by evlinden
Last edited on: 21 march 2008 evdlinden
Release 1.0: Spry widget functionality (except validation widgets and autosuggest)
Release 1.3: JSON/XML (nested) DataSet functionality
Release 1.4: custom widgets stylesheets
Release 1.5: white space management. Minified js output
Release 1.6: setIsUtils,setIsJSONDataSets,setIsNestedJsonDataSet,setIsXMLDataSets,setIsNestedXMLDataSets
Release 1.7: setIsDataSets
--->
	<cffunction name="init" access="public" returntype="spry">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setPluginName("Spry Plugin")>
		<cfset setPluginVersion("1.7")>
		<cfset setPluginDescription("Plugin for bulding spry 1.6 based views")>
		<cfreturn this>
	</cffunction>

	<cffunction name="getSpryData" access="private" returntype="struct">
		<cfset var spryData = StructNew()>
		
		<!--- No Spry data available? --->
		<cfif not isSpryData()>

			<cfset spryData.isDebug = false>
			<cfset spryData.spryRelativePath = getSetting("spry.relativePath")>
			<cfset spryData.isEffects = false>
			<cfset spryData.isUtils = false>
			<cfset spryData.isDataSets = false>
			<cfset spryData.isJSONDataSets = false>
			<cfset spryData.isNestedJsonDataSets = false>
			<cfset spryData.isXMLDataSets = false>
			<cfset spryData.isNestedXMLDataSets = false>
			<cfset spryData.tabbedPanels = ArrayNew(1)>
			<cfset spryData.collapsiblePanels = ArrayNew(1)>
			<cfset spryData.collapsiblePanelGroups = ArrayNew(1)>
			<cfset spryData.accordions = ArrayNew(1)>
			<cfset spryData.menuBars = ArrayNew(1)>
			<cfset spryData.slidingPanels = ArrayNew(1)>
			<cfset spryData.toolTips = ArrayNew(1)>
			<cfset spryData.HTMLPanels = ArrayNew(1)>
			<cfset spryData.JSONDataSets = ArrayNew(1)>
			<cfset spryData.nestedJSONDataSets = ArrayNew(1)>
			<cfset spryData.XMLDataSets = ArrayNew(1)>
			<cfset spryData.nestedXMLDataSets = ArrayNew(1)>
			<cfset spryData.jsLinks = ArrayNew(1)>
			<cfset spryData.cssLinks = ArrayNew(1)>
			<cfset spryData.javascripts = ArrayNew(1)>
			<cfset spryData.HTMLHeadJavascripts = ArrayNew(1)>
			<cfset spryData.cssLinkWidgets = StructNew()>
			<cfset spryData.textAreaValidations = ArrayNew(1)>
			<cfset spryData.textFieldValidations = ArrayNew(1)>
			<cfset spryData.radioValidations = ArrayNew(1)>
			<cfset spryData.checkboxValidations = ArrayNew(1)>
			<cfset spryData.selectValidations = ArrayNew(1)>
			<cfset spryData.passwordValidations = ArrayNew(1)>
			<cfset spryData.confirmValidations = ArrayNew(1)>
			<cfset request.spryData = spryData>

			<!--- Setup cssLinks widgets --->
			<cfset setupCssLinksWidgets()>
			
		</cfif>		
		
		<cfreturn request.spryData>
	</cffunction>

	<cffunction name="setupCssLinksWidgets" access="private" returntype="void">
		<!--- Tabbed Pannel --->
		<cfif settingExists("spry.css.tabbedPanel")>
			<cfset setCSSLinkWidget( getSetting("spry.css.tabbedPanel") ,"tabbedPanel")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/tabbedpanels/SpryTabbedPanels.css" ,"tabbedPanel")>
		</cfif> 
		<!--- Collapsible Panel --->
		<cfif settingExists("spry.css.collapsiblePanel")>
			<cfset setCSSLinkWidget( getSetting("spry.css.collapsiblePanel") ,"collapsiblePanel")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/collapsiblepanel/SpryCollapsiblePanel.css" ,"collapsiblePanel")>
		</cfif> 
		<!--- Accordion --->
		<cfif settingExists("spry.css.accordion")>
			<cfset setCSSLinkWidget( getSetting("spry.css.accordion") ,"accordion")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/accordion/SpryAccordion.css" ,"accordion")>
		</cfif> 
		<!--- MenuBar: Horizontal --->
		<cfif settingExists("spry.css.menuBar.horizontal")>
			<cfset setCSSLinkWidget( getSetting("spry.css.menuBar.horizontal") ,"menuBar.horizontal")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/menubar/SpryMenuBarHorizontal.css" ,"menuBar.horizontal")>
		</cfif> 
		<!--- MenuBar: Vertical --->
		<cfif settingExists("spry.css.menuBar.vertical")>
			<cfset setCSSLinkWidget( getSetting("spry.css.menuBar.vertical") ,"menuBar.vertical")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/menubar/SpryMenuBarVertical.css" ,"menuBar.vertical")>
		</cfif> 
		<!--- Sliding Panel --->
		<cfif settingExists("spry.css.slidingPanel")>
			<cfset setCSSLinkWidget( getSetting("spry.css.slidingPanel") ,"slidingPanel")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/slidingpanels/SprySlidingPanels.css" ,"slidingPanel")>
		</cfif> 
		<!--- ToolTip --->
		<cfif settingExists("spry.css.toolTip")>
			<cfset setCSSLinkWidget( getSetting("spry.css.toolTip") ,"toolTip")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/tooltip/SpryTooltip.css" ,"toolTip")>
		</cfif> 
		<!--- HTML Panel --->
		<cfif settingExists("spry.css.HTMLPanel")>
			<cfset setCSSLinkWidget( getSetting("spry.css.HTMLPanel") ,"HTMLPanel")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/tabbedpanels/SpryHTMLPanel" ,"HTMLPanel")>
		</cfif> 
		<!--- TextArea Validation --->
		<cfif settingExists("spry.css.textAreaValidation")>
			<cfset setCSSLinkWidget( getSetting("spry.css.textAreaValidation") ,"textAreaValidation")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/textareavalidation/SpryValidationTextarea.css" ,"textAreaValidation")>
		</cfif> 
		<!--- Textfield Validation --->
		<cfif settingExists("spry.css.textFieldValidation")>
			<cfset setCSSLinkWidget( getSetting("spry.css.textFieldValidation") ,"textFieldValidation")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/textfieldvalidation/SpryValidationTextField.css" ,"textFieldValidation")>
		</cfif> 
		<!--- Radio Validation --->
		<cfif settingExists("spry.css.radioValidation")>
			<cfset setCSSLinkWidget( getSetting("spry.css.radioValidation") ,"radioValidation")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/radiovalidation/SpryValidationRadio.css" ,"radioValidation")>
		</cfif> 
		<!--- CheckBox Validation --->
		<cfif settingExists("spry.css.checkboxValidation")>
			<cfset setCSSLinkWidget( getSetting("spry.css.checkboxValidation") ,"checkboxValidation")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/checkboxvalidation/SpryValidationCheckbox.css" ,"checkboxValidation")>
		</cfif> 
		<!--- Select Validation --->
		<cfif settingExists("spry.css.selectValidation")>
			<cfset setCSSLinkWidget( getSetting("spry.css.selectValidation") ,"selectValidation")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/selectvalidation/SpryValidationSelect.css" ,"selectValidation")>
		</cfif> 
		<!--- Password Validation --->
		<cfif settingExists("spry.css.passwordValidation")>
			<cfset setCSSLinkWidget( getSetting("spry.css.passwordValidation") ,"passwordValidation")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/passwordvalidation/SpryValidationPassword.css" ,"passwordValidation")>
		</cfif> 
		<!--- Confirm Validation --->
		<cfif settingExists("spry.css.confirmValidation")>
			<cfset setCSSLinkWidget( getSetting("spry.css.confirmValidation") ,"confirmValidation")>
		<cfelse>
			<cfset setCSSLinkWidget( "#getSpryRelativePath()#/widgets/confirmvalidation/SpryValidationConfirm.css" ,"confirmValidation")>
		</cfif> 

	</cffunction>

	<cffunction name="getCssLinkWidget" access="private" returntype="string">
		<cfargument name="widget" type="string" required="true" hint="accordion,menuBar etc.">
		<cfreturn getSpryData().cssLinkWidgets[arguments.widget]>
	</cffunction>

	<cffunction name="isSpryData" access="private" returntype="boolean">
        <cfreturn isDefined("request.spryData")>
	</cffunction>

	<cffunction name="getSpryRelativePath" access="public" returntype="string">
        <cfreturn getSpryData().spryRelativePath>
	</cffunction>

	<cffunction name="isDebug" access="public" returntype="boolean">
        <cfreturn getSpryData().isDebug>
	</cffunction>

	<cffunction name="isEffects" access="public" returntype="boolean">
        <cfreturn getSpryData().isEffects>
	</cffunction>

	<cffunction name="isUtils" access="public" returntype="boolean">
        <cfreturn getSpryData().isUtils>
	</cffunction>

	<cffunction name="isTabbedPanels" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().tabbedPanels)>
	</cffunction>

	<cffunction name="isCollapsiblePanels" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().collapsiblePanels)>
	</cffunction>

	<cffunction name="isCollapsiblePanelGroups" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().collapsiblePanelGroups)>
	</cffunction>

	<cffunction name="isAccordions" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().accordions)>
	</cffunction>

	<cffunction name="isMenuBars" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().menuBars)>
	</cffunction>

	<cffunction name="isSlidingPanels" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().slidingPanels)>
	</cffunction>

	<cffunction name="isTooltips" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().toolTips)>
	</cffunction>

	<cffunction name="isHTMLPanels" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().HTMLPanels)>
	</cffunction>

	<cffunction name="isDataSets" access="public" returntype="boolean">
		<cfset var isDataSets = false>
        <cfreturn getSpryData().isDataSets>
	</cffunction>

	<cffunction name="isJSONDataSets" access="public" returntype="boolean">
		<cfset var isJSONDataSets = false>
		<cfif not ArrayIsEmpty(getSpryData().JSONDataSets) or getSpryData().isJSONDataSets>
			<cfset isJSONDataSets = true>
		</cfif>
        <cfreturn isJSONDataSets>
	</cffunction>

	<cffunction name="isNestedJSONDataSets" access="public" returntype="boolean">
		<cfset var isNestedJSONDataSets = false>
		<cfif not ArrayIsEmpty(getSpryData().nestedJSONDataSets) or getSpryData().isNestedJSONDataSets>
			<cfset isNestedJSONDataSets = true>
		</cfif>
		<cfreturn isNestedJSONDataSets>
	</cffunction>

	<cffunction name="isXMLDataSets" access="public" returntype="boolean">
		<cfset var isXMLDataSets = false>
		<cfif not ArrayIsEmpty(getSpryData().XMLDataSets) or getSpryData().isXMLDataSets>
			<cfset isXMLDataSets = true>
		</cfif>
		<cfreturn isXMLDataSets>		
	</cffunction>

	<cffunction name="isNestedXMLDataSets" access="public" returntype="boolean">
		<cfset var isNestedXMLDataSets = false>
		<cfif not ArrayIsEmpty(getSpryData().nestedXMLDataSets) or getSpryData().isNestedXMLDataSets>
			<cfset isNestedXMLDataSets = true>
		</cfif>
		<cfreturn isNestedXMLDataSets>		
	</cffunction>

	<cffunction name="isTextAreaValidation" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().textAreaValidations)>
	</cffunction>
	
	<cffunction name="isTextFieldValidation" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().textFieldValidations)>
	</cffunction>
	
	<cffunction name="isRadioValidation" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().radioValidations)>
	</cffunction>
	
	<cffunction name="isCheckboxValidation" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().checkboxValidations)>
	</cffunction>
	
	<cffunction name="isSelectValidation" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().selectValidations)>
	</cffunction>
	
	<cffunction name="isPasswordValidation" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().passwordValidations)>
	</cffunction>
	
	<cffunction name="isConfirmValidation" access="public" returntype="boolean">
        <cfreturn not ArrayIsEmpty(getSpryData().confirmValidations)>
	</cffunction>

	<cffunction name="setTabbedPanel" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var tabbedPanel = StructNew()>
		<cfset tabbedPanel.id = arguments.id>
		<cfset tabbedPanel.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().tabbedPanels,tabbedPanel)>
	</cffunction>

	<cffunction name="setIsDebug" access="public" returntype="void">
		<cfargument name="isDebug" type="boolean" required="true">
        <cfset getSpryData().isDebug = arguments.isDebug>
	</cffunction>

	<cffunction name="setIsEffects" access="public" returntype="void">
		<cfargument name="isEffects" type="boolean" required="true">
        <cfset getSpryData().isEffects = arguments.isEffects>
	</cffunction>

	<cffunction name="setIsUtils" access="public" returntype="void">
		<cfargument name="isUtils" type="boolean" required="true">
        <cfset getSpryData().isUtils = arguments.isUtils>
	</cffunction>

	<cffunction name="setIsDataSets" access="public" returntype="void">
		<cfargument name="isDataSets" type="boolean" required="true">
        <cfset getSpryData().isDataSets = arguments.isDataSets>
	</cffunction>

	<cffunction name="setIsJSONDataSets" access="public" returntype="void">
		<cfargument name="isJSONDataSets" type="boolean" required="true">
        <cfset getSpryData().isJSONDataSets = arguments.isJSONDataSets>
	</cffunction>

	<cffunction name="setIsNestedJSONDataSets" access="public" returntype="void">
		<cfargument name="isNestedJSONDataSets" type="boolean" required="true">
        <cfset getSpryData().isNestedJSONDataSets = arguments.isNestedJSONDataSets>
	</cffunction>

	<cffunction name="setIsXMLDataSets" access="public" returntype="void">
		<cfargument name="isXMLDataSets" type="boolean" required="true">
        <cfset getSpryData().isXMLDataSets = arguments.isXMLDataSets>
	</cffunction>

	<cffunction name="setIsNestedXMLDataSets" access="public" returntype="void">
		<cfargument name="isNestedXMLDataSets" type="boolean" required="true">
        <cfset getSpryData().isNestedXMLDataSets = arguments.isNestedXMLDataSets>
	</cffunction>
	
	<cffunction name="setCollapsiblePanel" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var collapsiblePanel = StructNew()>
		<cfset collapsiblePanel.id = arguments.id>
		<cfset collapsiblePanel.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().collapsiblePanels,collapsiblePanel)>
	</cffunction>

	<cffunction name="setCollapsiblePanelGroup" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var collapsiblePanelGroup = StructNew()>
		<cfset collapsiblePanelGroup.id = arguments.id>
		<cfset collapsiblePanelGroup.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().collapsiblePanelGroups,collapsiblePanelGroup)>
	</cffunction>

	<cffunction name="setAccordion" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var accordion = StructNew()>
		<cfset accordion.id = arguments.id>
		<cfset accordion.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().accordions,accordion)>
	</cffunction>

	<cffunction name="setTextAreaValidation" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var textAreaValidation = StructNew()>
		<cfset textAreaValidation.id = arguments.id>
		<cfset textAreaValidation.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().textAreaValidations,textAreaValidation)>
	</cffunction>

	<cffunction name="setTextFieldValidation" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="validationType" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var textFieldValidation = StructNew()>
		<cfset textFieldValidation.id = arguments.id>
		<cfset textFieldValidation.validationType = arguments.validationType>
		<cfset textFieldValidation.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().textFieldValidations,textFieldValidation)>
	</cffunction>

	<cffunction name="setRadioValidation" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var radioValidation = StructNew()>
		<cfset radioValidation.id = arguments.id>
		<cfset radioValidation.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().radioValidations,radioValidation)>
	</cffunction>

	<cffunction name="setCheckboxValidation" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var checkboxValidation = StructNew()>
		<cfset checkboxValidation.id = arguments.id>
		<cfset checkboxValidation.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().checkboxValidations,checkboxValidation)>
	</cffunction>

	<cffunction name="setSelectValidation" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var selectValidation = StructNew()>
		<cfset selectValidation.id = arguments.id>
		<cfset selectValidation.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().selectValidations,selectValidation)>
	</cffunction>

	<cffunction name="setPasswordValidation" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var passwordValidation = StructNew()>
		<cfset passwordValidation.id = arguments.id>
		<cfset passwordValidation.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().passwordValidations,passwordValidation)>
	</cffunction>

	<cffunction name="setConfirmValidation" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var confirmValidation = StructNew()>
		<cfset confirmValidation.id = arguments.id>
		<cfset confirmValidation.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().confirmValidations,confirmValidation)>
	</cffunction>

	<cffunction name="setMenuBar" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var menuBar = StructNew()>
		<cfset menuBar.id = arguments.id>
		<cfset menuBar.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().menuBars,menuBar)>
	</cffunction>

	<cffunction name="setSlidingPanel" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var slidingPanel = StructNew()>
		<cfset slidingPanel.id = arguments.id>
		<cfset slidingPanel.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().slidingPanels,slidingPanel)>
	</cffunction>

	<cffunction name="setToolTip" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="triggerId" type="string" hint="html trigger id" required="false" default="#arguments.id#_trigger">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var toolTip = StructNew()>
		<cfset toolTip.id = arguments.id>
		<cfset toolTip.triggerId = arguments.triggerId>
		<cfset toolTip.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().toolTips,toolTip)>
	</cffunction>

	<cffunction name="setHTMLPanel" access="public" returntype="void">
		<cfargument name="id" type="string" hint="html id" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var HTMLPanel = StructNew()>
		<cfset HTMLPanel.id = arguments.id>
		<cfset HTMLPanel.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().HTMLPanels,HTMLPanel)>
	</cffunction>
	
	<cffunction name="setJsLink" access="public" returntype="void">
		<cfargument name="src" type="string" required="true">
		<cfset arrayAppend(getSpryData().jsLinks,arguments.src)>
	</cffunction>

	<cffunction name="setJavascript" access="public" returntype="void">
		<cfargument name="javascript" type="string" required="true">
		<cfargument name="isHTMLHead" type="boolean" required="false" default="false">
		
		<cfif arguments.isHTMLHead>
			<cfset arrayAppend(getSpryData().HTMLHeadJavascripts,arguments.javascript)>				
		<cfelse>
			<cfset arrayAppend(getSpryData().javascripts,arguments.javascript)>				
		</cfif>
		
	</cffunction>

	<cffunction name="setPluginJavascripts" access="public" returntype="void">
		<cfargument name="javascript" type="string" required="true">
		<cfargument name="isHTLMhead" type="boolean" required="false" default="false">

		<cfset arrayAppend(getSpryData().spryJavascripts,arguments.customJavascript)>
	</cffunction>

	<cffunction name="setCssLink" access="public" returntype="void">
		<cfargument name="href" type="string" required="true">
		<cfargument name="media" type="string" required="false" default="screen">
		
		<cfset var cssLink = StructNew()>
		<cfset cssLink.href = arguments.href>
		<cfset cssLink.media = arguments.media>
		
		<cfset arrayAppend(getSpryData().cssLinks,cssLink)>		
	</cffunction>

	<cffunction name="setCssLinkWidget" access="private" returntype="void">
		<cfargument name="href" type="string" required="true">
		<cfargument name="widget" type="string" required="true" hint="accordion,menuBar etc.">
		<cfset getSpryData().cssLinkWidgets[arguments.widget] = arguments.href>
	</cffunction>

	<cffunction name="setJSONDataSet" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="url" type="string" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var JSONDataSet = StructNew()>
		<cfset JSONDataSet.name = arguments.name>
		<cfset JSONDataSet.url = arguments.url>
		<cfset JSONDataSet.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().JSONDataSets,JSONDataSet)>		
	</cffunction>

	<cffunction name="setNestedJSONDataSet" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="parentDataSet" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var nestedJSONDataSet = StructNew()>
		<cfset nestedJSONDataSet.name = arguments.name>
		<cfset nestedJSONDataSet.parentDataSet = arguments.parentDataSet>
		<cfset nestedJSONDataSet.path = arguments.path>
		<cfset nestedJSONDataSet.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().nestedJSONDataSets,nestedJSONDataSet)>		
	</cffunction>

	<cffunction name="setXMLDataSet" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="url" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var XMLDataSet = StructNew()>
		<cfset XMLDataSet.name = arguments.name>
		<cfset XMLDataSet.url = arguments.url>
		<cfset XMLDataSet.path = arguments.path>
		<cfset XMLDataSet.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().XMLDataSets,XMLDataSet)>		
	</cffunction>

	<cffunction name="setNestedXMLDataSet" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="parentDataSet" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="options" type="string" required="false" default="">
		
		<cfset var nestedXMLDataSet = StructNew()>
		<cfset nestedXMLDataSet.name = arguments.name>
		<cfset nestedXMLDataSet.parentDataSet = arguments.parentDataSet>
		<cfset nestedXMLDataSet.path = arguments.path>
		<cfset nestedXMLDataSet.options = arguments.options>
		
		<cfset arrayAppend(getSpryData().nestedXMLDataSets,nestedXMLDataSet)>		
	</cffunction>
				
	<cffunction name="render" access="public" returntype="string" output="false">
        <cfset var i = 0>
		<cfset var jsResult = "">
		<cfset var url = "">
        <cfset var custom = StructNew()>
        
		<!--- Some Spry plugin settings need to load first, so hold all relevant custom settings  --->
		<cfset custom.javascripts = getSpryData().javascripts>
        <cfset custom.HTMLHeadJavascripts = getSpryData().HTMLHeadJavascripts>
		<cfset custom.jsLinks = getSpryData().jsLinks>
		<cfset custom.cssLinks = getSpryData().cssLinks>
		<!--- Clear related existing custom settings --->
		<cfset ArrayClear(getSpryData().javascripts)>
		<cfset ArrayClear(getSpryData().HTMLHeadJavascripts)>
		<cfset ArrayClear(getSpryData().jsLinks)>
		<cfset ArrayClear(getSpryData().cssLinks)>
				
		<!--- Spry data in request? --->
		<cfif isSpryData()>

			<!--- Tabbed panels? --->
			<cfif isTabbedPanels()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryTabbedPanels.js')>
				<cfset setCssLink( getCssLinkWidget("tabbedPanel") )>
				<!--- Create JS objects: TabbedPannels --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().tabbedPanels)#">
					<cfset setJavascript('var #getSpryData().tabbedPanels[i].id# = new Spry.Widget.TabbedPanels("#getSpryData().tabbedPanels[i].id#",{#getSpryData().tabbedPanels[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Collapsible pannels or collapsible panel groups? --->
			<cfif isCollapsiblePanels() or isCollapsiblePanelGroups()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryCollapsiblePanel.js')>
				<cfset setCssLink( getCssLinkWidget("collapsiblePanel") )>
			</cfif>

			<!--- Collapsible panels? --->
			<cfif isCollapsiblePanels()>
				<!--- Create JS objects: CollapsiblePanels --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().collapsiblePanels)#">
					<cfset setJavascript('var #getSpryData().collapsiblePanels[i].id# = new Spry.Widget.CollapsiblePanel("#getSpryData().collapsiblePanels[i].id#",{#getSpryData().collapsiblePanels[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Collapsible panel groups? --->
			<cfif isCollapsiblePanelGroups()>
				<!--- Create JS objects: CollapsiblePanelGroups --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().collapsiblePanelGroups)#">
					<cfset setJavascript('var #getSpryData().collapsiblePanelGroups[i].id# = new Spry.Widget.CollapsiblePanel("#getSpryData().collapsiblePanelGroups[i].id#",{#getSpryData().collapsiblePanelGroups[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Accordions? --->
			<cfif isAccordions()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryAccordion.js')>
				<cfset setCssLink( getCssLinkWidget("accordion") )>
				<!--- Create JS objects: Accordions --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().accordions)#">
					<cfset setJavascript('var #getSpryData().accordions[i].id# = new Spry.Widget.Accordion("#getSpryData().accordions[i].id#",{#getSpryData().accordions[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Menubars? --->
			<cfif isMenuBars()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryMenuBar.js')>
				<cfset setCssLink( getCssLinkWidget("menuBar.horizontal") )>
				<cfset setCssLink( getCssLinkWidget("menuBar.vertical") )>
				<!--- Create JS objects: MenuBars --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().menuBars)#">
					<cfset setJavascript('var #getSpryData().menuBars[i].id# = new Spry.Widget.MenuBar("#getSpryData().menuBars[i].id#",{#getSpryData().menuBars[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Sliding panels? --->
			<cfif isSlidingPanels()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SprySlidingPanels.js')>
				<cfset setCssLink( getCssLinkWidget("slidingPanel") )>
				<!--- Create JS objects: SlidingPanels --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().slidingPanels)#">
					<cfset setJavascript('var #getSpryData().slidingPanels[i].id# = new Spry.Widget.SlidingPanels("#getSpryData().slidingPanels[i].id#",{#getSpryData().slidingPanels[i].options#});')>
				</cfloop>
			</cfif>

			<!--- ToolTips? --->
			<cfif isToolTips()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryTooltip.js')>
				<cfset setCssLink( getCssLinkWidget("toolTip") )>
				<!--- Create JS objects: ToolTips --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().tooltips)#">
					<cfset setJavascript('var #getSpryData().tooltips[i].id# = new Spry.Widget.Tooltip("#getSpryData().tooltips[i].id#","###getSpryData().tooltips[i].triggerId#",{#getSpryData().tooltips[i].options#});')>
				</cfloop>
			</cfif>

			<!--- HTML panels? --->
			<cfif isHTMLPanels()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryHTMLPanel.js')>
				<cfset setCssLink( getCssLinkWidget("HTMLPanel") )>
				<!--- Create JS objects: HTMLPanels --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().HTMLPanels)#">
					<cfset setJavascript('var #getSpryData().HTMLPanels[i].id# = new Spry.Widget.HTMLPanel("#getSpryData().HTMLPanels[i].id#",{#getSpryData().HTMLPanels[i].options#});')>
				</cfloop>
			</cfif>

			<!--- TextArea Validation? --->
			<cfif isTextAreaValidation()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryValidationTextarea.js')>
				<cfset setCssLink( getCssLinkWidget("textAreaValidation") )>
				<!--- Create JS objects: textAreaValidations --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().textAreaValidations)#">
					<cfset setJavascript('var #getSpryData().textAreaValidation[i].id# = new Spry.Widget.ValidationTextarea("#getSpryData().textAreaValidation[i].id#",{#getSpryData().textAreaValidation[i].options#});')>
				</cfloop>
			</cfif>

			<!--- TextField Validation? --->
			<cfif isTextFieldValidation()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryValidationTextField.js')>
				<cfset setCssLink( getCssLinkWidget("textFieldValidation") )>
				<!--- Create JS objects: textFieldValidations --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().textFieldValidations)#">
					<cfset setJavascript('var #getSpryData().textFieldValidations[i].id# = new Spry.Widget.ValidationTextField("#getSpryData().textFieldValidations[i].id#","#getSpryData().textFieldValidations[i].validationType#",{#getSpryData().textFieldValidations[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Radio Validation? --->
			<cfif isRadioValidation()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryValidationRadio.js')>
				<cfset setCssLink( getCssLinkWidget("radioValidation") )>
				<!--- Create JS objects: radioValidations --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().radioValidations)#">
					<cfset setJavascript('var #getSpryData().radioValidations[i].id# = new Spry.Widget.ValidationRadio("#getSpryData().radioValidations[i].id#",{#getSpryData().radioValidations[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Checkbox Validation? --->
			<cfif isCheckboxValidation()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryValidationCheckbox.js')>
				<cfset setCssLink( getCssLinkWidget("checkboxValidation") )>
				<!--- Create JS objects: checkboxValidations --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().checkboxValidations)#">
					<cfset setJavascript('var #getSpryData().checkboxValidations[i].id# = new Spry.Widget.ValidationCheckbox("#getSpryData().checkboxValidations[i].id#",{#getSpryData().checkboxValidations[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Select Validation? --->
			<cfif isSelectValidation()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryValidationSelect.js')>
				<cfset setCssLink( getCssLinkWidget("selectValidation") )>
				<!--- Create JS objects: selectValidations --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().selectValidations)#">
					<cfset setJavascript('var #getSpryData().selectValidations[i].id# = new Spry.Widget.ValidationSelect("#getSpryData().selectValidations[i].id#",{#getSpryData().selectValidations[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Password Validation? --->
			<cfif isPasswordValidation()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryValidationPassword.js')>
				<cfset setCssLink( getCssLinkWidget("passwordValidation") )>
				<!--- Create JS objects: passwordValidations --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().passwordValidations)#">
					<cfset setJavascript('var #getSpryData().passwordValidations[i].id# = new Spry.Widget.ValidationPassword("#getSpryData().passwordValidations[i].id#",{#getSpryData().passwordValidations[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Confirm Validation? --->
			<cfif isConfirmValidation()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryValidationConfirm.js')>
				<cfset setCssLink( getCssLinkWidget("confirmValidation") )>
				<!--- Create JS objects: confirmValidations --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().confirmValidations)#">
					<cfset setJavascript('var #getSpryData().confirmValidations[i].id# = new Spry.Widget.ValidationConfirm("#getSpryData().confirmValidations[i].id#",{#getSpryData().confirmValidations[i].options#});')>
				</cfloop>
			</cfif>

			<!--- Effects? --->
			<cfif isEffects()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryEffects.js')>
			</cfif>
			
			<!--- Utils? --->
			<cfif isUtils()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryUtils.js')>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryDomUtils.js')>
			</cfif>
			
			<!--- Xpath JS? --->
			<cfif isJSONDataSets() or isNestedJSONDataSets() or isXMLDataSets() or isNestedXMLDataSets()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/xpath.js')>
			</cfif>
			
			<!--- SpryData JS? --->			
			<cfif isDataSets() or isJSONDataSets() or isNestedJSONDataSets() or isXMLDataSets() or isNestedXMLDataSets()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryData.js')>
			</cfif>

			<!--- JSON DataSet? --->
			<cfif isJSONDataSets()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryJSONDataSet.js')>
				<!--- Create JS objects: JSONDataSets --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().JSONDataSets)#">
					<!--- Quotes? --->
					<cfif getSpryData().JSONDataSets[i].url eq "null">
						<cfset url = getSpryData().JSONDataSets[i].url>
					<cfelse>
						<cfset url = '"#getSpryData().JSONDataSets[i].url#"'>
					</cfif>

					<cfset setJavascript('var #getSpryData().JSONDataSets[i].name# = new Spry.Data.JSONDataSet(#url#,{#getSpryData().JSONDataSets[i].options#});',true)>
				</cfloop>
			</cfif>
			
			<!--- Nested JSON DataSet? --->
			<cfif isNestedJSONDataSets()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryNestedJSONDataSet.js')>
				<!--- Create JS objects: NestedJSONDataSets --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().nestedJSONDataSets)#">
					<cfset setJavascript('var #getSpryData().nestedJSONDataSets[i].name# = new Spry.Data.NestedJSONDataSet(#getSpryData().nestedJSONDataSets[i].parentDataSet#,"#getSpryData().nestedJSONDataSets[i].path#",{#getSpryData().nestedJSONDataSets[i].options#});',true)>
				</cfloop>
			</cfif>

			<!--- XML DataSets? --->
			<cfif isXMLDataSets()>
				<!--- Create JS objects: XMLDataSets --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().XMLDataSets)#">
					<!--- Quotes? --->
					<cfif getSpryData().XMLDataSets[i].url eq "null">
						<cfset url = getSpryData().XMLDataSets[i].url>
					<cfelse>
						<cfset url = '"#getSpryData().XMLDataSets[i].url#"'>
					</cfif>
					<cfset setJavascript('var #getSpryData().XMLDataSets[i].name# = new Spry.Data.XMLDataSet(#url#,"#getSpryData().XMLDataSets[i].path#",{#getSpryData().XMLDataSets[i].options#});',true)>
				</cfloop>
			</cfif>

			<!--- Nested XML DataSet? --->
			<cfif isNestedXMLDataSets()>
				<cfset setJsLink('#getSpryRelativePath()#/includes_minified/SpryNestedXMLDataSet.js')>
				<!--- Create JS objects: NestedXMLDataSets --->
				<cfloop index="i" from="1" to="#ArrayLen(getSpryData().nestedXMLDataSets)#">
					<cfset setJavascript('var #getSpryData().nestedXMLDataSets[i].name# = new Spry.Data.NestedXMLDataSet(#getSpryData().nestedXMLDataSets[i].parentDataSet#,"#getSpryData().nestedXMLDataSets[i].path#",{#getSpryData().nestedXMLDataSets[i].options#});',true)>
				</cfloop>
			</cfif>	
			
			<!--- Set custom settings: load Spry settings first issue --->
			<cfloop index="i" from="1" to="#ArrayLen(custom.jsLinks)#">
				<cfset setJsLink(custom.jsLinks[i])>
			</cfloop>
			<cfloop index="i" from="1" to="#ArrayLen(custom.cssLinks)#">
				<cfset setCSSLink(custom.cssLinks[i].href,custom.cssLinks[i].media)>
			</cfloop>
			<cfloop index="i" from="1" to="#ArrayLen(custom.HTMLHeadJavascripts)#">
				<cfset setJavascript(custom.HTMLHeadJavascripts[i],true)>
			</cfloop>
			<cfloop index="i" from="1" to="#ArrayLen(custom.javascripts)#">
				<cfset setJavascript(custom.javascripts[i])>				
			</cfloop>
			
			<!--- Include javascript links in HTML Head --->
			<cfloop index="i" from="1" to="#ArrayLen(getSpryData().jsLinks)#">
				<cfhtmlhead text='<script language="javascript" src="#getSpryData().jsLinks[i]#" type="text/javascript"></script>'>
			</cfloop>
				
			<!--- Include stylesheet links in HTML Head --->
			<cfloop index="i" from="1" to="#ArrayLen(getSpryData().cssLinks)#">
				<cfhtmlhead text='<link rel="stylesheet" href="#getSpryData().cssLinks[i].href#" type="text/css" media="#getSpryData().cssLinks[i].media#">'>
			</cfloop>

			<!--- Render javascript in HTMLHead --->
			<cfhtmlhead text='<script type="text/javascript">#getCompressedJs(ArrayTolist(getSpryData().HTMLHeadJavascripts,""))#</script>'>

			<!--- Render javascript post content --->
			<cfset jsResult = '<script type="text/javascript">#getCompressedJs(ArrayTolist(getSpryData().javascripts,""))#</script>'>
			
			<!--- Debug? --->
			<cfif isDebug()>
				<cfsavecontent variable="jsResult">
					<cfoutput>#jsResult#</cfoutput>
					<cfdump label="SpryData" var="#getSpryData()#">
				</cfsavecontent>
			</cfif>
			
		</cfif>
		
		<cfreturn jsResult>
	</cffunction>
	
	<cffunction name="getCompressedJs" output="false" access="public" returntype="string">
		<cfargument name="javascript" type="string" required="true">
		<!--- Strip all spaces; we use 2 spaces for not replacing code spaces --->
		<!--- Bugs when using comments --->
		<cfset var compressedJs = ReReplace(arguments.javascript, "\s\s", "","all")> 
		<cfreturn compressedJs>
	</cffunction>	
</cfcomponent>
