import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord ,updateRecord,generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import leadStatus from '@salesforce/schema/Lead.Status';
import program  from '@salesforce/schema/Lead.nm_Program__r.Name';
import eligiblityCriteria  from '@salesforce/schema/Lead.nm_EligiblityCriteria__r.Name';
import informationCenterId from '@salesforce/schema/Lead.nm_InformationCenter__c';
import Description  from '@salesforce/schema/Lead.Description';
import OldDescription  from '@salesforce/schema/Lead.Old_Description__c';
import registrationNo  from '@salesforce/schema/Lead.nm_RegistrationNo__c';
import dob  from '@salesforce/schema/Lead.nm_DateOfBirth__c';
import emailVerified from '@salesforce/schema/Lead.nm_IsEmailVerified__c';
import mobileVerified from '@salesforce/schema/Lead.Is_Mobile_Verified__c';
import leadProgramName from '@salesforce/schema/Lead.nm_ProgramName__c';
import emailId from '@salesforce/schema/Lead.Email';
import name from '@salesforce/schema/Lead.Name';
import mobileNumber from '@salesforce/schema/Lead.MobilePhone';
import Salutation from '@salesforce/schema/Lead.Salutation';
import firstName from '@salesforce/schema/Lead.FirstName';
import lastName from '@salesforce/schema/Lead.LastName';
import icname from '@salesforce/schema/Lead.IC_Name__c';
import siteUrl from '@salesforce/label/c.Site_Url'; 
import DOCUMENT_SERVER from  '@salesforce/label/c.DOCUMENT_SERVER';
import sendVerificationEmailToStudent from '@salesforce/apex/nmSendNotification.sendVerificationEmailToStudent'; 
import sendVerificationSMSToStudent from '@salesforce/apex/nmSendNotification.sendVerificationSMSToStudent';
import ValidateLead from '@salesforce/apex/nmValidateLeadWebService.ValidateLead'; 
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import Profile_Name from '@salesforce/schema/User.Profile.Name'; 
import lightningSiteUrl from "@salesforce/label/c.lightningSiteUrl"; 
import getObjectApiNameUsingRecordId from '@salesforce/apex/lightningButtonController.getObjectApiNameUsingRecordId';
let fields  = [ leadStatus ,program ,eligiblityCriteria,informationCenterId,Description,OldDescription,registrationNo,dob,emailVerified,mobileVerified,leadProgramName,emailId,name,
                mobileNumber,Salutation,firstName,lastName,icname];

export default class LeadObjectButton extends NavigationMixin(LightningElement) {
    @track showPopup = { title: '', message: '', variant: '' };
    @track accId;
    @track error;
    @api recordId;
    @track objectApiName;
    @track userProfileName;
    @track quickLeadFlag = false;
    @track quickLeadCreateFlag = false;
    // @track Lead;
    @track leadRender;
    @wire (getRecord, { recordId: '$recordId', fields })
    Lead;
    
    // to check logs for lead data 
    // wiredRecord({ error, data }) {
    //     if (error) {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error loading lead',
    //                 message: error.message,
    //                 variant: 'error',
    //             }),
    //         );
    //         console.log('error '+JSON.stringify(error));
    //     } else if (data) {
    //         this.Lead = data;
    //         console.log('Lead Data in wired' + JSON.stringify(this.Lead))
    //     }
    // }


    @wire(getRecord, {
        recordId: USER_ID,
        fields: [Profile_Name]
    }) wireuser({error,data}) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.userProfileName = data.fields.Profile.value.fields.Name.value;
        }
    }

    @wire(getObjectApiNameUsingRecordId , {
            recordId: '$recordId'
    }) getObjectName({error,data}){
        if(error){
            console.log('error in getobjectName '+error);
        }else if(data){
            this.objectApiName = data;
            console.log('objectApiName ' + this.objectApiName);
            if(this.objectApiName === 'Lead'){
                this.leadRender = true;
            }
        }
    }

    renderedCallback(){
        console.log('this.recordId ' + this.recordId );
     //   console.log('this.objectApiName '+this.objectApiName);
    }
    get status() {
        return getFieldValue(this.Lead.data, leadStatus);
    }

    get leadProgram() {
        return getFieldValue(this.Lead.data, program);
    }

    get elCriteria(){
        return getFieldValue(this.Lead.data, eligiblityCriteria);
    }

    get leadDescr(){
        return getFieldValue(this.Lead.data, Description);
    }

    get oldDescr(){
        return getFieldValue(this.Lead.data, OldDescription);
    }

    get icId(){
        return getFieldValue(this.Lead.data, informationCenterId);
    }

    get regNo(){
        return getFieldValue(this.Lead.data, registrationNo);
    }

    get Dateofbirth(){
        return getFieldValue(this.Lead.data, dob);
    }

    get isEmailVerify(){
        return getFieldValue(this.Lead.data, emailVerified);
    }

    get isMobileVerify(){
        return getFieldValue(this.Lead.data, mobileVerified);
    }

    get studentEmail(){
        return getFieldValue(this.Lead.data, emailId);
    }

    get studentMobile(){
        return getFieldValue(this.Lead.data, mobileNumber);
    }

    get ldProgramName(){
        return getFieldValue(this.Lead.data, leadProgramName);
    }
    
    get studentName(){
        return getFieldValue(this.Lead.data, name);
    }
    
    get studSalutation(){
        return getFieldValue(this.Lead.data, Salutation);
    }

    get studFirstName(){
        return getFieldValue(this.Lead.data, firstName);
    }

    get studLastName(){
        return getFieldValue(this.Lead.data, lastName);
    }
    
    get studIcName(){
        return getFieldValue(this.Lead.data, icname);
    }

    // get options() {
    //     return [
    //         { label: 'Print Registration Form', value: 'PrintRegForm' },
    //         { label: 'Make Admission / Registration / Late fees payment', value: 'AdmissionOrRegOrLateFeePayment' },
    //         { label: 'Counsellor Profile', value: 'CPProfile' },
    //         { label: 'Transfer Description', value: 'TransferDescr' },
    //         { label: 'Upload Image', value: 'UploadImage' },
    //         { label: 'Complete Form Login', value: 'CompleteFormLogin' },
    //         { label: 'Send Verification Email / SMS', value: 'SendVerficationSMSOrEmail' },
    //         { label: 'AEP Request', value: 'AepRequest' },
    //         { label: 'Compelete Lead Details', value: 'CompleteleadDetails' },
    //         { label: 'Quick Lead Form', value: 'QuickLead' }
    //     ];
    // }

    handleChange(event) {
        // this.leadAction = event.detail.value;
        // if(this.leadAction === 'PrintRegForm'){
        //     this.PrintRegForm();
        // }else if(this.leadAction === 'AdmissionOrRegOrLateFeePayment'){
        //     this.makePayment();
        // }else if(this.leadAction === 'CPProfile'){
        //     this.callCpProfile();
        // }else if(this.leadAction === 'TransferDescr'){
        //     this.updateDescription();
        // }else if(this.leadAction === 'UploadImage'){
        //     this.uploadImage();
        // }else if(this.leadAction === 'CompleteFormLogin'){
        //     this.CompleteFormLogin();
        // }else if(this.leadAction === 'SendVerficationSMSOrEmail'){
        //     this.checkEmailMobileVerification();
        // }else if(this.leadAction === 'AepRequest'){
        //     this.AEPRequest();
        // }else if(this.leadAction === 'CompleteleadDetails'){
        //     this.completeLeadDetails();
        // }else if(this.leadAction === 'QuickLead'){
        //     this.QuickLeadForm();
        // }

        let value = event.currentTarget.dataset.value;
        if (value === "PrintRegForm") {
          this.PrintRegForm();
        } else if (value === "AdmissionOrRegOrLateFeePayment") {
          this.makePayment();
        } else if (value === "CPProfile") {
          this.callCpProfile();
        } else if (value === "TransferDescr") {
          this.updateDescription();
        } else if (value === "UploadImage") {
          this.uploadImage();
        } else if (value === "CompleteFormLogin") {
          this.CompleteFormLogin();
        } else if (value === "SendVerficationSMSOrEmail") {
          this.checkEmailMobileVerification();
        } else if (value === "AepRequest") {
          this.AEPRequest();
        } else if (value === "CompleteleadDetails") {
          this.completeLeadDetails();
        } 
        else if (value === "QuickLeadForm") {
        //   this.quickLeadCreateFlag = true;
         this.QuickLeadForm();
        } else if (value === "quickLead") {
          this.quickLeadFlag = true;
          console.log("quickLeadFlag" + this.quickLeadFlag);
        }else{
            this.quickLeadFlag = false;
            // this.quickLeadCreateFlag = false;
        }
    }

    PrintRegForm(){
        let redirectURL = siteUrl+"nm_PrintRegistrationForm?id="+this.recordId+"&IC=true";
        console.log('redirectURL '+redirectURL);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: redirectURL
            }
        },
        // true // Replaces the current page in your browser history with the URL
      );
    }

    makePayment(){
        if( this.leadProgram !== '' && this.leadProgram !== 'DGM' && this.elCriteria !== '' && (this.status === 'Registration Form Filled' || this.status ==='Registration Fee Paid' || this.status === 'Registration Fee Disapproved By Finance') ){
            var random = Math.random();
            ValidateLead({ strLeadId: this.recordId})
            .then(result => {
                this.accId = result;
                console.log(JSON.stringify(this.accId));
                if(this.accId === '' || this.accId === null){
                    window.open(siteUrl+"nmPaymentnew?id="+this.recordId+"&IC=true&random=" + random, "_blank");
                }else {
                    // alert(this.accId);
                    this.showHtmlMessage(this.accId,'success','success');
                }
            })
            .catch(error => {
                this.error = error;
                // alert(this.error);
                this.showHtmlMessage("An error occured.",error.message,'error');
            });
        }else if(this.leadProgram === '' && this.elCriteria === ''){
            // alert('Registration Could not be processed without Program and Eligibility Criteria');
            this.showHtmlMessage("Registration Could not be processed without Program and Eligibility Criteria",'Warning','warning');
        }else if (this.status !== 'Registration Form Filled') {
            // alert('Please fill the student detail via Complete form first and then make DD Payment');
            this.showHtmlMessage("Please fill the student detail via Complete form first and then make DD Payment", 'Warning', 'warning');
        } else if (this.leadProgram === 'DGM') {
            // alert('DGM program is inactive.Kindly change the program');
            this.showHtmlMessage("DGM program is inactive.Kindly change the program", 'Warning', 'warning');
        }else{
            // alert('something went wrong...');
            this.showHtmlMessage("something went wrong...",'Error','error');
        }
    }

    callCpProfile(){
        if(this.icId !== ''){
            var answer = confirm("Please only new applicant fill the form to update info goto Counselor profile tab");
            if(answer == true){
                window.open("/apex/nmCounselor_details?IC="+this.icId, "_blank");
            }
        }else{
            // alert ('Information center cannot be null');
            this.showHtmlMessage("Information center cannot be null",'Warning','warning');
        }
    }

    updateDescription(){
        let record = {
            fields: {
                Id: this.recordId,
                Old_Description__c : this.leadDescr,
                Description: '',
            },
        };
        updateRecord(record)
        .then(() => {
           location.reload();
        })
        .catch(error => {
            // alert("An Error has Occurred. Error: " +error.message);
            this.showHtmlMessage("An Error has Occurred", error.message, 'error');
        });

    }

    uploadImage(){
        console.log('uploadImage '+this.recordId);
        var leadid15digit = this.recordId;
        leadid15digit = leadid15digit.substring(0,15);

        if(this.userProfileName === 'Information Center Partner Community User'){
            window.open(DOCUMENT_SERVER+'uploadPhotoForm?leadId='+leadid15digit+'&uid='+this.recordId+'&type=lead', '_blank');
        } else {
            window.location.href = '/apex/nmProfileImage_lead?id='+this.recordId;
        }

    }   

    CompleteFormLogin(){
        console.log('this.regNo ' + this.regNo+ 'Date of birth '+this.Dateofbirth);
        if (this.regNo !== '' && this.regNo !== null && this.Dateofbirth !== '' && this.Dateofbirth !== null){
            //{!DAY(Lead.nm_DateOfBirth__c)}/{!MONTH(Lead.nm_DateOfBirth__c)}/{!YEAR(Lead.nm_DateOfBirth__c)}
            let dateofbirthFormat = this.format_date(this.Dateofbirth); 
            window.open( siteUrl+"nmlogin_new?registrationNo="+this.regNo+"&dob="+dateofbirthFormat+"&type=registration");
        }else{
            // alert('Please enter Date Of Birth');
            this.showHtmlMessage("Please enter Date Of Birth", 'Warning', 'warning');
        }
    }

    checkEmailMobileVerification(){
        console.log('email verify '+JSON.stringify(this.isEmailVerify)+' mobile verify '+JSON.stringify(this.isMobileVerify));
        if(!this.isEmailVerify){
            sendVerificationEmailToStudent({ emailId: this.studentEmail, studentName: this.studentName , typeOfRecord: 'Lead' , recordId : this.recordId})
            .then(result => {
                // alert("Email verification link has been sent");
                this.showHtmlMessage("Email verification link has been sent",'Success','success');
            })
            .catch(error => {
                this.error = error;
                // alert(this.error);
                this.showHtmlMessage("An error occured.", error.message, 'error');

            });
        }

        if(!this.isMobileVerify){
            sendVerificationSMSToStudent({ mobileNumber: this.studentMobile, ProgramName: this.ldProgramName , RegistrationNo: this.regNo , displayName : 'Registration No' , typeOfRecord: 'Lead', recordId:this.recordId})
            .then(result => {
                // alert("Mobile verification link has been sent");
                this.showHtmlMessage("Mobile verification link has been sent", 'Success', 'success');
            })
            .catch(error => {
                this.error = error;
                // alert(this.error);
                this.showHtmlMessage("An error occured.",error.message,'error');
            });
        }
        window.location.reload();
    }

    AEPRequest(){
        if(this.userProfileName === 'Information Center Partner Community User'){
            window.open("https://nga-sce.force.com/a0y/e?CF00N9000000EcWiH="+this.studSalutation+'+'+this.studFirstName+'+'+this.studLastName+"&CF00N9000000EcWiH_lkid="+this.recordId+"&CF00N9000000EcWiA="+this.studIcName, "_self");
        }else{
            window.open("https://ap1.salesforce.com/a0y/e?CF00N9000000EcWiH="+this.studSalutation+'+'+this.studFirstName+'+'+this.studLastName+"&CF00N9000000EcWiH_lkid="+this.recordId+"&CF00N9000000EcWiA="+this.studIcName, "_self");
        }
    }

    completeLeadDetails(){
        window.open("/apex/nmForm?id="+this.recordId, "_blank")
    }

    QuickLeadForm(){
        if(this.recordId !== ''){
            window.open(lightningSiteUrl+"s/quick-lead");
        }else{
            this.showHtmlMessage("Error!, Please contact System Administrator",'Error','error');
        }
    }

    handleCloseQuickLead(event){
        if(event.detail !== 1){
            if(event.detail === 'close'){
                this.quickLeadFlag = false;
            }
        }
    }

    // handleCloseQuickLeadCreate(event){
    //     if(event.detail !== 1){
    //         if(event.detail === 'close'){
    //             this.quickLeadCreateFlag = false;
    //         }
    //     }
    // }

    format_date(dateValue) { 
        var nDate = dateValue.slice(8, 10) + '/'  
                   + dateValue.slice(5, 7) + '/'  
                   + dateValue.slice(0, 4); 
        return nDate;
    }

    // To show Toast message
    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}