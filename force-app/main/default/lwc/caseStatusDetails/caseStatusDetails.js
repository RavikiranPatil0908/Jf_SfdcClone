/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, track, api } from "lwc";
import getMyCaseList from "@salesforce/apex/MyCasesController.getMyCaseList";
import getMyClosedCaseList from "@salesforce/apex/MyCasesController.getMyClosedCaseList";
import getFeedbacks from "@salesforce/apex/MyCasesController.getFeedbacks";
import findCases from "@salesforce/apex/MyCasesController.findCases";
import escalateCase from "@salesforce/apex/MyCasesController.escalateCase";
import decryptToken from "@salesforce/apex/MyCasesController.decryptToken";
import getStudentDetails from "@salesforce/apex/MyCasesController.getStudentDetails";
import getSchedulingTask from "@salesforce/apex/MyCasesController.getSchedulingTask";
import scheduleCall from "@salesforce/apex/MyCasesController.scheduleCall";
import updateEscalationDate from "@salesforce/apex/MyCasesController.updateEscalationDate";
import checkCallScheduled from "@salesforce/apex/MyCasesController.checkCallAlreadyScheduled";
import { NavigationMixin } from "lightning/navigation";
import LightningAlert from "lightning/alert";
import StudentZoneBaseUrlLabel from '@salesforce/label/c.Student_Zone_Base_Url';
import SiteUrlLabel from '@salesforce/label/c.Site_Url';
import { formatDate } from 'c/formatedDate';

const timeRangeList = ['12 am - 1 am','1 am - 2 am','2 am - 3 am','3 am - 4 am','4 am - 5 am','5 am - 6 am','6 am - 7 am','7 am - 8 am','8 am - 9 am','9 am - 10 am','10 am - 11 am','11 am - 12 pm','12 pm - 1 pm','1 pm - 2 pm','2 pm - 3 pm','3 pm - 4 pm','4 pm - 5 pm','5 pm - 6 pm','6 pm - 7 pm','7 pm - 8 pm','8 pm - 9 pm','9 pm - 10 pm','10 pm - 11 pm','11 pm - 12 am'];

export default class CaseStatusDetails extends NavigationMixin( LightningElement ) {
	@api recordId;
	@track program;
	@track showCaseDetails = true;
	@track showCaseView = false;
	@track showCreateCase = false;
	@track caseColumns = [];
	@track selectedOption;
	@track error;
	@track caseList;
	@track searchKey = "";
	@track accDetails;
	@track isView = false;
	@track showSpinner = false;
	@track lastName;
	@track callValue;
	@api navLst = ['STUDENT ZONE','STUDENT SUPPORT','MY TICKETS'];
	@api token;
	@api isPortal;

	@track hitTime;
	@track options = [{label:'My Open Tickets',value:'open'},{label:'My Closed Tickets',value:'closed'},{label:'My Feedbacks',value:'feedback'}];
	@track showEscalationModel = false; 
	@track showEscalationSuccess =false ;
	@track callSchedulingDate= [];
	@track callSchedulingTimeRange = {};
	@track isCallSchedulingModalOpen = false;
	@track isCallSchedulingRecordContains = false;
	@track timeRange = timeRangeList;
	@track timeRangeSelected = [];
	@track isCallSchedulingConfirm = false;
	@track caseDetail;
	@track isCommentButtonAvailableForCallScheduling = false;
	@track showPopup = { title: '', message: '', variant: '' };
	@track modalMsg = { title: 'Choose a preferrable date and time slot to schedule a callback', messgae: '', btnTitle: 'Cancel'};
	@track showL4Message = false;

	sno;
	selectedDate;
	selectedTimeRange;
	selectedTimeRangeValue;
	selectedId;
	callType = 'Escalation';
	disbaleBtn = false;
		
	connectedCallback() {
		console.log('login value '+this.isPortal);
		if(this.token === ''){
			window.location = StudentZoneBaseUrlLabel;
		}else{
			this.validateSession();	
		}
	}
	
	validateSession() {
		if(this.token !== ''){
			decryptToken({ token: this.token })
			.then(result => {
				console.log(result);
				if (result !== "" || result != null) {
					let res = result.split(" ");
					if(res[0].length > 11){
						this.sno = res[0].split("_")[1];
					}else{
						this.sno = res[0];
					}
					this.hitTime = res[1];
					if(this.sno === ''){
						LightningAlert.open({
							message: "Login Again",
							theme: "error",
							label: "No Student Found",
							variant: "header"
						});	
						if(this.isPortal === false){
							window.location = `${SiteUrlLabel}apex/Login`;
						}else{
							window.location = StudentZoneBaseUrlLabel;
						}
					}else{
						let d = new Date();
						d.setTime(d.getTime() + 60 * 60 * 1000);
						document.cookie = "sno=" + this.sno;
						document.cookie = 'time='+ this.hitTime;		
						document.cookie = 'expires='+d;
						this.studentDetails();
						this.getOpenCases();
					}
				}
			})
			.catch(error => {
				console.log(error);
			});
		}
	}
		
	
	studentDetails(){
		getStudentDetails({sno: this.sno, rno: '', email: '', mobile: ''}).then(result => {
			console.log(JSON.stringify(result));
			this.accDetails = result;
			this.program = result.program;
			if(result.lname === '.'){
					this.lastName = '';
			}else{
					this.lastName = result.lname;
			}
		}).catch(() => {
			LightningAlert.open({
				message: "No Student found with this student no in salesforce",
				theme: "error",
				label: "No Student Found!",
				variant: "header"
			});
			if(this.isPortal === false){
				window.location = `${SiteUrlLabel}apex/Login`;
			}else{
				window.location = StudentZoneBaseUrlLabel;
			}
		});
	}
		
	renderedCallback() {
		this.addEventListener('onnavevent', this.handlenavevent);
		let diff = Date.now() - this.hitTime;
		console.log("diff " + diff);
		if (diff > 3600000) {
			LightningAlert.open({
				message: "Please login again",
				theme: "error",
				label: "Session Expired!",
				variant: "header"
			});
			if(this.isPortal === false){
				window.location = `${SiteUrlLabel}apex/Login`;
			}else{
				window.location = StudentZoneBaseUrlLabel;
			}
		}
	}
	
	//customevent 
	handlemycustomevent(event){
		this.navLst = event.detail;
		this.showCaseView = false;
		this.showCreateCase = false;
		this.showCaseDetails = true;			
	}
		
	handlenavevent(event){
		this.navLst = event.detail.nav;
		this.recordId = event.detail.caseid;
		this.isView = true;
		this.showCaseView = true;
		this.showCreateCase = false;
		this.showCaseDetails = false;	
	}
	
	handleupdatenavevent(event){			
		this.navLst = event.detail;
	}
		
	getOpenCases() {
		this.showSpinner = true;
		getMyCaseList({ sno: this.sno })
		.then(result => {
			console.dir(result);

			this.caseColumns = [
				{
					label: "Ticket No.",
					type: "button",
					typeAttributes: {
						label: { fieldName: "caseNumber" },
						variant: "destructive-text"
					},
				},
				{ label: "Subject", hideDefaultActions: true, fieldName: "caseSubject", initialWidth: 400},
				{ label: "Status", hideDefaultActions: true, fieldName: "caseStatus" },
				{ label: "Open Date", hideDefaultActions: true, sortable:true, fieldName: "caseCreatedDate" },
				{ label: "In Progress Date", hideDefaultActions: true, fieldName: "caseInProgressDate" },
				{ label: "Expected Close Date", hideDefaultActions: true, fieldName: "caseCloseDate" },
				// { label: "Escalation Level", hideDefaultActions: true, fieldName: "escalationNumber" },     // New column added here
				{
					label: "Escalate?",
					type: "button",						
					typeAttributes: {
						label: { fieldName: "showButton"},
						name: "yes",
						variant: { fieldName: "variant"},
						disabled: { fieldName: "isActive" }
					}
				},
				{
					label: "Schedule Call back?",
					type: "button",
					initialWidth: 180,
					typeAttributes: {
						label: { fieldName: "callBtnLabel"},
						name: "call",
						variant: { fieldName: "callBtnVariant"},
						disabled: { fieldName: "callBtnDisabled" }
					}
				}
			];
			this.caseList = result;
			this.showSpinner = false;
		})
		.catch(error => {
			console.log(error);
			this.showSpinner = false;
		});
	}

	getClosedCases() {
		getMyClosedCaseList({ sno: this.sno })
		.then(result => {
			this.caseColumns = [
			{
				label: "Ticket No.",
				type: "button",
				typeAttributes: {
				label: { fieldName: "caseNumber" },
				variant: "destructive-text"
				}
			},
			{ label: "Subject", hideDefaultActions: true, fieldName: "caseSubject", initialWidth: 500 },
			{ label: "Status", hideDefaultActions: true, fieldName: "caseStatus" },
			{ label: "Open Date", hideDefaultActions: true, fieldName: "caseCreatedDate" },
			{ label: "Close Date", hideDefaultActions: true, fieldName: "caseCloseDate" },
		    // { label: "Escalation Level", hideDefaultActions: true, fieldName: "escalationNumber" }, // New column added here
			{
				label: "Escalate?",
				type: "button",						
				typeAttributes: {
					label: { fieldName: "showButton"},
					name: "yes",
					variant: { fieldName: "variant"},
					disabled: { fieldName: "isActive" }
				}
			},
			{ label: "Schedule Call back?", hideDefaultActions: true, fieldName: "callBtnLabel" }
			];
			this.caseList = result;
		})
		.catch(error => {
			console.log(error);
		});
	}

	getFeedbacks() {
		getFeedbacks({ sno: this.sno })
		.then(result => {
			this.caseColumns = [
			{
				label: "Subject",
				type: "button",
							initialWidth: 600,
				typeAttributes: {
				label: { fieldName: "caseSubject" },
				variant: "destructive-text"
				}
			},
			{ label: "Open Date", hideDefaultActions: true, fieldName: "caseCreatedDate" },
			{ label: "Status", hideDefaultActions: true, fieldName: "caseStatus" }
			];
			this.caseList = result;
		})
		.catch(error => {
			console.log(error);
		});
	}

	changeHandler(event) {			
		this.selectedOption = event.target.value;
				this.options = this.options.map((option) => {
				return {
				...option,
				selected: option.value === this.selectedOption
				};
			});
				
		if (this.selectedOption === "closed") {
			this.getClosedCases();
		} else if (this.selectedOption === "open") {
			this.getOpenCases();
		} else if (this.selectedOption === "feedback") {
			this.getFeedbacks();
		}
	}

	handleKeyChange(event) {
		this.searchKey = event.target.value;
		this.handleSearchInput();
	}

	handleSearchInput() {
		findCases({ searchKey: this.searchKey, sno: this.sno })
		.then(result => {
			this.caseList = result;
			console.log(result);
		})
		.catch(error => {
			console.log(error);
		});
	}

	// To escalate the case.
	handleCaseEscalation() {
		console.log("in caseEscalation ");
		escalateCase({ caseId: this.recordId, callValue: this.callValue })
		.then(() => { 
			this.showEscalationModel = false;
			this.showEscalationSuccess =false;
			this.showL4Message = false;
			if(this.callValue === 'Yes'){
				this.callType = 'Escalation';
				this.onCreateTask();
			}else{
				
				window.location.reload();
			}
		} )
		.catch(error => {
			console.log(error);
			this.showSpinner = false;
    	});	
	}

	async checkCallAlreadyScheduled() {
		let objTask = null;
		try {
			console.log('record called ==>');
			console.log('==>'+this.accDetails.accountId);
			await checkCallScheduled({recordId: this.accDetails.accountId})
			.then(result => {
				if(typeof result === 'object' && result !== null) {
					console.log('result ==>'+JSON.stringify(result));
					objTask = result;
				}
			})
			.catch(error => {
				console.log(error);
			});
		} catch (error) {
			console.log(error);
		}
		console.dir(objTask);
		return objTask;
	}

	handleCallback(){
		this.showSpinner = true;
		this.callValue = 'Yes';
		this.handleCaseEscalation();			
	}
		
	handleCancel(){
		this.showSpinner = true;
		this.callValue = 'No';
		this.handleCaseEscalation();		
	}
		
	async handleCreateCase(event) {
		let type = event.currentTarget.dataset.type === 'call' ? true : false;
		let objTask = null;
		if(type ) {
			objTask = await this.checkCallAlreadyScheduled();
			console.log(objTask);
		}
		if(objTask) {
			let date = null;
			if(objTask.Schedule_Call_Time__c !== undefined) {
				let dtVal = new Date(objTask.Schedule_Call_Time__c);
				date = formatDate(dtVal,'d/MM/yyyy h:mm TT','');
			} else {
				let dtVal = new Date(objTask.Call_date__c);
				date = formatDate(dtVal,'d/MM/yyyy','');
			}
			this.modalMsg.title = 'Callback already scheduled';
			this.modalMsg.btnTitle = 'Ok';
			this.modalMsg.messgae = `A callback is already scheduled on ${date} for Ticket No. - ${objTask.Case__r.CaseNumber}. \n Please wait to complete this callback to schedule a new one.`;
			this.isCallSchedulingRecordContains = false;
			this.isCallSchedulingModalOpen = true;
			this.callType = 'Regular';
			return;
		}

		let encodedAccountDetails = encodeURIComponent(JSON.stringify(this.accDetails));
		window.open(`/apex/CaseSubmission?token=${this.token}&acc=${encodedAccountDetails}&type=${type}`);
	}

	handleRowAction(event) {
		this.recordId = event.detail.row.caseId;

		let actionName = event.detail.action.name;
		switch (actionName) {
			case "yes":
				this.caseDetail = event.detail.row;
				if (this.caseDetail.escalationNumber=="2" || this.caseDetail.escalationNumber=="3") {
				    this.showEscalationModel = false;
					this.showEscalationSuccess = true;
					this.showL4Message = this.caseDetail.escalationNumber == "3" ? true : false;
					console.log('this.caseDetail.escalationLevel--->' + this.caseDetail.escalationNumber +'this.showEscalationModel-->' + this.showEscalationModel + 'this.showEscalationSuccess--->' + this.showEscalationSuccess + 'this.showL4Message-->' + this.showL4Message);
				} else {
				    this.showEscalationModel = true;
				}
				
				console.log('this.caseDetail123', JSON.stringify(this.caseDetail));
				break;
			case "call":
				this.caseDetail = event.detail.row;
				this.callType = 'Regular';
				this.onCreateTask();
				break;
			default:
				// eslint-disable-next-line no-case-declarations
				const url = '/apex/CaseView?id=' + this.recordId + '&token=' + this.token + '&acc=' + encodeURIComponent(JSON.stringify(this.accDetails)) + '&navLst=' + encodeURIComponent(JSON.stringify(this.navLst));
				window.open(url);
				break;
		}
	}
		
	handleNav(event){
		let nav = event.currentTarget.dataset.id;
		if(nav === 'MY TICKETS'){
			//pass		
		}else if(nav === 'STUDENT SUPPORT'){
			window.open(`${StudentZoneBaseUrlLabel}studentportal/student/connectWithUs`);
		}else if(nav === 'STUDENT ZONE'){
			window.open(`${StudentZoneBaseUrlLabel}studentportal/home`);
		}
	}

	handleRefresh() {
		this.getOpenCases();
	}

	async onCreateTask() {
		console.log('Create Task button clicked')
		console.log('this.caseDetail onCreateTask', JSON.stringify(this.caseDetail));
		this.isCallSchedulingModalOpen = true;
		this.isCommentButtonAvailableForCallScheduling = false;
		let dateLst = [];
		
		this.callSchedulingTimeRange = [];
		this.showSpinner = true;
		let escalationLevel = this.callType === 'Regular' ? '1' : this.caseDetail.escalationNumber;
		await getSchedulingTask({ escalationLevel: escalationLevel, caseId: this.caseDetail.caseId, recordId: this.caseDetail.recordId, callType: this.callType, programName: this.program, calledFor: ''})
		.then(result => {
			console.log('result')
			console.log(JSON.stringify(result));
			this.modalMsg.btnTitle = 'Cancel';
			let mapOfDateVsTimeRange = result.mapOfDateVsTimeRange;
			let errorMsg = 'Kindly try again later as no call schedule is active. \n You can add a comment to the ticket so the concern team will reply on the same.';
			if (result.status === 'error') {
				this.modalMsg.messgae = result.message === 'Something Went Wrong' ? errorMsg : result.message;
				this.isCommentButtonAvailableForCallScheduling = result.message === 'Something Went Wrong' ? true : false;

				if(this.modalMsg.messgae.startsWith('A callback is already')) {
					this.modalMsg.title = 'Callback already scheduled';
					this.modalMsg.btnTitle = 'Ok';
				}
			}
			
			dateLst =  Object.keys(mapOfDateVsTimeRange); 
			this.isCallSchedulingRecordContains = dateLst.length > 0 ? true : false;
			if (!this.modalMsg.messgae && !this.isCallSchedulingRecordContains) {
				this.modalMsg.messgae = errorMsg;
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

	onAddCommentFromSchedule() {
		if(this.callType === 'Escalation') {
			this.setEscalationDate();
		}
		const url = '/apex/CaseView?id=' + this.recordId + '&token=' + this.token + '&acc=' + JSON.stringify(this.accDetails) + '&navLst=' + encodeURIComponent(JSON.stringify(this.navLst));
		window.open(url);
	}

	openKnowledgeArticles() {
		window.open('https://ngasce.my.site.com/articles/s/');
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

	async scheduleCall() {
		this.disbaleBtn = true;
		this.showSpinner = true;
		let scheduleCallWrapper = {
			scheduleId : this.selectedId, 
			scheduleDate: this.selectedDate, 
			scheduleTimeRange : this.selectedTimeRange, 
			scheduleEscalationLevel : this.callType === 'Regular' ? '1' : this.caseDetail.escalationNumber, 
			recordId : this.caseDetail.recordId, 
			typeOfObject: this.caseDetail.typeOfObject, 
			mobileNumber: this.accDetails.mobile, 
			studentName:  this.accDetails.fname + ' ' + this.accDetails.lname, 
			caseId : this.caseDetail.caseId, 
			email: this.accDetails.email,
			callType: this.callType
		}
		scheduleCall({objWrapper: scheduleCallWrapper})
		.then(result=> {
			console.log(result)
			this.showSpinner = false;
			this.showHtmlMessage('Success', 'Call Scheduled Successfully', 'success');
			this.closeModal();
			this.handleRefresh();
		}).catch( error => {
			this.showSpinner = false;
			this.showHtmlMessage('Error', 'Something went wrong, Kindly try again later', 'error');
			this.handleRefresh();
			console.log(error)
		})
	}

	async setEscalationDate() {
		this.showSpinner = true;
		await updateEscalationDate({caseId : this.caseDetail.caseId, callBack: false})
		.then(result=> {
			console.log('Status ==>'+result);
			this.showSpinner = false;
			this.handleRefresh();
		}).catch( error => {
			this.showSpinner = false;
			console.log(error);
			this.handleRefresh();
		})
	}

	closeModal() {
		this.selectedDate = '';
		this.selectedTimeRange = '';
		this.selectedId= '';
		this.timeRangeSelected =[];
		this.modalMsg.messgae = '';
		this.modalMsg.title = 'Choose a preferrable date and time slot to schedule a callback';
		this.isCallSchedulingConfirm = false;
		this.isCallSchedulingModalOpen = false;
	}

	oncloseModalCallScheduleModal() {
		this.closeModal();
		if(this.callType === 'Escalation') {
			this.setEscalationDate();
		}
	}

	oncloseModalCallScheduleConfirm() {
		this.isCallSchedulingConfirm = false;
		this.isCallSchedulingModalOpen = true;
	}

	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}