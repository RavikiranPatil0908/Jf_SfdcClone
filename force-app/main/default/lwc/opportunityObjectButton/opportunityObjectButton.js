import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import siteUrl from '@salesforce/label/c.Site_Url'; 
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import Profile_Name from '@salesforce/schema/User.Profile.Name';
import stageName from '@salesforce/schema/Opportunity.StageName';
import accId from '@salesforce/schema/Opportunity.AccountId';
import sem from '@salesforce/schema/Opportunity.nm_Semester__c';
import program from '@salesforce/schema/Opportunity.nm_Program__c';
import reRegPayment from '@salesforce/schema/Opportunity.Is_Re_Registration_Payment__c';
import studentNo from '@salesforce/schema/Opportunity.Student_Number__c';
import getObjectApiNameUsingRecordId from '@salesforce/apex/lightningButtonController.getObjectApiNameUsingRecordId';
import getToken from '@salesforce/apex/AutoUpdateStateAndCountryWebService.getToken';

let fields = [stageName, accId, sem, program, reRegPayment, studentNo];
export default class OpportunityObjectButton extends LightningElement {
    @track showPopup = { title: '', message: '', variant: '' };
    @api recordId;
    @track oppRender;
    @track objectApiName;

    @wire(getRecord, { recordId: '$recordId', fields })
    opp;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [Profile_Name]
    }) wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userProfileName = data.fields.Profile.value.fields.Name.value;
        }
    }

   // renderedCallback(){
        // console.log('recordId ---'+this.recordId);
     //   console.log('opp '+JSON.stringify(this.opp));
    //}

    get oppStageName() {
        return getFieldValue(this.opp.data, stageName);
    }
    get accIdValue() {
        return getFieldValue(this.opp.data, accId);
    }
    get semester() {
        return getFieldValue(this.opp.data, sem);
    }
    get oppProgram() {
        return getFieldValue(this.opp.data, program);
    }
    get isreRegPayment() {
        return getFieldValue(this.opp.data, reRegPayment);
    }
    get studentNumber() {
        return getFieldValue(this.opp.data, studentNo);
    }

    handleChange(event) {
        let value = event.currentTarget.dataset.value;
        console.log('handleChange ' + value);
        if (value === 'PrintReRegForm') {
            this.PrintReRegistrationForm();
        }else if(value === 'admPayment'){
            this.makeAdmissionPayment();
        }else if(value === 'studentDetails'){
            this.studentDetails();
        }
    }

    @wire(getObjectApiNameUsingRecordId, {
        recordId: '$recordId'
    }) getObjectName({ error, data }) {
        if (error) {
            console.log('error in getobjectName ' + error);
        } else if (data) {
            this.objectApiName = data;
            console.log('objectApiName ' + this.objectApiName);
            if (this.objectApiName === 'Opportunity') {
                this.oppRender = true;
            }
        }
    }

    PrintReRegistrationForm(){
        if (this.oppStageName != 'Registration Done') {
            var answer = window.confirm("Are you sure want to Print Re-Registration form "+this.accIdValue);
            if (answer == true) {
                window.open(siteUrl + "PrintReRegistrationForm?target=pdf&id=" + this.accIdValue+"&sem="+this.semester);
            }
        }
        else {
            // alert('You cant print Re-Registration form at this Stage.');
            this.showHtmlMessage('You cant print Re-Registration form at this Stage.', 'error', 'error');
        }
    }

    makeAdmissionPayment(){
        var random = Math.random();

        if (this.isreRegPayment) {
            // alert('You can not use this button for Re-registration payment.Please use button "Make Re-registration Payment"on Account page for Re-registration');
            this.showHtmlMessage('You can not use this button for Re-registration payment.Please use button "Make Re-registration Payment"on Account page for Re-registration', 'Warning','warning');
        }else if (this.oppStageName === 'Closed lost') {
            // alert("As Student is Closed Lost\n Can't Make Admission Payment At this Starge");
            this.showHtmlMessage("As Student is Closed Lost n Can't Make Admission Payment At this Starge", 'Warning', 'warning');
        } else if (this.oppStageName === 'Pending Payment' && this.oppProgram !== 'DGM') {
            window.open("http://ngasce.force.com/nmPaymentNew?id={!Account.nm_LeadId__c}&oppId={!Opportunity.Id}&IC=true&sem=1&random=" + random, "_blank");
        } else if (this.oppStageName === 'Registration Done' && this.oppProgram !== 'DGM') {
            window.open("http://ngasce.force.com/nmPaymentNew?id={!Account.nm_LeadId__c}&oppId={!Opportunity.Id}&IC=true&sem=1&random=" + random, "_blank");
        }else if (this.semester > 1) {
            //alert('You can not use this button for Re-registration payment.Please use button "Make Re-registration Payment"on Account page for Re-registration');
            this.showHtmlMessage('You can not use this button for Re-registration payment.Please use button "Make Re - registration Payment"on Account page for Re-registration', 'Warning', 'warning');
        }else if (this.oppProgram === 'DGM') {
            // alert('DGM is now inactive.Kindly inform HO to change the program.')
            this.showHtmlMessage('DGM is now inactive.Kindly inform HO to change the program.', 'Warning', 'warning');
        }else{
            // alert('Not need as of now...');
            this.showHtmlMessage('Not need as of now...', 'Warning', 'warning');
        }
    }

    studentDetails(){
        if(this.studentNumber){
            getToken({ sapId: this.studentNumber})
                .then(result => {
                    let urlEncodedToken = result;
                    console.log('urlEncodedToken ' + JSON.stringify(urlEncodedToken));
                    window.open("http://studentzone-ngasce.nmims.edu/studentportal/viewStudentDetailsDashBoard?sapId="+this.studentNumber+"&token=" + urlEncodedToken);
                })
                .catch(error => {
                    alert("Error while calling student portals..."+this.error);
                });
        }else{
            alert('You can not see Details for this Case.');
        }
    }

    // To show Toast message
    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}