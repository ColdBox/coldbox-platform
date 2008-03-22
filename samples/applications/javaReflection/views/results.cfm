<cfoutput>
<!--- Render Form --->
#renderView('home')#

<!--- Render Results --->
<cfoutput>


<table width="100%" class="classHeaderTable" cellpadding="3" cellspacing="0">
	<tr>
		<td class="label">Package:</td>
		<td width="100%" >#rc.reflection.package#</td>
	</tr>
	<tr>
		<td class="label">
			<cfif rc.reflection.isInterface>
				Interface:
			<cfelse>
				Class:
			</cfif>
		</td>
		<td>#rc.reflection.name#</td>
	</tr>
	<tr>
		<td class="label">
			Modifiers:
		</td>
		<td>#rc.reflection.modifiers#</td>
	</tr>
	
	<cfif NOT rc.reflection.isInterface>
		<tr>
			<td class="label">Inheritance:</td>
			<td colspan="2">
				<cfloop from="#ArrayLen(rc.reflection.superclasses)#" to="1" index="x" step="-1">
					<p style="padding-left: #(ArrayLen(rc.reflection.superclasses) - x)*30#px;margin:5px">
						|-----+<a href="#event.getSelf()##rc.xehDoReflection#&className=#rc.reflection.superclasses[x]#">#rc.reflection.superclasses[x]#</a>
					</p>
				</cfloop>
				<p style="padding-left: #(ArrayLen(rc.reflection.superclasses))*32#px;margin:5px">|---+#rc.reflection.package#.#rc.reflection.name#</p>
			</td>
		</tr>
	</cfif>
	
	<tr>
		<td class="label">Implemented Interfaces:</td>
		<td>
			<cfif ArrayLen(rc.reflection.interfaces)>
				<cfloop from="1" to="#ArrayLen(rc.reflection.interfaces)#" index="x">
					<a href="#event.getSelf()##rc.xehDoReflection#&className=#rc.reflection.interfaces[x]#">#ListLast(rc.reflection.interfaces[x], ".")#</a>
				</cfloop>
			<cfelse>
				<p><i>None</i></p>
			</cfif>
		</td>
	</tr>
	
	<tr>
		<td class="label">
			Inner Classes:
		</td>
		<td>
			<cfif ArrayLen(rc.reflection.NestedClasses)>
				<cfloop from="1" to="#ArrayLen(rc.reflection.NestedClasses)#" index="x">
					<a href="#event.getSelf()##rc.xehDoReflection#&className=#rc.reflection.NestedClasses[x]#">#ListLast(rc.reflection.NestedClasses[x], ".")#</a>
				</cfloop>
			<cfelse>
				<p><i>None</i></p>
			</cfif>
		</td>
	</tr>
	
	<tr>
		<td class="label">
			String Value:

		</td>
		<td>#rc.reflection.stringrepresentation#</td>
	</tr>
	
</table>

<hr size="1">

<div class="summaryTableTitle">Methods summary</div>

<cfif ArrayLen(rc.reflection.fields)>
	<table width="100%" class="summaryTable" cellpadding="5" cellspacing="0">
		<th colspan="2">
			Fields
		</tr>
		
		<tr>
			<td class="label">
				Field
			</td>
			<td class="label">
				Static Value
			</td>
		</tr>
		<cfloop from="1" to="#ArrayLen(rc.reflection.fields)#" index="x">
			<tr>
				<td>
					#rc.reflection.fields[x].modifiers#
					<cfif NOT rc.reflection.fields[x].IsPrimitive>
						<a href="#event.getSelf()##rc.xehDoReflection#&className=#rc.reflection.fields[x].type#">#rc.reflection.fields[x].type#</a>
					<cfelse>
						#rc.reflection.fields[x].type#
					</cfif>
					#rc.reflection.fields[x].name#
				</td>
				<td>
					<cfif StructKeyExists(rc.reflection.fields[x], "staticValue")>
						<cfif IsObject(rc.reflection.fields[x].staticValue)>
							#rc.reflection.fields[x].staticValue.getClass().getName()#
						<cfelse>
							#rc.reflection.fields[x].staticValue#
						</cfif>
					<cfelse>
						<p><i>None</i></p>
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
	
<cfif ArrayLen(rc.reflection.constructors)>
	<table width="100%" class="summaryTable" cellpadding="5" cellspacing="0">
		<th colspan="3">Constructors</th>
		<cfloop from="1" to="#ArrayLen(rc.reflection.constructors)#" index="x">
			<tr>
				<td  nowrap="true">#rc.reflection.constructors[x].Modifiers#</td>
				<td  nowrap="true">#rc.reflection.name#</td>
				<td width="100%">
					<strong>#rc.reflection.constructors[x].name#</strong>(
					<cfloop from="1" to="#ArrayLen(rc.reflection.constructors[x].Parameters)#" index="y">
						<cfif Find(".", rc.reflection.constructors[x].parameters[y]) GT 1>
							<a href="#event.getSelf()##rc.xehDoReflection#&className=#rc.reflection.constructors[x].parameters[y]#">#rc.reflection.constructors[x].parameters[y]#</a>
						<cfelse>
							#rc.reflection.constructors[x].parameters[y]#
						</cfif>
						
						<cfif y IS NOT ArrayLen(rc.reflection.constructors[x].Parameters)>, </cfif>
					</cfloop>
					)
				</td>
			</tr>
		</cfloop>
	</table>		
</cfif>

<cfif ArrayLen(rc.reflection.methods)>
	<table width="100%" class="summaryTable" cellpadding="5" cellspacing="0">
		<th colspan="3">
			Methods
		</th>
		<cfloop from="1" to="#ArrayLen(rc.reflection.methods)#" index="x">
			<tr>
				<td nowrap="true">#rc.reflection.methods[x].MODIFIERS#</td>
				
				<td  nowrap="true">
					<cfif Find(".", rc.reflection.methods[x].returnType) GT 1>
						<a href="#event.getSelf()##rc.xehDoReflection#&className=#rc.reflection.methods[x].returnType#">#rc.reflection.methods[x].returnType#</a>
					<cfelse>
						#rc.reflection.methods[x].returnType#
					</cfif>
				</td>
				
				<td width="100%">
					<strong>#rc.reflection.methods[x].name#</strong>(
						<cfloop from="1" to="#ArrayLen(rc.reflection.methods[x].Parameters)#" index="y">
							<cfif Find(".", rc.reflection.methods[x].parameters[y]) GT 1>
								<a href="#event.getSelf()##rc.xehDoReflection#&className=#rc.reflection.methods[x].parameters[y]#">#rc.reflection.methods[x].parameters[y]#</a>
							<cfelse>
								#rc.reflection.methods[x].parameters[y]#
							</cfif>
							
							<cfif y IS NOT ArrayLen(rc.reflection.methods[x].Parameters)>, </cfif>
						</cfloop>
					)
				</td>
			</tr>
		</cfloop>
	</table>		
</cfif>

</cfoutput>
</cfoutput>