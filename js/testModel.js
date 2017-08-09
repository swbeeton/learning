;( function ( global ) {

    // The following mimics a Constructor (Part 1)
    var LDSPEventModel = function ( options, cb ) {		
		return new LDSPEventModel.init( options, cb );                       
    }
    
    // Private Constants
	
	var context;
	
	// default options
	var options = {
		siteUrl: "/TASites/LearningHub/V2_Redevelopment",
		list: "Events",
		joinList: "Resources",
		joinField: "Name",
		projectedFields: ["headlineA", "headlineB", ],
		viewFields: ["Category_HeadlineA", ],
		orderBy: "",
		orderAsc: true,
		pagingInfo: "",
		pageIndex: 1,
		rowLimit: 2
	};	
	    
	var result = [];
	
	// Public functions
    LDSPEventModel.prototype = {
		
        get_results: function( cb ) { 
		
		    var self = this;
			
			// SP JSOM code
		
			var oList = context.get_web().get_lists().getByTitle(options.list); // Define the query
			
			var camlQuery = new SP.CamlQuery();
					
			camlQuery.set_viewXml(
				"<View>" +
				
					"<Joins>" +
						"<Join Type='INNER' ListAlias='Event_Times'>" +
							"<Eq>" +
								"<FieldRef List='Events' Name='Event_x0020_Name' />" +
								"<FieldRef List='Event_Times' Name='Event_Name' RefType='Id'/>" +
							"</Eq>" +
						"</Join>" +
						// "<Join Type='INNER' ListAlias='Resources'>" +
							// "<Eq>" +
								// "<FieldRef Name='Name' RefType='Id' />" +
								// "<FieldRef List='Resources' Name='ID' />" +
							// "</Eq>" +
						// "</Join>" +
					"</Joins>" +
					
					// "<ProjectedFields>" +
						// "<Field Name='Events_Site' Type='Lookup' List='Events' ShowField='Site_x0020_Calculated' />" +
						// "<Field Name='Events_Session_Size' Type='Lookup' List='Events' ShowField='Session_x0020_Size' />" +
						// "<Field Name='Events_Note' Type='Lookup' List='Events' ShowField='Event_x0020_Note' />" +
						// "<Field Name='Resources_Title' Type='Lookup' List='Resources' ShowField='Title' />" +
						// "<Field Name='Resources_Short_Description' Type='Lookup' List='Resources' ShowField='Short_x0020_Description' />" +
					// "</ProjectedFields>" +
					
					// "<ViewFields>" +
					  // "<FieldRef Name='Events_Site' />" +
					  // "<FieldRef Name='Events_Session_Size' />" +
					  // "<FieldRef Name='Events_Note' />" +
					  // "<FieldRef Name='Resources_Title' />" +
					  // "<FieldRef Name='Resources_Short_Description' />" +
					  // "<FieldRef Name='Start_x0020_Time' />" +
					  // "<FieldRef Name='End_x0020_Time' />" +
					// "</ViewFields>" +					

					"<Query />" +
						// "<Where>" +
							// "<Geq>" +
								// "<FieldRef Name='Start_x0020_Time'/>" +
								// "<Value Type='DateTime'>2015-08-15T00:00:00Z</Value>" +
							// "</Geq>" +
						// "</Where>" +
						// "<OrderBy>" + 
                            // "<FieldRef Name='" + options.orderBy + "' Ascending='true' />" + 
                        // "</OrderBy>" + 
					// "</Query>" +
					// "<RowLimit>" + options.rowLimit + "</RowLimit>" +
				
				"</View>");
				
			// Paging stuff	
				
			camlQuery.set_listItemCollectionPosition(options.pagingInfo);
				
			collListItem = oList.getItems(camlQuery);

			context.load(collListItem);
			
			context.executeQueryAsync( // Fetch the query results
				// On Success do this
				function ( sender , args ){
					
					var listItemEnumerator = collListItem.getEnumerator();
        
					while (listItemEnumerator.moveNext()) {
					
						var oListItem = listItemEnumerator.get_current();
								
						result.push({
							// title: oListItem.get_item('Resources_Title').get_lookupValue(),
							// short_description: oListItem.get_item('Resources_Short_Description').get_lookupValue(),
							// site: oListItem.get_item('Events_Site').get_lookupValue(),
							// room: oListItem.get_item('Room').get_lookupValue(),
							// site: oListItem.get_item('Events_Note').get_lookupValue(),
							// start_time: oListItem.get_item('Start_x0020_Time'),
							// end_time: oListItem.get_item('End_x0020_Time')
						});
					
					}
					
					// PAGING: Query successful, let's set the positions for the next and previous buttons.
					options.pagingInfo = collListItem.get_listItemCollectionPosition();
					options.pageIndex = options.pageIndex + 1;
					options.prevIndex = collListItem.itemAt(0).get_item('ID');
					
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
		},
		
		get_pageIndex: function ( ) { return options.pageIndex },
		
        get_result: function ( ) { return result; }

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
