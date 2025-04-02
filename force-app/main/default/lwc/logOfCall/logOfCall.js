import { LightningElement, api, wire, track } from 'lwc';
// import getLeadRecord from '@salesforce/apex/salesCadenceController.getLeadRecord';
import fetchPickListValue from '@salesforce/apex/salesCadenceController.fetchPickListValue';
import saveTask from '@salesforce/apex/salesCadenceController.saveTask'

export default class LogOfCall extends LightningElement {
    @api recordId;
    @api leadDetail;
    @api enableEdit = false;
    @api typeOfTask;
    @api leadName;
    @track task = {
        WhoId : this.recordId,
        Subject: '',
        Description: '',
        ActivityDate: '',
        Type: '',
        TaskSubtype: '',
        Status: ''
    };
    @track subjectOptions  = [ { label: '--None--', value: '' } ];
    @track statusOptions = [ { label: '--None--', value: '' } ];

    renderedCallback() {
        if(this.typeOfTask === 'Call') {
            this.task.TaskSubtype = this.typeOfTask;
            this.task.Type = this.typeOfTask;
            this.task.Subject = this.typeOfTask;

            // to set the due date on log of call. 
            let current_datetime = new Date()
            let formatted_date = current_datetime.getFullYear() + "-" + this.getMonth(current_datetime) + "-" + current_datetime.getDate();
            this.task.ActivityDate = formatted_date;

        } else if(this.typeOfTask === 'Task') {
            this.task.Status = 'Not Started';
        }
    }

    get isCall() {
        return this.typeOfTask === "Call";
    }

    @wire(fetchPickListValue, { objInfo: {'sobjectType' : 'Task'}, picklistFieldApi: 'Subject'}) 
    subjectNameValues({error, data}) {
        if(data) {
            console.log(data);
            for (const list of data) {
				const option = {
					value: list.svalue,
					label: list.slabel
				};
				this.subjectOptions = [ ...this.subjectOptions, option ];
			}
        } else if (error) {
            console.error(error);
        }
    }

    @wire(fetchPickListValue, { objInfo: {'sobjectType' : 'Task'}, picklistFieldApi: 'Status'}) 
    statusNameValues({error, data}) {
        if(data) {
            console.log(data);
            for (const list of data) {
				const option = {
					value: list.svalue,
					label: list.slabel
				};
				this.statusOptions = [ ...this.statusOptions, option ];
			}
        } else if (error) {
            console.error(error);
        }
    }

    handleChange(event) {
		let field = event.target.dataset.field;
		if ({}.hasOwnProperty.call(this.task, field)) {
			this.task[field] = event.detail.value;
		}
	}

    // to validate the form.
	formValidate() {
		const allValid = [
			...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-radio-group')
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		return allValid;
	}
    
    handleClick() {
        if (!this.formValidate()) {
			return;
		}
        this.task.WhoId = this.recordId;
        console.log(this.task);
        saveTask({ objTask: this.task })
            .then((result) => {
                if (result != null) {
                    console.log('result ==>');
                    console.log(result);
                    this.updateChange();
                    this.toggeleEditOption();
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }

    updateChange() {
        const filterChangeEvent = new CustomEvent('change', {
            detail: {
                "taskAdded":true,
            }
        });
        this.dispatchEvent(filterChangeEvent);
    }
 
    toggeleEditOption() {
        this.enableEdit = !this.enableEdit;
    }

    getMonth(date) {
        let month = date.getMonth() + 1;
        return month < 10 ? '0' + month : '' + month; // ('' + month) for string result
    }  
}