import { LightningElement } from 'lwc';
import CaseConvert from '@salesforce/apex/ConvertCaseController.CaseConvert';

export default class ConvertToEnquiryComplain extends LightningElement {
		
		connectedCallback(){
				CaseConvert({ caseid: this.recordId, purpose: 'Enquiry'}).then(result => {
						alert('Feedback converted successfully.');						
      	})
      	.catch(error => {
						alert('Feedback conversion failed.');
						console.log(error);
				})
		}
}