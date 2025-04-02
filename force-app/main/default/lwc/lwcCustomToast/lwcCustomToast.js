/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MiscNotification extends LightningElement {
    @api title = 'Sample Title';
    @api message = 'Sample Message';
    @api variant = 'error';
    @api autoCloseTime = 3000;
    @api autoClose = false;
    @api autoCloseErrorWarning = false;

    variantOptions = [
        { label: 'error', value: 'error' },
        { label: 'warning', value: 'warning' },
        { label: 'success', value: 'success' },
        { label: 'info', value: 'info' },
    ];

    titleChange(event) {
        this.title = event.target.value;
    }

    messageChange(event) {
        this.message = event.target.value;
    }

    variantChange(event) {
        this.variant = event.target.value;
    }

    showNotification() {

        if(ShowToastEvent) {
            
            const evt = new ShowToastEvent({
                title: this.title,
                message: this.message,
                variant: this.variant,
            });

            this.dispatchEvent(evt);

        }
    }

    @api
    showCustomNotice() {
        
        const toastModel = this.template.querySelector('[data-id="toastModel"]');
        toastModel.className = 'slds-show';
        
        if(this.autoClose){
            if( (this.autoCloseErrorWarning && this.variant !== 'success') || this.variant === 'success') {
                this.delayTimeout = setTimeout(() => {
                    // eslint-disable-next-line no-shadow
                    const toastModel = this.template.querySelector('[data-id="toastModel"]');
                    toastModel.className = 'slds-hide';
                }, this.autoCloseTime);
            }
        }
    }

    closeModel() {
        const toastModel = this.template.querySelector('[data-id="toastModel"]');
        toastModel.className = 'slds-hide';
    }

    get mainDivClass() { 
        return 'slds-notify slds-notify_toast slds-theme_'+this.variant;
      }

    get messageDivClass() { 
        return 'slds-icon_container slds-icon-utility-'+this.variant+' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
    get iconName() {
        return 'utility:'+this.variant;
    }

    // to check if the value is updated.
    get checkVariant(){
        if(this.variant){
            return true;
        }
        return false;
    }
}