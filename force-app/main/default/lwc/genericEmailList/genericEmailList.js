import { LightningElement, api, track, wire } from 'lwc';
import { formatDate } from 'c/formatedDate';
import fetchRecords from '@salesforce/apex/GenericEmailController.getEmailMessage';

export default class GenericEmailList extends LightningElement {

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
          body: '',
          hasAttachment: false,
          textBody:''
    };
    @track DataLoading = true;

    get isClassic() {
          if(this.experience === 'classic') {
                return true;
          }
          return false;
    }
    @wire(fetchRecords, { parentId: '$recordId' })//001In000005G3Ka  //$recordId
    getEmailList({ error, data }) {
        console.log(data);
          if (data) {
                this.count = data.length;
                let localId =1;
                data.forEach(element => {
                        let dtVal = new Date(element.createdDate);
                        let date = formatDate(dtVal,'d/MM/yyyy h:mm TT','');
                        console.log('element.fromEmailId ==>'+element.fromEmailId);
                        this.records.push({ value:  Object.assign({}, element, { fromAddress : element.fromEmailId,toAddress : element.mailId}), key: ''+localId++, date: date});
                });
                this.hasData = true;
                this.DataLoading = false;
          } else if (error) {
                console.error(error);
                this.DataLoading = false;
          }
          console.log('recordId gm ==>'+this.recordId);
          console.log(this.experience);
    }

    handleClick = (event) => {
          let key = event.target.dataset.key;
          console.log(key);
          this.records.forEach(element => {
                if(element.key === key) {
                  console.log(element);
                        this.emailMessage.rec = element.value;
                        this.emailMessage.date = element.date;
                  //     this.emailMessage.rec = {...element.value,fromAddress : element.value.fromEmailId,toAddress: element.value.mailId};
                        this.emailMessage.date = element.value.createdDate;
                      if({}.hasOwnProperty.call(element.value, 'body')) {
                            this.emailMessage.textBody = element.value.body.replace(/\n/g, "<br />");
                      }
                     // this.emailMessage.hasAttachment = element.value.attachments.length > 0 ? true : false;
                      console.log('emailMessage',this.emailMessage.fromAddress,this.emailMessage.toAddress);
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