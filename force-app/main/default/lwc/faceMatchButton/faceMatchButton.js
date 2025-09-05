/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 20--08--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-08-2025   @Ravi    Initial Version
 **/
import { LightningElement, track, api, wire } from 'lwc';
import getAccountAndDoc from '@salesforce/apex/LightningAccountButtonController.getAccountAndDoc';
import { CloseActionScreenEvent } from 'lightning/actions';
import URLMatchvs2 from '@salesforce/apex/LightningAccountButtonController.URLMatch';
import updateAccountRecord from '@salesforce/apex/LightningAccountButtonController.updateAccountRecord';
import processDigiLockerDoc from '@salesforce/apex/LightningAccountButtonController.processDigiLockerDoc';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';

export default class FaceMatchButton extends LightningElement {
    @api recordId;
    @track selectedOption;
    @track docType = [];
    @track documentRecords = [];
    @track webServiceResponse;

    accountRec;
    counter;
    

    handleChange(event) {
        this.selectedOption = event.detail.value;
    }

    handleCancel() {
        this.closeQuickAction();
    }

    handleSave() {
        if (this.selectedOption) {
            this.redirectMethod();
            this.closeQuickAction();
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    @wire(getAccountAndDoc, { recordId: '$recordId' })
    getDocUsingAccount({ data, error }) {
        if (data) {
            console.log(data.account);
            console.log(data.docList);

            this.accountRec = data.account;
            this.documentRecords = data.docList;
            console.log('Account record ----> ' + this.accountRec);
            if (
                data.account.Student_Image_Url2__c !== '' &&
                data.account.Student_Image_Url2__c !== undefined &&
                data.account.Student_Image_Url2__c !== 'null'
            ) {
                console.log(this.accountRec.Student_Image_Url2__c);
                const option = { value: 'Student Image 2', label: 'Student Image 2' };
                this.docType = [...this.docType, option];
            }

            if (data.docList.length > 0) {
                for (const list of data.docList) {
                    const option = { value: list.Name, label: list.Name };
                    this.docType = [...this.docType, option];
                }
            }

            console.log(this.docType);
        } else if (error) {
            console.error(error);
            this.closeQuickAction();
        }
    }

    // redirectMethod() {
    //     this.counter = this.accountRec.Findability_Counter__c;

    //     if (this.selectedOption) {
    //         URLMatchvs2({ AccountId: this.accountRec.Id, DocName: this.selectedOption })
    //             .then(result => {
    //                 this.webserviceResponse = result;
    //                 console.log('API Response ----> ' + result);

    //                 if (this.webserviceResponse) {
    //                     console.log(this.counter);
    //                     this.counter++;
    //                     this.updateAccount();
    //                 } else {
    //                     LightningAlert.open({
    //                         message: 'Failed to update',
    //                         theme: 'error',
    //                         label: 'Error!',
    //                         variant: 'header',
    //                     });
    //                 }
    //             })
    //             .catch(error => {
    //                 console.error(error);
    //             });
    //     }
    // }
    async redirectMethod() {
        this.counter = this.accountRec.Findability_Counter__c || 0;
        if (this.selectedOption) {
            try {
                // Process DigiLocker documents first if needed
                if (this.selectedOption === 'Photo ID proof' || this.selectedOption === 'Aadhaar Card') {
                    await this.processDigiLockerDocument();
                }
                // Call the face matching service
                this.webServiceResponse = await URLMatchvs2({ 
                    AccountId: this.accountRec.Id, 
                    DocName: this.selectedOption 
                });
                console.log('API Response ----> ' + this.webServiceResponse);

                if (this.webServiceResponse) {
                    console.log(this.counter);
                    this.counter++;
                    await this.updateAccount();
                } else {
                    await LightningAlert.open({
                        message: 'Failed to update',
                        theme: 'error',
                        label: 'Error!',
                        variant: 'header',
                    });
                }
            } catch (error) {
                console.error(error);
                await LightningAlert.open({
                    message: 'Error: ' + error.body?.message || error.message,
                    theme: 'error',
                    label: 'Error!',
                    variant: 'header',
                });
            }
        }
    }
    async processDigiLockerDocument() {
        try {
            // Find the document record
            const docRecord = this.documentRecords.find(doc => doc.Name === this.selectedOption);
            if (docRecord && docRecord.Document_Upload_Mode__c === 'Upload via DigiLocker' && !docRecord.Updated_document_link__c) {
                // Process DigiLocker document
                const imageUrl = await processDigiLockerDoc({
                    accountId: this.accountRec.Id,
                    docName: this.selectedOption
                });
                console.log('Processed DigiLocker document, image URL: ', imageUrl);
            }
        } catch (error) {
            console.error('Error processing DigiLocker document: ', error);
            // Continue with the face matching even if DigiLocker processing fails
        }
    }


    async updateAccount() {
        let accountRec2 = {
            Id: this.accountRec.Id,
            Findability_Counter__c: this.counter,
            Findability_Date__c: new Date(),
        };

        console.log(accountRec2);

        updateAccountRecord({ acc: accountRec2 })
            .then(() => {
                console.log('Account record updated after API call');
            })
            .catch(error => {
                console.error(error);
                this.closeQuickAction();
            });
        if (this.webServiceResponse) {
            LightningAlert.open({
                message: 'Updated - ' + this.webServiceResponse,
                theme: 'success',
                label: 'Success',
            }).then(() => {
                if (this.selectedOption === 'Student Image 2') {
                    this.handleConfirm();
                } else {
                    window.location.reload();
                } 
            });
        }
    }

    async handleConfirm() {
        const confirm = await LightningConfirm.open({
            message: 'Do you want to replace with Original image?',
            variant: 'warning',
            label: 'Warning',
        });

        if (confirm) {
            let accountRec3 = {
                Id: this.accountRec.Id,
                nm_StudentImageUrl__c: this.accountRec.Student_Image_Url2__c,
            };

            console.log(accountRec3);

            updateAccountRecord({ acc: accountRec3 })
                .then(() => {
                    console.log('Account record updated for Image');
                    LightningAlert.open({
                        message: 'Student Image Updated',
                        theme: 'success',
                        label: 'Success',
                    }).then(() => {
                        window.location.reload();
                    });
                })
                .catch(error => {
                    console.error(error);
                    this.closeQuickAction();
                });
        } else {
            this.closeQuickAction();
            window.location.reload();
        }
    }
}