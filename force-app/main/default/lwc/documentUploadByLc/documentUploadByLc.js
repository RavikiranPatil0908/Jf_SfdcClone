/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 07--11--2024
 * @last modified by  : @Ravi
**/
import { LightningElement, track } from 'lwc';
import LightningAlert from "lightning/alert";
import { loadScript } from 'lightning/platformResourceLoader';
import SCRIPTS from '@salesforce/resourceUrl/Scripts';
import getAccountDetails from '@salesforce/apex/UploadDocumentByLcController.getAccountDetails';
import docUrl from '@salesforce/label/c.DOCUMENT_SERVER';


export default class DocumentUploadByLc extends LightningElement {
    @track sapId = '';
    @track uploadUrl;
    @track errorMessage;
    @track isUploading = false;
    @track modeOfUpload;
    @track studentName;
    @track studentNo;
    @track informationCenter;
    jQueryInitialized = false;

    uploadModes = [
        { label: 'None', value: '' },
        { label: 'Upload Gazetted / Notarized Document', value: 'Upload Gazetted / Notarized Document' },
        { label: 'Original Uploaded by LC', value: 'Original Uploaded by LC' },
    ];

    

    renderedCallback() {
        console.log('rendering');
        if (this.jQueryInitialized) {
            return;
        }
        this.jQueryInitialized = true;

        // Load the jQuery script
        loadScript(this, SCRIPTS + '/scripts/jquery-1.8.2.min.js')
            .then(() => {
                console.log('jQuery loaded successfully');
            })
            .catch(error => {
                console.error('Error loading jQuery', error);
            });
    }

    handlesapId(event) {
        console.log('handlesapId' + event.target.value);
        let Id =event.target.value
        this.sapId = Id.trim();
    }

    handleselectedMode(event) {
        console.log('handleselectedmode' + event.target.value);
        this.modeOfUpload =encodeURIComponent(event.target.value); 
    }

    restrictAlphabets(event) {
        const charCode = event.which ? event.which : event.keyCode;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }

    isEmpty(str) {
        return (!str || str.length === 0);
    }

    validateAndProceed() {
        if (this.isEmpty(this.sapId) || this.isEmpty(this.modeOfUpload)) {
            this.showMessage('Please fill all required fields', 'error', 'Error');
            return;
        }
        console.log('validateAndProceed' + this.sapId);
        getAccountDetails({ sapId: this.sapId })
            .then(studObject => {
                if (studObject) {
                    this.informationCenter = studObject.nm_Centers__r.Name;
                    this.studentName = studObject.Name;
                    this.studentNo = studObject.nm_StudentNo__c;
                    console.log('sapid ' + studObject.nm_StudentNo__c + ' name ' + studObject.Name);
                    this.uploadUrl = docUrl + 'uploadDocumentForm?accountId=' + studObject.Id.substring(0, 15) + '&uid=' + studObject.Id+'&mode='+this.modeOfUpload.replaceAll("%20","+");
                    console.log('uploadUrl ' +  this.uploadUrl);
                    // this.uploadUrl = docUrl + 'uploadDocumentForm?mode=' + this.modeOfUpload + '&id=' + studObject.Id;
                    this.errorMessage = '';
                } else {
                    this.showMessage('Invalid SAP ID. Please enter a valid SAP ID number.', 'error', 'Error');
                    this.uploadUrl = null;
                }
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                this.uploadUrl = null;
            });
    }

    backPress() {
        this.uploadUrl = null;
        this.sapId='';
        this.modeOfUpload='';

    }

    showMessage(msg, theme, label) {
        LightningAlert.open({
            message: msg,
            theme: theme,
            label: label
        });
    }
}