import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import siteUrl from '@salesforce/label/c.Site_Url'; 
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import Profile_Name from '@salesforce/schema/User.Profile.Name'; 
import fedExShipDate from '@salesforce/schema/Dispatch_Order__c.Fed_Ex_Shipment_Created__c';
import toCenter from '@salesforce/schema/Dispatch_Order__c.To_Centers__c';
import toStudent from '@salesforce/schema/Dispatch_Order__c.To_Student__c';
// import centerId from '@salesforce/schema/Dispatch_Order__c.To_CentersId__c';
// import stockId from '@salesforce/schema/Dispatch_Order__c.Stock_Keeping_UnitId__c';
import selfLearn from '@salesforce/schema/Dispatch_Order__c.Self_Learning_Material_For_Student__c';
import getObjectApiNameUsingRecordId from '@salesforce/apex/lightningButtonController.getObjectApiNameUsingRecordId';
import createShipment from '@salesforce/apex/FedExWebService.createShipment'; 
// import UpdateFinalQuantityOnCenter from '@salesforce/apex/DispatchForClosedWon.UpdateFinalQuantityOnCenter';
let fields = [fedExShipDate, toCenter, toStudent, selfLearn];
// let fields = [fedExShipDate, toCenter, toStudent, selfLearn, centerId, stockId];
export default class DispatchOrderObjectButton extends LightningElement {
    @track showPopup = { title: '', message: '', variant: '' };
    @api recordId;
    @track error;
    @track objectApiName;
    @track userProfileName;
    @track dispatchOrderRender;
    @wire(getRecord, { recordId: '$recordId', fields })
    dispatchOrder;

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
            if (this.objectApiName === 'Dispatch_Order__c') {
                this.dispatchOrderRender = true;
            }
        }
    }

    // renderedCallback() {
    //     console.log('this.recordId ' + this.recordId);
    //     console.log('this.objectApiName '+this.objectApiName);
    // }

    get fedExShipmentDate() {
        return getFieldValue(this.dispatchOrder.data, fedExShipDate);
    }
    get toCenterId() {
        return getFieldValue(this.dispatchOrder.data, toCenter);
    } 
    get toStudId() {
        return getFieldValue(this.dispatchOrder.data, toStudent);
    }
    get selfLearningMaterial() {
        return getFieldValue(this.dispatchOrder.data, selfLearn);
    }
    // get aepId() {
    //     return getFieldValue(this.dispatchOrder.data, centerId);
    // }
    // get stockUnitId() {
    //     return getFieldValue(this.dispatchOrder.data, stockId);
    // }

    handleChange(event){
        let value = event.currentTarget.dataset.value;
        if (value === 'CreateFedEx') {
            this.CreateFexExShipment();
        } else if (value === 'receivedBystud') {
            this.ReceivedBystudent();
        } 
    }

    CreateFexExShipment(){
        console.log('selfLearnMaterial '+this.selfLearningMaterial+' center id '+this.toCenterId +' studnet id '+this.toStudId+' fedExshipDate '+this.fedExShipmentDate);
        if (this.selfLearningMaterial === 'Send to my Information Centre. I will pick up.' && this.toCenterId === ''){
            this.showHtmlMessage('Please select Information center.','Warning','warning');
        } else if (this.selfLearningMaterial === 'Send to my shipping address' && this.toStudId === '') {
            this.showHtmlMessage('Please select TO STUDENT', 'Warning', 'warning');
        }else if (this.fedExShipmentDate) {
            this.showHtmlMessage('FedEx Shipment is already created', 'Warning', 'warning');
        }else {
            var answer = confirm("Are you sure you want to create FedEx Shipment?");
            if (answer == true) {
                createShipment({ id: this.recordId })
                    .then(result => {
                        // alert("Fed Ex shipment is created successfully");
                        this.showHtmlMessage("Fed Ex shipment is created successfully", 'Success', 'success');
                    })
                    .catch(error => {
                        this.error = error;
                        this.showHtmlMessage("Error in creating FedEx Shipment", error.message, 'error');
                    });
                // window.location.reload();
            }
        }
    }

    ReceivedBystudent(){
        console.log('enter in ReceivedBystudent');
    //     if (this.selfLearningMaterial == 'Send it to my Information Center.I will pick it up.') {
    //         var answer = confirm("Are you sure you want to Update Quantity at Information Center ?");
    //         if (answer == true) {
    //             UpdateFinalQuantityOnCenter({ centerId: this.aepId, stockId: this.stockUnitId})
    //             .then(result => {
    //                 let response = result;
    //                 console.log(JSON.stringify(response));
    //                 if (response === 'Done'){
    //                     this.showHtmlMessage('The Quantity is successfully updated on the Information Center', 'success', 'success');
    //                 }else {
    //                     this.showHtmlMessage(response,'Warning','warning');
    //                 }
    //             })
    //             .catch(error => {
    //                 this.error = error;
    //                 this.showHtmlMessage("An error occured.",error.message,'error');
    //             });
    //         }

    //     }
    //     else {
    //         this.showHtmlMessage('Not Applicable for the "Self Learning Material" chosen by the Candidate', 'Warning', 'warning');
    //     }
    }

    // To show Toast message
    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}