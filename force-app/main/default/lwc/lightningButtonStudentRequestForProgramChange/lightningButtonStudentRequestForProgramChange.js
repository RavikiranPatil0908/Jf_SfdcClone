/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 04--07--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   24--06--2025   @Ravi   Initial Version
**/
import { LightningElement ,api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class LightningButtonStudentRequestForProgramChange extends LightningElement {
    @api redirectUrl;
    @api FinalURL;

    connectedCallback() {
        if (this.FinalURL) {
            window.open(this.FinalURL, '_blank');
            this.dispatchEvent(new CloseActionScreenEvent()); // close the action
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }
   
}