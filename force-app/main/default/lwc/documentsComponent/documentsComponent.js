import { LightningElement, track, api, wire } from 'lwc';
import lightningSiteUrl from '@salesforce/label/c.lightningSiteUrl';
import getAllDocuments from '@salesforce/apex/salesCadenceController.getAllDocuments';
export default class DocumentsComponent extends LightningElement {

    @api isDataLoaded = false;
    @api searchValue = '';
    @api optionValue = 'All';
    @track documnetsData = [];
    @track folders = [{ label: 'All', value: 'All' }, ];

    @wire(getAllDocuments)
    getAllDocuments({ error, data }) {
        if (data) {
            let folders = new Array();
            console.dir(data);
            if (Object.keys(data).length === 0 && data.constructor === Object) {
                console.error('error in data retrive...' + error);
                this.isDataLoaded = false;
            } else {
                data.forEach(element => {
                    let length,uri;

                    // to set folders list
                    if ({}.hasOwnProperty.call(element, 'Folder') && !folders.includes(element.FolderId)) {
                        folders.push(element.FolderId);
                        const option = {
                            value: element.FolderId,
                            label: element.Folder.Name
                        }
                        this.folders = [...this.folders, option];
                    }

                    if (element.Type === 'URL') {
                        length = '(URL)';
                        uri = element.Url;
                    } else {
                        length = this.getFileSize(element.BodyLength);
                        uri = lightningSiteUrl + "servlet/servlet.FileDownload?file=" + element.Id;
                    }
                    
                    this.documnetsData.push({ 
                        value: element, 
                        key: element.Id, 
                        selected: false, 
                        show: true, 
                        folderId: element.FolderId, 
                        folder: element.Folder.Name, 
                        docUrl: uri, 
                        fileSize: length 
                    });
                });

                // to sort the folders by Ascending order
                this.folders = this.folders.sort(this.sortBy('label', false, (a) =>  a.toUpperCase()));
                const AllIndex = this.folders.findIndex(folder => folder.label === 'All');
                this.folders.push(...this.folders.splice(0, AllIndex));

                this.isDataLoaded = true;
            }
        } else if (error) {
            this.isDataLoaded = false;
            console.error(error);
        }
    }

    handleChange = (event) => {
        this.isDataLoaded = false;
        let name = event.target.dataset.name;
        if (this.documnetsData.length > 0) {
            if (name === 'folders') {
                this.optionValue = event.detail.value;
                this.documnetsData.forEach(element => {
                    if (element.folderId === this.optionValue || this.optionValue === 'All') {
                        element.show = true;
                    } else {
                        element.show = false;
                    }
                });
            } else {
                this.searchValue = event.detail.value;
                this.documnetsData.forEach(element => {
                    const docName = element.value.Name;
                    if ((element.folderId === this.optionValue || this.optionValue === 'All') &&
                        (docName === '' || docName.toLowerCase().includes(this.searchValue.toLowerCase()))) {
                        element.show = true;
                    } else {
                        element.show = false;
                    }
                });
            }
        }
        this.isDataLoaded = true;
    }

    getFileSize = (BodyLength) => {
        let bytes = BodyLength,sizeIn_KB,sizeIn_MB,length;
        sizeIn_KB = bytes / 1000;
        sizeIn_MB = sizeIn_KB / 1000;
        if(sizeIn_MB >= 1) {
            if(Math.round(sizeIn_MB) !== sizeIn_MB) {
                sizeIn_MB = sizeIn_MB.toFixed(2);
            }
            length = `${sizeIn_MB} MB`; 
        } else {
            if(Math.round(sizeIn_KB) !== sizeIn_KB) {
                sizeIn_KB = sizeIn_KB.toFixed(2);
            }
            length = `${sizeIn_KB} KB`; 
        }
        return length;
    }

    sortBy = (field, reverse, primer) => {
        const key = primer ?
            function(x) {
                return primer(x[field])
            } :
            function(x) {
                return x[field]
            };
      
        reverse = !reverse ? 1 : -1;
      
        return function(a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
}