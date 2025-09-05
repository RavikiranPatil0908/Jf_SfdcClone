/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 06--08--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   24--06--2025   @Ravi   Initial Version
**/
import { LightningElement, api, wire, track } from 'lwc';
import refundRequest from '@salesforce/apex/LightningAccountButtonController.refundRequest';
import { CloseActionScreenEvent } from 'lightning/actions';
import refundData from '@salesforce/apex/LightningAccountButtonController.refundData';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import refundAmountData from '@salesforce/apex/LightningAccountButtonController.refundAmountData';
import insertRefundPayment from '@salesforce/apex/LightningAccountButtonController.insertRefundPayment';

export default class RefundRequestButton extends LightningElement {
    @track showPopup = true;
    @api recordId;
    @track refundType = '';
    Account;
    opportunity;
    isInstallment;
    paymentMode;
    msg;
    
    refundOptions = [
        { label: 'Admission Cancellation', value: 'Admission Cancellation' },
        { label: 'Registration Cancellation', value: 'Registration Cancellation' },
        { label: 'Excess Refund', value: 'Excess Refund' },
    ];
    handleChange(event) {
        this.refundType = event.detail.value;
    }

    handleCancel() {
        this.closeQuickAction();
    }

    handleSave() {
        if (this.refundType) {
            this.closeQuickAction();
            this.cancellation();
        }
    }

    @wire(refundRequest, { recordId: '$recordId' })
    checkRefund({ error, data }) {
        if (data) {
            console.log(data.account);
            console.log(data.opportunity);
            this.Account = data.account;
            this.opportunity = data.opportunity[0];
        }
        else if (error) {
            console.error(error);
            this.closeQuickAction();
        }
    }

    cancellation() {
         console.log('Ravi0')
        if (this.opportunity.StageName === 'Closed Won' && this.refundType === 'Admission Cancellation') {
            refundData({ accountId: this.Account.Id, refundType: this.refundType })
                .then(result => {
                    console.log(this.refundType);
                    console.log(this.opportunity.Id);
                    console.log('check confirmation:' + result.paymentRecords);
                    if (result.paymentRecords) {
                        this.handleConfirmClick();
                    } 
                    else {
                        this.cancelAddReg();
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.closeQuickAction();
                });
        } else if (this.opportunity.StageName !== 'Closed Won' && this.refundType === 'Registration Cancellation') {
            console.log('check');
            this.cancelAddReg();
        }
        else if (this.refundType === 'Excess Refund') {
            this.handleExcessRefundAlert();
        } else {
            this.msg='Can\'t perform this action at this stage.';
            this.handleStageAlert(this.msg);
        }
    }

    async cancelAddReg() {
        console.log('cancel add and reg');
        await refundAmountData({ oppId: this.opportunity.Id })
            .then(result => {
                let email = this.Account.PersonEmail;
                if(this.refundType === 'Registration Cancellation') {
                    this.isInstallment = result.installment;
                }
                else {
                    this.isInstallment = false;
                }
                let regfeeNeft = result.amount;
                console.log(regfeeNeft);
                console.log('nmPayment record:' + result.refund);
                console.log('account email:' + email);

                if (!result.refund) {
                    this.actionPerform(email, regfeeNeft);
                }
                else {
                    this.msg = 'Refund record is already created.';
                    this.handleStageAlert(this.msg);
                }
            })
            .catch(error => {
                console.error(error);
                this.closeQuickAction();
            });
    }

    actionPerform(email, regfeeNeft) {
        let interviewSlot = this.Account.Interview_Slot__c;
        let studykit = this.opportunity.Dispatch_Order_For_Student__c;
        let Dispatchstatus = this.opportunity.Final_Status_Of_Dispatch__c;
        let totalApprovedamount = this.opportunity.nm_TotalApprovedPayment__c;
        let Specialisation = this.opportunity.Specialisation__c;
        let interviewSlotSelected = false;
        let refundAmount = 0;
    
        // let studykitapp = this.StudyKitCheck(studykit,Dispatchstatus); 
        refundAmount = totalApprovedamount - regfeeNeft ;
        console.log(refundAmount);
        console.log(email);

        if (Specialisation === 'MBA (WX)' && interviewSlot) {
            interviewSlotSelected = true;
        }

        this.insertNewPaymentRecord(refundAmount, studykit, interviewSlotSelected, email);
    }

    StudyKitCheck(studykit, Dispatchstatus) {
        if (studykit) {
            return true;
        } else {
            return false;
        }
    }

    insertNewPaymentRecord(refundAmount, studykit, interviewSlotSelected, email) {
        let refundPaymentRec = {};
        refundPaymentRec['nm_Payment_Type__c'] = 'Refund Payment';
        refundPaymentRec['nm_Payment_Status__c'] = 'Refund Initiated';
        refundPaymentRec['Status__c'] = 'Refund Request Created';
        refundPaymentRec['Total_Refund_Amount__c'] = refundAmount;
        refundPaymentRec['Opportunity__c'] = this.opportunity.Id;
        refundPaymentRec['Instalment_done__c'] = this.isInstallment;
        refundPaymentRec['Study_Kit__c'] = studykit;
        refundPaymentRec['Type_of_Refund__c'] = this.refundType;
        refundPaymentRec['Account__c'] = this.Account.Id;
        refundPaymentRec['nm_Student_E_mail__c'] = email;
        if (interviewSlotSelected) {
            refundPaymentRec['InterciewSlot_Selected__c'] = true;
        }
        insertRefundPayment({ refundPayment: refundPaymentRec })

            .then(() => {
                LightningAlert.open({
                    message: 'Refund Payment Created',
                    theme: 'success',
                    label: 'Success',
                }).then(() => {
                    console.log('Record inserted successfully');
                    location.reload();
                });
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    async handleConfirmClick() {
        const confirm = await LightningConfirm.open({
            message: 'This student has opt for career service.Kindly Confirm if you want to proceed?',
            variant: 'warning',
            label: 'Refund',
        });
        if (!confirm) {
            this.closeQuickAction();
        } else {
            this.cancelAddReg();
            console.log('admission cancel');
        }
    }

    async handleExcessRefundAlert() {
        await LightningAlert.open({
            message: 'Please do the excess refund at opportunity level.',
            theme: 'warning', 
            label: 'Excess Refund', 
        });
    }

    async handleStageAlert(msg) {
        await LightningAlert.open({
            message: msg,
            theme: 'error', 
            label: 'Error!', 
        });
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}