import { LightningElement, api, wire, track } from 'lwc';
import getCancelDates from "@salesforce/apex/AEPMerchandiseController.getCancelDates";
import LightningConfirm from 'lightning/confirm';
import saveCancelationDateRecord from "@salesforce/apex/AEPMerchandiseController.saveCancelationDateRecord";
import deleteCancelationDateByRecordId from "@salesforce/apex/AEPMerchandiseController.deleteCancelationDateByRecordId";
import updateCancelationDateChanges from "@salesforce/apex/AEPMerchandiseController.updateCancelationDateChanges";

export default class ShowCancelationDates extends LightningElement {
    @api paymentConfigId; // Receive the key from parent
    @track lstCancelDates = [];
    @track inputFields = []; // Array to store dynamic input fields
    @track isShowSpinner = false;
    @track isEditModalOpen = false;
    @track editModalData = {};
    editInputFieldChanges = {};

    // @wire(getCancelDates, { recordId: '$paymentConfigId' })
    // getCancelDates({ error, data }) {
    //     if (data) {
    //         this.lstCancelDates = data;
    //         console.log('data--->' + JSON.stringify(this.lstCancelDates));
    //     }
    //     else if(error) {
    //         console.log('error---->' + JSON.stringify(error));
    //     }
    // }

    @api
    refresh() {
        // Logic to refresh child component
        console.log('Child component refreshed ' + this.paymentConfigId);
        this.lstCancelDates = [];
        const dummyParam = new Date().getTime(); // Unique value
        getCancelDates({ recordId: this.paymentConfigId, dummy: dummyParam  })
        .then((result) => {
            console.log('lstCancelDates--->' + this.lstCancelDates);
            console.log('paymentConfigId--->' + this.paymentConfigId);
            this.lstCancelDates = result;
            console.log('data1--->' + JSON.stringify(result));
        }).catch((err) => {
            console.log('error---->' + JSON.stringify(err));
        });
        return true;
    }

    @api
    validateParentSaveButton() { 
        if (this.inputFields.length > 0) {
            return true;
        }
        return false;
    }

    // Method to process the cancellation dates
    get processedCancellationDates() {
        return this.lstCancelDates.map(record => ({
            ...record, // Keep all existing record fields
            admissionFeeDeduction: record.Admission_Fee__c ? 'Full Deduction' : '',
            formattedFromDate: this.convertDateINToISTDate(record.From_Date__c),
            formattedToDate: this.convertDateINToISTDate(record.To_Date__c) // Compute icon name
            //alternativeText: record.Admission_Fee__c ? 'Yes' : 'No' // Compute alternative text
        }));
    }

    // onCloseCancelationDateModal() {
    //     this.dispatchEvent(new CustomEvent('close'));
    // }

    convertDateINToISTDate(dateStr) {
        const date = new Date(dateStr);
        const months = date.getMonth() >= 0 ? date.getMonth() + 1 : 0;
        console.log('dateStr -->' + dateStr);
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = String(date.getFullYear());
        const formattedDate = `${day}/${month}/${year}`;
        console.log('formattedDate--->' + formattedDate);
        return  months ? formattedDate : '-';
    }

    // Show Remove Button only when there is at least one input field
    get showRemoveButton() {
        return this.inputFields.length > 0;
    }

    // Add a new set of input fields
    handleAddField() {
        this.inputFields = [
            ...this.inputFields,
            {
                fieldId: Date.now(),
                From_Date__c: '',
                To_Date__c: '',
                Amount__c: '',
                Admission_Fee__c: false,
                Percentage__c: '',
                error: {}
            }
        ];
    }

    // Remove the last set of input fields
    handleRemoveField() {
        if (this.inputFields.length > 0) {
            this.inputFields.pop();
            this.inputFields = [...this.inputFields]; // Ensure reactivity
        }
    }

    // Update field values dynamically
    handleFieldChange(event) {
        const index = event.target.dataset.index;
        const fieldName = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

        this.inputFields[index][fieldName] = value;
        this.inputFields[index].error[fieldName] = ''; // Clear field error
        this.inputFields = [...this.inputFields]; // Ensure reactivity
    }

    // Example method to get the final object data
    getFormattedData() {
        console.log('Formatted Data:', JSON.stringify(this.inputFields));
        return this.inputFields;
    }

    handleDelete(event) {
        const recordId = event.target.dataset.id;
        const index = event.target.dataset.index;
        console.log('recordId--->' + recordId);
        this.deleteCancelationDateRecord(recordId,index);
    }

    async deleteCancelationDateRecord(recordId,index) {
        const result = await LightningConfirm.open({
            message: 'Are you sure want to delete record ?',
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        if (result) {
            deleteCancelationDateByRecordId({recordId : recordId})
            .then(result => {
                console.log('result ---->' + result);
                if (result) {
                    // Check if the index is valid
                    let mutableList = [...this.lstCancelDates]; // Spread operator creates a shallow copy
                    if (index >= 0 && index < mutableList.length) {
                        mutableList.splice(index, 1);
                        this.lstCancelDates = mutableList; // Reassign the modified list back
                        console.log('after delete list--->' + JSON.stringify(this.lstCancelDates));
                    }
                    alert('Record deleted Successfully');
                } else {
                    alert('Something went wrong. Please try again!');
                }
            }).catch(error => {
                console.log('error--->' + error);
                alert('Something went wrong. Please try again!');
            })
        }
    }

    onCloseEditModal() {
        this.isEditModalOpen = false;
        this.editModalData = {};
        this.editInputFieldChanges = {};
        //this.dispatchEvent(new CustomEvent('close'));
    }

    handleEdit(event) {
        console.log('edit modal');
        this.editModalData = {};
        this.editInputFieldChanges = {};
        const index = event.target.dataset.index;
        this.editModalData = { ...this.lstCancelDates[index] };
        this.editModalData.index = index;
        this.editModalData.error = {};
        this.isEditModalOpen = true;
    }

    handleEditFieldChange(event) {
        let inputName = event.target.name;
        //if (event.target.value) {
            this.editModalData[inputName] = event.target.type === 'checkbox' ? event.target.checked : event.target.value;;
            this.editInputFieldChanges[inputName] = event.target.type === 'checkbox' ? event.target.checked : event.target.value;;
            event.target.setCustomValidity('');
            event.target.reportValidity();
            this.editModalData.error[inputName] = '';
            console.log('inputName-->' + inputName + ' ' +  event.detail.value);
            console.log(' this.editInputFieldChanges--->' +  JSON.stringify(this.editInputFieldChanges));
        //}
        // else {
        //     delete this.editInputFieldChanges[inputName];
        // }
    }

    async handleCancelationUpdate() {
        if (Object.keys(this.editInputFieldChanges).length == 0) {
            alert('At least change 1 value')
        } else {
            let isValid = true;
            console.log('test');
            console.log('field1---->' + JSON.stringify(this.editModalData));
            console.log('list update:' + JSON.stringify(this.editInputFieldChanges));
            
            let fieldErrors = {};

            // Validate required fields
            if (!this.editModalData.From_Date__c) {
                fieldErrors.From_Date__c = 'From Date is required.';
                isValid = false;
            }

            if (!this.editModalData.To_Date__c) {
                fieldErrors.To_Date__c = 'To Date is required.';
                isValid = false;
            }

            // Validate date logic
            if (this.editModalData.From_Date__c && this.editModalData.To_Date__c && new Date(this.editModalData.From_Date__c) > new Date(this.editModalData.To_Date__c)) {
                fieldErrors.To_Date__c = 'To Date must be after From Date.';
                isValid = false;
            }

            // Update field errors
            this.editModalData.error = fieldErrors;
            
            // Check Lightning Input Validation
            const allValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((isValidInput, input) => {
                    input.reportValidity();
                    return isValidInput && input.checkValidity();
                }, true);

            if (!isValid || !allValid) {
                console.log('⚠️ Validation failed: Please correct the errors.');
                alert('Please update the invalid form entries and try again.');
                return;
            }
            const result = await LightningConfirm.open({
                message: 'Are you sure want to apply changes ?',
                variant: 'headerless',
                label: 'this is the aria-label value',
                // setting theme would have no effect
            });
            if (result) {
                updateCancelationDateChanges({recordId : this.editModalData.Id,mapOfInputAndValues : this.editInputFieldChanges})
                .then(result => {
                    if (result) {
                        console.log('result-->' + result);
                        // Clone the array to ensure reactivity
                        let updatedList = [...this.lstCancelDates];

                        // Replace the item at the specific index
                        updatedList.splice(this.editModalData.index, 1, { ...this.editModalData });

                        // Reassign the cloned and updated array
                        this.lstCancelDates = updatedList;
                        alert('Record updated Successfully');
                        this.isEditModalOpen = false;
                    } else {
                        alert('Something went wrong');
                    }
                }).catch(error => {
                    console.log('error--->' + error);
                    alert('Something went wrong');
                })
            }
        }
        
    }

    // Validate all fields before saving
    handleCancelationConfirmClick() {
        let isValid = true;
        console.log('field1---->' + JSON.stringify(this.inputFields));
        this.inputFields.forEach((field, index) => {
            let fieldErrors = {};

            // Validate required fields
            if (!field.From_Date__c) {
                fieldErrors.From_Date__c = 'From Date is required.';
                isValid = false;
            }

            if (!field.To_Date__c) {
                fieldErrors.To_Date__c = 'To Date is required.';
                isValid = false;
            }

            // Validate date logic
            if (field.From_Date__c && field.To_Date__c && new Date(field.From_Date__c) > new Date(field.To_Date__c)) {
                fieldErrors.To_Date__c = 'To Date must be after From Date.';
                isValid = false;
            }

            // Update field errors
            this.inputFields[index].error = fieldErrors;
        });

        this.inputFields = [...this.inputFields]; // Ensure reactivity

        // Check Lightning Input Validation
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((isValidInput, input) => {
                input.reportValidity();
                return isValidInput && input.checkValidity();
            }, true);

        if (!isValid || !allValid) {
            console.log('⚠️ Validation failed: Please correct the errors.');
            alert('Please update the invalid form entries and try again.');
            return;
        }
        console.log('✅ Validation passed:', JSON.stringify(this.inputFields));
        this.handleConfirmClick();
    }

    async handleConfirmClick() {
        //this.isShowSpinner = true;
        console.log('before');
        const result = await LightningConfirm.open({
            message: 'Are you sure want to apply changes ?',
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        console.log('after confirm');
        if (result) {
            saveCancelationDateRecord({lstOfCancelationDates : this.inputFields,paymentConfigId : this.paymentConfigId})
            .then(result => {
                this.isShowSpinner = false;
                console.log('result.isSuccess--->' + result.isSuccess);
                console.log('record created-->' + JSON.stringify(result.lstInsertedCancelRecord));
                if (result.isSuccess) {
                    // Merge the two lists
                    let mergedList = [...this.lstCancelDates, ...result.lstInsertedCancelRecord];

                    // Sort the merged list by FromDate in ascending order
                    this.lstCancelDates = mergedList.sort((a, b) => {
                        // Convert FromDate to Date objects for comparison
                        let dateA = new Date(a.From_Date__c);
                        let dateB = new Date(b.From_Date__c);
                        return dateA - dateB; // Ascending order
                    });
                }       
                console.log('merged---->' + JSON.stringify(this.lstCancelDates));         
                this.inputFields = [];
                console.log('this.lstCancelDates---->' + JSON.stringify(this.lstCancelDates + result.msg));
                alert(result.msg);
                //window.location.reload();
            }).catch(error => {
                this.isShowSpinner = false;
                console.log('saveChangedDated catch -->',JSON.stringify(error))
                alert('Something went wrong, kindly try again later')
            })
        }
    }

}