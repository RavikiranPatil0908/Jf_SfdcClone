import { LightningElement, api } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import CaseConvert from '@salesforce/apex/ConvertCaseController.CaseConvert';

export default class ConvertToEnquiryComplain extends LightningElement {

	@api recordId;
	isLoading = false;

	connectedCallback() {
		this.handleConfirmClick();
	}

	async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: 'Are you sure want to Convert case type from Feedback to Enquiry!',
            variant: 'header',
            label: 'Kindly Confirm?',
        });
		if(result) {
			this.isLoading = true;
			CaseConvert({ Caseid: this.recordId, purpose: 'Enquiry'}).then(() => {
				this.isLoading = false;
				LightningAlert.open({
					message: 'Feedback converted successfully',
					theme: 'success', // a red theme intended for error states
					label: 'Success!', // this is the header text
				}).then(() => {
                    this.navigateToRecordViewPage();
                });
			}).catch(error => {
				console.log(error);
				this.isLoading = false;
				LightningAlert.open({
					message: 'Feedback conversion failed.',
					theme: 'error', // a red theme intended for error states
					label: 'Error!', // this is the header text
				}).then(() => {
                    this.closeQuickAction();
                });
			})
		} else {
			this.closeQuickAction();
		}
    }

	closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

	navigateToRecordViewPage() {
		console.log('Redirect to record Page');
		updateRecord({ fields: { Id: this.recordId }});
		this.closeQuickAction();
	}
}