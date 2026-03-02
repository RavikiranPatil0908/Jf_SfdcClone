/* eslint-disable dot-notation */
import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshView } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningPrompt from 'lightning/prompt';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import recordForNewEmail from '@salesforce/apex/LightningAccountButtonController.recordForNewEmail';
import recordForNewMobile from '@salesforce/apex/LightningAccountButtonController.recordForNewMobile';
import getAccount from '@salesforce/apex/LightningAccountButtonController.getAccount';
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
    currentAcc;
    currentLeadCreatedDate;
    //currentLeadcreateddate =  new Date({YEAR(account.Lead_created_date__c)}, {MONTH(account.Lead_created_date__c)} - 1, {DAY(account.Lead_created_date__c)});
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

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    @wire(getAccount, { recordId: '$recordId' })
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
        if(this.updateType === 'Update Email') {
            await this.handlePromptClick('New Email','Please enter new emaill address here','email');
            if(!this.isNullOrEmpty(this.newEmail) && /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/.test(this.newEmail)) {
                await this.getLeadAccountEmail();
                if(this.lead) {
                    console.log('lead email confirm waiting');
                    const confirm = await this.handleConfirmClick('Lead Info \r\n\t: Registration number -->' + this.lead.nm_RegistrationNo__c + '\r\n\tCurrent status-->' + this.lead.Status + '\r\n\tICname-->' + this.lead.IC_Name__c + '\r\n\t. Are you sure to update email ?');
                    if(confirm) {
                        console.log('lead after confirm for email');
                        let initialCreatedDate = this.convertDate(this.lead.Lead_created_date__c);
                        let checkCreatedDate = this.checkDate(this.currentLeadCreatedDate,initialCreatedDate);
                        let sameLc = this.checkLc(this.currentAcc.LC_Name__c, this.lead.LC_name__c, this.currentAcc.IC_company__c, this.lead.IC_company__c, this.currentAcc.GroupName__c, this.lead.GroupName__c);
                        this.updateLead(this.lead.nm_LeadId__c, this.lead.Email, this.currentAcc.Id, this.newEmail, null, null, this.lead.LeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate);
                    }
                    else {
                        this.closeQuickAction();
                        this.handleAlert('No action perform');
                    }
                }
                else if(this.account) {
                    const confirm = await this.handleConfirmClick('Account Info \r\n\t: Registration number -->' + this.account.nm_RegistrationNumber__c + '\r\n\tCurrent status-->' + this.account.nm_StudentStatus__c + '\r\n\tICname-->' + this.account.IC_Name_1__c + '\r\n\tStage-->' + this.account.nmCaptureOpportuntiyStage__c + '\r\n\tActual amount received' + this.account.Total_amount_received__c + '\r\n\t. Are you sure to update email ?');
                    if(confirm) {
                        let initialCreatedDate = this.convertDate(this.account.Lead_created_date__c);                 
                        let checkCreatedDate = this.checkDate(this.currentLeadCreatedDate,initialCreatedDate);
                        let sameLc = this.checkLc(this.currentAcc.LC_Name__c, this.account.LC_name__c, this.currentAcc.IC_company__c, this.account.IC_company__c, this.currentAcc.GroupName__c, this.account.GroupName__c);
                        this.updateAccount(this.currentAcc.Id, this.newEmail, null, this.account.PersonLeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate);
                    }
                    else {
                        this.closeQuickAction();
                        this.handleAlert('No action perform');
                    }
                }
                else {
                    console.log('direct update');
                    this.updateAccount(this.currentAcc.Id, this.newEmail, null, null, null, null, null);
                }
            }
            else {
                this.handleAlert('Please enter valid email id');
            }
        }
        else if(this.updateType === 'Update Mobile') {
            await this.handlePromptClick('New Mobile Number', 'Please enter new mobile number here', 'mobile');
            if(!this.isNullOrEmpty(this.newMobile && Number.isInteger) && this.newMobile.match(/^\d{10}$/)) {
                await this.getLeadAccountMobile();
                if(this.lead) {
                    const confirm = await this.handleConfirmClick('Lead Info \r\n\t: Registration number -->' + this.lead.nm_RegistrationNo__c + '\r\n\tCurrent status-->' + this.lead.Status + '\r\n\tICname-->' + this.lead.IC_Name__c + '\r\n\t. Are you sure to update mobile number?');
                    if(confirm) {
                        let initialCreatedDate = this.convertDate(this.lead.Lead_created_date__c);
                        let checkCreatedDate = this.checkDate(this.currentLeadCreatedDate,initialCreatedDate);
                        let sameLc = this.checkLc(this.currentAcc.LC_Name__c, this.lead.LC_name__c, this.currentAcc.IC_company__c, this.lead.IC_company__c, this.currentAcc.GroupName__c, this.lead.GroupName__c);
                        this.updateLead(this.lead.nm_LeadId__c, this.lead.Email, this.currentAcc.Id, null, this.lead.MobilePhone, this.newMobile, this.lead.LeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate);
                    }
                    else {
                        this.closeQuickAction();
                        this.handleAlert('No action perform');
                    }
                }
                else if(this.account) {
                    const confirm = await this.handleConfirmClick('Account Info \r\n\t: Registration number -->' + this.account.nm_RegistrationNumber__c + '\r\n\tCurrent status-->' + this.account.nm_StudentStatus__c + '\r\n\tICname-->' + this.account.IC_Name_1__c + '\r\n\tStage-->' + this.account.nmCaptureOpportuntiyStage__c + '\r\n\tActual amount received' + this.account.Total_amount_received__c + '\r\n\t. Are you sure want to update mobile number?');
                    if(confirm) {
                        let initialCreatedDate = this.convertDate(this.account.Lead_created_date__c);                   
                        let checkCreatedDate = this.checkDate(this.currentLeadCreatedDate,initialCreatedDate);
                        let sameLc = this.checkLc(this.currentAcc.LC_Name__c, this.account.LC_name__c, this.currentAcc.IC_company__c, this.account.IC_company__c, this.currentAcc.GroupName__c, this.account.GroupName__c);
                        this.updateAccount(this.currentAcc.Id, null, this.newMobile, this.account.PersonLeadSource, this.currentAcc.PersonLeadSource, sameLc, checkCreatedDate);
                    }
                    else {
                        this.closeQuickAction();
                        this.handleAlert('No action perform');
                    }

                }
                else {
                    this.updateAccount(this.currentAcc.Id, null, this.newMobile, null, null, null, null);
                }
            }
            else {
                this.handleAlert('Please enter valid mobile number');
            }
        }
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

    async updateLead( leadId, email, accountId, updateEmail, mobile, updateMobile, leadSource, currentLeadSource, sameLc, checkCreatedDate ) {
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
                console.error(error);
                this.closeQuickAction();
            });
        }

        await updateLeadRecord({ updateLead: lead})
        .then(() => {
            console.log('Update lead')
            if (!this.isNullOrEmpty(updateEmail)) {
                this.updateAccount( accountId, updateEmail, null, leadSource, currentLeadSource, sameLc, checkCreatedDate );
            }
            if (!this.isNullOrEmpty(updateMobile)) {
                this.updateAccount( accountId, null, updateMobile, leadSource, currentLeadSource, sameLc, checkCreatedDate );
            }
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
        });
    }

    async updateAccount( accountId, updateEmail, updateMobile, leadSource, currentLeadSource, sameLc, checkCreatedDate ) {
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
        if (!this.isNullOrEmpty(updateEmail)) {
            accountRec['PersonEmail'] = updateEmail;
        }
        if (!this.isNullOrEmpty(updateMobile)) {
            accountRec['PersonMobilePhone'] = updateMobile;
        }

        await updateAccountRecord({acc: accountRec})
        .then(() => {
            window.location.reload();
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
        });
    }

    async getLeadAccountEmail() {
        await recordForNewEmail({ email: this.newEmail })
        .then(result => {
            console.log('account record email:');
            console.log(result.accountRecordEmail[0]);
            console.log('lead record email:');
            console.log(result.leadRecordEmail[0]);
            this.account = result.accountRecordEmail[0];
            this.lead = result.leadRecordEmail[0];
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
        });
    }

    async getLeadAccountMobile() {
        await recordForNewMobile({ mobile: this.newMobile })
        .then(result => {
            console.log('account record number:');
            console.log(result.accountRecordMobile[0]);
            console.log('lead record number:');
            console.log(result.leadRecordMobile[0]);
            this.account = result.accountRecordMobile[0];
            this.lead = result.leadRecordMobile[0];
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
        });
    }


    async handlePromptClick(label, msg, type) {
        const input = await LightningPrompt.open({
            label: label,
            message: msg,
            defaultValue: '',
        });
        if(type === 'email') {
            this.newEmail = input;
        }
        if(type === 'mobile') {
            this.newMobile = input;
        }
        console.log(input);
    }

    async handleAlert(msg) {
        await LightningAlert.open({
            message: msg,
            theme: 'error', 
            label: 'Error!',
        });
        this.closeQuickAction();
    }

    async handleConfirmClick(msg) {
        const confirm = await LightningConfirm.open({
            message: msg,
            variant: 'warning',
            label: 'Refund',
        });
        return confirm;
    }

    isNullOrEmpty(value) {
        return (value === null || value === '');
    }

}