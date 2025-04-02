import { LightningElement, wire, api, track } from 'lwc';
//import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTaskDetails from "@salesforce/apex/CallDispositionController.getTaskDetails";
import getTaskFieldOptions from '@salesforce/apex/CallDispositionController.getTaskFieldOptions';
import getDependentPicklistValues from '@salesforce/apex/CallDispositionController.getDependentPicklistValues';
import updateTaskRecord from '@salesforce/apex/CallDispositionController.updateTaskRecord';
import getChatTrancriptTasks from '@salesforce/apex/CallDispositionController.getChatTrancriptTasks';

export default class CallDispositionComp extends LightningElement {
    @api recordId;
    @api isCase = false;
    data = [];
    columns = [];
    record = {};
    hasRecords = false;
    showForm = false;
    disbaleDisposition = true;
    @track callCategoryVal = 'Admissions';
    @track taskRecord;
    // For Picklist Options
    @track optionsForPurpose;
    @track optionsForQR;
    @track optionsForStatus;
    @track optionsForCallCategory;
    @track optionsForDisposition;
    cardLabel = 'Call Logs';

    connectedCallback() {
        this.updateColumns();
    }

    updateColumns() {
        this.columns = [
            { label: 'Subject', fieldName: 'Subject' },
            {
                label: 'Schedule Call Time', fieldName: 'Schedule_Call_Time__c',
                type: "date",
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: true
                }
            },
            { label: 'Time Range', fieldName: 'Time_Range__c' },
            { label: 'Call Date', fieldName: 'Call_date__c', type: 'date' },
            { label: 'Status', fieldName: 'Status' }
        ];

        if (this.isCase) {
            // If isCase is true, include the "Edit" column
            this.columns.push({
                label: "Edit",
                type: "button",
                typeAttributes: {
                    name: "edit",
                    label: 'Edit',
                }
            });
            // to update the card Label.
            this.cardLabel = 'Call Disposition';
        }
    }
    

    @wire(getChatTrancriptTasks, { chatId: '$recordId' })
    wiredChat({ error, data }) {
        console.log(this.isCase);
        if (data && !this.isCase) {
            console.log('data chat ==>' + JSON.stringify(data));
            this.data = data;
            if (this.data.length > 0) {
                this.hasRecords = true;
            }
        } else {
            console.error(error);
        }
    }

    @wire(getTaskDetails, { caseId: '$recordId' })
    wiredTaskDetails({ error, data }) {
        if (data && this.isCase) {
            console.log('data case ==>' + JSON.stringify(data));
            this.data = data;
            if (this.data.length > 0) {
                this.hasRecords = true;
            }
        } else {
            console.error(error);
        }
    }

    @wire(getTaskFieldOptions, { fieldAPIName: 'Purpose__c' })
    getPurposeList({ error, data }) {
        if (data) {
            this.optionsForPurpose = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getTaskFieldOptions, { fieldAPIName: 'Query_Resolved__c' })
    getQRList({ error, data }) {
        if (data) {
            this.optionsForQR = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getTaskFieldOptions, { fieldAPIName: 'Status' })
    getStatusList({ error, data }) {
        if (data) {
            this.optionsForStatus = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getTaskFieldOptions, { fieldAPIName: 'Call_Category__c' })
    getCCList({ error, data }) {
        if (data) {
            this.optionsForCallCategory = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getDependentPicklistValues, { fieldAPIName: 'Disposition__c', fieldValue: '$callCategoryVal' })
    getDispositionList({ error, data }) {
        if (data) {
            this.optionsForDisposition = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        console.log(JSON.stringify(row));
        this.taskRecord = JSON.parse(JSON.stringify(row));
        this.showForm = true;
    }

    handleChange(event) {
        console.log(event.target.dataset.field);
        console.log(event.detail.value);
        if (event.target.dataset.field === 'Call_Category__c') {
            // event.target.fieldName
            this.disbaleDisposition = false;
            this.callCategoryVal = event.detail.value;
        }
        let field = event.target.dataset.field;
        // if ({}.hasOwnProperty.call(this.taskRecord, field)) {
            this.taskRecord[field] = event.detail.value;
        // }
        console.log(this.taskRecord);
    }

    handleClick() {
        this.showForm = false;
    }

    closeForm() {
        this.showForm = false;
    }

    handleSubmit() {
        const {
            Id,
            Subject,
            Purpose__c,
            Query_Resolved__c,
            Status,
            Call_Category__c,
            Disposition__c,
            Description
        } = this.taskRecord;
        console.log(this.taskRecord, 'this.taskRecord');
        if (Subject && Purpose__c && Query_Resolved__c && Status && Call_Category__c && Disposition__c && Description) {
            updateTaskRecord({
                taskId: Id,
                purpose: Purpose__c,
                queryResolved: Query_Resolved__c,
                status: Status,
                callCategory: Call_Category__c,
                disposition: Disposition__c,
                description: Description
            })
                .then(result => {
                    if (result === 'Success') {
                        // Show a success toast message
                        this.showToast('Success', 'Task updated successfully', 'success');
                        // Switch back to the table view
                        this.showForm = false;
                    } else {
                        // Show an error toast message
                        this.showToast('Error', result, 'error');
                    }
                })
                .catch(error => {
                    console.error(error);
                    // Show an error toast message
                    this.showToast('Error', 'Error updating task', 'error');
                });
        } else {
            console.log(Subject, Purpose__c, Query_Resolved__c, Status, Call_Category__c, Disposition__c, Description);
            this.showToast('Error', 'Please fill in all required fields ', 'error');
        }

    }
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);

    }

}











/*handleSubmit() {
    const fields = {
        Id: this.taskRecord.Id,
        Subject: this.taskRecord.Subject,
        Purpose__c: this.taskRecord.Purpose__c,
        Query_Resolved__c: this.taskRecord.Query_Resolved__c,
        Status: this.taskRecord.Status,
        Call_Category__c: this.taskRecord.Call_Category__c,
        Disposition__c: this.taskRecord.Disposition__c,
        Description: this.taskRecord.Description
    };
 
    // Call the Apex method to update the record
    updateTaskRecord({ taskFields: fields })
        .then(() => {
            // Show a success toast message
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Task updated successfully',
                variant: 'success'
            });
            this.dispatchEvent(toastEvent);
 
            // Switch back to the table view
            this.showForm = false;
        })
        .catch(error => {
            // Handle error and show an error toast message
            console.error(error);
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Error updating task',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        });
}*/




/* handleSubmit() {
     const { Id, Subject, Purpose__c, Query_Resolved__c, Status, Call_Category__c, Disposition__c, Description } = this.taskRecord;
     
     updateTaskRecord({ 
         taskId: Id, 
         subject: Subject, 
         purpose: Purpose__c, 
         queryResolved: Query_Resolved__c, 
         status: Status, 
         callCategory: Call_Category__c, 
         disposition: Disposition__c, 
         description: Description 
     })
         .then(result => {
             if (result === 'Success') {
                 // Show a success toast message
                 this.showToast('Success', 'Task updated successfully', 'success');
                 // Switch back to the table view
                 this.showForm = false;
             } else {
                 // Show an error toast message
                 this.showToast('Error', result, 'error');
             }
         })
         .catch(error => {
             console.error(error);
             // Show an error toast message
             this.showToast('Error', 'Error updating task', 'error');
         });
 }
 
 showToast(title, message, variant) {
     const toastEvent = new ShowToastEvent({
         title: title,
         message: message,
         variant: variant
     });
     this.dispatchEvent(toastEvent);
 }*/








/* handleSubmit() {
     debugger;
     // Prepare the fields to update
     const fields = {};
     fields.Id = this.taskRecord.Id;
     fields.Subject = this.taskRecord.Subject;
     fields.Purpose__c = this.taskRecord.Purpose__c;
     fields.Query_Resolved__c = this.taskRecord.Query_Resolved__c;
     fields.Status = this.taskRecord.Status;
     fields.Call_Category__c = this.taskRecord.Call_Category__c;
     fields.Disposition__c = this.taskRecord.Disposition__c;
     fields.Description = this.taskRecord.Description;

     // Create a record input object
     const recordInput = { fields };

     // Update the record
     updateRecord(recordInput)
         .then(() => {
             // Show a success toast message
             const toastEvent = new ShowToastEvent({
                 title: 'Success',
                 message: 'Task updated successfully',
                 variant: 'success',
             });
             this.dispatchEvent(toastEvent);

             // Switch back to the table view
             this.showForm = false;
         })
         .catch(error => {
             // Handle error and show an error toast message
             console.error(error);
             const toastEvent = new ShowToastEvent({
                 title: 'Error',
                 message: 'Error updating task',
                 variant: 'error',
             });
             this.dispatchEvent(toastEvent);
         });
 }*/







/* handleSubmit() {
     // Update the task using the Apex method
     updateTask({ task: this.taskRecord })
       .then(result => {
         // Show a success toast message
         const toastEvent = new ShowToastEvent({
           title: 'Success',
           message: 'Task updated successfully',
           variant: 'success',
         });
         this.dispatchEvent(toastEvent);
 
         // Reset the form and switch back to table view
         this.showForm = false;
         this.loadData();
       })
       .catch(error => {
         // Handle any errors and show an error toast message
         const toastEvent = new ShowToastEvent({
           title: 'Error',
           message: 'An error occurred while updating the task',
           variant: 'error',
         });
         this.dispatchEvent(toastEvent);
       });
   }










/*async handleSubmit() {
 try {
     const fields = {};
     fields.Id = this.taskRecord.Id;
     fields.Subject = this.taskRecord.Subject;
     fields.Purpose__c = this.taskRecord.Purpose__c;
     fields.Query_Resolved__c = this.taskRecord.Query_Resolved__c;
     fields.Status = this.taskRecord.Status;
     fields.Call_Category__c = this.taskRecord.Call_Category__c;
     fields.Disposition__c = this.taskRecord.Disposition__c;
     fields.Description = this.taskRecord.Description;

     const recordInput = { fields };
     await updateRecord(recordInput);
     
     // Show a success toast message
     this.dispatchEvent(
         new ShowToastEvent({
             title: 'Success',
             message: 'Task updated successfully',
             variant: 'success',
         })
     );

     // Switch back to the table view
     this.showForm = false;
 } catch (error) {
     console.error(error);
     // Show an error toast message if the update fails
     this.dispatchEvent(
         new ShowToastEvent({
             title: 'Error',
             message: 'Error updating Task',
             variant: 'error',
         })
     );
 }

}*/