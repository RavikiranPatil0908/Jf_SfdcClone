/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 22--04--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification

**/
import { LightningElement, track } from 'lwc';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import createCase from '@salesforce/apex/MyCasesController.createCase';
import getStudentDetails from "@salesforce/apex/MyCasesController.getStudentDetails";
import getDependentPicklistValues from '@salesforce/apex/MyCasesController.getDependentPicklistValues';
import getMobileAndEmailForOTP from '@salesforce/apex/MyCasesController.getMobileAndEmailForOTP';
import VerifyOTP from '@salesforce/apex/MyCasesController.VerifyOTP';
import sendOTP from '@salesforce/apex/MyCasesController.sendOTP';
import sendEmailOTP from '@salesforce/apex/MyCasesController.sendEmailOTP';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';

export default class RaiseTicket extends LightningElement {
		@track caseId;
		@track caseNumber;
		@track subject = '';
		@track category = '';
		@track subCategory = '';		
		@track isUploadFile = false;
		@track filesUploaded = [];
		@track error = '';
		@track studentNo = '';
		@track closeDate;
		@track message = '';
		@track otp = '';
		@track showOtp = false;
		@track timeVal;
		@track mobileNo;
		@track emailId;
		@track contactId;
		@track resend = true;
		@track program;
		@track showToast = false;
		error = '';
		sentTime;
		OtpCode;
		description;
		purpose;
		caseMap={};
		
		@track options = [];
		get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    }
		
		@track categories = [{label: 'Admissions', value: 'Admissions'}, {label: 'Academics', value: 'Academics'},
												 {label: 'Assignment/Internal Assessment', value: 'Assignment/Internal Assessment'},
												 {label: 'Term End Examination', value: 'Term End Examination'},{label: 'Logistics', value: 'Logistics'},
												 {label: 'Service Request', value: 'Service Request'},{label: 'Others', value: 'Others'}];
		
		@track queryTypes = [{label: 'Enquiry', value: 'Enquiry'},{label: 'Feedback', value: 'Feedback'},{label: 'Complaint', value: 'Complaint'}];
	
		count = 5;
  	timer;
	
		handleOtpChange(event){
				this.otp = event.target.value;
		}
		
		handlePurposeChange(event){
				this.purpose = event.target.value;
				this.caseMap['purpose'] = event.target.value;		
				this.caseMap['source'] = 'Public URL';
		}
		
		handleCategoryChange(event){
				this.options = [];
				this.subCategory = '';
				this.category = event.target.value;
				
				getDependentPicklistValues({categoryValue: this.category, program: this.program}).then(result => {
					for(let i=0; i<result.length; i++){
						this.options = [ ...this.options, {label: result[i], value: result[i]} ];
						console.log(this.options);
					}						
				})
				.catch(error => {
					console.log(error);
				});
				this.subject = this.category;
				this.enable = true;
				this.caseMap['category'] = this.category;				
		}
		
		handleChange(event) {
				this.subCategory = event.detail.value;
				console.log(this.subCategory);
				this.subject = this.category + ' - ' + this.subCategory;
				this.caseMap['subcat'] = this.subCategory;
				this.caseMap['sub'] = this.subject;
		}
		
		handleSubjChange(event){
				this.subject = event.target.value;
				this.caseMap['sub'] = this.subject;
		}		
		
		handleDescChange(event){
				this.caseMap['description'] = event.target.value;	
		}
		
		handleCheckChange(event){
				this.isUploadFile = event.target.checked;				
		}
		
		refreshComponent(event){
        const inputFields = this.template.querySelectorAll( 'lightning-input-field' );
        if ( inputFields ) {
            inputFields.forEach( field => {
                field.reset();
            } );
        }
    }
		
		handleNoChange(event){
				this.studentNo = event.target.value;
				this.caseMap['studentNo'] = this.studentNo;
				this.studentDetails();
		}
		
		studentDetails(){
			if(this.studentNo.length == 11){
				getStudentDetails({sno: this.studentNo, rno: '', email: '', mobile: ''}).then(result => {
					console.log(result);
					this.program = result.program;
					this.caseMap['converted'] = '';
					this.error = '';
      	})
      	.catch(error => {
					this.error = 'No student found. Re-enter the Sap Id';
        	console.log(error);
      	});
			}
		}
		
		handleSubmit(){
			if(Object.keys(this.caseMap).length != 0 && 'studentNo' in this.caseMap && 'subcat' in this.caseMap && this.caseMap['subcat'] !== '' && 'sub' in this.caseMap && this.caseMap['sub'].trim().length > 0 && 'description' in this.caseMap && this.caseMap['description'].trim().length > 0){
				this.showOtp = true;
				getMobileAndEmailForOTP({studentNo: this.studentNo, registrationNo:'', email: '', mobile: '', converted: this.caseMap['converted']}).then(result => {
						this.sentTime = new Date().getTime();
						
						if(result == 'No match found for entered Sap Id'){
								this.showOtp = false;
								LightningAlert.open({
            				message: result,
            				theme: 'error', 
            				label: 'No record found!', 
            				variant: 'header',
        				});
								this.studentNo = '';
						}else{
								var res = result.split(' ');
								this.mobileNo = res[0];
								this.emailId = res[1];
								this.contactId = res[2];
								this.OtpCode = res[3];
								var mail = res[1].split('@');	
								this.message = 'OTP has been sent to your mobile no ******'+ this.mobileNo.slice(-4) + ' and email id ****'+ mail[0].slice(-4) +'@'+ mail[1];
								var now = new Date().getTime();							
								this.count = now + (2*60000);
								this.timer = setInterval(()=>{
										var now = new Date().getTime();
										var distance = this.count - now;
										
      						if (this.timeVal == '0:0') {
        							clearInterval(this.timer);
											this.resend = false;
      						} else {
										
        							var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            					var seconds = Math.floor((distance % (1000 * 60)) / 1000);            		
            					
            					// Output the result in the timeVal variable
            					this.timeVal = minutes + ":" + seconds;   
      						}
								}, 1000);
						}
				}).catch(error => {
					console.log(error);
				});
			}else{
						this.showToast = true;
						setInterval(() => {
      				this.showToast = false;
    				}, 4000);
				}
		}
		
		verification(){
				VerifyOTP({OtpCode: this.OtpCode, Otp: this.otp, otpSentTime: this.sentTime}).then(result => {
						this.message = result;
						console.log(JSON.stringify(this.caseMap));
						if(result == 'OTP Verified'){									
								createCase({caseMap: this.caseMap}).then(result => {	
									this.caseNumber = result.split(' ')[1];
									this.caseId = result.split(' ')[0];
									console.log('Case Id -->',this.caseId);
									if(this.caseId != undefined){
		
											if(this.filesUploaded.length > 0){
													this.attachFiles(event);
											}			
											this.showOtp = false;			
											this.handleConfirm();
									}			
								})
								.catch(error => {
										console.log(JSON.stringify(error));
								});
						}
				}).catch(error => {
					console.log(error);
				});
		}
		
		async handleConfirm(){
				if(this.caseId != undefined){
					const res = await LightningConfirm.open({
            						message: 'Your ticket has been raised successfully. Please use Ticket No - #'+this.caseNumber+' in all future correspondences.',
            						variant: 'header',
            						label: 'Thank You!',
            						theme: 'success',
        	});	
				
					if(res==true){
						window.location.reload();
        	}		
				}
		}
		
		handleResendOtp(){
				sendOTP({mobileNo: this.mobileNo}).then(result => {
						this.message = 'OTP has been resent to your mobile no ******'+ this.mobileNo.slice(-4);
						this.resend = true;
						this.OtpCode = result;
						this.sentTime = new Date().getTime();
						console.log('Contact admin');
				}).catch(error => {
						console.log(error);
				});
				
				sendEmailOTP({personContactId: this.contactId}).then(result => {
						this.message = 'OTP has been resent to your mobile no ******'+ this.mobileNo.slice(-4);
						this.resend = true;
						console.log('Contact admin');
				}).catch(error => {
						console.log(error);
				});
		}
		
		handleModalClose(){
				this.showOtp = false;
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
										if (!this.acceptedFormats.includes('.'+extension[extension.length - 1])) {
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

    attachFiles(event){
        uploadFiles({files: this.filesUploaded, caseId: this.caseId})
            .then(result => {
                if(result == true) {             
										console.log('Files uploaded successfully');
                }else{
                    console.log('Error uploading files');
                }
            })
            .catch(error => {
                //this.showToastMessage('Error','Error uploading files', 'error');
            });
    }

		handleRemove(event) {
		let title = event.target.dataset.fid;
		let index = this.filesUploaded.findIndex(obj => obj.Title === title);
		console.log(index);
		this.filesUploaded.splice(index, 1);
	}

}