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
	
	$("body").fadeIn('normal');
});

