import {LightningElement, api} from 'lwc';

export default class ConfirmationDialog extends LightningElement {
    @api visible; //used to hide/show dialog
    @api title; //modal title
    @api message; //modal message
    @api confirmLabel; //confirm button label
    @api cancelLabel; //cancel button label

    //handles button clicks
    handleClick(event){
        //creates object which will be published to the parent component
        let finalEvent = {
            status: event.target.name
        };

        //dispatch a 'click' event so the parent component can handle it
        this.dispatchEvent(new CustomEvent('click', {detail: finalEvent}));
    }

    closeModal() {
        let finalEvent = {
            status: 'cancel'
        };

        //dispatch a 'click' event so the parent component can handle it
        this.dispatchEvent(new CustomEvent('click', {detail: finalEvent}));
    }
}