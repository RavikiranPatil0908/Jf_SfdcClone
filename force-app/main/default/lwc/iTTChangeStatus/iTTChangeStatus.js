import { LightningElement, track, wire, api } from 'lwc';
import { getFieldValue } from 'lightning/uiRecordApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import updateCaseStatus from '@salesforce/apex/CaseController.updateCaseStatus';
import LightningAlert from "lightning/alert";
import Id from "@salesforce/user/Id";
import { getRecord } from 'lightning/uiRecordApi';
import recordUserId from '@salesforce/schema/Case.CreatedById';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';


export default class ITTChangeStatus extends NavigationMixin(LightningElement) {
    @api recordId;
    @track message;
    @track internalRecordTypeId;
    @track caseStatusPicklistValues;
    @track filesUploaded = [];
    @track StatusValues=[{ label: 'None', value: '' }, 
        {label: 'New', value: 'New' },
        {label: 'Escalated', value: 'Escalated' },
        {label: 'In Progress', value: 'In Progress' },
        {label: 'Response Received', value: 'Response Received' },
        {label: 'Internal Response Received', value: 'Internal Response Received' },
        {label: 'New Case', value: 'New Case' },
        {label: 'Repeat case', value: 'Repeat case' },
        ];
    @track objCase = {
        Status: '',
        Case_Comment__c: '',
        RecordTypeId: ''
    };

    get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx'];
	}

    isUploadFile = false;
    fileUploadError;
    prevStatusValue ='';
    showSpinner = false;

    @wire(getRecord, { recordId: '$recordId', fields: [recordUserId,'Case.RecordType.Name', CASE_STATUS] })
    wireuser({ error, data }) {
        this.showSpinner = true;   
        if (data) {
        
                if(data.fields.CreatedById.value == Id)
                { 
                    const evt = new ShowToastEvent({
                        title: 'Validation error',
                        message: 'You do not have permission to change the Status of your own case.',
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else{
                    this.prevStatusValue = getFieldValue(data,CASE_STATUS );
                    console.log('Status :::: ',this.prevStatusValue);
                    this.showSpinner = false;
                }
                
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }
    

    isEmpty(str) {
        return (!str || str.length === 0 );
    }

    async handleSubmit() {
        try {
            // Validate Form
            if(this.isEmpty(this.objCase.Status) || this.isEmpty(this.objCase.Case_Comment__c) 
                ) {
                this.showMessage('Please Fill all the mandatory details .', 'error', 'Fields Incomplete!');
                return;
            } 
            if(this.isUploadFile == true && this.filesUploaded.length === 0)
                {
                    this.showMessage("Please attach at least one file.", 'error', 'File Missing!');
                    return;
                }
            this.showSpinner = true;   
            this.message = await this.updateStatus();
            if(this.message !='Success') {
                this.handleError();
                return;
            }
             if(this.message ==='Success' && this.filesUploaded.length === 0){
                this.showMessage('Status Updated Successfully .', 'success', 'Success');
                this.msg = 'success';
                 this.handleNavigate(this.msg);
                //  location.reload();
             }
            this.handleSucces();
        } catch (error) {
            this.showSpinner = false;
            this.showMessage(error, 'error', 'Error!');
        }
    }

    async updateStatus() {

        console.log('call update status method from class',this.recordId,this.objCase.Status, this.objCase.Case_Comment__c, this.prevStatusValue);
        const msg = await updateCaseStatus({ caseId:this.recordId,status: this.objCase.Status,comment:this.objCase.Case_Comment__c, prevStatus:this.prevStatusValue})
        .then(result => {
            console.log('status change Succesfully ==>'+ result);
            return result;
        })
        .catch(error => {
            console.log(error);
            // this.errorMsg = this.handleErrorResponse(error);
        });
        return msg;
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

    handleFileUploaded(event) {
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

    async attachFiles() {
		await uploadFiles({ files: this.filesUploaded, caseId: this.recordId })
			.then(result => {

				if (result === true) {

                    this.showMessage('Comment and all Attachment files uploaded successfully','success', 'Success!');
					this.showUpload = false;
                    this.showSpinner=true;
                    handleNavigate('success');
                    // location.reload();
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

     handleSucces() {
        // console.log('Record ID: ', this.record);
        console.log('is checked: ', this.isUploadFile);
        if(this.isUploadFile) {
         this.attachFiles();  
        } 
    }
    
    handleRemove(event) {
		let title = event.target.dataset.fid;
		let index = this.filesUploaded.findIndex(obj => obj.Title === title);
		console.log(index);
		this.filesUploaded.splice(index, 1);
	}
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleNavigate(msg) {
        if (msg === 'success') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId:this.recordId,
                    objectApiName:'Case',
                    actionName: 'view'
                }
            });
        }
    }

    handleCheckChange(event) {
		this.isUploadFile = event.target.checked;
        if(!this.isUploadFile && this.filesUploaded.length > 0) {
			this.filesUploaded = [];
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