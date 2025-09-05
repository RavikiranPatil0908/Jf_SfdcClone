/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 28-07-2025
 * @last modified by  : @Shailesh
**/
import { LightningElement,wire,track } from 'lwc';
import getAEPefficency  from '@salesforce/apex/AEPEfficiencyReportController.getAEPefficency';

const columns = [
    //{ label: 'Label', fieldName: 'driveName' },
    //{ label: 'Website', fieldName: 'driveName1'},
    { label: 'LC Name', fieldName: 'lcName', type: 'text', sortable: true  },
    { label: 'AEP Name', fieldName: 'aepName', type: 'text', sortable: true  },
    { label: '# of Active Councellors', fieldName: 'activeCounsellorCount', type:'number', sortable: true },
    //{ label: 'Phone', fieldName: 'totalCounsellorCount' },
    { label: 'Jan2025 Sem1 Admissions', fieldName: 'semCountValue' , type:'number', sortable: true},
     { label: 'Jul2025 Sem1 Admissions', fieldName: 'semCountValue1', type:'number', sortable: true },
      { label: 'Jan2025 Performance', fieldName: 'peformanceValue', type:'number', sortable: true},
    { label: 'Jul2025 Performance', fieldName: 'peformanceValue1', type:'number', sortable: true},
];
export default class AEPEfficiencyReport extends LightningElement {
     labelNames = {
        'lcName': 'LC Name',
        'aepName': 'AEP Name',
        'activeCounsellorCount': '# of Active Councellors',
        'semCountValue': 'Jan2025 Sem1 Admissions',
        'semCountValue1': 'Jul2025 Sem1 Admissions',
        'peformanceValue': 'Jan2025 Performance',
        'peformanceValue1': 'Jul2025 Performance'
    };
@track data = [];
columns = columns;
@track sortBy;
@track sortDirection = 'asc';
@track lstDescription = ['','',''];
 //@track listData = [];
 //@track drive1 = '';
 //@track drive2 = '';
 connectedCallback() {

    this.checkAEPefficency('');

 }

 checkAEPefficency(searchValue){

    
    getAEPefficency({drivename: 'Jan2025,Jul2025' ,search : searchValue })
            .then(result => {
                // console.log('result' + JSON.stringify(result));
                 console.log('result123 :: ' + result);
                 console.log('result123json :: ' + JSON.parse(result));
                //     this.data = result;
               //  this.listData = result;
                this.data=[];
                JSON.parse(result).forEach(statusField => {
                console.log(statusField.driveName, statusField.lcName,statusField.driveName1);
                //this.drive1 = statusField.driveName;
                //this.drive2 = statusField.driveName1;
             
                const options = { 
                    'driveName': statusField.driveName, 
                    'driveName1': statusField.driveName1, 
                    'lcName': statusField.lcName, 
                    'aepName': statusField.aepName,
                    'activeCounsellorCount': statusField.activeCounsellorCount,
                    'totalCounsellorCount': statusField.totalCounsellorCount,
                    'semCountValue': statusField.semCountValue,
                    'peformanceValue': statusField.peformanceValue,
                    'semCountValue1': statusField.semCountValue1,
                    'peformanceValue1': statusField.peformanceValue1      
                };
                //this.listData = [...this.listData,options];
                this.data = [...this.data,options];
                });
                 console.log('data' + this.data);
                 //console.log('data123' ,  this.drive1, this.drive2);
            })
            .catch(error => {
                console.log('error' + JSON.stringify(error));
            });

 }
    handleRefreshbtn(){
    location.reload();
    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
            console .log('==>'+this.queryTerm);
            this.checkAEPefficency(evt.target.value);
        }
    }
    handleSortdata(event) {
        console.log('event :: ' + JSON.stringify(event));
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
    handleSortChange(event) {
        let key = event.target.dataset.key;
        if(key === 'field') {
            this.mobileSortField = event.detail.value;
        } else if(key === 'direction') {
            this.sortDirection = event.detail.value;
        }
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
 
//  @wire(getAEPefficency, { drivename: 'Jan2025,Jul2025' })
//     wiredgetAEPefficency({ error, data }) {
//         console.log('==>'+JSON.stringify(data));
//         console.log('data123' + data);
//         console.log('data123.length' + data.length);
//        // console.log('InsertEventMonitoring:: '+Id);
//         if (data) {
//             if (data.length > 0) {
//              data.forEach(statusField => {
//                // console.log(statusField.MasterLabel, statusField.Id);
//                 const options = { 'driveName': statusField.driveName, 
//                     'lcName': statusField.lcName, 
//                     'aepName': statusField.aepName,
//                     'totalCounsellorCount': statusField.totalCounsellorCount,
//                     'semCountValue': statusField.semCountValue,
//                     'peformanceValue': statusField.peformanceValue,
//                     'activeCounsellorCount': statusField.activeCounsellorCount};
//                 this.listData = [...this.listData,options];
//                 });
//                  console.log('data123' + this.listData);
//             } else {
        
//             }
      
//         } else if (error) {
//             console.error(error);
     
//         }
//     }

    

    
}