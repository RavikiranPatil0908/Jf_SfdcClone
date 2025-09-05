/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 18-07-2025
 * @last modified by  : @Shailesh
**/
import { api, LightningElement, wire } from 'lwc';
import checkForRefreshUrl from '@salesforce/apex/VvcMeetingUrlController.checkForRefreshUrl';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class RefreshVvcMeetingUrlbtn extends LightningElement {

    @api recordId;
     
        handlebtnclick(){
           // confirm("please confirm to refresh Meeting Link!\nEither OK or Cancel.");
                checkForRefreshUrl({recordId: this.recordId})
                    .then((data,error) => {
                                if (data) {
                                    console.log("data :: "+data);
                                if (data.length > 0 && data.length < 5) {
                                    this.showAlert('Success', 'Meeting Link refreshed', 'success');
                                    this.handleReload();
                                } else {    
                                this.showAlert('Meeting Link not refreshed', 'please try after sometime.', 'unsuccessful');
                                this.handleReload();
                                }
                                
                            } else if (error) {
                                console.error(error);
                            
                                this.showAlert('Error', error.body.message, 'error');
                            }
                            
                        })
                .catch(error => {
                    this.showAlert('Error', error.body.message, 'error');
                });
        }
        handlebtnReject(event){
           // this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());
           
        }
         handleReload(){
             window.location.reload();
         }

    showAlert(title, message, variant) 
    {
        if (this.template.querySelector('lightning-toast')) {
            // Lightning Experience: Show toast notification
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        } else {
            // Classic Experience: Show alert
            alert(`${title}: ${message}`);
        }
    }
    
}