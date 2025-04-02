import {api, LightningElement, track, wire} from 'lwc';
import getPickListValuesForDisposition from '@salesforce/apex/CallLogController.getPickListValuesForDisposition';
import createCallLog from '@salesforce/apex/CallLogController.createCallLog'
import checkAccount from '@salesforce/apex/CallLogController.checkAccount'
import getPickListValuesForCallCategory from '@salesforce/apex/CallLogController.getPickListValuesForCallCategory';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValuesForSubject from '@salesforce/apex/CallLogController.getPickListValuesForSubject';
import getPickListValuesForCallType from '@salesforce/apex/CallLogController.getPickListValuesForCallType';

export default class CallLogButton extends LightningElement {
    
    @api recordId;
    @track message = '';
    @track subjects ;
    //  = [
    //     { label: '--None--', value: '' },
    //     { label: 'Call', value: 'Call' },
    //     { label: 'Send Letter', value: 'Send Letter' }, 
    //     { label: 'Send Quote', value: 'Send Quote' }, 
    //     { label: 'Other', value: 'Other' }
    // ];

    @track callCategories ;
    // = [
    //     { label: '--None--', value: '' },
    //     { label: 'Academics', value : 'Academics'},
    //     { label: 'Admissions', value: 'Admissions' },
    //     { label: 'Logistics', value: 'Logistics' },
    //     { label: 'Student Support', value: 'Student Support' },
    //     { label: 'Examination - Internal Assignment', value: 'Examination - Internal Assignment' }, 
    //     { label: 'Examination - TEE', value: 'Examination - TEE' },
    //     { label: 'Portal Support', value: 'Portal Support' },  
    //     { label: 'Others', value: 'Others' }
    // ];

    @track dispositions = [];
    @track callTypes ;
    // = [
    //     { label: '--None--', value: '' },
    //     { label: 'Inbound Call', value: 'Inbound Call' },
    //     { label: 'Outbound Call', value: 'Outbound Call' }
    // ];
    @track objCase = {
        Subject: '',
        Description: '',
        Call_Category__c: '',
        Disposition__c: '',
        Call_Type__c: ''
    };
  
    @track showSpinner = true;
    @track showMessage = false;
    @track showToast = false;

    @wire(checkAccount, { recordIdValue: '$recordId' })
		wireCheckAccount({ error, data }) {
            if (data && this.recordId != undefined) {
				console.log('Program '+data);
                        this.showSpinner = false;
                        console.log(data); 
                    }
            else if(!data){                   
                        console.log(data);
                        const evt = new ShowToastEvent({
                            title: 'Error loading',
                            message: 'No Account found.',
                            variant: 'error'
                        });
                        this.dispatchEvent(evt);
                        this.dispatchEvent(new CloseActionScreenEvent()); 
                    }
            else if(error){
				console.log(error);
                const evt = new ShowToastEvent({
                    title: 'Error loading',
                    message: error,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent()); 
            }
      	}

        @wire(getPickListValuesForCallCategory)
        wireCallCategory({ error, data })
        {
            if(data){                   
                console.log(data);
                this.callCategories = [{ label: '--None--', value: '' }];
                for (let i = 0; i < data.length; i++) {
                    this.callCategories = [...this.callCategories, { label:data[i],value:data[i] }];
                    //console.log(this.callCategories);
                }
            }
            else if(error){
                console.log(error);
            }
        }
        @wire(getPickListValuesForCallType)
        wireCallType({ error, data })
        {
            if(data){                   
                console.log(data);
                this.callTypes = [{ label: '--None--', value: '' }];
                for (let i = 0; i < data.length; i++) {
                    this.callTypes = [...this.callTypes, { label:data[i],value:data[i] }];
                    //console.log(this.callCategories);
                }
            }
            else if(error){
                console.log(error);
            }
        }
        @wire(getPickListValuesForSubject)
        wireSubject({ error, data })
        {
            if(data){                   
                console.log(data);
                this.subjects = [{ label: '--None--', value: '' }];
                for (let i = 0; i < data.length; i++) {
                    this.subjects = [...this.subjects, { label:data[i],value:data[i] }];
                    //console.log(this.callCategories);
                }
            }
            else if(error){
                console.log(error);
            }
        }

        

    handleChangeSubject(event) {
        this.objCase.Subject = event.target.value;
        console.log(JSON.stringify(this.objCase));
    }
    handleChangeDescription(event) {
        this.objCase.Description = event.target.value;
        console.log(JSON.stringify(this.objCase));
    }
    handleChangeDisposition(event) {
        this.objCase.Disposition__c = event.target.value;
        console.log(JSON.stringify(this.objCase));
    }
    handleChangeCalltype(event) {
        this.objCase.Call_Type__c = event.target.value;
        console.log(JSON.stringify(this.objCase));
    }
    handleChangeCallCategory(event) {
        this.objCase.Call_Category__c = event.target.value;
        this.dispositions = [{ label: '--None--', value: '' }];
        console.log(JSON.stringify(this.objCase));
  
        getPickListValuesForDisposition({ callCategory :this.objCase.Call_Category__c}).then(result => {
            console.log('result' + result);
			for (let i = 0; i < result.length; i++) {
				this.dispositions = [...this.dispositions, { label:result[i],value:result[i] }];
				//console.log(this.dispositions);
			}
		})
        .catch(error => {
            console.log(error);
        });
    }
    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent()); 
    }
 
    handleSubmit(){
        this.showSpinner = true;
        console.log('recordId : ',this.recordId);
        createCallLog({recordId : this.recordId, objTask : this.objCase}).then(result =>{
            if(result)
                {
                    console.log(result);
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'record saved successfully.',
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                    setTimeout(() => {
                        this.dispatchEvent(new CloseActionScreenEvent()); 
                        },5); 
                }else{
                   console.log(result); 
                const evt = new ShowToastEvent({
                    title: 'Failed',
                    message: 'record not saved',
                    variant: 'warning'
                });
                this.dispatchEvent(evt);
               
                   setTimeout(() => {
                       this.dispatchEvent(new CloseActionScreenEvent()); 
                     },5);
                }
        }).catch(error =>{
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'Error loading',
                message: 'error occurred',
                variant: 'error'
            });
            this.dispatchEvent(evt);
            setTimeout(() => {
                this.dispatchEvent(new CloseActionScreenEvent()); 
              },5);
        });

    }
    
    
}