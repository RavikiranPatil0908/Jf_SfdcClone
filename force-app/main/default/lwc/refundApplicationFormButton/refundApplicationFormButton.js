import { LightningElement, api } from "lwc";
// import { NavigationMixin } from "lightning/navigation";
import SiteUrlLabel from '@salesforce/label/c.Site_Url';

export default class RefundApplicationFormButton extends LightningElement {
    @api recordId;

    connectedCallback() {
        this.handleNavigate();
    }

    handleNavigate() {
        // const config = {
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: `${SiteUrlLabel}apex/Refund?id=${this.recordId}`
        //     }
        // };
        // this[NavigationMixin.Navigate](config);

        window.location = `${SiteUrlLabel}apex/Refund?id=${this.recordId}` ;	
    }
}