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
   
   
If you find this blog worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). Gifts are always welcome. ;)
Install directions may be found in BlogCFC.doc/pdf.

Last Updated: June 9, 2006 (BlogCFC 5.005)
/org/camden/blog/blog.cfc - Changed access attribute on a few methods (thanks Pete F)
/client/includes/pods/recentcomments.cfm - bug with cropped html
Documentation updates
/client/Application.cfm (minor sec fix, thanks Pete F)

Last Updated: June 2, 2006 (BlogCFC 5.004)
User pointed out the code that got related entries in the admin didn't filter by blog
Doc update (nothing worth noting for current users)

Last Updated: May 12, 2006 (BlogCFC 5.003)
Two security issues pointed out by Pete Freitag. Fixes in getComments/getTrackbacks

Last Updated: May 12, 2006 (BlogCFC 5.002)
/client/admin/entry.cfm - removed an extra line that was accidently duplicated 
/org/camden/blog.cfc - fixes to getComments and getRecentComments
/tag/adminlayout.cfm - add link to stats.cfm
/admin/index.cfm - just added the blog title 
/includes/main_en_us.properties - new translation
/client/stats.cfm - fix for gettopviews and added gettotalviews
	
Last Updated: May 12, 2006 (BlogCFC 5)

CAPTCHA support does not work on BlueDragon.Net.

Files: Pretty much every file changed.
Database changes include the following:

tblBlogCategories:
	categoryalias(nvarchar/50) added
	
tblBlogEntries:
	views(int) added - You must set all old views to 0
	released(bit) added - You must set your old data to released=1 with a quick query
	mailed(bit) added - You can set the old ones to true, but you don't need to)

tblBlogEntriesRelated: (New table)
	entryid (nvarchar/35)
	relatedid (nvarchar/35)

tblUsers:
	name(nvarchar/50) added - You should add your name here, or your code name. Or whatever you go by.