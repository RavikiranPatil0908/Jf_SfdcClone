import { LightningElement,api,wire } from 'lwc';
import getStudentImage from "@salesforce/apex/VideoVerificationFormController.getStudentImage";

export default class ShowStudentImage extends LightningElement {
@api accountId;
studentImage = '';

@wire(getStudentImage, {recordId: '$accountId'})
    wiredAccount ({ data, error}) {
        console.log('recordId--->' + this.accountId)
        if (data) {
            this.studentImage = data;
            console.log('image--->' + this.studentImage);
        }
        else if (error) {
            console.log('Something went wrong');
        }
    }

}