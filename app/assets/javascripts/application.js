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
};

var split = function ( val ) {
	return val.split( /,\s*/ );
};
var extractLast = function ( term ) {
	return split( term ).pop();
};

var ready = (function(){
	$('.alert-error').on('click', function(event) { 
		$(this).hide();
	});
	$('.alert-info').on('click', function(event) { 
		$(this).hide();
	});

	$('#terms')// don't navigate away from the field on tab when selecting an item
      .bind( "keydown", function( event ) {
        if ( event.keyCode === $.ui.keyCode.TAB &&
            $( this ).autocomplete( "instance" ).menu.active ) {
          event.preventDefault();
        }
      })
      .autocomplete({
        source: function( request, response ) {
          $.getJSON( "search/autocomplete.json", {
            term: extractLast( request.term )
          }, response );
        },
        search: function() {
          // custom minLength
          var term = extractLast( this.value );
          if ( term.length < 2 ) {
            return false;
          }
        },
        focus: function() {
          // prevent value inserted on focus
          return false;
        },
        select: function( event, ui ) {
          var terms = split( this.value );
          // remove the current input
          terms.pop();
          // add the selected item
          terms.push( ui.item.value );
          // add placeholder to get the comma-and-space at the end
          terms.push( "" );
          this.value = terms.join( ", " );
          return false;
        }
      });
    var search_right = $('#search_right');
    var search_left = $('#search_left');
    var introblurb = $('#introblurb');
	$('#sequenceserver').load(function(){
		var parent = $(this).contents();
		var node = $(this).contents().find('body').find('.navbar');
		var self = $(this);
		node.remove();
		$(this).contents().find('#footer').html('');

		$($(this).contents()).click(function(event) {
			all_downloads = parent.find(".mutation_link");
			all_downloads.attr('target','_blank');
		});

		search_btn = $(this).contents().find('#method');
		console.log(search_btn);

		search_btn.click(function(){
			console.log("Clicked blast!");
			console.log(search_right);
			search_right.width('100%')
			self.width('950px');
			search_left.hide();
			introblurb.hide();
		});

	});
});

$(document).ready(ready);
$(document).on('page:load', ready);
