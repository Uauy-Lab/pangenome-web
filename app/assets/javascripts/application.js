// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read nonrockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui

//= require turbolinks
//= require deletions
//= require w2ui
//= require_tree .
//= require bundle

var primersPrepareTable= function(tablename){
	var table = $('#'+tablename).dynatable();
};

var downloadTable = function(tablename){
	var table = $('#'+tablename);
	table.data('dynatable').records.resetOriginal();
	table.data('dynatable').queries.run();
	table.data('dynatable').sorts.init();
	var nodes = table.data('dynatable').records.sort();
	var csvContent = "data:text/csv;charset=utf-8,";
	nodes.forEach(function(infoArray, index){
		infoArray = $.map(infoArray, function(el) { return el; });
		dataString = infoArray.join(",");
		csvContent += index < nodes.length ? dataString+ "\n" : dataString;
	});
	var encodedUri = encodeURI(csvContent);
	window.open(encodedUri);
};

var setupTableButtons = function(suffix){
	var save_button = "save-" + suffix;
	var tablename =  "table-primers-" + suffix;
	var primers_select = "primer-check-" + suffix;
	$( "#" + save_button ).button().click(function( event ) {
		downloadTable(tablename);
	});
	


	var sp = $('#sp-' + suffix).attr("checked",true);
	var semi = $('#semi-' + suffix).attr("checked",true);
	var non = $('#non-' + suffix).attr("checked",true);
	var items = $("#"+primers_select).buttonset();
	var table = $('#'+tablename);

	sp.change(function() {
		
	});
	semi.change(function() {
		console.log("sp click");
	});
	semi.change(function() {
		console.log("sp click");
	});
}

var ready = (function(){
	$('.alert-error').on('click', function(event) { 
		$(this).hide();
	});
	$('.alert-info').on('click', function(event) { 
		$(this).hide();
	});

	$('#sequenceserver').load(function(){
		var node = $(this).contents().find('body').find('.navbar');
		node.remove();
		$(this).contents().find('#footer').html('');
	});
});

$(document).ready(ready);
$(document).on('page:load', ready);
