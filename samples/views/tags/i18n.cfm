<cfoutput >
<strong>Locale:</strong> <br />#application.localeUtils.getfwLocale()#<br />
<strong>Language:</strong> <br />#application.localeUtils.showLanguage()#<br />
<strong>Country:</strong> <br />#application.localeUtils.showCountry()#<br />
<strong>TimeZone:</strong> <br />#application.localeUtils.getServerTZ()#<br />
<strong>i18nDateFormat:</strong> <br />#application.localeUtils.i18nDateFormat(application.localeUtils.toEpoch(now()),1)#<br />
<strong>i18nTimeFormat:</strong> <br />#application.localeUtils.i18nTimeFormat(application.localeUtils.toEpoch(now()),2)#<br />
<hr>
<strong>I18NUtilVersion:</strong> <br />#application.localeUtils.getVersion().I18NUtilVersion#<br>
<strong>I18NUtilDate:</strong> <br />#application.localeUtils.dateLocaleFormat(application.localeUtils.getVersion().I18NUtilDate)#<br>
<strong>Java version:</strong> <br />#application.localeUtils.getVersion().javaVersion#<br>
</cfoutput>