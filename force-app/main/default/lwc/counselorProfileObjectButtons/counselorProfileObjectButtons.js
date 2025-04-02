import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from "@salesforce/user/Id"; //this is how you will retreive the USER ID of current in user.
import Profile_Name from "@salesforce/schema/User.Profile.Name"; 
import imgUrl from '@salesforce/schema/Counsellor_Profile__c.Employee_Image_URL__c';
import examDone from "@salesforce/schema/Counsellor_Profile__c.Exam_Done__c";
import getObjectApiNameUsingRecordId from "@salesforce/apex/lightningButtonController.getObjectApiNameUsingRecordId";

let fields = [imgUrl, examDone];


export default class CounselorProfileObjectButtons extends LightningElement {
    @track showPopup = { title: '', message: '', variant: '' };
    @api recordId;
    // @api cpProfile;
    value = '';
    @track cpProfileRender;
    @track error;
    @track objectApiName;
    @track userProfileName;
    @track bShowModal = false;
    @wire(getRecord, { recordId: '$recordId', fields })
    cpProfile;
    //to check logs for cpProfile data 
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

    @wire(getObjectApiNameUsingRecordId, {
        recordId: '$recordId'
    }) getObjectName({ error, data }) {
        if (error) {
            console.log('error in getobjectName ' + error);
        } else if (data) {
            this.objectApiName = data;
            console.log('objectApiName ' + this.objectApiName);
            if (this.objectApiName === "Counsellor_Profile__c") {
                this.cpProfileRender = true;
            }
        }
    }

    get empImgURL() {
        return getFieldValue(this.cpProfile.data, imgUrl);
    }
    get examDoneStatus() {
        return getFieldValue(this.cpProfile.data, examDone);
    }

    get options() {
        return [
          { label: "--None--", value: "" },
          { label: "Counselor Assessment- 1", value: "Counselor Assessment- 1" },
          { label: "PKT- MBA (WX)", value: "PKT- MBA (WX)" }
        ];
    }
    
    handleChange(event){
        let value = event.currentTarget.dataset.value;
        console.log('handleChange '+value);
        if (value === 'uploadImage') {
            this.UploadImage();
        }else if(value === 'uploadSignature'){
            this.UploadSignature();
        }else if(value === 'startAssessment'){
            this.StartAssessment();
        }
    }

    UploadImage(){
        window.open("/apex/CounselorProfileImage?Profileid="+this.recordId+"&type=image" , "_blank")
    }

    UploadSignature(){
        window.open("/apex/CounselorProfileImage?Profileid="+this.recordId+"&type=sign" , "_blank")
    }

    StartAssessment(){
        console.log("entered in StartAssessment");
        this.bShowModal = true;
    }

    handleAssessment(event){
        this.value = event.detail.value;
        if (this.empImgURL != null && this.empImgURL != "") {
          if (this.value === "Counselor Assessment- 1") {
            window.open("http://ngasce.force.com/CounselorTest?id=a0u0o00000RP5Xx&cpid="+this.recordId);
          } else if (this.value === "PKT- MBA (WX)") {
                   //alert('Soon will be uploaded');
                window.open("http://ngasce.force.com/CounselorTest?id=a0u0o00000kzqb8&cpid=" +this.recordId);
            }
        } else {
        //   alert("Kindly upload your image prior taking Assessment test");
            this.showHtmlMessage("Image not found","Kindly upload your image prior taking Assessment test",'warning');
        }
    }

    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }
    // To show Toast message
    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}