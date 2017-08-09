<!DOCTYPE html>
<%@ Page language="C#" %>
<%@ Register Tagprefix="SharePoint"
     Namespace="Microsoft.SharePoint.WebControls"
     Assembly="Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    <!-- the following 5 js files are required to use CSOM -->
    <script src="/_layouts/1033/init.js"></script>
    <script src="/_layouts/MicrosoftAjax.js"></script>
    <script src="/_layouts/sp.core.js"></script>
    <script src="/_layouts/sp.runtime.js"></script>
    <script src="/_layouts/sp.js"></script>

    <!-- include your app code -->
	<!-- Compiled and minified CSS -->
	<!-- <link rel="stylesheet" href="/TASites/LearningHub/V2_Redevelopment/Core/styles/materialize.min.css"> -->
	<link rel="stylesheet" href="/TASites/LearningHub/V2_Redevelopment/Core/styles/LDHub.css">

  <!-- Compiled and minified JavaScript -->


</head>
<body>

<form>

<!-- ENTER WEB PART CODE HERE -->

	<!-- ENTER DEPENDANCIES HERE -->

	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/jquery-1.11.1.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/moment.min.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/mustache.js"></script>
	<link rel="stylesheet" href="/TASites/LearningHub/V2_Redevelopment/Core/styles/LDHub.css">

	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/SPHelpers.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/SPEventModel.js"></script>
	
	<!-- ADD VIEW TEMPLATES HERE -->

	<script id="event_list_tmpl" type="x-tmpl-mustache">

		{{#events}}

			<div class="event_details">			
				<h1><a href="{{link_url}}" class="resource-image">{{title}}</a></h1>
				<p>{{short_description}}</p>
				<p><strong>{{site}}</strong></p>
				<p><strong>{{room}}</strong></p>
				<p><strong>{{room}}</strong></p>
				<p><strong>{{room}}</strong></p>
				<a href="{{link_url}}">More Information</a>
			</div>

		{{/events}}

	</script>
	
	<script id="event_detail_tmpl" type="x-tmpl-mustache">

		{{#events}}

			<div class="event_details">			
				<h1><a href="#" class="resource-image">{{title}}</a></h1>
				<p>{{short_description}}</p>
				<p><strong>{{site}}</strong></p>
				<p><strong>{{room}}</strong></p>
				<p><strong>{{#timeFormat}}{{start_time}}{{/timeFormat}} - {{#timeFormat}}{{end_time}}{{/timeFormat}} ({{#durationFormat}}{{duration}}{{/durationFormat}})</strong></p>
				<p><strong>{{#dateFormat}}{{end_time}}{{/dateFormat}}</strong></p>
				<a href="#">More Information</a>
			</div>

		{{/events}}
		
		{{^events}}
			<div class="event_details">			
				<h1>No event found</h1>
				<p>This event may have been removed or expired. </p>
				<p>Please go back and try again. </p>
			</div>
		{{/events}}

	</script>
	
	<!-- ENTER PLACEHOLDER HERE -->

	<div id="events-filter">

		<button id="filter_LearningExpress" onclick="return false;">Learning Express</button>
		<button id="filter_LAndD" onclick="return false;">Learning &amp; Development</button>

	</div>
	
	<div id="events">

		Loading...

	</div>

	<div id="events-pagination">

		<button id="btnAddLess" onclick="return false;">Back..</button>
		<button id="btnAddMore" onclick="return false;">Next..</button>

	</div>


	<!-- ENTER VIEW AND CONTROLLER CODE HERE -->
	
	<script>

		//Parse template for rendering later
		var eventTemplate = $( "#event_detail_tmpl" ).html( );
		Mustache.parse( eventTemplate );
		
		$( document ).ready( function ( ) {

			// Wait until events loaded and then execute

			ExecuteOrDelayUntilScriptLoaded(function ( ) { // First argument is the eventView to run when script loads
			
				//
				// VIEW 
				// This callback is executed by the Controller and configures and renders the components
				//

				var eventView = function ( ) {
				
					var eventList = {events: eventModel.get_result(  )};
				
					eventList.dateFormat = function () {
						return function (SPDate, render) {
							return moment(render(SPDate)).format("dddd, D MMMM YYYY");
						}
					};
					
					eventList.timeFormat = function () {
						return function (SPDate, render) {
							return moment(render(SPDate)).format("hh:mma");
						}
					};
					
					eventList.durationFormat = function() {
						return function (duration, render) {
							return Math.floor(moment.duration(parseInt(render(duration))).asHours()) + "h " + moment.duration(parseInt(render(duration))).minutes() + "m";
						}					
					};
						
					// Once the data query has been complete, run the use Mustache template to update page
					$( "#events" ).html( Mustache.render( eventTemplate, eventList ) );

					// then update the paginate buttons
					eventModel.get_pagingInfo() === null ? $("#btnAddMore").prop("disabled",true) : $("#btnAddMore").prop("disabled",false);

					eventModel.get_pageIndex() > 1 ? $("#btnAddLess").prop("disabled",false) : $("#btnAddLess").prop("disabled",true);

				};
				
				//
				// CONTROLLER
				// This code controls the events (on page load, on click event etc) and talks to the Model and View
				//
				
				// PAGE LOAD
				
				var start_datetime = moment.utc().startOf("month").toISOString();
				
				var end_datetime = moment.utc().endOf("month").toISOString();

				var options = {
					siteUrl: "/TASites/LearningHub/V2_Redevelopment",
					list: "Event Times",
					where:
					[
						["And", "Eq", "Events_Status", "Text", "Completed"],
						["And", "Eq", "Events_Type", "Text", "Learning Express"],
						["And", "Geq", "Start_x0020_Time", "DateTime", start_datetime],
						["And", "Leq", "End_x0020_Time", "DateTime", end_datetime]
					],
					orderBy: "Start_x0200_Time",
					orderAsc: true,
					pageIndex: 0,
					rowLimit: 5
				};
				
				var eventModel = E$(options, eventView);
				
				// INPUT EVENTS

				$("#btnAddMore").click( function () {
					eventModel.get_results(eventView);
				});

				$("#btnAddLess").click( function () {
					eventModel.set_pagingInfo("prev");
					eventModel.get_results(eventView);
				});
				
				$("#filter_LearningExpress").click( function () {
					eventModel.set_pagingInfo(false);
					eventModel.set_filter(
						[ 
							["And", "Eq", "Events_Status", "Text", "Completed"],
							["And", "Eq", "Events_Type", "Text", "Learning Express"],
							["And", "Geq", "Start_x0020_Time", "DateTime", start_datetime],
							["And", "Leq", "End_x0020_Time", "DateTime", end_datetime]
						]
					);
					eventModel.get_results(eventView);
				});

				$("#filter_LAndD").click( function () {
					eventModel.set_pagingInfo(false);
					eventModel.set_filter(
						[
							["And", "Eq", "Events_Status", "Text", "Completed"],
							["And", "Eq", "Events_Type", "Text", "Learning & Development"],
							["And", "Geq", "Start_x0020_Time", "DateTime", start_datetime],
							["And", "Leq", "End_x0020_Time", "DateTime", end_datetime]
						]
					);
					eventModel.get_results(eventView);
				});
				
				
				
				
				
			},
			// second argument is the script to wait for.
			"sp.js"
			);
		
		});

	</script>
	
<!-- END WEB PART CODE -->

</form>

	<!-- FormDigest required for security purposes -->
	<SharePoint:FormDigest ID="FormDigest1" runat="server"></SharePoint:FormDigest>

</body>
</html>
