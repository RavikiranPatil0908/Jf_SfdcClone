import { LightningElement, api, track, wire } from 'lwc';
import addComment from '@salesforce/apex/MassUpdateCases.addComment';
import getProgram from '@salesforce/apex/MassUpdateCases.getProgram';
import getDependentPicklistValues from '@salesforce/apex/MassUpdateCases.getDependentPicklistValues';

export default class AddCaseComment extends LightningElement {
		@api recordId;
		@track comment;
		@track status;
		@track owner;
		@track ecd;
		@track category;
		@track subCategory = '';
		@track techIssue;
		@track error = '';
		@track program;
		@track showSpinner = false;
		@track isUploadFile = false;
		@track options = [];
		@track enable = false;
		fieldMap = {};
		
		// connectedCallback(){
		// 	console.log('recordId ==>'+recordId);
		// 		getProgram({caseId: this.recordId}).then(result => {
		// 				console.log('Program '+result);
		// 				this.program = result;
		// 		}).catch(error => {
		// 				console.log(error);
		// 		});
		// }

		@wire(getProgram, { caseId: '$recordId' })
		getProgramList({ error, data }) {
            if (data) {
				console.log('Program '+data);
				this.program = data;
            } else if (error) {
				console.error(error);
            }
      	}
		
		handleCommentChange(event){
				this.comment = event.target.value;
				this.fieldMap['comment'] = this.comment;
		}
		
		handleStatusChange(event){
				this.fieldMap['status'] = event.target.value;	
		}
		
		handleOwnerChange(event){
				this.fieldMap['owner'] = event.target.value;	
		}
		 
		handleCategoryChange(event){
				console.log(this.program);
				this.category = event.target.value;
				this.fieldMap['cat'] = this.category;
				if(this.program != null){
						getDependentPicklistValues({categoryValue: this.category, program: this.program}).then(result => {
							for(let i=0; i<result.length; i++){
								this.options = [ ...this.options, {label: result[i], value: result[i]} ];
								console.log(this.options);
								this.enable = true;
							}						
						})
						.catch(error => {
							console.log(error);
						});
				}else{
						this.error = 'There is no program attached for the student';
				}
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
		
		handleCheckChange(event){
				this.isUploadFile = event.target.checked;				
		}
		
		handleSubmit(){				
				// Check if fieldMap has ECD or status
					if (this.fieldMap.comment && !this.fieldMap.ecd && !this.fieldMap.status) {
						this.error = 'Please update either the Status or Expected Close Date field to add a comment.';
						return;
					}

					// Validate tech issue if status is changed to 'Closed'
					if (this.fieldMap.status === 'Closed' && !this.fieldMap.issue && !this.fieldMap.cat && !this.fieldMap.subcat) {
						this.error = 'Tech Issue, Admin Category and Sub-Category is mandatory if the status is changed to Closed.';
						return;
					}
				
					if (this.fieldMap.status === 'Closed' && this.fieldMap.owner ) {
						this.error = 'Cannot update owner if the status is Closed.';
						return;
					}
				
						this.error = '';
						this.showSpinner = true;
						addComment({fieldMap: this.fieldMap, caseId: this.recordId}).then(result => {
							this.showSpinner = false;
							console.log(result);
							alert('Record updated successfully');
							if(this.isUploadFile == true){									
								window.location.href = "https://ngasce--c.vf.force.com/apex/AddCommentFlow?cid="+result+"&rid="+this.recordId;
							}else{
								window.location.reload();								
							}
						}).catch(error => {
							console.log(error);
						});
		}
		
		lookupRecord(event){
        this.fieldMap['owner'] = event.detail.selectedRecord.Id;
    }
}