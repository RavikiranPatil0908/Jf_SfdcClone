/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 07--12--2024
 * @last modified by  : @Ravi
**/
import { LightningElement, track, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import CURRENT_USER from '@salesforce/schema/User.Name';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import CASE_OBJECT from '@salesforce/schema/Case';
import uploadFiles from '@salesforce/apex/MyCasesController.uploadFiles';
import transferCase from '@salesforce/apex/UpdateInternalCaseOwner.caseTransfer';
import verifyStudentAccount from '@salesforce/apex/UpdateInternalCaseOwner.verifyStudentAccount';
import getLCName from '@salesforce/apex/UpdateInternalCaseOwner.getLCName';
import createCase from '@salesforce/apex/UpdateInternalCaseOwner.createCase';
import CATEGORY_NAME from '@salesforce/schema/Case.InternalCategory__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import LightningAlert from "lightning/alert";
import { NavigationMixin } from 'lightning/navigation';
import AccountId from '@salesforce/schema/AccountHistory.AccountId';

export default class RaiseInternalTicket extends NavigationMixin(LightningElement) {

   
   @api isClassic = false;
    @track record;
    @track CurrentuserName ;
    @track accountId;
    @track recordTypeId;
    @track message = '';
    @track msg = '';
    @track studentNumber='';
    @api internalRecordTypeId;
    @track categories;
    @track filesUploaded = [];
    @track ccEmailError = '';
  
    objectApiName = CASE_OBJECT;
    isUploadFile = false;
    isAEPRequest = false;
    isValidCCEmail = true;
    isValid= true;
    fileUploadError;
    isAEP = false;
    categoryVal;
    errorMsg;
    showSpinner = true;
    SAPId ;

    @track objCase = {
        purpose__c: '',
        InternalCategory__c: '',
        InternalSub_Category__c: '',
        CC_Emails__c : '',
        Description: '',
        AccountId: '',
        nm_StudentNo__c: '',
        RecordTypeId: ''

    };

    @track purposes = [{ label: 'None', value: '' }, 
        { label: 'Complaint', value: 'Complaint' }, 
        { label: 'Enquiry', value: 'Enquiry' }, 
        { label: 'Feedback', value: 'Feedback' }
    ];

    @track subcategories = [
        { label: 'None', value: '' },
        { label: 'Email / Mobile Update', value: 'Email / Mobile Update' },
        { label: 'Send Email / Mobile Verification link', value: 'Send Email / Mobile Verification link' },
        { label: 'Personal Details Update', value: 'Personal Details Update' },
        { label: 'Eligibility Criteria Change', value: 'Eligibility Criteria Change' },
        { label: 'Program Change', value: 'Program Change' },
        { label: 'Loan Query', value: 'Loan Query' },
        { label: 'Registration Cancel', value: 'Registration Cancel' },
        { label: 'Payment Related', value: 'Payment Related' },
        { label: 'Document Query', value: 'Document Query' },
        { label: 'Lead Status Update', value: 'Lead Status Update' },
        { label: 'Dispatch Location Update', value: 'Dispatch Location Update' }
    ];
    
   
    connectedCallback() {
        this.categoriesVsUserNameMap = new Map();
        const userNameVsCategoryPairs = [
            ['Mihhiir Lakhani', 'Marketing'],
            ['NGASCE Exams - University', 'TEE'],
            ['Ngasce exams', 'Internal Exam'],
            ['Ngasce Academics', 'Academics'],
            ['Sangeeta Shetty', 'Student Support'],
            ['Finance Department', 'Finance'],
            ['Harshad Kasliwal', 'Product'],
            ['Likesh Bhambhwani', 'Product'],
            ['Deepali Shetty', 'Logistics'],
            ['Admission Dept.', 'Admissions'],
            ['Varun Mathur', 'Career Services'],
            ['LC Mumbai', 'LC Mumbai'],
            ['LC Lucknow', 'LC Lucknow'],
            ['LC Hyderabad', 'LC Hyderabad'],
            ['LC Chennai', 'LC Chennai'],
            ['LC Bangalore', 'LC Bangalore'],
            ['LC Indore', 'LC Indore'],
            ['LC Ahmedabad', 'LC Ahmedabad'],
            ['LC Pune', 'LC Pune'],
            ['LC Kolkata', 'LC Kolkata'],
            ['LC Delhi', 'LC Delhi'],
            ['LC Chandigarh', 'LC Chandigarh']
        ];
        userNameVsCategoryPairs.forEach(key => {
            this.categoriesVsUserNameMap.set(key[0], key[1]);
        });
    }
 
  
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            let objArray = data.recordTypeInfos;
            for (let i in objArray) {
                if (objArray[i].name === "Internal Ticket")
                    //eslint-disable-next-line @lwc/lwc/no-api-reassignments
                    this.internalRecordTypeId = objArray[i].recordTypeId;
            }
            console.log("recordtypeId " + this.internalRecordTypeId);
        } else if (error) {
            console.log(JSON.stringify(error))
        }
    }

    @wire(getRecord, { recordId: Id, fields: [PROFILE_NAME ,CURRENT_USER] })
    wireuser({ error, data }) {
        if (data) {

            if (data.fields.Name.value != null) {
                this.CurrentuserName = data.fields.Name.value;
                console.log("Current user Name : " + this.CurrentuserName);
            }
            // this.userProfileName = data.fields.Profile.value.fields.Name.value;
            if(data.fields.Profile.value.fields.Name.value === 'Information Center Partner Community User') {
                this.isAEP = true;
            }
            console.log("is AEP:" + this.isAEP);
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$internalRecordTypeId', fieldApiName: CATEGORY_NAME })
    async picklistCategoryResults({ error, data }) {
        if (data) {
            // console.log("values =" + data.values);
            console.log("picklist data " + JSON.stringify(data.values));
            let LCName; 
            if(this.isAEP) {
                LCName = await this.getLCNameOfAEP();
                console.log("LC Name of AEP : " + LCName);
            }          
            this.categories = [{ label: 'None', value: '' }];
            data.values.forEach(category => {
               
                this.categoryVal = this.categoriesVsUserNameMap.get(this.CurrentuserName);
                console.log(" category value From Map  =" +  this.categoryVal);
                if(this.isAEP && (LCName === category.value  || category.value =='AEP Request')) {
                    const options = { 'label': category.label, 'value': category.value };
                    this.categories = [ ...this.categories, options ];
                } else if(!this.isAEP && (category.value != this.categoryVal )) {       //&& (category.value != 'AEP Request')
                    const options = { 'label': category.label, 'value': category.value };
                    this.categories = [ ...this.categories, options ];
                }
            });
            this.showSpinner = false;
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }


    handleCategory(event){
        this.isAEPRequest =false;
       this.objCase.InternalCategory__c = event.target.value;
       if(this.objCase.InternalCategory__c =='AEP Request') {
            this.isAEPRequest =true;    
       }
    }
    
    restrictAlphabets(event) {
        const charCode = event.which ? event.which : event.keyCode;
        // Allow only numbers (0-9), keyCode for numbers is 48-57
        if (charCode < 48 || charCode > 57) {
            event.preventDefault(); // Prevent the keypress if it's not a number
        }
    }

    handleCCEmail(event) {
        this.objCase.CC_Emails__c = event.target.value;
        const emailInput = event.target.value;
        const emails = emailInput.split(',').map(email => email.trim());
        // Regular expression to validate email addresses
        const emailPattern = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        // Reset flags and messages
        this.isValidCCEmail = true;
        this.ccEmailError = '';
    
        // Validate each email
        emails.forEach(email => {
            if (!emailPattern.test(email)) {
                this.isValidCCEmail = false;
             }
        });
        // Display error if any email is invalid
        if (!this.isValidCCEmail) {
            this.ccEmailError = 'Please enter valid email addresses.';
        }
    }


    handleChange(event) {
        this.objCase[event.target.dataset.field] = event.target.value;
        console.log(this.objCase[event.target.dataset.field]);
    }

    async getLCNameOfAEP() {
        let LcName = await getLCName()
			.then(result => {
				return result;
			})
			.catch(error => {
				console.log(error);
			});
        return LcName;
    }

    get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx'];
	}
  


    // Set the new Record
    async handleSubmit() {
        try {
            // Validate Form
            console.log(this.isValidCCEmail);
            if(!this.isValidCCEmail) {
                this.showMessage('Please enter valid email addresses.', 'warning', 'validation failed!');
                return ;
            }
           
            if(this.isEmpty(this.objCase.purpose__c) || this.isEmpty(this.objCase.InternalCategory__c) 
                || this.isEmpty(this.objCase.InternalSub_Category__c) || this.isEmpty(this.objCase.Description)) {

              if(this.objCase.InternalSub_Category__c=='AEP Request' && this.isEmpty(this.objCase.nm_StudentNo__c)){
                    this.showMessage('Please Enter Student SAP ID for AEP Request', 'warning', 'validation failed!');
                    return;
              }
              
              if(this.ccEmailError != ''){
                    this.showMessage('Please Enter Valid email address', 'warning', 'validation failed!');
                    return;
              } 
                this.showMessage('Fill all the mandatory details', 'error', 'Fields Incomplete!');
                return;
            } 

            this.objCase.Subject = `${this.objCase.InternalCategory__c} - ${this.objCase.InternalSub_Category__c}`;
            this.objCase.RecordTypeId = this.internalRecordTypeId;
            this.showSpinner = true;
           
            console.log("this.isAEPRequest :: " + this.isAEPRequest);
            console.log("!this.isEmpty(this.objCase.nm_StudentNo__c) ::" + !this.isEmpty(this.objCase.nm_StudentNo__c));

            if(this.isAEPRequest  && !this.isEmpty(this.objCase.nm_StudentNo__c)) {
                console.log("Student Number: " + this.objCase.nm_StudentNo__c);
                this.studentNumber= this.objCase.nm_StudentNo__c;
               this.accountId =await this.verifyStudent();
               console.log('accountId:::'+ this.accountId); 

               if(this.isEmpty(this.accountId)) {
                this.showMessage('Please Enter Valid SAP ID ', 'warning', 'validation failed!');
                this.showSpinner = false;
                 this.objCase.nm_StudentNo__c =''
                   return;
               }  
               this.objCase.AccountId = this.accountId;
              // console.log('this.objCase.Account:::'+  this.objCase.AccountId);   //test
            } 
   
            this.record = await this.insertCase();
            if(this.isEmpty(this.record)) {
                this.handleError();
                return;
            }
            this.handleSucces();
        } catch (error) {
            this.showSpinner = false;
            this.showMessage(error, 'error', 'Error!');
        }
    }

        async verifyStudent(){
            console.log("Verifying Student..."+this.isAEP);
              const AccId = await verifyStudentAccount({sapId: this.objCase.nm_StudentNo__c ,isAEP :this.isAEP})
              .then(result => {
                return result;
              }) .catch(error => {
               console.log(error);
               this.errorMsg = this.handleErrorResponse(error);
           });
            return AccId;
           }

    async insertCase() {
        console.log('Case transfer process initiated ==>'+this.objCase.Account);
        const RecordId = await createCase({objCase: this.objCase})
        .then(result => {
            console.log('Case transfer result ==>'+result);
            return result;
        })
        .catch(error => {
            console.log(error);
            this.errorMsg = this.handleErrorResponse(error);
        });
        return RecordId;
    }

    handleFileUploaded(event) {
		this.fileUploadError = '';
		if (event.target.files.length > 0) {
			console.log(event.target.files);
			const MAX_FILE_SIZE = (3 * 1024 * 1024);
			for (let i = 0; i < event.target.files.length; i++) {
				let file = event.target.files[i];
				if (file.size > MAX_FILE_SIZE) {
					this.fileUploadError = 'File size exceeds the limit';
				} else {
					let reader = new FileReader();
					reader.onload = () => {
						let base64 = 'base64,';
						let content = reader.result.indexOf(base64) + base64.length;
						let fileContents = reader.result.substring(content);
						var extension = file.name.split('.');
						if (!this.acceptedFormats.includes('.' + extension[extension.length - 1])) {
							this.fileUploadError = 'Select file with valid extension';
						} else {
							this.filesUploaded.push({ PathOnClient: file.name, Title: file.name, VersionData: fileContents });
						}
					};
					reader.readAsDataURL(file);
				}
			}
		}
	}

    handleRemove(event) {
		let title = event.target.dataset.fid;
		let index = this.filesUploaded.findIndex(obj => obj.Title === title);
		console.log(index);
		this.filesUploaded.splice(index, 1);
	}

    async attachFiles() {
		await uploadFiles({ files: this.filesUploaded, caseId: this.record })
			.then(result => {
				if (result === true) {
					this.showUpload = false;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

    async updateCaseOwner() {
        let isSuccess = await transferCase({ caseId: this.record , isAEPUser : this.isAEP ,studentNumber :this.studentNumber })
            .then(result => {
                console.log('Case transfer result ==>'+result);
                console.log('Case transfer result ==>'+JSON.stringify(result));
                // if (result === true) {
                //     this.showSpinner = false;
                // }
                return result;
            })
            .catch(error => {
                console.log(error);
            });
        return isSuccess;
    }

    isEmpty(str) {
        return (!str || str.length === 0 );
    }

    async handleSucces() {
        console.log('Record ID: ', this.record);
        if(this.isUploadFile) {
            await this.attachFiles();
        }
        const isSuccess = await this.updateCaseOwner();
        this.showSpinner = false;
        if (this.objCase.purpose__c === 'Feedback') {
            this.msg = `Thank you for your feedback for ${this.objCase.Subject}. We have taken note of it and forwarded it to the relevant teams.`;
            this.showMessage(this.msg, 'success', 'Success!');
        } else {
            this.showMessage('Your ticket has been raised successfully.', 'success', 'Success!');
            // this.msg = 'success'
            // this.handleNavigate(this.msg);
        }
        this.msg = 'success';
        if(!isSuccess) {
            this.showMessage('Case didn\'t transfered to the Function, Kindly raise it to System Admin.', 'warning', 'Error!');
        } else {
            this.handleNavigate(this.msg);
        }
    }

    handleCheckChange(event) {
		this.isUploadFile = event.target.checked;
        if(!this.isUploadFile && this.filesUploaded.length > 0) {
			this.filesUploaded = [];
		}
	}

    handleCancel() {
        this.msg = 'cancel';
        console.log("cancel");
        this.handleNavigate(this.msg);
    }

    handleError() {
        this.showSpinner = false;
        console.error('Error: ', this.errorMsg);
        this.showMessage(this.errorMsg, 'error', 'Error!');
    }

    handleNavigate(msg) {
        if(this.isClassic) {
            this.handleClassicNavigation(msg);
        } else {
            this.handleLightningNavigation(msg);
        }
    }

    handleClassicNavigation(msg) {
        if (msg === 'success') {
            let redirectURL = '/' + this.record;
            console.log(redirectURL);
            window.open(redirectURL, "_self");
        } else {
            window.open('/500', '_self');
        }
    }

    handleLightningNavigation(msg) {
        if(msg === 'success') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.record,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'list'
                },
                state: {
                    filterName: 'Recent' 
                }
            });
        }
	}

    showMessage(msg, theme, label) {
        LightningAlert.open({
            message: msg,
            theme: theme,
            label: label,
            variant: 'header',
        });
    }

    handleErrorResponse(error) {
        // Handle and display the error message
        if (error && error.body && Array.isArray(error.body)) {
            // If the error is an array of errors (usually for validation rules)
            const errorMessages = error.body.map(err => err.message);
            // Display the error messages
            return errorMessages.join(', ');
        } else if (error && typeof error.body.message === 'string') {
            // If the error is a single message
            return error.body.message;
        } 
        // Generic error handling
        return 'Unknown error';
    }
}