import { LightningElement, api, track } from 'lwc';
import { formatDate } from 'c/formatedDate';

export default class UtilityHistoryPanel extends LightningElement {
    @api utilityPanel;
    @api hasRendered = 'load';
    @api increment;
    @track descriptions = [];
    leadDescription;
    showList = false;
    addComment = false;
    comment;

    connectedCallback(){
        this.setDescription(null);
        this.hasRendered = 'loaded';
    }

    renderedCallback() {
        console.log('rendered '+this.hasRendered);
        if(this.hasRendered === 'load' || this.hasRendered === 'reload') {
            this.setDescription(null);
            this.hasRendered = 'loaded';
            console.log('description load done');
        }
    }

    @api
    get leadDescription() {
        return this._leadDescription;
    }

    set leadDescription(value) {
        this._leadDescription = value;
    }

    get checkLoad() {
        return this.counter === this.increment ? true : false;
    }

    get utilityPanelClass() {
        return this.utilityPanel === 'open' ? 
            'slds-utility-panel slds-grid slds-grid_vertical utilityPanel slds-is-open' :
            this.utilityPanel === 'hide' ? 
            'slds-utility-panel slds-grid slds-grid_vertical utilityPanel slds-is-closed' :
            'slds-utility-panel slds-grid slds-grid_vertical utilityPanel';
    }

    // to toggle the Panel
    handleEventClick = (event) => {
        let key = event.currentTarget.dataset.key;
        let toggleOption = ['open','close','hide'];
        if(key && toggleOption.includes(key)) {
            this.utilityPanel = key;
            if(this.utilityPanel === 'close') {
                this.pushCloseEvent();
            }
        } else if(key === 'add') {
            this.addComment = true;
        } else if(key === 'save') {
            if(this.comment) {
                this.pushUpdateEvent();
            }
            this.addComment = false;
        } else if(key === 'refersh') {
            this.setDescription(null);
            this.hasRendered = 'loaded';
        }
    }

    handleChange(event) {
        this.comment = event.target.value;
    }

    @api setDescription(description) {
        if(description) {
            this.leadDescription = description;
        }
        console.log(this.leadDescription);
        if(this.leadDescription) {
            let arrayList = this.leadDescription.split('\n');
            if(arrayList.length > 0) {
                let response = this.formatList(arrayList);
                if(response.msg === 'success') {
                    this.createObject(response.list);
                } else  {
                    this.showList = false;
                }
            } 
        } else  {
            this.showList = false;
        }
        this.pushLoadEvent();
    }

    formatList(listOfComment) {
        let updatedList = [];
        let toSkip = -1;
        let headerCount = -1;
        let response = {list: [],msg: ''};
        try {
            for (let i = 0; i < listOfComment.length; i++) {
                if(i <= toSkip) {
                    continue;
                }
                let content = listOfComment[i];
                if(!content.includes('updated by')) {
                    let body = content;
                    let next = i + 1;
                    for(let j = next; j < listOfComment.length; j++) {
                        if(listOfComment[j].includes('updated by')) {
                            break;
                        }
                        body += "<br/>"+ listOfComment[j];
                        toSkip = j;
                    }
                    console.log(body);
                    updatedList.push(body);
                } else if(content.includes('updated by') && i != headerCount+1) {
                    updatedList.push(content);
                    headerCount = i;
                }
            }
            console.dir(updatedList);
            response.list = updatedList;
            response.msg = 'success';
        } catch (error) {
            response.list = [];
            response.msg = 'error';
            console.log(error);
        }
        return response;
    }

    createObject(description) {
        let objActivity = [];
        try {
            for (let i = 0; i < description.length; i++) {
                if (i === 0 || i % 2 === 0) {
                    let next = i + 1;
                    let header = description[next];
                    let headerArray = header.split('updated by');
                    let dateTime = headerArray[0];
                    // let momentDate = moment(dateTime,'YYYY-MM-DD HH:mm:ss');
                    let momentDate = new Date(dateTime);
                    // date = formatDate(momentDate,'MMMM dd, yyyy, h:mm t','');

                    const objDescription = {
                        header: headerArray[1],
                        date: formatDate(momentDate,'MMMM dd, yyyy, h:mm tt',''),
                        body: description[i],
                        id: i
                    };
                    objActivity.push(objDescription);
                }
            }
            objActivity.reverse();
            this.descriptions = objActivity;
            this.showList = true;
        } catch(error) {
            console.log(error);
            this.showList = false;
        }
    }

    // to send the parent that the component is closed.
    pushCloseEvent() {
        const event = new CustomEvent('change', {
            detail: {
                "check": "closed",
                "panel": "history"
            }
        });
        this.dispatchEvent(event);
    }

    // to send the parent that the data has been loaded.
    pushLoadEvent() {
        const event = new CustomEvent('change', {
            detail: {
                "check": "loaded",
                "panel": "history"
            }
        });
        this.dispatchEvent(event);
    }

    pushUpdateEvent() {
        const event = new CustomEvent('change', {
            detail: {
                "check": "update",
                "panel": "history",
                "comment": this.comment,
            }
        });
        this.dispatchEvent(event);
        this.comment = '';
    }
}