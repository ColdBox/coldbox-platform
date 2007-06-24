<cfsilent>
<cfparam name="form.thisLocale" type="string" default="th_TH">
<cfparam name="form.dateF" type="numeric" default="0">
<cfparam name="form.timeF" type="numeric" default="2">

<cfscript>
       hours=randRange(20,200);
       i18nUtils=createObject("component","i18nutils").init();
       i18nUtils.loadLocale(form.thisLocale);
       now=i18nUtils.toEpoch(now());
       locales=i18nUtils.getLocales();
       lang=i18nUtils.showLanguage();
       country=i18nUtils.showCountry();
       c=i18nUtils.showISOCountry();
       timeZones=i18nUtils.getAvailableTZ();
       serverTZ=i18nUtils.getServerTZ();
       thisTZ=timezones[randRange(1,arrayLen(timeZones))];
       laterOn=i18nUtils.i18nDateAdd(now,"hour",hours,thisTZ);
       usesDST=i18nUtils.usesDST(thisTZ);
       if (usesDST)
               inDST=i18nUtils.inDST(now,thisTZ);
       tDate=i18nUtils.i18nDateFormat(now,form.dateF,thisTZ);
       tDateTime=i18nUtils.i18nDateTimeFormat(now,form.dateF,form.timeF,thisTZ);
       version=i18nUtils.getVersion();
       tzOffset=i18nUtils.getTZOffset(now,thisTZ);
</cfscript>
</cfsilent>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!--- yes i know, no directionality, langauge hints --->
<html>
<head>
       <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
       <title>i18n util Explorer</title>
</head>

<body>
<cfoutput>
<form action="i18nUtilTB.cfm" method="post">
<table border="1" cellspacing="1" cellpadding="1" bgcolor="##b0c4de" style="{font-size:85%;}">
<tr valign="top"><td align="right" valign="top"><b>choose locale</b>:</td>
<td><select name="thisLocale" size="1">
<cfloop index="i" from="1" to="#arrayLen(locales)#">
       <option value="#locales[i].toString()#">#locales[i].toString()#</option>
</cfloop>
</select>
</td>
<td align="right" valign="top"><b>time format:</b></td>
<td>
<select name="timeF" size="1">
       <option value="0">Long</option>
       <option value="1">Full</option>
       <option value="2" SELECTED>Medium</option>
       <option value="3">Short</option>
</select>
</td>
<td align="right" valign="top"><b>date format:</b></td>
<td>
<select name="dateF" size="1">
       <option value="0" SELECTED>Long</option>
       <option value="1">Full</option>
       <option value="2">Medium</option>
       <option value="3">Short</option>
</select>
</td>
<td align="center">&nbsp;&nbsp;<input type="submit" value="test">&nbsp;&nbsp;</td>
</tr>
</form>
<tr valign="top">
<td align="center" colspan="10" bgcolor="##b0c4de">&nbsp;<b>Results</b>&nbsp;</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>Locale:</b></td>
<td colspan="10" bgcolor="##87ceeb">#form.thisLocale#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>isBidi:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.isBIDI()#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>showLanguage:</b></td>
<td colspan="10" bgcolor="##87ceeb">#lang#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>showCountry:</b></td>
<td colspan="10" bgcolor="##87ceeb"><cfif len(trim(country))>#country#<cfelse>&nbsp;</cfif></td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>server timezone:</b></td>
<td colspan="10" bgcolor="##87ceeb">#serverTZ#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>Timezone(s):</b></td>
<td colspan="10" bgcolor="##87ceeb">
<select name="tz" size="1">
<cfloop index="i" from="1" to="#arrayLen(timezones)#">
       <option value="#timezones[i]#">#timezones[i]#</option>
</cfloop>
</select>
</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>using timezone:</b></td>
<td colspan="10" bgcolor="##87ceeb"> #thisTZ# <font size="-1">(randomly chosen)</font></td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>timezone offset:</b></td>
<td colspan="10" bgcolor="##87ceeb">#tzOffset# hours</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>uses DST:</b></td>
<td colspan="10" bgcolor="##87ceeb">#usesDST#</td>
</tr>
<cfif usesDST>
<tr valign="top">
<td align="right" valign="top"><b>in DST:</b></td>
<td colspan="10" bgcolor="##87ceeb">#inDST#</td>
</tr>
</cfif>
<tr valign="top">
<td align="right" valign="top"><b>i18nDateTimeFormat:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.i18nDateTimeFormat(now,dateF,timeF,thisTZ)#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>i18nDateFormat:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.i18nDateFormat(now,form.dateF,thisTZ)#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>i18nTimeFormat:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.i18nTimeFormat(now,form.timeF,thisTZ)#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>i18nDateParse:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.i18nDateParse(tDate)# (original date: #tDate#)</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>i18nDateTimeParse:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.i18nDateTimeParse(tDateTime)# (original datetime: #tDateTime#)</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>getDateTimePattern:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.getDateTimePattern()#</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>formatDateTime:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.formatDateTime(now,"d MMMM yyyy")# (using "d MMMM yyyy")</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>i18nDateDiff:</b></td>
<td colspan="10" bgcolor="##87ceeb">#i18nUtils.i18nDateDiff(now,laterOn,"day",thisTZ)# day(s) (#laterOn# #now#, randomly generated end date)</td>
</tr>
<tr valign="top">
<td align="right" valign="top"><b>version:</b></td>
<td colspan="10" bgcolor="##87ceeb">
I18NUtilVersion:=#version.I18NUtilVersion#<br>
I18NUtilDate:=#version.I18NUtilDate#<br>
Java version:=#version.javaVersion#<br>
JRE version:=#version.javaRuntimeVersion#<br>
</td>
</tr>
</table>
</cfoutput>
</body>
</html>