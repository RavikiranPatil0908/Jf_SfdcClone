import { LightningElement, track } from 'lwc';
import getStudentDetails from "@salesforce/apex/MyCasesController.getStudentDetails";
import getMobileAndEmailForOTP from '@salesforce/apex/MyCasesController.getMobileAndEmailForOTP';
import VerifyOTP from '@salesforce/apex/MyCasesController.VerifyOTP';
import sendOTP from '@salesforce/apex/MyCasesController.sendOTP';
import sendEmailOTP from '@salesforce/apex/MyCasesController.sendEmailOTP';
import getToken from '@salesforce/apex/generateToken.getToken';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';

export default class OtpLoginPage extends LightningElement {
		@track caseId;
		@track caseNumber;
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
		@track showToast = false;
		error = '';
		sentTime;
		OtpCode;
		description;
		purpose;
		caseMap={};
		count = 5;
  	timer;
	
		handleOtpChange(event){
				this.otp = event.target.value;
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
			if(Object.keys(this.caseMap).length != 0 && 'studentNo' in this.caseMap && this.studentNo != ''){
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
								console.log(res);
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
						if(result == 'OTP Verified'){	
							getToken({sapId: this.studentNo}).then(result => {
									//navigate to tt home page
									window.location.assign('/apex/MyTickets?token='+result+'&isPortal=false');
							}).catch(error => {
									console.log(error);
							});								
						}
				}).catch(error => {
					console.log(error);
				});
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
}