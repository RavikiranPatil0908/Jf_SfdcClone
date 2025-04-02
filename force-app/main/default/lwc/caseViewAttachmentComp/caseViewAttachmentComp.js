import { LightningElement, api, track } from 'lwc';
import getCaseAttachments from '@salesforce/apex/MyCasesController.getCaseAttachments';

export default class CaseViewAttachmentComp extends LightningElement {
    
    isAttachmentAvailable = false;
    showSpinner = false;
    @api recordId;
    @track attachments = [];

    connectedCallback() {
        this.getAttachments();
    }

    @api
    getAttachments() {
		this.showSpinner = true;
		console.log('methods has been called');
		getCaseAttachments({ caseId: this.recordId }).then(result => { 
			this.isAttachmentAvailable = false;
			if(result && result.length > 0) {
				console.dir(result);
				result.sort((a,b) => (Date.parse(a.createdDate) < Date.parse(b.createdDate) ? 1 : -1));
				console.dir(result);
                console.log(JSON.stringify(result));
				this.attachments = result;
				this.isAttachmentAvailable = true;
				console.log('this.attachments ==>'+this.attachments);
			}
			this.showSpinner = false;
		}).catch(error => {
			console.log('this.attachments ==> error');
			console.log(error);
			this.showSpinner = false;
		});
	}

    handleDownloadPdf(event) {
		console.log(event.target.dataset.fileUrl);
		console.log(event.target.dataset.fileName);
		const downloadContainer = this.template.querySelector('.download-container');
		const downloadUrl = event.target.dataset.fileUrl;
		const fileName = event.target.dataset.fileName;
		
		let a = document.createElement('a');
		a.href = downloadUrl;
		a.target = '_blank';
		// Use a.download if available, it prevents plugins from opening.
		a.download = fileName;
		// Add a to the doc for click to work.
		if (downloadContainer) {
            downloadContainer.appendChild(a);
		}
		if (a.click) {
            a.click(); // The click method is supported by most browsers.
		}
		// Delete the temporary link.
		downloadContainer.removeChild(a);
		// Download the next file with a small timeout. The timeout is necessary
		// for IE, which will otherwise only download the first file.   
	}
}