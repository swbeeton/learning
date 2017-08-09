;( function ( global ) {

    // The following mimics a Constructor (Part 1)
    var LDSPUser = function ( cb ) {
        return new LDSPUser.init( cb );                       
    }
    
    // Private Variables
    var userId = 'Default';
    var userName = '';
    var userDomain = '';
    var userEmail = '';

	// Public functions
    LDSPUser.prototype = {

        getUser: function( cb ) { 
		
            var self = this;
			
			// SP JSOM code
			var context = new SP.ClientContext("/TASites/LearningHub/V2_Redevelopment"); // Define the SharePoint context
			var web = context.get_web()
			var currentUser = web.get_currentUser(); // Define the query
			
			context.load(web,'EffectiveBasePermissions');
			context.load(currentUser); // Load the query
			
			context.executeQueryAsync( // Fetch the query results
				// On Success do this
				function ( sender , arg ){
					
					// Set the private variables
					userDomain = currentUser.get_loginName().replace('ATONET\\', '');
					userId = currentUser.get_loginName().replace('ATONET\\', '');
					userName = currentUser.get_loginName().replace('ATONET\\', '');
					userEmail = currentUser.get_loginName().replace('ATONET\\', '');
					
					console.log(web.get_effectiveBasePermissions().has(SP.PermissionKind.editListItems));
					
					// Run the callback
					cb ( self );
					
				},
				// On Fail do this
				function ( sender , arg ) { 
					alert('request failed ' + args.get_message() + '\n' + args.get_stackTrace());
				}
				
			);
			
        },                                            
        getUserDomain: function ( ) { return userDomain; },
        getUserId: function ( ) { return userId; },
        getUserName: function ( ) { return userName; },
        getUserEmail: function ( ) { return userEmail; }

    };

    // The following mimics a Constructor (Part 2)
    LDSPUser.init = function ( cb ) { this.getUser( cb ); return this }
    
    // The following mimics a Constructor (Part 3)
    LDSPUser.init.prototype = LDSPUser.prototype;
    
    // Sets LDSPUser and U$ to be an alias of of this class in the global namespace 
    global.LDSPUser = global.U$ = LDSPUser;

}( window ))
