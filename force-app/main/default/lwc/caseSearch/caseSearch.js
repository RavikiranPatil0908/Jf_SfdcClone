import { LightningElement, track, wire, api } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import searchCase from "@salesforce/apex/AEPMerchandiseController.searchCase";
import updateStatusAndSendMailForCase from "@salesforce/apex/AEPMerchandiseController.updateStatusAndSendMailForCase";
import CASE_OBJECT from '@salesforce/schema/Case';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import CATEGORY_FIELD from '@salesforce/schema/Case.nm_Category__c';



const actions = [
    { label: 'Open In New Tab', name: 'openInNewTab' },
    { label: 'Open Record', name: 'openRecord' },
];


const columns = [
    // {
    //     type: 'action',
    //     typeAttributes: { rowActions: actions },
    // },
    // { label: 'CaseNumber', fieldName: 'CaseNumber', type: 'text' },
    // { type: "button",fieldName: 'CaseNumber', typeAttributes: {  
    //     label: 'View',  
    //     name: 'View',  
    //     title: 'View',  
    //     disabled: false,  
    //     value: 'view',  
    //     iconPosition: 'left'  
    // } },  
    {
        label: 'CaseNumber',
        type: 'button',
        fieldName: 'CaseNumber',
        typeAttributes: {
            value: {
                fieldName: 'CaseNumber'
            },
            label: {
                fieldName: 'CaseNumber'
            },
            title: {
                fieldName: 'CaseNumber'
            },
            name: {
                fieldName: 'CaseNumber'
            },
            variant: 'base'
        }
    },
    { label: 'Status', fieldName: 'Status' },
    { label: 'Subject', fieldName: 'Subject' },
    { label: 'Assigned To', fieldName: 'OwnerName' },
];

export default class CaseSearch extends NavigationMixin(LightningElement) {
    @track showPopup = { title: '', message: '', variant: '' };
    @track loader = false;
    @track allFilterSelected = {};
    @track selectedvalue;
    @track selectedValueList = [];
    // @track options = options;
    @track StatusOptions;
    @track CategoryOptions;
    @track searchInput = '';
    @track caseTableDate = [];
    @track lstCaseNumber = [];
    @track isOpenModal = false;
    @track OpenModalForUpdateCase = { isOpenModalForUpdateCase: false, buttonName: '', isUpdate: false, isEmail: false, switchButtonName: '' }
    @track recordOpened = {};
    @track caseUpdate = {
        caseNumbers: '',
        caseStatus: '',
        caseSubject: '',
        caseSubjectType: '',
        caseDescription: '',
        isNewSubjectNeeded: false,
        isEmailToSent: false
    };
    data = [];
    columns = columns;
    subjectTypePickList = [
        { label: 'New Subject', value: 'New Subject' },
        { label: 'Existing Subject', value: 'Existing Subject' },
    ]
    statusPickList = [
        // { label :'', value :'-None-'},
        { label: 'On Hold', value: 'On Hold' },
        { label: 'Escalated', value: 'Escalated' },
        { label: 'Closed', value: 'Closed' },
        { label: 'New', value: 'New' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Response Received', value: 'Response Received' },
        { label: 'New Case', value: 'New Case' },
        { label: 'Re-Open', value: 'Re-Open' },
        { label: 'Internal Response Received', value: 'Internal Response Received' },
        { label: 'Interested', value: 'Interested' },
        { label: 'Not Interested', value: 'Not Interested' },
        { label: 'Repeat case', value: 'Repeat case' },
        { label: 'Open', value: 'Open' },
        { label: 'Assigned', value: 'Assigned' },
        { label: 'In Progress(Escalated)', value: 'In Progress(Escalated)' },
        { label: 'Invalid Case', value: 'Invalid Case' }
    ]


    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        JSON.stringify('currentPageReference --> '  + currentPageReference);
    }


    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATUS_FIELD })
    wiredPicklistProgramType({ error, data }) {
        if (data) {
            let statusFieldArray = [{ 'label': 'none', 'value': 'none' }]
            data.values.forEach(statusField => {
                // console.log(statusField.label, statusField.value)
                statusFieldArray.push({ 'label': statusField.label, 'value': statusField.value })
            });
            this.StatusOptions = statusFieldArray;
            this.selectedvalue = '["New","Escalated","In Progress"]';
            let filterSelected= this.allFilterSelected;
                filterSelected["1"] = {
                apiName : "Status",
                extra: '',
                value: JSON.parse(this.selectedvalue),
                fieldType: 'MultiplePickList'
            }
            this.allFilterSelected = filterSelected;
            this.getSearchCaseFromController('', JSON.stringify(this.allFilterSelected ));
            // console.log(this.StatusOptions);
        }
        if (error) {
            console.log('error')
            this.showHtmlMessage('Something went wrong', error, 'error');

        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CATEGORY_FIELD })
    wiredPictProgramType({ error, data }) {
        if (data) {
            let categoryFieldArray = [{ 'label': 'none', 'value': 'none' }]
            data.values.forEach(statusField => {
                // console.log(statusField.label, statusField.value)
                categoryFieldArray.push({ 'label': statusField.label, 'value': statusField.value })
            });
            this.CategoryOptions = categoryFieldArray;
        }
        if (error) {
            console.log('error')
            this.showHtmlMessage('Something went wrong', error, 'error');
        }
    }
    connectedCallback() {
    }

    handleChangeForSubject(event) {
        this.caseUpdate.caseSubject = event.detail.value;
    }
    handleChangeForSubjectType(event) {
        if (event.detail.value == 'New Subject') {
            this.caseUpdate.isNewSubjectNeeded = true;
        } else {
            this.caseUpdate.isNewSubjectNeeded = false;
        }
        this.caseUpdate.caseSubjectType = event.detail.value;
    }
    handleChangeForStatus(event) {
        this.caseUpdate.caseStatus = event.detail.value;
    }
    handleDescriptionTextChange(event) {
        this.caseUpdate.caseDescription = event.detail.value;
    }

    async handleConfirmClick(event) {
        // console.log('result --> ' + event.currentTarget.dataset.updateSelected)
        console.log('result --> ' + JSON.stringify(this.caseUpdate))
        let isValid = false;
        if (event.currentTarget.dataset.updateSelected == 'Update Case And Send Mail') {
            if (this.caseUpdate.caseNumbers && this.caseUpdate.caseStatus && this.caseUpdate.caseSubjectType && this.caseUpdate.caseDescription && this.caseUpdate.isEmailToSent) {
                if ((this.caseUpdate.isNewSubjectNeeded && this.caseUpdate.caseSubject) || (!this.caseUpdate.isNewSubjectNeeded)) {
                    isValid = true;
                }
            }

        } else if (event.currentTarget.dataset.updateSelected == 'Update Case') {
            if (this.caseUpdate.caseNumbers && this.caseUpdate.caseStatus &&  !this.caseUpdate.isEmailToSent) {
                isValid = true;
            }
        }
        console.log('isValid --> ' + isValid)
        if (isValid) {
            const result = await LightningConfirm.open({
                label: 'Confirm ? ',
                message: 'Are you sure want to update Status to - ' + this.caseUpdate.caseStatus,
            });
            if (result) {
                this.SaveUpdateStatusAndSendMailForCase(this.caseUpdate);
            } else {
                this.showHtmlMessage('info', 'You Selected No', 'info');
            }
        } else {
            this.showHtmlMessage('Validation error', 'kindly enter all required value', 'error');
        }


    }

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        let arrayOfCaseNumber = [];
        selectedRows.forEach(element => {
            arrayOfCaseNumber.push(element.CaseNumber);
        });
        this.lstCaseNumber = arrayOfCaseNumber;
        // console.log(JSON.stringify(selectedRows))
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const { Id } = row;

        // console.log(actionName)
        // console.log(JSON.stringify(actionName))
        // console.log(JSON.stringify(event))
        // console.log('Id --> ' + Id);
        if (actionName == 'openInNewTab' || actionName.fieldName == 'CaseNumber') {
            this.openTabInNewTab(Id);
        } else if (actionName == 'openRecord') {
            console.log('insoder open recoed')
            this.caseTableDate.forEach(element => {
                if (element.Id == Id) {
                    this.recordOpened = element;
                }
            });
            this.isOpenModal = true;

        }
    }

    handleOnClickModalClose(event) {
        this.isOpenModal = false;
    }

    handleOpenInNewTab(event) {
        let newTab = event.currentTarget.dataset.newTab;
        this.openTabInNewTab(newTab);
    }

    handleOnUpdateCaseOpen(event) {
        if (this.lstCaseNumber.length > 0) {
            console.log('event.currentTarget.dataset -->' + JSON.stringify(event.currentTarget.dataset));
            this.OpenModalForUpdateCase.isOpenModalForUpdateCase = true;
            if (event.currentTarget.dataset.updateSelected == 'Update Case And Send Mail') {
                const slicedArray = this.lstCaseNumber.slice(0, 50);
                this.caseUpdate.caseNumbers = slicedArray.join(',');
                this.OpenModalForUpdateCase.isEmail = true;
                this.OpenModalForUpdateCase.isUpdate = false;
                this.OpenModalForUpdateCase.buttonName = 'Update Case And Send Mail';
                this.OpenModalForUpdateCase.switchButtonName = 'Update Case';
                this.caseUpdate.isEmailToSent = true;
            } else if (event.currentTarget.dataset.updateSelected == 'Update Case') {
                const slicedArray = this.lstCaseNumber.slice(0, 200);
                this.caseUpdate.caseNumbers = slicedArray.join(',');
                this.OpenModalForUpdateCase.isEmail = false;
                this.OpenModalForUpdateCase.isUpdate = true;
                this.OpenModalForUpdateCase.buttonName = 'Update Case';
                this.OpenModalForUpdateCase.switchButtonName = 'Update Case And Send Mail';
                this.caseUpdate.isEmailToSent = false;
            }
        } else {
            this.showHtmlMessage('Kindly select at least one case', 'error', 'error');
        }
    }
    handleOnUpdateCaseClose(event) {
        this.OpenModalForUpdateCase.isOpenModalForUpdateCase = false;
    }

    openTabInNewTab(Id) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: ''
            }
        }).then(url => {
            console.log(url)
            window.open('/' + Id, "_blank");
        });
    }

    //for multiselect picklist
    handleSelectOptionList(event) {
        console.log('handleSelectOptionList called')
        // console.log(event.detail);
        this.selectedValueList = event.detail;
        let filterSelected= this.allFilterSelected;
        filterSelected[event.currentTarget.dataset.fieldKey] = {
            apiName : event.currentTarget.dataset.apiName,
            extra: '',
            value: this.selectedValueList,
            fieldType: event.currentTarget.dataset.fieldType
        }

        console.log('event.currentTarget.dataset.apiName --' + event.currentTarget.dataset.apiName);
        // this.allFilterSelected[event.currentTarget.dataset.apiName] = this.selectedValueList;
        this.allFilterSelected = filterSelected;
        // console.log(JSON.stringify(this.allFilterSelected))
        this.getSearchCaseFromController(this.searchInput, JSON.stringify(this.allFilterSelected));
        // if (this.searchInput.length > 2) {
        // } else {
        //     this.showHtmlMessage('Kindly enter more than 2 character', 'error', 'info');
        // }
    }

    handleSearchInput(event) {
        this.searchInput = event.detail.value;
    }

    handleSearch(event) {
        console.log('Handle Search Called -->');
        console.log(this.searchInput)
        if (this.searchInput.length == 0 || this.searchInput.length > 2) {
            this.getSearchCaseFromController(this.searchInput, JSON.stringify(this.allFilterSelected));
        } else {
            this.showHtmlMessage('Kindly enter more than 2 character', 'error', 'info');
        }
    }

    getSearchCaseFromController(searchCase1, filterDetails) {
        console.log(searchCase1, filterDetails)
        let searchWord = searchCase1.length > 2 ? searchCase1 : '';
        this.loader = true;
        searchCase({ searchQuery: searchWord, filterDetails: filterDetails })
            .then(data => {
                this.loader = false;
                // console.log(data);
                if (data) {
                    // console.log(data);
                    if (data.length > 0) {
                        this.showHtmlMessage('new list reloaded.', 'success', 'success');
                        let dataTable = [];
                        data.forEach(element => {
                            let table = {
                                CaseNumber: element.CaseNumber,
                                Id: element.Id,
                                Subject: element.Subject,
                                Description: element.Description,
                                Status: element.Status,
                                OwnerName: element.Owner.Name
                            }
                            dataTable.push(table);
                        })
                        this.caseTableDate = dataTable;
                    } else {
                        this.caseTableDate = [];
                        this.showHtmlMessage('No record found.', 'kindly remove some filter or search different text', 'info');
                    }
                } else {
                    this.loader = false;
                    this.showHtmlMessage('Something went wrong.', error, 'error');
                }
            }).catch((error) => {
                this.loader = false;
                console.log(error);
                this.showHtmlMessage('Something went wrong.', error, 'error');
            });
    }

    SaveUpdateStatusAndSendMailForCase(caseUpdateObject) {
        this.loader = true;
        updateStatusAndSendMailForCase({ caseUpdateDetails: JSON.stringify(caseUpdateObject) })
            .then(response => {
                this.loader = false;
                console.log(response)
                if (response.includes('Failed')) {
                    this.showHtmlMessage("Something went Wrong", response, "error");
                } else {
                    this.showHtmlMessage("Updated", response, "success");
                }
                window.location.reload();

            })
            .catch(error => {
                this.showHtmlMessage("Something went Wrong", error.body.message, "error");
                this.loader = false;
                console.log(error)
            })
    }

    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}