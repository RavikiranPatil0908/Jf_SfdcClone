import { LightningElement, api, track } from 'lwc';
import uploadFiles from '@salesforce/apex/UploadFiles.uploadFiles';

export default class FileUpload extends LightningElement {
		@api rid;
		@api cid;
		@track filesUploaded = [];
		@track error = '';
		
		get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    }
		
		handleFileUploaded(event) {
				this.error = '';
        if (event.target.files.length > 0) {
						console.log(event.target.files);
            let files = [];
						const MAX_FILE_SIZE = (3 * 1024 * 1024); 
            for(var i=0; i< event.target.files.length; i++){
                let file = event.target.files[i];
								if (file.size > MAX_FILE_SIZE) {								
        					this.error = 'File size exceeds the limit';
    						}else{
                	let reader = new FileReader();
                	reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);										
										var extension = file.name.split('.');					
										if (!this.acceptedFormats.includes('.'+extension[1].toLowerCase())) {
												this.error = 'Select file with valid extension';
										}else{
												this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
										}                    
                	};
                	reader.readAsDataURL(file);
								}
            }
        }
    }

		handleRemove(event){
				var title  = event.target.dataset.fid;
				var index = this.filesUploaded.findIndex(obj => obj.Title === title);
				console.log(index);
				this.filesUploaded.splice(index, 1);
		}

    attachFiles(event){
				console.log(this.rid);
        uploadFiles({files: this.filesUploaded, caseId: this.rid, commId: this.cid})
            .then(result => {
								console.log(result);
							
                if(result == true) {            
										window.location = 'https://ngasce.my.salesforce.com//'+this.rid;
                }else{
                    //this.showToastMessage('Error','Error uploading files', 'error');
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
}