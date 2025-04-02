import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import siteUrl from '@salesforce/label/c.Site_Url'; 
import docServerUrl from '@salesforce/label/c.DOCUMENT_SERVER'; 
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import Profile_Name from '@salesforce/schema/User.Profile.Name'; 
import studentStatus from '@salesforce/schema/Account.nm_StudentStatus__c';
import regNo from '@salesforce/schema/Account.nm_RegistrationNumber__c';
import dob from '@salesforce/schema/Account.nm_DateOfBirth__c';
import studPhoto from '@salesforce/schema/Account.nm_StdtPhoto__c';
import studPhotoURL from '@salesforce/schema/Account.nm_StudentImageUrl__c';
import uniqueId from '@salesforce/schema/Account.Account_Unique_ID__c';
import studNo from '@salesforce/schema/Account.nm_StudentNo__c';
import salutation from '@salesforce/schema/Account.Salutation';
import firstName from '@salesforce/schema/Account.FirstName';
import lastName from '@salesforce/schema/Account.LastName';
import icName from '@salesforce/schema/Account.IC_Name_1__c';
import chooseProgram from '@salesforce/schema/Account.nm_ChooseaProgram__c';
import personalMobile from '@salesforce/schema/Account.PersonMobilePhone';
import personalEmailId from '@salesforce/schema/Account.PersonEmail';
import getObjectApiNameUsingRecordId from '@salesforce/apex/lightningButtonController.getObjectApiNameUsingRecordId';
import getPickListValuesForChooseProg from '@salesforce/apex/lightningButtonController.getPickListValuesForChooseProg';
import getEligiblityCriteria from '@salesforce/apex/lightningButtonController.getEligiblityCriteria';
import StudentInfo from '@salesforce/apex/WebServiceForDualprogram.StudentInfo';

let fields = [studentStatus, regNo, dob, studPhoto, studPhotoURL, uniqueId, studNo,
    salutation, firstName, lastName, icName, chooseProgram, personalMobile, personalEmailId];

export default class AccountObjectButton extends NavigationMixin(LightningElement) {
    @track showPopup = { title: '', message: '', variant: '' };
    @api recordId;
    @api account;
    @track accountRender;
    @track error;
    @track objectApiName;
    @track userProfileName;
    @track bShowModal = false;
    @track isEmpty = true;
    @track selectedChooseProgram;
    @track selectedProgramValue;
    @track selectedEligiblityCritera;
    @track programListOptions = [{ label: 'Choose Program', value: '' }];
    @track eliCriteriaOptions = [{ label: 'Choose Eligiblity criteria', value: '' }];
    @track mapOfValues = [];
    @track mapOfeligibleValues = [];
    @wire(getRecord, { recordId: '$recordId', fields })
    account;
    //to check logs for account data 
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
    //         this.account = data;
    //         console.log('Account Data in wired' + JSON.stringify(this.account))
    //     }
    // }

    // renderedCallback() {
    //     // console.log('this.recordId ' + this.recordId);
    //     //   console.log('this.objectApiName '+this.objectApiName);
    //  //   console.log('account --->'+JSON.stringify(this.account));
    // }

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


    get studStatus() {
        return getFieldValue(this.account.data, studentStatus);
    }
    get studRegNo() {
        return getFieldValue(this.account.data, regNo);
    }
    get studdob() {
        return getFieldValue(this.account.data, dob);
    }
    get studentPhoto() {
        return getFieldValue(this.account.data, studPhoto);
    }
    get studentImageURL() {
        return getFieldValue(this.account.data, studPhotoURL);
    }
    get studentUniqueId() {
        return getFieldValue(this.account.data, uniqueId);
    }
    get studentNumber() {
        return getFieldValue(this.account.data, studNo);
    }

    get studentSalutation() {
        return getFieldValue(this.account.data, salutation);
    }
    get studentFirstName() {
        return getFieldValue(this.account.data, firstName);
    }
    get studentLastName() {
        return getFieldValue(this.account.data, lastName);
    }
    get aepName() {
        return getFieldValue(this.account.data, icName);
    }
    get chooseProgramValue(){
        return getFieldValue(this.account.data, chooseProgram);
    }
    get studMobile() {
        return getFieldValue(this.account.data, personalMobile);
    }
    get studEmailId() {
        return getFieldValue(this.account.data, personalEmailId);
    }
    get chooseProgram() {
        return [
            { label: 'Certificate Programs', value: 'Certificate Programs' },
            { label: 'Diploma Programs', value: 'Diploma Programs' },
            { label: 'Executive Programs', value: 'Executive Programs' },
            { label: 'Post Graduate Diploma Programs', value: 'Post Graduate Diploma Programs' }
          //  { label: 'Master Programs', value: 'Master Programs' }
        ];
    }

    @wire(getObjectApiNameUsingRecordId, {
        recordId: '$recordId'
    }) getObjectName({ error, data }) {
        if (error) {
            console.log('error in getobjectName ' + error);
        } else if (data) {
            this.objectApiName = data;
            console.log('objectApiName ' + this.objectApiName);
            if (this.objectApiName === 'Account') {
                this.accountRender = true;
            }
        }
    }
    handleChange(event){
        let value = event.currentTarget.dataset.value;
        console.log('handleChange '+value);
        if (value === 'PrintAdmForm') {
            this.PrintAdmForm();
        }else if( value === 'RegistrationLogin'){
            this.regLogin();
        }else if( value === 'PrintRegistrationForm'){
            this.PrintRegForm();
        } else if (value === 'uploadProfileImg'){
            this.uploadProfileImage();
        }else if( value === 'makeReRegPayment'){
            this.makeReRegistrationPayment();
        } else if (value === 'aepReq'){
            this.aepRequest();
        }else if( value === 'createSecondLead'){
            this.createSecondLead();
        } else if (value === 'logaCallCS'){
            this.LogACallForCS();
        } else if (value === 'chooseProgram'){
            this.selectedChooseProgram = event.target.value;
            console.log(this.selectedChooseProgram);
            if (this.selectedChooseProgram && this.selectedChooseProgram !== '--None--' ){
                this.isEmpty = false;
                this.getProgramList();
                this.getEligiblityCriteraList();
            }else{
                this.isEmpty = true;
            }
        } else if (value === 'progType'){
            this.selectedProgramValue = event.target.value;
            console.log(this.selectedProgramValue);
        } else if (value === 'eligibleCriteria'){
            this.selectedEligiblityCritera = event.target.value;
            console.log(this.selectedEligiblityCritera);
        }
    }

    PrintAdmForm(){
        console.log('this.studStatus ' + this.studStatus);
        if (this.studStatus === 'Confirmed') {
            var answer = window.confirm("Do you want to Print Admission Form..?");
            if (answer === true) {
                window.open(siteUrl+"nmPrintAdmissionForm?id=" + this.recordId);
            }
        } else {
            // alert('You cant Print the Admission Form at this Stage.');
            this.showHtmlMessage("You can't Print the Admission Form at this Stage.",'Warning','warning');
        }
    }

    regLogin(){
        console.log('this.studRegNo ' + this.studRegNo + ' Date of birth ' + this.studdob);
        if (this.studRegNo !== '' && this.studRegNo !== null && this.studdob !== '' && this.studdob !== null) {
            //{!DAY(Lead.nm_DateOfBirth__c)}/{!MONTH(Lead.nm_DateOfBirth__c)}/{!YEAR(Lead.nm_DateOfBirth__c)}
            let dateofbirthFormat = this.format_date(this.studdob);
            window.open(siteUrl + "nmlogin_new?registrationNo=" + this.studRegNo + "&dob=" + dateofbirthFormat + "&type=registration&ic=true");
        } else {
            // alert('Please enter Date Of Birth');
            this.showHtmlMessage("Please enter Date Of Birth", 'Warning', 'warning');
        }
    }

    PrintRegForm(){
        console.log('this.studStatus ' + this.studStatus);
        if (this.studStatus !== 'Confirmed') {
            var answer = window.confirm("Do you want to Print Registration Form..?");
            if (answer === true) {
                window.open(siteUrl + "nmPrintAdmissionForm?id=" + this.recordId);
            }
        } else {
            // alert('Kindly Print Admission Form.');
            this.showHtmlMessage("Kindly Print Admission Form.", 'Warning', 'warning');
        }
    }

    uploadProfileImage(){

        if (this.studStatus === 'Confirmed' && this.userProfileName !== 'System Administrator') {
            // alert('You can not upload image after Student gets confirmed. Please contact HO to upload');
            this.showHtmlMessage("You can not upload image after Student gets confirmed. Please contact HO to upload", 'Warning', 'warning');
        }
        else if (this.studentImageURL !== null && this.studentImageURL !== "" && this.userProfileName !== 'System Administrator') {
            // alert('Please upload the image from Upload Documents Button');
            this.showHtmlMessage("Please upload the image from Upload Documents Button", 'Warning', 'warning');
        }
        else if (this.studStatus === 'Admission form & documents Approved' || status == 'Admission Form & Documents Provisional') {
            // alert('You can not upload image after Documents are Approved ');
            this.showHtmlMessage("You can not upload image after Documents are Approved ", 'Warning', 'warning');
        }
        else if (this.studentPhoto === true) {
            // alert('You can upload document of approved Student Photograph');
            this.showHtmlMessage("You can upload document of approved Student Photograph", 'Warning', 'warning');
        }else {
            var answer = window.confirm("Do you want to upload Image.?");
            if (answer === true) {
                if (this.userProfileName === 'Information Center Partner Community User') {
                    window.open(docServerUrl+'uploadPhotoForm?accountId='+this.recordId+'&uid='+this.studentUniqueId, '_blank');
                } else {
                    window.open('/apex/nmProfileImage?id='+this.recordId);
                }

            }
        }
    }

    makeReRegistrationPayment(){
        console.log('this.studStatus ' + this.studStatus);
        if (this.studStatus === 'Confirmed') {
            var answer = window.confirm("Are you sure want to Re-Register for student ?");
            if (answer === true) { 
                let dateofbirthFormat = this.format_date(this.studdob);
                window.open(siteUrl + "nmLogin_new?studentNo=" + this.studentNumber + '&dob=' + dateofbirthFormat + '&IC=true&type=reregistration','_blank');
            }
        } else {
            alert('You cant Re-Register at this Stage.');
            this.showHtmlMessage("You can't Re-Register at this Stage.", 'Error', 'error');
        }
    }

    aepRequest(){
        console.log('profile '+this.userProfileName);
        if (this.userProfileName === 'Information Center Partner Community User') {
            window.open("https://nga-sce.force.com/a0y/e?CF00N9000000EcWiJ="+this.studentSalutation+"+"+this.studentFirstName+"+"+this.studentLastName+"&CF00N9000000EcWiJ_lkid="+this.recordId+"&CF00N9000000EcWiA="+this.aepName, "_self");
        }
        else {
            window.open("https://ap1.salesforce.com/a0y/e?CF00N9000000EcWiJ="+this.studentSalutation+"+"+this.studentFirstName+"+"+this.studentLastName+"&CF00N9000000EcWiJ_lkid="+this.recordId+"&CF00N9000000EcWiA="+this.aepName, "_self");
        }
    }

    createSecondLead(){
        // alert('Work in progress , please try after some time');
        this.bShowModal = true;
    }

    LogACallForCS(){
        window.open("https://ap8.salesforce.com/00T/e?title=Call for Career Service&who_id="+this.recordId+"&what_id="+this.recordId+"&followup=1&tsk5=Call for Career Service&retURL="+this.recordId,"_self");
    }

    // get the programs dropdown from Controller depends upon choosed program or specialsation
    getProgramList() {
        this.programListOptions = [];
        this.mapOfValues = [];
        getPickListValuesForChooseProg({
            choosedProgValue: this.selectedChooseProgram
        })
            .then((result) => {
                for (let key in result) {
                    // Preventing unexcepted data
                    if (result.hasOwnProperty(key)) {
                        // Filtering the data in the loop
                        this.mapOfValues.push({ value: result[key], label: key });
                    }
                }
                for (const list of this.mapOfValues) {
                    const option = {
                        value: list.label,
                        label: list.value
                    };
                    // console.log('Option values '+JSON.stringify(option));

                    this.programListOptions = [...this.programListOptions, option];
                }
            })
            .catch((error) => {
                alert("Error !"+ error.body.message);
                console.log('error', JSON.stringify(error.body.message));
            });
    }

    getEligiblityCriteraList() {
        this.eliCriteriaOptions = [];
        this.mapOfeligibleValues = [];
        getEligiblityCriteria({ choosedProgValue: this.selectedChooseProgram})
            .then((result) => {
                // console.log('result ' + JSON.stringify(result));
                for (let key in result) {
                    // Preventing unexcepted data
                    if (result.hasOwnProperty(key)) {
                        // Filtering the data in the loop
                        this.mapOfeligibleValues.push({ value: result[key], label: key });
                    }
                }
                for (const list of this.mapOfeligibleValues) {
                    const option = {
                        value: list.label,
                        label: list.value
                    };
                    this.eliCriteriaOptions = [...this.eliCriteriaOptions, option];
                }
            })
            .catch((error) => {
                alert("Error !"+ error.body.message);
                console.log('error', JSON.stringify(error.body.message));
            });
    }

    createLead(){
        let objPicklist = {};
        objPicklist.programtype = this.selectedChooseProgram;
        objPicklist.programSpecialisation = this.selectedProgramValue;
        objPicklist.eligibilityCriteria = this.selectedEligiblityCritera;
        console.log(objPicklist);
        var flag = this.combinationChooseProgramAllowed(this.chooseProgramValue, objPicklist.programtype);
        console.log('flag ' + flag);
        if (flag === 'true' && !this.isNotBlank(objPicklist.programSpecialisation)) {
            flag = 'false';
        }

        alert('flag-->' + flag);

        if (flag === 'true' && this.studStatus === 'Confirmed') {
            StudentInfo({ accountId: this.recordId, Mobilephone: this.studMobile, email: this.studEmailId, chooseprogram: objPicklist.programtype, eligibility: objPicklist.eligibilityCriteria, program: objPicklist.programSpecialisation })
                .then(result => {
                    alert("result --->" + JSON.stringify(result));
                    window.location.reload();
                })
                .catch(error => {
                    alert("error --->"+JSON.stringify(error.body.message));
                });
        } else {
            alert('Currently you are not allowed to create Lead');
        }
        this.selectedChooseProgram = '';
        this.selectedProgramValue = '';
        this.selectedEligiblityCritera = '';
    }

    combinationChooseProgramAllowed(existingLeadprg, incomingLeadprg) {
        var msg;
        console.log("existingLeadprg " + existingLeadprg + " incomingLeadprg " + incomingLeadprg);
        if (existingLeadprg === 'Certificate Programs' && (incomingLeadprg === 'Post Graduate Diploma Programs' || incomingLeadprg === 'Diploma Programs' || incomingLeadprg === 'Executive Programs')) {
            msg = 'true';
        } else if (existingLeadprg === 'Executive Programs' && (incomingLeadprg === 'Post Graduate Diploma Programs' || incomingLeadprg === 'Diploma Programs' || incomingLeadprg === 'Certificate Programs')) {
            msg = 'true';
        } else if (existingLeadprg === 'Post Graduate Diploma Programs' && (incomingLeadprg === 'Executive Programs' || incomingLeadprg === 'Certificate Programs')) {
            msg = 'true';
        } else if (existingLeadprg === 'Diploma Programs' && (incomingLeadprg === 'Executive Programs' || incomingLeadprg === 'Certificate Programs')) {
            msg = 'true';
        } else if (existingLeadprg === 'Certificate Programs' && (incomingLeadprg === 'Executive Programs' || incomingLeadprg === 'Certificate Programs')) {
            if (existingLeadprg === 'Certificate Programs' && incomingLeadprg === 'Certificate Programs') {
                msg = 'true';
            }
            msg = 'true';
        }
        else {
            msg = 'false';
        }
        return msg;
    }

    closeModal() {
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }

    format_date(dateValue) {
        var nDate = dateValue.slice(8, 10) + '/'
            + dateValue.slice(5, 7) + '/'
            + dateValue.slice(0, 4);
        return nDate;
    }

    isNotBlank(str) {
        if (str != "" || str.length > 0) {
            return true;
        } else {
            return false;
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