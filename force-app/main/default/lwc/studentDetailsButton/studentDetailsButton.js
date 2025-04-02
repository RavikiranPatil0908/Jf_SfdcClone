import { LightningElement, api, wire } from 'lwc';
import getToken from '@salesforce/apex/AutoUpdateStateAndCountryWebService.getToken';
import getSapId from '@salesforce/apex/AutoUpdateStateAndCountryWebService.getSapId';
import { NavigationMixin } from 'lightning/navigation';
import StudentZoneBaseUrlLabel from '@salesforce/label/c.Student_Zone_Base_Url';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class StudentDetailsButton extends NavigationMixin(LightningElement) {
	@api recordId;
	sapId;
	urlToRedirect = StudentZoneBaseUrlLabel;

	connectedCallback() {
		// this.navigateToWebPage();
	}

	@wire(getSapId, { recordId: '$recordId' })
	getStudentNo({ error, data }) {
		if (data) {
			console.log('sapId '+data);
			this.sapId = data.includes("_") ? data.split("_")[1] : data;
			console.log('sapId '+this.sapId);
			this.getTokenVal();
		} else if (error) {
			console.error(error);
		}
	}

	navigateToWebPage() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.urlToRedirect
            }
        },
        false // Replaces the current page in your browser history with the URL
      	);
	  this.closeQuickAction();
    }
	
	
	
	getTokenVal(){
		getToken({sapId: this.sapId}).then(result => {
			result = encodeURIComponent(result);
			console.log('result ==>'+result);
			this.urlToRedirect = `${StudentZoneBaseUrlLabel}studentportal/viewStudentDetailsDashBoard?sapId=${this.sapId}&token=${result}`;
			console.log('url ==>'+this.urlToRedirect);
			this.navigateToWebPage();				
		})
		.catch(error => {
			console.log(error);
		});
	}

	closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}