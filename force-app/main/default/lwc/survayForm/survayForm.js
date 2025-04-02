import { LightningElement, track, wire, api } from 'lwc';
import getSurveyRecord from '@salesforce/apex/Survey.getSurveyRecord';
import Createrecord from '@salesforce/apex/Survey.Createrecord';
import Question_Bank__c from '@salesforce/schema/Question_Bank__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import Function__c from '@salesforce/schema/Question_Bank__c.Function__c';
import Activity__c from '@salesforce/schema/Question_Bank__c.Activity__c';
import Program_Type__c from '@salesforce/schema/Question_Bank__c.Program_Type__c';
import Type__c from '@salesforce/schema/Question_Bank__c.Type__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const actions = [
    { label: 'Edit', name: 'edit' },
];
export default class LightningDataTableLWC extends NavigationMixin(LightningElement) {
    @api experience;
    refresh;
    temp_choices = '';
    arr = [];
    choiceTypes = ['Single Choice','Multiple Choice'];
    @track Survay = {};
    //export default class survayForm extends LightningElement {
    customHideModalPopup() {
        customFormModal = false;
    }
    error = '';
    Program_TypePicklist;
    FunctionPicklist;
    picklistValuesOfActivtiy;

    @track CreateRecords = {
        Activity__c: '',
        Answer__c: '',
        Choices__c: '',
        Function__c: '',
        Program_Type__c: '',
        Question__c: '',
        Type__c: '',
        Active__c: true,
        Mark__c: 1
    }
    @track isChoiceVisible = false;
    objectApiName = 'Question_Bank__c';

    @track data;
    @track columns = [
        { label: 'Question Bank Name', fieldName: 'Name', type: 'Auto Number' },
        { label: 'Active', Active__c: 'Active__c', type: 'Checkbox' },
        { label: 'Activity', fieldName: 'Activity__c', type: 'Picklist' },
        { label: 'Answer', fieldName: 'Answer__c', type: 'Long Text Area(131072)' },
        { label: 'Choices', fieldName: 'Choices__c', type: 'Long Text Area(131072)' },
        { label: 'Function', fieldName: 'Function__c', type: 'Picklist' },
        { label: 'Program Type', fieldName: 'Program_Type__c', type: 'Picklist (Multi-Select)' },
        { label: 'Question', fieldName: 'Question__c', type: 'Long Text Area(131072)' },
        { label: 'Type', fieldName: 'Type__c', type: 'Picklist' },
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        },
    ];

    // Edit Form
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'edit':
                this.editRow(row);
                break;
            default:
        }

    }

    @track data;
    @track parameters;
    @track error;
    refreshTable;

    @wire(getSurveyRecord)
    wiredCallback(result) {
        this.refreshTable = result;
        if (result.data) {
            this.parameters = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.parameters = undefined;
        }
    }

    //Model Popup
    @track customFormModal = false;

    customShowModalPopup() {
        let defaultRecord = {
            Activity__c: '',
            Answer__c: '',
            Choices__c: '',
            Function__c: '',
            Program_Type__c: '',
            Question__c: '',
            Type__c: '',
            Active__c: true,
            Mark__c: 1
        }
        this.CreateRecords = {...defaultRecord};
        this.SurveyList = [{ id:0, value:'' }];
        this.customFormModal = true;
    }

    customHideModalPopup() {
        this.customFormModal = false;
    }

    // Addding Row
    @track KeyIndex = 0;
    @track SurveyList = [{
        id: 0,
        value: ''
    }];


    addRow(event) {
        this.KeyIndex = parseInt(event.target.accessKey) + 1;
        let accessKey = parseInt(event.target.accessKey) + 1;
        let newItem = { id: accessKey, value: '' };
        this.SurveyList.push(newItem);
    }

    removeRow(event) {
        let getIndexOfElementTOBeRemoved;
        this.SurveyList.forEach((survey, index) => {
            if (parseInt(event.target.accessKey) == survey.id) {
                getIndexOfElementTOBeRemoved = this.SurveyList.indexOf(survey);
            }
        })
        if (this.SurveyList.length > 1) {
            this.SurveyList.splice(getIndexOfElementTOBeRemoved, 1);
        }
    }

    @wire(getObjectInfo, { objectApiName: Question_Bank__c })
    Question_BankMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$Question_BankMetadata.data.defaultRecordTypeId',
            fieldApiName: Function__c,
        }
    )
    FunctionPicklist;

    @wire(getPicklistValues, {
        recordTypeId: '$Question_BankMetadata.data.defaultRecordTypeId', fieldApiName: Activity__c
    })
    wiredPicklistActivtiy({ error, data }) {
        if (data) {
            this.activityOptions = data;
            this.picklistValuesOfActivtiy = data.values;
            this.error = undefined;
        } 
        if (error) {
            this.picklistValuesOfActivtiy = undefined;
            this.error = error;
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$Question_BankMetadata.data.defaultRecordTypeId',
            fieldApiName: Program_Type__c,
        }
    )
    Program_TypePicklist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$Question_BankMetadata.data.defaultRecordTypeId',
            fieldApiName: Type__c,
        }
    )
    TypePicklist;


    handleChange(event) {
        if (event.currentTarget.dataset.field) {
            const field = event.currentTarget.dataset.field;
            console.log(this.CreateRecords);
            let value = field === 'Active__c' ? event.detail.checked : event.detail.value;
            console.log(field +' => '+ value);
            if ({}.hasOwnProperty.call(this.CreateRecords, field)) {
                if (field === 'Function__c') {
                    let key = this.activityOptions.controllerValues[event.detail.value];
                    this.picklistValuesOfActivtiy = this.activityOptions.values.filter(opt => opt.validFor.includes(key));
                    console.log(this.picklistValuesOfActivtiy);
                }
                else if(field === 'Type__c') {
                    this.isChoiceVisible = this.choiceTypes.includes(value) ? true : false;
                }
            }
            this.CreateRecords[field] = value;
        }
    }

    Savevalue(event) {
        let choices = "";
        this.SurveyList.forEach(survay => {
            if (survay.id == parseInt(event.target.accessKey)) {
                survay.value = event.detail.value;
            }
            choices += survay.value + "\n"
        })
        this.CreateRecords.Choices__c = choices;
    }

    handleSave() {
        Createrecord({ QbRecObje: this.CreateRecords })
            .then(result => {
                const toastEvent = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Record Added successfully',
                    variant: 'success'
                })
                this.dispatchEvent(toastEvent);
                return refreshApex(this.refreshTable);
                
            })
            .catch((error) => {
                this.errorMsg = error.message;
            });
        this.customFormModal = false;
    }

    editRow(row) {
        this.CreateRecords = {...row};
        if(this.choiceTypes.includes(this.CreateRecords.Type__c) && this.CreateRecords.Choices__c) {
            this.SurveyList = [{ id:0, value:'' }];
            this.isChoiceVisible = true;
            let choices = this.CreateRecords.Choices__c.split(/\r\n|\n\r|\n|\r/);
            choices.forEach((element,index) => {
                let newItem = { id: index, value: element };
                this.SurveyList[index] = newItem;
            });
        } else {
            this.isChoiceVisible = false;
        }
        this.customFormModal = true;
    }
}