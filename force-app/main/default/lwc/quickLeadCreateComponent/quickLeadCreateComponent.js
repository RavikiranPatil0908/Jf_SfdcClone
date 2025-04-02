import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPickListValuesForChooseProg from "@salesforce/apex/lightningButtonController.getPickListValuesForChooseProg";
import saveLeadDetails from "@salesforce/apex/lightningButtonController.saveLeadDetails";
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import getCenterUserData from "@salesforce/apex/lightningButtonController.getCenterUserData";
import getCPDetails from "@salesforce/apex/lightningButtonController.getCPDetails";
export default class QuickLeadUpdate extends LightningElement {

    @track showPopup = { title: '', message: '', variant: '' };
    @track selectedProgramValue;
    @track isEmpty = true;
    @track selectedChooseProgram;
    @track selectedChooseProgram;
    @track programListOptions = [{ label: 'Choose Program', value: '' }];
    @track mapOfValues = [];
    @track counselorOptions = [{ label: 'Choose Counselor Profile', value: '' }];
    @track mapOfCPValues = [];
    @track selectedProgram;
    @track otherLeadSource = false;
    @track allowBachelor = false;
    @track message;
    @track error;
    @api centerUser = {};
    @track ld ={
        FirstName : '',LastName : '',Email : '',MobilePhone : '',nm_DateOfBirth__c : '',LeadSource:'',nm_OtherLeadSources__c:'',
        nm_Gender__c : '',Status:'',Lead_Description__c:'',nm_ChooseaProgram__c : '',nm_Program__c:'',Lead_Action__c:'',Counselor_Profile__c:'',
        nm_Stream__c:'',Highest_Qualification__c:'',Working__c:'',Reason__c:'',nm_WorkExperience__c:'',Industry:'',nm_Designation__c:'',Next_Follow_up__c:'',
        nm_Mother_Tongue__c:'',nm_City_P__c:'',Comment__c:''
    }

    get chooseProgram() {
        return  this.allowBachelor ? [
            { label: 'Certificate Programs', value: 'Certificate Programs' },
            { label: 'Diploma Programs', value: 'Diploma Programs' },
            { label: 'Post Graduate Diploma Programs', value: 'Post Graduate Diploma Programs' },
            { label: 'Executive Programs', value: 'Executive Programs' },
            { label: 'Professional Programs', value: 'Professional Programs' },
            { label: 'Master Programs', value: 'Master Programs' },
            { label: 'Bachelor Programs', value: 'Bachelor Programs' }
        ] :  [
            { label: 'Certificate Programs', value: 'Certificate Programs' },
            { label: 'Diploma Programs', value: 'Diploma Programs' },
            { label: 'Post Graduate Diploma Programs', value: 'Post Graduate Diploma Programs' },
            { label: 'Executive Programs', value: 'Executive Programs' },
            { label: 'Professional Programs', value: 'Professional Programs' },
            { label: 'Master Programs', value: 'Master Programs' }
        ];
    }


    @wire(getCenterUserData, { userId: USER_ID })
	getAEPUserDetails({ error, data }) {
		if (data) {
			console.log(JSON.stringify(data));
            this.centerUser = data;
            if(this.centerUser.nm_Centers__c){
                this.getCounselorProfileData();
                if(this.centerUser.nm_Centers__r.Allow_Bachelor__c) {
                    this.allowBachelor = true;
                } else {
                    this.allowBachelor = false;
                }   
            }
		} else if (error) {
			console.error(error);
		}
    }

    getCounselorProfileData(){
        this.counselorOptions = [];
        this.mapOfCPValues =[]; 
        getCPDetails({centerId : this.centerUser.nm_Centers__c })
        .then((response) => {
            for (let key in response) {
                // Preventing unexcepted data 
                if (response.hasOwnProperty(key)) {
                    // Filtering the data in the loop
                    this.mapOfCPValues.push({ value: response[key], key: key });
                }
            }
            for (const list of this.mapOfCPValues) {
                const option = {
                    value: list.key,
                    label: list.value
                };

                this.counselorOptions = [...this.counselorOptions, option];
            }

    	})
		.catch((error) => {
            alert("Error !"+ error.body.message);
            console.log('error', JSON.stringify(error.body.message));
        });
    }


    // Form input handle change event
	handleName(event) {
        let field = event.target.dataset.field;
        
		if ({}.hasOwnProperty.call(this.ld, field)) {
            this.ld[field] = event.detail.value;
            if (field === "LeadSource") {
                if(this.ld[field] === 'Other'){
                    this.otherLeadSource = true;
                }else{
                    this.otherLeadSource = false;
                }
            }
		}
    }
    // To show Toast message
    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }

    handleChange(event){
        let value = event.currentTarget.dataset.value;
        console.log('handleChange '+value);
        if (value === "nm_ChooseaProgram__c") {
          this.selectedChooseProgram = event.target.value;
          console.log(this.selectedChooseProgram);
          this.ld.nm_ChooseaProgram__c = this.selectedChooseProgram;
          if (
            this.selectedChooseProgram &&
            this.selectedChooseProgram !== "--None--"
          ) {
            this.isEmpty = false;
            this.getProgramList();
          } else {
            this.isEmpty = true;
          }
        } else if (value === "nm_Program__c") {
          this.selectedProgram = event.target.value;
          console.log(this.selectedProgram);
          this.ld.nm_Program__c = this.selectedProgram;
        } else if (value === "Counselor_Profile__c") {
          let cpValue = event.target.value;
          console.log(cpValue);
          this.ld.Counselor_Profile__c = cpValue;
        }
    }

     // to validate the form.
	formValidate() {
		const allValid = [
			...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group')
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		return allValid;
	}
    
     // call apex method and insert or update  the lead 
    saveLead() {
        if (!this.formValidate()) {
			return;
		}
        console.log('Lead '+JSON.stringify(this.ld));
        saveLeadDetails({ lead : this.ld})
            .then(result => {
                this.message = result;
                this.error = undefined;
                if(this.message !== undefined) {
                    this.ld = {};
                    this.showHtmlMessage("Success", "Successfully Created !", "success");   
                }
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.showHtmlMessage('Error creating record!',error.body.message,'error');
                console.log("error", JSON.stringify(this.error));
            });
    }

    getProgramList() {
        this.programListOptions = [];
        this.mapOfValues = [];
        getPickListValuesForChooseProg({
            choosedProgValue: this.selectedChooseProgram
        })
            .then((result) => {
                for (let key in result) {
                    // Preventing unexcepted data
                    if (result.hasOwnProperty(key)) {
                        // Filtering the data in the loop
                        this.mapOfValues.push({ value: result[key], label: key });
                    }
                }
                for (const list of this.mapOfValues) {
                    const option = {
                        value: list.label,
                        label: list.value
                    };
                    // console.log('Option values '+JSON.stringify(option));

                    this.programListOptions = [...this.programListOptions, option];
                }
            })
            .catch((error) => {
                alert("Error !"+ error.body.message);
                console.log('error', JSON.stringify(error.body.message));
            });
    }
}