import { LightningElement, api, wire, track } from 'lwc';
//import { NavigationMixin } from 'lightning/navigation';
import getOpportunityLineItems from '@salesforce/apex/OpportunityLineItemDataTableController.getOpportunityLineItems';

export default class OpportunityLineItemDataTable extends LightningElement {
    @api recordId;
    @track records;
    @track dataLoading = true;
    @track hasData = false;

    @wire(getOpportunityLineItems, { opportunityId: '$recordId' })
    wiredOpportunityLineItems({ error, data }) {
        if (data) {
            if (data.length > 0) {
               // Map product names to records
               this.records = data.map(item => ({
                ...item,
                productName: item.Product2.Name,
                ActualSalePrice__c: item.ActualSalePrice__c.toFixed(2),
                UnitPrice: item.UnitPrice.toFixed(2)
            }));
                this.hasData = true;
            } else {
                this.hasData = false;
            }
            this.dataLoading = false;
        } else if (error) {
            console.error('Error fetching opportunity line items: ', error);
            this.dataLoading = false;
        }
    }
}