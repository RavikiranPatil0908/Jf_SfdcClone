import { LightningElement, api, track, wire } from 'lwc';
import getQuestionBank from '@salesforce/apex/Survey.getQuestionBank';
import insertQuestions from '@salesforce/apex/Survey.addQuestions';

const actions = [
    { label: 'Show details', name: 'show_details' }
];

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Question', fieldName: 'Question__c', type: 'text' },
    { label: 'Type', fieldName: 'Type__c', type: 'text' },
    { label: 'Function', fieldName: 'Function__c', type: 'text' },
    { label: 'Activity', fieldName: 'Activity__c', type: 'text' },
    { label: 'Program Type', fieldName: 'Program_Type__c', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class ManageQuestionBank extends LightningElement {
    data = [];
    columns = columns;
    record = {};
    isViewModal = false;
    showPopup = { title: '', message: '', variant: '' };
    footerNote;

    @track preSelectedRows = [];
    @api row;
    @wire(getQuestionBank, {
        function: '$row.Function__c',
        activity: '$row.Activity__c',
        programType: '$row.Program_Type__c',
        surveyId: '$row.Id'
    })
    getQuestionBank({ error, data }){
        if (data){
            this.data = data.lstQuestionBank;
            this.preSelectedRows = data.preExistingQB;
            this.selectedRowHandler(this.preSelectedRows.length);
        }
        else if(error){
            this.error = undefined;
            console.error(error);
        }
    }

    hideModal() {
        this.sendValues(null,'close');
    }
    
    hideViewModal() {
        this.isViewModal = false;
    }

    sendValues(result,type) {
        console.log('sendValues called');
        this.dispatchEvent(new CustomEvent("modalresponse", {
            detail: {
                message: this.showPopup,
                values: result,
                type: type
            }
        }));
    }

    addQuestions() {
        let el = this.template.querySelector('lightning-datatable');
        console.log(el);
        let selected = el.getSelectedRows();
        if(selected.length > 0) {
            insertQuestions({lstQB : selected,surveyId : this.row.Id})
            .then((result) => { 
                if(result){
                    this.showPopup.title = 'Record inserted successfully!';
                    this.showPopup.message = 'success'; 
                    this.showPopup.variant = 'success';
                } else {
                    this.showPopup.title = 'Record inserted Failed!';
                    this.showPopup.message = 'error'; 
                    this.showPopup.variant = 'error';
                }
                this.sendValues(result,'save');
            })
            .catch((error) => {
                this.showPopup.title = 'Error while inserting the record!';
                this.showPopup.message = 'error'; 
                this.showPopup.variant = 'error';
                console.log(error);
                this.sendValues(result,'save');
            });
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }

    selectedRowHandler(event) {
        let selectedRowsLength = 0;
        if(typeof event == 'number') {
            selectedRowsLength = event;
        } else {
            selectedRowsLength = event.detail.selectedRows.length;
        }
        this.footerNote = selectedRowsLength > 0 ? `Note: ${selectedRowsLength} Questions selected` : '';
    }

    showRowDetails(record) {
        this.isViewModal = true;
        this.record = record;
        console.log(JSON.stringify(this.record));
    }
}