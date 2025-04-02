import { LightningElement, track, api  } from 'lwc';
import getEmailsForCase from '@salesforce/apex/MyCasesController.getEmailsForCase';

export default class CaseViewMsgLst extends LightningElement {

    @api recordId;
    @api accName;
    @track msgList;
    showSpinner = false;
    isMsgAvialable = false;

    connectedCallback() {
        this.getEmailMessages();
        console.log('this.recordId l1==>'+this.recordId);
        console.log('this.objAccount l1==>'+this.accName);
    }

    @api
    getEmailMessages() {
        this.showSpinner = true;
		console.log('method called ==>');
		getEmailsForCase({ caseId: this.recordId }).then(result => {
			//const regex = /<\/?[a-z][\s\S]*>/i.test();
			this.msgList = result.map((elem) => ({
				...elem,
				...{
					'hasTags': /<\/?[a-z][\s\S]*>/i.test(elem.CommentBody) ? true : false,
					'CreatedBy': elem.CreatedBy.Name === 'NMIMS Site Guest User' || elem.CreatedBy.Name === 'Admin User' ? this.accName : (elem.CreatedBy.Name.split(' ')[0] + ' ' + elem.CreatedBy.Name.split(' ')[1].charAt(0))
				}
			}));

			if(this.msgList.length > 0) {
				this.isMsgAvialable = true;
			}
            this.showSpinner = false;
		})
		.catch(error => {
			console.log(error);
            this.showSpinner = false;
		});
	}
}