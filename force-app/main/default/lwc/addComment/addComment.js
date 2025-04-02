import { LightningElement ,track ,wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import addComment from '@salesforce/apex/CaseController.AddComment';
import CASE_RECORDTYPE_NAME from '@salesforce/schema/Case.RecordType.Name';
import LightningAlert from "lightning/alert";
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class AddComment extends LightningElement {
@api recordId; 
@track Case_Comment;
@track filesUploaded = [];
@track isUploadFile = false;
@track errorMsg ;
fileUploadError='';
showSpinner = false; 

get acceptedFormats() {
    return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx'];
};

@wire(getRecord, { recordId: '$recordId', fields: [CASE_RECORDTYPE_NAME] })
async wiredCase({ error, data }) {
    this.showSpinner = true;
    if (data) {
        this.showSpinner = false;
        const recordTypeName = getFieldValue(data, CASE_RECORDTYPE_NAME);

        if (recordTypeName !== 'Internal Ticket') {
            await this.ValidateRecordType();
        }
    } else if (error) {
        this.showSpinner = false;   
        console.error('Error fetching case record:', error);
    }
}

async ValidateRecordType() {
    const evt = new ShowToastEvent({
        title: 'Validation error',
        message: 'This action is only allowed for "Internal Ticket" Record Type.',
        variant: 'warning'
    });
    this.dispatchEvent(evt);
    this.dispatchEvent(new CloseActionScreenEvent()); // close the action
    return;
}

handleChange(event){
    this.Case_Comment=event.target.value;
}

handleRemove(event){
    let title = event.target.dataset.fid;
    let index = this.filesUploaded.findIndex(obj => obj.Title === title);
    console.log(index);
    this.filesUploaded.splice(index, 1);
}

handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent()); 
}




handleCheckChange(event){
    this.isUploadFile = event.target.checked;
        if(!this.isUploadFile && this.filesUploaded.length > 0) {
			this.filesUploaded = [];
		}
}

isEmpty(str) {
    return (!str || str.length === 0 );
}

handleError() {
    this.showSpinner = false;
    console.error('Error: ', this.errorMsg);
    this.showMessage(this.errorMsg, 'error', 'Error!');
}

handleFileUploaded(event){
    this.fileUploadError = '';
    if (event.target.files.length > 0) {
        console.log(event.target.files);
        const MAX_FILE_SIZE = (3 * 1024 * 1024);
        for (let i = 0; i < event.target.files.length; i++) {
            let file = event.target.files[i];
            if (file.size > MAX_FILE_SIZE) {
                this.fileUploadError = 'File size exceeds the limit';
            } else {
                let reader = new FileReader();
                reader.onload = () => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    var extension = file.name.split('.');
                    if (!this.acceptedFormats.includes('.' + extension[extension.length - 1])) {
                        this.fileUploadError = 'Select file with valid extension';
                    } else {
                        this.filesUploaded.push({ PathOnClient: file.name, Title: file.name, VersionData: fileContents });
                    }
                };
                reader.readAsDataURL(file);
            }
        }
    }
}

async handleSubmit() {
    try {
        // Validate Form
        if(this.isEmpty(this.Case_Comment)) {
            this.showMessage('Please Fill all the mandatory details .', 'error', 'Fields Incomplete!');
            return;
        } 
        if(this.isUploadFile == true && this.filesUploaded.length === 0)
            {
                this.showMessage("Please attach at least one file.", 'error', 'File Missing');
                return;
            }
        this.showSpinner = true;   
        this.message = await this.addCaseComment();
        if(this.message !='Success') {
            this.handleError();
            return;
        }
         if(this.message ==='Success' && this.filesUploaded.length === 0){
            this.showMessage('Comment added successfully .', 'success', 'Success');
            this.msg = 'success';
             this.handleNavigate(this.msg);
         }
        this.handleSucces();
    } catch (error) {
        this.showSpinner = false;
        this.showMessage(error, 'error', 'Error!');
    }
}

async addCaseComment() {
    const msg = await addComment({ caseId:this.recordId,comment: this.Case_Comment})
    .then(result => {
        return result;
    })
    .catch(error => {
        console.log(error);
        // this.errorMsg = this.handleErrorResponse(error);
    });
    return msg;
}



async handleSucces() {
    // console.log('Record ID: ', this.record);
    console.log('is checked: ', this.isUploadFile);
    if(this.isUploadFile) {
        this.showSpinner = true;
        await this.attachFiles();
        this.showSpinner = false;
    } 
}

async attachFiles() {
    await uploadFiles({ files: this.filesUploaded, caseId: this.recordId })
        .then(result => {

            if (result === true) {
                this.showMessage('Comment and all Attachment files uploaded successfully','success', 'Success!');
                this.showUpload = false;
                this.msg ='success';
                this.handleNavigate(this.msg);
            }
        })
        .catch(error => {
            console.log(error);
        });
}

handleNavigate(msg) {
    if (msg === 'success') {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId:this.recordId,
                actionName: 'view'
            }
        });
    }
}

showMessage(msg, theme, label) {
    LightningAlert.open({
        message: msg,
        theme: theme,
        label: label,
        variant: 'header',
    });
}



}