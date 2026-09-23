<cfoutput>
<div class="perf-complex">
	<section class="users">
		<h3>Users (#prc.users.len()#)</h3>
		<ul>
		<cfloop array="#prc.users#" item="u">
			<li>#u.id# — #u.firstName# #u.lastName# &lt;#u.email#&gt; [#u.role#]</li>
		</cfloop>
		</ul>
	</section>

	<section class="products">
		<h3>Products (#prc.products.len()#)</h3>
		<ul>
		<cfloop array="#prc.products#" item="p">
			<li>#p.id# — #p.name# (#p.sku#) $#numberFormat( p.price, "9.99" )# — #p.category#</li>
		</cfloop>
		</ul>
	</section>
</div>
</cfoutput>
