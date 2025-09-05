/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : @Shailesh
**/
import { LightningElement, api, wire, track } from 'lwc';
import getPersonAccountDetails from '@salesforce/apex/PersonAccountDetailsController.getPersonAccountDetails';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import insertEventMonitoring from '@salesforce/apex/EventMonitoringController.insertEventMonitoring';

export default class PersonAccountDetails extends LightningElement {
    @api recordId;
    @track records = [];
    @track dataLoading = true;
    @track hasData = false;

    constructor() {
        super();
        document.addEventListener("keydown", this.handleNotificationCopy);
        document.addEventListener("dragstart", this.handleNotificationDrag);

    }
     connectedCallback() {
        insertEventMonitoring({
        leadId: this.recordId,
        userId: Id,
        objectType: 'Account',
        event: 'View'
        });
     }
    handleNotificationCopy = (event) => {
        if (event.ctrlKey && event.key === 'c') {
          //  console.log('Ctrl + C pressed');
            insertEventMonitoring({
            leadId: this.recordId,
            userId: Id,
            objectType: 'Account',
            event: 'Copy'
        });
        }
    };
    handleNotificationDrag = (event) => {
       
          //  console.log('Draged');
            insertEventMonitoring({
            leadId: this.recordId,
            userId: Id,
            objectType: 'Account',
            event: 'Drag'
        });
        
    };

    @wire(getPersonAccountDetails, { recordId: '$recordId' })
    wiredPersonAccountDetails({ error, data }) {
        console.log('==>'+JSON.stringify(data));
       // console.log('InsertEventMonitoring:: '+Id);
        if (data) {
            if (data.length > 0) {
                this.records = data;
                this.hasData = true;
            } else {
                this.hasData = false;
            }
            this.dataLoading = false;
        } else if (error) {
            console.error(error);
            this.dataLoading = false;
        }
    }
}