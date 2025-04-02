import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import QB_OBJECT from '@salesforce/schema/Question_Bank__c';
import FUNCTION_FIELD from '@salesforce/schema/Question_Bank__c.Function__c';
import ACTIVITY_FIELD from '@salesforce/schema/Question_Bank__c.Activity__c';
import PROGRAM_FIELD from '@salesforce/schema/Question_Bank__c.Program_Type__c';
import upsertAssessment from '@salesforce/apex/Survey.upsertAssessment';

export default class UpsertAssessmentModal extends LightningElement {
    error = '';
    picklistValuesOfFuntion;
    picklistValuesOfActivtiy;
    picklistValuesOfProgramType;
    @api record;
    @api isCreate = false;
    @track currentRecord = {
        Name:'',
        Timer__c:'',
        Function__c:'',
        Activity__c:'',
        Program_Type__c:'',
        Submit_Response__c:'',
        IsActive__c:true,
        Show_Result__c:true,
        Survey_Header__c:'',
        New_Survey__c:true
    };
    @track activityOptions;
    @track showPopup = { title: '', message: '', variant: '' };

    connectedCallback() {
        // to set the record to the current Record.
        if(!this.isCreate) {
            // this.currentRecord = this.record;
            this.currentRecord = {...this.record}
            console.dir(this.currentRecord);
            console.log('check value');
        }
    }

    @wire(getObjectInfo, { objectApiName: QB_OBJECT })
	objectInfo;

    @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FUNCTION_FIELD 
    })
    wiredPicklistFunction({ error, data }){
        if(data){
            this.picklistValuesOfFuntion = data.values;
            console.log(' data ', data.values);
            this.error = undefined;
        }
        if(error){
            this.picklistValuesOfFuntion = undefined;
            this.error = error;
        }
    }

    @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ACTIVITY_FIELD 
    })
    wiredPicklistActivtiy({ error, data }){
        if(data){
            this.activityOptions = data;
            this.picklistValuesOfActivtiy = this.activityOptions.values;
            // console.log(' data ', this.activityOptions);
            this.error = undefined;
        }
        if(error){
            // this.isActivityDisabled = true;
            this.picklistValuesOfActivtiy = undefined;
            this.error = error;
        }
    }

    @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PROGRAM_FIELD 
    })
    wiredPicklistProgramType({ error, data }){
        if(data){
            this.picklistValuesOfProgramType = data.values;
            console.log(' data ', data.values);
            this.error = undefined;
        }
        if(error){
            this.picklistValuesOfProgramType = undefined;
            this.error = error;
        }
    }

    get isActive(){
        return this.currentRecord.IsActive__c;
    }

    get showResult(){
        return this.currentRecord.Show_Result__c;
    }

    handleValueChange(event){
        let value;
        if(event.detail.field) {
            const field = event.detail.field;
            let arrayValues = [];
            if(field === 'Function__c') {
                this.picklistValuesOfActivtiy = undefined;
                console.log('Function '+event.detail.values);
                if(event.detail.values.length > 0) {
                    event.detail.values.forEach(element => {
                        if(element) {
                            // this.isActivityDisabled = false;
                            let key = this.activityOptions.controllerValues[element];
                            if(this.picklistValuesOfActivtiy) {
                                this.picklistValuesOfActivtiy = this.picklistValuesOfActivtiy.concat(this.activityOptions.values.filter(opt => opt.validFor.includes(key)));
                            } else {
                                this.picklistValuesOfActivtiy = this.activityOptions.values.filter(opt => opt.validFor.includes(key));
                            }
                        }
                    });
                    value = event.detail.values.join(';');
                } 
                else {
                    this.picklistValuesOfActivtiy = this.activityOptions.values;
                    this.picklistValuesOfFuntion.forEach(element => {
                        arrayValues.push(element.value);
                    });
                    value = arrayValues.join(';');
                }
            } else if(field === 'Activity__c') {
                this.picklistValuesOfActivtiy.forEach(element => {
                    arrayValues.push(element.value);
                });
                value = event.detail.values.length > 0 ? event.detail.values.join(';') : arrayValues.join(';');
            } else if(field === 'Program_Type__c') {
                this.picklistValuesOfProgramType.forEach(element => {
                    arrayValues.push(element.value);
                });
                value = event.detail.values.length > 0 ? event.detail.values.join(';') : arrayValues.join(';');
            }
            if ({}.hasOwnProperty.call(this.currentRecord, field)) {
                this.currentRecord[field] = value;
                console.log(value);
            }
        } else if(event.currentTarget.dataset.field) {
            const field = event.target.dataset.field;
            if ({}.hasOwnProperty.call(this.currentRecord, field)) {
                value = field === 'IsActive__c' || field === 'Show_Result__c' ? event.detail.checked : event.detail.value;
                console.log(field + ' => ' + value)
                this.currentRecord[field] = value;
            }
        }
    }

    saveAssessment() {
        // if combo-box option not selected
        this.setdefaultValues();
        console.dir(this.currentRecord);
        if (!this.formValidate()) {
			return;
		}
        // upsert Assessment Record.
        upsertAssessment({objSurvey : this.currentRecord})
        .then((result) => { 
            console.log('result '+result);
            if(result != null){
                this.showPopup.title = 'Record saved successfully!';
                this.showPopup.message = 'success'; 
                this.showPopup.variant = 'success';
                console.log(JSON.stringify(result));
                this.sendValues(result,'save');
            }
        })
        .catch((error) => {
            this.showPopup.title = 'Error while inserting the record!';
            this.showPopup.message = 'error'; 
            this.showPopup.variant = 'error';
            console.log(error);
            this.sendValues(null,'save');
        });
    }

    setdefaultValues() {
        let arrayValues = [];
        if(!this.currentRecord.Function__c) {
            arrayValues = [];
            this.picklistValuesOfFuntion.forEach(element => {
                arrayValues.push(element.value);
            });
            this.currentRecord.Function__c = arrayValues.join(';');
        }
        if(!this.currentRecord.Activity__c) {
            arrayValues = [];
            this.picklistValuesOfActivtiy.forEach(element => {
                arrayValues.push(element.value);
            });
            this.currentRecord.Activity__c = arrayValues.join(';');
        }
        if(!this.currentRecord.Program_Type__c) {
            arrayValues = [];
            this.picklistValuesOfProgramType.forEach(element => {
                arrayValues.push(element.value);
            });
            this.currentRecord.Program_Type__c = arrayValues.join(';');
        }
    }

    formValidate() {
		const allValid = [
			...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group')
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		return allValid;
    }

    hideModal() {
        this.sendValues(null,'close');
    }

    sendValues(result,type) {
        this.dispatchEvent(new CustomEvent("modalresponse", {
            detail: {
                message: this.showPopup,
                values: result,
                type: type
            }
        }));
    }
}