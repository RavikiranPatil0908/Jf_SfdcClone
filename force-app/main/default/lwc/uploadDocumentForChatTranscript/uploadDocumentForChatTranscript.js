import { LightningElement, track, api } from 'lwc';
import uploadFile from "@salesforce/apex/UploadDocumentToFolder.uploadFile";
import LightningAlert from 'lightning/alert';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class UploadDocumentForChatTranscript extends LightningElement {
    fileData;
    isFileUploaded = true;
    formatAccepted = ["jpg","jpeg","png","svg","gif","pdf","doc","docx","ppt","pptx","xls","xlsx","zip","rar"];
    formatTest;
    @track fileLink;
    isFileSaved = false;
	isLoading = false;
    readOnly = true;
	@api isEnabled;

    handleUploadFinished(event) {
        const file = event.target.files[0];
        const size = (file.size / 1024 / 1024).toFixed(2); // in MB
        const fileformat = file.name.split(".");
        console.log(size)
        
        this.formatTest = this.formatAccepted.includes(fileformat[fileformat.length - 1]);
        if (size <= 3 && this.formatTest) {
			console.log(file);
			let reader = new FileReader();
			reader.onload = () => {
				let base64 = reader.result.split(",")[1];
				this.fileData = {
					filename: file.name,
					base64: base64
				};
				console.log(this.fileData);
			};
			reader.readAsDataURL(file);
			this.isFileUploaded = false;
		} else if (size > 3) {
			this.handleAlert('Invalid File.', 'File size exceeds 3 MB', 'warning');
			event.target.files = null;
		} else {
			this.handleAlert('Invalid File.', 'File format should be in [jpg, jpeg, png, svg, gif, pdf, doc, docx, ppt, pptx, xls, xlsx, zip, rar]', 'warning');
			event.target.files = null;
		}
    }

    onSubmit() {
        console.log(this.fileData);
        // const { base64, filename } = this.fileData;
		const base64 = this.fileData.base64;
		const filename = this.fileData.filename;
		const folderName = 'ChatDocuments';
		this.isLoading = true;
        uploadFile({ attachmentBody: base64, fileName: filename, folderName: folderName }).then((result) => {
			if (result) {
				this.fileData = null;
				console.log(result);
				this.fileLink = result;
				this.isFileSaved = true;
				this.isLoading = false;
			} else {
				this.handleAlert('Something went wrong.', 'File cannot be uploaded', 'error');
				this.isLoading = false;
			}
        });
    }

    copyToClipboard() {
		console.log(this.fileLink);
		let tempTextArea = document.createElement('textarea');
		tempTextArea.value = this.fileLink;
		document.body.appendChild(tempTextArea);
		tempTextArea.select();
		document.execCommand('copy');
	}
  
	async handleAlert(lab,msg,type) {
		await LightningAlert.open({
			message: msg,
			theme: type, 
			label: lab,
		});
		this.closeQuickAction();
	}

	refreshData() {
		this.isFileSaved = false;
		this.isFileUploaded = true;
	}

	closeQuickAction() {
		this.dispatchEvent(new CloseActionScreenEvent());
	}
      
}