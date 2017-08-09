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

	<!-- ENTER WEB PART CODE HERE -->

	<!-- ADD VIEW TEMPLATES HERE -->

	<script id="article_promos_tmpl" type="x-temp-mustache">

		{{#articles}}

			<div class="article">
				<h1 class="header">
					{{headlineA}}<br />
					<strong>{{headlineB}}</strong>
				</h1>
				<h2>{{title}}</h2>
				<a href="{{action_url}}">{{action_description}}</a>
				<a href=""></a>
			</div>

		{{/articles}}

	</script>



	<div id="article-promos">

		Loading...

	</div>

	<div id="article-pagination">

		<button id="btn_NewsLess" onclick="return false;">Less..</button>
		<button id="btn_NewsMore" onclick="return false;">More..</button>

	</div>
	
	<!-- ENTER DEPENDANCIES HERE -->

	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/jquery-1.11.1.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/moment.min.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/mustache.js"></script>
	<link rel="stylesheet" href="/TASites/LearningHub/V2_Redevelopment/Core/styles/LDHub.css">

	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/SPNewsModel.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/SPEventModel.js"></script>

	<!-- ENTER CONTROLLER CODE HERE -->
	
	<script>

		//Parse template for rendering later
		var newsTemplate = $( "#article_promos_tmpl" ).html( );
		Mustache.parse( newsTemplate );

		// Wait until resources loaded and then execute



	</script>
	
	<!-- END WEB PART CODE -->
	
<!-- ENTER WEB PART CODE HERE -->

	<!-- ENTER DEPENDANCIES HERE -->

	
	
	<!-- ADD VIEW TEMPLATES HERE -->

	<script id="event_list_tmpl" type="x-temp-mustache">

		{{#events}}

			<div class="event_listing">			
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
	
	<script id="event_detail_tmpl" type="x-temp-mustache">

		{{#events}}

			<div class="event_listing">			
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
			<div class="event_listing">			
				<h1>No events found</h1>
				<p>Please choose another filter or date period.</p>
			</div>
		{{/events}}

	</script>
	
	<!-- ENTER PLACEHOLDER HERE -->

	<div id="events-filter">

		<button id="filter_LearningExpress" onclick="return false;">Learning Express</button>
		<button id="filter_LAndD" onclick="return false;">Learning &amp; Development</button>

	</div>
	
	<h1>Upcoming Events</h1>
	
	<div id="events">

		Loading...

	</div>

	<div id="events-pagination">

		<button id="btnAddLess" onclick="return false;">Back..</button>
		<button id="btnAddMore" onclick="return false;">Next..</button>

	</div>

	<!-- ENTER TEMPLATES HERE -->



	<!-- ENTER CONTROLLER CODE HERE -->
	
	<script>

		//Parse template for rendering later
		var eventTemplate = $( "#event_detail_tmpl" ).html( );
		Mustache.parse( eventTemplate );

		// Wait until events loaded and then execute
		$( document ).ready( function ( ) {

			ExecuteOrDelayUntilScriptLoaded(function ( ) { // First argument is the eventView to run when script loads

				var eventView = function ( ) {
				
					var eventList = {events: events.get_result(  )};
				
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
					events.get_pagingInfo() === null ? $("#btnAddMore").prop("disabled",true) : $("#btnAddMore").prop("disabled",false);

					events.get_pageIndex() > 1 ? $("#btnAddLess").prop("disabled",false) : $("#btnAddLess").prop("disabled",true);

				};
				
				var start_datetime = moment.utc().startOf("month").toISOString();
				
				var end_datetime = moment.utc().endOf("month").toISOString();

				var event_options = {
					siteUrl: "/TASites/LearningHub/V2_Redevelopment",
					list: "Event Times",
					where:
					[
						["And","Eq", "Events_Status", "Text", "Completed"],
						["And","Eq", "Events_Type", "Text", "Learning Express"],
						["And","Geq", "Start_x0020_Time", "DateTime", start_datetime],
						["And","Leq", "End_x0020_Time", "DateTime", end_datetime],
					],
					orderBy: "Start_x0200_Time",
					orderAsc: true,
					pageIndex: 0,
					rowLimit: 5
				};
				
				var events = E$(event_options, eventView);

				$("#btnAddMore").click( function () {

					events.get_results(eventView);

				});

				$("#btnAddLess").click( function () {

					events.set_pagingInfo("prev");

					events.get_results(eventView);

				});
				
				$("#filter_LearningExpress").click( function () {
				
					events.set_pagingInfo(false);

					events.set_filter(
						[
							["And","Eq", "Events_Status", "Text", "Completed"],
							["And","Eq", "Events_Type", "Text", "Learning Express"],
							["And","Geq", "Start_x0020_Time", "DateTime", start_datetime],
							["And","Leq", "End_x0020_Time", "DateTime", end_datetime],
						]
					);
					
					events.get_results(eventView);

				});

				$("#filter_LAndD").click( function () {

					events.set_pagingInfo(false);

					events.set_filter(
						[
							["And","Eq", "Events_Status", "Text", "Completed"],
							["And","Eq", "Events_Type", "Text", "Learning and Development"],
							["And","Geq", "Start_x0020_Time", "DateTime", start_datetime],
							["And","Leq", "End_x0020_Time", "DateTime", end_datetime],
						]
					);
					
					events.get_results(eventView);

				});
				
				var news_options = {
					siteUrl: "/TASites/LearningHub/V2_Redevelopment",
					list: "News",
					joinList: "News Categories",
					joinField: "Category",
					projectedFields: ["headlineA", "headlineB", ],
					viewFields: ["Category_HeadlineA", ],
					orderBy: "",
					orderAsc: true,
					limit: [1,5],
					pageIndex: 0,
					rowLimit: 5
				};

				var news_view = function ( ) {

					// Once the data query has been complete, run the use Mustache template to update page
					$( "#article-promos" ).html(
						// Call Mustache Render
						Mustache.render(
							// First parameter is the parsed template
							newsTemplate,
							// Second parameter is the data object array
							{articles: news.getArticles( )}
						)
					);

					// then update the paginate buttons
					news.get_pagingInfo() === null ? $("#btn_NewsMore").prop("disabled",true) : $("#btn_NewsMore").prop("disabled",false);

					news.get_pageIndex() > 1 ? $("#btn_NewsLess").prop("disabled",false) : $("#btn_NewsLess").prop("disabled",true);

				};

				var news = N$(news_options, news_view);

				$("#btn_NewsMore").click( function () {

					news.getNews(news_view);

				});

				$("#btn_NewsLess").click( function () {

					news.set_pagingInfo("prev");

					news.getNews(news_view);

				});
				


			},
			// second argument is the script to wait for.
			"sp.js"
			);

		});


	</script>
	
<!-- END WEB PART CODE -->
	<!-- FormDigest required for security purposes -->
	<SharePoint:FormDigest ID="FormDigest1" runat="server"></SharePoint:FormDigest>

</body>
</html>
