import { LightningElement, api, wire, track } from 'lwc';
import fetchEmailListValue from '@salesforce/apex/salesCadenceController.getOrgDetails';
import getAllDocuments from '@salesforce/apex/salesCadenceController.getAllDocuments';
import sendEmailMessage from '@salesforce/apex/salesCadenceController.sendEmail';
import getAllEmailTemplate from '@salesforce/apex/salesCadenceController.getAllEmailTemplate';
import getOrganization from '@salesforce/apex/salesCadenceController.getOrganization';
import communityURL from '@salesforce/label/c.communityURL';
import { loadStyle } from 'lightning/platformResourceLoader';
import NewFormResource from '@salesforce/resourceUrl/NewFormResource';

export default class EmailWizard extends LightningElement {
    emailPanel = true;
    @api bccValue = '';
    @api ccValue = '';
    @api showModal = false;
    @api showAttachment = false;
    @api showTemplate = false;
    @api showPreview = false;
    @api ld;
    @api count = 0;
    @api templateDataLoaded = false;
    @api attachmentValue = 'All';
    @api templateValue = 'All';
    @api searchValue = '';
    @api isDialogVisible = false;
    @api uiEmailTemplateURL;
    @track bccList = [];
    @track ccList = [];
    @track sendOption = true;
    @track files = [];
    @track templates = [];
    @track email = {
        fromAdress: '',
        toAddress: '',
        ccAddress: '',
        bccAddress: '',
        subject: '',
        body: '',
        hasAttachment: false,
        attachments: [],
        leadId: '',
        emailType: 'text',
        templateId: '',
    }
    @track showPopup = { title: '', message: '', variant: '' };
    @track folders = [{ label: 'All', value: 'All' }];
    @track templateFolders = [
        { label: 'All', value: 'All' }, 
        { label: 'Unfiled Public Classic Email Templates', value: ''}
    ];
    @track attachments = [];

    connectedCallback() {
        Promise.all([ loadStyle(this, NewFormResource + '/css/inline.css') ]).then(() => {
			console.log('css loaded');
		});
    }

    @api
    get toAddress() {
        return this.email.toAddress;
    }

    set toAddress(value) {
        if (value) {
            this.email.toAddress = value;
        }
    }

    @api
    get checkTemplateType() {
        if(this.email.emailType === 'text') {
            return true;
        } else {
            return false;
        }
    }

    set checkTemplateType(value) {
        this.email.emailType = value;
    }

    get dockerClass() {
        return this.emailPanel ? 
            'slds-docked-composer slds-grid slds-grid_vertical slds-is-open' :
            'slds-docked-composer slds-grid slds-grid_vertical slds-is-closed';
    }

    @wire(fetchEmailListValue)
    fromAdressValues({ error, data }) {
        if (data) {
            console.log(data);
            this.email.fromAdress = data.Address;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getAllDocuments)
    getAllDocuments({ error, data }) {
        if (data) {
            console.log(data);
            let folders = new Array();
            data.forEach(element => {
                if (element.Type !== 'URL') {
                    this.files.push({ value: element, key: element.Id, selected: false, show: true, folder: element.Folder.Name });
                    // to set folders list
                    if (!folders.includes(element.Folder.Name)) {
                        folders.push(element.Folder.Name);
                        const option = {
                            value: element.Folder.Name,
                            label: element.Folder.Name
                        }
                        this.folders = [...this.folders, option];
                    }
                }
            });
            console.log('Folders ==>');
            console.log(this.folders);
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getOrganization)
    getOrganization({ error, data }) {
        if (data) {
            this.templateFolders.forEach(element => {
                if(element.label === 'Unfiled Public Classic Email Templates') {
                    element.value = data.Id;
                }
            });
        }
    }

    @wire(getAllEmailTemplate)
    getAllEmailTemplate({ error, data }) {
        if (data) {
            console.log(data);
            let folders = new Array();
            data.forEach(element => {
                // to set folders list
                if ({}.hasOwnProperty.call(element, 'Folder') && !folders.includes(element.FolderId)) {
                    folders.push(element.FolderId);
                    const option = {
                        value: element.FolderId,
                        label: element.Folder.Name
                    }
                    this.templateFolders = [...this.templateFolders, option];
                }

                const getItem = this.templateFolders.find(item => item.value === element.FolderId);
                if (typeof getItem === 'undefined') {
                    this.templates.push({ value: element, key: element.Id, selected: false, show: true, folderId: element.FolderId, folderName: 'Unfiled Public Classic Email Templates' });
                } else {
                    this.templates.push({ value: element, key: element.Id, selected: false, show: true, folderId: element.FolderId, folderName: getItem.label });
                }
            });
            this.templateDataLoaded = true;
        } else if (error) {
            console.error(error);
        }
    }

    closeModal() {
        this.showModal = false;
    }

    toggeleEditOption() {
        this.showModal = true;
        this.emailPanel = true;
    }

    showAttachmentModal() {
        this.showAttachment = true;
    }

    closeAttachmentModal() {
        this.showAttachment = false;
    }

    showTemplateModal() {
        this.showTemplate = true;
    }

    closeTemplateModal() {
        this.showTemplate = false;
    }

    showPreviewModal() {
        this.showPreview = true;
    }

    closePreviewModal() {
        this.showPreview = false;
    }

    hideEmailModal() {
        this.emailPanel = false;
    }

    showEmailModal() {
        this.emailPanel = true;
    }

    handleChangeOnAttachment(event) {
        this.attachmentValue = event.detail.value;
        if (this.files.length) {
            this.files.forEach(element => {
                if (element.folder === this.attachmentValue || this.attachmentValue === 'All') {
                    element.show = true;
                } else {
                    element.show = false;
                }
            });
        }
    }

    handleChangeOnTemplate(event) {
        this.templateDataLoaded = false;
        let name = event.target.name;
        if (this.templates.length > 0) {
            if(name === 'folders') {
                this.templateValue = event.detail.value;
                this.templates.forEach(element => {
                    if (element.folderId === this.templateValue || this.templateValue === 'All') {
                        element.show = true;
                    } else {
                        element.show = false;
                    }
                });
            } else {
                this.searchValue = event.detail.value;
                this.templates.forEach(element => {
                    const templateName = element.value.Name;
                    if ((element.folderId === this.templateValue || this.templateValue === 'All') && 
                        (templateName === '' || templateName.toLowerCase().includes(this.searchValue.toLowerCase()))) {
                        element.show = true;
                    } else {
                        element.show = false;
                    }
                });
            }
        }
        this.templateDataLoaded = true;
    }

    handleSelect(event) {
        let key = event.currentTarget.dataset.key;
        this.files.forEach(element => {
            if (element.key === key) {
                element.selected = !element.selected;
                if (element.selected) {
                    this.count++;
                } else {
                    this.count--;
                }
            }
        })

        if (this.count > 0) {
            this.sendOption = false;
        } else {
            this.sendOption = true;
        }
    }

    onSubmit() {
        this.files.forEach(element => {
            if (element.selected) {
                const getItem = this.attachments.find(item => item.Id === element.key);
                console.log('Item ==>' + getItem);
                if (typeof getItem === 'undefined') {
                    const attachment = {
                        name: element.value.Name,
                        Id: element.key
                    }
                    this.attachments = [...this.attachments, attachment];
                }
            }
        })

        if (this.attachments.length > 0) {
            this.email.hasAttachment = true;
        }

        this.closeAttachmentModal();
    }

    removeAttachment(event) {
        let index = event.target.dataset.index;
        this.attachments.splice(index, 1);

        if (this.attachments.length === 0) {
            this.email.hasAttachment = false;
        }
    }

    removeAddress(event) {
        let key = event.currentTarget.dataset.key;
        let val = event.currentTarget.dataset.address;

        console.log(key +' ===> '+ val);

        if(key === 'bcc' && this.bccList.length > 0) {
            for( var i = 0; i < this.bccList.length; i++){ 
                if (this.bccList[i] === val) { 
                    this.bccList.splice(i, 1); 
                }
            }
        } else if(key === 'cc' && this.ccList.length > 0) {
            for( var i = 0; i < this.ccList.length; i++){ 
                if (this.ccList[i] === val) { 
                    this.ccList.splice(i, 1); 
                }
            }
        }
    }

    sendEmail() {
        if (this.email.hasAttachment) {
            this.attachments.forEach(element => {
                this.email.attachments.push(element.Id);
            })
        }

        this.email.leadId = this.ld.Id;
        console.log(this.email);
        sendEmailMessage({ objWrapper: this.email })
            .then((result) => {
                console.log(result);
                if (result === 'Success') {
                    this.showHtmlMessage('Success!!', 'Mail Sent!', 'success');
                    this.updateChange();
                }
            })
            .catch((error) => {
                console.log('error', JSON.stringify(error));
                this.showHtmlMessage('Error !', error.body.message, 'error');
            });

        this.closeModal();
    }

    handleChange(event) {
        let field = event.target.dataset.field;
        let val = event.detail.value;
        console.log(field);
        if ({}.hasOwnProperty.call(this.email, field)) {
            this.email[field] = val;
        }else if(field === 'bccValue' && val && (val.includes(',') || val.includes(','))) {
            this.bccValue = val;
            this.bccList = this.bccList.concat(this.bccValue.split(','));
            this.bccList = this.bccList.filter(item => item);
            this.bccValue = '';
            console.log(this.bccValue);
        } else if(field === 'ccValue' && val && (val.includes(',') || val.includes(','))) {
            this.ccList = this.ccList.concat(val.split(','));
            this.ccList = this.ccList.filter(item => item);
            this.ccValue = '';
            console.log(this.ccList);
        }
    }

    updateChange() {
        const filterChangeEvent = new CustomEvent('change', {
            detail: {
                "taskAdded": true,
            }
        });
        this.dispatchEvent(filterChangeEvent);
    }

    insertTemplate(event) {
        let key = event.currentTarget.dataset.key;
        console.log(key);
        if(key) {
            let getItem = this.templates.find(item => item.key === key);
            console.log(getItem);
            if(typeof getItem !== 'undefined' && {}.hasOwnProperty.call(getItem, 'value')) {
                this.checkTemplateType = getItem.value.TemplateType;
                if(getItem.value.TemplateType === 'text') {
                    this.email.body = `<span style="white-space: pre-line">${getItem.value.Body}</span>`;
                } else {
                    this.email.body = getItem.value.HtmlValue;
                }
                let encodedURI = encodeURIComponent(communityURL);
                this.uiEmailTemplateURL = `${communityURL}/email/templaterenderer?id=${getItem.key}&recipient_type_id=${this.ld.Id}&base_href=${encodedURI}&preview_frame=contentFrame&render_type=REPLACED_HTML_BODY`;
                this.email.templateId = getItem.key;
                this.email.subject = getItem.value.Subject;
                this.closeTemplateModal();
            }
        }
    }

    showConfrimDialog(){
        this.isDialogVisible = true;
    }

    handleClickOnConfirmDialog(event) {
        if(event.detail !== 1){
            //gets the detail message published by the child component
            //you can do some custom logic here based on your scenario
            if(event.detail.status === 'confirm') {
                //do something
                this.email.subject = '';
                this.email.body = '';
                this.email.ccAddress = '';
                this.email.bccAddress = '';
                this.email.templateId = '';
                this.checkTemplateType = 'text';
                if(this.email.hasAttachment) {
                    this.email.hasAttachment = false;
                    this.email.attachments = [];
                    this.attachments = [];
                }
                this.uiEmailTemplateURL = '';
                this.isDialogVisible = false;
            }else if(event.detail.status === 'cancel'){
                //do something else
                this.isDialogVisible = false;
            }
        }
    }

    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}