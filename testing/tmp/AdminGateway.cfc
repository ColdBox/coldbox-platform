component  displayname="AdminGateway" hint="Admin gateway page" output="false" 
		   extends="shared.api.tc.baseResources.Gateway"
{
	this.approvedFilterCondition = 'eq,cn';
	this.approvedSortOrder = 'asc,desc';
	/**
	* constructor
	*/
	public AdminGateway function init(){
		super.init();
		return this;
	}

	/**
	@hint returns the search result found using hql query
	*/	
	public any function searchByQuery( required string entityName,
												string filterField ='',
												string filterCondition ='',
												string filterValue = '',
												string sortOrder='',
												string sortColumn='',
												numeric maxResults = 10,
												numeric offset = 0,
												boolean asQuery = true){
		var returnResult = "";
		var hql = 'from #arguments.entityName#';
		var options = {maxresults = arguments.maxresults, offset = arguments.offset};
		var params = {};
		
		
		try{
		// set the filter conditions
			if (len(arguments.filterField) > 0 and 
			    len(arguments.filterCondition) > 0 and 
				len(arguments.filterValue) > 0 and 
				listFindNoCase(this.approvedFilterCondition,arguments.filterCondition,',') > 0){
				switch (arguments.filterCondition){
					case 'eq':
						hql = hql & " where #arguments.filterField#=:filterValue";
						params.filterValue = arguments.filterValue; 
					break;
					case 'cn':
						hql = hql & " where #arguments.filterField# like :filterValue";
						params.filterValue = '%#arguments.filterValue#%';
					break;
				}
			}
			
			//set the sort order
			if (len(arguments.sortColumn) > 0 and 
			    len(arguments.sortOrder) > 0 and 
				listFindNoCase(this.approvedSortOrder,arguments.sortOrder,',') > 0){
						hql = hql & " order by #arguments.sortColumn# #arguments.sortOrder#";
			}
	
			returnResult = ormExecuteQuery(getUtility().sqlSafe(hql),params,false,options);
		
			if (arguments.asQuery eq true)
				returnResult =  EntityToQuery(returnResult);
		}catch (any e){
			rethrow;
			//do nothing
		}
		return returnResult;
	}
	
	/**
	@hint returns the total no of records found using hql query
	*/
	public numeric function getSearchCountByQuery( required string entityName,
												string filterField ='',
												string filterCondition ='',
												string filterValue = ''
											 ){
		var totalrecods = 0;
		var hqlTotalCount = 'select count(*) as totalCount from #arguments.entityName#';
		var params = {};

		try{
			// set the filter conditions
			if (len(arguments.filterField) > 0 and 
			    len(arguments.filterCondition) > 0 and 
				len(arguments.filterValue) > 0 and 
				listFindNoCase(this.approvedFilterCondition,arguments.filterCondition,',') > 0){
				switch (arguments.filterCondition){
					case 'eq':
						hqlTotalCount = hqlTotalCount & " where #arguments.filterField#=:filterValue";
						params.filterValue = arguments.filterValue; 
					break;
					case 'cn':
						hqlTotalCount = hqlTotalCount & " where #arguments.filterField# like :filterValue";
						params.filterValue = '%#arguments.filterValue#%';
					break;
				}
			}
	
			totalRecords = ormExecuteQuery(getUtility().sqlSafe(hqlTotalCount),params,true);
		}catch(any e){
			rethrow;
			//do nothing
		}

		return totalRecords;
	}
}