import { LightningElement, api, wire, track } from 'lwc';
import getPersonAccountDetails from '@salesforce/apex/PersonAccountDetailsController.getPersonAccountDetails';

export default class PersonAccountDetails extends LightningElement {
    @api recordId;
    @track records = [];
    @track dataLoading = true;
    @track hasData = false;

    @wire(getPersonAccountDetails, { recordId: '$recordId' })
    wiredPersonAccountDetails({ error, data }) {
        console.log('==>'+JSON.stringify(data));
        if (data) {
            if (data.length > 0) {
                this.records = data;
                this.hasData = true;
            } else {
                this.hasData = false;
            }
            this.dataLoading = false;
        } else if (error) {
            console.error(error);
            this.dataLoading = false;
        }
    }
}