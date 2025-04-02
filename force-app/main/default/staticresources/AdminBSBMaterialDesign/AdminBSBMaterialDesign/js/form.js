var ctrlPressed = false;

function checkCtrlV(e) {
    var code = (document.all) ? event.keyCode : e.which;
    // Check if Ctrl key is pressed
    if (code == 17) {
        ctrlPressed = true;
    }
    // Check if Ctrl + V combination is pressed
    if (ctrlPressed && code == 86) {
        e.preventDefault(); // Prevent the default paste action
        console.log('Pasting is disabled');
    }
}

// Reset ctrlPressed when Ctrl key is released
document.addEventListener('keyup', function (e) {
    if (e.keyCode == 17) {
        ctrlPressed = false;
    }
});

$(document).ready(function () { 
    console.log(0);

    $('body').on('focus','.form-control', function(){
        $(this).closest('.form-line').addClass('focused');
    });

    $('body').on('click', '.form-float .form-line .form-label', function () {
        $(this).parent().find('input').focus();
    });

    

    

    /*-----------------------------------------------------------Personal Details Validation ---------------------------------*/

    // $(".emailValidation").change(function(){
    $('body').on('change','.emailValidation', function(){
        if(!isValidEmailAddress($(this).val())){
            showHtmlMessage('Invalid Information','Please enter a valid email address.');
            $(this).val("");
        }
    });
    
    // $(".mobileNoValidation").change(function(){
    //     let mobileNumberValue = $(this).val();
    //     let lastdigits = mobileNumberValue.slice(-4);
    //     console.log(lastdigits);
    //     let pattern = "^(?!(\\d)\\1{8})";
    //     pattern = new RegExp(pattern);
    //     if(!pattern.test(mobileNumberValue)){  
    //         // showHtmlMessage('Invalid Information','Please Enter Valid Mobile Number');
    //         $(this).val("");
    //     }else if( (mobileNumberValue.length >10 && lastdigits != '0000') || mobileNumberValue.length < 10){
    //         // showHtmlMessage('Invalid Information','Please enter a valid 10 digit mobile number.');
    //         $(this).val("");
    //     }
    // });
    
    // $(".pincodeValidate").change(function(){
    //    var pincodeValue = $(this).val();
    //     if(pincodeValue.length >6 || pincodeValue.length<6){
    //         // showHtmlMessage('Invalid Information','Please Enter 6 digit Pincode');
    //         $(this).val("");
    //     } 
    // });
    
    // $('[id$=aadharCard]').change(function(){
    //     var aadharCardValue = $(this).val();
    //     if(aadharCardValue.length >12 || aadharCardValue.length< 12){
    //         // showHtmlMessage('Invalid Information','Please Enter 12 digit Aadhaar Card Number');
    //         $(this).val('');
    //     } 
    // });
    

    // // Nationality Check for making aadhar card mandatory
    $('body').on('change','[id$=nationality]', function(){
        var nationality = $(this).val();
        if(nationality =='Indian'){
            $('.IndianNationalityPanelId').show();
            //for passport not mandatory 
            $('[id$=passport]').removeClass('notnull');
            $('[id$=passportLabel]').text('Passport No');

        }else{
            $('.IndianNationalityPanelId').hide(); 
            $('[id$=aadharCard]').removeClass('notnull');       
            //for passport mandatory 
            $('[id$=passport]').addClass('notnull');
            $('[id$=passportLabel]').html('Passport No <span style="color:red;font-style:bold">*</span>');

        }
    });

    $('body').on('change','[id$=motherTongue]', function(){
        $('.otherMotherTonguePanelId').hide();
        if($(this).val() == 'Other') {
            $('.otherMotherTonguePanelId').show();
            $('[id$=otherMotherTongue]').addClass('notnull');
        }else{
            $('[id$=otherMotherTongue]').removeClass('notnull');
            $('[id$=otherMotherTongue]').val('');
        }
    });

    // // LinkedIn Validation
    // $(".linkedURLValidation").change(function(){
    //    console.log('validation for linked url');
    //    var linkedinURL = $(this).val();
    // //    var pattern = '/(ftp|http|https):\/\/?(?:www\.)?linkedin.com(\w+:{0,1}\w*@)?(\S+)(:([0-9])+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/';
    // //     pattern = new RegExp(pattern);
    //     if(!(/(ftp|http|https):\/\/?(?:www\.)?linkedin.com(\w+:{0,1}\w*@)?(\S+)(:([0-9])+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/).test(linkedinURL)){  
    //         // showHtmlMessage('Invalid Information','Please Enter valid Linkedin URL');
    //         $(this).val('');
    //         $(this).addClass('');
    //     }
    // });
    
    // if($(".linkedURLValidation").val() !='' && $(".linkedURLValidation").val() !=null){
    //     $(".linkedURLValidation").trigger('change');
    // }

    // //Pan Card Validation
    $('body').on('change','[id$=PanCardno]', function(){    
        var regExp = /[a-zA-z]{5}\d{4}[a-zA-Z]{1}/; 
        var txtpan = $(this).val(); 
        if (txtpan.length == 10 ) { 
            if( !txtpan.match(regExp) ){ 
                $(this).val('');
                showHtmlMessage('Invalid Information','Pan Card Number Invalid.');
            }
        } 
        else { 
            $(this).val(''); 
            showHtmlMessage('Invalid Information','Pan Card Number Invalid.');
        } 

    });

    // //Passport Validation
    $('body').on('change','[id$=passport]', function(){ 
        if($('[id$=nationality]').val() == 'Indian') {
            var regExp = /[a-zA-Z]{1}\d{7}/; 
            var txtpan = $(this).val(); 
            if (txtpan.length == 8 ) { 
                if( !txtpan.match(regExp) ){ 
                    $(this).val('');
                    showHtmlMessage('Invalid Information','Passport Number Invalid.');
                }
            } 
            else { 
                $(this).val(''); 
                showHtmlMessage('Invalid Information','Passport Number Invalid.');
            } 
        }   
    });

    $('body').on('change','[id$=diffAbled]', function(){ 
        var differentlyAbled = $(this).val();
        if (differentlyAbled == 'Yes') {
            $('[id$=disability]').addClass('notnull');
            $('[id$=disabilityPanel]').css('display', 'block');
        } else {
            $('[id$=disability]').removeClass('notnull');
            $('[id$=disabilityPanel]').css('display', 'none');
            if ($('[id$=disability]').val()) {
                $('[id$=disability]').val('');
            }
        }
    });

    $('body').on('changeDate','#datetimepicker2', function(event){
        var dateString = event.format();
        var today = new Date();
        var datestr = (dateString.split(" ")[0]).split("/");
        var birthDate  =  new Date(datestr[2],datestr[1]-1,datestr[0]);
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) 
        {
            age--;
        }
        $('[id$=ageAsOn]').val(age);
        if(age < 17){
            showHtmlMessage('Invalid Details','Date of Birth cannot be less than 17 years.');
            $('[id$=dateOfBirth]').val('');
        }
    });

    $('body').on('keypress','.doNotAllowedSpecialCharacter', function(e){
        var regex = new RegExp("^[a-z  A-Z]*$");
        var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
        if (!regex.test(str) && str !="'") {
            $(this).focus();
            $(this).val('');
            e.preventDefault();
            $(this).closest('div.form-group').children('span.error').remove();
            $(this).closest('div.form-group').append('<span class="error" style="color:red;font-style:bold">Please enter value.</span>');
        }else{
            $(this).closest('div.form-group').children('span.error').remove();
        }
    });

    $('body').on('change','[id$=maritalStatus]', function(){
        if($('[id$=maritalStatus]').val() === 'Married'){
            $("[id$=spousePanelId]").show();
            $("[id$=spouseName]").addClass('notnull');
        }else{
            $("[id$=spousePanelId]").hide();
            $("[id$=spouseName]").removeClass('notnull').val('');
            $("[id$=spouseName]").closest('div.form-group').children('span.error').remove();

        }
    });


    /*----------------------------------------------------------- #END# of Personal Details Validation ---------------------------------*/

    /*------------------------------------------------------------Page Navigation Start ---------------------------------------------------------------*/
    // function onClickNextToPersonalInformationTab(){
    //     var flag = validateForm('[id$=generateRegistrationNo]');
    //     if (flag != 0 ) {
    //         showHtmlMessage('Invalid Details','Please fill in all the required fields.');
    //         $('ul.setup-panel li a[href="#generateRegistrationNoPanel"]').trigger('click');
    //     }else{
    //         $('[id$=generateRegistrationNoTab]').addClass('disabled');
    //         $('[id$=personalInformationTab]').removeClass('disabled');
    //         $('ul.setup-panel li a[href="#personalInformationPanel"]').trigger('click');
    //     }
    // }
    /*-----------------------------------------------------------#END# of Page Navigation Start ---------------------------------------------------------*/

    function gotoAddressInformation(section){
        let ageAsOn = $('[id$=ageAsOn]').val();
        if(ageAsOn < 17){
            showHtmlMessage('Invalid Details','Date of Birth cannot be less than 17 years.');
            $('[id$=dateOfBirth]').val('');
            return false;
        }else {
            return validateForm(`[id$=${section}]`) === 0 ? true : false;
        }
    }

    function validateForm(id) {
        var flag = 0;
        $(id).find('.notnull').each(function () {
            if(!$(this).prop('disabled')) {
                if($(this).val() !=null){
                    if ($(this).val().trim().length == 0) {
                        flag = 1;
                        console.log('Id Required Value --'+$(this).attr('id'));
                        $(this).focus();
                        $(this).closest('div.form-group').children('span.error').remove();
                        $(this).closest('div.form-group').append('<span class="error" style="color:red;font-style:bold">Please enter value.</span>');
                    }else if($(this).attr('type') == 'radio') {
                        var attrName = $(this).attr('name');
                        console.log('radio btn checked'+$("input[name='"+attrName+"']:checked").val());
                        if(!$("input[name='"+attrName+"']:checked").val()) {
                            flag = 1;
                            console.log('Id Required Value --'+$(this).attr('id'));
                            $(this).focus();
                            $(this).siblings('span.error').remove();
                            $(this).siblings('label').after('<br/> <span class="error" style="color:red;font-size: 13px;">Please enter value.</span>');
                        }
                    }
                }else{
                    flag = 1;
                    console.log('Id Required Value --'+$(this).attr('id'));
                    $(this).focus();
                    $(this).closest('div.form-group').children('span.error').remove();
                    $(this).closest('div.form-group').append('<span class="error" style="color:red;font-style:bold">Please enter value.</span>');    
                }
            }
        });
        return flag;  
    }

    function isValidEmailAddress(emailAddress) {
        // var pattern = new RegExp(/^[+a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/i);
        let pattern = new RegExp(/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/g);
        // alert( pattern.test(emailAddress) );
        return pattern.test(emailAddress);
    } 

    function showHtmlMessage(header,message) {
        swal({
            title: header+"!",
            text: message,
            type: "warning"
        });
    }

});