import { LightningElement, api, track, wire } from 'lwc';
import getAssessments from '@salesforce/apex/Survey.getAssessments';
import getAssessmentRecords from '@salesforce/apex/Survey.getAssessmentRecords';

const actions = [
    { label: 'Manage Questions', name: 'manage_questions' },
    { label: 'Edit', name: 'edit' },
];

const columns = [
    { 
        label: 'Assessment Name', 
        fieldName: 'Name', 
        sortable: true,
        type: 'text',
        cellAttributes: { alignment: 'left' } 
    },
    { 
        label: 'Function', 
        fieldName: 'Function__c', 
        sortable: false,
        type: 'text',
        cellAttributes: { alignment: 'left' } 
    },
    { 
        label: 'Activity', 
        fieldName: 'Activity__c',
        sortable: false,
        type: 'text',
        cellAttributes: { alignment: 'left' } 
    },
    { 
        label: 'Program Type', 
        fieldName: 'Program_Type__c',
        sortable: false,
        type: 'text',
        cellAttributes: { alignment: 'left' } 
    },
    { 
        label: 'Created Date', 
        fieldName: 'CreatedDate',
        sortable: true,
        type: 'datetime',
        cellAttributes: { alignment: 'left' } 
    },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
export default class CreateAssessment extends LightningElement {
    pageNumber = 0;
    recordsPerPage = 200;
    error = '';
    keyword = '';
    sortedField = '';
    sortDirection = '';
    sortType = '';
    isFocus = false;
    isCreateModalOpen = false;
    isQBModalOpen = false;
    record;
    totalRecordCount;
    totalPageCount;
    isCreate = true;
    // isActivityDisabled = true;
    @api experience;
    @track data = [];
    @track columns = columns;
    @track currentRecord = {
        Name:'',
        Timer__c:'',
        Function__c:'',
        Activity__c:'',
        Program_Type__c:'',
        Submit_Response__c:'',
        IsActive__c:'',
        Show_Result__c:'',
        Survey_Header__c:'',
        New_Survey__c:true
    };
    @track activityOptions;
    @track showPopup = { title: '', message: '', variant: '' };

    get popoverClass() {
        return this.isFocus ?  
        'slds-popover slds-popover_tooltip slds-nubbin_top-left slds-is-absolute slds-var-m-top_x-small tooltip slds-rise-from-ground' :
        'slds-popover slds-popover_tooltip slds-nubbin_top-left slds-is-absolute slds-var-m-top_x-small tooltip slds-fall-into-ground';
    }

    @wire(getAssessments)
    getAssessments({ error, data }){
        if (data){
            this.data = data;
            console.dir(this.data);
        }
        else if(error){
            this.error = undefined;
            console.error(error);
        }
    }

    handleSort(event) {
        this.pageNumber = 1;
        this.sortedField = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortType = this.columns.find(column => this.sortedField === column.fieldName).type;
        this.handlePageChange();
    }

    handleKeyWordChange(event) {
        this.pageNumber = 1;
        this.keyword = event.target.value;
        if(!this.keyword) {
            this.isFocus = false;
        }
        this.handlePageChange();
    }

    loadPopUp() {
        this.isFocus = true;
    }

    hidePopUp() {
        this.isFocus = false;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.editRow(row);
                console.log('edit');
                break;
            case 'manage_questions':
                this.showRowDetails(row);
                console.log('manage_questions');
                break;
            default:
        }
    }

    handlePageChange() {
        getAssessmentRecords({
            pageNumber: this.pageNumber,
            recordsPerPage: this.recordsPerPage,
            keyword: this.keyword,
            sortedField: this.sortedField,
            sortDirection: this.sortDirection,
            sortType: this.sortType
        })
        .then(result => {
            this.data = result.currentRecords;
            this.totalRecordCount = result.totalRecordCount;
            this.totalPageCount = result.totalPageCount;
            console.log(this.data);
        })
        .catch(error => {
            // this.currentRecord = {};
            this.error = error;
            console.log('Error =>'+this.error);
            console.dir(this.error);
        })
    }

    handleClick(event) { 
        let key = event.currentTarget.dataset.key;
        if(key === 'refersh') {
            this.pageNumber = 1;
            this.recordsPerPage = 200;
            this.keyword = null;
            this.handlePageChange();
        }
    }

    handleBtnGrp(event) {
        this.hideCreateModal();
        let key = event.target.value;
        if(key === 'new') {
            this.record = {};
            this.isCreate = true;
            this.loadCreateModal();
        }
    }

    loadCreateModal() {
        this.isCreateModalOpen = true;
    }

    hideCreateModal() {
        this.isCreateModalOpen = false;
    }

    loadQBModal() {
        this.isQBModalOpen = true;
    }

    hideQBModal() {
        this.isQBModalOpen = false;
    }

    handleResponse(event) {
        console.log(event);
        if(event.detail.type === 'close') {
            this.hideCreateModal();
        } else if(event.detail.type === 'save') {
            const msg = event.detail.message;
            this.handlePageChange();
            this.showHtmlMessage(msg.title, msg.message, msg.variant);
            this.hideCreateModal();
        }
    }

    handleQBResponse(event) {
        if(event.detail.type === 'close') {
            this.hideQBModal();
        } else if(event.detail.type === 'save') {
            const msg = event.detail.message;
            this.showHtmlMessage(msg.title, msg.message, msg.variant);
            this.hideQBModal();
        }
    }

    // findRowIndexById(id) {
    //     let ret = -1;
    //     this.data.some((row, index) => {
    //         if (row.id === id) {
    //             ret = index;
    //             return true;
    //         }
    //         return false;
    //     });
    //     return ret;
    // }

    editRow(row) {
        this.record = row;
        this.isCreate = false;
        this.loadCreateModal();
    }

    showRowDetails(row) {
        console.log(row);
        console.log(JSON.stringify(row));
        this.record = row;
        this.loadQBModal();
    }

    // To show Toast message
	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
	}
}