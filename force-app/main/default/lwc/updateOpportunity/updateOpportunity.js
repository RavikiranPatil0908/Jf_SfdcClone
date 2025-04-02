/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import updateOpportunity from '@salesforce/apex/SforceOpportunityRevisedController.updateOpportunity';

export default class UpdateOpportunity extends LightningElement {

    @api oppList;
    @track oppStatusOptions;
    @track oppDescrOption;
    @track OppDescField;
    @track message;
    @track error;
    @track opportunity = {Next_Follow_Up_Date_Time__c :'',Opportunity_Status__c:'',Opportunity_Description__c:'',DescriptionforOther__c:''}
    @track Descrother = false;
    @track showPopup = { title: '', message: '', variant: '' };
    @track eduvanz;

    connectedCallback(){
        console.log('oppList '+JSON.stringify(this.oppList));
        if(this.oppList.Loan_Type__c === 'EduVanz') {
            this.eduvanz = true;
        }else{
            this.eduvanz = false;
        }
    }

    handleName(event) {
        if(event.target.name === "OppStatus"){
            console.log('OppStatus '+event.target.value);
            this.opportunity.Opportunity_Status__c = event.target.value;
            
        }else if(event.target.name === "OppDescr"){
            console.log('OppDescr '+event.target.value);
            this.opportunity.Opportunity_Description__c = event.target.value;
            if(event.target.value === 'Others') {
                this.Descrother = true;
            }else{
                this.Descrother = false;
            }
        }else if(event.target.name === "followUpDateTime"){
            console.log('followUpDateTime '+event.target.value);
            this.opportunity.Next_Follow_Up_Date_Time__c = event.target.value;
        }else if(event.target.name === 'otherDescr'){
            console.log('otherDescr '+event.target.value);
            this.opportunity.DescriptionforOther__c = event.target.value;
        }
    }

    save() {
        console.log('opportunity '+JSON.stringify(this.opportunity));
        
        updateOpportunity({ opp : this.opportunity,oppId: this.oppList.Id})
            .then(result => {
                this.message = result;
                this.error = undefined;
                console.log("result =>"+JSON.stringify(this.message));
                this.showHtmlMessage('Success!!','Updated Successfully!','success');
                // const event = new CustomEvent('recordUpdate', {
				// 	detail: true
				// });
				// this.dispatchEvent(event);
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                console.log("error", JSON.stringify(this.error));
                this.showHtmlMessage('Error !',error.body.message,'error');
            });
    }

    // To show Toast message
	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
	}
}