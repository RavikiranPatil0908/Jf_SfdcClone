/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api } from 'lwc';
import getScheduleTableData from '@salesforce/apex/MyCasesController.getScheduleTableData';
import getCancelScheduleAPI from '@salesforce/apex/MyCasesController.getCancelScheduleAPI';
import getSchedulingTask from "@salesforce/apex/MyCasesController.getSchedulingTask";
import scheduleCall from "@salesforce/apex/MyCasesController.scheduleCall";
import LightningAlert from 'lightning/alert';

const scheduleColumns = [
	{ label: "Schedule Time", hideDefaultActions: true, sortable:true, fieldName: "scheduleDateRange" },
	// { label: "Status", hideDefaultActions: true, fieldName: "scheduleStatus" },
	{
		label: "Cancel Schedule",
		type: "button",						
		typeAttributes: {
			label: { fieldName: "scheduleCancelBtnText"},
			name: "Cancel",
			variant: { fieldName: "scheduleCancelBtnVariant"},
			disabled: { fieldName: "scheduleCancelBtnActive" }
		}
	},
	{
		label: "Re-Schedule Call",
		type: "button",
		typeAttributes: {
			label: { fieldName: "scheduleRescheduleBtnText"},
			name: "ReSchedule",
			variant: { fieldName: "scheduleRescheduleBtnVariant"},
			disabled: { fieldName: "scheduleRescheduleBtnActive" }
		}
	}
];

const timeRangeList = ['12 am - 1 am','1 am - 2 am','2 am - 3 am','3 am - 4 am','4 am - 5 am','5 am - 6 am','6 am - 7 am','7 am - 8 am','8 am - 9 am','9 am - 10 am','10 am - 11 am','11 am - 12 pm','12 pm - 1 pm','1 pm - 2 pm','2 pm - 3 pm','3 pm - 4 pm','4 pm - 5 pm','5 pm - 6 pm','6 pm - 7 pm','7 pm - 8 pm','8 pm - 9 pm','9 pm - 10 pm','10 pm - 11 pm','11 pm - 12 am'];

export default class CaseViewCallComp extends LightningElement {

    @api recordId;
    // @api accountId;

	// Note: these parameter is missing, need to fetch the data from class. 
    @api objAccount;
    @api objCase;
	showTooltip = false;

    scheduleDetail = {};
    scheduleColumns = scheduleColumns;
    @track callScheduleData = [];
	@track isCallRescheduling = false;
	@track callSchedulingDate= [];
	@track callSchedulingTimeRange = {};
	@track isCallSchedulingModalOpen = false;
	@track isCallSchedulingRecordContains = false;
	@track timeRange = timeRangeList;
	@track timeRangeSelected = [];
	@track isCallSchedulingConfirm = false;
	@track modalMsg = { title: 'Choose a preferrable date and time slot to schedule a callback', messgae: '', btnTitle: 'Cancel'};
	@track confirmScheduleModal = {isModalVisible: false, head: '', body: '', action: ''};
    @track showPopup = { title: '', message: '', variant: '' };

    isCallScheduleAvailable = false;
	callType = 'Escalation';
	taskId = null;
	selectedDate;
	selectedTimeRange;
	selectedTimeRangeValue;
	selectedId;
	disbaleBtn = false;
    showSpinner = false;

    connectedCallback() {
		this.showToolTip();
        this.handleActive();
        console.log('this.recordId l1==>'+this.recordId);
        console.log('this.objCase l1==>'+this.objCase);
        console.log('this.objAccount l1==>'+this.objAccount);
    }

    handleActive() {
		this.showSpinner = true;
		getScheduleTableData({caseId: this.recordId}).then(dataTable => {
			this.showSpinner = false;
            console.log('dataTable --> ',JSON.stringify(dataTable ))
			this.callScheduleData = dataTable;
			this.isCallScheduleAvailable = false;
			if(dataTable && dataTable.length > 0) {
				this.isCallScheduleAvailable = true;
			}
		}).catch(err => {
			this.showSpinner = false;
			console.log(err)
		})
	}

    handleRowAction(event) {
		// this.recordId = event.detail.row.caseId;
		console.log('event.detail.row --> ',JSON.stringify(event.detail.row))
		let actionName = event.detail.action.name;
		switch (actionName) {
			case "Cancel":
				this.scheduleDetail = event.detail.row;
				this.handleRowActionCancelClick( 'Cancel', 'Cancel Scheduled Callback','Are you sure you want to cancel the scheduled call?');
				break;
			case "ReSchedule":
				this.scheduleDetail = event.detail.row;
				this.handleRowActionCancelClick('Re-schedule', 'Re-schedule the call','Are you sure you want to Re-Schedule the call?');
					break;
			default:
				console.log('handleRowAction --> default');
				break;
		}
	}

	handleRowActionCancelClick(action, modalTitle, modalDescription) {
		this.confirmScheduleModal = {isModalVisible: true, head: modalTitle, body: modalDescription, action: action};
		console.log(JSON.stringify(this.confirmScheduleModal));
    }

	oncloseModalConfirmScheduleModal() {
		this.confirmScheduleModal = {isModalVisible: false, head: '', body: '', action: ''};
	}

	onOpenConfirmScheduleModal() {
		this.confirmScheduleModal.isModalVisible = false;
		if (this.confirmScheduleModal.action === 'Re-schedule') {
			this.isCallRescheduling = true;
			this.callType = this.scheduleDetail.scheduleCallType;
			this.taskId = this.scheduleDetail.scheduleTaskId;
			this.getScheduleDates();
		} else if(this.confirmScheduleModal.action === 'Cancel') {
			this.isCallRescheduling = false;
			this.callCancelScheduleAPI(this.scheduleDetail, 'Cancel', {});
		}
	}

	callCancelScheduleAPI(scheduleDetail, action, scheduleCallWrapper) {
		this.showSpinner = true;
		getCancelScheduleAPI({ callId: scheduleDetail.scheduleCallUuid, taskId: scheduleDetail.scheduleTaskId, callStatus : scheduleDetail.scheduleStatus, actionType : action}).then(data => {
			this.showSpinner = false;
			console.log(data, typeof data)
			console.log('action : '+ action);
			console.log('status : ' +
			scheduleDetail.scheduleStatus);
			if (action === 'Cancel') {
				LightningAlert.open({
					message: data ? `Call ${action} successfully` : 'Failed to cancel, kindly try again!',
					theme: data ? 'success' : 'error',
					label: action,
					variant: 'header',
				})
				.then(() => {
                    // window.location.reload();
					this.handleActive();
                })
				
			} else if(action === 'Re-schedule') {
				if (data) {
					console.log('scheduleCallWrapper --> ', scheduleCallWrapper)
					scheduleCallWrapper.isEscalate = false;
					scheduleCall({objWrapper: scheduleCallWrapper})
					.then(result=> {
						this.handleActive();
						console.log(result)
						if (result) {
							this.showSpinner = false;
							this.showHtmlMessage('Success', 'Call Scheduled Successfully', 'success');
							this.closeModal();
						} else {
							this.showSpinner = false;
							this.showHtmlMessage('Error', 'Something went wrong, Kindly try again later', 'error');
							this.closeModal();
						}
					}).catch( error => {
						this.showSpinner = false;
						this.showHtmlMessage('Error', 'Something went wrong, Kindly try again later', 'error');
						this.closeModal();
						console.log(error)
					})
				} else {
					this.showSpinner = false;
					this.showHtmlMessage('Error', 'Something went wrong, Kindly try again later', 'error');
					this.closeModal();
					console.log('error')
				}
			}
			this.handleActive();
		}).catch(error => {
			this.showSpinner = false;
			console.log(error);
		});
	}

	async getScheduleDates() {
		console.log('Create Task button clicked')
		console.log('this.objCase getScheduleDates', JSON.stringify(this.objCase));
		this.isCallSchedulingModalOpen = true;
		let dateLst = [];
		
		this.callSchedulingTimeRange = [];
		this.showSpinner = true;
		let escalationLevel = this.callType === 'Regular' ? '1' : this.objCase.escalationNumber;
		await getSchedulingTask({ escalationLevel: escalationLevel, caseId: this.objCase.caseId, recordId: this.objCase.recordId, callType: this.callType, programName: this.objAccount.program, calledFor: 'Reschedule'})
		.then(result => {
			console.log('result')
			console.log(JSON.stringify(result));
			this.modalMsg.btnTitle = 'Cancel';
			let mapOfDateVsTimeRange = result.mapOfDateVsTimeRange;
			let errorMsg = 'Kindly try again later as no call schedule is active. \n You can add a comment to the ticket so the concern team will reply on the same.';
			if (result.status === 'error') {
				this.modalMsg.messgae = result.message === 'Something Went Wrong' ? errorMsg : result.message;

				if(this.modalMsg.messgae.startsWith('A callback is already')) {
					this.modalMsg.title = 'Callback already scheduled';
					this.modalMsg.btnTitle = 'Ok';
				}
			}
			
			dateLst =  Object.keys(mapOfDateVsTimeRange); 
			this.isCallSchedulingRecordContains = dateLst.length > 0 ? true : false;
			if (!this.modalMsg.messgae && !this.isCallSchedulingRecordContains) {
				this.modalMsg.messgae = errorMsg;
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

	async scheduleCall() {
		this.showSpinner = true;
		this.disbaleBtn = true;
		let scheduleCallWrapper = {
			scheduleId : this.selectedId, 
			scheduleDate: this.selectedDate, 
			scheduleTimeRange : this.selectedTimeRange, 
			scheduleEscalationLevel : this.callType === 'Regular' ? '1' : this.objCase.escalationNumber, 
			recordId : this.objCase.recordId, 
			typeOfObject: this.objCase.typeOfObject, 
			mobileNumber: this.objAccount.mobile, 
			studentName:  this.objAccount.fname + ' ' + this.objAccount.lname, 
			caseId : this.objCase.caseId, 
			email: this.objAccount.email,
			callType: this.callType,
			taskId: this.taskId
		}
		this.callCancelScheduleAPI(this.scheduleDetail, 'Re-schedule', scheduleCallWrapper);
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

	@api
	showToolTip() {
		this.showTooltip = true;
		setTimeout(() => { 
			this.showTooltip = false; 
		}, 10000);
	}
}