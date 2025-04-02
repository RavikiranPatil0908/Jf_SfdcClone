import { LightningElement, api } from 'lwc';

export default class EmailMessageDetail extends LightningElement {
    @api activeSections = ['A', 'B', 'C'];
    @api emailMessage = {
        rec: {},
        date: '',
        textBody: '',
        hasAttachment: false
    };

    downloadURI = (uri, name) => {
        var link = document.createElement("a");
        link.download = name;
        link.href = uri;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    downloadFile = (event) => {
        let key = event.currentTarget.dataset.key;
        let attachments = this.emailMessage.rec.attachments; 
        attachments.forEach(file => {
            if(key.toString() === file.attachmentId) {
                let dataURI = `data:${file.contentType};base64,${file.attachmentBody}`;
                this.downloadURI(dataURI,file.name);
            }
        });
    }
}