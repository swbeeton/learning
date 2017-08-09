;( function ( global ) {

    // The following mimics a Constructor (Part 1)
    var LDSPNewsModel = function ( options, cb ) {		
		return new LDSPNewsModel.init( options, cb );                       
    }
    
    // Private Constants
	
	var context;
	
	// default options
	var options = {
		siteUrl: "/TASites/LearningHub/V2_Redevelopment",
		list: "News",
		joinList: "News Categories",
		joinField: "Category",
		projectedFields: ["headlineA", "headlineB", ],
		viewFields: ["Category_HeadlineA", ],
		orderBy: "",
		orderAsc: true,
		pagingInfo: "",
		pageIndex: 1,
		rowLimit: 2
	};	
	    
	var articles = [];
	
	// Public functions
    LDSPNewsModel.prototype = {
		
        getNews: function( cb ) { 
		
		    var self = this;
			
			// SP JSOM code
		
			var oList = context.get_web().get_lists().getByTitle(options.list); // Define the query
			
			var camlQuery = new SP.CamlQuery();
						
			camlQuery.set_viewXml(
				"<View>" +
				
					"<Joins>" +
						"<Join Type='LEFT' ListAlias='News Categories'>" +
							"<Eq>" +
								"<FieldRef Name='Category' RefType='Id' />" +
								"<FieldRef List='News Categories' Name='ID' />" +
							"</Eq>" +
						"</Join>" +
					"</Joins>" +
					
					"<ProjectedFields>" +
						"<Field Name='Category_HeadlineA' Type='Lookup' List='News Categories' ShowField='HeadlineA' />" +
						"<Field Name='Category_HeadlineB' Type='Lookup' List='News Categories' ShowField='HeadlineB' />" +
						"<Field Name='Category_Title' Type='Lookup' List='News Categories' ShowField='Title' />" +
					"</ProjectedFields>" +
					
					"<ViewFields>" +
					  "<FieldRef Name='Category_HeadlineA' />" +
					  "<FieldRef Name='Category_HeadlineB' />" +
					  "<FieldRef Name='Title' />" +
					  "<FieldRef Name='Action' />" +
					"</ViewFields>" +
					
					"<Query>" +
						// "<Where>" +
							// "<Geq>" +
								// "<FieldRef Name='Order0'/>" +
								// "<Value Type='Number'>1</Value>" +
							// "</Geq>" +
						// "</Where>" +
						"<OrderBy>" + 
                            "<FieldRef Name='" + options.orderBy + "' Ascending='true' />" + 
                        "</OrderBy>" + 

					"</Query>" +
					"<RowLimit>" + options.rowLimit + "</RowLimit>" +
					
				"</View>");
				
			// Paging stuff	
				
			camlQuery.set_listItemCollectionPosition(options.pagingInfo);
				
			var collListItem = oList.getItems(camlQuery);

			context.load(collListItem);
			
			context.executeQueryAsync( // Fetch the query results
				// On Success do this
				function ( sender , args ){
					
					articles = [];
					
					var listItemEnumerator = collListItem.getEnumerator();
        
					while (listItemEnumerator.moveNext()) {
						
						var oListItem = listItemEnumerator.get_current();
								
						articles.push({
							headlineA: oListItem.get_item('Category_HeadlineA').get_lookupValue(),
							headlineB: oListItem.get_item('Category_HeadlineB').get_lookupValue(),
							title: oListItem.get_item('Title').replace(/(?:\r\n|\r|\n)/g, '<br />'),
							action_description: oListItem.get_item('Action').get_description(),
							action_url: oListItem.get_item('Action').get_url()
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
		
		setQueryOptions: function ( optionsList ) {	options = optionsList; },
		
		setSPContext: function (SPsiteUrl) { context = new SP.ClientContext(SPsiteUrl) }, // Define the SharePoint context}
		
		get_pagingInfo: function () { return options.pagingInfo },
		
		set_pagingInfo: function ( direction ) { 
			if (direction == "prev") {
				options.pagingInfo = new SP.ListItemCollectionPosition();
				options.pagingInfo.set_pagingInfo("PagedPrev=TRUE&Paged=TRUE&p_ID=" + options.prevIndex );
				options.pageIndex = options.pageIndex - 2;
			}
		},
		
		get_pageIndex: function ( ) { return options.pageIndex },
		
        getArticles: function ( ) { return articles; }

    };

    // The following mimics a Constructor (Part 2)
    LDSPNewsModel.init = function ( options, cb ) {
		
		this.setSPContext(options.siteUrl);
		this.validateQueryOptions(options).setQueryOptions(options);
		this.getNews( cb ); 
		return this 
		
	}
    
    // The following mimics a Constructor (Part 3)
    LDSPNewsModel.init.prototype = LDSPNewsModel.prototype;
    
    // Sets LDSPNewsModel and U$ to be an alias of of this class in the global namespace 
    global.LDSPNewsModel = global.N$ = LDSPNewsModel;

}( window ))
