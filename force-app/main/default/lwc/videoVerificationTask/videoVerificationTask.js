import { LightningElement,api, track, wire } from 'lwc';
import lightningSiteUrl from '@salesforce/label/c.lightningSiteUrl';
import communityURL from '@salesforce/label/c.communityURL';
import NewFormResource from '@salesforce/resourceUrl/NewFormResource';
import { loadStyle } from 'lightning/platformResourceLoader';
import findVideoCallByStatus from '@salesforce/apex/VideoVerificationTaskController.findVideoCallByStatus';
import { formatDate } from 'c/formatedDate';
import LightningAlert from "lightning/alert";
import Id from "@salesforce/user/Id";
import { getRecord } from 'lightning/uiRecordApi';
import ProfileName from '@salesforce/schema/User.Profile.Name';


const columns = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Student_Name__c'}, 
        target: '_blank'},
        sortable: true
    },
    // { label: 'Subject', fieldName: 'Subject', type: 'text', sortable: true },
    { label: 'Schedule Call Time', fieldName: 'scheduleCallTime', type: 'text', sortable: true },
    { label: 'Registration No', fieldName: 'registrationNo', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true },
    {
        label: "Call date",
        fieldName: "Call_Date__c",
        type: "date-local",
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        },
        sortable: true
    },
    { label: 'IsVideoCallVerified', fieldName: 'isVideoCallVerified', type: 'text', sortable: true },
    { label: 'Call Play Url', fieldName: 'Call_Recording_Url__c', type: 'url',
        typeAttributes: {label: 'Play', 
        target: '_blank'}, sortable: true }
];

export default class VideoVerificationTask extends LightningElement {

    labelNames = {
        'Status__c': 'Status',
        'isVideoCallVerified': 'IsVideoCallVerified',
        //'Subject': 'Subject',
        'Call_Date__c': 'Call date',
        'registrationNo': 'Registration No',
        'nameUrl': 'Name',
        'scheduleCallTime': 'Schedule Call Time',
        'Call_Recording_Url__c': 'Call Play url'
    };
    @api experience;
    @track sortBy;
    @track sortDirection = 'asc';
    @track lstDescription = ['','',''];
    // dependent fields

    @track filters = {
        TaskStatus: [],
        To_From_Date: '',
        To_Call_Date: ''
    }
    DataLoading = false;
    columns = columns;
    data = [];
    showFilter = false;
    // rowLimit ;
    // rowOffSet ;

    @track statusTaskValues = [
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
        { label: 'Not Connected', value: 'Not Connected' }
    ];

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
    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
        async wireuser({ error, data }) {
        if (data) {
            //console.log('wireuser :: data :'+data.fields.Profile.value.fields.Name.value+':::: '+Id);
            let userProfile = data.fields.Profile.value.fields.Name.value;
            if(userProfile === 'Information Center' || userProfile === 'Information Center Executive Community User' || userProfile === 'Information Center Partner Community User')
            {
                //console.log('wireuser :: data :'+data.fields.Profile.value.fields.Name.value);  
                this.columns = [...columns].filter(columns => columns.fieldName != 'Call_Recording_Url__c');
            }

        } else if (error) {
            console.log(JSON.stringify(error));
        }
        }


    connectedCallback() {
        if(this.isClassic) {
            Promise.all([ loadStyle(this, NewFormResource + '/css/inline.css') ]).then(() => {
                console.log('css loaded');
            });
        }
        var rDate = new Date();
        var resultDate=rDate.toISOString();
        let today = resultDate.split('T');
        rDate.setDate(rDate.getDate() + 1);
        resultDate=rDate.toISOString();
        let tommorrow = resultDate.split('T');
        this.filters.To_Call_Date = tommorrow[0];
        this.filters.To_From_Date = today[0];
        this.filters.TaskStatus = ['In Progress'];
        // this.rowLimit = 15;
        // this.rowOffSet = 0;

        this.searchTask();
    }

    searchTask(){
        if(this.filters.To_From_Date > this.filters.To_Call_Date)
            {
                LightningAlert.open({
                    message: "To date cannot be less than From date.",
                    theme: "warning",
                    label: "validation error!", 
                  });
                return;
            }
        if(this.filters.To_From_Date == null || this.filters.To_Call_Date == null)
        {
            LightningAlert.open({
                message: "Date cannot empty.",
                theme: "warning",
                label: "validation error!",
              });
            return;
        }
        if(this.filters.TaskStatus == '' )
            {
                LightningAlert.open({
                    message: "Atleast select one option.",
                    theme: "warning",
                    label: "validation error!",
                  });
                return;
            }
        //console.log(this.filters.To_From_Date+' :: '+this.filters.TaskStatus+' :: '+this.filters.To_Call_Date);
        return findVideoCallByStatus({ callStatus :this.filters.TaskStatus,fromDate:this.filters.To_From_Date,callDate:this.filters.To_Call_Date}).then(data => {
            let nameUrl,registrationNo,scheduleCallTime,isVideoCallVerified;
           // console.log('result' + data);
            let calldata = data.map(row => { 
                nameUrl = `/${row.Account__r.Id}`;
                registrationNo = row.Account__r.nm_RegistrationNumber__c;
                isVideoCallVerified = row.Account__r.is_Video_Call_Verified__c;
                scheduleCallTime = formatDate(new Date(row.Schedule_Call_Time__c) ,'d/MM/yyyy h:mm TT','');
                //console.log('isVideoCallVerified :: '+isVideoCallVerified+' row.Account.is_Video_Call_Verified__c :: '+ row.Account.is_Video_Call_Verified__c);
                return {...row , nameUrl, registrationNo,scheduleCallTime,isVideoCallVerified};
            });
            this.data = calldata;
            this.DataLoading = false;
		})
        .catch(error => {
            console.log(error);
            LightningAlert.open({
                message: "No of record is to high, please choose appropriate filters.",
                theme: "warning",
                label: "Record Limit error!", 
              });
         
        });

    }
    
    handleStatusChangeTask(event){
        this.filters.TaskStatus = event.target.value;
        //console.log('this.filters.TaskStatus :: '+this.filters.TaskStatus);
    }

    handleChange(event) {
        let field = event.target.dataset.key;
		if ({}.hasOwnProperty.call(this.filters, field)) {
			this.filters[field] = event.target.value === '--None--' ? null : event.target.value ;
		}
        //console.log('this.filters :: '+this.filters.To_Call_Date +' ::::: '+this.filters.To_From_Date);
    }
    handleClick(event){
        this.showFilter = !this.showFilter;
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
    handleSortChange(event) {
        let key = event.target.dataset.key;
        if(key === 'field') {
            this.mobileSortField = event.detail.value;
        } else if(key === 'direction') {
            this.sortDirection = event.detail.value;
        }
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