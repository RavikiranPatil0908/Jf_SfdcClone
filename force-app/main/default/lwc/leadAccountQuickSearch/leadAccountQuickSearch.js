import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import searchRecords from '@salesforce/apex/QuickSearchController.searchRecords';
import Id from '@salesforce/user/Id';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import SalesforceBaseUrl from '@salesforce/label/c.SalesforceBaseUrl';
import lightningSiteUrl from '@salesforce/label/c.lightningSiteUrl';
import communityURL from '@salesforce/label/c.communityURL';

export default class LeadAccountQuickSearch extends LightningElement {
    @api experience;
    @track searchKey = '';
    @track results;
    @track error;
    isFocus = false;    
    isAEP = false; 
    isRecordFound = true;

    columns = [
        {
            label: 'Name',
            fieldName: 'recordUrl',
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
        },
        { label: 'Email', fieldName: 'email', type: 'text' },
        { label: 'Secondary Email', fieldName: 'secondaryEmail', type: 'text' },
        { label: 'Mobile Phone', fieldName: 'mobilePhone', type: 'text' },
        { label: 'Phone', fieldName: 'phone', type: 'text' },
        { label: 'Registration No', fieldName: 'RegistrationNo' },
        { label: 'Object Type', fieldName: 'objectType' }
    ];
 
    @wire(getRecord, { recordId: Id, fields: [PROFILE_NAME] })
    wireuser({ error, data }) {
        if (data) {
            if (data.fields.Profile.value.fields.Name.value === 'Information Center Partner Community User') {
                this.isAEP = true;
            }
            console.log("is AEP:" + this.isAEP);
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    get popoverClass() {
        return this.isFocus ?  
        'slds-popover slds-popover_tooltip slds-nubbin_top-left slds-is-absolute slds-m-top_x-small tooltip slds-rise-from-ground' :
        'slds-popover slds-popover_tooltip slds-nubbin_top-left slds-is-absolute slds-m-top_x-small tooltip slds-fall-into-ground';
    }

    get isClassic() {
        console.log("is Classic:" + this.experience);
        return this.experience === 'classic' ? true : false;
    }
      
    get baseURL() {
        let baseURL;
        console.log("is classic URL" + this.isClassic);
        console.log("is Aep" + this.isAEP);
        if (this.isAEP) {
            baseURL = window.location.origin;
        } else {
            baseURL = SalesforceBaseUrl;
        }
        return baseURL;
    }
    
    loadPopUp() {
        this.isFocus = true;
    }

    hidePopUp() {
        this.isFocus = false;
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        if (this.searchKey) {
            searchRecords({ searchText: this.searchKey })
                .then(data => {
                    console.log("Data: " + JSON.stringify(data));
                    if (data.length === 0) {
                        // No records found, show message
                        this.results = undefined;
                        this.isRecordFound = false;
                    } else {
                        this.results = data.map(result => {
                            const record = result.record;
                            console.log("Records: " + JSON.stringify(record));
                            const objectType = (result.objectType !== 'Lead' && result.objectType !== 'Account') ? 'Quick Leads' : result.objectType;
                            const url = this.baseURL + '/' + record.Id;
                            console.log("URL:::::" + url);
                            return {
                                recordId: record.Id,
                                Name: record.Name || (record.First_Name__c + ' ' + record.Last_Name__c),
                                RegistrationNo: record.nm_RegistrationNumber__c || record.nm_RegistrationNo__c,
                                email: record.Email__c || record.Email || record.PersonEmail,
                                secondaryEmail: record.nm_SecondryEmail__c || record.nm_SecondryEmail__c,
                                mobilePhone: record.MobilePhone || record.PersonMobilePhone || record.MOBILEPHONE__c,
                                phone: record.Phone,
                                objectType: objectType,
                                recordUrl: url
                            };
                        });
                        this.error = undefined;
                    }
                })
                .catch(error => {
                    this.results = undefined;
                    this.error = 'An error occurred while searching: ' + JSON.stringify(error);
                    console.error('Error:', error);
                });
        } else {
            this.results = undefined;
            this.isRecordFound = false;
        }
    }
}