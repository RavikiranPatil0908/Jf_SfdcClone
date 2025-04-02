/* eslint-disable no-console */
import { LightningElement, api , track} from 'lwc';

export default class PaginationParent extends LightningElement {

	@api page = 1;
    @api totalrecords;
    @api centerRecordId;
    @api _pagesize = 5;
    @api oppIdfound = false;
    @api updateOpp;
	@track recordUpdate = false;
	
	get pagesize() {
		return this._pagesize;
	}
	set pagesize(value) {
		this._pagesize = value;
    }
    
    get checkCenterRecordId() {
        if(this.centerRecordId) {
            return true;
        }

        return false;
    }

	handlePrevious() {
		if (this.page > 1) {
			this.page = this.page - 1;
		}
	}
	handleNext() {
		if (this.page < this.totalPages) this.page = this.page + 1;
	}
	handleFirst() {
		this.page = 1;
	}
	handleLast() {
		this.page = this.totalPages;
	}
	handleRecordsLoad(event) {
		this.totalrecords = event.detail;
		this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
	}
	handlePageChange(event) {
		this.page = event.detail;
    }
    handleRecordLoadOnOpportunity(event) {
        this.oppIdfound = true;
        this.updateOpp = event.detail;
    }
    handleNewPageSize(event) {
        this.pagesize = event.detail;
	}
	
}