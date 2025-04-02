import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import updateCaseStatus from '@salesforce/apex/CaseController.updateCaseStatus';
import LightningAlert from 'lightning/alert';
import LightningConfirm from 'lightning/confirm';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_CLOSE_DATETIME from '@salesforce/schema/Case.ClosedDate';
import CASE_RECORDTYPE_NAME from '@salesforce/schema/Case.RecordType.Name';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CaseReOpenClose extends NavigationMixin(LightningElement) {
    @api recordId;
    @track previousStatus = '';
    @track showSpinner = false;
    @track showPop = false;
    @track isUploadFile = false;
    @track todayDate = new Date();
    @track message;
    @track filesUploaded = [];
    @track updatedStatus = '';
    @track objCase = { Case_Comment__c: '' };
    

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx'];
    }

    @wire(getRecord, { recordId: '$recordId', fields: [CASE_RECORDTYPE_NAME, CASE_STATUS, CASE_CLOSE_DATETIME] })
    wiredCase({ error, data }) {
        this.showSpinner = true;
        if (data) {
            this.showSpinner = false;
            const recordTypeName = getFieldValue(data, CASE_RECORDTYPE_NAME);
            const statusValue = getFieldValue(data, CASE_STATUS);
            this.previousStatus = statusValue;
            const CaseClosedDateTime = getFieldValue(data, CASE_CLOSE_DATETIME);
            const updatedCaseClosedDate = new Date(CaseClosedDateTime);
            updatedCaseClosedDate.setDate(updatedCaseClosedDate.getDate() + 7);
            const reOpenAllowDate = new Date(updatedCaseClosedDate.setHours(0, 0, 0, 0));
            const normalizedTodayDate = new Date(this.todayDate.setHours(0, 0, 0, 0));

            if (recordTypeName !== 'Internal Ticket') {
                this.ValidateRecordType();
                return;
            }

            if (CaseClosedDateTime && (reOpenAllowDate < normalizedTodayDate)) {
                this.showMessage('The Case can be Re-Opened only within 7 days from the case Closure date.', 'warning', 'Alert');
                this.closeScreen();
            } else {
                if (!this.showPop) {
                    this.showConfirmation();
                }
            }
        } else if (error) {
            this.showSpinner = false;
            console.error('Error fetching case record:', error);
        }
    }

    ValidateRecordType() {
        const evt = new ShowToastEvent({
            title: 'Validation error',
            message: 'This action is only allowed for "Internal Ticket" Record Type.',
            variant: 'warning'
        });
        this.dispatchEvent(evt);
        this.closeScreen();
    }

    async showConfirmation() {
        let action = this.previousStatus === 'Closed' ? 'Re-Open' : 'Close';
        let result = await LightningConfirm.open({
            title: `Confirm '${action}' Case`,
            message: `Current status of your case is '${this.previousStatus}'. Are you sure you want to '${action}' the case?`,
            variant: 'headerless',
            label: `'${action}' Case Confirmation`,
        });

        if (result) {
            this.updatedStatus = action === 'Re-Open' ? 'Re-Open' : 'Closed';
            this.showPop = true;
            this.showForm = true;
        } else {
            this.closeScreen();
        }
    }

    async handleSubmit() {
        this.showSpinner = true;
        try {
            if (this.isEmpty(this.objCase.Case_Comment__c)) {
                this.showMessage('Please add the reason to Close/Re-Open Case.', 'error', 'Fields Incomplete!');
                return;
            }
            if (this.isUploadFile && this.filesUploaded.length === 0) {
                this.showMessage("Please attach at least one file.", 'error', 'File Missing');
                return;
            }
            const msg = await this.updateStatus();
            if (msg !== 'Success') {
                this.showMessage(msg, 'error', 'Error!');
                return;
            }

            if (this.isUploadFile && this.filesUploaded.length > 0) {
            let isSuccess =await this.attachFiles();
               if(isSuccess){
                this.showMessage('Status updated successfully. Files attached successfully.', 'success', 'Success');
                this.handleNavigate('success');
                return;
               }
            } else {
                this.showMessage('Status updated successfully.', 'success', 'Success');
                this.handleNavigate('success');
                return;
            }

           
        } catch (error) {
            this.showMessage(error.message, 'error', 'Error!');
        } finally {
            this.showSpinner = false;
        }
    }

    async updateStatus() {
        return await updateCaseStatus({
            caseId: this.recordId,
            status: this.updatedStatus,
            comment: this.objCase.Case_Comment__c,
            prevStatus: this.previousStatus
        });
    }

    async attachFiles() {
        return await uploadFiles({ files: this.filesUploaded, caseId: this.recordId });
    }

    handleRemove(event) {
        let title = event.target.dataset.fid;
        this.filesUploaded = this.filesUploaded.filter(file => file.Title !== title);
    }

    handleCheckChange(event) {
        this.isUploadFile = event.target.checked;
        if (!this.isUploadFile && this.filesUploaded.length > 0) {
            this.filesUploaded = [];
        }
    }

    handleChange(event) {
        this.objCase[event.target.dataset.field] = event.target.value;
        console.log(this.objCase[event.target.dataset.field]);
    }

    handleError() {
        this.showSpinner = false;
        console.error('Error: ', this.errorMsg);
        this.showMessage(this.errorMsg, 'error', 'Error!');
    }

    handleCancel() {
        this.closeScreen();
    }

    handleFileUploaded(event) {
        this.fileUploadError = '';
        const promises = [];
        if (event.target.files.length > 0) {
            for (let i = 0; i < event.target.files.length; i++) {
                let file = event.target.files[i];
                if (file.size > (3 * 1024 * 1024)) {
                    this.fileUploadError = 'File size exceeds the limit';
                    continue;
                }
                const promise = new Promise((resolve, reject) => {
                    let reader = new FileReader();
                    reader.onload = () => {
                        let base64 = 'base64,';
                        let content = reader.result.indexOf(base64) + base64.length;
                        let fileContents = reader.result.substring(content);
                        var extension = file.name.split('.');
                        if (!this.acceptedFormats.includes('.' + extension[extension.length - 1])) {
                            this.fileUploadError = 'Select file with valid extension';
                            reject(new Error('Invalid extension'));
                        } else {
                            this.filesUploaded.push({ PathOnClient: file.name, Title: file.name, VersionData: fileContents });
                            resolve();
                        }
                    };
                    reader.readAsDataURL(file);
                });
                promises.push(promise);
            }
            Promise.all(promises).then(() => {
                console.log('All files processed');
            }).catch(error => {
                console.error('Error processing files:', error);
            });
        }
    }

    closeScreen() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showMessage(msg, theme, label) {
        const evt = new ShowToastEvent({
            title: label,
            message: msg,
            variant: theme
        });
        this.dispatchEvent(evt);
    }

    isEmpty(val) {
        return !val || val.trim().length === 0;
    }

    handleNavigate(status) {
        if (status === 'success') {
            location.reload();  // Update this for better UX later
        }
    }
}