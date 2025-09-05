/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 05--09--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   20--08--2025   @Ravi   Initial Version
**/
import { LightningElement, track, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getAccount from '@salesforce/apex/LightningAccountButtonController.getAccount';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import refundData from '@salesforce/apex/LightningAccountButtonController.refundData';
import getOpportunityClosed from '@salesforce/apex/LightningAccountButtonController.getOpportunityClosed';
import updateAccountRecord from '@salesforce/apex/LightningAccountButtonController.updateAccountRecord';
import deletePaymentUsingRegno from '@salesforce/apex/LightningAccountButtonController.deletePaymentUsingRegno';
import updateDocumentForUndo from '@salesforce/apex/LightningAccountButtonController.updateDocumentForUndo';
import deleteLeadForUndo from '@salesforce/apex/LightningAccountButtonController.deleteLeadForUndo';
import { NavigationMixin } from 'lightning/navigation';
import updateStudentProgram from '@salesforce/apex/LightningAccountButtonController.updateStudentProgram';
import updateOpportunityList from '@salesforce/apex/LightningAccountButtonController.updateOpportunityList';
import getProgramList from '@salesforce/apex/LightningAccountButtonController.getProgramList';
import updateOpportunityForUndo from '@salesforce/apex/LightningAccountButtonController.updateOpportunityForUndo';
import updatePaymentRecord from '@salesforce/apex/LightningAccountButtonController.updatePaymentRecord';

export default class CancelRelatedButton extends NavigationMixin(LightningElement) {
    @api recordId;
    @track cancelType;
    @track cancelOptions = [
        { label: 'Cancel Admission', value: 'cancelAdmission' },
        { label: 'Cancel Registration', value: 'cancelRegistration' },
        { label: 'De-Register', value: 'deRegister' },
        { label: 'Rusticated', value: 'Rusticated' },
        { label: 'Undo Cancel', value: 'undo' }
    ];
    // @track isProgramDisabled = true;
    @track deRegister = false;
    @track certificateValue = '';
    @track certificateOptions = [
        { label: 'Yes' , value: 'Yes'},
        { label: 'No' , value: 'No'}
    ]
    @track programOptions = [];
    @track programValue = '';
    currentAcc;
    status;
    email;
    mobile;    
    programList;

    handleUpdateRecord() {
        console.log(this.programValue);
        if(this.certificateValue === 'Yes' && this.programValue) {
            this.closeQuickAction();
            this.forDeRegister();
        }
        if(this.certificateValue === 'No') {
            this.closeQuickAction();
            this.forDeRegister();
        }
    }

    handleCertificateChange(event) {
        this.certificateValue = event.detail.value;
        // if(this.certificateValue === 'Yes' && this.programList.length > 0) {
        //     this.isProgramDisabled = false;
        // }
        // if(this.certificateValue === 'No') {
        //     this.isProgramDisabled = true;
        //     // this.programValue = '';
        // }
    }

    handleProgramChange(event) {
        this.programValue = event.detail.value;
    }

    handleChange(event) {
        this.cancelType = event.detail.value;
    }

    handleCancel() {
        this.closeQuickAction();
    }

    handleSave() {
        if (this.cancelType === 'deRegister') {
            this.deRegister = true;
        }
        else if (this.cancelType) {
            console.log('type===>',this.cancelType);
            this.closeQuickAction();
            this.cancelProgram();
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    @wire(getAccount, { recordId: '$recordId' })
    getAccountRecord({ error, data }) {
        if (data) {
            console.log('Account --> ' + JSON.stringify(data.accountData));
            this.currentAcc = data.accountData;
            this.programList = data.listProgram; 
            console.log(`Student status : ${this.currentAcc.nm_StudentStatus__c} Opp stage:${this.currentAcc.nmCaptureOpportuntiyStage__c}`);
            console.log(data.listProgram);
            if(this.programList.length > 0) {
                
                for (const list of this.programList) {
                    const option = {
                        value: list.Id,
                        label: list.nm_ProgramName__c
                    };
                    this.programOptions = [ ...this.programOptions, option ];
                }
                console.log('Program List --> ' + JSON.stringify(this.programOptions));   
            }  
        }
        else if (error) {
            console.error(error);
            this.closeQuickAction();
        }
    }

    cancelProgram() {
        if(this.cancelType === 'cancelAdmission') {
            this.forCancelAdmission();
        }
        else if(this.cancelType === 'cancelRegistration') {
            this.forCancelRegistration();
        }
        else if(this.cancelType === 'Rusticated') {
            this.forRusticated();
        }
        else if(this.cancelType === 'undo') {
            this.forUndo();
        }
    }

    async forCancelAdmission() {
        await refundData({accountId : this.currentAcc.Id, refundType : 'Admission Cancellation'}) 
        .then(result => {
           console.log('Payment record for career service --> ' + result.paymentRecords);
           if(result.paymentRecords) {
            this.handleConfirmClick();
           }
           else {
            this.admissionCancelUsingStage();
           }
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
        });
    }

    async admissionCancelUsingStage() {
        await getOpportunityClosed({accId : this.currentAcc.Id}) 
        .then(result => {
            console.log(`termOpp: ${result.termOpp}  nonTermOpp: ${result.nonTermOpp} noOpportunity: ${result.noOpportunity}`);
            if (!result.noOpportunity && ((result.termOpp <= 4 && result.nonTermOpp === 0) || (result.termOpp === 0 && result.nonTermOpp <= 2))) {
                if(this.currentAcc.nm_StudentStatus__c === 'Confirmed') {
                    this.handelConfirmAdmission();
                }
                else {
                    this.handleAlert('You can not cancel Admission.', 'error', 'Error!');
                }
            }
            else {
                this.handleAlert('You can not cancel Admission at this Stage.', 'error', 'Error!');
            }
         })
         .catch(error => {
             console.error(error);
             this.closeQuickAction();
         });
    }

    async handelConfirmAdmission() {
        const confirm = await LightningConfirm.open({
            message: 'Are you sure want to Cancel the Admission...',
            variant: 'warning',
            label: '',
        });
        if(confirm) {
            if( this.currentAcc.nmCaptureOpportuntiyStage__c === 'Payment made' ||
            this.currentAcc.nmCaptureOpportuntiyStage__c === 'Pending Payment' ||
            this.currentAcc.nmCaptureOpportuntiyStage__c === 'Closed' ||
            this.currentAcc.nmCaptureOpportuntiyStage__c === 'Registration Done' ||
            this.currentAcc.nmCaptureOpportuntiyStage__c.includes('Pending Payment')) {
                await this.handleAlert('You can not cancel Admission at this Stage.', 'error', 'Error!');
            }
            else {
                let accountRec = {};
                accountRec['Id'] = this.currentAcc.Id;
                accountRec['nm_StudentStatus__c'] = 'Admission Cancelled';
                console.log('Update Account --> ' + JSON.stringify(accountRec));
                await updateAccountRecord({acc : accountRec})
                .then(() => {
                    console.log('Account Updated for Admission Cancellation');
                    this.handleAlert('Admission Cancelled!', 'success', 'Success');
                })
                .catch(error => {
                    console.error(error);
                    this.handleAlert('Something went wrong . Please follow the exception.' + error, 'error', 'Error!');
                    this.closeQuickAction();
                });
            }  
        }
        else {
            this.closeQuickAction();
        }
    }

    async handleConfirmClick() {
        const confirm = await LightningConfirm.open({
            message: 'This student has opt for career service.Kindly Confirm if you want to proceed?',
            variant: 'warning',
            label: '',
        });
        if(confirm) {
           this.admissionCancelUsingStage();
        }
        else {
            this.closeQuickAction();
        }
    }

    async forCancelRegistration() {
        console.log('this.currentAcc.nm_StudentStatus__c',this.currentAcc.nm_StudentStatus__c);
        console.log('this.currentAcc.nm_StudentStatus__c==',this.currentAcc.nm_StudentStatus__c == 'Registered');
        
        if(this.currentAcc.nm_StudentStatus__c === 'Confirmed' ||
        this.currentAcc.nm_StudentStatus__c === 'Admission form & documents submitted' ||
        this.currentAcc.nm_StudentStatus__c === 'Admission Form & Documents Provisional' ||
        this.currentAcc.nm_StudentStatus__c === 'Admission form & documents Approved' ||
        this.currentAcc.nm_StudentStatus__c === 'Registered' ||
        this.currentAcc.nm_StudentStatus__c === 'Documents Disapproved') {
            console.log('forCancelRegistratio===');
            const answer = await this.handleConfirm('Are you sure want to Cancel the Registration ?');
            if(answer) {
                if(this.currentAcc.nmCaptureOpportuntiyStage__c === 'Closed Won') {
                    await this.handleAlert('You can not cancel Registration at this Stage.', 'error', 'Error!');
                }
                else if(this.currentAcc.Is_Late_fees_pending__c) {
                    await this.handleAlert('Please Pay Late Fees', 'error', 'Error!');
                }
                else if(this.currentAcc.Is_Late_fees_paid__c) {
                    await this.handleAlert('Please Approve Late Fees', 'error', 'Error!');
                }
                else {
                    if (this.currentAcc.nmCaptureOpportuntiyStage__c === 'Closed' ||  this.currentAcc.nmCaptureOpportuntiyStage__c.includes('Pending Payment') || this.currentAcc.nmCaptureOpportuntiyStage__c === 'Registration Done') {
                        let accountRec = {};
                        accountRec['Id'] = this.currentAcc.Id;
                        accountRec['nm_StudentStatus__c'] = 'Registration Cancelled';
                        console.log('Update Account --> ' + JSON.stringify(accountRec));
                        updateAccountRecord({acc : accountRec})
                        .then(() => {
                            console.log('Registration Cancelled');
                            this.handleAlert('Registration Cancelled!', 'success', 'Success');
                        })
                        .catch(error => {
                            console.error(error);
                            this.closeQuickAction();
                        });
                    }
                }
            }
            else {
                this.closeQuickAction();
            }
        }
        else {
            await this.handleAlert('You can not cancel Registration at this Stage.', 'error', 'Error!');
        }
    }

    async forRusticated() {
        if(this.currentAcc.nm_StudentStatus__c === 'Confirmed') {
            const answer = await this.handleConfirm('Are you sure want to mark Rusticated...');
            if(answer) {
                let accountRec = {};
                accountRec['Id'] = this.currentAcc.Id;
                accountRec['nm_StudentStatus__c'] = 'Rusticated';
                console.log('Update Account --> ' + JSON.stringify(accountRec));
                updateAccountRecord({acc : accountRec})
                .then(() => {
                    console.log('Student status rusticated');
                    this.handleAlert('Student Status is Rusticated!', 'success', 'Success');
                })
                .catch(error => {
                    console.error(error);
                    this.closeQuickAction();
                });
            }
            else {
                this.closeQuickAction();
            }
        }
        else {
            await this.handleAlert('You can not mark Rusticated at this Stage.', 'error', 'Error!');
        }
    }

    forDeRegister() {
        console.log('deregister');
        if(this.certificateValue !== '' && this.currentAcc.nm_StudentStatus__c === 'Confirmed') {
            this.UpdateRecordsvs2();
        }
        else if(this.currentAcc.nm_StudentStatus__c !== 'Confirmed') {
            this.handleAlert('De-Registered is not possible at this stage', 'error', 'Error!');
        }
        else {
            this.handleAlert('Error: Certificate Picklist value is Null or Empty', 'error', 'Error!');
        }
    }

    async UpdateRecordsvs2() {
        if(this.certificateValue === 'Yes' && this.programValue !== '') {
            await updateStudentProgram({accId : this.currentAcc.Id, program : this.programValue})
            .then(() => {
                LightningAlert.open({
                    message: 'Updated student program Sucessfully',
                    theme: 'success',
                    label: 'Success',
                }).then(() => {
                    console.log('Updated Student Program');
                    this.UpdateAcc();
                });
            })
            .catch(error => {
                console.error(error);
                this.closeQuickAction();
                this.handleAlert('failed to update studentprogram ' + error.message, 'error', 'Error!');
            });

        }
        else if(this.certificateValue === 'No') {
            LightningAlert.open({
                message: 'just de-register without issuing certificate',
                theme: 'success',
                label: 'Success',
            }).then(() => {
                this.UpdateAcc(this.currentAcc.Id, null);
            });
        }
    }

    async UpdateAcc(accId, stProgram) {
        const answer = await this.handleConfirm('De-Register the Student ?');
        if(answer) {
            let accountRec = {};
            accountRec['Id'] = accId;
            accountRec['nm_StudentStatus__c'] = 'De-Registered';
            accountRec['nm_StudentNo__c'] = 'De-Registered_'+ this.currentAcc.nm_StudentNo__c;
            accountRec['PersonEmail'] = 'De-Registered_'+ this.currentAcc.PersonEmail;
            accountRec['PersonMobilePhone'] = 'De-Registered_'+ this.currentAcc.PersonMobilePhone;
            if(stProgram) {
                await getProgramList({program : stProgram})
                .then(result => {
                    console.log('Program --> ' + JSON.stringify(result[0]));
                    if(result.length >0) {
                        if(result[0].nm_ProgramName__c === 'Certificate in Business Management' || result[0].nm_ProgramName__c === 'Diploma in Business Management') {
                            accountRec.Pass_Out__c = true;
                        }
                    }     
                })
                .catch(error => {
                    console.error(error);
                    this.closeQuickAction();
                });
            }
            if(stProgram) {
                accountRec.nm_Program__c = stProgram;
            }
            console.log('Update Account --> ' + JSON.stringify(accountRec));

            await updateAccountRecord({acc : accountRec})
            .then(() => {
                LightningAlert.open({
                    message: 'Updated Account Sucessfully',
                    theme: 'success',
                    label: 'Success',
                }).then(() => {
                    console.log('account update');
                    updateOpportunityList({accId : this.currentAcc.Id})
            .then(() => {
                LightningAlert.open({
                    message: 'Updated opportunity Sucessfully',
                    theme: 'success',
                    label: 'Success',
                }).then(() => {
                    console.log('opportunity updated');
                    window.location.reload();
                });
            })
            .catch(error => {
                console.error(error);
                this.closeQuickAction();
                this.handleAlert('failed to update opportunity ' + error.message, 'error', 'Error!');
            });
                });
            })
            .catch(error => {
                console.error(error);
                this.closeQuickAction();
                this.handleAlert('Failed to update Account ' + error.message, 'error', 'Error!');
            });

        }
    }

    async forUndo() {
        let msg = '';
        if(this.currentAcc.nm_StudentStatus__c === 'Registration Cancelled' ||
        this.currentAcc.nm_StudentStatus__c === 'De-Registered' ||
        this.currentAcc.nm_StudentStatus__c === 'Registration Cancelled' ||
        this.currentAcc.nm_StudentStatus__c === 'Admission Cancelled' ||
        this.currentAcc.nm_StudentStatus__c === 'Rusticated') {
            const answer = await this.handleConfirm('Are you sure want to Undo the '+ this.currentAcc.nm_StudentStatus__c + ' ....');
            if(answer) {
                this.email = this.currentAcc.PersonEmail.split('_')[1];
                this.mobile = this.currentAcc.PersonMobilePhone.split('_')[1];
                console.log('email:'+ this.email);
                console.log('mobile:'+this.mobile);
                // Step 1
                msg = await this.deleteRefundPayment();
                console.log('msg:'+msg);
                if(msg === 'error') {
                    console.log('msg:'+msg);
                    return;
                }

                //Step 2
                msg = await this.deleteLead();
                console.log('check');
                if (msg === 'error') {
                    return;
                }
    
                // Step 3 & 4
                msg = await this.updateAccount();
                if (msg === 'error') {
                    return;
                }
    
                // Step 5 & 6
                msg = await this.updateOpportunity();
                if (msg === 'error') {
                    return;
                }
            }
            else {
                this.closeQuickAction();
            }
        }
        else {
            await this.handleAlert('You can not undo at this Stage.', 'error', 'Error!');
        }
    }
    //Step 1
    async deleteRefundPayment() {
        await deletePaymentUsingRegno({accId : this.currentAcc.Id, regno : this.currentAcc.nm_RegistrationNumber__c})
        .then(result => {
            this.status = result.paymentStatus;
            if(this.status === 'error') {
                this.handleAlert('You can not undo at this Stage as Refund has been made aginst the Account.', 'error', 'Error!');
            }
            console.log(result.paymentStatus);
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
            this.handleAlert('Unable to delete the Refund Payment Record', 'error', 'Error!');
            this.status = 'error';
        });
        return this.status;
    }

    //Step 2
     async deleteLead() {
        await deleteLeadForUndo({email : this.email, mobile : this.mobile})
        .then(result => {
            this.status = result.leadStatus;
            if(this.status === 'error') {
                this.handleAlert('You can not undo at this Stage as payment has been made aginst the lead reord.', 'error', 'Error!');
                this.status = 'error';
            }
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
            this.handleAlert('Unable to delete the Lead Record', 'error', 'Error!');
            this.status = 'error';
        });
        return this.status;
     }
/* Step 3
update Account to undo Cancelation
*/
     async updateAccount() {
        let regNo = this.currentAcc.nm_RegistrationNumber__c.split('_')[1];
        console.log(regNo);
        let accStatus = ['Rusticated', 'Admission Cancelled', 'De-Registered'];
        let accountRec = {};
        accountRec['Id'] = this.currentAcc.Id;
        accountRec['nm_StudentStatus__c'] = accStatus.includes(this.currentAcc.nm_StudentStatus__c) ? 'Confirmed' : 'Registered';
        accountRec['PersonEmail'] = this.email;
        accountRec['PersonMobilePhone'] = this.mobile;
        accountRec['nm_RegistrationNumber__c'] = regNo;
        accountRec['Inactive_account__c'] = false;
        if (accountRec.nm_StudentStatus__c === 'Confirmed') {
            let stuNo = this.currentAcc.nm_StudentNo__c.split('_')[1];
            accountRec['nm_StudentNo__c'] = stuNo;
            accountRec['Is_Mobile_Verified__c'] = true;
            accountRec['nm_IsEmailVerified__c'] = true;
        }
        console.log(accountRec);
        await updateAccountRecord({acc : accountRec})
        .then(() => {
            console.log('Account Record Updated');
           this.status = 'success';
           this.triggerAccountStatusUpdate();
           this.navigateToAccountPage();
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
            this.handleAlert('Unable to update the Account Record', 'error', 'Error!');
            this.status = 'error';
        });
        return this.status;
     }
 /* Step 4
update document to get the current status.
*/
     async triggerAccountStatusUpdate() {
        await updateDocumentForUndo({accId : this.currentAcc.Id})
        .then(() => {
            console.log('Document Record Updated.');
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
            console.log('Document Record Update Failed.');
        });
     }

     // Have List of Opportunity but using last opportunity to update nm_Payment__c 
     /* Step 5
update Opportunity to undo Cancelation.
*/
     async updateOpportunity() {
        console.log('Opportunity function call for update');
        await updateOpportunityForUndo({accId : this.currentAcc.Id})
        .then(result => {
            console.log(result.oppSize + ' ' + result.opportunityId);
            if(result.oppSize) {
                console.log('Opportunity Updated');
                this.status = 'success';
                if(this.currentAcc.nm_StudentStatus__c != 'Confirmed') {
                    console.log(result.opportunityId);
                    this.triggerOppStageUpdate(result.opportunityId);
                }
            }
            else {
                console.log('No Opportunity record found to update.');
                this.status = 'error';
            } 
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
            this.handleAlert('Unable to update the Opportunity Record', 'error', 'Error !');
            this.status = 'error';
        });
        return this.status;
     }

     async triggerOppStageUpdate(oppId) {
        await updatePaymentRecord({opportunityId : oppId})
        .then(() => {
            console.log('Payment Record Updated.');
        })
        .catch(error => {
            console.error(error);
            this.closeQuickAction();
            console.log('Payment Record Update Failed.');
        });

     }

    async handleConfirm(msg) {
        const confirm = await LightningConfirm.open({
            message: msg,
            variant: 'warning',
            label: 'Warning',
        });
        return confirm;
    }

    async handleAlert(msg, type, lab) {
        await LightningAlert.open({
            message: msg,
            theme: type, 
            label: lab,
        });
    //    window.location.reload();
    }

    navigateToAccountPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.currentAcc.Id,
                // objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

}