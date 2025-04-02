/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 04--03--2025
 * @last modified by  : @Ravi
**/
import { LightningElement, api, track } from 'lwc';
import getCaseDetails from '@salesforce/apex/MyCasesController.getCaseDetails';
//import updateCaseDisclamerflag from '@salesforce/apex/MyCasesController.updateCaseDisclamerflag';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import updateCaseStatus from '@salesforce/apex/MyCasesController.updateCaseStatus';
import reopenCase from '@salesforce/apex/MyCasesController.reopenCase';
import addComment from '@salesforce/apex/MyCasesController.addComment';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';

export default class CaseView extends LightningElement {
	
	@api accDetails;
	@api recordId;
	@api navLst;
	@api token;
	@track msgList;
	@track caseLst;
	@track isOpen = false;
	@track addComment = false;
	@track isFeedback = false;
	@track comment = '';
	@track reason = '';
	@track filesUploaded = [];
	@track error = '';
	@track createdBy = '';
	@track placeholder = '';
	@track hitTime;
	@track newNav;
	@api isView = false;
	@track showEscalationLevel = false;
	@track isAdmissionCancellation = false;
	@track disclaimerflag = [false];
	@track hideDescription =false;    //true if sub-category is project title approval
	fnames = '';
	accName = '';
	reopen = false;
	close = false;
	isReopen = true;
	isMsgAvialable = false;
	showSpinner = false;
	caseDetail;
//&& this.addComment == false && this.isOpen == false;
	get buttonstatus(){
		console.log('isAdmissionCancellation:'+this.isAdmissionCancellation);
		return this.isAdmissionCancellation ? !this.disclaimerflag[0] : false ;
	}
	//By closing this ticket, I confirm that my admission cancellation request will be withdrawn, and I will continue as an enrolled student.
	get cboptions() {
        return [
            { label: '', value: 'true' },
        ];
    }

	reOpenReasons = [{ label: 'Not happy with the resolution', value: 'Not happy with the resolution' }, 
		{ label: 'Additional information needed', value: 'Additional information needed' },
		{ label: 'New Query', value: 'New Query' },
		{ label: 'Erroneously closed by the counsellor', value: 'Erroneously closed by the counsellor' }, 
		{ label: 'Erroneously closed by system', value: 'Erroneously closed by system' }];

	get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg'];
	}

	formats = [
		'font',
		'size',
		'bold',
		'italic',
		'underline',
		'list',
		'indent',
		'align',
		'link',
		'clean',
		'table',
		'header',
	];

	connectedCallback() {
		const queryString = window.location.search.substring(1);
		const params = new URLSearchParams(queryString);
		this.recordId = params.get('id');
		this.navLst = JSON.parse(decodeURIComponent(params.get('navLst')));
		this.token = params.get('token');
		this.accDetails = JSON.parse(decodeURIComponent(params.get('acc')));
		
		this.handleCookies();
		this.getCaseInfo();
	}

	renderedCallback() {
		let diff = Date.now() - this.hitTime;
		console.log(this.hitTime);
		if (diff > 3600000 || this.hitTime === undefined) {
			LightningAlert.open({
				message: 'Please login again',
				theme: 'error',
				label: 'Session Expired!',
				variant: 'header',
			});
			window.location = 'https://studentzone-ngasce.nmims.edu/';
		}
	}


	getCaseInfo() {
		getCaseDetails({ caseId: this.recordId }).then(result => {
			// Determine whether to show the Escalation Level
			if (result.Escalation_Level__c === 1 || result.Escalation_Level__c === 2 || result.Escalation_Level__c === 3 || result.Escalation_Level__c === 4) {
				this.showEscalationLevel = true;
			} else {
				this.showEscalationLevel = false;
			}

			if(!this.navLst.includes('#' + result.CaseNumber)) {
				this.navLst.push('#' + result.CaseNumber);
			}
			let typeOfObject = result.Lead_Registrants_Student__c === 'Lead' ? 'Lead' : 'Account';
            let recId = typeOfObject === 'Lead' ? result.Lead__c : result.AccountId;
			
			this.caseDetail = {escalationNumber: String(result.Escalation_Level__c), caseId: result.Id, recordId: recId, typeOfObject: typeOfObject  };
			console.log(result);
			if (this.isView === true) {
				this.navLst.push('#' + result.CaseNumber);
				const navEvent = new CustomEvent('updatenavevent', {
					detail: this.navLst, bubbles: true
				});
				this.dispatchEvent(navEvent);
			}

			if (result.Student_Purpose__c === 'Feedback') {
				this.isFeedback = true;
			} else {
				console.log(result.ReOpenable_Period__c);
				let originalDate = new Date(result.ClosedDate);
				let today = new Date();
				let newDate = new Date(originalDate.getTime() + (result.ReOpenable_Period__c * 24 * 60 * 60 * 1000));
				let lastName;
				if (result.Account.LastName === '.') {
					lastName = '';
				} else {
					lastName = result.Account.LastName;
				}
				this.accName = result.Account.FirstName + ' ' + lastName;
				if (result.Student_Status__c !== 'Closed') {
					this.isOpen = true;
				} else if (result.Student_Status__c === 'Closed' && newDate > today) {
					this.isReopen = false;
				}
			}
			if(result.Student_Category__c == 'Admissions' && result.Student_Sub_Categories__c == 'Admission Cancellation')
			{
				this.isAdmissionCancellation = true;
			}
			console.log('===='+(result.Student_Sub_Categories__c === 'Project title Approval'));
			if(result.Student_Sub_Categories__c === 'Project title Approval')
			{ console.log('hideDescription==>'+result.Student_Sub_Categories__c);
               this.hideDescription=true;
			}
			
			this.caseLst = result;

		})
			.catch(error => {
				console.log(error);
			});
	}

	handleAddComment() {
		this.reopen = false;
		this.close = false;
		this.placeholder = 'Add a comment';
		this.addComment = true;
		this.disclaimerflag = [false];
		this.isAdmissionCancellation = false;
	}

	async handleCaseUpdate() {
		this.showSpinner = true;
		updateCaseStatus({ caseId: this.recordId,disclaimerflag: this.disclaimerflag[0] }).then(() => {
			// window.location.reload();
			LightningAlert.open({
				message: 'Ticket Closed Successfully',
				theme: 'success',
				label: 'Success!',
				variant: 'header',
			});
			this.getCaseInfo();
			this.isOpen = false;
			this.showSpinner = false;
		})
		.catch(error => {
			console.log(error);
			this.showSpinner = false;
		});
	}

	// async handleCaseDisclamerflagUpdate() {
	// 	updateCaseDisclamerflag({ caseId: this.recordId,disclaimerflag: this.disclaimerflag[0] }).then(() => {
	// 	})
	// 	.catch(error => {
	// 		console.log(error);
	// 	});
	// }
	handleChange(e) {
        this.disclaimerflag = e.detail.value;
    }

	handleCloseCase() {
		this.placeholder = 'Add a closing comment';
		this.addComment = true;
		this.close = true;
		this.disclaimerflag = [false];
		if(this.caseLst.Student_Category__c == 'Admissions' && this.caseLst.Student_Sub_Categories__c == 'Admission Cancellation')
		{
			this.isAdmissionCancellation = true;
		}
	}

	reopenCase() {
		this.placeholder = 'Add a reopening comment';
		this.addComment = true;
		this.reopen = true;
		this.disclaimerflag = [false];
		this.isAdmissionCancellation = false;
	}

	async handleReopenCase() {
		this.showSpinner = true;
		reopenCase({ caseId: this.recordId, reason: this.reason }).then(isSuccess => {
			if(isSuccess) {
				LightningAlert.open({
					message: 'Ticket Re-Opened Successfully',
					theme: 'success',
					label: 'Success!',
					variant: 'header',
				});
				this.handleComment();
				this.reopen = false;
				this.showSpinner = false;
			} else {
				this.showSpinner = false;
				LightningAlert.open({
					message: 'Re-Open Attempt failed, Error Occured!',
					theme: 'error',
					label: 'Important Message!',
					variant: 'header',
				});
			}
			
		})
		.catch(error => {
			console.log(error);
			this.showSpinner = false;
		});
	}

	handleCommentChange(event) {
		this.comment = event.detail.value;
	}

	handleReasonChange(event) {
		this.reason = event.detail.value;
		console.log('this.reason ==>'+this.reason);
	}

	async insertComment() {
		console.log('method called insert Comment');
		if (this.comment.replace(/<[^>]+>/g, '').trim().length > 0) {
			await addComment({ comment: this.comment, caseId: this.recordId, isReopen: this.reopen }).then(() => {
				console.log('method called insert Comment inside');
				this.addComment = false;
				this.getCaseInfo();
				this.template.querySelector('c-case-view-attachment-comp').getAttachments();
				this.template.querySelector('c-case-view-msg-lst-comp').getEmailMessages();
				console.log('child method called ==>');
				console.log(this.template.querySelector('c-case-view-msg-lst-comp').getEmailMessages());
				this.comment = '';
				this.showSpinner = false;
			})
			.catch(error => {
				console.log(error);
				this.showSpinner = false;
			});
		} else {
			this.error = 'Please fill the field';
			this.showSpinner = false;
		}
	}

	async handleComment() {
		this.showSpinner = true;
		if (this.filesUploaded.length > 0) {
			await this.attachFiles();
		} else {
			await this.insertComment();
		}
	}

	formValidate() { 
		const allValid = [
			...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea')
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);

		return allValid;
	}

	async handleSubmit() {
		if(this.formValidate()) {
			if (this.reopen === true) {
				await this.handleReopenCase();
	
			} else if (this.close === true) {
				const result = await LightningConfirm.open({
					message: 'Are you sure you want to close the case?',
					variant: 'header',
					label: 'Please Confirm',
					theme: 'error',
				});
				console.log(result);
				if (result === true ) {
					console.log(result);
					await this.handleComment();
					await this.handleCaseUpdate();
				}
			} else {
				this.handleComment();
			}
		} 
	}

	handleFileUploaded(event) {
		this.error = '';
		if (event.target.files.length > 0) {
			console.log(event.target.files);
			const MAX_FILE_SIZE = (3 * 1024 * 1024);
			let totalFileSize = this.getAttachedFileSize();
			for (let i = 0; i < event.target.files.length; i++) {
				let file = event.target.files[i];
				totalFileSize = parseInt(file.size, 10) + totalFileSize;
				if (file.size > MAX_FILE_SIZE || totalFileSize > MAX_FILE_SIZE) {
					this.error = 'Total File size exceeds the limit';
				} else {
					let reader = new FileReader();
					reader.onload = () => {
						let base64 = 'base64,';
						let content = reader.result.indexOf(base64) + base64.length;
						let fileContents = reader.result.substring(content);
						let extension = file.name.split('.');
						if (!this.acceptedFormats.includes('.' + extension[extension.length - 1])) {
							this.error = 'Select file with valid extension';
						} else {
							this.fnames = this.fnames + '<br/>' + file.name;
							this.filesUploaded.push({ PathOnClient: file.name, Title: file.name, VersionData: fileContents, Size: file.size });
						}
					};
					reader.readAsDataURL(file);
				}
			}
		}
	}

	getAttachedFileSize() {
		let fileSize = 0;
		if(this.filesUploaded.length > 0) {
			this.filesUploaded.forEach(element => {
				fileSize = parseInt(element.Size, 10) + fileSize;
			});
		} 
		return fileSize;
	}

	handleRemove(event) {
		let title = event.target.dataset.fid;
		let index = this.filesUploaded.findIndex(obj => obj.Title === title);
		this.filesUploaded.splice(index, 1);
		this.fnames = this.fnames.replace(title, "");
	}

	async attachFiles() {
		await uploadFiles({ files: this.filesUploaded, caseId: this.recordId })
			.then(result => {
				if (result === true) {
					this.comment = this.comment + '<br/>Files attached: ' + this.fnames;
					this.insertComment();
					this.showUpload = false;
					this.filesUploaded = [];
					this.fnames = '';
				} else {
					//this.showToastMessage('Error','Error uploading files', 'error');
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	goBack() {
		window.location.assign('/apex/MyTickets?token=' + this.token);
		/*console.log(this.navLst);
		this.navLst = this.navLst.filter(value => !value.toString().includes('#'));
		const selectEvent = new CustomEvent('mycustomevent', {
			detail: this.navLst, bubbles: true
		});
		this.dispatchEvent(selectEvent);*/
	}

	handleNav(event) {
		let nav = event.currentTarget.dataset.id;
		if (nav === 'MY TICKETS') {
			window.location.assign('/apex/MyTickets?token=' + this.token);
		} else if (nav === 'STUDENT SUPPORT') {
			window.open('https://studentzone-ngasce.nmims.edu/studentportal/student/connectWithUs');
		} else if (nav === 'STUDENT ZONE') {
			window.open('https://studentzone-ngasce.nmims.edu/studentportal/home');
		}
	}

	handleCookies() {
		const cookies = document.cookie.split(';');
		cookies.forEach(cookie => {
			const [name, value] = cookie.trim().split('=');
			if (name === 'time') {
				this.hitTime = value;
			}
		});
		console.log('this.hitTime 1==>'+this.hitTime);
	}

	showToolTip() {
		console.log('mouseOver on');
		if(this.template.querySelector('c-case-view-call-comp')) {
			this.template.querySelector('c-case-view-call-comp').showToolTip();
		}
	}
}