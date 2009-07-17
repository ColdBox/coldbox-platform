$(document).ready(function() {
	$('#fisheye').Fisheye(
		{
			maxWidth: 70,
			items: 'a',
			// itemsText: 'span',
			container: '.fisheyeContainer',
			itemWidth: 70,
			proximity: 60,
			halign: 'center'
		}
	)
	
	$("body").fadeIn('slow');
	
	$("#commentSubmitButton").click(function(e){
		e.preventDefault();
		$.ajax({
			url: 'index.cfm/ajax/ajaxDoAddComment', 
			type: 'POST',
			dataType: 'html',
			data: {commentField: document.getElementById('commentField').value, id: document.getElementById('id').value},
			error: funtion(){
				alert('there was an error');
			},
			success: function(){
				document.getElementById('commentField').value = '';
				alert('Your data has been saved.');
			}
		});
	});		
});

