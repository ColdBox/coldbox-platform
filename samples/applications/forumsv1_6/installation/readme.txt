LICENSE 
Copyright 2006 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


Welcome to Galleon. This is an open-source forums application for ColdFusion. For installation instructions, please
read the word documentation. For folks who are upgrading, BE SURE to read the notes below. It details
what changes in each release.

This application was created by Raymond Camden (ray@camdenfamily.com). 
You may use this application as you will. I ask that you link back to my blog (http://ray.camdenfamily.com).

If you find this app worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). 
Gifts are always welcome. ;)


---- LATEST VERSION ----
1.6.1 (August 3, 2006)
Typo in SQLServer install script. Thanks Josh Rogers. No version change.

1.6.1 (July 27, 2006)
/install/ - All DB scripts updated. The size of the name fields for 
conferences, forums, threads, and messages are now all set to a max
of 255. There was also a bug in the mysql script that limited the size
on one field to a low number.

/admin/conferences_edit, forums_edit, threads_edit, messages_edit - 
all had the sizes removed from name fields.

/cfcs/conferences+messages+forums+threads.cfc - support for new size
and new email of full messages. Also added wrap to emails.

/cfcs/settings.ini.cfm - added fullemails key

/messages.cfm + /newposts.cfm - updated with new sizes
---- ARCHIVED UPDATES ----
1.6.002 (July 21, 2006)
DB install scripts had a bug.
/cfcs/settings.ini.cfm - just a version change

1.6.001 (July 17, 2006)
/admin/user_edit.cfm - Bug when requireconfirmation was false
/admin/Application.cfm, /Application.cfm - better "is admin file" checking. 
/cfcs/settings.ini.cfm - Just a version change

1.6 (final release July 12, 2006)

DB CHANGES: Add confirmed as a bit property to the users table. If you wish to use confirmations,
you must write a sql query to update all old users and mark them confirmed.

FILE CHANGES: Note the updated files below. Most importantly, you need to rename settings.ini to 
settings.ini.cfm and add requireconfirmation, title fields.

/admin/users.cfm - show confirmation
/admin/users_edit.cfm - show confirmation, require one group
/cfc/conference.cfc, forum.cfc, thread.cfc - show last user
/cfc/message.cfc - fix saving for moderators, make title dynamic
/cfc/user.cfc - confirmation support and dynamic title
/cfc/galleon.cfc - use a cfm file
/includes/udf.cfm - various
/pagetemplates/main_* - Support dynamic title, show version
/stylesheets/style.css - minor change to footer
/tags/datatabase.cfm - confirmation support
/tags/breadcrumbs.cfm - minor layout mod
/Application.cfm - Better admin check, logout fix
/confirm.cfm - new file
/threads.cfm - show last user
/search.cfm - auto focus on search box
/login.cfm - require confirmation changes
/index.cfm, /forums.cfm - show last user
/installation - Word doc updated, PDF version added, and SQL install files updated

1.6 (beta released July 6, 2006)
These notes are NOT complete. Install instructions NOT updated. File headers NOT updated.
Please add "confirmed" as a bit property to the users table. Better release notes to ship in the 
final 1.6 version.

1.5 (no new version number) (released 11/22/05)
/cfcs/conference.cfc - restrict length of search term and delete subscription clean ip
/cfcs/forum.cfc - ditto
/cfcs/message.cfc - just search term limit
/cfcs/thread.cfc - search limit + sub fix (as conference.cfc)
/pagetemplates/* All updated to turn off cfoutput only, and changed footer
/stylesheets/style.css - added style for footer a
/tags/pagination.cfm - another IE bug fix
/search.cfm - limit size of searchstring
/messages.cfm - allow bigger titles 
/install/ SQL scripts updated to reflect bigger message title.

1.5 (no new version number) (released 10/10/05)
/pagetemplates/main_header.cfm - quick mod to login link on top
/members.cfm - fixes for IE bug, and prevent message add if not logged in

1.5 (no new version) (released 10/6/05)
/cfcs/user.cfc - fixed bug with subscribe 
/pagetemplates/main_header.cfm

1.5 (released 9/15/05)
/cfcs/conferences.cfc - getConferences returns threadid of last post
/cfcs/forum.cfc - getForums returns threadid of last post
/includes/udf.cfm - udfs in support of sorting mainly
/installation/mysql.sql - missing ; at end
/stylesheets/style.css - change to support sorting
/Application.cfm - support for sorting
/forums.cfm - ditto
/index.cfm - ditto 
/messages.cfm - ditto
/threads.cfm - ditto

The last 4 files also had a bug fix applied to paging, and links to last posts added.

/Application.cfm - use an error template, error.cfm

1.4.1  (released 9/9/05)
Admin pages expanded again to give more room. More information shows up as well. So for example, you see in the messages table the thread, forum, 
and conference the message belongs to. 

/admin/conferences.cfm - changed columns
/admin/forums.cfm - ditto
/admin/messages.cfm - ditto
/admin/threads.cfm - ditto
/cfcs/message.cfm - new cols return on getAll
/cfcs/settings.ini - new version
/pagetemplates/admin_header.cfm - small formatting changes
/stysheets/style.css - ditto
/tags/datatable.cfm - sorting added (finally)


1.4 (released 8/29/05)
Unfortunately, I can't really list out the files that have changed since pretty much all files 
have changed. Here are the changes in features:

No need for a mapping.
A new settings.ini property, tableprefix, allows you to specify a prefix in front of each table name.

So what does this mean? Your old table names would have looked like: conferences, threads, etc. If
you needed to put these tables into an existing database, it may conflict with existing tables. Now
you can use table names with a prefix, like galleon_. Update the settings file with this prefix, and
Galleon will use the prefix when performing sql operations.

Default install scripts use table names with galleon_ in front. Default settings.ini file uses this
as a prefix.

Sticky Threads: If a thread is marked as sticky, it will sit on top of the forum.

Ranks: Allows you to give ranks to people based on the number of posts they have created.

Admin - updated the look a tiny bit, and moved some general stats to the default admin home page.



1.3.7 (released 8/9/05)
/rss.cfm - Links in the RSS need to be unique, so added a row counter. Thanks to Tom Thomas
/messages.cfm - Fix typo
/pagetemplates/main_header.cfm - Add Firefox auto-rss. Thanks to Tom Thomas.
/stylesheets/style.css - fix for links in message footer


1.3.6 (released 8/3/05)
/admin/users.cfm and /admin/users_edit.cfm - fixes to bugs related to 1.3.5
/cfcs/user.cfc - ditto above
/pagetemplates/main_header.cfm - Use meta tags
/messages.cfm and /newpost.cfm - refresh user cache on post
/messages.cfm - reworked the bottom link a bit

1.3.5 (released 7/29/05)
This releases changes how subscriptions work. In the past, as a user, you would just say yes or no to getting
email when people post to threads you posted to. Now you have explicit control over what you subscribe to.

You must updated your database. There is a new table, subscriptions.
Also, the users table has removed the "sendnotifications" column.

/profile.cfm, /login.cfm - changes to subscription support
/forums.cfm - pass mode to pagination tag
/messages.cfm, /newport.cfm - subscribe option
/cfc/user.cfc and messages.cfc - changes for subscription
/tags/pagination.cfm - show button
All db scripts updated.


1.3.4 (released 7/15/05)
cfcs/messages.cfc - I pass in the settings now.
cfc/application.cfc renamed to galleon.cfc
stylesheets/style.css - updated with a new style
tags/pagination.cfm - changed rereplace to a nocase version
messages.cfm - links to invidual messages, and hide bogus error msg


1.3.3 (release 6/17/05)
Just changed the Reply link to make it auto go to login if not logged on

1.3.2 (Release April 15, 2005)
Fix in getForums for MS Access in forum.cfc
Minor layout bugs fixed in index.cfm and forums.cfm
When we auto-push in index.cfm, addToken=false

1.3.1 (Released April 8, 2005)
Fixed a bug in page counting: index.cfm, forums.cfm, threads.cfm, messages.cfm 
Removed lastupdated stuff in admin as I'm tired of updating it.

1.3 (Released April 6, 2005)
Msg count and last post in conf/forums

1.2 (Released March 31, 2005)
Re-arranged a bit about you post stuff.
Re-arranged display of posts a bit.
Fixed bad Util call in messages.cfc.
Remember-me functionality.

1.1.1 (Released February 3, 2005)
Fix to conference.cfc getLatestPosts() error for mysql
Update admin/index.cfm with version #.

1.1 (Released February)
Support for mysql, msaccess. Search update

--------------------------------
License

This software is free to everyone. You can use it any way you want to. You can use it for a commercial site.
You can use it for a free site. Please don't ask me if you can use the software. You can use it. Trust me.

If you like this software and you find that it saves you time, I ask that you please donate to my Amazon wishlist:

http://www.amazon.com/o/registry/2TCL1D08EZEYE


If you find a bug or want to suggest a new feature, please use the Forums themselves at ray.camdenfamily.com/forums

