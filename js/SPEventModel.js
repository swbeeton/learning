;( function ( global ) {

    // The following mimics a Constructor (Part 1)
    var LDSPEventModel = function ( options, cb ) {		
		return new LDSPEventModel.init( options, cb );                       
    }
    
    // Private Constants
	
	var context;
	
	// default options
	var options = {};
	    
	var result = [];
	
	// Public functions
    LDSPEventModel.prototype = {
		
        get_results: function( cb ) { 
		
		    var self = this;
			
			// SP JSOM code
		
			var oList = context.get_web().get_lists().getByTitle(options.list); // Define the query
			
			var camlQuery = new SP.CamlQuery();
			
			var query = 				
				"<View>" +
				
					"<Joins>" +
						"<Join Type='LEFT' ListAlias='Events'>" +
							"<Eq>" +
								"<FieldRef Name='Event_x0020_Name' RefType='Id' />" +
								"<FieldRef List='Events' Name='ID' />" +
							"</Eq>" +
						"</Join>" +
						"<Join Type='LEFT' ListAlias='Resources'>" +
							"<Eq>" +
								"<FieldRef List='Events' Name='Name' RefType='Id' />" +
								"<FieldRef List='Resources' Name='ID' />" +
							"</Eq>" +
						"</Join>" +
					"</Joins>" +
					
					"<ProjectedFields>" +
						"<Field Name='Events_Session_Size' Type='Lookup' List='Events' ShowField='Session_x0020_Size' />" +
						"<Field Name='Events_Note' Type='Lookup' List='Events' ShowField='Event_x0020_Note' />" +
						"<Field Name='Events_Type' Type='Lookup' List='Events' ShowField='Event_x0020_Type_x0020_Calculate' />" +
						"<Field Name='Events_Status' Type='Lookup' List='Events' ShowField='Planning_x0020_Status_x0020_Calc' />" +
						"<Field Name='Resources_Title' Type='Lookup' List='Resources' ShowField='Title' />" +
						"<Field Name='Resources_Short_Description' Type='Lookup' List='Resources' ShowField='Short_x0020_Description' />" +
					"</ProjectedFields>" +
					
					"<ViewFields>" +
					  "<FieldRef Name='Events_Type' />" +
					  "<FieldRef Name='Events_Status' />" +
					  "<FieldRef Name='Events_Session_Size' />" +
					  "<FieldRef Name='Events_Note' />" +
					  "<FieldRef Name='Resources_Title' />" +
					  "<FieldRef Name='Resources_Short_Description' />" +
					  "<FieldRef Name='Start_x0020_Time' />" +
					  "<FieldRef Name='End_x0020_Time' />" +
					  "<FieldRef Name='Site' />" +
					  "<FieldRef Name='Room' />" +
					  "<FieldRef Name='Event_x0020_Name' />" +
					"</ViewFields>" +					

					"<Query>"+
						this.set_query(options.where) + 
						"<OrderBy>" + 
                            "<FieldRef Name='" + options.orderBy + "' Ascending='" + options.orderAsc + "' />" + 
                        "</OrderBy>" + 
					"</Query>" +
					"<RowLimit>" + options.rowLimit + "</RowLimit>" +
				
				"</View>";	
				
			console.log(query);
										
			camlQuery.set_viewXml(query);
				
			// Paging stuff	
				
			camlQuery.set_listItemCollectionPosition(options.pagingInfo);
				
			var collListItem = oList.getItems(camlQuery);

			context.load(collListItem);
			
			context.executeQueryAsync( // Fetch the query results
				// On Success do this
				function ( sender , args ){
					
					var listItemEnumerator = collListItem.getEnumerator();
					
					result=[];
        
					while (listItemEnumerator.moveNext()) {
					
						var newsListItem = listItemEnumerator.get_current();
								
						result.push({
							title: newsListItem.get_item('Resources_Title').get_lookupValue(),
							short_description: newsListItem.get_item('Resources_Short_Description').get_lookupValue(),
							site: newsListItem.get_item('Site'),
							// site: newsListItem.get_item('Events_Site').get_lookupValue().split(";#").filter(function(n){ return n != '' }).join(', '),
							note: newsListItem.get_item('Events_Note').get_lookupValue(),
							start_time: newsListItem.get_item('Start_x0020_Time'),
							end_time: newsListItem.get_item('End_x0020_Time'),
							duration: newsListItem.get_item('End_x0020_Time') - newsListItem.get_item('Start_x0020_Time'),
							room: newsListItem.get_item('Room'),
							type: newsListItem.get_item('Events_Type').get_lookupValue(),
							eventId: newsListItem.get_item('Event_x0020_Name').get_lookupValue()
						});
					
					}
					
					// PAGING: Query successful, let's set the positions for the next and previous buttons.
					if (result.length) {
						options.pagingInfo = collListItem.get_listItemCollectionPosition();
						options.pageIndex = options.pageIndex + 1;
						options.prevIndex = collListItem.itemAt(0).get_item('ID');
					}
										
					// Run the callback
					cb ( self );
					
					return this;
					
				},
				// On Fail do this
				function ( sender , args ) { 
					alert('request failed ' + args.get_message() + '\n' + args.get_stackTrace());
				}
				
			);
			
        },
		
        get_result: function( cb ) { 
		
		    var self = this;
			
			// SP JSOM code
		
			var oTimesList = context.get_web().get_lists().getByTitle("Event Times"); 
			var oEventList = context.get_web().get_lists().getByTitle("Events");
			var oResourcesList = context.get_web().get_lists().getByTitle("Resources");
			
			var camlQueryTimes = new SP.CamlQuery();
			var camlQueryEvent = new SP.CamlQuery();
			var camlQueryResources = new SP.CamlQuery();
			
			var query = 				
				"<View>" +
				
					"<Joins>" +
						"<Join Type='LEFT' ListAlias='Events'>" +
							"<Eq>" +
								"<FieldRef Name='Event_x0020_Name' RefType='Id' />" +
								"<FieldRef List='Events' Name='ID' />" +
							"</Eq>" +
						"</Join>" +
						"<Join Type='LEFT' ListAlias='Resources'>" +
							"<Eq>" +
								"<FieldRef List='Events' Name='Name' RefType='Id' />" +
								"<FieldRef List='Resources' Name='ID' />" +
							"</Eq>" +
						"</Join>" +
					"</Joins>" +
					
					"<ProjectedFields>" +
						"<Field Name='Events_Session_Size' Type='Lookup' List='Events' ShowField='Session_x0020_Size' />" +
						"<Field Name='Events_Note' Type='Lookup' List='Events' ShowField='Event_x0020_Note' />" +
						"<Field Name='Events_Type' Type='Lookup' List='Events' ShowField='Event_x0020_Type_x0020_Calculate' />" +
						"<Field Name='Events_Status' Type='Lookup' List='Events' ShowField='Planning_x0020_Status_x0020_Calc' />" +
						"<Field Name='Resources_Title' Type='Lookup' List='Resources' ShowField='Title' />" +
						"<Field Name='Resources_Short_Description' Type='Lookup' List='Resources' ShowField='Short_x0020_Description' />" +
					"</ProjectedFields>" +
					
					"<ViewFields>" +
					  "<FieldRef Name='Events_Type' />" +
					  "<FieldRef Name='Events_Status' />" +
					  "<FieldRef Name='Events_Session_Size' />" +
					  "<FieldRef Name='Events_Note' />" +
					  "<FieldRef Name='Resources_Title' />" +
					  "<FieldRef Name='Resources_Short_Description' />" +
					  "<FieldRef Name='Start_x0020_Time' />" +
					  "<FieldRef Name='End_x0020_Time' />" +
					  "<FieldRef Name='Site' />" +
					  "<FieldRef Name='Room' />" +
					  "<FieldRef Name='Event_x0020_Name' />" +
					"</ViewFields>" +					

					"<Query>"+
						this.set_query(options.where) + 
						"<OrderBy>" + 
                            "<FieldRef Name='" + options.orderBy + "' Ascending='" + options.orderAsc + "' />" + 
                        "</OrderBy>" + 
					"</Query>" +
					"<RowLimit>" + options.rowLimit + "</RowLimit>" +
				
				"</View>";	

			camlQuery.set_viewXml(query);
				
			// Paging stuff	
				
			camlQuery.set_listItemCollectionPosition(options.pagingInfo);
				
			var collListItem = oList.getItems(camlQuery);

			context.load(collListItem);
			
			context.executeQueryAsync( // Fetch the query results
				// On Success do this
				function ( sender , args ){
					
					var listItemEnumerator = collListItem.getEnumerator();
					
					result=[];
        
					while (listItemEnumerator.moveNext()) {
					
						var newsListItem = listItemEnumerator.get_current();
								
						result.push({
							title: newsListItem.get_item('Resources_Title').get_lookupValue(),
							short_description: newsListItem.get_item('Resources_Short_Description').get_lookupValue(),
							site: newsListItem.get_item('Site'),
							// site: newsListItem.get_item('Events_Site').get_lookupValue().split(";#").filter(function(n){ return n != '' }).join(', '),
							note: newsListItem.get_item('Events_Note').get_lookupValue(),
							start_time: newsListItem.get_item('Start_x0020_Time'),
							end_time: newsListItem.get_item('End_x0020_Time'),
							duration: newsListItem.get_item('End_x0020_Time') - newsListItem.get_item('Start_x0020_Time'),
							room: newsListItem.get_item('Room'),
							type: newsListItem.get_item('Events_Type').get_lookupValue(),
							eventId: newsListItem.get_item('Event_x0020_Name').get_lookupValue()
						});
					
					}
					
					// PAGING: Query successful, let's set the positions for the next and previous buttons.
					if (result.length) {
						options.pagingInfo = collListItem.get_listItemCollectionPosition();
						options.pageIndex = options.pageIndex + 1;
						options.prevIndex = collListItem.itemAt(0).get_item('ID');
					}
										
					// Run the callback
					cb ( self );
					
					return this;
					
				},
				// On Fail do this
				function ( sender , args ) {  alert('request failed ' + args.get_message() + '\n' + args.get_stackTrace()); }
				
			);
			
        },

		set_query: function (filters) {
			
			var num_filters = filters.length;
			
			var count = 0;
			
			var where = "<Where>";
			
			var recursive = function (item) {
				if (num_filters > 1) {
					where += "<"+item[0]+">";
				} 
				
				where += 
					"<"+item[1]+">"+
						"<FieldRef Name='"+item[2]+"'/>"+
						"<Value Type='"+item[3]+"'>"+item[4]+"</Value>"+
					"</"+item[1]+">";
				
				num_filters = num_filters - 1;
				count = count + 1;
				
				if (num_filters > 0) {
					recursive(filters[count]);
					where += "</"+item[0]+">";
				}

			}
			
			recursive(filters[0]);
			
			where += "</Where>";

			return where;
			
		},

		
		set_filter: function (filter) { options.where = filter },
		
		validateQueryOptions: function ( options ) { /* TODO: Validate options */ return this },
		
		set_queryOptions: function ( optionsList ) {	options = optionsList; },
		
		set_SPContext: function (SPsiteUrl) { context = new SP.ClientContext(SPsiteUrl) }, // Define the SharePoint context}
		
		get_pagingInfo: function () { return options.pagingInfo },
		
		set_pagingInfo: function ( direction ) { 
				
			if (direction == "prev") {
				options.pagingInfo = new SP.ListItemCollectionPosition();
				options.pagingInfo.set_pagingInfo("PagedPrev=TRUE&Paged=TRUE&p_ID=" + options.prevIndex );
				options.pageIndex = options.pageIndex - 2;
			}
			if (direction === false) {
				options.pagingInfo = new SP.ListItemCollectionPosition();
				options.pagingInfo.set_pagingInfo("");
				options.pageIndex=0;
			}
							
		},
		
		get_pageIndex: function ( ) { return options.pageIndex },
		
        get_result: function ( callback ) { return result; }

    };

    // The following mimics a Constructor (Part 2)
    LDSPEventModel.init = function ( options, cb ) {
		
		this.set_SPContext(options.siteUrl);
		this.validateQueryOptions(options).set_queryOptions(options);
		this.get_results( cb ); 
		return this 
		
	}
    
    // The following mimics a Constructor (Part 3)
    LDSPEventModel.init.prototype = LDSPEventModel.prototype;
    
    // Sets LDSPEventModel and U$ to be an alias of of this class in the global namespace 
    global.LDSPEventModel = global.E$ = LDSPEventModel;

}( window ))
