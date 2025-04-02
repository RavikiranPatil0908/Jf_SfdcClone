/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api } from 'lwc';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import createCase from '@salesforce/apex/MyCasesController.createCase';
import getDependentPicklistValues from '@salesforce/apex/MyCasesController.getDependentPicklistValues';
import LightningAlert from "lightning/alert";
import StudentZoneBaseUrlLabel from '@salesforce/label/c.Student_Zone_Base_Url';
import getSchedulingTask from "@salesforce/apex/MyCasesController.getSchedulingTask";
import getAccountId from "@salesforce/apex/MyCasesController.getAccountId";
import scheduleCall from "@salesforce/apex/MyCasesController.scheduleCall";
import Activate_Category_LSC from "@salesforce/label/c.Activate_Category_LSC";

const timeRangelst = ['12 am - 1 am','1 am - 2 am','2 am - 3 am','3 am - 4 am','4 am - 5 am','5 am - 6 am','6 am - 7 am','7 am - 8 am','8 am - 9 am','9 am - 10 am','10 am - 11 am','11 am - 12 pm','12 pm - 1 pm','1 pm - 2 pm','2 pm - 3 pm','3 pm - 4 pm','4 pm - 5 pm','5 pm - 6 pm','6 pm - 7 pm','7 pm - 8 pm','8 pm - 9 pm','9 pm - 10 pm','10 pm - 11 pm','11 pm - 12 am'];

export default class CreateCaseComp extends LightningElement {
   
	@track accDetails;
	@track caseId;
	@track subject = '';
	@track category = '';
	@track subCategory = '';
	@track proposedResearchTopic ='';
	@track problemStatement ='';
	@track businessIsssues ='';
	@track relevanceOfResearch ='';
	@track researchObjective ='';
	@track researchHypothesis ='';
    @track researchMethodology ='';
    @track expectedOutcomes ='';
	@track isUploadFile = false;
	@track filesUploaded = [];
	@track error = '';
	@track studentNo;
	@track closeDate;
	@track enable = false;
	@track showCaseView = false;
	@track showToast = false;
	@track showSpinner = false;
	@track disabledSubject =false;
	@track isFileUploadMandatory = false;
	@track fileUploadInstruction ='';
	@track lastName;
	@track caseMap = {studentNo:'', purpose:'', source:'', category: '', subcat: '', sub: '', description: '', isSchedule: '' , topic: '', probStatement: '', businessIssu: '', relevance:'', researchObj:'',researchHypo: '',researchMetho:'', expectedOutcome:''};

	@api navLst = ['STUDENT ZONE', 'STUDENT SUPPORT', 'MY TICKETS', 'CREATE A TICKET'];
	headerTitle = 'Raise a Ticket';
	scheduleCalls = false;
	purpose;
	toastMsg ='';
	msg = '';
	program;
	hitTime;
	disbaleBtn = false;
	disbaleSubmitBtn = false;

	// Schedule Calls
	@track showEscalationModel = false; 
	@track callSchedulingDate = [];
	@track callSchedulingTimeRange = [];
	@track isCallSchedulingModalOpen = false;
	@track isCallSchedulingRecordContains = false;
	@track timeRange = timeRangelst;
	@track timeRangeSelected = [];
	@track schedulingErrorMsg = '';
	selectedDate;
	selectedTimeRange;
	selectedTimeRangeValue;
	selectedId;
	accountId;
	@track isCallSchedulingConfirm = false;
	@track caseDetail;
	@track isCommentButtonAvailableForCallScheduling = false;
	@track showPopup = { title: '', message: '', variant: '' };


	@track options = [];
	get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg'];
	}

	@track categories = [{ label: 'Admissions', value: 'Admissions' }, { label: 'Academics', value: 'Academics' },
	{ label: 'Assignment/Internal Assessment', value: 'Assignment/Internal Assessment' },
	{ label: 'Term End Examination', value: 'Term End Examination' }, { label: 'Logistics', value: 'Logistics' },
	{ label: 'Service Request', value: 'Service Request' }, { label: 'Others', value: 'Others' }];

	@track queryTypes = [{ label: 'Enquiry', value: 'Enquiry' }, { label: 'Feedback', value: 'Feedback' }, { label: 'Complaint', value: 'Complaint' }];

	get AllowForFileUploadToTEEUnabletoJoin () { 
		return ['Camera/Microphone permission issue','Cannot join back the test','Project payment issue','Unable to click on Exam Link','Unable to type descriptive answers']
	};
	get AllowForFileUploadToTEEPaymentIssue () {
		return ['Exam Registration payment issue'];
	};
	get AllowForFileUploadToLogisticsDamagedDoc () {
		return ['Damaged Document'];
	};
	get AllowForFileUploadToLogisticsmissingBook () { 
		return['Book missing from the study kit'];
	};
	get AllowForFileUploadToAcadmics () {
		return ['E-Books different from books received'];
	};
	get AllowForFileUploadToOtherCategory () { 
		return ['Refund not received'];
	}

	connectedCallback() {
		const queryString = window.location.search.substring(1);
		const params = new URLSearchParams(queryString);
		this.token = params.get('token');
		this.scheduleCalls = params.get('type') === 'true' ? true : false;
		this.accDetails = JSON.parse(decodeURIComponent(params.get('acc')));
		this.program = this.accDetails.program;
		if (this.accDetails.LastName === '.') {
			this.lastName = '';
		} else {
			this.lastName = this.accDetails.LastName;
		}

		if(this.scheduleCalls) {
			this.queryTypes = this.queryTypes.filter(item => item.label !== 'Feedback');
			this.headerTitle = 'Schedule a Callback';
		}

		// set cookie value.
		this.handleCookies();

	}

	renderedCallback() {
		var diff = Date.now() - this.hitTime;
		// console.log('diff ' + diff);
		if (diff > 3600000) {
			LightningAlert.open({
				message: 'Please login again',
				theme: 'error',
				label: 'Session Expired!',
				variant: 'header',
			});
			window.location = StudentZoneBaseUrlLabel;
		}
	}

	handlePurposeChange(event) {
		this.purpose = event.target.value;
		if (this.purpose === 'Feedback') {
			this.msg = 'Please note your feedback will be raised to the concerned team however if you are seeking a reply please raise a ticket as Enquiry instead of feedback.';
		} else {
			this.msg = '';
		}
		this.caseMap.studentNo = this.studentNo;
		this.caseMap.purpose = event.target.value;
		this.caseMap.source = 'Web App';

        if (this.purpose === 'Feedback' && this.category === 'Learner Support Center') {
            this.category = '';
            this.subCategory = '';
            this.subject = '';
        }
        
		const learnerSupport = { label: 'Learner Support Center', value: 'Learner Support Center' };
		const careerServices = { label: 'Career Services', value: 'Career Services' };
		let updatedCategories = [...this.categories];
		
		if (this.purpose === 'Enquiry' || this.purpose === 'Complaint') {
			// Add Learner Support Center if not already present
			if (!updatedCategories.some(category => category.value === learnerSupport.value)) {
				updatedCategories.splice(1, 0, learnerSupport);  
			}
			// Add Career Services if not already present
			if (!updatedCategories.some(category => category.value === careerServices.value)) {
				updatedCategories.splice(2, 0, careerServices);
			}
		} else {
			// Remove Learner Support Center if it exists
			const indexLearner = updatedCategories.findIndex(category => category.value === learnerSupport.value);
			if (indexLearner !== -1) {
				updatedCategories.splice(indexLearner, 1);
			}
		
			// Remove Career Services if it exists
			const indexCareer = updatedCategories.findIndex(category => category.value === careerServices.value);
			if (indexCareer !== -1) {
				updatedCategories.splice(indexCareer, 1);
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
		this.disabledSubject=false;
		this.options = [];
		this.category = event.target.value;
		this.showSpinner = true;
		getDependentPicklistValues({ categoryValue: this.category, program: this.program }).then(result => {
			for (let i = 0; i < result.length; i++) {
				this.options = [...this.options, { label: result[i], value: result[i] }];
			}
			console.dir(this.options);
			this.subject = this.category;
			
			this.caseMap.category = this.category;
			this.showSpinner = false;

			// reset sub category
			this.subCategory = '';
			this.caseMap.subcat = '';
			this.caseMap.sub = this.subject;
		}).catch(error => {
			console.log(error);
			this.showSpinner = false;
		});

        if (this.category === 'Learner Support Center') {
            this.enable = false;
        }
        else {
            this.enable = true;
        }
        console.log('enable ---->' + this.enable);
        this.subject = this.category;
        //this.enable = true;
        this.caseMap['category'] = this.category; 
		         
	}

	handleChange(event) {
		this.disabledSubject = false;
		this.isFileUploadMandatory = false;
		this.subCategory = event.detail.value;
		console.log('subCategory ==>'+this.subCategory);
		if(this.subCategory === 'Project title Approval'){
           this.disabledSubject = true;
		}
		// console.log('AllowForFileUploadToTermandExamination==>'+this.AllowForFileUploadToTermandExamination);
		if (this.AllowForFileUploadToTEEUnabletoJoin.includes(this.subCategory)) {
			this.isFileUploadMandatory = true;
			this.fileUploadInstruction ='Please share the picture of the error message with the timestamp (Date and Time needs to be visible).';
        } else if(this.AllowForFileUploadToTEEPaymentIssue.includes(this.subCategory)) {
			this.isFileUploadMandatory = true;
			this.fileUploadInstruction ='Please share the picture of the error message and the picture of the transaction details.';
		} else if (this.AllowForFileUploadToAcadmics.includes(this.subCategory) || this.AllowForFileUploadToLogisticsmissingBook.includes(this.subCategory)) {
			this.isFileUploadMandatory = true;
			this.fileUploadInstruction ='Please share the picture of the study kit including all the books received.'; 
		} else if (this.AllowForFileUploadToOtherCategory.includes(this.subCategory)) {
			this.isFileUploadMandatory = true;
			this.fileUploadInstruction ='Please could you share the screenshot of the latest bank statement.';
		} else if (this.AllowForFileUploadToLogisticsDamagedDoc.includes(this.subCategory)) {
			this.isFileUploadMandatory = true;
			this.fileUploadInstruction ='Please share the picture of the damaged document/certificate. Once the approval is received, the student would have to send the damaged document to the University, and only post that will the new certificate be printed and dispatched.';
		} else {
            this.isFileUploadMandatory = false;
            this.fileUploadInstruction ='';
        }

		this.subject = this.category + ' - ' + this.subCategory;
		this.caseMap.subcat = this.subCategory.trim();
		this.caseMap.sub = this.subject;
	}

	handleSubjChange(event) {
		this.subject = event.target.value;
		this.caseMap.sub = this.subject;
	}

	handleDescChange(event) {
		this.caseMap.description = event.target.value;
	}
	handleTopicChange(event) {
		this.proposedResearchTopic = this.limitWords(event.target.value, 30);
		this.caseMap.topic = this.proposedResearchTopic;
	}
	
	handleProblemChange(event) {
		this.problemStatement = this.limitWords(event.target.value, 500);
		this.caseMap.probStatement = this.problemStatement;
    }
	handleBusinessIssueChange(event) {
		this.businessIsssues = this.limitWords(event.target.value, 1500);
		this.caseMap.businessIssu = this.businessIsssues;
	}
	handleRelevanceChange() {
		this.relevanceOfResearch = this.limitWords(event.target.value, 500);
		this.caseMap.relevance = this.relevanceOfResearch;
	}
    handleObjectiveChange(event) {
		this.researchObjective = this.limitWords(event.target.value, 200);
		this.caseMap.researchObj = this.researchObjective;
	}
	handleHyponthesisChange(event) {
		this.researchHypothesis = this.limitWords(event.target.value, 500);
		this.caseMap.researchHypo = this.researchHypothesis;
    }
	handleMethodologyChange(event) {
		this.researchMethodology = this.limitWords(event.target.value, 1500);
		this.caseMap.researchMetho = this.researchMethodology;
    }
	handleOutcomeChange(event) {
		this.expectedOutcomes = this.limitWords(event.target.value, 500);
		this.caseMap.expectedOutcome = this.expectedOutcomes;
	}
	handleCheckChange(event) {
		this.isUploadFile = event.target.checked;
	}

	limitWords(text, maxWords) {
		let words = text.trim().split(/\s+/); //split by spaces
		return words.length > maxWords ? words.slice(0, maxWords).join(" ") : text;   
	}
	refreshComponent() {
		const inputFields = this.template.querySelectorAll('lightning-input-field');
		if (inputFields) {
			inputFields.forEach(field => {
				field.reset();
			});
		}
	}

	async handleSubmit() {
		if(Object.keys(this.caseMap).length === 0 || !('studentNo' in this.caseMap) || this.isEmpty(this.caseMap.category) 
			|| !('sub' in this.caseMap) || this.isEmpty(this.caseMap.sub) 
		    || (this.subCategory !== 'Project title Approval' && (!('description' in this.caseMap) || this.isEmpty(this.caseMap.description)))
			|| this.checkEmpty()
            || (this.isUploadFile && this.filesUploaded.length === 0 && !this.isFileUploadMandatory)) {
			this.toastMsg ='Fill all the mandatory details';
			this.showToast = true;
			this.hideToast();
			return;
		}
		if((this.isFileUploadMandatory && (this.filesUploaded.length === 0))){
			console.log('length---->' + this.filesUploaded.length);
			this.toastMsg ='Attachment is mandatory for this issue.';
			this.showToast = true;
			this.hideToast();
			return;
		}
    
        console.log('submit');
		
        if(this.scheduleCalls && (this.category != 'Career Services')) {
            this.caseMap.isSchedule = 'yes';
        }
        this.disbaleSubmitBtn = true;
        this.showSpinner = true;
        await createCase({ caseMap: this.caseMap }).then(result => {
            this.caseId = result.split(' ')[0];
            console.log('create');
            if (this.caseId !== undefined) {
				//validation msg for career services;
				if (result.startsWith('You can only have one active callback request')) {
					this.toastMsg =result;
					this.showToast = true;
					this.showSpinner = false;
					this.disbaleSubmitBtn = false;
					this.hideToast();
					return;
				}
                this.showSpinner = false;
				let message='';
				if(this.category == 'Career Services'){
					message='Your ticket has been raised successfully.You will receive a call back from our Team';
				} else{
					message = 'Your ticket has been raised successfully.';
				}
                
                if (this.purpose === 'Feedback') {
                    message = `Thank you for your feedback for ${this.subject}. We have taken note of it and forwarded it to the relevant teams.`;
                }
                this.showHtmlMessage('Success!', message, 'success');
                
                // To upload the files.
                if (this.filesUploaded.length > 0) {
                    this.attachFiles();
                } 

                // To schedule calls
                if(this.scheduleCalls && (this.category !='Career Services')) {
                    this.getAccountId();
                    this.getScheduleSlots();
                } else {
					setInterval(() => {
						this.redirectToCaseDetails();
					}, 3000);
                }
            } 
        }).catch(error => {
            console.log(JSON.stringify('error---->' + error));
            this.showToast = false;
            this.disbaleSubmitBtn = false;
            this.showHtmlMessage('Error!', 'Something went wrong, kindly try again.', 'error');
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
		}, 6000);
	}

	checkEmpty() {
		return (this.subCategory === 'Project title Approval' && (!('topic' in this.caseMap) || this.isEmpty(this.caseMap.topic) 
		|| !('probStatement' in this.caseMap) || this.isEmpty(this.caseMap.probStatement) 
		||  !('businessIssu' in this.caseMap) || this.isEmpty(this.caseMap.businessIssu) 
		|| !('relevance' in this.caseMap) || this.isEmpty(this.caseMap.relevance) 
		|| !('researchObj' in this.caseMap) || this.isEmpty(this.caseMap.researchObj) 
		||  !('researchHypo' in this.caseMap) || this.isEmpty(this.caseMap.researchHypo) 
		|| !('researchMetho' in this.caseMap) || this.isEmpty(this.caseMap.researchMetho) 
		|| !('expectedOutcome' in this.caseMap) || this.isEmpty(this.caseMap.expectedOutcome)));
	}



	async getScheduleSlots() {
		this.showSpinner = true;
		this.isCallSchedulingModalOpen = true;
		this.isCommentButtonAvailableForCallScheduling = false;
		let dateLst = [];
		this.callSchedulingTimeRange = [];
		await getSchedulingTask({ escalationLevel: '1', caseId: this.caseId, recordId: this.accountId, callType: 'Regular', programName: this.program, calledFor: ''})
		.then(result => {
			console.log('result');
			console.log(JSON.stringify(result));
			let mapOfDateVsTimeRange = result.mapOfDateVsTimeRange;
			let errorMsg = 'Kindly try again later as no call schedule is active. \n You can add a comment to the ticket so the concern team will reply on the same.';
			if (result.status === 'error') {
				this.schedulingErrorMsg = result.message === 'Something Went Wrong' ? errorMsg : result.message;
				this.isCommentButtonAvailableForCallScheduling = result.message === 'Something Went Wrong' ? true : false;
			}
			
			dateLst =  Object.keys(mapOfDateVsTimeRange); 
			this.isCallSchedulingRecordContains = dateLst.length > 0 ? true : false;
			if (!this.schedulingErrorMsg && !this.isCallSchedulingRecordContains) {
				this.schedulingErrorMsg = errorMsg;
				this.isCommentButtonAvailableForCallScheduling = true;
			}
			dateLst.sort((a,b) => Date.parse(a) - Date.parse(b));
			this.callSchedulingDate = [];
			dateLst.forEach(element => {
				this.callSchedulingDate.push({
					value: element, label: (new Date(element)).toLocaleDateString('en-GB')
				})
				let timeRange = mapOfDateVsTimeRange[element];
				let timeRangeInOrder = [];
				this.timeRange.forEach(time => {
					timeRange.forEach(resultTimeRange => {
						if (resultTimeRange.timeRange === time) {
							timeRangeInOrder.push({label : resultTimeRange.timeRange, value : resultTimeRange.timeRange + '|' + resultTimeRange.schedulingId});
						}
					})
				})
				this.callSchedulingTimeRange[element] = timeRangeInOrder;
			})

			console.log(JSON.stringify(this.callSchedulingDate));
			console.log(JSON.stringify(this.callSchedulingTimeRange));
			this.showSpinner = false;
		})
		.catch(e => {
			this.showSpinner = false;
			this.callSchedulingDate = [];
			console.log('e ==?', JSON.stringify(e))
		})
	}

	onScheduleDate(event) {
		let value = event.detail.value;
		this.selectedDate = value;
		this.timeRangeSelected = this.callSchedulingTimeRange[value] ;
		console.log('this.timeRangeSelected --> ' + JSON.stringify(this.callSchedulingTimeRange))
		console.log('this.timeRangeSelected --> ' + JSON.stringify(this.timeRangeSelected))
		this.template.querySelectorAll('.dateCls').forEach(element => {
			if (element.dataset.buttonid === value ) {
				element.classList.remove('slds-button_text-destructive')
				element.classList.add('slds-button_destructive')
			} else {
				element.classList.remove('slds-button_destructive')
				element.classList.add('slds-button_text-destructive')
			}
		})
	}

	onScheduleTimeRange(event) {
		console.log('value', event)
		console.log('value', JSON.stringify(event.detail))
		this.selectedTimeRangeValue = event.detail.value;
		let val = event.detail.value.split('|');
		this.selectedTimeRange = val[0];
		this.selectedId = val[1];
		this.isCallSchedulingModalOpen = false;
		this.isCallSchedulingConfirm = true;
		this.disbaleBtn = false;
	}

	oncloseModalCallScheduleConfirm() {
		this.isCallSchedulingConfirm = false;
		this.isCallSchedulingModalOpen = true;
	}

	async scheduleCall() {
		this.disbaleBtn = true;
		this.showSpinner = true;
		let scheduleCallWrapper = {
			scheduleId : this.selectedId, 
			scheduleDate: this.selectedDate, 
			scheduleTimeRange: this.selectedTimeRange, 
			scheduleEscalationLevel: '1', 
			recordId : this.accountId, 
			typeOfObject: 'Account', 
			mobileNumber: this.accDetails.mobile, 
			studentName:  this.accDetails.fname + ' ' + this.accDetails.lname, 
			caseId : this.caseId, 
			email: this.accDetails.email,
			callType: 'Regular'
		}
		await scheduleCall({objWrapper: scheduleCallWrapper})
		.then(result=> {
			console.log(result)
			this.showSpinner = false;
			if(result === 'failed') {
				this.showHtmlMessage('Error', 'Something went wrong, Kindly try again later', 'error');
			} else {
				this.showHtmlMessage('Success', 'Call Scheduled Successfully', 'success');
			}
		}).catch( error => {
			this.showSpinner = false;
			this.showHtmlMessage('Error', 'Something went wrong, Kindly try again later', 'error');
			console.log(error);
		})

		setTimeout(() => { this.redirectToCaseDetails(); }, 1000);
		
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
						var extension = file.name.split('.');
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

	handleRemove(event) {
		var title = event.target.dataset.fid;
		var index = this.filesUploaded.findIndex(obj => obj.Title === title);
		console.log(index);
		this.filesUploaded.splice(index, 1);
	}

	async attachFiles() {
		await uploadFiles({ files: this.filesUploaded, caseId: this.caseId })
			.then(result => {
				if (result === true) {
					this.showUpload = false;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	async getAccountId() {
		await getAccountId({ studentno: this.studentNo})
			.then(result => {
				if(result !== "") {
					this.accountId = result;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	goBack() {
		window.location.assign('/apex/MyTickets?token=' + this.token);
	}

	handleNav(event) {
		let nav = event.currentTarget.dataset.id;
		if (nav === 'MY TICKETS') {
			window.location.assign('/apex/MyTickets?token=' + this.token);
		}else if(nav === 'STUDENT SUPPORT'){
			window.open(`${StudentZoneBaseUrlLabel}studentportal/student/connectWithUs`);
		}else if(nav === 'STUDENT ZONE'){
			window.open(`${StudentZoneBaseUrlLabel}studentportal/home`);
		}
	}

	handleCookies() {
		const cookies = document.cookie.split(';');
		console.log('cookie ' + cookies);
		cookies.forEach(cookie => {
			const [name, value] = cookie.trim().split('=');
			if (name === 'time') {
				this.hitTime = value;
			}
			if (name === 'sno') {
				this.studentNo = value;
			}
		});
	}

	redirectToCaseDetails() {
		const url = '/apex/CaseView?id=' + this.caseId + '&token=' + this.token + '&acc=' + encodeURIComponent(JSON.stringify(this.accDetails)) + '&navLst=' + encodeURIComponent(JSON.stringify(this.navLst));
		window.location.href = url;
	} 

	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}