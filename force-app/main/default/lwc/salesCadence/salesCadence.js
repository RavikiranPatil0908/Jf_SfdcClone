import { LightningElement, api, wire, track } from 'lwc';
import getLeads from '@salesforce/apex/salesCadenceController.getLeads';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
export default class SalesCadence extends LightningElement {
    @api message;
    @api experience;
    @track leads;
    @track ldIdfound = false;
    @track updateLead;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        // subscribe to refreshLeadChangeEvent event
        registerListener('refreshLeadChangeEvent', this.handleChange, this);
    }
    disconnectedCallback() {
        // unsubscribe from refreshLeadChangeEvent event
        unregisterAllListeners(this);
    }
    handleChange(inputVal) {
        if(inputVal){
            this.leads = inputVal.leads;
        }
        console.log('handlechange pubsub....');
        let event = {};
        let ld = this.leads.filter(function (e) {
            return e.Id === inputVal.id;
        });
        event['detail'] = ld[0];
        this.handleRecordLoadLeads(event);
    }

    @wire(getLeads)
    getLeadDetails({ error, data }) {
        if (data) {
            this.leads = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleRecordLoadLeads(event) {
        this.ldIdfound = true;
        this.updateLead = event.detail;
    }


}