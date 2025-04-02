/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import searchVendor from '@salesforce/apex/SforceOpportunityRevisedController.searchVendor';

export default class OpportunitySearchComponent extends LightningElement {
    @track emailId;
    @track password;
    @track checkValidVendor = false;
    @track showLoginPanel = true;
    @track informationCenter;
    @track showPopup = { title: '', message: '', variant: '' };
    @api centerId;

    handleName(event){
        if(event.target.name === 'emailId'){
            this.emailId = event.target.value;
        }else if(event.target.name === 'password'){
            this.password = event.target.value;
        }
    }
    
    searchCenter(){
        searchVendor({emailId : this.emailId,password : this.password})
        .then(result => {
            this.informationCenter = result;
            this.centerId = this.informationCenter.Id;
            console.log(this.informationCenter);
            this.checkValidVendor = true;
            this.showLoginPanel = false;
        })
        .catch(error => {
            console.log("error", error);
            this.showHtmlMessage('Invalid Credentials!','Please enter a valid EmailId and Password.','error');
            this.checkValidVendor = false;
            this.showLoginPanel = true;
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