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

	<script id="article_list_tmpl" type="x-temp-mustache">

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

	<h2>News</h2>
	
	<div id="news">

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

	<!-- ENTER CONTROLLER CODE HERE -->
	
	<script>

		//Parse template for rendering later
		var newsTemplate = $( "#article_list_tmpl" ).html( );
		Mustache.parse( newsTemplate );

		// Wait until resources loaded and then execute
		$( document ).ready( function ( ) {

			ExecuteOrDelayUntilScriptLoaded(function ( ) { // First argument is the callback to run when script loads

				var options = {
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

				var callback = function ( ) {

					// Once the data query has been complete, run the use Mustache template to update page
					$( "#news" ).html(
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

				var news = N$(options, callback);

				$("#btn_NewsMore").click( function () {

					news.getNews(callback);

				});

				$("#btn_NewsLess").click( function () {

					news.set_pagingInfo("prev");

					news.getNews(callback);

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
