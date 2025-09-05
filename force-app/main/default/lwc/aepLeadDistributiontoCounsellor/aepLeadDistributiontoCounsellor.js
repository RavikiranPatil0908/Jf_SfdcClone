/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 20-06-2025
 * @last modified by  : @Shailesh
**/
import { LightningElement,track,wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getcounsellorsfromuserId from '@salesforce/apex/AepLeadDistributionController.getcounsellorsfromuserId';
import getLeadStatus from '@salesforce/apex/AepLeadDistributionController.getLeadStatus';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import LEADSTATUS_OBJECT from "@salesforce/schema/LeadStatus";
import tranferLeadtoCounsellors from '@salesforce/apex/AepLeadDistributionController.tranferLeadtoCounsellors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AepLeadDistributiontoCounsellor extends LightningElement {

   // @track userId = Id;
    counsellors = []; //to hold seleced value
    @track counsellorLst = [];
    @track LeadStatusOptions = [{ label: 'Choose Lead Status', value: '' }];
    @track SessionOptions = [{ label: 'Choose sessions', value: '' },{ label: 'January', value: 'January' },{ label: 'July', value: 'July' },{ label: 'October', value: 'October' },{ label: 'September', value: 'September' },{ label: 'March', value: 'March' },{ label: 'April', value: 'April' },{ label: 'June', value: 'June' }];
    @track YearOptions = [{ label: 'Choose year', value: '' },{ label: '2023', value: '2023' },{ label: '2024', value: '2024' },{ label: '2025', value: '2025' },{ label: '2026', value: '2026' },{ label: '2027', value: '2027' },{ label: '2028', value: '2028' }];
    @track leadSourceOptions = [{ label: 'Choose Lead Source', value: '' },{ label: 'Web', value: 'Web' },{ label: 'Partner', value: 'Partner' }];
    formData = {};
    handlestatuschange(event) {
       // this.LeadStatusOptions = [{ label: 'Choose Drive', value: '' }];
        console.log(event.target.value);
        this.formData.leadStatus = event.target.value;
        console.log('this.formData :: '+JSON.stringify(this.formData));
    }
    handlesessionchange(event) {
       // this.DriveOptions = [{ label: 'Choose Drive', value: '' }];
       console.log(event.target.value);
        this.formData.session = event.target.value;
    }
    handleYearchange(event) {
       // this.DriveOptions = [{ label: 'Choose Drive', value: '' }];
       console.log(event.target.value);
        this.formData.year = event.target.value;
    }
    handleleadSourcechange(event) {
       // this.DriveOptions = [{ label: 'Choose Drive', value: '' }];
        console.log(event.target.value);
        console.log(event.detail.value);
        this.formData.leadSource = event.target.value;
    }


   // value = [];

    get options() {
        return this.counsellorLst;
    }

    get selectedValues() {
        return this.counsellors.join(',');
    }

    handleChange(event) {
        this.counsellors = event.detail.value;
        this.formData.counsellorIds = this.counsellors.join(',');
    }

    handleClickbtn(event){
        console.log('this.formData :: '+this.formData);
        console.log('this.formData :: '+JSON.stringify(this.formData));
         tranferLeadtoCounsellors({counsellorIds: this.formData.counsellorIds, leadStatus: this.formData.leadStatus, leadSource: this.formData.leadSource, session: this.formData.session, year: this.formData.year , userId: Id})
            .then(result => {
                // console.log('result' + JSON.stringify(result));
                 console.log('result123 :: ' + result);
                //     this.data = result;
                // console.log('data' + JSON.stringify(this.data));
            this.showAlert('Message', result, 'success');
            })
            .catch(error => {
                console.log('error' + JSON.stringify(error));
                 this.showAlert('Error Occured', error.body.message, 'error');
            });
    }

    showAlert(title, message, variant) {
        if (this.template.querySelector('lightning-toast')) {
            // Lightning Experience: Show toast notification
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        } else {
            // Classic Experience: Show alert
            alert(`${title}: ${message}`);
        }
    }

    //  gettranferLeadtoCounsellors() {
    //     console.log('gettranferLeadtoCounsellors:: ');
    //         tranferLeadtoCounsellors({counsellorIds: this.formData.counsellorIds, leadStatus: this.formData.leadStatus, leadSource: this.formData.leadSource, session: this.formData.session, year: this.formData.year , userId: Id})
    //         .then(result => {
    //              console.log('result' + JSON.stringify(result));
    //             //     this.data = result;
    //             // console.log('data' + JSON.stringify(this.data));
    //         })
    //         .catch(error => {
    //             console.log('error' + JSON.stringify(error));
    //         });
    //     }



     @wire(getLeadStatus)
    leadStatus({ error, data }) {
            
           // console.log('InsertEventMonitoring:: '+Id);
            if(data){
           // console.log('data', data);
            //console.log('==>'+JSON.stringify(data));
                if(data.length > 0) {
              //  console.log('data ls 123', data);
              //   console.log('data ls 123', data.values);
                data.forEach(statusField => {
            //    console.log(statusField.MasterLabel, statusField.Id)
                const options = { 'label': statusField.MasterLabel, 'value': statusField.MasterLabel };
                this.LeadStatusOptions = [...this.LeadStatusOptions,options];
            });
                //    this.hasData = true;
                } else {
                //    this.hasData = false;
                }
               // this.dataLoading = false;
            } else if (error) {
                console.error(error);
               // this.dataLoading = false;
            }
        }

      @wire(getcounsellorsfromuserId, { userId: Id })  //'005In000000jypN'
        counsellorsfromuserId({ error, data }) {
             //console.log('data', data);
            //console.log('==>'+JSON.stringify(data));
           // console.log('InsertEventMonitoring:: '+Id);
            if(data){
                if(data.length > 0){
                console.log('data cs 123', data);
                 //   this.counsellors = data;
                //    this.hasData = true;
                data.forEach(statusField => {
              //  console.log(statusField.Name, statusField.Id)
                const options = { 'label': statusField.Name+' :: '+statusField.Full_Name__c  , 'value': statusField.Id };
                this.counsellorLst = [...this.counsellorLst,options];
            });
                } else {
                //    this.hasData = false;
                }
               // this.dataLoading = false;
            } else if (error) {
                console.error(error);
               // this.dataLoading = false;
            }
        }

}