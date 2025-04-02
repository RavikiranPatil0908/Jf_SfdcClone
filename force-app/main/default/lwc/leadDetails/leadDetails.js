import { LightningElement, track, api, wire } from 'lwc';
import getLeadsforRefresh from "@salesforce/apex/salesCadenceController.getLeadsforRefresh";
import updateLead from '@salesforce/apex/salesCadenceController.updateLead';
import getLeadRecord from '@salesforce/apex/salesCadenceController.getLeadRecord';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import { loadStyle } from 'lightning/platformResourceLoader';
import NewFormResource from '@salesforce/resourceUrl/NewFormResource';
import lightningSiteUrl from '@salesforce/label/c.lightningSiteUrl';
import communityURL from '@salesforce/label/c.communityURL';

export default class LeadDetails extends LightningElement {
    @api leadList;
    @api experience;
    @track leadListRecord;
    @track refreshLeads;
    @track Lead = { Next_Follow_up__c: '', Status: '', Lead_Description__c: ''};
    @track showPopup = { title: '', message: '', variant: '' };
    @track nextFollowUpDateTime;
    @wire(CurrentPageReference) pageRef;
    @track groupBtn = { refersh: false, edit: false};
    @track quickLeadFlag = false;
    @wire(getLeadRecord,{recordId:'$leadList'})
    getLeadRecord({ error, data}) {
        if(data) {
            console.log('leadListRecord '+JSON.stringify(data));
            this.leadListRecord = data;
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        Promise.all([ loadStyle(this, NewFormResource + '/css/inline.css') ]).then(() => {
			console.log('css loaded');
		});
    }

    // renderedCallback(){
    //     this.nextFollowUpDateTime = this.leadListRecord.Next_Follow_up__c;
    // }

    get isClassic() {
        return this.experience === 'classic' ? true : false;
    }
    
    get baseURL() {
        let baseURL = communityURL.includes(window.location.origin) ? communityURL : window.location.origin;
        if(!this.isClassic) {
            baseURL = `${lightningSiteUrl}s/detail`;
        }
        return baseURL;
    }

    handleChange(event) {

        var date = new Date();
        if (event.target.name === "leadstatus") {
            console.log('leadstatus ' + event.target.value);
            this.Lead.Status = event.target.value;
        } else if (event.target.name === "leadDescr") {
            console.log('leadDescr ' + event.target.value);
            this.Lead.Lead_Description__c = event.target.value;
        } else if (event.target.name === "nextFollowUp"){
            console.log(event.target.value)
            this.Lead.Next_Follow_up__c = event.target.value;
        }
    }

    save() {
        if(this.validateForm()) {
            return;
        }
        console.log('Lead ' + JSON.stringify(this.Lead));

        updateLead({ ld: this.Lead, ldId: this.leadListRecord.Id})
            .then(result => {
                this.showHtmlMessage('Success!!', 'Updated Successfully!', 'success');
                console.log("result =>" + JSON.stringify(result));
                this.getRefreshLeads();
            })
            .catch(error => {
                this.showHtmlMessage('Error !', error.body.message, 'error');
            });
    }

    validateForm() {
        
        let date = new Date();
        let nextFollowUpTimeHot  = (this.addDays(date, 3)).toISOString();
        let nextFollowUpTimeWarm = (this.addDays(date, 8)).toISOString();
        let nextFollowUpTimeNfu = (this.addDays(date, 15)).toISOString();
        let nextFollowUpTimeCold = (this.addDays(date, 30)).toISOString();
        let nextFollowUpTimeCallInfo = (this.addDays(date, 3)).toISOString();
        let nextFollowUpTimeFrozen = (date).toISOString();
        let nextFollowUpTimeNoRes = (this.addDays(date, 2)).toISOString();
        let nextFollowUpTimeFormFilled = (this.addDays(date, 5)).toISOString();
        let flag = false;

        console.log('Lead status ' + this.Lead.Status + ' Lead next follow up ' + this.Lead.Next_Follow_up__c + ' nextFollowUpTime ' + nextFollowUpTimeHot);
        if (this.Lead.Status === 'Hot' && this.Lead.Next_Follow_up__c > nextFollowUpTimeHot){
            flag = true;
        }else if(this.Lead.Status === 'Warm' && this.Lead.Next_Follow_up__c > nextFollowUpTimeWarm){
            flag = true;
        } else if (this.Lead.Status === 'Needs Follow Up' && this.Lead.Next_Follow_up__c > nextFollowUpTimeNfu) {
            flag = true;
        } else if (this.Lead.Status === 'Cold (within this drive)' && this.Lead.Next_Follow_up__c > nextFollowUpTimeCold) {
            flag = true;
        } else if ((this.Lead.Status === 'Ask to Call back' || this.Lead.Status === 'Ask for information')  && this.Lead.Next_Follow_up__c > nextFollowUpTimeCallInfo) {
            flag = true;
        } else if (this.Lead.Status === 'Frozen (next drive)' && this.Lead.Next_Follow_up__c < nextFollowUpTimeFrozen) {
            flag = true;
        } else if (this.Lead.Status === 'Phone Switched Off/Ringing/No Response' && this.Lead.Next_Follow_up__c > nextFollowUpTimeNoRes) {
            flag = true;
        } else if (this.Lead.Status === 'Registration Form Filled' && this.Lead.Next_Follow_up__c > nextFollowUpTimeFormFilled) {
            flag = true;
        } 

        if(flag) {
            this.template.querySelector("lightning-input-field[data-id=Next_Follow_up__c]").value = "";
            this.showHtmlMessage('Error !', 'Invalid Next follow up date time', 'error');
        }
        return flag;
    }

    getRefreshLeads(){
        getLeadsforRefresh()
            .then((response) => {
                console.log('response '+JSON.stringify(response));
                this.refreshLeads = response;
                let updatedEvent = {
                    'leads' : this.refreshLeads,
                    'id' : this.leadList.Id
                };
                if (this.refreshLeads) {
                    fireEvent(this.pageRef, 'refreshLeadChangeEvent', updatedEvent);
                }
            })
            .catch((error) => {
                // console.log('error occured ...'+error.body.message);
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

    addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }

    handleBtnClick(event) {
        let key = event.currentTarget.dataset.key;
        console.log('key ==>'+key);
        if(key === 'edit') {
            this.groupBtn.edit = !this.groupBtn.edit;
        }else if(key === 'redirectLead'){
            // window.open("https://sandbox-nga-sce.cs5.force.com/AEPorg/"+this.leadList, "_blank");
            window.open(`${this.baseURL}/${this.leadList}`, "_blank");
        }else if(key === 'quickLead'){
            this.quickLeadFlag = true;
            console.log("quickLeadFlag" +this.quickLeadFlag);
        }else{
            this.quickLeadFlag = false;
        }
        console.log('this.groupBtn.edit ==>'+this.groupBtn.edit)
    }

    handleCloseQuickLead(event){
        if(event.detail !== 1){
            if(event.detail === 'close'){
                this.quickLeadFlag = false;
            }
        }
    }

    clickToCall() {
        fireEvent(this.pageRef, "toggleCallPanel", "open");
    }
}