import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { FlowNavigationEvent } from 'lightning/flowSupport';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport'

export default class ShowToastInFlowLWC extends LightningElement {
    @api mode;
    @api variant;
    @api toastMessage;
    @api title;
    @api avialableActions = [];

    connectedCallback() {
        this.handleShowToast();
        this.handleClose();
    }

    handleShowToast() {
        const evt = new ShowToastEvent({
            title: this.title,
            message: this.toastMessage,
            variant: this.variant,
            mode: this.mode
        });
        this.dispatchEvent(evt);
    }

    handleClose() {
        const navigateNextEvent = new FlowNavigationFinishEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    // handleClose() {
    //     const navigateNextEvent = new FlowNavigationEvent();
    //     this.dispatchEvent(navigateNextEvent);
    // }
}