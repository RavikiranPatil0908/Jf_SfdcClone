import { LightningElement, api, wire, track } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import getLeadsforRefresh from '@salesforce/apex/salesCadenceController.getLeadsforRefresh';

export default class WorkQueue extends LightningElement {

    enableFilter = false;
    @api lstLeads;
    @track lstLeadsClone;
    @wire(CurrentPageReference) pageRef;
    @track chooseLeadStatus;
    @track chooseProgramList;
    @track filteredLeads;
    get statusFilterOptions() {
        return [
            { label: "--None--", value: "" },
            { label: "Not Contacted", value: "Not Contacted" },
            { label: "Reborn", value: "Reborn" }
        ];
    }
    get chooseProrgramFilterOptions() {
        return [
            { label: "--None--", value: "" },
            { label: 'Certificate Programs', value: 'Certificate Programs' },
            { label: 'Diploma Programs', value: 'Diploma Programs' },
            { label: 'Post Graduate Diploma Programs', value: 'Post Graduate Diploma Programs' },
            { label: 'Professional Programs', value: 'Professional Programs' },
            { label: 'Master Programs', value: 'Master Programs' },
            { label: 'Bachelor Programs', value: 'Bachelor Programs' }
        ];
    }

    handleClick(event) {
        // event.preventDefault();
        let field = event.currentTarget.dataset.id;
        let eventType = event.target.dataset.type;
        console.log('field value ' + field);
        console.log('eventType value ' + eventType);
        //console.log('Leads '+JSON.stringify(this.lstLeads));
        let lead = this.lstLeads.filter(function (entry) { return entry.Id === field; });
        if(lead.length > 0){ 
            lead = lead[0];
            console.log('lead=====>');
            console.log(lead);
            const selectedEvent = new CustomEvent('selected', { detail: lead.Id });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
    }

    toggleFilter() {
        this.enableFilter = !this.enableFilter;
    }

    getRefreshLeads(){
        getLeadsforRefresh()
            .then((response) => {
                console.log('refersh response ==>');
                console.log(response);
                let updatedEvent = {
                    'leads' : response,
                    'id' : null
                };
                if (response) {
                    this.chooseLeadStatus = '';
                    this.chooseProgramList = '';
                    // this.lstLeads = response;
                    fireEvent(this.pageRef, 'refreshLeadChangeEvent', updatedEvent);
                }
            })
            .catch((error) => {
                console.log('error occured ...'+error.body.message);
                // this.showHtmlMessage('Error !', error.body.message, 'error');
            });
    }
    
    handleChange(event){
        var eventName = event.target.dataset.id;
        console.log("eventName" + eventName);
        if(eventName === "status"){
            this.chooseLeadStatus = event.target.value;
        }else if(eventName === "chooseProgram"){
            this.chooseProgramList = event.target.value;
        }   
        if(this.chooseLeadStatus || this.chooseProgramList){
            this.filerLeads();
        }
    }

    get leads() {
        return this.chooseLeadStatus || this.chooseProgramList ? this.filteredLeads : this.lstLeads;
    }

    filerLeads(){

        var leads = this.lstLeads;
        var statusfilterCriteria = this.chooseLeadStatus;
        var chooseProgramFilterCriteria = this.chooseProgramList;
        this.filteredLeads='';
        console.log("statusfilterCriteria " + statusfilterCriteria +" chooseProgramFilterCriteria "+chooseProgramFilterCriteria);
        console.dir(leads);
        var result = leads.filter(function (lead) {
            if (statusfilterCriteria && (chooseProgramFilterCriteria === undefined || chooseProgramFilterCriteria === '') && lead.Status){
                return lead.Status == statusfilterCriteria;
            }else if(chooseProgramFilterCriteria && (statusfilterCriteria === undefined || statusfilterCriteria === '') && lead.nm_ChooseaProgram__c){
                return lead.nm_ChooseaProgram__c == chooseProgramFilterCriteria;
            }else if(statusfilterCriteria && chooseProgramFilterCriteria && lead.Status && lead.nm_ChooseaProgram__c){
                return (lead.Status == statusfilterCriteria && lead.nm_ChooseaProgram__c == chooseProgramFilterCriteria);
            }
        });
        console.dir(result);
        this.filteredLeads = result;
        return result;
    }

    // sendOpenEvent = () => {
    //     fireEvent(this.pageRef, "toggleCallPanel", "open");
    // }
}