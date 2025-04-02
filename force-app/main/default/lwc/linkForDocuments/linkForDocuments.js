import { api, LightningElement, track, wire } from 'lwc';
import fetchRecords from '@salesforce/apex/purchaseLicenseForAEPController.getArchiveLinkforDocuments';

export default class LinkForDocuments extends LightningElement {
    @api recordId;
    @api experience = 'lightning';
    @api records = [];
    hasData = false;

    @track DataLoading = true;

    get isClassic() {
        if(this.experience === 'classic') {
                return true;
        }
        return false;
    }
    @wire(fetchRecords, { parentId: '$recordId' })
    getArchiveLinkDocsList({ error, data }) {
        if (data) {
            if (typeof data !== 'undefined' && data.length > 0) {
                data.forEach(element => {
                // looping the i varibale till 20 because of 20 fields in Document name, Document status and URL For documents
                    for(let i=1;i<20;i++){
                        let linkId = i;
                        if(element[`Document_Name_${i}__c`] === undefined){
                            return;
                        }
                        
                        // update Old URL to new URL
                        let Uri = this.replaceOldURL(element[`URL_for_Documents${i}__c`]);
                        let hasLink = Uri ? true : false;
                        let objLinkDoc = {
                            DocumentName : element[`Document_Name_${i}__c`],
                            DocumentLink : Uri,
                            DocumentStatus : element[`Document_Status_${i}__c`]
                        }
                        
                        this.records.push({ value: objLinkDoc, key: linkId, hasLink :hasLink});
                    }
                });
                console.log(JSON.stringify(this.records));
                // console.log('Data '+JSON.stringify(data));
                this.hasData = true;
                this.DataLoading = false;
            }else{
                this.hasData = false;
                this.DataLoading = false;
            }
        } else if (error) {
                console.error(error);
                this.DataLoading = false;
        }
        console.log('recordId ==>'+this.recordId);
        console.log(this.experience);
    }

    replaceOldURL(Uri) {
        if(Uri) {
            Uri = Uri.includes('admissions-ngasce.nmims.edu:4001') ? Uri.replace(/(http:|)(^|\/\/)(.*?\/)/g, 'https://studentzone-ngasce.nmims.edu/') : Uri;
        }
        return Uri;
    }
}