import { LightningElement, wire, track, api } from 'lwc';
import getListAsyncRecords from "@salesforce/apex/FacultyVideoReviewController.getListAsyncRecords";
import getTOCRecords from "@salesforce/apex/FacultyVideoReviewController.getTOCRecords";
import updateAsyncwithTOC from "@salesforce/apex/FacultyVideoReviewController.updateAsyncwithTOC";
import updateTocWithAsync from "@salesforce/apex/FacultyVideoReviewController.updateTocWithAsync";
import LightningConfirm from 'lightning/confirm';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import ASYNC_OBJECT from "@salesforce/schema/Async_Shoot_Post_Production__c";
import PROGRAM_FIELD from "@salesforce/schema/Async_Shoot_Post_Production__c.Program__c";
import SUBJECT_FIELD from "@salesforce/schema/Async_Shoot_Post_Production__c.Subject__c";
import MAPPING_STATUS_FIELD from "@salesforce/schema/Async_Shoot_Post_Production__c.Mapping_Status__c";

export default class AttachTocToAsyncVideos extends LightningElement {

    @api recordId;
    @track recordColumns = [
        {
            label: "Name",
            type: "button",
            initialWidth: 100,
            typeAttributes: {
                label: { fieldName: "name" },
                variant: "destructive-text"
            },
        },
        { 
            label: "is Mapped", hideDefaultActions: true, fieldName: "isMapped",initialWidth: 300,wrapText:true,
            cellAttributes: { 
                iconName: { fieldName: 'dynamicIcon' } 
            }
        },
        { label: "Mapping Status", hideDefaultActions: true, fieldName: "mappingStatus",initialWidth: 250},
        { label: "Subject", hideDefaultActions: true, fieldName: "subject", initialWidth: 300,wrapText:true},
        { label: "Video Title", hideDefaultActions: true, fieldName: "videoTitle" ,initialWidth: 300,wrapText:true},
        { label: "Video Coverage", hideDefaultActions: true, fieldName: "videoCoverage",initialWidth: 400,wrapText:true }
    ];
    @track tocColumns = [
        { label: "Block Name", hideDefaultActions: true, fieldName: "blockName" },
        { label: "Unit Name", hideDefaultActions: true, fieldName: "unitName" },
        { label: "Topic Name", hideDefaultActions: true, fieldName: "topicName" },
        { label: "Sub Topic Name", hideDefaultActions: true, fieldName: "subTopicName" },
        {
            label: "Map",
            type: "button",						
            typeAttributes: {
                label: { fieldName: "mapLabel"},
                name: "Map",
                iconPosition: 'left',
                value: { fieldName: "isMapped" },
                variant: { fieldName: "btnVariant" },
                iconName: { fieldName: 'dynamicIcon'} 
            }
        }
    ];
    @track asyncRecord = {};
    @track updateTocRecord = {}; 
    @track showPopup = { title: '', message: '', variant: '' };
    @track filters = { program: '', subject: '', search: '', id: '', getPendingList: false };
    data;
    error;
    isOpen = false;
    @track blockFieldOptions = [{ label: 'Choose Block Name', value: '' }];
    @track unitFieldOptions = [{ label: 'Choose Unit Name', value: '' }];
    @track topicFieldOptions = [{ label: 'Choose Video Title', value: '' }];
    @track subTopicFieldOptions = [{ label: 'Choose Video Coverage', value: '' }];
    lstTocRecords;
    filteredTOCRecords;
    blockName = '';
    unitName = '';
    topicName = '';
    subTopic = '';
    isLoading = false;
    isEdit = false;
    isPlaying = false;
    youTubeId = undefined;
    vttLink;
    isChanged = false;
    showTOCOnly = false;

    @track programOptions = [{ label: 'Choose Program', value: '' }];
    @track subjectOptions = [{ label: 'Choose Subject', value: '' }];
    @track mappingStatusOptions = [{ label: 'Choose Subject', value: '' }];

    connectedCallback() {
        if(this.recordId) {
            this.isOpen = true;
            this.showTOCOnly = true;
            this.isLoading = true;
            this.filters.recordId = this.recordId;
            this.fetchTOC();
        }
    }

    @wire(getObjectInfo, { objectApiName: ASYNC_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: PROGRAM_FIELD })
    picklistProgramResults({ error, data }) {
        if (data) {
            console.log(data.values);
            console.log(JSON.stringify(data.values));
            // this.programOptions = data.values;

            data.values.forEach(statusField => {
                // console.log(statusField.label, statusField.value)
                const options = { 'label': statusField.label, 'value': statusField.value };
                this.programOptions = [...this.programOptions,options];
            });

        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: SUBJECT_FIELD })
    picklistSubjectResults({ error, data }) {
        if (data) {
            // this.subjectOptions = data.values;
            data.values.forEach(statusField => {
                // console.log(statusField.label, statusField.value)
                const options = { 'label': statusField.label, 'value': statusField.value };
                this.subjectOptions = [...this.subjectOptions,options];
            });
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: MAPPING_STATUS_FIELD })
    picklistMappingStatusResults({ error, data }) {
        if (data) {
            data.values.forEach(statusField => {
                const options = { 'label': statusField.label, 'value': statusField.value };
                this.mappingStatusOptions = [...this.mappingStatusOptions,options];
            });
        } else if (error) {
            console.error(error);
        }
    }

    get isVTTAvialble() {
        if(this.asyncRecord.Post_Production_Status__c === 'Approved & Completed') {
            return true;
        }
        return false;
    }

    get isVideoAvialable() {
        if(this.asyncRecord.Current_Download_Link__c) {
            return true;
        }
        return false;
    }

    get showBackBtn() {
        if(!this.showTOCOnly && this.isOpen) {
            return true;
        }
        return false;
    }

    // get showFilters() {
    //     if(!this.showTOCOnly && !this.isOpen) {
    //         return true;
    //     }
    //     return false;
    // }

    get showAsyncTable() {
        if(!this.showTOCOnly && !this.isOpen) {
            return true;
        }
        return false;
    }

    get showTOCTable() {
        if(this.showTOCOnly || this.isOpen) {
            return true;
        }
        return false;
    }

    get stlyeClass() {
        return !this.showTOCOnly ? 'slds-var-m-horizontal_xx-large slds-var-m-top_xx-small slds-var-m-bottom_xx-large' : '';
    }
    
    filterSearch(event) {
        let element = event.currentTarget.dataset.element;
        this.filters[element] = event.target.value;
        if((this.filters.program && this.filters.subject) || this.filters.search) {
            this.isLoading = true;
            this.getListAsyncDetails(false);
            this.filters.getPendingList = false;
        }
    }

    fetchUnMappedAsync() {
        this.isLoading = true;
        this.filters.getPendingList = true;
        this.getListAsyncDetails(false);
        this.filters.getPendingList = false;
    }

    fetchTOC() {
        if(this.filters.recordId) {
            this.getListAsyncDetails(true);
        }
    }

    async getListAsyncDetails(isDirect = false) {
        await getListAsyncRecords({wrapper: this.filters})
        .then(result => {
            if(isDirect) {
                this.asyncRecord = { ...result[0].objRecord };
                this.getTOCDetails();
                this.isLoading = false;
            } else {
                this.data = result;
                this.error = undefined;
                this.isLoading = false;
            }
            console.log('data' + JSON.stringify(this.data));
        })
        .catch(error => {
            this.data = undefined;
            this.error = error;
            this.showHtmlMessage('Error',this.error, 'error');
            console.log('error' + JSON.stringify(this.error));
            this.isLoading = false;
        });
    }

    handleRowAction(event) {
        this.isLoading = true;
        this.asyncRecord = { ...event.detail.row.objRecord };
        this.vttLink = `https://dxiqj7blpabkh.cloudfront.net/${this.asyncRecord.File_Name_Revised__c}.vtt`;

        this.getTOCDetails();
        this.isOpen = true;
	}

    async handleTOCRowAction(event) {
        let tableRow = event.detail.row;
        let isMap = tableRow.isMapped === 'No' ? true : false;
        let msg = 'Are you sure you want to Un-Link Video to the Selected Topic/Sub Topic';
        if(isMap) {
            msg = 'Are you sure you want to map Video to the Selected Topic/Sub Topic';
        }
        const result = await LightningConfirm.open({
            message: msg,
            variant: 'headerless',
            label: 'Confirm',
            // setting theme would have no effect
        });
        if(result) {
            this.updateTocRecord = tableRow.objRecord;
            // this.updateTocRecord.Async_Shoot_Post_Production__c = null;
            // if(isMap) {
            //     this.updateTocRecord.Async_Shoot_Post_Production__c = this.asyncRecord.Id;
            // }
            // this.asyncRecord.TOC__c = tocRecord.Id;
            let isSuccess = await this.updateTOC(isMap);
            console.log('method called 3')
            if(isSuccess) {
                this.isChanged = true;
                await this.updateRow(tableRow,isMap,this.updateTocRecord);
                this.isLoading = false;
                this.showHtmlMessage('Success','Table of Content mapped with Async Video', 'success');
            } else {
                this.isLoading = false;
                this.showHtmlMessage('Error','Table of Content mapping failed', 'error');
            }
        }
    }

    async updateRow(row, isMapped, objRecord) {
        let updatedData = this.filteredTOCRecords.map(item => {
            if (item.objRecord.Id === row.objRecord.Id) {
                let tableRow = { ...item };
                tableRow.objRecord = { ...objRecord };
                tableRow.isMapped = isMapped ? 'Yes' : 'No';
                tableRow.dynamicIcon = isMapped ? 'utility:unlinked' : 'utility:edit';
                tableRow.mapLabel = isMapped ? 'Un-Link' : 'Map';
                tableRow.btnVariant = isMapped ? 'destructive' : 'destructive-text';
                // Modify the field you want to change
                return { ...tableRow }; 
            }
            return item;
        });

        // Update the tracked property to trigger reactivity
        this.filteredTOCRecords = updatedData;
        await this.getTOCDetails();
    }

    async updateAsync() {
        this.isLoading = true;
        const isSuccess = await updateAsyncwithTOC({obj: this.asyncRecord})
        .then(result => {
            this.isChanged = true;
            this.asyncRecord = result;
            this.isLoading = false;
            return true;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('Error ==>'+JSON.stringify(error));
            return false;
        });
        return isSuccess;
    }

    async updateTOC(isInsert) {
        this.isLoading = true;
        const isSuccess = await updateTocWithAsync({tocId: this.updateTocRecord.Id, asyncId: this.asyncRecord.Id, isInsert: isInsert})
        .then(result => {
            if(result) {
                console.log('method called 2')
                return true;
            }
            return false;
        })
        .catch(error => {
            this.isLoading = false;
            this.showHtmlMessage('Error','TOC mapping failed!', 'error');
            console.log('Error ==>'+JSON.stringify(error));
            return false;
        });
        return isSuccess;
    }

    async getTOCDetails() {
        this.blockFieldOptions = [{ label: 'Choose Block Name', value: '' }];
        console.log('method called 1');
        await getTOCRecords({subject: this.asyncRecord.Subject__c, program: this.asyncRecord.Program__c, asyncId: this.asyncRecord.Id})
        .then(result => {
            this.lstTocRecords = result;
            let blockFieldSet = new Set(this.lstTocRecords.map(item => item.objRecord.Block_Name__c));
            blockFieldSet.forEach(key => {
                console.log(key)
                const option = {
                    value: key,
                    label: key
                };
                this.blockFieldOptions = [...this.blockFieldOptions, option];
            });
            this.setDefaultElements();
            this.isLoading = false;
        })
        .catch(error => {
            console.log('Error ==>'+JSON.stringify(error));
            this.isLoading = false;
        });
    }

    setDefaultElements() {
        this.filteredTOCRecords = [];
        this.lstTocRecords.forEach(element => {
            if(element.mapLabel === 'Un-Link') {
                this.filteredTOCRecords = [...this.filteredTOCRecords, element];
            }
        });
    }

    handleBlockFieldChange(event) {
        this.blockName = event.target.value;
        let unitFieldSet = new Set();
        this.unitFieldOptions = [{ label: 'Choose Unit Name', value: '' }];
        this.filteredTOCRecords = [];
        this.lstTocRecords.forEach(element => {
            if(element.objRecord.Block_Name__c === this.blockName) {
                if(element.objRecord.Unit_Name__c) {
                    unitFieldSet.add(element.objRecord.Unit_Name__c);
                }
                this.filteredTOCRecords = [...this.filteredTOCRecords, element];
            }
        });

        unitFieldSet.forEach(element => {
            const option = {
                value: element,
                label: element
            };
            this.unitFieldOptions = [...this.unitFieldOptions, option]
        });

        if(!this.blockName) {
            this.unitFieldOptions = [{ label: 'Choose Unit Name', value: '' }];
            this.topicFieldOptions = [{ label: 'Choose Video Title', value: '' }];
            this.subTopicFieldOptions = [{ label: 'Choose Video Coverage', value: '' }];
        } else {
            this.topicFieldOptions = [{ label: 'Choose Video Title', value: '' }];
            this.subTopicFieldOptions = [{ label: 'Choose Video Coverage', value: '' }];
        }
    }

    handleUnitFieldChange(event) {
        this.unitName = event.target.value;
        let topicFieldSet = new Set();
        this.topicFieldOptions = [{ label: 'Choose Video Title', value: '' }];
        this.filteredTOCRecords = [];
        this.lstTocRecords.forEach(element => {
            if(element.objRecord.Block_Name__c === this.blockName && ((this.unitName && element.objRecord.Unit_Name__c === this.unitName) || !this.unitName)) {
                if(element.objRecord.Topic_Name__c) {
                    topicFieldSet.add(element.objRecord.Topic_Name__c);
                }
                this.filteredTOCRecords = [...this.filteredTOCRecords, element];
            }
        });

        topicFieldSet.forEach(element => {
            const option = {
                value: element,
                label: element
            };
            this.topicFieldOptions = [...this.topicFieldOptions, option]
        });

        if(!this.unitName) {
            this.topicFieldOptions = [{ label: 'Choose Video Title', value: '' }];
            this.subTopicFieldOptions = [{ label: 'Choose Video Coverage', value: '' }];
        } else {
            this.subTopicFieldOptions = [{ label: 'Choose Video Coverage', value: '' }];
        }
    }

    handleTopicFieldChange(event) {
        this.topicName = event.target.value;
        let topicFieldSet = new Set();
        this.subTopicFieldOptions = [{ label: 'Choose Video Coverage', value: '' }];
        this.filteredTOCRecords = [];
        this.lstTocRecords.forEach(element => {
            if(element.objRecord.Block_Name__c === this.blockName && element.objRecord.Unit_Name__c === this.unitName && 
                element.objRecord.Topic_Name__c === this.topicName) {
                if(element.objRecord.Sub_Topic_Name__c) {
                    topicFieldSet.add(element.objRecord.Sub_Topic_Name__c);
                    console.log(element.objRecord.Sub_Topic_Name__c);
                }
                this.filteredTOCRecords = [...this.filteredTOCRecords, element];
            }
        });

        topicFieldSet.forEach(element => {
            const option = {
                value: element,
                label: element
            };
            console.dir(option);
            this.subTopicFieldOptions = [...this.subTopicFieldOptions, option]
        });

        if(!this.topicName) {
            this.subTopicFieldOptions = [{ label: 'Choose Video Coverage', value: '' }];
        }
    }

    handleSubTopicFieldChange(event) {
        this.subTopic = event.target.value;
        this.filteredTOCRecords = [];
        this.lstTocRecords.forEach(element => {
            if(element.objRecord.Block_Name__c === this.blockName && element.objRecord.Unit_Name__c === this.unitName && element.objRecord.Topic_Name__c === this.topicName 
                && (!this.subTopic || (this.subTopic && element.objRecord.Sub_Topic_Name__c === this.subTopic))) {
                this.filteredTOCRecords = [...this.filteredTOCRecords, element];
            }
        });
    }

    async handleClick() {
        if(this.isChanged) {
            this.isLoading = true;
            await this.getListAsyncDetails(false);
        }
        this.lstTocRecords = undefined;
        this.filteredTOCRecords = undefined;
        this.isOpen = false;
        this.isChanged = false;
    }

    async handleEdit() {
        this.isEdit = this.isEdit ? false : true;
    }

    handleFormChange(event) {
        let value = event.currentTarget.dataset.field;
        console.log('handleChange field ==>'+value);
        if(value) {
            // let objRecord = 
            this.asyncRecord[value] = event.target.value;
        }
    }

    handleObjectiveChange(event) {
        this.asyncRecord.Learning_Objectives__c = event.target.value;
    }

    handleOutcomesChange(event) {
        this.asyncRecord.Learning_Outcomes__c = event.target.value;
    }

    handlePlay() {
        if(!this.isPlaying) {
            this.youTubeId = this.getVideoId(this.asyncRecord.Current_Download_Link__c);
            this.isPlaying = true;
        } else {
            this.isPlaying = false;
        }
    }

    getVideoId(url) {
        // Just the regex. Output is in [1].
        // /^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*/
        let r, rx = /^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*/;
        
        r = url.match(rx);
        console.log(r[1]);
        return r[1];
    }

    

    async handlSubmit() {
        let fields = ['Topics_Covered__c','SubTopics__c','Learning_Objectives__c','Learning_Outcomes__c'];
        let formInValid = false; 
        fields.forEach(field => {
            if(!this.asyncRecord[field]) {
                this.showHtmlMessage('Error','Please enter all the fields', 'error');
                formInValid = true;
            }
        });
        if(formInValid) {
            return false;
        }
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to update Async Record',
            variant: 'headerless',
            label: 'Confirm',
            // setting theme would have no effect
        });
        if(result) {
            let isSuccess = await this.updateAsync();
            if(isSuccess) {
                this.showHtmlMessage('Success','Async Record Successfuly Updated', 'success');
                this.isEdit = false;
            } else {
                this.showHtmlMessage('Error','Async Record Update Failed!', 'error');
            }
        }
        return true;
    }

    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }

}