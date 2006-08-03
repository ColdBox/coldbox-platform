Welcome to the ColdBox Application Template

This is a skeleton for you to start your ColdBox application. Below is a sample
ColdBox application directory structure.  You need to follow this structure in order
for ColdBox to work.

******************************************************************************
Sample Directory Structure For Your Application
******************************************************************************
-ApplicationFolder
	-system (ColdBox System folder) REQUIRED
	-config (Your config folder, where your config.xml.cfm resides) REQUIRED
	-handlers (Your ColdBox event handlers) REQUIRED
	-layouts  (Your layouts) REQUIRED
	-views (Your views, can include folders) REQUIRED
	-includes (Your include files if used.) OPTIONAL
	-tags (Your cf tags if used) OPTIONAL
	-images (Your images) OPTIONAL	
	-{Any other folder(s) you want} OPTIONAL
******************************************************************************
NAMING CONVENTIONS
******************************************************************************
Views (Optional): All my views start with 'vw'
	ex: vwMyview.cfm, vwHello.cfm

Layouts (Optional): All my layouts start with 'Layout.'
	ex: Layout.Main.cfm, Layout.Open.cfm, Layout.Popup.cfm

Event Handlers (Required): 
All event handlers method calls follow this regular expression:
"^eh[a-zA-Z]+\.(dsp|do|on)[a-zA-Z]+"
ex: ehGeneral.doLogin, ehTools.doParse, ehGeneral.dspHome, ehGeneral.dspContactInfo
All event handlers start with 'eh' + the name.
ex: ehGeneral.cfc, ehLuis.cfc, ehTools.cfc, ehBase.cfc
******************************************************************************
QUICK START
******************************************************************************
How to start? 
Start of by copying the ApplicationTemplate folder to your web root and
name it to something you want. Then, the first place to start is your config/config.xml.cfm file.
Open it and adjust it to your liking. You can read the config.xml guide in order
to understand all the variables in this file.  

Then you need to change the name property of your Application.cfc or
Application.cfm template. So open the file Application.cfc and change the this.name
property to whatever you want it to be. Remember that every application will need
its own name property. Also,please note that ColdBox uses the client scope and session 
scope. So both of these scopes will need to be active in order for the framework to work.

Once you have completed editing the config.xml file make sure that you now go to 
your CFMX administrator and create the CFMX mapping if needed. If your application
lies on the root of your server, then you do not need a mapping. The mapping will
be left blank.

Now that you have a mapping,if used, you will need to alter the default event handler provided,
ehGeneral, in order to extend the base eventhandler.cfc located in the system folder of 
your current application.

Every event handler that you code needs to extend this base cfc. Open the file and enter 
the name of the mapping in the extends property. Your extends property should look similar to 
the one below:

extends="MyMapping.system.eventhandler"

Now that you have completed editing your config, Application.cfc and your first
event handler, you are ready to see results. Point your browser to your application
folder and you will see a message display:

Welcome to Coldbox!!

Now get your mind out of procedural code, dive into OO Programming. Please make sure
to fasten your seat belts, it WILL GET BUMPY!!

NOTES:
Please note that in order to use the clientstorage and the messagebox plugin you 
will need to have the client scope activated.

MAKE SURE YOUR SYSTEM FOLDER IS IN YOUR APPLICATION ROOT, YOU CAN COPY IT THER OR 
CREATE A SYMBOLIC LINK, THAT IS UP TO YOU.