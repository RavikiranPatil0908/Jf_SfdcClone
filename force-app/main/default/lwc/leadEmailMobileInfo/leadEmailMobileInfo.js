/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 17-06-2025
 * @last modified by  : @Shailesh
**/
import { LightningElement, api, wire, track } from 'lwc';
import getLeadEmailMobileInfo from '@salesforce/apex/LeadEmailMobileInfoController.getLeadEmailMobileInfo';
import updateLeadInfo from '@salesforce/apex/LeadEmailMobileInfoController.updateLeadInfo';
import insertEventMonitoring from '@salesforce/apex/EventMonitoringController.insertEventMonitoring';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';
export default class LeadEmailMobileInfo extends LightningElement {
    @api recordId;
    userId = Id;
    userName;
    userRoleName;
    userProfileName;
   // @track disableEditbtn = true;
    @track records = [];
    @track dataLoading = true;
    @track hasData = false;
    @track isEditing = false;
    @track showSaveButton = false;
    originalEmail;
    originalMobile;
    originalSecondaryEmail;
    originalPhone;
    editedEmail;
    editedMobile;
    editedSecondaryEmail;
    editedPhone;

    constructor() {
        super();
        document.addEventListener("keydown", this.handleNotificationCopy);
        document.addEventListener("dragstart", this.handleNotificationDrag);
       
    }
     connectedCallback() {
         
        insertEventMonitoring({
            leadId: this.recordId,
            userId: Id,
            objectType: 'Lead',
            event: 'View'
        });

     }
    handleNotificationCopy = (event) => {
        if (event.ctrlKey && event.key === 'c') {
         //   console.log('Ctrl + C pressed');
            insertEventMonitoring({
            leadId: this.recordId,
            userId: Id,
            objectType: 'Lead',
            event: 'Copy'
        });
        }
    };
    handleNotificationDrag = (event) => {
       
           // console.log('Draged');
            insertEventMonitoring({
            leadId: this.recordId,
            userId: Id,
            objectType: 'Lead',
            event: 'Drag'
        });
        
    };

    // @wire(getRecord, { recordId: Id, fields: [Name, RoleName, ProfileName] })
    // userDetails({ error, data }) {
    //     if (error) {
    //         this.error = error;
    //     } else if (data) {
    //         if (data.fields.Name.value != null) {
    //             this.userName = data.fields.Name.value;
    //         }
    //         if (data.fields.UserRole.value != null) {
    //             this.userRoleName = data.fields.UserRole.value.fields.Name.value;
    //         }
    //         if (data.fields.Profile.value != null) {
    //             this.userProfileName = data.fields.Profile.value.fields.Name.value;
    //             if(this.userProfileName != undefined && (this.userProfileName === 'Super Admin' || this.userProfileName === 'Head Office' || this.userProfileName === 'System Administrator')){
    //                 if(this.userProfileName === 'Super Admin'){
    //                     if(this.userName === 'marketing ngasce'){
    //                         this.disableEditbtn =  false;
    //                     } 
    //                     }else{
    //                         this.disableEditbtn = false;
    //                     } 
    //                 }
    //         }
    //         }
    //         console.log('userProfileName:: '+this.userProfileName);
    //         console.log('userRoleName:: '+this.userRoleName );
    //         console.log('userName::'+this.userName);     
    // }


    @wire(getLeadEmailMobileInfo, { recordId: '$recordId' })
    wiredLeadEmailMobileInfo({ error, data }) {
        if (data) {
            if (data.length > 0) {
                this.records = data;
                this.originalEmail = data[0].email;
                this.originalMobile = data[0].mobile;
                this.originalSecondaryEmail = data[0].secondaryEmail;
                this.originalPhone = data[0].phone;
                this.editedEmail = data[0].email;
                this.editedMobile = data[0].mobile;
                this.editedSecondaryEmail = data[0].secondaryEmail;
                this.editedPhone = data[0].phone;
                this.hasData = true;
              
            } else {
                this.hasData = false;
            }
            this.dataLoading = false;
        } else if (error) {
            console.error(error);
            this.dataLoading = false;
        }
    }


    get isDisabled() {
        return !this.isEditing;
    }
    logEventMonitoring(eventMsg ){

    insertEventMonitoring({
                    leadId: this.recordId,
                    userId: Id,
                    objectType: 'Lead',
                    event: eventMsg
                });

    }

    handleEdit() {
       this.isEditing = true;
       this.showSaveButton = true;
    }

    handleEmailChange(event) {
        this.editedEmail = event.target.value;
        this.showSaveButton = true;
    }

    handleMobileChange(event) {
        this.editedMobile = event.target.value;
        this.showSaveButton = true;
    }

    handleSecondaryEmailChange(event) {
        this.editedSecondaryEmail = event.target.value;
        this.showSaveButton = true;
    }

    handlePhoneChange(event) {
        this.editedPhone = event.target.value;
        this.showSaveButton = true;
    }

    handleSave() {
        // Frontend validation for Mobile and Phone fields
        if (this.editedMobile && !/^\d{10}$/.test(this.editedMobile)) {
            this.showAlert( 'Mobile number must be a 10-digit number.', 'error');
            return;
        }
        if (this.editedPhone && !/^\d+$/.test(this.editedPhone)) {
            this.showAlert( 'Phone must contain only numeric characters.', 'error');
            return;
        }

        updateLeadInfo({ leadId: this.recordId, email: this.editedEmail, mobile: this.editedMobile, secondaryEmail: this.editedSecondaryEmail, phone: this.editedPhone })
            .then(() => {
                this.originalEmail = this.editedEmail;
                this.originalMobile = this.editedMobile;
                this.originalSecondaryEmail = this.editedSecondaryEmail;
                this.originalPhone = this.editedPhone;
                this.isEditing = false;
                this.showSaveButton = false;
                this.showAlert('Success', 'Lead updated successfully', 'success');
            })
            .catch(error => {
                this.showAlert('Error updating lead', error.body.message, 'error');
            });
    }

    handleCancel() {
        this.editedEmail = this.originalEmail;
        this.editedMobile = this.originalMobile;
        this.editedSecondaryEmail = this.originalSecondaryEmail;
        this.editedPhone = this.originalPhone;
        this.isEditing = false;
        this.showSaveButton = false;
    }

    showAlert(title, message, variant) {
        if (this.template.querySelector('lightning-toast')) {
            // Lightning Experience: Show toast notification
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        } else {
            // Classic Experience: Show alert
            alert(`${title}: ${message}`);
        }
    }

    
   
}