import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import { getRecord } from 'lightning/uiRecordApi';
import CreatedById from '@salesforce/schema/Case.CreatedById';
import Expected_Close_Date__c from '@salesforce/schema/Case.Expected_Close_Date__c';
import CreatedDate from '@salesforce/schema/Case.CreatedDate';
import RecordTypeName from '@salesforce/schema/Case.RecordType.Name';
import Escalation_Level__c from '@salesforce/schema/Case.Escalation_Level__c';
import InternalCategory__c from '@salesforce/schema/Case.InternalCategory__c';
import CASE_STATUS_FIELD  from '@salesforce/schema/Case.Status';
import getEscalateCase from '@salesforce/apex/EscalationLevelController.EscalateCase';
import { CloseActionScreenEvent } from 'lightning/actions';
import Name from '@salesforce/schema/User.Name';
import LightningConfirm from 'lightning/confirm';

export default class CaseEscalation extends LightningElement {
@api recordId;
@track showSpinner = true;
@track userName = '';

@wire(getRecord,{ recordId: Id, fields: [Name] })
wirecurrentuser({error,data}){
    if(data){
        console.log('data :::: ',data);
        this.userName = data.fields.Name.value;
    }else if (error) {
        console.log(JSON.stringify(error));
    }
}

@wire(getRecord, { recordId: '$recordId', fields: [CreatedById,RecordTypeName,Expected_Close_Date__c,CreatedDate,Escalation_Level__c, InternalCategory__c, CASE_STATUS_FIELD ] })
async wireuser({ error, data }) {
    if (data) {
        var date = new Date();

        var resultCreatedDate = new Date(data.fields.CreatedDate.value);
        resultCreatedDate.setDate(resultCreatedDate.getDate() + 1);

        console.log('data :::: ',data);
        console.log('Id :::: ',Id);
        console.log('CreatedById :::: ',data.fields.CreatedById.value);
        console.log('ExpectedCloseDate :::: ',data.fields.Expected_Close_Date__c.value+'sdssssss: '+new Date(data.fields.Expected_Close_Date__c.value));  //only after 
        console.log('CreatedDate :::: ',data.fields.CreatedDate.value,'::::'+new Date(data.fields.CreatedDate.value)); //+24hrs
        console.log('data :::: ',data.fields.Escalation_Level__c.value);
        console.log('data :::: ',data.fields.InternalCategory__c.value);
        console.log('date :::: ',date);
        // console.log('date :::: ',date);

        // console.log('date :::: ',date.setDate(date.getDate()-1) );
        // console.log('date :::: ',data.fields.Expected_Close_Date__c.value < date);
        // console.log('date :::: ',date.setDate(date.getDate()-1) <= data.fields.CreatedDate.value);
        // console.log('date :::: ',date);
            if(data.fields.RecordType.displayValue != 'Internal Ticket')
            {
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'error, case cannot be escalated.',     
                    variant: 'warning'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
                return;
            }
            if(data.fields.Status.value === 'Closed')
                {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'error, case is closed, cannot be escalated.',     
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    return;
                }
            if (data.fields.CreatedById.value != Id )
                {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'You are not authorized to Escalate this case. Only ' + this.userName  + ' can do so.',     
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.showSpinner = false;
                    return;
                }
            if( date <= resultCreatedDate) //data.fields.CreatedDate.value
                {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'error case can be escalated after 24hrs.',     
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    return;
                }
            if (data.fields.Escalation_Level__c.value != null && data.fields.Escalation_Level__c.value == this.map[data.fields.InternalCategory__c.value])
                {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Maximum escalation level, cannot be escalated.',     
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.showSpinner = false;
                    return;
                }
            if( data.fields.Expected_Close_Date__c.value != null && new Date(data.fields.Expected_Close_Date__c.value) > date )
                {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'error, case can be escalated after expected closed date.',     
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    return;
                }
            else{

                let flag = await this.showConfirmation();
                if(flag == false)
                {
                    return;
                }
                var EscalationLevelValue =  data.fields.Escalation_Level__c.value != null ?  data.fields.Escalation_Level__c.value : 0;
                var CategoryEsclevelValue = this.map[data.fields.InternalCategory__c.value];
                var resultDate = new Date();
                resultDate.setDate(resultDate.getDate() + 2);

                console.log('caseId :'+ this.recordId+' EscalationLevelValue :'+EscalationLevelValue+' CategoryEsclevelValue: '+CategoryEsclevelValue + ' resultDate : '+resultDate);

                getEscalateCase({caseId : this.recordId, EscalationLevel : EscalationLevelValue, ECDDate : resultDate , CategoryEsclevel : CategoryEsclevelValue}).then(result=>{
                    if(result)
                    {
                        console.log('getEscalateCase ------> result :: '+result);
                        const evt = new ShowToastEvent({
                            title: 'success',
                            message: result,     
                            variant: 'success'
                        });
                        this.dispatchEvent(evt);
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.showSpinner = false;
                        location.reload();
                    }
                }).catch(error=>{
                    console.log(error.message);
                })
            }
            
    } else if (error) {
        console.log(JSON.stringify(error));
    }
}

    async showConfirmation() {
    let action = 'escalate';
    let result = await LightningConfirm.open({
        title: `Confirm '${action}' Case`,
        message: `Are you sure you want to '${action}' the case?`,
        variant: 'headerless',
        label: `'${action}' Case Confirmation`,
    });

    if (result) {
        console.log('result ::: '+result);
        return true;
    } else {
        console.log('result ::: '+result);
        this.dispatchEvent(new CloseActionScreenEvent());
        return false;
    }
}
    //Category Levels
     map = {
        'LC Mumbai': 4,
        'LC Lucknow': 4,
        'LC Hyderabad': 4,
        'LC Chennai': 4,
        'LC Bangalore': 4,
        'LC Indore': 4,
        'LC Ahmedabad': 4,
        'LC Pune': 4,
        'LC Kolkata': 4,
        'LC Delhi': 4,
        'LC Chandigarh': 4,
        'Marketing': 3,
        'TEE': 3,
        'Internal Exam': 3,
        'Academics': 3,
        'Student Support': 3,
        'Finance': 3,
        'Product': 2,
        'Admissions': 3,
        'Career Services': 3,
        'Logistics': 3
    };
    
}