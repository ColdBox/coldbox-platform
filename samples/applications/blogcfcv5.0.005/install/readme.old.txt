ReadMe

This blog was created by Raymond Camden (ray@camdenfamily.com) of Mindseye (www.mindseye.com). You
may use this blog as you will. I ask that you link back to my blog though. 

If you find this blog worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). Gifts are always welcome. ;)

Install Instructions:
	Extract
	Run SQL script (for MS SQL users)
	Edit the users table to add yourself as a user.
	Edit the ini file. All the settings should make sense.
	Run.
	
	Or read the more details instructions in the Word doc.
	
To admin, go to <yourblogurl>?designmode=1

Current Version: 3.9
Last Updated: August 8, 2005 and August 12, 2005
/org/camden/blog/blog.cfc - was missing a few xmlFormat() calls, use multiple cat tags for rss2, thanks to Roger B
/client/stats.cfm - added states for the past 30 days 

/org/camden/blog/blog.cfc - support for category editing, rss2.0 (Steven Erat), and enclosures
/client/unsubscribe.cfm - use title argument for layout.cfm
/client/stats.cfm - ditto
/client/rss.cfm - allow for version control
/client/index.cfm - removed admin links, add enclosure link
/client/editor.cfm - enclosure support
/client/category_editor.cfm - new
/client/tags/layout.cfm - increased size of editor window and moved in 'admin bar'
/client/includes/main_en_US.properties - new keys (SPANISH VERSION NOT UPDATED YET)
/client/includes/pods/search.cfm - make it point to the right place
/install/migration 3.9 folder added. Contains sql server file only.
/install: All 3 db scripts
/install/BlogCFC.doc - 3.9 updates


------------------ ARCHIVED UPDATES ------------------ 
Last updated: July 29, 2005
/client/includes/main_es_ES.properties, by Steven Erat, added. Spanish locale file
/client/tags/layout.cfm - title can be passed in. This is useful if you want stuff outside of the core blog to use the blog layout
/client/tags/layout.cfm - moved the pods a bit
/client/index.cfm - Two fixes to scopecache use. First, there was a bug where if the cache lived past midnight, the calendar would show the wrong day highlighted.
Next, there was a bug where the cache stopped people from subscribing, since the code inside wasn't being run!
/org/camden/blog/blog.cfc - Technorati support. See Word doc. Thanks to Steven Erat.

Last Updated July 27, 2005
/client/tags/layout.cfm - Changed how rootURL was created. Due to a bug in listDeleteAt at in BD - and my code stunk anyway.
/install/blogcfc.doc - It is important that your BlogURL setting contain "/index.cfm" at the end. I made that clear in the doc.


Last Updated: July 22, 2005
/client/tags/layout.cfm and /client/addcomment.cfm - added a meta tag for utf-8, thanks to Paul (rkc 7/22/05)
/client/rss.cfm - PaulH added localized error labels (rkc 7/22/05)
/client/error.cfm - ditto above
/client/tags/simplecontenteditor.cfm, coloredcode, podlayout, scopecache - ditto
/client/includes/main_en_US.properties - PaulH mods
/install/blogcfc.doc - added note about DSN mod for international issues 
/client/index.cfm - MORE link didn't use right email (rkc 7/21/05)
/client/addcomment.cfm - emails weren't using right format, adding cfproc (rkc 7/21/05)
/client/editor.cfm - titles with quotes were bugged (rkc 7/21/05)
/client/rss.cfm, /client/stats.cfm, /client/unsubscribe.cfm - added cfproc (rkc 7/21/05)
Word doc updated. (rkc 7/15/05)
Removed some old migration files (rkc 7/15/05)
Added a warning to Sean's import_mt script since I do not believe it works anymore, but can be modded. (rkc 7/15/05)
/client/addcomment.cfm - minor layout mods (rkc 7/12/05)
/client/editor.cfm - support for auto-creating SES aliases, minor layout mods, remove delete button (rkc 7/12/05)
/client/index.cfm - parseses.cfm call, SES changes (rkc 7/12/05)
/client/includes/pod/recent.cfm - new link code (rkc 7/12/05)
/client/includes/pod/rss.cfm - uses right URL for rss link (rkc 7/12/05)
/client/includes/style.css - minor tweak to input, select (rkc 7/12/05)
/client/tags/layout.cfm - lots and tweaks
/client/tags/parseses.cfm - new tag
/org/camden/blog/blog.cfc - makeLink


Version: 3.7.1
/client/includes/pods/calendar.cfm - SEO update by Rob Brooks-Bilson (rkc 6/23/05)
/client/tags/layout.cfm - ditto the above (rkc 6/23/05)
/client/index.cfm - ditto the above (rkc 6/23/05)

Changes
Application.cfm - security update (rkc 6/17/05)
Application.cfm - update to app name (rkc 6/17/05)
editor.cfm - fixed the regex to be cleaner - thanks to New Atlanta (rkc 6/17/05)
includes/udf.cfm - update to security (6/17/05)
blog.cfc - rss timezone issue fixed (rkc 6/17/05)
blog.cfc modified to support ping (rkc 6/14/05)
Word doc updated for ping stuff (rkc 6/17/05)

blog.cfc issue under BlueDragon/MYSQL (rkc 6/8/05)

rss feeds would cut off in html (rkc 6/7/05)
editor.cfm under BlueDragon didn't work with <code> blocks right. Fix thanks to Rey Bango and Charlie Arehart (rkc 6/7/05)

error.cfm wouldn't work on BD cuz it used error.rootcause, not we check for it (rkc 5/27/05)
layout.cfm - added cfproc (rkc 5/27/05)
blog.cfc - BD was more precise on a queryparam with access. (rkc 5/27/05)
mysql.sql file updated to specify utf8 (rkc 5/27/05)
includes/pods/archives.cfm now shows RSS links (rkc 5/13/05)
includes/pods/rss.cfm - don't change url for category or entry (rkc 5/13/05)
add includes/pods/subscribe.cfm (rkc 5/13/05)
includes/man_en_us.properties updated with new strings (rkc 5/13/05)
tags/layout.cfm changed to include subscribe pod (rkc 5/13/05)
addcomments.cfm checks for allow comments (rkc 5/13/05)
editor.cfm - fix for <more/>, thanks to a user, and support for allowcomments (rkc 5/13/05)
index.cfm notices allow comments (rkc 5/13/05)
tags/layout.cfm modded so that sub windows are resizable (rkc 5/13/05)
unsubscribe.cfm notices unsub from blog (rkc 5/13/05)
blog.cfc - fix to <more/>, support for comment blocking and blog subscribing (rkc 5/13/05)
install/ db files - support for changes above (rkc 5/13/05)

Fixed /client/includes/pod/calendar.cfm for double closing tr bug (rkc 4/18/05)
Changes:
Updated /client/includes/pod/calendar.cfm, fixed links (rkc 4/5/05)
Updated /client/tags/layout.cfm to show titles (rkc 4/5/05)
Updated /org/camden/blog/blog, just to add new version (rkc 4/5/05)
Updated /client/stats.cfm (rkc 4/5/05)

Updated /client/includes/main_en_US.properties (rkc 4/4/05)
Updated /client/error.cfm to show error if in designmode (rkc 4/4/05)
Updated /client/stats.cfm so it actually works (rkc 4/4/05)
Updated /install/BlogCFC.doc to mention stats (rkc 4/4/05)
Updated /org/camden/blog/blog.cfc to fix mysql/getactivedays bug (rkc 4/4/05)

Support for mail server/u/p (rkc 3/25/05)
Fix for bug in unsubscribe (rkc 3/25/05)
Re-arranged email sent to subscribers (rkc 3/25/05)
Fixed bug with getActiveDays (rkc 3/25/05)
Typo in layout.cfm (rkc 3/23/05)
Better BlueDragon check (rkc 3/23/05)
Better URL validation of dates (rkc 3/23/05)
Removed need for main mapping (rkc 3/20/05)
Fixed issue in admin unsub link (rkc 3/20/05)
Added footer to messages (rkc 3/20/05)
Hide messages in the future (rkc 3/20/05)
Aded paragraphformat2 to UDFs so comments will look a bit cleaner (rkc 3/10/05)
Fixed double escaping in comment additions (rkc 3/10/05)
Added unsubcribe file, and dynamic link for comments so users can unsub via email (rkc 10/21/04)