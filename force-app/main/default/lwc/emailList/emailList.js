import { LightningElement, api, track, wire } from 'lwc';
import { formatDate } from 'c/formatedDate';
import fetchRecords from '@salesforce/apex/purchaseLicenseForAEPController.getEmailMessage';

export default class EmailList extends LightningElement {
      count = 0;
      activeSections = ['A', 'B', 'C','D'];
      viewMail = false;
      showModal = false;
      @api recordId;
      @api experience = 'lightning';
      @api records = [];
      @api hasData = false;
      
      @track emailMessage = {
            rec: null,
            date: '',
            textBody: '',
            hasAttachment: false
      };
      @track DataLoading = true;

      get isClassic() {
            if(this.experience === 'classic') {
                  return true;
            }
            return false;
      }

      @wire(fetchRecords, { parentId: '$recordId' })
      getEmailList({ error, data }) {
            if (data) {
                  this.count = data.length;
                  data.forEach(element => {
                        let dtVal = new Date(element.createdDate);
                        let date = formatDate(dtVal,'d/MM/yyyy h:mm TT','');
                        this.records.push({ value: element, key: element.id, date: date});
                  });
                  this.hasData = true;
                  this.DataLoading = false;
            } else if (error) {
                  console.error(error);
                  this.DataLoading = false;
            }
            console.log('recordId ==>'+this.recordId);
            console.log(this.experience);
      }

      handleClick = (event) => {
            let key = event.target.dataset.key;
            this.records.forEach(element => {
                  if(element.key === key) {
                        this.emailMessage.rec = element.value;
                        this.emailMessage.date = element.date;
                        if({}.hasOwnProperty.call(element.value, 'textBody')) {
                              this.emailMessage.textBody = element.value.textBody.replace(/\n/g, "<br />");
                        }
                        this.emailMessage.hasAttachment = element.value.attachments.length > 0 ? true : false;
                        console.log(this.emailMessage);
                        this.activeSections = this.emailMessage.hasAttachment ? ['A', 'B', 'C','D'] : ['A', 'B', 'C'];
                        this.viewMail = true;
                        this.showModal = true;
                  }
            });
      }

      closeModal() {
            this.showModal = false;
      }
}