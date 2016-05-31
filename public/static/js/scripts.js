$(function(){
	
	if ($(window).width() >= 1200) {
		skrollr.init({forceHeight: false});	
		
		var controller = $.superscrollorama();
		controller.addTween('#should_section', TweenMax.from( $('#should_section'), .5, {css:{opacity: 0}}));
		controller.addTween('#how_section', TweenMax.from( $('#how_section'), .5, {css:{opacity: 0}}));
		controller.addTween('#start_section', TweenMax.from( $('#start_section'), .5, {css:{opacity: 0}}));
		//On scroll effects END
	}else{
		$('.big_img_container').each(function(){
			var offset_left = $(this).find('div > img').offset().left;
			$(this).find('.shadow').css('left', offset_left-15);
		})
	}
	
	//Show all projects
	$(document).on('click', '#show_more_domains', function(){
		$('.how_table_wrap').addClass('full_list');
		$(this).hide();
		return false;
	})
	//Show all projects END
    
})