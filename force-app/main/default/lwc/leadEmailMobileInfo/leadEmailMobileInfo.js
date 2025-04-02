import { LightningElement, api, wire, track } from 'lwc';
import getLeadEmailMobileInfo from '@salesforce/apex/LeadEmailMobileInfoController.getLeadEmailMobileInfo';
import updateLeadInfo from '@salesforce/apex/LeadEmailMobileInfoController.updateLeadInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadEmailMobileInfo extends LightningElement {
    @api recordId;
    @track records = [];
    @track dataLoading = true;
    @track hasData = false;
    @track isEditing = false;
    @track showSaveButton = false;
    originalEmail;
    originalMobile;
    originalSecondaryEmail;
    originalPhone;
    editedEmail;
    editedMobile;
    editedSecondaryEmail;
    editedPhone;

    @wire(getLeadEmailMobileInfo, { recordId: '$recordId' })
    wiredLeadEmailMobileInfo({ error, data }) {
        if (data) {
            if (data.length > 0) {
                this.records = data;
                this.originalEmail = data[0].email;
                this.originalMobile = data[0].mobile;
                this.originalSecondaryEmail = data[0].secondaryEmail;
                this.originalPhone = data[0].phone;
                this.editedEmail = data[0].email;
                this.editedMobile = data[0].mobile;
                this.editedSecondaryEmail = data[0].secondaryEmail;
                this.editedPhone = data[0].phone;
                this.hasData = true;
            } else {
                this.hasData = false;
            }
            this.dataLoading = false;
        } else if (error) {
            console.error(error);
            this.dataLoading = false;
        }
    }

    get isDisabled() {
        return !this.isEditing;
    }

    handleEdit() {
        this.isEditing = true;
        this.showSaveButton = true;
    }

    handleEmailChange(event) {
        this.editedEmail = event.target.value;
        this.showSaveButton = true;
    }

    handleMobileChange(event) {
        this.editedMobile = event.target.value;
        this.showSaveButton = true;
    }

    handleSecondaryEmailChange(event) {
        this.editedSecondaryEmail = event.target.value;
        this.showSaveButton = true;
    }

    handlePhoneChange(event) {
        this.editedPhone = event.target.value;
        this.showSaveButton = true;
    }

    handleSave() {
        // Frontend validation for Mobile and Phone fields
        if (this.editedMobile && !/^\d{10}$/.test(this.editedMobile)) {
            this.showAlert( 'Mobile number must be a 10-digit number.', 'error');
            return;
        }
        if (this.editedPhone && !/^\d+$/.test(this.editedPhone)) {
            this.showAlert( 'Phone must contain only numeric characters.', 'error');
            return;
        }

        updateLeadInfo({ leadId: this.recordId, email: this.editedEmail, mobile: this.editedMobile, secondaryEmail: this.editedSecondaryEmail, phone: this.editedPhone })
            .then(() => {
                this.originalEmail = this.editedEmail;
                this.originalMobile = this.editedMobile;
                this.originalSecondaryEmail = this.editedSecondaryEmail;
                this.originalPhone = this.editedPhone;
                this.isEditing = false;
                this.showSaveButton = false;
                this.showAlert('Success', 'Lead updated successfully', 'success');
            })
            .catch(error => {
                this.showAlert('Error updating lead', error.body.message, 'error');
            });
    }

    handleCancel() {
        this.editedEmail = this.originalEmail;
        this.editedMobile = this.originalMobile;
        this.editedSecondaryEmail = this.originalSecondaryEmail;
        this.editedPhone = this.originalPhone;
        this.isEditing = false;
        this.showSaveButton = false;
    }

    showAlert(title, message, variant) {
        if (this.template.querySelector('lightning-toast')) {
            // Lightning Experience: Show toast notification
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        } else {
            // Classic Experience: Show alert
            alert(`${title}: ${message}`);
        }
    }
}