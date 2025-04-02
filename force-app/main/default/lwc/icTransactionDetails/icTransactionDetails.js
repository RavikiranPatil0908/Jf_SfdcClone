import { LightningElement, api, track, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { formatDate } from 'c/formatedDate';
import getCenterUserData from '@salesforce/apex/purchaseLicenseForAEPController.getCenterUserData';
import getAEPList from '@salesforce/apex/purchaseLicenseForAEPController.getAEPCenterData';
import getPaymentDetails from '@salesforce/apex/purchaseLicenseForAEPController.getPaymentDetails';

export default class IcTransactionDetails extends LightningElement {

    @api experience = 'lightning';
    @track transactionRecords = [];
    //@track searchFilter = { month: '', year: '', centerId: '' };
   @track searchFilter = { fromMonthYear: '', toMonthYear: '', centerId: '' };
    
    @track showPopup = { title: '', message: '', variant: '' };

    @track password = '';
    @track centerUser = {};
    @track aepDetails = {};
    @track aepOptions = [];

    isAdmin = false;
    alertPrompt = false;
    isLoading = false;
    isLC = false;
    hasData = false;
    totalDebit = 0;
    totalCredit = 0;

    @api
    get months() {
        return [
            { label: 'January', value: 'January' },
            { label: 'February', value: 'February' },
            { label: 'March', value: 'March' },
            { label: 'April', value: 'April' },
            { label: 'May', value: 'May' },
            { label: 'June', value: 'June' },
            { label: 'July', value: 'July' },
            { label: 'August', value: 'August' },
            { label: 'September', value: 'September' },
            { label: 'October', value: 'October' },
            { label: 'November', value: 'November' },
            { label: 'December', value: 'December' }
        ];
    }

    get isClassic() {
        if(this.experience === 'classic') {
            return true;
        }
        return false;
    }

    @wire(getCenterUserData, { userId: USER_ID })
	getAEPUserDetails({ error, data }) {
        console.log("data in getAEPUserDetails" + JSON.stringify(data));
        if (data) {
            console.log(JSON.stringify(data));
            if (Object.keys(data).length === 0 && data.constructor === Object){
                //alert("You are not authorize for this page....");
                this.showHtmlMessage('Error', 'You are not authorize for this page....', 'error');
                this.isAdmin = false;
            }else{
                this.isAdmin = true;
                this.alertPrompt = true;
                this.centerUser = data;
                if(this.centerUser.nm_Centers__c){
                    this.aepDetails = data.nm_Centers__r;
                    if(this.aepDetails.recordtype__c === 'Learning Center') {
                        this.isLC = true;
                        this.getAEPLists(this.centerUser.nm_Centers__c);
                    }
                }
            }
		} else if (error) {
            console.error(error);
        } 
    }

    handleChange(event) {
        let field = event.target.dataset.name;
		if ({}.hasOwnProperty.call(this.searchFilter, field)) {
           	this.searchFilter[field] = event.detail.value;
		}
    }

    formValidate() {
		const allValid = [
			...this.template.querySelectorAll('lightning-input, lightning-combobox')
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		return allValid;
	}

    handleClick() {
		if (!this.formValidate()) {
			return;
        }
        this.isLoading = true;
        this.totalDebit = 0;
        this.totalCredit = 0;
        if(!this.isLC) {
            this.searchFilter.centerId = this.centerUser.nm_Centers__c;
        }
        getPaymentDetails({ objWrapper: this.searchFilter  })
			.then((response) => {
                if(response) {
                    // this.transactionRecords = response;
                    this.transactionRecords = new Array;
                    console.log(response);
                    let closingBalance = 0;
                    response.forEach(element => {
                        console.log(element, "ELEMENT");
                        //console.log(element.Opportunity__r.Is_Re_Registration_Payment__c, "ELEMENT Opportunity");
                        // 1. Format Date

                        let type = element.Transaction_Type__c;
                        let credit,debit,date,dtVal,isCredit;

                        let admissionStatus;
                        dtVal = new Date(element.Date__c);
                        date = formatDate(dtVal,'MMMM dd, yyyy','');
                        if (element.Opportunity__r) {
                            if(element.Opportunity__r.Is_Re_Registration_Payment__c === true) {
                                admissionStatus = 'Re Registration';
                            }
                            if(element.Opportunity__r.Is_Re_Registration_Payment__c === false) {
                                admissionStatus = 'Fresh Admission';
                            }

                        } 
                        
                        // 2. Filtering the data in the loop
                        if(type && type.includes('Credit')) {
                            closingBalance = closingBalance + element.Amount__c;
                            credit = parseFloat(element.Amount__c).toFixed(2);
                            this.totalCredit = this.totalCredit + element.Amount__c;
                            isCredit = true;
                        } else if(type && type.includes('Debit')) {
                            closingBalance = closingBalance - element.Amount__c;
                            debit = parseFloat(element.Amount__c).toFixed(2);
                            this.totalDebit = this.totalDebit + element.Amount__c;
                            isCredit = false;
                        }

                        this.transactionRecords.push({ 
                            value: element, 
                            key: element.Id, 
                            isCredit:isCredit, 
                            credit: credit, 
                            debit: debit, 
                            balance: parseFloat(closingBalance).toFixed(2), 
                            date: date, 
                            admissionStatus: admissionStatus
                        });
                    });
                    this.isLoading = false;
                    this.hasData = true;
                    this.totalDebit = parseFloat(this.totalDebit).toFixed(2);
                    this.totalCredit = parseFloat(this.totalCredit).toFixed(2);
                } else {
                    this.showHtmlMessage('Info!', 'No Data Found', 'warning');
                    this.isLoading = false;
                    this.hasData = false;
                }
            })
			.catch((error) => {
				console.log(error);
                this.showHtmlMessage('Error!', error.body.message, 'error');
                this.hasData = false;
                this.isLoading = false;
			});
    }

    handleCodeChange = (event) => {
        this.password = event.detail.value;
    } 

    validatePassCode = () => {
        if (!this.formValidate() || !this.password) {
			return;
        }
        if(this.password.trim() === this.aepDetails.Password__c) {
            this.alertPrompt = false;
        } else {
            this.showHtmlMessage('Invalid Password!', '', 'error');
            this.isAdmin = false;
        }
    }

    async getAEPLists(lcId) {
        console.log(lcId);
        this.isLoading = true;
        await getAEPList({centerId: lcId})
        .then(result => {
            console.log(result);
            console.log(JSON.stringify(result));
            if(result && result.length > 0) {
                result.forEach(element => {
                    const option = {
                        value: element.Id,
                        label: element.Name
                    };
                    this.aepOptions = [ ...this.aepOptions, option ];
                });
            }
            console.dir(this.aepOptions);
            this.isLoading = false;
        })
        .catch(error => {
            console.log(error);
            this.hasData = false;
            this.isLoading = false;
        });
    }

    // To show Toast message
	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
    

    generatePdf(){
        let Uri = '';
        if(!this.isClassic) {
            Uri = window.location.origin + '/apex/';
        }
        // let url = `${Uri}ICPaymentReport?pdf=true&Info=${this.searchFilter.centerId}&filterMonth=${this.searchFilter.fromMonthYear}&filterYear=${this.searchFilter.toMonthYear}&selectedFilter=MMYYYY`;
        let url = `${Uri}ICPaymentReport?pdf=true&Info=${this.searchFilter.centerId}&fromMonthYear=${this.searchFilter.fromMonthYear}&toMonthYear=${this.searchFilter.toMonthYear}&selectedFilter=MonthYearRange`;
        console.log(url);
        window.open(url);
      }
}