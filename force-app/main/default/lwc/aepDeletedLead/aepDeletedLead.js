import { LightningElement, api, track, wire } from 'lwc';
import getAEPLeadDetails from '@salesforce/apex/purchaseLicenseForAEPController.getDeletedLeads';
const columns = [
    { label: 'Name', fieldName: 'Name',type: 'text' },
    { label: 'Id', fieldName: 'Id', type: 'text'},
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'text' },
    { label: 'Lead Source', fieldName: 'LeadSource', type: 'text' },
    { label: 'Other Lead Source', fieldName: 'nm_OtherLeadSources__c', type: 'text' },
    { label: 'Choose Program', fieldName: 'nm_ChooseaProgram__c', type: 'text' },
    { label: 'Deleted Date', fieldName: 'LastModifiedDate', type: 'date'}
];

export default class AepDeletedLead extends LightningElement {
    columns = columns;
    @api hasData = false;
    @track page = 1;
    @track pages = [];
    set_size = 5;
    perpage = 20;
    data = [];

    renderedCallback() {
        this.renderButtons();
    }
    renderButtons = () => {
        this.template.querySelectorAll('button').forEach((but) => {
            but.style.backgroundColor = this.page === parseInt(but.dataset.id, 10) ? 'dodgerblue' : 'white';
            but.style.color = this.page === parseInt(but.dataset.id, 10) ? 'white' : 'black';
        });
    }

    async connectedCallback() {
        this.data = await getAEPLeadDetails();
        if(this.data) {
            this.setPages(this.data);
            this.hasData = true;
        }
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

    pageData = () => {
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page * perpage) - perpage;
        let endIndex = (page * perpage);
        console.log(this.data.slice(startIndex, endIndex));
        return this.data.slice(startIndex, endIndex);
    }

    setPages = (data) => {
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

}