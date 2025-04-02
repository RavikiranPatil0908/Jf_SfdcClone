import { LightningElement, api, track, wire } from 'lwc';
import KnowlarityAPIKey from '@salesforce/label/c.KnowlarityAPIKey';
import KnowlarityAuthKey from '@salesforce/label/c.KnowlarityAuthKey';
import SRNumber from '@salesforce/label/c.SR_Outbound_Number';
import getCounselorDetails from '@salesforce/apex/salesCadenceController.getCounselorDetails';

export default class UtilityCallPanel extends LightningElement {
    @api utilityPanel; //defaulted to false
    message;
    timer;
    timeVal = 0;
    myTimer;
    connectCall = false;
    agentNumber;
    isDisabled = true;
    comment;
    @track options = [];
    @api lead;

    get utilityPanelClass() {
        return this.utilityPanel === 'open' ? 
            'slds-utility-panel slds-grid slds-grid_vertical utilityPanel slds-is-open' :
            this.utilityPanel === 'hide' ? 
            'slds-utility-panel slds-grid slds-grid_vertical utilityPanel slds-is-closed' :
            'slds-utility-panel slds-grid slds-grid_vertical utilityPanel';
    }

    get checkSecondaryNo() {
        return this.lead.Phone ? true : false;
    }

    get primaryNumber() {
        return this.lead.MobilePhone;
    }

    get secondaryNumber() {
        return this.checkSecondaryNo ? this.lead.Phone : '';
    }

    get panelTitle() {
        return this.message ? `${this.lead.Name} - ${this.message}` : this.lead.Name;
    }

    get centerName() {
        return this.lead.nm_InformationCenter__r.Name;
    }

    @wire(getCounselorDetails,{centerId:'$centerName'})
    getCounselorDetails({ error, data}) {
        if(data) {
            if(data.length > 0) {
                data.forEach(element => {
                    const option = {
                        label: `${element.First_Name__c} ${element.Last_Name__c}`,
                        value: element.Agent_Number__c
                    }
                    this.options = [...this.options, option];
                });

                if(localStorage.getItem("agentNumber") != null) {
                    this.agentNumber = localStorage.getItem("agentNumber");
                    this.isDisabled = false;
                }
            }
        } else if (error) {
            console.error(error);
        }
    }

    // to hide the Panel
    handleEventClick = (event) => {
        let key = event.currentTarget.dataset.key;
        if(key === 'hide') {
            this.utilityPanel = 'hide';
        }
        else if(key === 'open') {
            this.utilityPanel = 'open';
        }
        else if(key === 'call') {
            this.clickToCall();
        }
        else if(key === 'close') {
            this.endCall();
        }
    }

    // to open the Panel
    toggleCallPanel = (val) => {
        this.utilityPanel = val;
    } 

    // to close the Panel.
    endCall = () => {
        this.utilityPanel = 'close';
        clearInterval(this.myTimer);
        this.timeVal = 0;
        this.timer = '';
        this.connectCall = false;
        if(this.comment) {
            this.pushUpdateEvent();
        }
        this.pushCloseEvent();
    }

    clickToCall = () => {
        if(this.utilityPanel === 'open') {
            let customerNumber = `+91${this.primaryNumber}`;
            // if (contactType === 2 && this.checkSecondaryNo) {
            //     customerNumber = '+91';
            //     if(this.lead.nm_STDCode__c && this.secondaryNumber.length == 8) {
            //         var code = parseInt(this.lead.nm_STDCode__c);
            //         var codeStr = code.toString();
            //         customerNumber = customerNumber + codeStr.slice(-2) + this.secondaryNumber.slice(-8);
            //     } else {
            //         customerNumber = customerNumber + this.secondaryNumber.slice(-10);
            //     }
            // }
            console.log('customerNumber ==>' + customerNumber);
            this.connectCall = true;
            const jsonBody = {'k_number': SRNumber, 'agent_number': this.agentNumber, 'customer_number': customerNumber};
            fetch('https://kpi.knowlarity.com/Basic/v1/account/call/makecall', {
                method:"POST",
                headers:{
                    "Content-Type": "application/json",
                    "x-api-key": KnowlarityAPIKey,
                    "authorization": KnowlarityAuthKey,
                },
                body: JSON.stringify(jsonBody)
            })
            .then((response) => {
                return response.json(); // returning the response in the form of JSON
            })
            .then((jsonResponse) => {
                console.dir(jsonResponse);
                if({}.hasOwnProperty.call(jsonResponse, 'success')) {
                    this.callId = jsonResponse.success.call_id;
                    this.message = 'Calling...';
                    // set timer...
                    this.setTimer();
                } else if({}.hasOwnProperty.call(jsonResponse, 'error'))  {
                    this.message = response.error.message;
                }
            })
            .catch(error => {
                console.log('callout error ===> '+JSON.stringify(error));
            })
        }
    }

    handleChange(event) {
        let field = event.target.dataset.field;
        if(field === 'counselor') {
            this.isDisabled = true;
            this.agentNumber = event.target.value;
            localStorage.setItem('agentNumber',this.agentNumber);
            if(this.agentNumber) {
                this.isDisabled = false; 
            }
        } else if(field === 'comment'){
            this.comment = event.target.value;
            console.log(this.comment);
        }
    }

    setTimer() {
        clearInterval(this.myTimer);
        this.myTimer = setInterval(() => {
            this.timeVal++;
            let minutes = Math.floor(this.timeVal / 60);
            let seconds = "0" + (this.timeVal - minutes * 60);
            this.timer = minutes.toString().substr(-2) + ":" + seconds.toString().substr(-2);
        }, 1000);
    }

    pushCloseEvent() {
        const event = new CustomEvent('change', {
            detail: {
                "check": "closed",
                "panel": "call"
            }
        });
        this.dispatchEvent(event);
    }

    pushUpdateEvent() {
        const event = new CustomEvent('change', {
            detail: {
                "check": "update",
                "panel": "call",
                "comment": this.comment,
            }
        });
        this.dispatchEvent(event);
        this.comment = '';
    }

}