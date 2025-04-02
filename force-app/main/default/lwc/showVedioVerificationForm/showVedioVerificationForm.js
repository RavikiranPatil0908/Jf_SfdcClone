import { LightningElement, track, wire, api} from 'lwc';
import createStudentRating from "@salesforce/apex/VideoVerificationFormController.createStudentRating";
import getAccount from "@salesforce/apex/VideoVerificationFormController.getAccount";
import Toast from 'lightning/toast';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class ShowVedioVerificationForm extends LightningElement {
    @track dobVerification;
    @track enrollmentVerification;
    @track programDurationVerification;
    @track hasLoan = false; // Set this based on the student's data
    @track loanAgreementVerification;
    @track examFeesVerification;
    @track programValidityVerification;
    @track passingMarksVerification;
    @track examMalpracticeVerification;
    @track placementServicesVerification;
    @track engagementVerification;
    @track cancellationDateVerification;
    @track comments;
    @track specialCaseStudent;
    @track validityDate;
    userName;

    @api recordId;
    @api isNo;
    @api content;
    @api isFormFilled;
    @api taskId;
    @api ratingId;
   
    @track questions = [{question1:true,value:'dobVerification'}, {question2:'',value:'enrollmentVerification'},
        {question3:'',value:'programDurationVerification'}, {question4:'',value:'loanAgreementVerification'},
        {question5:'',value:'examFeesVerification'}, {question6:'',value:'programValidityVerification'},
        {question7:'',value:'passingMarksVerification'}, {question8:'',value:'examMalpracticeVerification'},
        {question9:'',value:'specialCaseStudent'},{question10:'',value:'placementServicesVerification'}, 
        {question11:'',value:'engagementVerification'},{question12:'',value:'cancellationDateVerification'}
    ];

    @track questionLabel = { question5: 'Please note the examination fee is Rs‘800’ per subject per attempt and Project fee is Rs‘1500’ applicable in the respective term (in case of MBA student). This is not part of tuition fees. Also note the first two assignment submissions are free however any submissions post that for the failed subject(s) will be Rs. 500/-.per submission per subject per examination',
                             question7: 'Are you aware that passing marks is 40 marks per subject and there is no grace marks',
                             question8: 'Currently our examination can be attempted online from any location or at one of our designated examination centres. However, if you are found indulging in any malpractices such as using phones, books, or not being visible on camera during the exam, the exam will be marked as unfair, and the subject will be marked as‘null and void’. Repeat instances of malpractices are subject to penalties as per the Unfair Means Policy.' +
                                        'Note- The University reserves the right to switch to center-based examinations completely at its discretion at any point of time.',
                             question9: 'Since you have applied under the Special needs category, please note if you opt for a scribe during examination, you would have to attempt the examination at our examination centre only. If you do not opt for scribe during the examination, you can opt for online examination from your location.',
                             question10: 'There are no placement services or referral bonus offered by the University. However, we offer career services which is a paid service offering access to NCDOE Job Portal, coaching services, Practice interviews and Profile development. *Fee will be charged separately for each module. ',
                             question11: 'As per UGC guidelines, you need to have 75% engagement throughout the program .i.e 90 hours per subject per semester. This can be achieved by attending live sessions, viewing recordings and E-Books, participating in discussion forums, quizzes, posting queries and assignment submissions. Note: Students will not be allowed to attempt the TEE if the engagement is less than 75% '
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
            this.validityDate = data.validityDate;
            if (this.objAccount.nm_ProgramType__c === 'Diploma Programs') {
                this.questionLabel.question5 = 'Please note the examination fee is Rs‘800’ per subject per attempt. This is not part of tuition fees. Also note the first two assignment submissions are free however any submissions post that for the failed subject(s) will be Rs. 500/-.per submission per subject per examination';
            }
            console.log('validityDate--->' + this.validityDate);
            console.log('acc--->' + JSON.stringify(this.objAccount));
            console.log('opp--->' + JSON.stringify(this.objOpp));
            this.mapOfCancelDate = data.mapOfConditionVsCancellationDate;
            const dateOfBirth = new Date(this.objAccount.nm_DateOfBirth__c);
            this.dob = ("0" + dateOfBirth.getDate()).slice(-2) + "-" + ("0"+(dateOfBirth.getMonth()+1)).slice(-2) + "-" + dateOfBirth.getFullYear();
            if (this.objOpp != null && this.objOpp.Loan_Type__c != null && this.objOpp.Loan_Type__c != '' && this.objOpp.Down_Payment_Made__c) {
                this.hasLoan = true;
                console.log('hasLoan--->' + this.hasLoan);
            }
            console.log('hasLoan--->' + this.hasLoan);
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

    dobOptions = [
        { label: 'Yes, it is correct', value: 'Yes, it is correct' },
        { label: 'No, it does not match (Re-verification needed)', value: 'No, it does not match (Re-verification needed)' },
    ];

    enrollmentOption = [
        { label: 'Yes, it is correct', value: 'Yes, it is correct' },
        { label: 'No, the student had the wrong information and does not agree', value: 'No, the student had the wrong information and does not agree' },
    ];

    notAgreeOptions = [
        { label: 'Yes, the student is aware', value: 'Yes, the student is aware' },
        { label: 'No, the student had the wrong information and does not agree', value: 'No, the student had the wrong information and does not agree' },
    ];

    programDurationOptions = [
        { label: 'Yes, continue, the student is aware', value: 'Yes, continue, the student is aware' },
        { label: 'No, the student is not aware and does not want to continue', value: 'No, the student is not aware and does not want to continue' },
    ];

    disAgreeOption = [
        { label: 'Yes, I agree', value: 'Yes, I agree' },
        { label: 'No, Disagree', value: 'No, Disagree' },
    ];

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
            this.examFeesVerification = event.target.value;
            this.questions[5].question6 = this.examFeesVerification === 'Yes, the student is aware' ? true : false;
            this.questions[5].question6 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question7') {
            this.programValidityVerification = event.target.value;
            this.questions[6].question7 = this.programValidityVerification === 'Yes, the student is aware' ? true : false;
            this.questions[6].question7 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question8') {
            this.passingMarksVerification = event.target.value;
            if (this.passingMarksVerification !== 'Yes, the student is aware') {
                this.hideQuestion();
            }
            else if (this.passingMarksVerification === 'Yes, the student is aware' && (this.objAccount.Differently_abled__c === undefined || this.objAccount.Differently_abled__c === 'No')) {
                this.questions[7].question8 = true;
            }
            else if (this.passingMarksVerification === 'Yes, the student is aware' && (this.objAccount.Differently_abled__c === 'Yes')) {
                this.questions[8].question9 = true;
            }
        }
        else if (this.dataValue === 'Question10') {
            if (this.questions[7].question8) {
                this.examMalpracticeVerification = event.target.value;
                this.questions[9].question10 = this.examMalpracticeVerification === 'Yes, I agree' ? true : false;
                this.questions[9].question10 === false ? this.hideQuestion() : true;
                this.questions[8].question9 = false;
            }
            else if (this.questions[8].question9) {
                this.specialCaseStudent = event.target.value;
                this.questions[9].question10 = this.specialCaseStudent === 'Yes, the student is aware' ? true : false;
                this.questions[9].question10 === false ? this.hideQuestion() : true;
                this.questions[7].question8 = false;
            }
        }
        else if (this.dataValue === 'Question11') {
            this.placementServicesVerification = event.target.value;
            this.questions[10].question11 = this.placementServicesVerification === 'Yes, continue, the student is aware' ? true : false;
            this.questions[10].question11 === false ? this.hideQuestion() : true;
        }
        else if (this.dataValue === 'Question12') {
            this.engagementVerification = event.target.value;
            this.questions[11].question12 = this.engagementVerification === 'Yes, the student is aware' ? true : false;
            this.questions[11].question12 === false ? this.hideQuestion() : true;
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

    get dobLabel() {
        if (this.objAccount && this.dob) {
            return `Please could you confirm your Date of Birth? (${this.dob})`;
        }
        return '';
    }

    get enrollmentLabel() {
        if (this.objAccount && this.objAccount.nm_Program__r.nm_ProgramName__c && this.objOpp.nm_Session__c && this.objOpp.nm_Year__c) {
            return this.objAccount.nm_Program__r.Specialisation__c == 'MBA' ? `You have enrolled for the '${this.objOpp.nm_Session__c} ${this.objOpp.nm_Year__c}' batch and the program name is '${this.objAccount.nm_Program__r.nm_ProgramName__c}'. Students are allowed to change their specialisation in Sem 2 and Sem 3 after paying change of specialisation fees.` : `You have enrolled for '${this.objAccount.nm_Program__r.nm_ProgramName__c}' and you are enrolled for the '${this.objOpp.nm_Session__c} ${this.objOpp.nm_Year__c}' batch.`;
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

    get validityLabel() {
        if (this.validityDate) {
            return `Please note the program validity is until '${this.validityDate}'. You have to complete your program by validity date.`;
        }
        return '';
    }

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
            if (this.objAccount.nm_ProgramType__c === 'Certificate Programs') {
                return `Please note that if admission is cancelled by ${formatDate(this.mapOfCancelDate['Amount']?.To_Date__c)} processing fee of Rs. ${this.mapOfCancelDate['Amount']?.Amount__c}/- plus GST will be deducted. Post that deduction of ${this.mapOfCancelDate['PostDeduction10']?.Percentage__c}% plus GST is applicable till ${formatDate(this.mapOfCancelDate['PostDeduction10']?.To_Date__c)}, ${this.mapOfCancelDate['PostDeduction20']?.Percentage__c}% plus GST till ${formatDate(this.mapOfCancelDate['PostDeduction20']?.To_Date__c)}, ${this.mapOfCancelDate['PostDeduction50']?.Percentage__c}% plus GST till ${formatDate(this.mapOfCancelDate['PostDeduction50']?.To_Date__c)} and 100% will be deducted after ${formatDate(this.mapOfCancelDate['Admisssion']?.To_Date__c)}. Please note Registration fee of 1200/- is non-refundable.`;
            }
            return `Please note that if admission is cancelled by ${formatDate(this.mapOfCancelDate['Amount']?.To_Date__c)} processing fee of Rs. ${this.mapOfCancelDate['Amount']?.Amount__c}/- will be deducted. Post that deduction of ${this.mapOfCancelDate['PostDeduction10']?.Percentage__c}% of semester fee is applicable till ${formatDate(this.mapOfCancelDate['PostDeduction10']?.To_Date__c)}, ${this.mapOfCancelDate['PostDeduction20']?.Percentage__c}% of semester fee till ${formatDate(this.mapOfCancelDate['PostDeduction20']?.To_Date__c)}, ${this.mapOfCancelDate['PostDeduction50']?.Percentage__c}% of semester fee till ${formatDate(this.mapOfCancelDate['PostDeduction50']?.To_Date__c)} and 100% of semester fee will be deducted till ${formatDate(this.mapOfCancelDate['Admisssion']?.To_Date__c)}. Please note Registration fee of 1200/- is non-refundable.`;
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
              (this.questions[4].question5 === true && !this.isNotBlank(this.examFeesVerification)) ||
              (this.questions[5].question6 === true && !this.isNotBlank(this.programValidityVerification)) ||
              (this.questions[6].question7 === true && !this.isNotBlank(this.passingMarksVerification)) ||
              (this.questions[7].question8 === true && !this.isNotBlank(this.examMalpracticeVerification)) ||
              (this.questions[8].question9 === true && !this.isNotBlank(this.specialCaseStudent)) ||
              (this.questions[9].question10 === true && !this.isNotBlank(this.placementServicesVerification)) ||
              (this.questions[10].question11 === true && !this.isNotBlank(this.engagementVerification)) ||
              (this.questions[11].question12 === true && !this.isNotBlank(this.cancellationDateVerification)) 
            ) {
            this.handleShowToast('Error','Please fill all required field','error');
            this.isFormFilled = false;
            return;
        }

        this.isFormFilled = true;
        console.log('after--->' + this.isFormFilled);
        
        let map1 = {};
        map1['Does the student photo in our database match the person on the video call?'] = 'Yes, the photo matches – Proceed with questionnaire';
        map1[this.dobLabel] = this.dobVerification;
        map1[this.enrollmentLabel] = this.enrollmentVerification;
        map1[this.durationLabel] = this.programDurationVerification;
        map1[this.loanLabel] = this.loanAgreementVerification;
        map1[this.questionLabel.question5] = this.examFeesVerification;
        map1[this.validityLabel] = this.programValidityVerification;
        map1[this.questionLabel.question7] = this.passingMarksVerification;
        map1[this.questionLabel.question8] = this.examMalpracticeVerification;
        map1[this.questionLabel.question9] = this.specialCaseStudent;
        map1[this.questionLabel.question10] = this.placementServicesVerification;
        map1[this.questionLabel.question11] = this.engagementVerification;
        map1[this.lastDateLabel] = this.cancellationDateVerification;
        map1['comments'] = this.comments;



        let verify = false;
        if (this.dobVerification !== 'No, it does not match (Re-verification needed)' && this.isNotBlank(this.dobVerification) &&
            this.enrollmentVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.enrollmentVerification) &&
            this.programDurationVerification !== 'No, the student is not aware and does not want to continue' && this.isNotBlank(this.programDurationVerification) &&
            this.examFeesVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.examFeesVerification) &&
            this.programValidityVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.programValidityVerification) &&
            this.passingMarksVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.passingMarksVerification) &&
            this.examMalpracticeVerification !== 'No, Disagree' &&
            this.placementServicesVerification !== 'No, the student had the wrong information and does not want to continue with the program' && this.isNotBlank(this.placementServicesVerification) &&
            this.engagementVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.engagementVerification) &&
            this.cancellationDateVerification !== 'No, the student had the wrong information and does not agree' && this.isNotBlank(this.cancellationDateVerification) &&
            this.loanAgreementVerification !== 'No, Disagree' &&
            this.specialCaseStudent !== 'No, the student had the wrong information and does not agree')
        {
            verify = true;
        }

        createStudentRating({verify : verify,recordId : this.recordId,vvcId : this.taskId,mapOfQuestionAndAns : map1,userName : this.userName}).then(result => {
            console.log('created--->' + result.msg);
            this.handleShowToast('Success',result.msg,'success');
            //this.ratingId = 'a1dIk000000Dr7k';
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
            console.log('no--->' + this.content);
        }
        if (this.enrollmentVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.enrollmentLabel + '</li>';
            this.isNo = true;
        }
        if (this.programDurationVerification === 'No, the student is not aware and does not want to continue') {
            this.content = this.content + '<li>' + this.durationLabel + '</li>';
            this.isNo = true;
        }
        if (this.examFeesVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>'+ this.questionLabel.question5 + '</li>';
            this.isNo = true;
        }
        if (this.programValidityVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.validityLabel + '</li>';
            this.isNo = true;
        }
        if (this.passingMarksVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question7 + '</li>';
            this.isNo = true;
        }
        if (this.specialCaseStudent === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question9 + '</li>';
            this.isNo = true;
        }
        if (this.examMalpracticeVerification === 'No, Disagree') {
            this.content = this.content + '<li>' + this.questionLabel.question8 + '</li>';
            this.isNo = true;
        }
        if (this.placementServicesVerification === 'No, the student had the wrong information and does not want to continue with the program') {
            this.content = this.content + '<li>' + this.questionLabel.question10 + '</li>';
            this.isNo = true;
        }
        if (this.engagementVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.questionLabel.question11 + '</li>';
            this.isNo = true;
        }
        if (this.cancellationDateVerification === 'No, the student had the wrong information and does not agree') {
            this.content = this.content + '<li>' + this.lastDateLabel + '</li>';
            this.isNo = true;
        }
        if (this.loanAgreementVerification === 'No, Disagree') {
            this.content = this.content + '<li>' + this.loanLabel + '</li>';
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