Welcome to the ColdBox Application Template

This is a skeleton for you to start a new ColdBox application. Below is a sample
ColdBox application directory structure.  You need to follow this structure in order
for ColdBox to work.

******************************************************************************
Sample Directory Structure For Your Application
******************************************************************************
-ApplicationFolder
	-config (Your config folder, where your config.xml.cfm resides) REQUIRED
	-handlers (Your ColdBox event handlers) REQUIRED
	-layouts  (Your layouts) REQUIRED
	-views (Your views, can be orgainzed in folders) REQUIRED
	-includes (Your include files if used.) OPTIONAL
	-tags (Your cf tags if used) OPTIONAL
	-images (Your images) OPTIONAL
	-logs (For ColdBox Logging) OPTIONAL
	-{Any other folder(s) you want} OPTIONAL
	
******************************************************************************
NAMING CONVENTIONS
******************************************************************************
Views (Optional): All my views start with 'vw'
	ex: vwMyview.cfm, vwHello.cfm

Layouts (Optional): All my layouts start with 'Layout.'
	ex: Layout.Main.cfm, Layout.Open.cfm, Layout.Popup.cfm

Event Handlers (REQUIRED): 

All event handlers method calls follow this regular expression:
"^eh[a-zA-Z]+\.(dsp|do|on)[a-zA-Z]+"
and they need to have an access of public

ex: ehGeneral.doLogin, ehTools.doParse, ehGeneral.dspHome, ehGeneral.dspContactInfo

All event handlers start with 'eh' + the name.
ex: ehGeneral.cfc, ehLuis.cfc, ehTools.cfc, ehBase.cfc

Valid PUBLIC method names should start with "on, dsp, do"

******************************************************************************
QUICK START
******************************************************************************
How to start? 
Start of by copying the ApplicationTemplate folder to your web root and
name it to something you want. Then, the first place to start is your config/config.xml.cfm file.
Open it and adjust it to your liking. You can read the config.xml guide in order
to understand all the variables in this file.  

Then you need to change the name property of your Application.cfc or
Application.cfm template. So open the file Application.cfc and change the name
property to whatever you want it to be. Remember that every application will need
its own name property. Also,please note that ColdBox uses the session and application
scope as a requirement. The client scope needs to be enabled if using the 
messagebox or clientstorage plugin.

Once you have completed editing the config.xml file make sure that you now go to 
your CFMX administrator and create the CFMX mapping if you are using one. 

Example: {web_root}/myapplication

Then your AppMapping setting will be: myapplication

Now that you have completed editing your config and Application.cfc, you are ready to see 
results. Point your browser to your application folder and you will see a message display:

Welcome to Coldbox!!

Now get your mind out of procedural code, dive into OO Programming. Please make sure
to fasten your seat belts, it WILL GET BUMPY!!


