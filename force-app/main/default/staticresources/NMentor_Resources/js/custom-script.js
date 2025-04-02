$(document).on('ready', function() {
  
  // Student Reviews slider code
  
  $(".regular").slick({
	dots: false,
	autoplay: false,
	infinite: true,
	slidesToShow: 4,
	slidesToScroll: 1,
	responsive: [
	{
	  breakpoint: 1024,
	  settings: {
		slidesToShow: 3,
		slidesToScroll: 1,
		infinite: true,
		dots: true
	  }
	},
	{
	  breakpoint: 750,
	  settings: {
		slidesToShow: 2,
		slidesToScroll: 1
	  }
	},
	{
	  breakpoint: 600,
	  settings: {
		slidesToShow: 2,
		slidesToScroll: 1
	  }
	},
	{
	  breakpoint: 480,
	  settings: {
		slidesToShow: 1,
		slidesToScroll: 1
	  }
	}
  ]
  });
 
	
	
	// mobile menu
	$('#nav-icon').click(function(){
		$(this).toggleClass('open');$('.social-icon-bg').slideToggle();
	});
	
	// sticky header
	 $(window).on('scroll', function() {
	   var scroll = $(window).scrollTop();
	   if (scroll >= 300) {
		   $("header").addClass("fixed-header");
	   } else { 
		   $("header").removeClass("fixed-header");
	   }
	});
	
	
	// careers option accordion
	//$(".demo-accordion").accordionjs();	
	
	
	function hideerr(){
		setTimeout(function(){ 
			$('.errormsg').fadeOut();
		}, 3000);
	}
	
	$('[id$=next]').click(function(e){
	
	// e.preventDefault();
	var filter = /^[\w\-\.\+]+\@[a-zA-Z0-9\.\-]+\.[a-zA-z0-9]{2,4}$/;
		//$('.erroemsg').hide();
		if($('[id$=name]').val() == ''){
			//$('#Frm_name_error').show();
			$('#frm_name_error').fadeIn();
			hideerr();
			return false ;
		}else if($('[id$=email]').val() == ''){  
			$('#frm_email_error').fadeIn();
			hideerr();
			return false ;
		}else if (!(filter.test($('[id$=email]').val()))){
			$('#frm_email_error').fadeIn();
			hideerr();
			return false ;
		}else if($('[id$=contactno]').val() == ''){
			$('#frm_contactno_error').fadeIn();
			hideerr();
			return false;
		}else if($('[id$=contactno]').val().length < 10 || $('[id$=contactno]').val().length > 10){
			$('#frm_contactno_error').fadeIn();
			hideerr();
			return false;
		}else if($('#otp').val() == ''){
			$('#frm_otp_error').fadeIn();
			hideerr();
			return false;
		}else if($('[id$=city]').val() == ''){
			$('#frm_city_error').fadeIn();
			hideerr();
			return false ;
		}else if($('#message').val() == ''){
			$('#frm_message_error').fadeIn();
			hideerr();
			return false ;
		}/*else if(grecaptcha.getResponse() == ""){	
			$('#captcha_errorloc').fadeIn();
			hideerr();
			return false ;
		}*/else{
			console.log('success');
			// return true;
			// var formdata = new FormData($('#servicefrm')[0]);
			// $.ajax({
				
			// 	url: "ajax-salesforce/submitFrom.php",
			// 	type: "POST",
			// 	data:formdata,
			// 	contentType: false, 
			// 	processData: false,
			// 	success:function(result){
			// 		$('#servicefrm')[0].reset();
			// 		var data = JSON.parse(result);
			// 		window.location=data.ResponseURL;
			// 	}
			// });
      
		}
        
    });
	
	
	
  
});



function numbersonly(e){
	var unicode=e.charCode? e.charCode : e.keyCode
	if (unicode!=8){ //if the key isn't the backspace key (which we should allow)
	if (unicode<48||unicode>57) //if not a number
	return false //disable key press
	}
}

