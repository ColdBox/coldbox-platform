<!---
	Name         :	utils.cfc
	Author       :	Paul Hastings, Raymond Camden 
	Created      :	October 29, 2003
	Last Updated :	26-nov-2005 (ph)
					- added more BIDI languages in isBIDI method, tracking CLDR changes
					- cleaned up & fixed bugs in loadLocale where calendar, etc were init using server default locale
					- added hacks to cover datetime varchar goop coming out of mysql (instead of datetime object)
					- added getCurrentLocale() to show what locale is currently loaded
					- added datetimeLocaleFormat() to format date/time
	History      : 
	Purpose		 :	Locale utils. Lots of help from Paul Hastings. Basically, since CF's locale funcs
					don't accept Java locales, I wrote these functions instead.
				   
				   Most of these methods operate on the current locale.
				   
				   To Do - handle converting from UTC to local time, modded by user pref TZ
--->

<cfcomponent displayName="Utils" output="false">

	<!--- Default locale --->
	<cfset loadLocale()>
	
	<cffunction name="dateLocaleFormat" access="public" returnType="string" output="false"
				hint="locale version of dateFormat">
		<cfargument name="date" type="date" required="true">
		<cfargument name="style" type="string" required="false" default="LONG">
		<cfscript>
		// hack to trap & fix varchar mystery goop coming out of mysql datetimes
		try {
			return variables.aDateFormat.getDateInstance(variables.aDateFormat[arguments.style],variables.thisLocale).format(arguments.date);
		}
		catch(Any e) {
			variables.aCalendar.setTime(arguments.date);
			return variables.aDateFormat.getDateInstance(variables.aDateFormat[arguments.style],variables.thisLocale).format(variables.aCalendar.getTime());
		}	
		</cfscript>
	</cffunction>

	<cffunction name="getAvailableLocales" access="public" returnType="array" output="false"
				hint="Returns an array of locales.">
		<cfscript>
		var i=0;
		var orgLocales=createObject("java","java.util.Locale").getAvailableLocales();
		var theseLocales=arrayNew(1);
		// we skip plain languages, en, fr, ar, etc.
		for (i=1; i LTE arrayLen(orgLocales); i=i+1) {
			if (listLen(orgLocales[i],"_") GT 1) {
			arrayAppend(theseLocales,orgLocales[i]);
			} // if
		} //for  
		return theseLocales;
		</cfscript>
	</cffunction>

	<cffunction name="getLocalizedDays" access="public" returnType="array" output="false"
				hint="Returns localized days">
		<cfscript>
		var localizedShortDays="";
		var i=0;
		var tmp=variables.dateSymbols.getShortWeekdays();
		// kludge java returns NULL first element in array so can't use arrayDeleteAt
		tmp=listToArray(arrayToList(tmp));
		// more kludge, fixup days to match week start
		switch (weekStarts()) {
			case 1:  //starts on sunday, just return day names
				localizedShortDays=tmp;
			break;

			case 2: // euro dates, starts on monday needs kludge
				localizedShortDays=arrayNew(1);
				localizedShortDays[7]=tmp[1]; //move sunday to last
				for (i=1; i LTE 6; i=i+1) {
					localizedShortDays[i]=tmp[i+1];
				}
			break;
			
			case 7: // starts saturday, usually arabic, needs kludge
				localizedShortDays=arrayNew(1);
				localizedShortDays[1]=tmp[7]; //move saturday to first
				for (i=1; i LTE 6; i=i+1) {
					localizedShortDays[i+1]=tmp[i];	
				}
			break;
		}
		return localizedShortDays;
		</cfscript>
	</cffunction>
	
	<cffunction name="getLocalizedMonth" access="public" returnType="string" output="false"
				hint="Returns localized month">
		<cfargument name="month" type="numeric" required="true">
		<cfscript>		
		variables.sDateFormat.init("MMMM",variables.thisLocale);
		return variables.sDateFormat.format(createDate(1999,arguments.month,1));
		</cfscript>
		
	</cffunction>

	<cffunction name="getLocalizedName" access="public" returnType="string" output="false"
				hint="Returns current locale name">
		<cfreturn variables.localeName>
	</cffunction>
	
	<cffunction name="getCurrentLocale" access="public" returnType="string" output="false"
				hint="Returns current locale">
		<cfreturn variables.thisLocale>
	</cffunction>

	<cffunction name="getLocalizedYear" access="public" returnType="string" output="false"
				hint="Returns localized year, probably only useful for BE calendars like in thailand, etc.">
		<cfargument name="thisYear" type="numeric" required="true">
		<cfscript>
		variables.sDateFormat.init("yyyy",variables.thisLocale);
		return variables.sDateFormat.init("yyyy",variables.thisLocale).format(createDate(arguments.thisYear,1,1));
		</cfscript>
	</cffunction>

	<cffunction name="isBIDI" access="public" returnType="boolean" output="false">
		<cfreturn listFind(variables.BIDILanguages,variables.lang)>
	</cffunction>
	
	<cffunction name="loadLocale" access="public" returnType="void" output="false"
				hint="Loads a locale.">
		<cfargument name="locale" type="string" default="en_US" required="false">
		
		<cfif not listLen(arguments.locale,"_") is 2 or
			  not len(listFirst(arguments.locale,"_")) is 2 or
			  not len(listLast(arguments.locale,"_")) is 2>
			<cfthrow message="Specified locale must be of the form language_country where language and country are 2 characters each, en_US, fr_FR, etc.">
		</cfif>
		
		<cfset variables.lang = listFirst(arguments.locale,"_")>
		<cfset variables.country = listLast(arguments.locale,"_")>
		
		<cfset variables.BIDIlanguages="ar,he,fa,ps"><!--- couple more BIDI writing systems --->
		<cfset variables.thisLocale=createObject("java","java.util.Locale").init(variables.lang, variables.country)>
		<cfset variables.localeName=variables.thisLocale.getDisplayName(variables.thisLocale)>
		<cfset variables.aDateFormat=createObject("java","java.text.DateFormat")>
		<cfset variables.sDateFormat=createObject("java","java.text.SimpleDateFormat")>
		<cfset variables.aCalendar=createObject("java","java.util.GregorianCalendar").init(variables.thisLocale)>
		<cfset variables.dateSymbols=createObject("java","java.text.DateFormatSymbols").init(variables.thisLocale)>
	</cffunction>

	<cffunction name="timeLocaleFormat" access="public" returnType="string" output="false"
				hint="locale version of timeFormat">
		<cfargument name="date" type="date" required="true">
		<cfargument name="style" type="string" required="false" default="SHORT">
		<cfscript>
		// hack to trap & fix varchar mystery goop coming out of mysql datetimes
		try {
			return variables.aDateFormat.getTimeInstance(variables.aDateFormat[arguments.style],variables.thisLocale).format(arguments.date);
		}
		catch (Any e) {
			variables.aCalendar.setTime(arguments.date);
			return variables.aDateFormat.getTimeInstance(variables.aDateFormat[arguments.style],variables.thisLocale).format(variables.aCalendar.getTime());
		}	
		</cfscript>		
	</cffunction>

	<cffunction name="datetimeLocaleFormat" access="public" returnType="string" output="false"
				hint="locale date/time format">
		<cfargument name="date" type="date" required="true">
		<cfargument name="dateStyle" type="string" required="false" default="SHORT">
		<cfargument name="timeStyle" type="string" required="false" default="SHORT">
		<cfscript>
		// hack to trap & fix varchar mystery goop coming out of mysql datetimes
		try {
			return variables.aDateFormat.getDateTimeInstance(variables.aDateFormat[arguments.dateStyle],variables.aDateFormat[arguments.timeStyle],variables.thisLocale).format(arguments.date);
		}
		catch (Any e) {
			variables.aCalendar.setTime(arguments.date);
			return variables.aDateFormat.getDateTimeInstance(variables.aDateFormat[arguments.dateStyle],variables.aDateFormat[arguments.timeStyle],variables.thisLocale).format(variables.aCalendar.getTime());
		}	
		</cfscript>
	</cffunction>
	
	<cffunction name="weekStarts" access="public" returnType="string" output="false"
				hint="Determines the first DOW">
		<cfscript>
		return variables.aCalendar.getFirstDayOfWeek();
		</cfscript>
	</cffunction>
		
</cfcomponent>

