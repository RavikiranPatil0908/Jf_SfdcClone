/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 18--07--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   10--07--2025   @Ravi   Initial Version
**/
import { LightningElement,track,api,wire} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningPrompt from 'lightning/prompt';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import getAccount from '@salesforce/apex/LightningAccountButtonController.getAccount';
import getRecordForNewEmail from '@salesforce/apex/LightningAccountButtonController.getRecordForNewEmail';
import getRecordForNewMobile from '@salesforce/apex/LightningAccountButtonController.getRecordForNewMobile';
import findDuplicateLead from '@salesforce/apex/LightningAccountButtonController.findDuplicateLead';
import updateLeadRecord from '@salesforce/apex/LightningAccountButtonController.updateLeadRecord';
import updateAccountRecord from '@salesforce/apex/LightningAccountButtonController.updateAccountRecord';
export default class UpdateEmailMobileButton extends LightningElement {
    @track updateType;
    @api recordId;
    newEmail;
    newMobile;
    account;
    lead;
    msg;
    currentAcc;
    currentLeadCreatedDate;

    updateOptions = [
        { label: 'Update Email', value: 'Update Email' },
        { label: 'Update Mobile', value: 'Update Mobile' },
    ];

    handleChange(event) {
        this.updateType = event.detail.value;
    }

    handleCancel() {
        this.closeQuickAction();
    }

    handleSave() {
        if (this.updateType) {
            this.closeQuickAction();
            this.updateMethod();
        }
    }

    @wire(getAccount,{ recordId: '$recordId' })
    checkAccount({ error, data }) {
        if (data) {
            console.log(data.accountData);
            this.currentAcc = data.accountData;
            let leaddate = new Date(data.accountData.Lead_created_date__c);
            this.currentLeadCreatedDate = `${leaddate.getDate()}/${leaddate.getMonth() + 1}/${leaddate.getFullYear()}`;
        }
        else if (error) {
            console.error(error);
            this.closeQuickAction();
        }
    }

   async updateMethod() {
       if(this.updateType == 'Update Email'){
       await this.handlePromptClick('New Email', 'Please enter new emaill address here...', 'email');
       if (this.newEmail === null || this.newEmail === undefined || this.newEmail === '') {
        this.closeQuickAction(); 
       return;
     }
        if(!this.isNullOrEmpty(this.newEmail) && /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/.test(this.newEmail)) {
            await this.getLeadAccountEmail();
             if(this.lead) {
                this.msg ='Are you sure you want to update the Email ?';
                await this.updateLead();
            }
            else if(this.account) {
                this.msg ='Are you sure you want to update the Email ?';
                await this.updateAccount();
            } else {
                console.log('this.newEmail'+this.newEmail);
                this.updateExistingAccount(this.currentAcc.Id, this.newEmail, null, null, null, null, null);
            }
        }
        else {
            this.handleAlert('Please enter valid email address');
        }
   } 
   else if(this.updateType === 'Update Mobile') {
    await this.handlePromptClick('New Mobile Number', 'Please enter new mobile number here', 'mobile');
    if (this.newMobile === null || this.newMobile === undefined || this.newMobile === '') {
      this.closeQuickAction(); 
    return;
    }
     this.msg='';
    if(!this.isNullOrEmpty(this.newMobile && Number.isInteger) && this.newMobile.match(/^\d{10}$/)) {
        await this.getLeadAccountMobile();
        if(this.lead) {
            this.msg ='Are you sure you want to update the Mobile number ?';
            await this.updateLead();
          
        }
        else if(this.account) {
            this.msg ='Are you sure you want to update the Mobile number?';
            await this.updateAccount();
            
        } else {
            this.updateExistingAccount(this.currentAcc.Id, null, this.newMobile, null, null, null, null);
        }
    } 
    else {
        this.handleAlert('Please enter valid mobile number....');
    }
   }
}

async updateAccount () { 
    const message = `Account Info =>
                    Registration Number: ${this.account.nm_RegistrationNumber__c},
                    Current Status     : ${this.account.nm_StudentStatus__c},
                    IC Name            : ${this.account.IC_Name_1__c},
                    Stage              : ${this.account.nmCaptureOpportuntiyStage__c},
                    Actual Amount Received: ₹${this.account.Total_amount_received__c}
                    `;
    const confirm = await LightningConfirm.open({
        message: message,
        variant: 'header',
        label: this.msg,
        theme: 'warning' 
    });

    if(confirm) {
                let initialCreatedDate = this.convertDate(this.account.Lead_created_date__c);                   
                let checkCreatedDate = this.checkDate(this.currentLeadCreatedDate,initialCreatedDate);
                let sameLc = this.checkLc(this.currentAcc.LC_Name__c, this.account.LC_name__c, this.currentAcc.IC_company__c, this.account.IC_company__c, this.currentAcc.GroupName__c, this.account.GroupName__c);
                if(this.updateType == 'Update Email') {
                    this.updateExistingAccount(this.currentAcc.Id, this.newEmail, null, this.account.PersonLeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate);
                } else {
                    this.updateExistingAccount(this.currentAcc.Id, null, this.newMobile, this.account.PersonLeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate);
                }
                
            }
        else {
                this.closeQuickAction();
                this.handleAlert('No action perform');
            }
}
async updateLead() {
        const message = `Lead Info =>
                        Registration Number : ${this.lead.nm_RegistrationNo__c} ,
                        Current Status      : ${this.lead.Status} ,
                        IC Name             : ${this.lead.IC_Name__c}`;

        const confirm = await LightningConfirm.open({
            message: message,
            variant: 'header',
            label: this.msg,
            theme: 'warning' 
        });

        if(confirm) {
            let initialCreatedDate = this.convertDate(this.lead.Lead_created_date__c);
            let checkCreatedDate = this.checkDate(this.currentLeadCreatedDate,initialCreatedDate);
            let sameLc = this.checkLc(this.currentAcc.LC_Name__c, this.lead.LC_name__c, this.currentAcc.IC_company__c, this.lead.IC_company__c, this.currentAcc.GroupName__c, this.lead.GroupName__c);
            if(this.updateType == 'Update Email') {
                this.updateExistingLead(this.lead.nm_LeadId__c, this.lead.Email, this.currentAcc.Id, this.newEmail, null, null, this.lead.LeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate);
            } else {
                this.updateExistingLead(this.lead.nm_LeadId__c, null, this.currentAcc.Id, null, this.lead.MobilePhone, this.newMobile, this.lead.LeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate)
            }
            
        }
        else {
            this.handleAlert('No action perform');
        }
}

 async updateExistingLead(leadId, email, accountId, updateEmail, mobile, updateMobile, leadSource, currentLeadSource, sameLc, checkCreatedDate ){
    let lead = {};
    lead['Id'] = leadId;
    if(!this.isNullOrEmpty(email)) {
        lead['Email'] = 'duplicate' + email;
        lead['InactiveLead__c'] = true;
    }
    if(!this.isNullOrEmpty(mobile)) {
        lead['Email'] = 'duplicate' + email;      
        let newmbNumber = parseInt(mobile + '0000');
        lead['MobilePhone'] = parseInt(mobile + '0000');
        lead['InactiveLead__c'] = true;
        await findDuplicateLead({ mobile: newmbNumber})
        .then(() => {
            console.log('Duplicate lead deleted if present.');
        })
        .catch(error => {
            this.handleAlert(JSON.stringify(error));
        });
    }
    await updateLeadRecord({ updateLead: lead})
        .then(() => {
            console.log('Update lead')
            if (!this.isNullOrEmpty(updateEmail)) {
                this.updateExistingAccount( accountId, updateEmail, null, leadSource, currentLeadSource, sameLc, checkCreatedDate );
            }
            if (!this.isNullOrEmpty(updateMobile)) {
                this.updateExistingAccount( accountId, null, updateMobile, leadSource, currentLeadSource, sameLc, checkCreatedDate );
            }
        })
        .catch(error => {
            this.handleAlert(JSON.stringify(error));
        });

}

async updateExistingAccount( accountId, updateEmail, updateMobile, leadSource, currentLeadSource, sameLc, checkCreatedDate ) {
    let source ='blank';
    let accountRec = {};
    accountRec['Id'] = accountId;

    if(leadSource === 'Web' && currentLeadSource === 'Partner' && sameLc === true && checkCreatedDate === true )
    {
        accountRec['PersonLeadSource'] = 'Web';    
        source = 'Web';         
    }
    if(source === 'blank')
    {
        if((leadSource === 'Web' && currentLeadSource === 'Partner') || (leadSource === 'Partner' && currentLeadSource === 'Web' ))
        {
            accountRec['PersonLeadSource'] = 'Web & Partner';
        }
    }
   /* if (!IsNullOrEmpty(accountrec.PersonLeadSource)) {
        System.debug('Lead source will be updated to ---->'+accountrec.PersonLeadSource);
    }*/
   console.log('accountrec.updateEmail =>'+updateEmail);
    if (!this.isNullOrEmpty(updateEmail)) {

        accountRec['PersonEmail'] = updateEmail;
    }
    if (!this.isNullOrEmpty(updateMobile)) {
        accountRec['PersonMobilePhone'] = updateMobile;
    }

    await updateAccountRecord({acc: accountRec})
    .then(() => {
        this.handleSuccess()
        window.location.reload();
    })
    .catch(error => {
        this.handleAlert(JSON.stringify(error));
    });
}


convertDate(dateString) {
    const parts = dateString.split('-');
    return new Date(parts[0], parts[1] - 1, parts[2]);
}

checkDate(currentLeaddate,initialCreatedDate) {
    let msg;
    if(currentLeaddate > initialCreatedDate) {
        msg = true;
    }
    else {
        msg = false;
    }
    return msg;
}

checkLc(currentLC,leadLc,currentCompany,leadCp,currentGroup,leadGrp) {
    let msg;
    if(currentLC === leadLc && !this.isNullOrEmpty(currentLC) && !this.isNullOrEmpty(leadLc) )
    {
        msg = true;
    }
    else if(currentCompany === leadCp && !this.isNullOrEmpty(currentCompany) && !this.isNullOrEmpty(leadCp))
    {
        msg = true;
    }
    else if(currentGroup === leadGrp && !this.isNullOrEmpty(leadGrp)&& !this.isNullOrEmpty(currentGroup))
    {
        msg = true;
    }
    else
    {
        msg = false;
    }
    return msg;
}

async handleConfirmClick(msg) {
    const confirm = await LightningConfirm.open({
        message: msg,
        variant: 'warning',
        label: 'Refund',
    });
    return confirm;
}

async getLeadAccountMobile(){
    await getRecordForNewMobile({mobile:this.newMobile})
    .then (result=> {
        console.log('account record mobile:');  
        console.log(result.accountRecordMobile[0]);
        this.account = result.accountRecordMobile[0];
        this.lead = result.leadRecordMobile[0];
    })
     .catch(error => {
        this.handleAlert(JSON.stringify(error));
        this.closeQuickAction();
    });
}
async getLeadAccountEmail() {
       await getRecordForNewEmail ({email:this.newEmail})
       .then (result=> {
        console.log('account record email:');
        console.log(result.accountRecordEmail[0]);
        this.account = result.accountRecordEmail[0];
        this.lead = result.leadRecordEmail[0];
       })
        .catch(error => {
            this.handleAlert(JSON.stringify(error));
            this.closeQuickAction();
        });
}
async handlePromptClick(label, msg, type) {
const input = await LightningPrompt.open({
    message: msg,
    label: label,
    defaultValue: '',
});
if(type === 'email') {
    this.newEmail = input;
}
if(type === 'mobile') {
    this.newMobile = input;
}
}

async handleAlert(msg) {
await LightningAlert.open({
    message: msg,
    theme: 'error', 
    label: 'Error!',
});
this.closeQuickAction();
}

async handleSuccess() {
    await LightningAlert.open({
        message: 'Record upadated Successfully',
        theme: 'success', 
        //variant: 'success',', 
        label: 'Success!',
    });
    this.closeQuickAction();
    }

closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
}


isNullOrEmpty(value) {
    return (value === null || value === '');
}
}