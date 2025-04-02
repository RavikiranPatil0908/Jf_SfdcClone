import { LightningElement, track, wire, api } from 'lwc';
// import { getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from "@salesforce/user/Id"; //this is how you will retreive the USER ID of current in user.
import Profile_Name from "@salesforce/schema/User.Profile.Name"; 
import getObjectApiNameUsingRecordId from "@salesforce/apex/lightningButtonController.getObjectApiNameUsingRecordId";
export default class AepRequestObjectButton extends LightningElement {
    @track aepRequestRender;
    @api recordId;
    @track error;
    @track objectApiName;
    @track userProfileName;
    @track bShowModal = false;
    // @wire(getRecord, { recordId: '$recordId', fields })
    // cpProfile;

    @wire(getObjectApiNameUsingRecordId, {
        recordId: '$recordId'
    }) getObjectName({ error, data }) {
        if (error) {
            console.log('error in getobjectName ' + error);
        } else if (data) {
            this.objectApiName = data;
            console.log('objectApiName ' + this.objectApiName);
            if (this.objectApiName === "AEP_Request__c") {
                this.aepRequestRender = true;
            }
        }
    }

    handleChange(event){
        let value = event.currentTarget.dataset.value;
        console.log('handleChange '+value);
        if (value === 'assignedLC') {
            this.assignedbackToLC();
        }
    }

    assignedbackToLC(){
        window.open("https://ap1.salesforce.com/"+this.recordId+"/e?retURL="+this.recordId+"&00N9000000EcWiI=Escalated to LC", "_blank");
    }
}