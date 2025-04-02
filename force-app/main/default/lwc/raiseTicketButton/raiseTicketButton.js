import { LightningElement, track, api, wire } from 'lwc';
import verifyStudent from '@salesforce/apex/MyCasesController.verifyStudent';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import getStudentNo from '@salesforce/apex/MyCasesController.getStudentNo';
import createCase from '@salesforce/apex/MyCasesController.createCase';
import getDependentPicklistValues from '@salesforce/apex/MyCasesController.getDependentPicklistValues';
import LightningAlert from "lightning/alert";
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import SalesforceBaseUrl from "@salesforce/label/c.SalesforceBaseUrl";
import Activate_Category_LSC from "@salesforce/label/c.Activate_Category_LSC";

export default class RaiseTicketButton extends NavigationMixin(LightningElement) {
	@api recordId;
	@api isClassic = false;
	@track showVerify = false;
	@track verified = false;
	@track showDetails = false;
	@track studentNo = '';
	@track purpose = '';
	@track subject = '';
	@track category = '';
	@track subCategory = '';
	@track isUploadFile = false;
	@track filesUploaded = [];
	@track error = '';
	@track caseId;
	@track account;
	@track message = '';
	@track closeDate;
	@track showToast = false;
	@track showSpinner = false;
	@track program;
	@track caseMap = {studentNo:'', purpose:'', source:'', category: '', subcat: '', sub: '', description: ''};
	@track options = [];
	@track enable = false;

	get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg'];
	}

	@track categories = [{ label: 'Admissions', value: 'Admissions' }, { label: 'Academics', value: 'Academics' },
	{ label: 'Assignment/Internal Assessment', value: 'Assignment/Internal Assessment' },
	{ label: 'Term End Examination', value: 'Term End Examination' }, { label: 'Logistics', value: 'Logistics' },
	{ label: 'Service Request', value: 'Service Request' },
	{ label: 'Others', value: 'Others' }];

	@track queryTypes = [{ label: 'Enquiry', value: 'Enquiry' }, { label: 'Feedback', value: 'Feedback' }, { label: 'Complaint', value: 'Complaint' }];

	connectedCallback() {
		if (this.recordId) {
			getStudentNo({ accId: this.recordId })
				.then(result => {
					this.studentNo = result.nm_StudentNo__c;
					this.program = result.nm_Program__r.Name;
					console.log(result);
					this.verified = true;
				})
				.catch(error => {
					console.log('No Student Found' + JSON.stringify(error));
				});
		} else {
			this.showVerify = true;
		}
	}

	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			// eslint-disable-next-line @lwc/lwc/no-api-reassignments
			this.recordId = currentPageReference.state.recordId;
			// eslint-disable-next-line @lwc/lwc/no-api-reassignments
			this.isClassic = false;
		}
	}

	handlePurposeChange(event) {
		this.purpose = event.target.value;
		this.caseMap.studentNo = this.studentNo;
		this.caseMap.purpose = event.target.value;
		this.caseMap.source = 'SFDC User';
		if (this.purpose === 'Feedback' && this.category === 'Learner Support Center') {
			this.category = '';
			this.subCategory = '';
			this.subject = '';
		}
		const learnerSupport = { label: 'Learner Support Center', value: 'Learner Support Center' };
		let updatedCategories = [...this.categories];

		if (Activate_Category_LSC === 'Yes') {
			if ((this.purpose === 'Enquiry' || this.purpose === 'Complaint') ) {
				if (!updatedCategories.some(category => category.value === learnerSupport.value)) {
					updatedCategories.splice(1, 0, learnerSupport);
					//updatedCategories.push(learnerSupport);
					// Sort categories alphabetically
					//updatedCategories.sort((a, b) => a.label.localeCompare(b.label));
				}
			} else {
				const index = updatedCategories.findIndex(category => category.value === learnerSupport.value);
				if (index !== -1) {
					updatedCategories.splice(index, 1);
				}
			}
		}
		
		// Sort categories alphabetically, except for 'Others'
		updatedCategories = updatedCategories
        .filter(category => category.value !== 'Others')
        .sort((a, b) => a.label.localeCompare(b.label));

        // Push 'Others' to the end of the list
        updatedCategories.push({ label: 'Others', value: 'Others' });

		
		this.categories = updatedCategories;
	}

	handleCategoryChange(event) {
		this.options = [];
		this.subCategory = '';
		this.subject = '';
		this.category = event.target.value;

		getDependentPicklistValues({ categoryValue: this.category, program: this.program }).then(result => {
			for (let i = 0; i < result.length; i++) {
				this.options = [...this.options, { label: result[i], value: result[i] }];
				console.log(this.options);
			}
		})
			.catch(error => {
				console.log(error);
			});
		this.subject = this.category;
		this.caseMap.sub = this.subject;
		if (this.category === 'Learner Support Center') {
			this.enable = false;
		}
		else {
			this.enable = true;
		}
		//this.subject = this.category;
		// this.enable = true;
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

	handleVerify() {
		verifyStudent({ sno: this.studentNo }).then(result => {
			if (JSON.stringify(result) !== '{}') {
				this.message = 'Student Verified';
				this.account = result;
				this.program = result.nm_Program__r.Name;
				this.verified = true;
				this.showDetails = true;
			} else {
				this.message = 'No match found for entered Student No. Please Enter a valid Student No';
			}
		});
	}

	handleSubmit() {

		// handle Error.
		if(Object.keys(this.caseMap).length === 0 || !('studentNo' in this.caseMap) || this.isEmpty(this.caseMap.category) 
			|| !('sub' in this.caseMap) || this.isEmpty(this.caseMap.sub) || !('description' in this.caseMap) || this.isEmpty(this.caseMap.description) 
			|| (this.category !== 'Learner Support Center' && this.isEmpty(this.caseMap.subcat.trim()))
		    || (this.isUploadFile && this.filesUploaded.length === 0)) {
			this.showToast = true;
			this.hideToast();
			return;
		}
			
		this.showSpinner = true;
		createCase({ caseMap: this.caseMap }).then(result => {
			this.caseId = result.split(' ')[0];
			if (this.caseId !== undefined) {
				this.showSpinner = false;
				if (this.purpose === 'Feedback') {
					let msg = `Thank you for your feedback for ${this.subject}. We have taken note of it and forwarded it to the relevant teams.`;
					this.showMessage(msg,'success','Success!');
				} else {
					this.showMessage('Your ticket has been raised successfully.','success','Success!');
				}

				if (this.filesUploaded.length > 0) {
					this.attachFiles();
				}
				if (this.recordId === '') {
					this.verified = false;
					this.message = '';
					this.navigateToRecordPage();
				} else {
					this.navigateToRecordPage();
				}
			}
		})
		.catch(error => {
			console.log(error);
		});
	}

	isEmpty(str) {
		if (typeof str == 'undefined' || !str || str.length === 0 || str === "" || !/[^\s]/.test(str) || /^\s*$/.test(str) || str.replace(/\s/g,"") === ""){
			return true;
		}
		return false;
	}

	hideToast() {
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setInterval(() => {
			this.showToast = false;
		}, 4000);
	}

	handleFileUploaded(event) {
		this.error = '';
		if (event.target.files.length > 0) {
			console.log(event.target.files);
			const MAX_FILE_SIZE = (3 * 1024 * 1024);
			for (let i = 0; i < event.target.files.length; i++) {
				let file = event.target.files[i];
				if (file.size > MAX_FILE_SIZE) {
					this.error = 'File size exceeds the limit';
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
			.catch(error => {
				console.log(error);
			});
	}

	showMessage(msg, theme, label) {
		LightningAlert.open({
			message: msg,
			theme: theme,
			label: label,
			variant: 'header',
		});
	}

	navigateToRecordPage() {
		console.log('isClassic ==>'+this.isClassic);
		if(!this.isClassic) {
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: this.caseId,
					objectApiName: 'Case',
					actionName: 'view'
				}
			});
		} else {
			//window.location.assign('/' + this.caseId);
			window.location.href = SalesforceBaseUrl + this.caseId;
		}
	}
}