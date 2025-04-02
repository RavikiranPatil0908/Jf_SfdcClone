/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 28--10--2024
 * @last modified by  : @Ravi
**/
import { LightningElement, api, track, wire ,  } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import changeDetails from '@salesforce/apex/CaseController.changeDetails';
import CASE_OBJECT from '@salesforce/schema/Case';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import recordUserId from '@salesforce/schema/Case.CreatedById';
import CASE_STATUS_FIELD  from '@salesforce/schema/Case.Status';
import LightningAlert from 'lightning/alert';

export default class IttUpdateDetails extends LightningElement {
    @api recordId;
    @track comment;
    @track newExpectedCloseDate;
    @track status;
    @track filesUploaded = [];
    @track StatusOptions=[{ label: '--None--', value: '' }, 
        {label: 'New', value: 'New' },
        {label: 'Escalated', value: 'Escalated' },
        {label: 'In Progress', value: 'In Progress' },
        {label: 'Response Received', value: 'Response Received' },
        {label: 'Internal Response Received', value: 'Internal Response Received' },
        {label: 'New Case', value: 'New Case' },
        {label: 'Repeat case', value: 'Repeat case' },
        ];

    @track message;
    @track todayDate;
    @track tdata;
    fileUploadError;
    // objectApiName = CASE_OBJECT;
    @track recordTypeName;
    @track showSpinner = true;
    @track showFileAttachment = false;

    @track createdByIdwire;
    @track recordtypewire ;
    @track statuswire;
 
    
    // @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    // wiredObjectInfo({ error, data }) {
    //     if (data) {
    //         let objArray = data.recordTypeInfos;
    //         for (let i in objArray) {
    //             if (objArray[i].name === "Internal Ticket")
    //                 //eslint-disable-next-line @lwc/lwc/no-api-reassignments
    //                 this.internalRecordTypeId = objArray[i].recordTypeId;
    //         }
    //         console.log("recordtypeId " + this.internalRecordTypeId);
    //     } else if (error) {
    //         console.log(JSON.stringify(error))
    //     }
    // }

    @wire(getRecord, { recordId: '$recordId', fields: [recordUserId,CASE_STATUS_FIELD] })
    wireuser({ error, data }) {
        console.log("recordId"+this.recordId);
        console.log('Data:::: ',data);
        if (data) {
            console.log('Id :::: ',Id);
            console.log('data :::: ',data);
            this.createdByIdwire = data.fields.CreatedById.value; // expected closed date change  data.fields.CreatedById.value == Id ||
            // this.recordtypewire = data.fields.RecordType.displayValue;
            this.statuswire = data.fields.Status.value;
                // if( data.fields.RecordType.displayValue != 'Internal Ticket')
                // {
                //     const evt = new ShowToastEvent({
                //         title: 'Warning',
                //         message: 'This action is only allowed for Internal Ticket Records.',
                //         variant: 'warning'
                //     });
                //     this.dispatchEvent(evt);
                //     this.dispatchEvent(new CloseActionScreenEvent());
                // }else{
                //    
                // }
                this.showSpinner = false;
                
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }
    
    get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx'];
	}
    connectedCallback(){
        var today = new Date();
        console.log("recordId"+this.recordId);
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
            this.newExpectedCloseDate = event.target.value;
            console.log('this.newExpectedCloseDate',this.newExpectedCloseDate);
        }
    }
    handleChangeDescription(event) {
        this.comment = event.target.value;
        console.log('this.comment',this.comment);
    }

    handleChangeStatus(event){
        this.status = event.target.value;
        console.log('this.status',this.status);
    }

    handleCheckbox(event){
        console.log('event:',event.target.checked);
        this.showFileAttachment = event.target.checked;
        console.log('showFileAttachment: ',this.showFileAttachment );
        if(!this.showFileAttachment && this.filesUploaded.length > 0) {
			this.filesUploaded = [];
		}
    }

    handleCancel(event) {
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
        console.log('submit');
        let localMessage = '';
        if(this.comment == null || this.comment === '')
        {
            const evt = new ShowToastEvent({
                title: 'Validation error',
                message: 'please provide required fields.',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return;
        }
        if(this.newExpectedCloseDate != null){
            if( this.createdByIdwire == Id)
                {
                    // const evt = new ShowToastEvent({
                    //     title: 'Warning',
                    //     message: 'you are not Authorized to change expected closed date',
                    //     variant: 'warning'
                    // });
                    // this.dispatchEvent(evt);
                    // this.dispatchEvent(new CloseActionScreenEvent());
                    this.showMessage('You are not authorized to change the expected close date.', 'warning', 'Validation failed!');
                    return ;
               
                }         
        }
        if(this.status != null && this.createdByIdwire == Id && this.statuswire === 'New'){
                console.log('submit with status');
                {
                    // const evt = new ShowToastEvent({
                    //     title: 'Warning',
                    //     message: "You can't change the status of your case while the case status is 'New'",
                    //     variant: 'warning'
                    // });
                    // this.dispatchEvent(evt);
                    // this.dispatchEvent(new CloseActionScreenEvent());
                    // return;
                    this.showMessage("You can't change the status of your case while the case status is 'New'", 'warning', 'Validation failed!');
                    return ;
                }         
        }

        if(this.comment != null && this.newExpectedCloseDate == null && this.status == null)
        {
            localMessage = 'Comment added successfuly';
        }
        else if( this.newExpectedCloseDate != null && this.status == null)
        {
            localMessage = 'Comment and expected Closed date changed successfully';
        }
        else if(this.newExpectedCloseDate == null && this.status != null){
            localMessage = 'Comment and Status changed successfully';
        }
        else if( this.newExpectedCloseDate != null && this.status != null){
            localMessage = 'changes saved successfully';
        }
        if(this.showFileAttachment == true && this.filesUploaded.length === 0)
        {
            // const evt = new ShowToastEvent({
            //     title: 'Validation error',
            //     message: 'please attach file.',
            //     variant: 'warning'
            // });
            // this.dispatchEvent(evt);
          this.showMessage("Please attach file.",'warning', 'Missing Data!');
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
        this.showMessage(localMessage,'success', 'Success!');
        // const evt = new ShowToastEvent({
        //     title: 'Success',
        //     message: localMessage,
        //     variant: 'success'
        // });
        // this.dispatchEvent(evt);
        // this.dispatchEvent(new CloseActionScreenEvent()); 
        location.reload();
    }
    async handleSave(){
        console.log("handleSave");
        await changeDetails({caseId : this.recordId, newExpectedCloseDate : this.newExpectedCloseDate, comment : this.comment, status : this.status , prevStatus :this.statuswire})      
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

    showMessage(msg, theme, label) {
        LightningAlert.open({
            message: msg,
            theme: theme,
            label: label,
            variant: 'header',
        });
    }


}