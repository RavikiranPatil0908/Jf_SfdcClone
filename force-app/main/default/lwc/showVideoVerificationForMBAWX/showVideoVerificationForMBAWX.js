import { LightningElement, track, wire, api} from 'lwc';
import createStudentRating from "@salesforce/apex/VideoVerificationFormController.createStudentRating";
import getAccount from "@salesforce/apex/VideoVerificationFormController.getAccount";
import Toast from 'lightning/toast';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class ShowVideoVerificationForMBAWX extends LightningElement {
    @track dobVerification;
    @track enrollmentVerification;
    @track programDurationVerification;
    @track hasLoan = false; // Set this based on the student's data
    @track loanAgreementVerification;

    @track session;//create
    @track examinationComponent;//create
    @track examEvaluation;//create
    @track termEndExamination;//create
    @track passingMarksVerification;
    @track reexamProcess;//create
    @track programValidityVerification;
    @track examMalpracticeVerification;
    @track specialCaseStudent;
    @track placementServicesVerification;
    @track engagementVerification;
    @track cancellationDateVerification;
    @track comments;
    userName;
   
    @api recordId;
    @api isNo;
    @api content;
    @api isFormFilled;
    @track validityDate;
    @api taskId;
    @api ratingId;
   
    @track questions = [{question1:true,value:'dobVerification'}, {question2:'',value:'enrollmentVerification'},
        {question3:'',value:'programDurationVerification'}, {question4:'',value:'loanAgreementVerification'},
        {question5:'',value:'session'}, {question6:'',value:'examinationComponent'},
        {question7:'',value:'examEvaluation'},{question8:'',value:'termEndExamination'},
        {question9:'',value:'passingMarksVerification'},{question10:'',value:'reexamProcess'},
        {question11:'',value:'programValidityVerification'},{question12:'',value:'examMalpracticeVerification'},
        {question13:'',value:'specialCaseStudent'},{question14:'',value:'placementServicesVerification'},
        {question15:'',value:'engagementVerification'},{question16:'',value:'cancellationDateVerification'}
    ];

    @track questionLabel = { question5: 'Are you aware that sessions are conducted - Monday to Friday – (07:00PM to 09:30 PM) every evening? In case of any public holidays, these sessions will be rescheduled to weekends. ',
                             question6: 'Are you aware that examination has two components internal assessment of 60 marks and Term End examination of 40 marks?',
                             question7: 'Each subject will have 6 internal assessments (12 marks each). Out of which Best 5 IAs, will be considered for the final evaluation. These will be conducted in the evening from 09:45 PM to 10:30 PM post live sessions. Note: Missed IAs cannot be rescheduled',
                             question8: 'Term end examination is conducted on Saturday/Sunday at 11:00AM. You can select either of the one slot as per your convenience. The dates of these slots will be provided in the batch planner. Note: Missed TEE cannot be rescheduled.',
                             question9: 'Are you aware that passing marks is 40 marks per subject and there is no grace marks. Also, you need to score minimum of 16 marks in Term end examination to clear the subject.',
                             question10: 'If a student is not able to clear a TERM, he/she has to either repeat the subject or appear for a Re-exam by paying the applicable fees. Student will be allowed to progress to the next TERM only if they clear all subjects. ',
                             question12: 'Currently our examination can be attempted online from any location. However, if you are found indulging in any malpractices such as using phones, books, or not being visible on camera during the exam, the exam will be marked as unfair, and the subject will be marked as ‘null and void’. Repeat instances of malpractices are subject to penalties as per the Unfair Means Policy.' +
                                        'Note- The University reserves the right to switch to center-based examinations completely at its discretion at any point of time.',
                             question13: 'Since you have applied under the Special needs category, please note if you opt for a scribe during examination, you would have to attempt the examination at our examination centre only. If you do not opt for scribe during the examination, you can opt for online examination from your location.',
                             question14: 'There are no placement services or referral bonus offered by the University. ',
                             question15: 'As per UGC guidelines, you need to have 75% engagement throughout the program .i.e 90 hours per subject per semester. This is can be achieved by attending live sessions, viewing recordings and E-Books, participating in discussion forums, quizzes, posting queries and assignment submissions. Note: Students will not be allowed to attempt the TEE if the engagement is less than 75%'
                            };
    
    objAccount;
    objOpp;
    // objCalender;
    validityDate;
    //cancelDate;
    dataValue;
    dob;
    //cancelDate2;
    mapOfCancelDate;

    @wire(getAccount, {recordId: '$recordId'})
    wiredAccount ({ data, error}) {
        if (data) {
            this.objAccount = data.acc;
            this.objOpp = data.opp;
            //this.objCalender = data.calender;
            this.cancelDate = data.cancelDate;
            this.validityDate = data.validityDate;
            this.cancelDate2 = data.cancelDate2;
            // console.log('cancelDate--->' + this.cancelDate);
            console.log('validityDate--->' + this.validityDate);
            console.log('acc--->' + JSON.stringify(this.objAccount));
            console.log('opp--->' + JSON.stringify(this.objOpp));
            // console.log('Cal--->' + JSON.stringify(this.objCalender));
            const dateOfBirth = new Date(this.objAccount.nm_DateOfBirth__c);
            this.mapOfCancelDate = data.mapOfConditionVsCancellationDate;
            this.dob = ("0" + dateOfBirth.getDate()).slice(-2) + "-" + ("0"+(dateOfBirth.getMonth()+1)).slice(-2) + "-" + dateOfBirth.getFullYear();
            if (this.objOpp != null && this.objOpp.Loan_Type__c != null && this.objOpp.Loan_Type__c != '' && this.objOpp.Down_Payment_Made__c) {
                this.hasLoan = true;
                console.log('hasLoan--->' + this.hasLoan);
            }
            console.log(' hasLoan--->' + this.hasLoan);
        } else if (error) {
            console.error('Some thing went wrong', error);
            this.handleShowToast('Error','Some thing went wrong','error');
            //handleClose();
            return;
        }
    }
    
    // Wire to get the User record
    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    userRecord({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching user data', error);
        }
    }

    //1
    dobOptions = [
        { label: 'Yes, it is correct', value: 'Yes, it is correct' },
        { label: 'No, it does not match (Re-verification needed)', value: 'No, it does not match (Re-verification needed)' },
    ];
    //2
    enrollmentOption = [
        { label: 'Yes, it is correct', value: 'Yes, it is correct' },
        { label: 'No, the student had the wrong information and does not agree', value: 'No, the student had the wrong information and does not agree' },
    ];
    //3
    programDurationOptions = [
        { label: 'Yes, continue, the student is aware', value: 'Yes, continue, the student is aware' },
        { label: 'No, the student is not aware and does not want to continue', value: 'No, the student is not aware and does not want to continue' },
    ];
    //4,12a
    disAgreeOption = [
        { label: 'Yes, I agree', value: 'Yes, I agree' },
        { label: 'No, Disagree', value: 'No, Disagree' },
    ];

    //5,6,7,8,9,10,11,12b,14,15
    notAgreeOptions = [
        { label: 'Yes, the student is aware', value: 'Yes, the student is aware' },
        { label: 'No, the student had the wrong information and does not agree', value: 'No, the student had the wrong information and does not agree' },
    ];
    //13
    placementServicesOptions = [
        { label: 'Yes, continue, the student is aware', value: 'Yes, continue, the student is aware' },
        { label: 'No, the student had the wrong information and does not want to continue with the program', value: 'No, the student had the wrong information and does not want to continue with the program' },
    ];

    handleChange(event) {
        this.dataValue = event.currentTarget.dataset.value;
        if (this.dataValue === 'Question2') {
            this.dobVerification = event.target.value;
            this.questions[1].question2 = this.dobVerification === 'Yes, it is correct' ? true : false;
            this.questions[1].question2 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question3') {
            this.enrollmentVerification = event.target.value;
            this.questions[2].question3 = this.enrollmentVerification === 'Yes, it is correct' ? true : false;
            this.questions[2].question3 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question4') {
            this.programDurationVerification = event.target.value;
            if (this.programDurationVerification !== 'Yes, continue, the student is aware') {
                this.hideQuestion();
            }
            else if (this.programDurationVerification === 'Yes, continue, the student is aware' && this.hasLoan) {
                this.questions[3].question4 = true;
            }
            else if (this.programDurationVerification === 'Yes, continue, the student is aware' && !this.hasLoan) {
                this.questions[3].question4 = false;
                this.questions[4].question5 = true;
            }
        }
        else if (this.dataValue === 'Question5') {
            this.loanAgreementVerification = event.target.value;
            this.questions[4].question5 = this.loanAgreementVerification === 'Yes, I agree' ? true : false;
            this.questions[4].question5 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question6') {
            this.session = event.target.value;
            this.questions[5].question6 = this.session === 'Yes, the student is aware' ? true : false;
            this.questions[5].question6 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question7') {
            this.examinationComponent = event.target.value;
            this.questions[6].question7 = this.examinationComponent === 'Yes, the student is aware' ? true : false;
            this.questions[6].question7 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question8') {
            this.examEvaluation = event.target.value;
            this.questions[7].question8 = this.examEvaluation === 'Yes, the student is aware' ? true : false;
            this.questions[7].question8 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question9') {
            this.termEndExamination = event.target.value;
            this.questions[8].question9 = this.termEndExamination === 'Yes, the student is aware' ? true : false;
            this.questions[8].question9 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question10') {
            this.passingMarksVerification = event.target.value;
            this.questions[9].question10 = this.passingMarksVerification === 'Yes, the student is aware' ? true : false;
            this.questions[9].question10 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question11') {
            this.reexamProcess = event.target.value;
            this.questions[10].question11 = this.reexamProcess === 'Yes, the student is aware' ? true : false;
            this.questions[10].question11 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question12') {
            this.programValidityVerification = event.target.value;
            if (this.programValidityVerification !== 'Yes, the student is aware') {
                this.hideQuestion();
            }
            else if (this.programValidityVerification === 'Yes, the student is aware' && (this.objAccount.Differently_abled__c === undefined || this.objAccount.Differently_abled__c === 'No')) {
                this.questions[11].question12 = true;
            }
            else if (this.programValidityVerification === 'Yes, the student is aware' && (this.objAccount.Differently_abled__c === 'Yes')) {
                this.questions[12].question13 = true;
            }
        }
        else if (this.dataValue === 'Question14') {
            if (this.questions[11].question12) {
                this.examMalpracticeVerification = event.target.value;
                this.questions[13].question14 = this.examMalpracticeVerification === 'Yes, I agree' ? true : false;
                this.questions[13].question14 === false ? this.hideQuestion() : true;
                this.questions[12].question13 = false;
            }
            else if (this.questions[12].question13) {
                this.specialCaseStudent = event.target.value;
                this.questions[13].question14 = this.specialCaseStudent === 'Yes, the student is aware' ? true : false;
                this.questions[13].question14 === false ? this.hideQuestion() : true;
                this.questions[11].question12 = false;
            }
        }
        else if (this.dataValue === 'Question15') {
            this.placementServicesVerification = event.target.value;
            this.questions[14].question15 = this.placementServicesVerification === 'Yes, continue, the student is aware' ? true : false;
            this.questions[14].question15 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question16') {
            this.engagementVerification = event.target.value;
            this.questions[15].question16 = this.engagementVerification === 'Yes, the student is aware' ? true : false;
            this.questions[15].question16 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === '') {
            this.cancellationDateVerification = event.target.value;
        }
        else if (this.dataValue === 'Comment') {
            this.comments = event.target.value;
        }
    }

    hideQuestion() {
        let check = false;
        let count = 0;
        
        console.log('hide');
        this.questions.forEach(questionObj => {
            count = count + 1;
            if (questionObj.hasOwnProperty(this.dataValue.toLowerCase())) {
                check = true;
            }
            console.log('lower ---->' + this.dataValue.toLowerCase());
            if (check) {
                let questionKey = `question${count}`;
                // questionObj.find(question => question.hasOwnProperty(questionKey));
                questionObj[questionKey] = false;
                let resetData = questionObj.value;
                this[resetData] = '';
                console.log(questionObj.value);
                console.log(questionObj.question2);
            }
          });

    }

    get question1() {
        return this.questions[0].question1;
    }

    get question2() {
        return this.questions[1].question2;
    }

    get question3() {
        return this.questions[2].question3;
    }

    get question4() {
        return this.questions[3].question4 && this.hasLoan;
    }

    get question5() {
        return this.questions[4].question5;
    }

    get question6() {
        return this.questions[5].question6;
    }

    get question7() {
        return this.questions[6].question7;
    }

    get question8() {
        return this.questions[7].question8;
    }

    get question9() {
        return this.questions[8].question9;
    }

    get question10() {
        return this.questions[9].question10;
    }

    get question11() {
        return this.questions[10].question11;
    }

    get question12() {
        return this.questions[11].question12;
    }

    get question13() {
        return this.questions[12].question13;
    }

    get question14() {
        return this.questions[13].question14;
    }

    get question15() {
        return this.questions[14].question15;
    }

    get question16() {
        return this.questions[15].question16;
    }

    get dobLabel() {
        if (this.objAccount && this.dob) {
            return `Please could you confirm your Date of Birth? (${this.dob})`;
        }
        return '';
    }

    get enrollmentLabel() {
        if (this.objAccount && this.objAccount.nm_Program__c && this.objAccount.Specialization_Type__c == 'Single Specialisation' && this.objOpp.nm_Year__c && this.objOpp.nm_Session__c) {
            return `You have enrolled for '${this.objAccount.nm_Program__r.nm_ProgramName__c}' and you are enrolled for the '${this.objOpp.nm_Session__c} ${this.objOpp.nm_Year__c}' batch.`;
        }
        if (this.objAccount && this.objAccount.nm_Program__c && this.objAccount.Specialization_Type__c == 'Dual Specialisation' && this.objAccount.nm_Program2__c && this.objOpp.nm_Year__c && this.objOpp.nm_Session__c) {
            return `You have enrolled for '${this.objAccount.nm_Program__r.nm_ProgramName__c}' and '${this.objAccount.nm_Program2__r.nm_ProgramName__c}' and you are enrolled for the '${this.objOpp.nm_Session__c} ${this.objOpp.nm_Year__c}' batch.`;
        }
        return '';
    }

    get durationLabel() {
        if (this.objAccount && this.objAccount.nm_Program__r.nm_ProgramDuration__c) {
            return `Are you aware that the duration of the program is '${this.objAccount.nm_Program__r.nm_ProgramDuration__c}' year and mode of delivery is online? Do you want to continue?`;
        }
        return '';
    }

    get loanLabel() {
        if (this.objOpp && this.objOpp.Loan_Type__c && this.objOpp.Tenure__c && this.objOpp.Loan_Amount__c) {
            return `We understand that you have opted for loan from (${this.objOpp.Loan_Type__c} for Rs.${this.objOpp.Loan_Amount__c}/- for a period of ${this.objOpp.Tenure__c} months) please note that the University has only facilitated this loan for you and your agreement is directly with the loan provider - ${this.objOpp.Loan_Type__c}. You have to abide by the terms of the loan agreement and any further issue due to this agreement is not the University's responsibility and you will have to directly deal with the loan provider.`;
        }
        return '';
    }

    //5,6,7,7,8,9,10,12,13,14 no label

    //11
    get validityLabel() {
        if (this.validityDate) {
            return `Please note the program validity is until '${this.validityDate}'. You have to complete your program by validity date.`;
        }
        return '';
    }

    // get lastDateLabel() {
    //     if (this.mapOfCancelDate) {
    //         console.log('Cancel date--->' + this.mapOfCancelDate[0]);
    //         return `Please note that if admission is cancelled by '${this.mapOfCancelDate['Amount']?.To_Date__c}' processing fee of Rs. ${this.mapOfCancelDate['Amount']?.Amount__c}/- will be deducted. Post that deduction applicable will be from '${this.mapOfCancelDate['PostDeduction10']?.From_Date__c}' to '${this.mapOfCancelDate['PostDeduction10']?.To_Date__c}' - ${this.mapOfCancelDate['PostDeduction10']?.Percentage__c}% of semester fee, from '${this.mapOfCancelDate['PostDeduction20']?.From_Date__c}' to '${this.mapOfCancelDate['PostDeduction20']?.To_Date__c}' - ${this.mapOfCancelDate['PostDeduction20']?.Percentage__c}% of semester fee, from '${this.mapOfCancelDate['PostDeduction50']?.From_Date__c}' to '${this.mapOfCancelDate['PostDeduction50']?.To_Date__c}' - ${this.mapOfCancelDate['PostDeduction50']?.Percentage__c}% of semester fee and from '${this.mapOfCancelDate['Admisssion']?.From_Date__c}' to '${this.mapOfCancelDate['Admisssion']?.To_Date__c}' - 100% of semester fee. Please note Registration fee of 1500/- is non-refundable. `
    //     }
    //     return '';
    // }

    get lastDateLabel() {
        if (this.mapOfCancelDate) {
            const formatDate = (dateStr) => {
                if (!dateStr) return ''; // Handle undefined date strings
                const date = new Date(dateStr);
            
                // Get day, month, and year
                const day = date.getDate();
                const month = date.toLocaleString('default', { month: 'long' }); // Full month name
                const year = date.getFullYear();
            
                // Add ordinal suffix to day
                const ordinalSuffix = (n) => {
                    if (n > 3 && n < 21) return 'th';
                    switch (n % 10) {
                        case 1: return 'st';
                        case 2: return 'nd';
                        case 3: return 'rd';
                        default: return 'th';
                    }
                };
            
                return `${day}${ordinalSuffix(day)} ${month} ${year}`;
            };
    
            return `Please note that if admission is cancelled by ${formatDate(this.mapOfCancelDate['Amount']?.To_Date__c)} processing fee of Rs. ${this.mapOfCancelDate['Amount']?.Amount__c}/- will be deducted. Post that deduction of ${this.mapOfCancelDate['PostDeduction10']?.Percentage__c}% of program fee will be applicable till ${formatDate(this.mapOfCancelDate['PostDeduction10']?.To_Date__c)}, deduction of ${this.mapOfCancelDate['PostDeduction20']?.Percentage__c}% of Program fee till ${formatDate(this.mapOfCancelDate['PostDeduction20']?.To_Date__c)}, deduction of ${this.mapOfCancelDate['PostDeduction50']?.Percentage__c}%  of Program fee till ${formatDate(this.mapOfCancelDate['PostDeduction50']?.To_Date__c)} and 100% deduction of Program fee till ${formatDate(this.mapOfCancelDate['Admisssion']?.To_Date__c)}. Please note Registration fee of 1500/- is non-refundable.`;
        }
        return '';
    }

    
    @api 
    validate() {
        this.isNo = false;
        this.isFormFilled = false;

        if ((this.questions[0].question1 === true && !this.isNotBlank(this.dobVerification)) ||
              (this.questions[1].question2 === true && !this.isNotBlank(this.enrollmentVerification)) ||
              (this.questions[2].question3 === true && !this.isNotBlank(this.programDurationVerification)) ||
              (this.questions[3].question4 === true && !this.isNotBlank(this.loanAgreementVerification)) ||
              (this.questions[4].question5 === true && !this.isNotBlank(this.session)) ||
              (this.questions[5].question6 === true && !this.isNotBlank(this.examinationComponent)) ||
              (this.questions[6].question7 === true && !this.isNotBlank(this.examEvaluation)) ||
              (this.questions[7].question8 === true && !this.isNotBlank(this.termEndExamination)) ||
              (this.questions[8].question9 === true && !this.isNotBlank(this.passingMarksVerification)) ||
              (this.questions[9].question10 === true && !this.isNotBlank(this.reexamProcess)) ||
              (this.questions[10].question11 === true && !this.isNotBlank(this.programValidityVerification)) ||
              (this.questions[11].question12 === true && !this.isNotBlank(this.examMalpracticeVerification)) ||
              (this.questions[12].question13 === true && !this.isNotBlank(this.specialCaseStudent)) ||
              (this.questions[13].question14 === true && !this.isNotBlank(this.placementServicesVerification)) ||
              (this.questions[14].question15 === true && !this.isNotBlank(this.engagementVerification)) ||
              (this.questions[15].question16 === true && !this.isNotBlank(this.cancellationDateVerification))
            ) {
            this.handleShowToast('Error','Please fill all required field','error');
            this.isFormFilled = false;
            return;
        }

        this.isFormFilled = true;
        console.log('after--->' + this.isFormFilled);
        // let rating = {};
        //     rating['Does_Photo_Matched__c'] = 'Yes, the photo matches – Proceed with questionnaire';
        //     rating['Confirm_Correct_DOB__c'] = this.dobVerification;
        //     rating['Confirm_Correct_Program__c'] = this.enrollmentVerification;
        //     rating['Confirm_Correct_Duration__c'] = this.programDurationVerification;
        //     rating['Confirm_Loan_Details__c'] = this.loanAgreementVerification;
        //     rating['Confirm_Session__c'] = this.session;
        //     rating['Confirm_Examination_Component__c'] = this.examinationComponent;
        //     rating['Confirm_Exam_Evaluation__c'] = this.examEvaluation;
        //     rating['Confirm_Term_End_Examination__c'] = this.termEndExamination;
        //     rating['Confirm_Passing_Marks__c'] = this.passingMarksVerification;
        //     rating['Confirm_Reexam_Process__c'] = this.reexamProcess;
        //     rating['Confirm_Validity_Of_Program__c'] = this.programValidityVerification;
        //     rating['Confirm_Exam_Conduction_Process__c'] = this.examMalpracticeVerification;
        //     rating['Confirm_Special_Case__c'] = this.specialCaseStudent;
        //     rating['Confirm_No_Placement_Service__c'] = this.placementServicesVerification;
        //     rating['Confirm_Mandatory_Engagement__c'] = this.engagementVerification;
        //     rating['Confirm_Cancellation_date__c'] = this.cancellationDateVerification;
        //     rating['Comments__c'] = this.comments;
        //     rating['Student__c'] = this.recordId;

        let map1 = {};
        map1['Does the student photo in our database match the person on the video call?'] = 'Yes, the photo matches – Proceed with questionnaire';
        map1[this.dobLabel] = this.dobVerification;
        map1[this.enrollmentLabel] = this.enrollmentVerification;
        map1[this.durationLabel] = this.programDurationVerification;
        map1[this.loanLabel] = this.loanAgreementVerification;
        map1[this.questionLabel.question5] = this.session;
        map1[this.questionLabel.question6] = this.examinationComponent;
        map1[this.questionLabel.question7] = this.examEvaluation;
        map1[this.questionLabel.question8] = this.termEndExamination;
        map1[this.questionLabel.question9] = this.passingMarksVerification;
        map1[this.questionLabel.question10] = this.reexamProcess;
        map1[this.validityLabel] = this.programValidityVerification;
        map1[this.questionLabel.question12] = this.examMalpracticeVerification;
        map1[this.questionLabel.question13] = this.specialCaseStudent;
        map1[this.questionLabel.question14] = this.placementServicesVerification;
        map1[this.questionLabel.question15] = this.engagementVerification;
        map1[this.lastDateLabel] = this.cancellationDateVerification;
        map1['comments'] = this.comments;

            let verify = false;
            if (this.dobVerification !== 'No, it does not match (Re-verification needed)' && this.isNotBlank(this.dobVerification) &&
                this.enrollmentVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.enrollmentVerification) &&
                this.programDurationVerification !== 'No, the student is not aware and does not want to continue' && this.isNotBlank(this.programDurationVerification) &&
                this.loanAgreementVerification !== 'No, Disagree' &&
                this.session !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.session) &&
                this.examinationComponent !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.examinationComponent) &&
                this.examEvaluation !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.examEvaluation) &&
                this.termEndExamination !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.termEndExamination) &&
                this.passingMarksVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.passingMarksVerification) &&
                this.reexamProcess !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.reexamProcess) &&
                this.programValidityVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.programValidityVerification) &&
                this.examMalpracticeVerification !== 'No, Disagree' &&
                this.specialCaseStudent !== 'No, the student had the wrong information and does not agree' && 
                this.placementServicesVerification !== 'No, the student had the wrong information and does not want to continue with the program' && this.isNotBlank(this.placementServicesVerification) &&
                this.engagementVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.engagementVerification) &&
                this.cancellationDateVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.cancellationDateVerification))
            {
                verify = true;
            }

            // let vvcQuestions = {};
            //     vvcQuestions['Question_Does_Photo_Matched__c'] = `Does the student's photo in our database match the person on the video call?`;
            //     vvcQuestions['Question_Correct_DOB__c'] = this.dobLabel;
            //     vvcQuestions['Question_Correct_Program__c'] = this.enrollmentLabel;
            //     vvcQuestions['Question_Correct_Duration__c'] = this.durationLabel;
            //     vvcQuestions['Question_Loan_Details__c'] = this.loanLabel;
            //     vvcQuestions['Question_Session__c'] = this.questionLabel.question5;
            //     vvcQuestions['Question_Examination_Component__c'] = this.questionLabel.question6;
            //     vvcQuestions['Question_Exam_Evaluation__c'] = this.questionLabel.question7;
            //     vvcQuestions['Question_Term_End_Examination__c'] = this.questionLabel.question8;
            //     vvcQuestions['Question_Passing_Marks__c'] = this.questionLabel.question9;
            //     vvcQuestions['Question_Reexam_Process__c'] = this.questionLabel.question10;
            //     vvcQuestions['Question_Validity_Of_Program__c'] = this.validityLabel;
            //     vvcQuestions['Question_Exam_Conduction_Process__c'] = this.questionLabel.question12;
            //     vvcQuestions['Question_Special_Case__c'] = this.questionLabel.question13;
            //     vvcQuestions['Question_No_Placement_Service__c'] = this.questionLabel.question14;
            //     vvcQuestions['Question_Mandatory_Engagement__c'] = this.questionLabel.question15;
            //     vvcQuestions['Question_Cancellation_date__c'] = this.lastDateLabel;

        // console.log('rating-->' + JSON.stringify(rating));
        createStudentRating({verify : verify,recordId : this.recordId,vvcId : this.taskId,mapOfQuestionAndAns : map1,userName : this.userName}).then(result => {
            console.log('created--->' + result.msg);
            this.handleShowToast('Success',result.msg,'success');
            // this.ratingId = result.ratingId;
            //handleClose();
        }).catch(error => {
            console.log(JSON.stringify(error));
            console.log('error--->' + error);
            this.handleShowToast('Error','Some thing went wrong','error');
            //handleClose();
        })
        
        this.content = '<ul>'
        if (this.dobVerification === 'No, it does not match (Re-verification needed)') {
            this.content = this.content + '<li>' + this.dobLabel +  '</li>';
            this.isNo = true;
        }
        if (this.enrollmentVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.enrollmentLabel + '</li>';
            this.isNo = true;
        }
        if (this.programDurationVerification === 'No, the student is not aware and does not want to continue') {
            this.content = this.content + '<li>' + this.durationLabel + '</li>';
            this.isNo = true;
        }
        if (this.loanAgreementVerification === 'No, Disagree') {
            this.content = this.content + '<li>' + this.loanLabel + '</li>';
            this.isNo = true;
        }
        if (this.session === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>'+ this.questionLabel.question5 + '</li>';
            this.isNo = true;
        }
        if (this.examinationComponent === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question6 + '</li>';
            this.isNo = true;
        }
        if (this.examEvaluation === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question7 + '</li>';
            this.isNo = true;
        }
        if (this.termEndExamination === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question8 + '</li>';
            this.isNo = true;
        }
        if (this.passingMarksVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question9 + '</li>';
            this.isNo = true;
        }
        if (this.reexamProcess === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question10 + '</li>';
            this.isNo = true;
        }
        if (this.programValidityVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.validityLabel + '</li>';
            this.isNo = true;
        }
        if (this.examMalpracticeVerification === 'No, Disagree') {
            this.content = this.content + '<li>' + this.questionLabel.question12 + '</li>';
            this.isNo = true;
        }
        if (this.specialCaseStudent === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question13 + '</li>';
            this.isNo = true;
        }
        if (this.placementServicesVerification === 'No, the student had the wrong information and does not want to continue with the program') {
            this.content = this.content + '<li>' + this.questionLabel.question14 + '</li>';
            this.isNo = true;
        }
        if (this.engagementVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question15 + '</li>';
            this.isNo = true;
        }
        if (this.cancellationDateVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.lastDateLabel + '</li>';
            this.isNo = true;
        }
        
        this.content = this.content + '</ul>';

    }

    handleShowToast(labelValue,setMessage,variantValue) {
        console.log('toast');
        Toast.show({
            label: labelValue,
            message: setMessage,
            mode: 'dismissable',
            variant: variantValue
        });
    }  

    isNotBlank(str) {
        if (str === "" || str === undefined) {
            return false;
        } else {
            return true;
        }
    }

}