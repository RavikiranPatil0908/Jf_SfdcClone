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
import siteUrl from '@salesforce/label/c.Site_Url'; 

export default class RaiseTicketForRegistrants extends LightningElement {
	@track caseId;
	@track caseNumber;
	@track subject = '';
	@track category = '';
	@track subCategory = '';
	@track isUploadFile = false;
	@track filesUploaded = [];
	@track error = '';
	@track regNo = '';
	@track email = '';
	@track mobile = '';
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
	@track defaultOptionValue = true;
	@track contactOptionValue = false;
	uploadError;
	sentTime;
	OtpCode;
	description;
	purpose;
	showSpinner = false;
	// caseMap = {};
	@track caseMap = {regNo:'', purpose:'', source:'', category:'', subcat:'', sub:'', description:'', email:'', mobile:'', converted: false};
	enable;
	suberror = '';
	@track options = [];
	get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg'];
	}

	@track categories = [{ label: 'Admissions', value: 'Admissions' }, { label: 'Academics', value: 'Academics' },
	{ label: 'Assignment/Internal Assessment', value: 'Assignment/Internal Assessment' },
	{ label: 'Term End Examination', value: 'Term End Examination' }, { label: 'Logistics', value: 'Logistics' },
	{ label: 'Service Request', value: 'Service Request' }, { label: 'Others', value: 'Others' }];

	@track queryTypes = [{ label: 'Complaint', value: 'Complaint' }, { label: 'Enquiry', value: 'Enquiry' }];

	count = 5;
	timer;

	@track selectedValue;
	@track showReg = true;
	@track showContact = false;

	handleSelected(event) {
		this.selectedValue = event.target.value;

		if (this.selectedValue === 'regno') {
			this.defaultOptionValue = true;
			this.contactOptionValue = false;
			this.showContact = false;
			this.showReg = true;

		} else if (this.selectedValue === 'contact') {
			this.defaultOptionValue = false;
			this.contactOptionValue = true;
			this.showReg = false;
			this.showContact = true;
		}
	}

	handleOtpChange(event) {
		this.otp = event.target.value;
	}

	handlePurposeChange(event) {
		this.purpose = event.target.value;
		this.caseMap.purpose = event.target.value;
		this.caseMap.source = 'Public URL';
	}

	handleCategoryChange(event) {
		this.options = [];
		this.subCategory = '';
		this.category = event.target.value;
		this.showSpinner = true;
		getDependentPicklistValues({ categoryValue: this.category, program: this.program }).then(result => {
			if (result.length !== 0) {
				for (let i = 0; i < result.length; i++) {
					this.options = [...this.options, { label: result[i], value: result[i] }];
				}
				this.suberror = '';
			}
			this.showSpinner = false;
		})
		.catch(error => {
			this.suberror = 'Invalid SAP ID/Reg No/Mobile No & Email ID';
			this.showSpinner = false;
			console.log(error);
		});

		this.subject = this.category;
		this.enable = true;
		this.caseMap.category = this.category;
	}

	handleChange(event) {
		this.subCategory = event.detail.value;
		console.log(this.subCategory);
		this.subject = this.category + ' - ' + this.subCategory;
		this.caseMap.subcat = this.subCategory;
		this.caseMap.sub = this.subject;
	}

	handleSubjChange(event) {
		this.subject = event.target.value;
		this.caseMap.sub = this.subject;
	}

	handleDescChange(event) {
		this.caseMap.description = event.target.value;
	}

	handleCheckChange(event) {
		this.isUploadFile = event.target.checked;
	}

	refreshComponent() {
		const inputFields = this.template.querySelectorAll('lightning-input-field');
		if (inputFields) {
			inputFields.forEach(field => {
				field.reset();
			});
		}
	}

	handleEmailChange(event) {
		var email = event.target;
		console.log(email.validity.valid);
		if (email.validity.valid) {
			this.email = email.value;
			this.caseMap.email = this.email;
			this.studentDetails();
		} else {
			//const helpTextElement = document.getElementById("help-message-16");
			//helpTextElement.textContent = "Please enter a valid email address (e.x. John@domain.com)";
		}
	}

	handleMobileChange(event) {
		this.mobile = event.target.value;
		this.caseMap.mobile = this.mobile;
		this.studentDetails();
	}

	validateDigits(event) {
		const keyCode = event.which || event.keyCode;
		if (keyCode < 48 || keyCode > 57) {
			event.preventDefault();
		}
	}

	handleNoChange(event) {
		this.regNo = event.target.value;
		this.caseMap.regNo = this.regNo;
		this.studentDetails();
	}

	async studentDetails() {
		console.log(this.caseMap);
		let objRequest = { sno: '', rno: '', email: '', mobile: '' };
		let alertMsg;
		if (this.regNo.length > 6 && (this.email !== '' && this.mobile.length === 10)) {
			objRequest.email = this.email;
			objRequest.mobile = this.mobile;
			alertMsg = `We couldn't find these details in our database. Please ensure you are using the correct Registration Number or Email ID and Mobile Number`;
		} else if (this.regNo.length > 6 && (this.email === '' && this.mobile === '')) {
			objRequest.rno = this.regNo;
			alertMsg = `We couldn't find these details in our database. Please ensure you are using the correct Registration Number or <a href='${siteUrl}ApplicationInquiry'>Register Here</a>.`;
		} else if (this.email !== '' && this.mobile.length === 10 && this.regNo === '') {
			objRequest.email = this.email;
			objRequest.mobile = this.mobile;
			alertMsg = `We couldn't find these details in our database. Please ensure you are using the registered Email ID and Mobile Number combination or <a href='${siteUrl}ApplicationInquiry'>Register Here</a>.`;
		}

		if(alertMsg) {
			await this.getStudentDetailsVal(objRequest, alertMsg);
		}
	}

	async getStudentDetailsVal(objRequest, alertMsg) {
		await getStudentDetails(objRequest).then(result => {
			console.log('res ' + JSON.stringify(result));
			if (JSON.stringify(result) !== '{}') {
				this.program = result.program;
				if (result.converted !== undefined) {
					this.caseMap.converted = result.converted;
				} else {
					this.caseMap.converted = true;
				}
				this.error = '';
			} else {
				this.error = alertMsg;
			}
		})
		.catch(error => {
			this.error = alertMsg;
			console.log(error);
		});
	}

	handleSubmit() {
		if (Object.keys(this.caseMap).length !== 0 && (this.caseMap.regNo.trim().length > 0 || (this.caseMap.email.trim().length > 0 && this.caseMap.mobile.trim().length > 0)) && this.caseMap.subcat !== '' && this.caseMap.sub.trim().length > 0 && this.caseMap.description.trim().length > 0) {
			this.showSpinner = true;
			getMobileAndEmailForOTP({ studentNo: '', registrationNo: this.regNo, email: this.email, mobile: this.mobile, converted: this.caseMap.converted }).then(result => {
				this.sentTime = new Date().getTime();

				if (result === 'No match found for entered Sap Id') {
					this.showOtp = false;
					this.showSpinner = false;
					LightningAlert.open({
						message: result,
						theme: 'error',
						label: 'No record found!',
						variant: 'header',
					});
					this.studentNo = '';
				} else {
					this.showSpinner = false;
					this.showOtp = true;
					let res = result.split(' ');
					this.mobileNo = res[0];
					this.emailId = res[1];
					this.contactId = res[2];
					this.OtpCode = res[3];
					let mail = res[1].split('@');
					this.message = 'OTP has been sent to your mobile no ******' + this.mobileNo.slice(-4) + ' and email id ****' + mail[0].slice(-4) + '@' + mail[1];
					let now = new Date().getTime();
					this.count = now + (2 * 60000);
					this.timer = setInterval(() => {
						let now = new Date().getTime();
						let distance = this.count - now;

						if (this.timeVal == '0:0') {
							clearInterval(this.timer);
							this.resend = false;
						} else {
							let minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
							let seconds = Math.floor((distance % (1000 * 60)) / 1000);

							// Output the result in the timeVal variable
							this.timeVal = minutes + ":" + seconds;
						}
					}, 1000);
				}
			}).catch(error => {
				console.log(error);
				this.showSpinner = false;
			});
		} else {
			this.showToast = true;
			setInterval(() => {
				this.showToast = false;
			}, 4000);
		}
	}

	verification() {
		this.showSpinner = true;
		VerifyOTP({ OtpCode: this.OtpCode, Otp: this.otp, otpSentTime: this.sentTime }).then(result => {
			this.message = result;
			if (result === 'OTP Verified') {
				console.log('this.caseMap debug');
				console.dir(this.caseMap);
				createCase({ caseMap: this.caseMap }).then(caseResult => {
					this.caseNumber = caseResult.split(' ')[1];
					this.caseId = caseResult.split(' ')[0];
					if (this.caseId !== undefined) {
						if (this.filesUploaded.length > 0) {
							this.attachFiles();
						}
						this.showOtp = false;
						this.showSpinner = false;
						this.handleConfirm();
					} else {
						this.showSpinner = false;
					}
				})
				.catch(error => {
					console.log(error);
					this.showSpinner = false;
				});
			}
		}).catch(error => {
			console.log(error);
			this.showSpinner = false;
		});
	}

	async handleConfirm() {
		if (this.caseId !== undefined) {
			const res = await LightningConfirm.open({
				message: 'Your ticket has been raised successfully. Please use Ticket No - #' + this.caseNumber + ' in all future correspondences',
				variant: 'header',
				label: 'Thank You!',
				theme: 'success',
			});

			if (res === true) {
				window.location.reload();
			}
		}
	}

	handleResendOtp() {
		sendOTP({ mobileNo: this.mobileNo }).then((result) => {
			this.message = 'OTP has been resent to your mobile no ******' + this.mobileNo.slice(-4);
			this.resend = true;
			this.OtpCode = result;
			this.sentTime = new Date().getTime();
			console.log('Contact admin');
		}).catch(error => {
			console.log(error);
		});

		sendEmailOTP({ personContactId: this.contactId }).then(() => {
			this.message = 'OTP has been resent to your mobile no ******' + this.mobileNo.slice(-4);
			this.resend = true;
			console.log('Contact admin');
		}).catch(error => {
			console.log(error);
		});
	}

	handleModalClose() {
		this.showOtp = false;
	}

	handleFileUploaded(event) {
		if (event.target.files.length > 0) {
			console.log(event.target.files);
			const MAX_FILE_SIZE = (3 * 1024 * 1024);
			for (let i = 0; i < event.target.files.length; i++) {
				let file = event.target.files[i];
				if (file.size > MAX_FILE_SIZE) {
					this.uploadError = 'File size exceeds the limit';
				} else {
					let reader = new FileReader();
					reader.onload = () => {
						let base64 = 'base64,';
						let content = reader.result.indexOf(base64) + base64.length;
						let fileContents = reader.result.substring(content);
						let extension = file.name.split('.');

						if (!this.acceptedFormats.includes('.' + extension[extension.length - 1])) {
							this.filesUploaded.push({ Title: 'Select file with valid extension' });
						} else {
							this.filesUploaded.push({ PathOnClient: file.name, Title: file.name, VersionData: fileContents });
						}
					};
					reader.readAsDataURL(file);
				}
			}
		}
	}

	attachFiles() {
		uploadFiles({ files: this.filesUploaded, caseId: this.caseId })
			.then(result => {
				if (result === true) {
					console.log('Files uploaded successfully');
				} else {
					console.log('Error uploading files');
				}
			})
			.catch(() => {
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