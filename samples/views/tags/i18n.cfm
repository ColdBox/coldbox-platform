<cfoutput >
<strong>Locale:</strong> <br />#getPlugin("i18n").getfwLocale()#<br />
<strong>Language:</strong> <br />#getPlugin("i18n").showLanguage()#<br />
<strong>Country:</strong> <br />#getPlugin("i18n").showCountry()#<br />
<strong>TimeZone:</strong> <br />#getPlugin("i18n").getServerTZ()#<br />
<strong>i18nDateFormat:</strong> <br />#getPlugin("i18n").i18nDateFormat(getPlugin("i18n").toEpoch(now()),1)#<br />
<strong>i18nTimeFormat:</strong> <br />#getPlugin("i18n").i18nTimeFormat(getPlugin("i18n").toEpoch(now()),2)#<br />
<hr>
<strong>I18NUtilVersion:</strong> <br />#getPlugin("i18n").getVersion().I18NUtilVersion#<br>
<strong>I18NUtilDate:</strong> <br />#getPlugin("i18n").dateLocaleFormat(now())#<br>
<strong>Java version:</strong> <br />#getPlugin("i18n").getVersion().javaVersion#<br>
</cfoutput>