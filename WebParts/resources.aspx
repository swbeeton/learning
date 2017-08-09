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

	<script id="resource_tmpl" type="x-temp-mustache">

		{{#resources}}

			<div class="video_resource">
				<a href="{{link_url}}" class="resource-image"><img src="{{}}" alt="{{title}}" /></a>
				<h1>{{title}}</h1>
				<p>{{short_description}}</p>
				<p><strong>Duration:</strong>&nbsp;{{duration}}</p>
				<p><strong>Intended for:</strong>&nbsp;{{audience}}</p>
				<a href="{{link_url}}">Watch it now</a>
				<a href=""></a>
			</div>

		{{/resources}}

	</script>



	<div id="resources">

		Loading...

	</div>

	<div id="resources-pagination">

		<button id="btnAddLess" onclick="return false;">Back..</button>
		<button id="btnAddMore" onclick="return false;">Next..</button>

	</div>
	
	<!-- ENTER DEPENDANCIES HERE -->

	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/jquery-1.11.1.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/moment.min.js"></script>
	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/lib/mustache.js"></script>
	<link rel="stylesheet" href="/TASites/LearningHub/V2_Redevelopment/Core/styles/LDHub.css">

	<script src="/TASites/LearningHub/V2_Redevelopment/Core/js/SPResourcesModel.js"></script>

	<!-- ENTER CONTROLLER CODE HERE -->
	
	<script>

		//Parse template for rendering later
		var resourcesTemplate = $( "#article_promos_tmpl" ).html( );
		Mustache.parse( resourcesTemplate );

		// Wait until resources loaded and then execute
		$( document ).ready( function ( ) {

			ExecuteOrDelayUntilScriptLoaded(function ( ) { // First argument is the callback to run when script loads

				var options = {
					siteUrl: "/TASites/LearningHub/V2_Redevelopment",
					list: "Resources",
					joinList: "Topics",
					joinField: "Topic",
					projectedFields: ["headlineA", "headlineB", ],
					viewFields: ["Title", "Short_x0020_Description", "Description", "Duration", "Image_x0020_URL", "Resource_x0020_URL", "Audience"],
					orderBy: "",
					orderAsc: true,
					limit: [1,5],
					pageIndex: 0,
					rowLimit: 5
				};

				var callback = function ( ) {

					// Once the data query has been complete, run the use Mustache template to update page
					$( "#resources" ).html(
						// Call Mustache Render
						Mustache.render(
							// First parameter is the parsed template
							resourcesTemplate,
							// Second parameter is the data object array
							{resources: resources.getArticles( )}
						)
					);

					// then update the paginate buttons
					resources.get_pagingInfo() === null ? $("#btnAddMore").prop("disabled",true) : $("#btnAddMore").prop("disabled",false);

					resources.get_pageIndex() > 1 ? $("#btnAddLess").prop("disabled",false) : $("#btnAddLess").prop("disabled",true);

				};

				var resources = R$(options, callback);

				$("#btnAddMore").click( function () {

					resources.getresources(callback);

				});

				$("#btnAddLess").click( function () {

					resources.set_pagingInfo("prev");

					resources.getresources(callback);

				});


			},
			// second argument is the script to wait for.
			"sp.js"
			);

		})


	</script>
	
	<!-- END WEB PART CODE -->

	<!-- FormDigest required for security purposes -->
	<SharePoint:FormDigest ID="FormDigest1" runat="server"></SharePoint:FormDigest>

</body>
</html>
