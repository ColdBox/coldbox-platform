<cfform>
    <cfgrid name = "FirstGrid" 
			format="html"
	        font="Tahoma" 
			fontsize="12"
			pageSize="10"
			width="100%"	
    		preservePageOnSort="yes"		
	        bind="cfc:#rc.locColdBoxProxy#.getData({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})" >
		    <cfgridcolumn name="idt" display=true header="Employee ID"/>
			<cfgridcolumn name="fname" display=true header="First Name"/>
			<cfgridcolumn name="lname" display=true header="Last Name"/>
    </cfgrid>
</cfform>
