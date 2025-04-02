import { LightningElement, api, wire, track } from 'lwc';
import { getRecord ,updateRecord,generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import { NavigationMixin } from 'lightning/navigation';
import getCenterUserData from '@salesforce/apex/purchaseLicenseForAEPController.getCenterUserData';
import getCPDetails from '@salesforce/apex/purchaseLicenseForAEPController.getCPDetails';
import saveCentersDetails from '@salesforce/apex/purchaseLicenseForAEPController.saveCentersDetails';
import DebitShareEntry from '@salesforce/apex/purchaseLicenseForAEPController.DebitShareEntry';
import saveContacts from '@salesforce/apex/purchaseLicenseForAEPController.saveContacts';
import rollbackDebitShareEntry from '@salesforce/apex/purchaseLicenseForAEPController.rollbackDebitShareEntry';
//import rollbackCentersDetails from '@salesforce/apex/purchaseLicenseForAEPController.rollbackCentersDetails';
import saveCentersDetailsForOnline from '@salesforce/apex/purchaseLicenseForAEPController.saveCentersDetailsForOnline';
import Contact_Name from '@salesforce/schema/User.AccountId__c';
import getMonthsBetween from '@salesforce/apex/purchaseLicenseForAEPController.getNoOfMonths';
import sendNotificationEmail from '@salesforce/apex/purchaseLicenseForAEPController.sendNotificationEmail';
import licensesFee from '@salesforce/label/c.Licenses_Fee';
import siteUrl from '@salesforce/label/c.Site_Url'; 
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact_OBJECT from '@salesforce/schema/Contact';
import ContactRole from '@salesforce/schema/Contact.User_Role__c';

export default class AepPurchaseLicense extends NavigationMixin(LightningElement)  {
    @track showPopup = { title: '', message: '', variant: '' };
    @api centerUser = {};
    @api aepDetails = {};
    @track cpRecords = [];
    @track message;
    @track error;
    @track onlinepayment = false;
    @track numberOflicense = 0;
    @track sizeofCpRecords;
    @api contactRecord = { FirstName: '', LastName: '', AccountId: '', Phone: '', Email: '', LeadSource: '', Counselor_Profile__c: ''};
    @track contactRecordToInsert = [] ;
    @track ichareId;
    @track accId;
    @track options;

    @api calculation = {
        monthsBetween : 0,
        perMonth : licensesFee,
        noOfProfiles : 0,
        amount : 0,
        show : false
    };
    @api allowProceed = false;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [Contact_Name]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           console.log(error);
        } else if (data) {
            this.accId = data.fields.AccountId__c.value;
            console.log('accId '+this.accId);
        }
    }

    @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
    objectInfo;
    
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ContactRole })
	getBoardNameList({ error, data }) {
		if (data) {
			this.options = data.values;
		} else if (error) {
			console.error(error);
		}
	}

    @wire(getMonthsBetween)
    getMonthsBetween({ error, data }) {
		if (data) {
            this.calculation.monthsBetween = data;
		} else if (error) {
			console.error(error);
		}
    }
    
    // @wire(getRecord, { recordId: this.contactname, fields: FIELDS })
    // contact({
    //     error,
    //     data
    // }) {
    //     if (error) {
    //        this.error = error ; 
    //        console.log('error '+error);  
    //     } else if (data) {
    //         console.log('data '+data);
    //         this.accId = data.fields.AccountId.value;
    //         console.log('accId '+this.accId);
    //     }
    // }


    @wire(getCenterUserData, { userId: USER_ID })
	getAEPUserDetails({ error, data }) {
        console.log("data in getAEPUserDetails" + JSON.stringify(data));
        if (data) {
            console.log(JSON.stringify(data));
            if (Object.keys(data).length === 0 && data.constructor === Object){
                //alert("You are not authorize for this page....");
                this.showHtmlMessage('Error', 'You are not authorize for this page....', 'error');
            }else{
                this.centerUser = data;
                if(this.centerUser.nm_Centers__c){
                    this.getCounselorProfileData();
                    this.aepDetails = data.nm_Centers__r;
                  //  this.sendEmail();
                }
            }
		} else if (error) {
            console.error(error);
        } 
    }
    
    getCounselorProfileData(){
      getCPDetails({centerId : this.centerUser.nm_Centers__c })
        .then((response) => {
            let arrayofCpRecords = [];
            console.log('response ' + JSON.stringify(response));
            if (Object.keys(response).length === 0 && response.constructor === Object){
                //alert("This center does not have any counselor profiles deatails");
                this.showHtmlMessage('Error', 'This center does not have any counselor profiles deatails', 'error');
            }else{
                for (let key in response) {
                    // Preventing unexcepted data 
                    if (response.hasOwnProperty(key)) {
                        // Filtering the data in the loop
                        this.cpRecords.push({ value: response[key], key:key, selected : false, role: 'User' });
                    }
                }
                console.log('cpRecords ' + JSON.stringify(cpRecords));
                arrayofCpRecords = this.cpRecords;
                this.sizeofCpRecords = arrayofCpRecords.length;
            }
    	})
		.catch((error) => {
			this.message = undefined;
            this.error = error;
		});
    }

    handleChange(event){

        if(event.target.name === 'undertakingForLicense'){
            if(event.target.checked){
                this.allowProceed = true;
            }else{
                this.allowProceed = false;
            }
        } else if(event.target.name === 'role') {
            let value = event.currentTarget.dataset.key;
            console.log('value ==> '+value);
            this.cpRecords.forEach(element => {
                if(element.key === value) {
                    element.role = event.target.value;
                }
            });
        }

        // if(event.target.name === 'takenCpForLicense'){
        //     if(event.target.checked){
        //         this.numberOflicense = this.numberOflicense + 1;
        //         const index = this.listOfCpIds.indexOf(event.target.value);
        //         if (index > -1) {
        //             this.listOfCpIds.splice(index, 1);
        //         }else{
        //             this.listOfCpIds.push(event.target.value);
        //         }
        //     }else{
        //         this.numberOflicense = this.numberOflicense - 1;
        //         const index = this.listOfCpIds.indexOf(event.target.value);
        //         if (index > -1) {
        //             this.listOfCpIds.splice(index, 1);
        //         }
        //     }
        //     console.log('listOfCpIds '+this.listOfCpIds);
        // }         
    }

    handleClick(event) {
        let value = event.currentTarget.dataset.value;
        console.log('value ==> '+value);
        this.cpRecords.forEach(element => {
            if(element.key === value) {
                if(element.selected) {
                    element.selected = false;
                    --this.calculation.noOfProfiles; 
                }else if(!element.selected) {
                    element.selected = true;
                    ++this.calculation.noOfProfiles;  
                }
                this.calculateTotalAmount();
            }
        });
    }

    calculateTotalAmount() {
        this.calculation.amount = parseFloat((this.calculation.noOfProfiles * this.calculation.perMonth) * this.calculation.monthsBetween).toFixed(2);
        if (this.calculation.amount > 0) {
            this.calculation.show = true;
        } else {
            this.calculation.show = false;
        }
    }

	formValidate() {
		const allValid = [
			...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group')
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		return allValid;
    }

    saveLicenseDetails(){
        console.log('this.aepDetails.Id '+ JSON.stringify(this.centerUser));
        var answer = window.confirm("Are you sure you want to pay the license fee amount from your IC share ?");
        if (answer === true) {
            saveCentersDetails({ numberOflicense: this.calculation.noOfProfiles, centerId: this.aepDetails.Id })
                .then((result) => {
                    if (result != null) {
                        this.showHtmlMessage('Record updated successfully !', result.TotalLicensesRequired__c, 'success');
                        this.createIcdebitShare();
                    }
                })
                .catch((error) => {
                    this.showHtmlMessage('Error while updating the record!', 'error', 'error');
                    this.rollbackChangesForCenter();
                    console.log(error);
                });
        }else{
            return;
        }
    }
    
    // rollback changes if any error in center details update
    rollbackChangesForCenter() {
        saveCentersDetails({ numberOflicense: 0, centerId: this.aepDetails.Id })
            .then((result) => {
                if (result != null) {
                    this.showHtmlMessage('Rollback Chnages done !', result.TotalLicensesRequired__c, 'warning');
                }
            })
            .catch((error) => {
                this.showHtmlMessage('Error while updating the record!', 'error', 'error');
                console.log(error);
            });
    }

    saveCenterDetailsOnlineMethod(){
        let cpusers = {};
        this.cpRecords.forEach(element => {
            if(element.selected) {
                cpusers[element.key] = element.role;
            }
        });
        console.log('cpusers '+JSON.stringify(cpusers));
        let cpusersJSON = JSON.stringify(cpusers);
        saveCentersDetailsForOnline({ numberOflicense: this.calculation.noOfProfiles, amount: this.calculation.amount, cpusers: cpusersJSON , centerId : this.aepDetails.Id })
            .then((result) => {
                if (result != null) {
                    this.showHtmlMessage('Record updated successfully !', result.TotalLicensesRequired__c, 'success');
                    this.onlinepayment = true;
                    window.open(siteUrl + 'nmAdditonalCharge?id=' + this.aepDetails.Id, "_self");
                    //window.history.back();
                }
            })
            .catch((error) => {
                this.showHtmlMessage('Error while updating the record!', 'error', 'error');
                this.rollbackCenterDetailsOnlineMethod();
                console.log(error);
            });
    }

    rollbackCenterDetailsOnlineMethod() {
        saveCentersDetailsForOnline({ numberOflicense: 0, amount: 0.0, cpusers: '',  centerId: this.aepDetails.Id })
            .then((result) => {
                if (result != null) {
                    this.showHtmlMessage('Rollback Chnages done !', result.TotalLicensesRequired__c, 'warning');
                    this.insertContacts();
                }
            })
            .catch((error) => {
                this.showHtmlMessage('Error while updating the record!', 'error', 'error');
                console.log(error);
            });
    }

    createIcdebitShare(){
        DebitShareEntry({AEPId : this.aepDetails.Id , licensesFee : this.calculation.amount})
        .then((result) => {
           console.log('result '+result);
           if(result != null){
                let icshareIdsplited = result.split(" ");
                this.ichareId = icshareIdsplited[1];
                console.log('ichareId '+this.ichareId);
                if(result.indexOf("success") > -1){
                    this.showHtmlMessage('Record saved successfully !', result, 'success');
                    this.insertContacts();
                } else if (result === 'No Credit Found to Debit Licenses Fee'){
                    this.showHtmlMessage('Please choose online paymnet method to pay', result, 'error');
                    this.rollbackChangesForCenter();
                }else{
                    this.showHtmlMessage('Something went wrong.', result, 'error');
                    this.rollbackChangesForCenter();
                }
           }
        })
        .catch((error) => {
            this.showHtmlMessage('Error while updating the record!', 'error in createIcdebitShare', 'error');
            this.rollbackChangesForCenter();
            this.rollbackChangesForIcpayment();
            console.log(error);
        });
    }

    // rollback changes if any error in ic payment insertion
    rollbackChangesForIcpayment() {
        rollbackDebitShareEntry({ centerId: this.aepDetails.Id })
            .then((result) => {
                if (result != null) {
                    this.showHtmlMessage('Rollback Chnages done !', result , 'warning');
                }
            })
            .catch((error) => {
                this.showHtmlMessage('Error while deleting the record!', 'error', 'error');
                console.log(error);
            });
    }

    insertContacts(){
        let conatcts = [];
        let uniqueContacts = {};
        this.cpRecords.forEach(element => {
            if(element.selected) {
                this.contactRecord.FirstName = element.value.First_Name__c ;
                this.contactRecord.LastName = element.value.Last_Name__c;
                this.contactRecord.AccountId = this.accId;
                this.contactRecord.Email = element.value.Email__c;
                this.contactRecord.Phone = element.value.MobilePhone__c;
                this.contactRecord.LeadSource = 'Web';
                this.contactRecord.Counselor_Profile__c = element.key;
                this.contactRecord.User_Role__c = element.role;
                let contact  = {...this.contactRecord};
                conatcts.push(contact);
            }  
        });
        console.log('conatcts ' + JSON.stringify(conatcts));
        for (let i in conatcts) {
            this.contactRecord.Counselor_Profile__c = conatcts[i]['Counselor_Profile__c'];
            uniqueContacts[this.contactRecord.Counselor_Profile__c] = conatcts[i];
        }
        for (let i in uniqueContacts) {
            this.contactRecordToInsert.push(uniqueContacts[i]);
        }
        console.log('contactRecordToInsert ' + JSON.stringify(this.contactRecordToInsert));
        saveContacts({lstContactInsert : this.contactRecordToInsert})
        .then((result) => { 
           console.log('result '+result);
           if(result != null){
                this.showHtmlMessage('Record saved successfully !', 'success', 'success');
                window.open(siteUrl+"nmRegistrationThankYou?id="+this.ichareId);
                this.sendEmail();
                window.history.back();
                // location.reload(); 
           }
        })
        .catch((error) => {
            this.showHtmlMessage('Error while inserting the record!', 'error in insertContacts', 'error');
            this.rollbackChangesForCenter();
            this.rollbackChangesForIcpayment();
            console.log(error);
        });
    }

    sendEmail(){
        sendNotificationEmail({ aepName: this.aepDetails.Center_Name__c, noOfLicense: this.calculation.noOfProfiles, amount: this.calculation.amount, timeperiod: this.calculation.monthsBetween, listofContact: this.contactRecordToInsert, receiptLink: siteUrl + "nmRegistrationThankYou?id=" + this.ichareId, paymentType: 'IC share'})
            .then((result) => {
                console.log('result ' + result);
                if (result === 'success') {
                    this.showHtmlMessage('Email has been sent !', 'Email sent', 'success');
                }else {
                    this.showHtmlMessage('Error', result, 'error');
                }
            })
            .catch((error) => {
                this.showHtmlMessage('Error occured!', 'error while sending an email', 'error');
                console.log(error);
            });
    }

    // To show Toast message
	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
	}
}