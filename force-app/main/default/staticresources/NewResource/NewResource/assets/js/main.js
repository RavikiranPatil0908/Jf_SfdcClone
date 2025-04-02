$(document).ready(function(){
	/* Mobile Nav */

	$(".mobileMenu").click(function() {
		$("body").toggleClass("open-menu");
		$(this).toggleClass("active")
	});
    $('.navLinks li>a').click(function(e) {        
        if($(this).next('ul').length){
			if($(this).attr('href')==="#"){
				e.preventDefault();
			}            
            
            if($(this).parent('li').hasClass('link')){
                if($(this).parent('li.link').hasClass('active')){
                    $('.navLinks li.link').removeClass('active');
                    $('.navLinks li.link li.innerDropdown').removeClass('active');
                }else{
                    $('.navLinks li.link').removeClass('active');
                    $('.navLinks li.link li.innerDropdown').removeClass('active');
                    $(this).parent('li.link').addClass('active');
                }
            }else if($(this).parent('li').hasClass('innerDropdown')){
                if($(this).parent('li.innerDropdown').hasClass('active')){
                    $('.navLinks li.link li.innerDropdown').removeClass('active');
                }else{
                    $('.navLinks li.link li.innerDropdown').removeClass('active');
                    $(this).parent('.innerDropdown').addClass('active');
                }
            }
        }
        
    });
	
	/* Date Picker */
	$('#datetimepicker1').datetimepicker({
		format: 'DD/MM/YYYY'         
	});
	$('#datetimepicker2').datetimepicker({
		format: 'DD/MM/YYYY'         
	});
	/*Commented because google api is not working with it//
	$("select").chosen({disable_search_threshold: 20});
    
    if ($('.chosen-container').length > 0) {
      $('.chosen-container').on('touchstart', function(e){
        e.stopPropagation(); e.preventDefault();
        $(this).trigger('mousedown');
      });
    }
	*/
	/* Sticky Header */
    $(window).scroll(function(e) {
        if($(window).width()>=768){        
            if($(window).scrollTop()>0){
                $('body').addClass('scroll');
                
            }else{
                $('body').removeClass('scroll');
            }
        }
    });
	
});