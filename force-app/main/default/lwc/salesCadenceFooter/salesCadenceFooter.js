import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import getLeadRecord from '@salesforce/apex/salesCadenceController.getLeadRecord';
import getLeadsforRefresh from '@salesforce/apex/salesCadenceController.getRefershRecord';
import updateDescription from '@salesforce/apex/salesCadenceController.updateDescription';

export default class SalesCadenceFooter extends LightningElement {
    event = '';
    callVal = '';
    historyVal = '';
    @track comment;
    @track hasRendered = 'load';
    @track lead;
    @track leadDescription;
    @track showPopup = { title: '', message: '', variant: '' };
    @api recordId;
    @wire(CurrentPageReference) pageRef;

    @wire(getLeadRecord,{recordId:'$recordId'})
    getLeadRecord({ error, data}) {
        if(data) {
            this.lead = data;
            this.hasRendered = 'reload';
            this.leadDescription = this.lead.Description;
            console.log(this.lead);
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        registerListener("toggleCallPanel", this.toggleCallPanel, this);
        // registerListener("refreshLeadChangeEvent", this.refreshLead, this);
    }
     
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    // for to toggle the class.
    get callBarItemClass() {
        return this.event === 'call' ? 'slds-utility-bar__item slds-utility-bar__item_pop-out' 
        : 'slds-utility-bar__item';
    }

    get historyBarItemClass() {
        return this.event === 'history' ? 'slds-utility-bar__item slds-utility-bar__item_pop-out' 
        : 'slds-utility-bar__item';
    }

    // for to toggle the class.
    get togglePhone() {
        return this.event === 'call' ? true : false;
    } 

    get toggleHistory() {
        return this.event === 'history' ? true : false;
    }
    
    get isEmpty() {
        // return this.recordId ? false : true;
        return false;
    }

    handleEventClick = (event) => {
        let key = event.currentTarget.dataset.key;
        if(key === 'call') {
            // this.sendOpenEvent();
            this.event = key;
            this.callVal = 'open';
        } else if(key === 'history') {
            this.event = key;
            this.historyVal = 'open';
        } 
    }
    
    toggleCallPanel() {
        this.event = 'call';
        this.callVal = 'open';
    }

    handleChange(event) {
        // on chnage for history Panel
        if(event.detail.panel === 'history') {
            if(event.detail.check === 'closed'){
                this.dateFilterSelection = event.detail.check;
                this.event = '';
                this.historyVal = '';
            } else if(event.detail.check === 'loaded') {
                this.hasRendered = 'loaded';
            } 
            else if(event.detail.check === 'update') {
                this.comment = event.detail.comment;
                this.save();
            }
        } else if(event.detail.panel === 'call') {
            if(event.detail.check === 'closed'){
                // this.dateFilterSelection = event.detail.check;
                this.event = '';
                this.callVal = '';
            } else if(event.detail.check === 'update') {
                this.comment = event.detail.comment;
                this.save();
            }
        }
        
    }

    save() {
        // const recordId = this.lead.Id;
        updateDescription({ leadId: this.recordId, comment: this.comment})
            .then(result => {
                if(result) {
                    this.showHtmlMessage('Success!!', 'Updated Successfully!', 'success');
                    this.refreshLead();
                }
            })
            .catch(error => {
                console.log(error.body.message);
                this.showHtmlMessage('Error !', error.body.message, 'error');
            });
    }


    refreshLead(){
        getLeadsforRefresh({recordId: this.recordId})
            .then((response) => {
                console.log('refresh method called');
                console.log(response);
                this.lead = response;
                this.hasRendered = 'reload';
                this.leadDescription = this.lead.Description;
                console.log('record found');
                this.template.querySelector("c-utility-history-panel").setDescription(this.lead.Description);
            })
            .catch((error) => {
                this.showHtmlMessage('Error !', error.body.message, 'error');
            });
    }

    // To show Toast message
    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }

    // to open Phone Panel.
    // sendOpenEvent(){
    //     fireEvent(this.pageRef, "toggleCallPanel", "open");
    // }
}