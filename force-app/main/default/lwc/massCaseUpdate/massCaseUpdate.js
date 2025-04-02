import { LightningElement, track } from 'lwc';
import updateCases from '@salesforce/apex/MassUpdateCases.UpdateCases';

export default class MassCaseUpdate extends LightningElement {
		@track caseNumbers;
		@track comment;
		@track status;
		@track owner;
		@track ecd;
		@track category;
		@track subCategory;
		@track techIssue;
		@track error = '';
		@track showSpinner = false;
		fieldMap = {};
		
		handleNoChange(event){
				this.fieldMap['nos'] = event.target.value;	
				console.log(this.fieldMap['nos']);
		}
		
		handleCommentChange(event){
				this.comment = event.target.value;
				this.fieldMap['comment'] = this.comment;
		}
		
		handleStatusChange(event){
				this.fieldMap['status'] = event.target.value;	
		}
		
		handleCategoryChange(event){
				this.fieldMap['cat'] = event.target.value;	
		}
		
		handleSubcatChange(event){
				this.fieldMap['subcat'] = event.target.value;	
		}
		
		handleECDChange(event){
				this.ecd = event.target.value;	
				this.fieldMap['ecd'] = this.ecd;	
		}
		
		handleTechChange(event){
				this.fieldMap['issue'] = event.target.value;	
		}
		
		handleSubmit(){
				console.log('map '+JSON.stringify(this.fieldMap));
				console.log(this.comment);
				if( this.fieldMap.hasOwnProperty('ecd') && (this.comment == '' || this.comment == undefined )){
						this.error = 'Add a reason for a change in Expected Close Date';
				}else{
						this.showSpinner = true;
						this.error = '';
						updateCases({fieldMap: this.fieldMap}).then(result => {
							this.showSpinner = false;
							alert('Comment added successfully');
							window.location.reload();
						}).catch(error => {
							this.error = 'Please check the entered case numbers';
							console.log(error);
						});
				}
		}
		
		lookupRecord(event){
        this.fieldMap['owner'] = event.detail.selectedRecord.Id;
    }
}