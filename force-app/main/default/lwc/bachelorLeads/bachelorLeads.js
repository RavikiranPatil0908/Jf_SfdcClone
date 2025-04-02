import { LightningElement,api, track, wire } from 'lwc';
import getAEPLeadDetails from '@salesforce/apex/purchaseLicenseForAEPController.getLeads';
import lightningSiteUrl from '@salesforce/label/c.lightningSiteUrl';
import communityURL from '@salesforce/label/c.communityURL';
import NewFormResource from '@salesforce/resourceUrl/NewFormResource';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';

const columns = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name'}, 
        target: '_top'},
        sortable: true
    },
    { label: 'Email', fieldName: 'Email', type: 'text', sortable: true },
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'text', sortable: true },
    { label: 'Lead Source', fieldName: 'LeadSource', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'Status', type: 'text', sortable: true },
    { label: 'Program Type', fieldName: 'Program_Type__c', type: 'text', sortable: true},
    {
        label: "Created Date",
        fieldName: "CreatedDate",
        type: "date-local",
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        },
        sortable: true
    }
];

export default class BachelorLeads extends LightningElement {
    @api hasData = false;
    @api experience;
    @track page = 1;
    @track pages = [];
    @track sortBy;
    @track sortDirection = 'asc';
    @track lstDescription = ['','',''];
    // dependent fields

    @track controllingValues = [];
    @track dependentValues = [];
    @track leadSourceValues = [];
    @track programTypeValues = [{label:'--None--', value:'--None--'},{label:'BBA', value:'BBA'},{label:'BCom', value:'BCom'}];
    @track filters = {
        Status: '',
        Lead_Description__c: '',
        Next_Follow_up__c: '',
        LeadSource: '',
        Program_Type__c: '',
        CreatedDate: ''
    }
    @track validFilters;
    DataLoading = true;
    isEmpty = true;
    columns = columns;
    set_size = 5;
    perpage = 50;
    data = [];
    searchVal;
    showFilter = false;
    showMobileFilter = false;
    showSortFilter = false;
    filterApplied = false;
    controlValues;
    totalDependentValues = [];
    mobileSortField;
    labelNames = {
        'Program_Type__c': 'Program Type',
        'CreatedDate': 'Created Date',
        'LeadSource': 'Lead Source',
        'MobilePhone': 'Mobile',
        'nameUrl': 'Name',
        'Lead_Description__c': 'Lead Description',
        'Next_Follow_up__c': 'Next Follow Up Date'
    };
    isFocus = false;

    get isClassic() {
        return this.experience === 'classic' ? true : false;
    }

    get sortColumns() {
        let fields = [];
        columns.forEach(element => {
            const option = {
                label: element.label,
                value: element.fieldName
            }
            fields.push(option);
        });
        return fields;
    }

    get directionOrders() {
        return [{label: 'Asc', value: 'asc'}, {label: 'Desc', value: 'desc'}]
    }

    get baseURL() {
        let baseURL = communityURL.includes(window.location.origin) ? communityURL : window.location.origin;
        if(!this.isClassic) {
            baseURL = `${lightningSiteUrl}s/detail`;
        }
        return baseURL;
    }

    connectedCallback() {
        if(this.isClassic) {
            Promise.all([ loadStyle(this, NewFormResource + '/css/inline.css') ]).then(() => {
                console.log('css loaded');
            });
        }
    }

    renderedCallback() {
        this.renderButtons();
    }
    renderButtons = () => {
        this.template.querySelectorAll('button').forEach((but) => {
            but.style.backgroundColor = this.page === parseInt(but.dataset.id, 10) ? 'dodgerblue' : 'white';
            but.style.color = this.page === parseInt(but.dataset.id, 10) ? 'white' : 'black';
        });
    }

    @wire(getAEPLeadDetails)
    getAEPLeadDetails({error, data}) {
        if(data) {
            // to push the description.
            let count = data.length > 50 ? '50+ items' : `${data.length} items`;
            this.lstDescription[0] = count;

            this.data = data.map(record => Object.assign(
                { "nameUrl": `${this.baseURL}/${record.Id}`},
                record
            ));
            this.setPages(this.data);
            this.DataLoading = false;
            this.hasData = true;
        }else {
            console.log(error);
            this.DataLoading = false;
        }
    }

    // dependent picklist
    // Account object info
    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfo;

    // Picklist values based on record type
    @wire(getPicklistValuesByRecordType, { objectApiName: LEAD_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
    statusPicklistValues({error, data}) {
        if(data) {
            let statusOptions = [{label:'--None--', value:'--None--'}];
            let sourceOptions = [{label:'--None--', value:'--None--'}];

            // Lead Status Control Field Picklist values
            data.picklistFieldValues.Status.values.forEach(key => {
                statusOptions.push({
                    label : key.label,
                    value: key.value
                })
            });

            this.controllingValues = statusOptions;
            
            data.picklistFieldValues.LeadSource.values.forEach(key => {
                sourceOptions.push({
                    label : key.label,
                    value: key.value
                })
            });
            this.leadSourceValues = sourceOptions;

            let descriptionOptions = [{label:'--None--', value:'--None--'}];

             // Lead Description Control Field Picklist values
            this.controlValues = data.picklistFieldValues.Lead_Description__c.controllerValues;
            // Lead Description dependent Field Picklist values
            this.totalDependentValues = data.picklistFieldValues.Lead_Description__c.values;

            this.totalDependentValues.forEach(key => {
                descriptionOptions.push({
                    label : key.label,
                    value: key.value
                })
            });

            this.dependentValues = descriptionOptions;
        }
        else if(error) {
            this.error = JSON.stringify(error);
        }
    }

    handleStatusChange(event) {
        // Selected Country Value
        this.filters.Status = event.target.value;
        this.isEmpty = false;
        let dependValues = [];

        if(this.filters.Status) {
            // if Selected country is none returns nothing
            if(this.filters.Status === '--None--') {
                this.isEmpty = true;
                dependValues = [{label:'--None--', value:'--None--'}];
                this.filters.Status = null;
                this.filters.Lead_Description__c = null;
                return;
            }

            // filter the total dependent values based on selected country value 
            this.totalDependentValues.forEach(conValues => {
                if(conValues.validFor[0] === this.controlValues[this.filters.Status]) {
                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })

            this.dependentValues = dependValues;
            if(dependValues.length < 1) {
                this.isEmpty = true;
            }
        }
    }

    handleChange(event) {
        let field = event.target.dataset.key;
		if ({}.hasOwnProperty.call(this.filters, field)) {
			this.filters[field] = event.target.value === '--None--' ? null : event.target.value ;
		}
    }

    getRefereshedLeadData() {
        getAEPLeadDetails()
        .then(result => {
            if(result) {
                this.pages = [];
                this.page = 1;
                // to push the description.
                let count = result.length > 50 ? '50+ items' : `${result.length} items`;
                this.lstDescription[0] = count;
                this.data = result.map(record => Object.assign(
                    { "nameUrl": `${this.baseURL}/${record.Id}`},
                    record
                ));
                this.setPages(this.data);
                this.DataLoading = false;
                this.hasData = true;
            } else {
                this.DataLoading = false;
            }
            
        })
        .catch(error => {
            console.log(error);
            this.DataLoading = false;
        });
    }

    get pagesList() {
        let mid = Math.floor(this.set_size / 2) + 1;
        if (this.page > mid) {
            return this.pages.slice(this.page - mid, this.page + mid - 1);
        }
        return this.pages.slice(0, this.set_size);
    }

    get hasPrev() {
        return this.page > 1;
    }
    get hasNext() {
        return this.page < this.pages.length
    }

    pageData() {
        let data = this.searchVal || this.filterApplied ? this.filteredData(this.searchVal) : this.data;
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page * perpage) - perpage;
        let endIndex = (page * perpage);
        return data.slice(startIndex, endIndex);
    }

    setPages(data) {
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }

    onNext = () => {
        ++this.page;
    }
    onPrev = () => {
        --this.page;
    }
    onPageClick = (e) => {
        this.page = parseInt(e.target.dataset.id, 10);
    }
    get currentPageData() {
        return this.pageData();
    }

    get dividers() {
        return this.lstDescription.filter(n => n);
    }

    get showNavigation() {
        return this.pages.length > 1 ? true : false;
    }

    get popoverClass() {
        return this.isFocus ?  
        'slds-popover slds-popover_tooltip slds-nubbin_top-left slds-is-absolute slds-m-top_x-small tooltip slds-rise-from-ground' :
        'slds-popover slds-popover_tooltip slds-nubbin_top-left slds-is-absolute slds-m-top_x-small tooltip slds-fall-into-ground';
    }

    handleBlur(event) {
        this.searchVal = event.target.value;
        if(!this.searchVal) {
            this.isFocus = false;
        }
    }

    loadPopUp() {
        this.isFocus = true;
    }

    hidePopUp() {
        this.isFocus = false;
    }

    handleClick(event) {
        let key = event.currentTarget.dataset.key;
        if(key === 'refersh') {
            this.getRefereshedLeadData();
        } else if(key === 'filter') {
            this.showFilter = !this.showFilter;
        } else if(key === 'mobileFilter') {
            this.showMobileFilter = !this.showMobileFilter;
        } else if(key === 'save') {
            this.showFilter = false;
            this.showMobileFilter = false;
            let fiteredOptions = [];
            this.validFilters = { ...this.filters };
            for (const key in this.filters) {
                if (this.filters.hasOwnProperty(key) && this.filters[key] && this.filters[key] != '--None--') {
                    this.filterApplied = true;
                    fiteredOptions.push(this.labelNames[key] != undefined ? this.labelNames[key] : key);
                }
            }
            this.filterApplied = fiteredOptions.length === 0 ? false : this.filterApplied;
            this.lstDescription[2] = this.filterApplied ? 'Filtered by - ' + fiteredOptions.join() : '';
            if(!this.filterApplied) {
                this.pages = [];
                this.page = 1;
                this.setPages(this.data);
            }
        } else if(key === 'cancel') {
            this.showFilter = false;
            this.showMobileFilter = false;
        } else if(key === 'mobileSort') {
            this.showSortFilter = true;
        } else if(key === 'saveSort') {
            this.showSortFilter = false;
            let event = {
                detail: {
                    fieldName: this.mobileSortField,
                    sortDirection: this.sortDirection
                }
            }
            this.handleSortdata(event);
        } else if(key === 'cancelSort') {
            this.showSortFilter = false;
        }
    }

    handleSortChange(event) {
        let key = event.target.dataset.key;
        if(key === 'field') {
            this.mobileSortField = event.detail.value;
        } else if(key === 'direction') {
            this.sortDirection = event.detail.value;
        }
    }

    filteredData(searchVal) {
        let data = [], filterData = [];
        if(this.filterApplied) {
            let filter = Object.entries(this.validFilters).reduce((a,[k,v]) => (v ? (a[k]=v, a) : a), {});
            filterData = this.data.filter(function(item) {
                for (const key in filter) {
                    let val = (key === 'CreatedDate' || key === 'Next_Follow_up__c') && item[key] ? item[key].split('T')[0] : item[key];
                    if (item[key] === undefined || val != filter[key]) {
                        return false;
                    }
                }
                return true;
            });
            if(searchVal) {
                data = this.searchFilter(searchVal, filterData);
            } else {
                data = filterData;
            }
        } else {
            data = this.searchFilter(searchVal, this.data);
        }

        // to match the page.
        let pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            pages.push(index);
        }
        if(!this.isEquivalent(pages,this.pages)) {
            this.pages = pages;
            this.page = 1;
        }
        return data;
    }

    searchFilter(searchVal, result) {
        let data = [];
        searchVal = searchVal != '' && searchVal != null ? searchVal.toLowerCase() : searchVal;
        result.forEach(item => {
            let name = item.Name.toLowerCase();
            let email = item.Email.toLowerCase();

            if(searchVal && (name.includes(searchVal) || email.includes(searchVal) || item.MobilePhone.includes(searchVal) 
            || (item.nm_RegistrationNo__c && item.nm_RegistrationNo__c.includes(searchVal))) ) {
                data.push(item);
            }
        });
        return data;
    }

    isEquivalent(a1,a2) {
        /* WARNING: arrays must not contain {objects} or behavior may be undefined */
        return JSON.stringify(a1)==JSON.stringify(a2);
    }

    handleSortdata(event) {
        const labelName = this.labelNames[event.detail.fieldName] != undefined ? this.labelNames[event.detail.fieldName] : event.detail.fieldName; 
        // field name
        this.sortBy = event.detail.fieldName;
        // sort direction
        this.sortDirection = event.detail.sortDirection;
        // to set the sortby description
        this.lstDescription[1] = `Sorted by ${labelName}`;
        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        // set the sorted data to data table data
        this.data = parseData;

    }

}