$(document).ready(function() {
    // Add required attribute to all elements with the class 'notnull'
    $('.notnull').attr('required', 'true');

    // Initially hide subCategory field
    $('.showsubCategory').hide();
    $('.showsubCategory').val('');

    // Handle change event for Category
    $('.Category').change(function() {
        var category = $(this).val();
        $('.subCategory').val('');

        if (category === 'Need More Information') {
            $('.showsubCategory').show();
            $('.subCategory').addClass('notnull').attr('required', 'true'); // Add required class when visible
        } else {
            $('.showsubCategory').hide();
            $('.subCategory').removeClass('notnull').removeAttr('required'); // Remove required class when hidden
            $('.subCategory').val(''); // Reset the subCategory dropdown
        }
        $('.subject').val(category); // Auto-populate subject based on category
    });

    // Handle change event for subCategory
    $('.subCategory').change(function() {
        var subCategory = $(this).val();
        var category = $('.Category').val();
        $('.subject').val(category + ' - ' + subCategory); // Set the subject field
    });

    // Handle attachment checkbox
    // $('.attcheckbox .').change(function() {
    //     console.log('Attachment checkbox');
    //     if ($(this).is(':checked')) {
    //         $(this).closest('.row').next('.attachmentblock').show(); 
    //     } else {
    //         $(this).closest('.row').next('.attachmentblock').hide(); 
    //     }
    // });

    $('.attcheckbox').change(function() {
        if ($(this).is(':checked')) {
            $('.attachmentblock').show(); // Show the attachment block
        } else {
            $('.attachmentblock').hide(); // Hide the attachment block
        }
    });



    

    // Remove error message on input or change
    $('.notnull').on('input change', function() {
        $(this).closest('div.form-group').children('span.error').remove();
    });

    // $('body').on('change', '.caseType', function (e) {
    //     e.stopPropagation();
    //     console.log($(this).val());
    //     if($(this).val()) {
    //         refreshTableData($(this).val());
    //     }
    // });
});

// Event listener for component 1
let selectCaseType = document.querySelector(".caseType");
selectCaseType.addEventListener("change", function (event) {
    console.log($(this).val());
    if($(this).val()) {
        refreshTableData($(this).val());
    }
});

function validateCaseForm(section) {
    if (validateForm(`[id$=${section}]`) === 0) {
        console.log("Form is valid. Proceeding to the next step.");
        return false; // Stop actual form submission
    } else {
        console.log("Form validation failed.");
        return true; // Prevent form submission if validation fails
    }
}

// Validation function
function validateForm(id) {
    var isValid = 0;
    console.log('Validating form in section: ' + id);

    $(id).find('.notnull').each(function() {
        if (!$(this).prop('disabled')) {
            console.log('Form validation element'+$(this).val());
            if ($(this).val() == null || $(this).val().trim().length == 0 || $(this).val() == "None") {
                isValid = 1;
                console.log('Field is required: ' + $(this).attr('id'));
                $(this).focus();
                $(this).closest('div.form-group').children('span.error').remove(); // Remove existing error
                $(this).closest('div.form-group').append('<span class="error" style="color:red;font-style:bold">Please enter value.</span>'); // Add error
            } else {
                $(this).closest('div.form-group').children('span.error').remove(); // Remove error if value is valid
            }
        }
    });

    return isValid;
}
function displayCaseDetails() {
    // Hide the form and show the case details section
    $('#raiseTicketPage').hide();
    $('#caseDetail').show();
    console.log("Case created successfully and details are displayed.");
}

 //  show the commentBox by removing 'display:none'
function showCommentBox() {
    console.log("show commentbox.");
    $('#commentBox').removeClass('commentBox');
}

function hideCommentBox(){
    $('#commentBox').addClass('commentBox');
}
// add Action Type to the commentBox
function setActionType(action) {
    console.log("Set Action Type: " + action);  // TODO: Implement logic to update the action type in the comment box
    $('#actionType').val(action);  
    
}


// function reRenderCaseSection() {
//     alert("Case has been successfully created!");  
//     $('#mainPage').hide();
//     $('#raiseTicketPage').show();
// }

function openRaiseTicketPage() {
    $('#mainPage').hide();
     $('#raiseTicketPage').show();
    //  $('#caseForm').hide();
    // $('#caseDetail').show();
    
}


function goBackToMainPage() {
    $('#raiseTicketPage').hide();
    $('#mainPage').show();
}

function showLoader() {
    $('.page-loader-wrapper').show();
}

function hideLoader() {
    $('.page-loader-wrapper').fadeOut();
}
