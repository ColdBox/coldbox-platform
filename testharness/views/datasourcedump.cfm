<div style="border:2px solid #53231d; padding:5px; background-color: #FFFFF0">
<cfoutput>
<cfset mysiteDSNBean = getColdBoxOCM().get("mysiteDSNBean")>
<h2>Datasource: #mysiteDSNBean.getname()#</h2>
<p>#now()#</p>
Database: #mysiteDSNBean.getdbtype()# <br>
Username: #mysiteDSNBean.getusername()# <br>
Password: #mysiteDSNBean.getpassword()#
</cfoutput>
</div>