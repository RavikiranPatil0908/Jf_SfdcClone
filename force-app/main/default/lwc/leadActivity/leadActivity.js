import { LightningElement, api, track, wire } from 'lwc';
import getTimelineItemData from '@salesforce/apex/salesCadenceController.getActivityHistory';
import getLeadRecord from '@salesforce/apex/salesCadenceController.getLeadRecord';

export default class LeadActivity extends LightningElement {
    @api recordId;
    @api activites;
    @api showHeader = false;
    @api count = 0;
    @track leadDetail;
    @track leadName;
    @track leadEmail;
    @track hasTimelineData = false;
    @track showFilter = false;
    @track dateFilterSelection = "all_time";
    @track taskAdded = false;
    error;

    @wire(getTimelineItemData,{recordId:'$recordId', dateFilter: '$dateFilterSelection', count: '$count'})
    getTimelineItemData({ error, data}) {
        if(data) {
            this.activites = data;
            this.hasTimelineData = true;
            console.log(this.activites);
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getLeadRecord,{recordId:'$recordId'})
    getLeadRecord({ error, data}) {
        if(data) {
            console.log(data);
            this.leadDetail = data;
            this.leadEmail = this.leadDetail.Email;
            this.leadName = this.leadDetail.Name;
            // this.task.WhoId = this.recordId;
        } else if (error) {
            console.error(error);
        }
    }

    handleRefereshChange(event) {
        if(event.detail.taskAdded){
            this.count = 1 + this.count;
        }
    }

    handleFilterChange(event) {
        if(event.detail.dateFilter){
            this.dateFilterSelection = event.detail.dateFilter;
        }
    }

}