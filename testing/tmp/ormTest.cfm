<cfscript>

test = ORMExecuteQuery('from User where id=:id',{id='123'},false,{});
		
writeDump(test);
abort;
</cfscript>