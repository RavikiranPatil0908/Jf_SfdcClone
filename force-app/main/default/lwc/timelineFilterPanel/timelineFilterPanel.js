import { LightningElement,track,api } from 'lwc';

export default class TimelineFilterPanel extends LightningElement {
    @track showFilter=false;
    @track dateFilterSelection="all_time";

    label = {
        Filter : 'Filter',
        Refresh_data: 'Refresh Data',
        Apply: 'Apply',
        Date_Range: 'Date Range',
        Filter_Results: 'Filter Results'
    }

    get filterStyles() {
        let filterStyle = '';
        if (this.showFilter) {
            filterStyle += 'display:block;';
        } else {
            filterStyle += 'display:none;';
        }
        filterStyle += 'position:absolute;top:2.25rem;left:-285px;width:300px;'
        return filterStyle;
    }
    showHideFilters() {
        this.showFilter = !this.showFilter;
    }

    get dateFilterOptions() {
        return [
            { label:'All Time', value: 'all_time' },
            { label: 'Last 7 days', value: 'last_7_days' },
            { label: 'Next 7 days', value: 'next_7_days' },
            { label: 'Last 30 days', value: 'last_30_days' },
        ];
    }


    handleDateFilterChange(event) {
        this.dateFilterSelection = event.detail.value;
    }


    applyFilters(event){
        let type = event.currentTarget.dataset.type;
        if(type === 'refersh') {
            this.dateFilterSelection = 'all_time';
        }
        const filterChangeEvent = new CustomEvent('change', {
            detail: {
                "dateFilter":this.dateFilterSelection,
            }
        });
        this.dispatchEvent(filterChangeEvent);
        if(type === 'submit') {
            this.showHideFilters();
        }
    }

    
}