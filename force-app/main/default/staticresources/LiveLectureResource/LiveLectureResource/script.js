/**
 * long description for the file
 *
 * @summary short description for the file
 * @author @BK
 *
 * Created at     : 2021-04-20 16:29:32 
 * Last modified  : 2021-05-24 17:31:05
 */

var cartList = {};
var CourseCount = 0;
var BacklogCount = 0;
$('.loaderPanel').show();
$(document).ready(function () {
    let courseList = $('[id$=hdnCourseList]').val();
    let backlogList = $('[id$=hdnBacklogList]').val();
    console.log(backlogList);
    let selLive = $('[id$=hdnLiveLecturesOption]').val();
    if (selLive == "No" || selLive == '') {
        let elm = $(`.PaymentForLiveLectures[data-value="No"]`);
        console.log('ghjghj');
        elm.addClass("active");
        console.log(elm)

    }
    console.log("on load -------------->" + $('[id$=hdnLiveLecturesOption]').val())
    onLoadSetLiveLectures(courseList, backlogList);

    $('body').on('click', '.makePayment', function () {
        let totalLiveLectureAmount = getApplicableAmountForLiveLectures();
        let totalBacklogAmount = getApplicableAmountForBacklog();
        let totalAmount = totalLiveLectureAmount + totalBacklogAmount;
        console.log("total Amount -----> " + totalAmount);
        if (totalAmount > 0) {
            $('[id$=PaymentGateWayOption]').css("display", "block");
        } else {
            callMakePayment();
        }

    });

    $('body').on('click', '.PaymentForLiveLectures', function () {
        delete cartList[0];
        updateCart();
        console.log("cartList from paymentLivelecture ");
        console.log(cartList);
        let selectionVal = $(this).data('value');
        console.log("selectionVal-PaymentForLiveLectures----------> " + selectionVal);
        console.log($(this));
        if(selectionVal) {

            triggerOnClick(selectionVal, $(this));
        }
    });

    $('body').on('click', '.ChooseSubjects', function () {
        let selectionVal = $(this).data('value').toString();
        console.log(selectionVal);
        let selectedOptions = $('[id$=hdnCourseList]').val();
        console.log(selectedOptions);
        let totalSubjects = $('.ChooseSubjects').length;
        let limitedSubjects = totalSubjects - 1;
        console.log("limited Subjects ------> " + limitedSubjects);
        console.log(this);
        let selectedOptionArray = selectedOptions != null && selectedOptions != '' ? selectedOptions.split(',') : [];
        if ($(this).hasClass('active') && $(this).hasClass('ChooseSubjects') && selectedOptionArray.length > 0) {
            selectedOptionArray.splice($.inArray(selectionVal, selectedOptionArray), 1);
            $(this).removeClass('active');
        } else if (!$(this).hasClass('active') && $(this).hasClass('ChooseSubjects')) {
            $(this).addClass('active');
            selectedOptionArray.push(selectionVal);
        }
        console.log(selectedOptionArray);
        let uniq = selectedOptionArray.length > 0 ? [...new Set(selectedOptionArray)] : [];
        console.log(" ----> " + uniq);
        console.log(" length -------------> " + uniq.length);
        if (limitedSubjects === uniq.length) {
            let livelectureElem = $("div.liveLectureBtnGroup").find('.activeBundle');
            if (livelectureElem.data('value')) {

                triggerOnClick(livelectureElem.data('value'), livelectureElem);
            }
        } else {
            $('[id$=hdnCourseList]').val(uniq.join());
            let totalAmount = getApplicableAmountForLiveLectures();
            console.log(totalAmount);

            // to revert if the amount is below Rs.0/-
            // if(totalAmount >= 0) {
            let subjectsLength = totalAmount > 0 ? uniq.length - CourseCount : '0';
            console.log(".choose Subject --- start  -->");
            console.log(cartList);
            cartList[0] = {
                'label': `Live Lectures - ${subjectsLength} Subjects`,
                'amount': totalAmount
            };
            console.log(cartList);
            console.log(".choose Subject --- end  -->");
            updateCart();
            // } 
            // else {
            //     if($(this).hasClass('active') && selectedOptionArray.length > 0) {
            //         selectedOptionArray.splice($.inArray(selectionVal, selectedOptionArray), 1);
            //         $(this).removeClass('active');
            //     } else if(!$(this).hasClass('active')) {
            //         $(this).addClass('active');
            //         selectedOptionArray.push(selectionVal);
            //     }
            //     uniq = selectedOptionArray.length > 0 ? [...new Set(selectedOptionArray)] : [];
            //     console.log(uniq);
            //     $('[id$=hdnCourseList]').val(uniq.join());
            // }

        }
    });

    // -----------------------------------For Backlog Subject start -----------------------------------------------------------------
    $('body').on('click', '.ChooseBacklogSubjects', function () {
        console.log("inside backlog script");
        let selectionBacklogVal = $(this).data('value').toString();
        console.log(selectionBacklogVal);
        let selectedBacklogOptions = $('[id$=hdnBacklogList]').val();
        console.log(selectedBacklogOptions);
        // let totalSubjects = $('.ChooseBacklogSubjects').length;
        // let limitedSubjects = totalSubjects - 1;
        let selectedBacklogOptionArray = selectedBacklogOptions != null && selectedBacklogOptions != '' ? selectedBacklogOptions.split(',') : [];
        if ($(this).hasClass('active') && selectedBacklogOptionArray.length > 0) {
            selectedBacklogOptionArray.splice($.inArray(selectionBacklogVal, selectedBacklogOptionArray), 1);
            $(this).removeClass('active');
        } else if (!$(this).hasClass('active')) {
            console.log('@@#@#@#');
            $(this).addClass('active');
            console.log(selectedBacklogOptionArray);
            console.log(selectionBacklogVal);
            selectedBacklogOptionArray.push(selectionBacklogVal);
        }
        console.log(selectedBacklogOptionArray);
        let uniq = selectedBacklogOptionArray.length > 0 ? [...new Set(selectedBacklogOptionArray)] : [];
        console.log(uniq);
        $('[id$=hdnBacklogList]').val(uniq.join());
        let totalBacklogAmount = getApplicableAmountForBacklog();
        console.log(totalBacklogAmount);

        // to revert if the amount is below Rs.0/-
        // if(totalBacklogAmount >= 0) {
        let subjectsBacklogLength = totalBacklogAmount > 0 ? uniq.length - BacklogCount : '0';
        if(totalBacklogAmount <= 0 && subjectsBacklogLength <= 0) {
            delete cartList[1];
        } else {
            cartList[1] = {
                'label': `Backlog Live Lectures - ${subjectsBacklogLength} Subjects`,
                'amount': totalBacklogAmount
            };
        }
        updateCart();
    });

    //---------------------------------------------------For Backlog Subject stop---------------------------------------------------------

    $('input[type=radio][name=paymentGatewayGrp]').change(function() {
        var selectedOpt = this.value;
        console.log('this.value ==>'+selectedOpt);
        $('[id$=hdngetWay]').val(selectedOpt);
        callMakePayment();
        $('.loaderPanel').show();
        $('[id$=PaymentGateWayOption]').css("display", "none");
    });

    $('body').on('click', '.toggleBtn', function () {
        let idval = $('.' + $(this).data('id'));
        idval.toggle();
    });

    $(window).load(function () {
        $(".loaderPanel").fadeOut("slow");
    });
});

function onLoadSetLiveLectures(courseList, backlogList) {
    let feeType = $('[id$=hdnPaymentOption]').val() ? $('[id$=hdnPaymentOption]').val().capitalize() : '';

    //to show live lectures types based on the Tuition Payment type
    let objOffeetTypeVsLectureType = {
        'ReRegistrationPayment': '1SemLecturesFee',
        'Admission': '1SemLecturesFee',
        'AnnualFee': '2SemLecturesFee',
        'MultipleSemFee': '3SemLecturesFee',
        '3SemFee': '3SemLecturesFee',
        'FullFee': '4SemLecturesFee',
        'AnnualFee-Considered': '1SemLecturesFee',
        'MultipleSemFee-Considered': '1SemLecturesFee',
        'FullFee-Considered': '1SemLecturesFee',
        '3SemFee-Considered': '1SemLecturesFee',
    };
    console.log(feeType);
    console.log('hdnCurrentSemester -------------> ' + $('[id$=hdnCurrentSemester]').val())
    if (objOffeetTypeVsLectureType.hasOwnProperty(feeType)) {
        let lectureType = objOffeetTypeVsLectureType[feeType];
        let selectedlectureType = $('[id$=hdnLiveLecturesOption]').val();
        console.log('selectedlectureType -------------> ' + $('[id$=hdnLiveLecturesOption]').val())
        let sem = parseInt(lectureType.charAt(0));
        $('.SemBundles').hide();
        $('.SemBundles').removeClass('activeBundle');

        let semLiveLecture1 = $(`.SemBundles[data-value="1SemLecturesFee"]`);
        semLiveLecture1.addClass('activeBundle');

        
        console.log($('[id$=jsonMapOfsetOfApplicablePaymentOptionForStudent]').val())

        let jsonMapOfsetOfApplicablePaymentOptionForStudent = $('[id$=jsonMapOfsetOfApplicablePaymentOptionForStudent]').val();
        let MapOfsetOfApplicablePaymentOptionForStudent = jsonMapOfsetOfApplicablePaymentOptionForStudent ? JSON.parse(jsonMapOfsetOfApplicablePaymentOptionForStudent) : [];

        MapOfsetOfApplicablePaymentOptionForStudent.forEach(element => {
            if (element !== 'Custom') {
                let elem = $(`.SemBundles[data-value="${element}"]`);
                // elem.addClass('activeBundle');
                elem.show();
            }
        });

        // for (let index = 1; index <= sem; index++) {
        //     let lectures = `${index}SemLecturesFee`;
        //     let elem = $(`.SemBundles[data-value="${lectures}"]`);
        //     if (lectures === '1SemLecturesFee') {
        //         elem.addClass('activeBundle');
        //     }
        //     elem.show();
        // }

        // to reset the cart list if the tution type has been changed. 
        if (selectedlectureType && selectedlectureType != 'Custom' && selectedlectureType != 'No') {
            console.log('to reset the cart list if the tution type has been changed.')
            let selectedSem = parseInt(selectedlectureType.charAt(0));
            if (selectedSem > sem) {
                delete cartList[0];
                $('[id$=hdnLiveLecturesOption]').val('');
                $('.PaymentForLiveLectures').removeClass('active');
            }
        }
    } else {
        console.log('inside delete ---------->')
        delete cartList[0];
        delete cartList[1];
        $('[id$=hdnLiveLecturesOption]').val('');
        $('.PaymentForLiveLectures').removeClass('active');
        $('[id$=hdnCourseList]').val('');
        $('.ChooseSubjects').removeClass('active');
        $('[id$=hdnBacklogList]').val('');
        $('.ChooseBacklogSubjects').removeClass('active');
    }

    // to show update in my cart
    if ($('[id$=hdnLiveLecturesOption]').val() && $('[id$=hdnCourseList]').val()) {
        setSelectedSubjects();
    }
    if ($('[id$=hdnBacklogList]').val()) {
        console.log('setSelectedBacklogSubjects()')
        setSelectedBacklogSubjects();
    }

    // Set count of already purchased Courses
    let selectedOptionArray = courseList ? courseList.split(',') : [];
    let selectedBacklogOptionArray = backlogList ? backlogList.split(',') : [];
    CourseCount = selectedOptionArray.length;
    BacklogCount = selectedBacklogOptionArray.length;
    console.log('CourseCount ==>' + CourseCount);
    console.log('BacklogCount ==>' + BacklogCount);
    updateCart();
}

function setSelectedSubjects() {
    console.log("inside setSelectedSubject ---->");
    console.log('selectedlectureType -------------> ' + $('[id$=hdnLiveLecturesOption]').val())
    // To set the Custom live lecture type selected
    let livelectureElem = $(`.PaymentForLiveLectures[data-value="Custom"]`);
    console.log(livelectureElem)
    console.log(livelectureElem.data('value'))
    if (livelectureElem.data('value')) {
        triggerOnClick(livelectureElem.data('value'), livelectureElem);

    }
    console.log('selectedlectureType -------------> ' + $('[id$=hdnLiveLecturesOption]').val())

    // To set the Selected Subjects active
    let selectedOptions = $('[id$=hdnCourseList]').val();
    console.log(selectedOptions);
    let selectedOptionArray = selectedOptions != null && selectedOptions != '' ? selectedOptions.split(',') : [];
    $(".ChooseSubjects").each(function (index, element) {
        let courseId = $(this).data('value').toString();
        console.log(courseId);
        console.log(selectedOptionArray);
        if ($.inArray(courseId, selectedOptionArray) != -1) {
            $(this).addClass('active disabledOption');
        }
    });
    console.log(selectedOptionArray);
    let totalAmount = getApplicableAmountForLiveLectures();
    let subjectsLength = totalAmount > 0 ? selectedOptionArray.length - CourseCount : '0';
    console.log(".setSelectedSubject --- start  -->");
    console.log(cartList);
    cartList[0] = {
        'label': `Live Lectures - ${subjectsLength} Subjects`,
        'amount': totalAmount
    };
    console.log(cartList);
    console.log(".setSelectedSubject --- end  -->");
}

// ----------------------------------setSelectedLectureForBacklog On Load------------------
function setSelectedBacklogSubjects() {
    console.log("inside setSelectedBacklogSubjects ---->");

    // To set the Selected Subjects active
    let selectedOptions = $('[id$=hdnBacklogList]').val();
    console.log(selectedOptions);
    let selectedOptionArray = selectedOptions != null && selectedOptions != '' ? selectedOptions.split(',') : [];
    $(".ChooseBacklogSubjects").each(function (index, element) {
        let courseId = $(this).data('value').toString();
        console.log(courseId);
        console.log(selectedOptionArray);
        if ($.inArray(courseId, selectedOptionArray) != -1) {
            $(this).addClass('active');
        }
    });
    console.log(selectedOptionArray);
    let totalAmount = getApplicableAmountForBacklog();
    let subjectsLength = totalAmount > 0 ? selectedOptionArray.length - CourseCount : '0';
    cartList[1] = {
        'label': `Backlog Live Lectures - ${subjectsLength} Subjects`,
        'amount': totalAmount
    };
}

function getApplicableAmountForLiveLectures() {
    let jsonStringOfProductVsAmount = $('[id$=jsonStringOfProductVsAmount]').val();
    console.log('jsonStringOfProductVsAmount --> ')
    console.log(jsonStringOfProductVsAmount)
    let mapOfProductVsAmount = JSON.parse(jsonStringOfProductVsAmount);
    let selectedOptionLiveLectures = $('[id$=hdnLiveLecturesOption]').val();
    let feePaidAmount = $('[id$=hdnfeePaidAmount]').val() ? parseFloat($('[id$=hdnfeePaidAmount]').val()) : 0;
    console.log('feePaidAmount ==> ' + feePaidAmount);
    // let feePaidBacklogAmount = $('[id$=hdnfeePaidBacklogAmount]').val() ? parseFloat($('[id$=hdnfeePaidBacklogAmount]').val()) : 0;
    let applicableAmountLL = 0;
    let lstOfLiveLectureFeeType = ['1SemLecturesFee', '2SemLecturesFee', '3SemLecturesFee', '4SemLecturesFee'];
    console.log('selectedOptionLiveLectures ==>' + selectedOptionLiveLectures);
    if (selectedOptionLiveLectures != undefined) {
        if (lstOfLiveLectureFeeType.includes(selectedOptionLiveLectures)) {
            applicableAmountLL = mapOfProductVsAmount[selectedOptionLiveLectures];
        } else if (selectedOptionLiveLectures == 'Custom') {
            let singleSub = mapOfProductVsAmount.hasOwnProperty('Live Lectures') ? mapOfProductVsAmount['Live Lectures'] : 0;
            let selectedSub = $('[id$=hdnCourseList]').val();
            let selectedOptionArray = selectedSub != null && selectedSub != '' ? selectedSub.split(',') : [];
            console.log('selectedSub ==> ' + selectedSub);
            console.log('selectedOptionArray ==> ' + selectedOptionArray);
            applicableAmountLL = singleSub * selectedOptionArray.length;
        }
    }
    if (feePaidAmount > 0 && selectedOptionLiveLectures == 'Custom') {
        applicableAmountLL = applicableAmountLL - feePaidAmount;
    }
    console.log('applicableAmountLL ==>' + applicableAmountLL);
    return applicableAmountLL;
}


// ------------------------------------------getApplicableAmountForBacklog--------------------------------------------

function getApplicableAmountForBacklog() {
    let jsonStringOfProductVsAmount = $('[id$=jsonStringOfProductVsAmount]').val();
    let mapOfProductVsAmount = JSON.parse(jsonStringOfProductVsAmount);
    let feePaidBacklogAmount = $('[id$=hdnfeePaidBacklogAmount]').val() ? parseFloat($('[id$=hdnfeePaidBacklogAmount]').val()) : 0;
    let applicableAmountLL = 0;
    let singleSub = mapOfProductVsAmount.hasOwnProperty('Backlog') ? mapOfProductVsAmount['Backlog'] : 0;
    let selectedSub = $('[id$=hdnBacklogList]').val();
    let selectedOptionArray = selectedSub != null && selectedSub != '' ? selectedSub.split(',') : [];
    applicableAmountLL = singleSub * selectedOptionArray.length;


    if (feePaidBacklogAmount > 0) {
        applicableAmountLL = applicableAmountLL - feePaidBacklogAmount;
    }
    console.log('applicableAmountLL ==>' + applicableAmountLL);
    return applicableAmountLL;
}



function updateCart() {
    let htmtElements = '';
    let totalLiveLectureAmount = 0;
    let totalBacklogAmount = 0;
    let Amount = 0;
    console.log("cartList from updatecart");
    console.log(cartList);
    if (!$.isEmptyObject(cartList)) {
        $.each(cartList, function (key, value) {
            let courseAmount = value.amount;
            htmtElements += `<div class="row">
                <div class="col-md-7">
                    <span>${value.label}</span>
                </div>
                <div class="col-md-5">
                    <span class="fright">${courseAmount}</span>
                </div>
            </div>`;
            Amount += parseInt(value.amount);
            // Amount += parseInt(courseAmount);
        });
        console.log(cartList);
        totalLiveLectureAmount = cartList.hasOwnProperty(0) ? cartList[0].amount : 0;
        console.log(totalBacklogAmount);
        console.log(totalLiveLectureAmount);
        totalBacklogAmount = cartList.hasOwnProperty(1) ? cartList[1].amount : 0;
        console.log("total Amount " + totalBacklogAmount + totalLiveLectureAmount);
        htmtElements += `<hr style="border-top: 1px solid black"><div class="row">
                <div class="col-md-7">
                    <span>Total Fees</span>
                </div>
                <div class="col-md-5">
                    <span class="fright">${Amount}</span>
                </div>
            </div>`;
    } else {
        htmtElements = `<center><img src="${imageURL}" width="90%"/></center><hr style="border-top: 1px solid black" />`;
    }

    $('.mycartClass').html(htmtElements);
    let oldCourseList = $('[id$=hdnOldCourseList]').val() ? $('[id$=hdnOldCourseList]').val().split(',') : [];
    let CourseList = $('[id$=hdnCourseList]').val() ? $('[id$=hdnCourseList]').val().split(',') : [];
    let oldBacklogList = $('[id$=hdnOldBacklogList]').val() ? $('[id$=hdnOldBacklogList]').val().split(',') : [];
    let BacklogList = $('[id$=hdnBacklogList]').val() ? $('[id$=hdnBacklogList]').val().split(',') : [];
    let selectedlectureType = $('[id$=hdnLiveLecturesOption]').val();
    console.log(selectedlectureType);
    let subjectCanBeSwitch = true;
    let checker = (arr, target) => target.every(v => arr.includes(v));
    if (($('[id$=hdnLectureCantBeSwitch]').val()).valueOf() == "false") {
        if (selectedlectureType == 'Custom') {
            subjectCanBeSwitch = checker(BacklogList, oldBacklogList) && checker(CourseList, oldCourseList) ? true : false;
        } else {
            subjectCanBeSwitch = checker(BacklogList, oldBacklogList);

        }
    }
    console.log($('[id$=hdnLectureCantBeSwitch]').val());
    console.log(checker(BacklogList, oldBacklogList));
    console.log(subjectCanBeSwitch);
    if (Amount >= 0 && (selectedlectureType && selectedlectureType != 'Custom' && selectedlectureType != 'No' || CourseList.length >= oldCourseList.length) && BacklogList.length >= oldBacklogList.length  && subjectCanBeSwitch) {
        $('.makePayment').prop("disabled", false);
        let labelVal = Amount > 0 && (totalLiveLectureAmount > 0 || totalBacklogAmount > 0) ? 'Make Payment' : 'Update';
        $('.makePayment').text(labelVal);
    } else {
        $('.makePayment').prop("disabled", true);
    }
}

function triggerOnClick(selectionVal, elem) {
    console.log("trigger method --------->")
    console.log(elem)
    let totalAmount = 0, totalSubjects = $('.ChooseSubjects').length;
    $('[id$=hdnLiveLecturesOption]').val(selectionVal);
    $('.PaymentForLiveLectures').removeClass('active');
    console.log('selectedlectureType -------------> ' + $('[id$=hdnLiveLecturesOption]').val())
    elem.addClass('active');
    if (selectionVal == 'Custom') {
        if (!$('[id$=strSecToShow]').val()) {
            let semester = ordinal(parseInt($('[id$=hdnCurrentSemester]').val()));
            showHtmlMessage(null, `You will be able to select subjects and pay for live lectures only for ${semester} semester. For subsequent semesters payment for live lectures will be applicable at the time of re-registration.`);
        }
        $('[id$=strSecToShow]').val('');
        $('.SubjectSection').removeClass('hide');
        $('.SubjectSection').show();
        if ($('.ChooseSubjects').hasClass('disabledOption')) {
            $('.disabledOption').addClass('active');
            let selectedOptionArray = [];
            console.log("lennn ----------- " + $('.disabledOption').length);
            $(".disabledOption").each(function (index, element) {
                let courseId = $(this).data('value').toString();
                console.log('courseId ==>' + courseId);
                console.log('selectedOptionArray ==>' + selectedOptionArray);
                selectedOptionArray.push(courseId);
            });
            console.log("selectedOptionArray --- " + selectedOptionArray);
            let uniq = selectedOptionArray.length > 0 ? [...new Set(selectedOptionArray)] : [];
            console.log("uniq " + uniq);
            $('[id$=hdnCourseList]').val(uniq.join());
            console.log(cartList);
        }
    } else {
        $('.SubjectSection').hide();
        $('.ChooseSubjects').removeClass('active');
        $('[id$=hdnCourseList]').val('');
        if (selectionVal != 'No') {
            let jsonStringOfProductVsSubjects = $('[id$=hdnSubjectsCount]').val();
            let mapOfProductVsSubjects = JSON.parse(jsonStringOfProductVsSubjects);
            totalSubjects = mapOfProductVsSubjects[selectionVal];
            totalAmount = getApplicableAmountForLiveLectures();
            console.log(totalAmount);
            totalSubjects = totalAmount > 0 ? totalSubjects - CourseCount : '0';
            console.log("trigger function --start ---->");
            console.log(cartList);
            cartList[0] = {
                'label': `Live Lectures - ${totalSubjects} Subjects`,
                'amount': totalAmount
            };
            console.log(cartList);
            console.log("trigger function -- end ---->")
        } else {
            delete cartList[0];
        }
        updateCart();
    }
}

function showHtmlMessage(header, message) {
    header = header == null ? 'Important Message' : header;
    $('#errorTitle').text(header);
    $('#errorMessage').html(message);
    $('#errorPopupPanel').show();
}

function hideme() {
    $('[id$=PaymentGateWayOption]').css("display", "none");
    $('[id$=errorPoupId]').css("display", "none");
}

function openPopUp() {
    // let strSecToShow = $('[id$=strSecToShow]').val();
    let message = $('[id$=message]').val();
    showHtmlMessage(null, message);
    $('[id$=strSecToShow]').val('');
    $('[id$=message]').val('');
}

function hidePopup() {
    $('#errorTitle').text('');
    $('#errorMessage').text('');
    $('#errorPopupPanel').hide();
}

function hideMe() {
    $('[id$=MsgPopUp]').hide();
}

function ordinal(n) {
    var s = ["th", "st", "nd", "rd"];
    var v = n%100;
    return n + (s[(v-20)%10] || s[v] || s[0]);
}

// to capitalize
String.prototype.capitalize = function () {
    return this.charAt(0).toUpperCase() + this.slice(1);
}