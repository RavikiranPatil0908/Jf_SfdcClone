import { LightningElement,track,api,wire} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import changeECDDate from '@salesforce/apex/CaseController.changeECDDate';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import { getRecord } from 'lightning/uiRecordApi';
import recordUserId from '@salesforce/schema/Case.CreatedById';

export default class ChangeExpectedClosedDate extends LightningElement {
    @api recordId;
    @track showSpinner = true;
    @track showFileAttachment = false;
    @track Date;
    @track Description;
    @track message;
    @track filesUploaded = [];
    @track todayDate;
    @track tdata;
    fileUploadError;
    @track recordTypeName;

    @wire(getRecord, { recordId: '$recordId', fields: [recordUserId,'Case.RecordType.Name'] })
    wireuser({ error, data }) {
        if (data) {
            console.log('Id :::: ',Id);
            console.log('data :::: ',data);
                if(data.fields.CreatedById.value == Id || data.fields.RecordType.displayValue != 'Internal Ticket')
                {
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: 'You do not have permission to change the Expected Close Date(ECD) of your own case.',
                        variant: 'warning'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else{
                    this.showSpinner = false;
                }
                
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx'];
	}
    connectedCallback(){
        var today = new Date();
        this.todayDate=today.toISOString();
        console.log(today.toISOString())
        console.log('todayadate: ',this.todayDate);
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

    handleRemove(event) {
		let title = event.target.dataset.fid;
		let index = this.filesUploaded.findIndex(obj => obj.Title === title);
		console.log(index);
		this.filesUploaded.splice(index, 1);
	}
    handleChangeDate(event) {
        console.log('event.target.value',event.target.value);
        this.tdata = this.todayDate.split('T');
        if(this.tdata[0] > event.target.value)
        {
           // alert('closed date must not be past date');
            const evt = new ShowToastEvent({
                title: 'Validation error',
                message: 'New Expected Close Date should be Greater than or Equal to Today'+'s Date',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return;
        }else {
            this.Date = event.target.value;
            console.log('this.date',this.Date);
        }
    }
    handleChangeDescription(event) {
        this.Description = event.target.value;
    }
    handleCheckbox(event){
        console.log('event: ',event.target.checked);
        this.showFileAttachment = event.target.checked;
        console.log('showFileAttachment: ',this.showFileAttachment );
        if(!this.showFileAttachment && this.filesUploaded.length > 0) {
			this.filesUploaded = [];
		}
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent()); 
    }
    isEmpty(str) {
        return (!str || str.length === 0 );
    }
    handleError() {
        this.showSpinner = false;
        console.error('Error: ', this.errorMsg);
        
    }
    async handleSubmit(){
        if(this.Date == null || this.Description == null)
        {
            const evt = new ShowToastEvent({
                title: 'Validation error',
                message: 'please provide required fields.',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return;
        }
        if(this.showFileAttachment == true && this.filesUploaded.length === 0)
        {
            const evt = new ShowToastEvent({
                title: 'Validation error',
                message: 'please attach file.',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return;
        }
        this.showSpinner = true;
        console.log("handleSubmit");
        await this.handleSave();
        if(this.isEmpty(this.message)) {
            this.handleError();
            return;
        }
         if(this.message === "Expected Close Date updated successfully"){
                console.log("handleSubmit if uploadfiles()");
                this.uploadFiles();
                console.log('message',this.message);
            }
            else{

                console.log('result',this.message);
            }
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'record saved successfully.',
            variant: 'success'
        });
        this.dispatchEvent(evt);
        this.dispatchEvent(new CloseActionScreenEvent()); 
        location.reload();
    }
    async handleSave(){
        console.log("handleSave");
        await changeECDDate({caseId : this.recordId, newExpectedCloseDate : this.Date, comment : this.Description })      
        .then(result => {
            console.log('status change Succesfully ==>'+ result);
            this.message  = result
        })
        .catch(error => {
            console.log(error);
        });
    }
    async uploadFiles(){
        console.log("uploadFiles");
        if(this.showFileAttachment){
            await this.attachFiles();
        }
    }
   async attachFiles() {
        console.log("attachFiles"+this.recordId);
		await uploadFiles({ files: this.filesUploaded, caseId: this.recordId })
			.then(result => {
				if (result === true) {
					this.showFileAttachment = false;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}
}