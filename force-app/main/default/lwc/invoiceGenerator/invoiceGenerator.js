import { LightningElement, track, api, wire } from 'lwc';
import getInvoiceDetails from '@salesforce/apex/lightningButtonController.getInvoiceDetails';
import uploadFile from '@salesforce/apex/lightningButtonController.uploadFile';
import updateInvoice from '@salesforce/apex/lightningButtonController.updateInvoice';

export default class InvoiceGenerator extends LightningElement {
    @track showPopup = { title: '', message: '', variant: '' };
    @api parameters;
    @api recordId;
    centerName = '';
    fileData;
    isAlreadyUploaded = false;
    checkData = false;
    type = 'IN';

    @track objAEPInvoice = {};
    @track isLoaded = false;

    connectedCallback(){
        // to set the recordId
        if(this.parameters){
            console.dir(this.parameters)
        }
		if (Object.prototype.hasOwnProperty.call(this.parameters, 'id')) {
			this.recordId = this.parameters.id;
        }
        if(Object.prototype.hasOwnProperty.call(this.parameters, 'type')) {
            this.type = this.parameters.type;
        }
    }

    get isInvoice() {
        return this.type === 'IN' ? true : false;
    }

    handleUploadFinished(event) {
        const file = event.target.files[0]
        const size = (file.size / 1024 / 1024).toFixed(2); // in MB
        let validFileExtensions = [".jpg", ".jpeg", ".png", ".pdf"];
        let validFormat = false;
        for (let j = 0; j < validFileExtensions.length; j++) {
            let sCurExtension = validFileExtensions[j];
            if (file.name.substr(file.name.length - sCurExtension.length, sCurExtension.length).toLowerCase() === sCurExtension.toLowerCase()) {
                validFormat = true;
                break;
            }
        }

        if(size <= 3 && validFormat) {
            let reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1];
                let newFileName = `${this.recordId}_${this.type}.${this.getExt(file.name)}`;
                this.fileData = {
                    'filename': newFileName,
                    'base64': base64
                }
                console.log(this.fileData)
            }
            reader.readAsDataURL(file)
        } else if(!validFormat) {
            this.showHtmlMessage('Invalid File.', `Invalid File Format, ${file.name} is invalid, allowed extension are: ${validFileExtensions.join(", ")}`, 'warning');
            event.target.files = null;
        } else if(size > 3) {
            this.showHtmlMessage('Invalid File.', 'File size exceeds 3 MB', 'warning');
            event.target.files = null;
        }
        
    }
    
    handleClick(){
        const {base64, filename} = this.fileData
        uploadFile({ base64, filename }).then(result=>{
            if(result) {
                this.fileData = null;
                this.updateInvoiceLink(result);
            } else {
                this.showHtmlMessage('Something went wrong.', 'File cannot be uploaded', 'error');
            }
        })
    }

    @wire(getInvoiceDetails, { invoiceId: '$recordId'})
	getInvoiceDetails({ error, data }) {
		console.log('enter for get course details ' + this.recordId);
		if (data) {
            console.log(JSON.stringify(data));
            this.objAEPInvoice = data[0];
            this.centerName = this.objAEPInvoice.AEP__r.Name;
            this.isAlreadyUploaded = this.checkifAlreadyUploaded();
            this.checkData = true;
		} else if (error) {
			console.error(error);
            this.showHtmlMessage('Something went wrong.', error, 'error');
            this.checkData = false;
		}
    }

    checkifAlreadyUploaded() {
        if(this.isInvoice && this.objAEPInvoice.Invoice_Link__c) {
            return true;
        } else if(!this.isInvoice && this.objAEPInvoice.Credit_Note_Link__c) {
            return true;
        }
        return false;
    }

    updateInvoiceLink(fileURL){
        console.log(fileURL);
        updateInvoice({invoiceId : this.recordId, invoiceLink: fileURL, isInvoice: this.isInvoice })
            .then((response) => {
                if (response) {
                    this.isAlreadyUploaded = true;
                    let invoiceType = this.isInvoice === true ? 'Invoice' : 'Credit Note';
                    this.showHtmlMessage('Success!', `${invoiceType} Document updated successfully`, 'success');
                } else {
                    this.showHtmlMessage('Something went wrong!', 'Kindly check the attachment.', 'error');
                }
            })
            .catch((error) => {
                console.log(error);
                this.showHtmlMessage('Something went wrong.', error, 'error');
            });
    }

    getExt(filename) {
        let ext = filename.split('.').pop();
        if(ext === filename) return "";
        return ext;
    }

    showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}