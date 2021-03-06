var split = function ( val ) {
	return val.split( /,\s*/ );
};
var extractLast = function ( term ) {
	return split( term ).pop();
};


var saveCSVContent = function (fileContents, fileName)
{

  if (navigator.msSaveBlob) { // IE 10+
      var blob = new Blob([fileContents],{type: "text/csv;charset=utf-8;"});
      navigator.msSaveBlob(blob, "csvname.csv");
    }else{

      
      var csvContent = "data:text/csv;charset=utf-8,";
      csvContent += fileContents;
      var encodedUri = encodeURI(csvContent);
      var link = document.createElement('a');
      link.download = fileName;
      link.href = encodedUri;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
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
		node.html('<h4>BLAST Scaffold</h4>');
		$(this).contents().find('#footer').html('');

		$($(this).contents()).click(function(event) {
			all_downloads = parent.find(".mutation_link");
			all_downloads.attr('target','_blank');
		});
		search_btn = $(this).contents().find('#method');
		
		search_btn.click(function(){
			search_right.width('100%')
			self.width('950px');
			search_left.hide();
			introblurb.hide();
		});
	});

	var textAreas = document.getElementsByTagName('textarea');
	Array.prototype.forEach.call(textAreas, function(elem) {
		elem.placeholder = elem.placeholder.replace(/\\n/g, '\n');
	});
});

$(document).on('ready page:load page:change page:restore page:update turbolinks:load', ready);