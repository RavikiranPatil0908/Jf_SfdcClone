/**
 * @description       : Redirects user to appropriate AEP request form based on profile.
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 12--08--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   23--07--2025   @Ravi   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation' ;
import getAccountById from '@salesforce/apex/LightningAccountButtonController.getAccountById';
// Import custom labels
import lightningBaseUrl from "@salesforce/label/c.SalesforceLightningBaseUrl";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class AepRequestButton extends NavigationMixin(LightningElement) {
    @api recordId;
    Account;
    profileName;
    urlToRedirect = '';

    @wire(getAccountById, { recordId: '$recordId' })
    getAccountRecord({ error, data }) {
        if (data) {
            console.log('account '+data);
            console.dir(data.account);
            console.log(data.profileName);

            this.Account=data.account;
            this.profileName=data.profileName;
            if(this.profileName === 'Information Center Partner Community User' || this.profileName === 'Information Center Executive Community User') {
                this.urlToRedirect = `https://ngasce.my.site.com/aep/a0y/e?CF00N9000000EcWiJ=${this.Account.salutation}+${this.Account.firstName}+${this.Account.lastName}&CF00N9000000EcWiJ_lkid=${this.Account.accountId}&CF00N9000000EcWiA=${this.Account.icName}`;
                console.log('url ==>'+this.urlToRedirect);
                this.navigateToWebPage();
            } else if(this.profileName === 'Head Office Community') {  //change base url for lightning exp
                this.urlToRedirect = `https://ngasce.my.site.com/HO/a0y/e?CF00N9000000EcWiJ=${this.Account.Salutation}+${this.Account.FirstName}+${this.Account.LastName}&CF00N9000000EcWiJ_lkid=${this.Account.Id}&CF00N9000000EcWiA=${this.Account.IC_Name_1__c}`;
                console.log('url ==>'+this.urlToRedirect);
                this.navigateToWebPage();
            } else if(this.profileName === 'Learning Center Community User') {  //change base url for lightning exp
                this.urlToRedirect = `https://ngasce.my.site.com/LC/a0y/e?CF00N9000000EcWiJ=${this.Account.Salutation}+${this.Account.FirstName}+${this.Account.LastName}&CF00N9000000EcWiJ_lkid=${this.Account.Id}&CF00N9000000EcWiA=${this.Account.IC_Name_1__c}`;
                console.log('url ==>'+this.urlToRedirect);
                this.navigateToWebPage();
            } else {
                this.urlToRedirect = `${lightningBaseUrl}lightning/o/AEP_Request__c/new?defaultFieldValues=Student__c=${this.Account.Id},AEP__c=${this.Account.nm_Centers__c}`;
                console.log('url ==>'+this.urlToRedirect);
                this.navigateToWebPage();
                
            }
		} else if (error) {
			console.error(error);
            this.closeQuickAction();
		}
	}

    navigateToWebPage() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.urlToRedirect
            }
        },
        false // Replaces the current page in your browser history with the URL
        );
        this.closeQuickAction();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}