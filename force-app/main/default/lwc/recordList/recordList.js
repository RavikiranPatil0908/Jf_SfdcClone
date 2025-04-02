/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import getOpportunityList from '@salesforce/apex/SforceOpportunityRevisedController.getOpportunityList';  
import getOpportunityCount from '@salesforce/apex/SforceOpportunityRevisedController.getOpportunityCount';  
import getToken from '@salesforce/apex/SforceOpportunityRevisedController.getToken';  

export default class RecordList extends LightningElement {
	@track lstOpportunity;
	@track error;
	@api currentpage;
    @api pagesize;
    @api centerId;
    @api updateOpp;
    @api oppIdfound = false;
    @track countVal = 1;
    @track loadSpinner = false;
    @track generatedToken ='';
    @track searchFields = {
        studentNo:'',
        studentName:'',
        name: '',
        semester: '',
        session: '',
        year: '',
        oppStage:'',
        chooseProgram:''
    };
    @track showPopup = { title: '', message: '', variant: '' };
	totalpages;
	localCurrentPage = null;
	isSearchChangeExecuted = false;
	// not yet implemented
	@api pageSizeOptions = [
		{ label: '5', value: 5 },
		{ label: '10', value: 10 },
		{ label: '25', value: 25 },
		{ label: '50', value: 50 },
		{ label: '100', value: 100 }
    ];

    @track stage = [
        { label: 'Re-Registration Pending' , value: 'Re-Registration Pending'},
        { label: 'Pending Payment', value: 'Pending Payment' },
        { label: 'Closed Won - Re-registration Pending' , value: 'Closed Won - Re-registration Pending'}
    ];

    @track ChoosedPrograms = [
        { label: 'Post Graduate Diploma Programs', value: 'Post Graduate Diploma Programs' },
        { label: 'MBA (Distance) Programs' , value: 'MBA (Distance) Programs'},
        { label: 'Diploma Programs' , value: 'Diploma Programs'},
        { label: 'Certificate Programs' , value: 'Certificate Programs'},
        { label: 'Bachelor Programs' , value: 'Bachelor Programs'},
        { label: 'Professional Programs' , value: 'Professional Programs'}
    ]
    handleChange(event) {
		let field = event.target.name;
		if ({}.hasOwnProperty.call(this.searchFields, field)) {
			this.searchFields[field] = event.detail.value;
		}
    }

    handleChangeOnSize(event) {
        if(event.target.value !== this.pagesize) {
            this.pagesize = event.target.value;
            this.isSearchChangeExecuted = false;
            this.currentpage = 1;
            
            const newPageSize = new CustomEvent('changesize', {
                detail: this.pagesize
            });
            this.dispatchEvent(newPageSize);
        }
    }

    handleClick(event) {
        // event.preventDefault();
        let field = event.target.dataset.id;
        let studentNo = event.target.dataset.studentno;
        console.log('field value '+field);
        console.log('studentNo '+studentNo);
        
        if(field){
            let updateOpp =  this.lstOpportunity.filter(function(e) {
                return e.Id === field;
            });
            this.updateOpp = updateOpp[0];
            // this.oppIdfound = true;
            console.log('updateOpp '+JSON.stringify(this.updateOpp));
            const selectedEvent = new CustomEvent('selected', { detail: this.updateOpp });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }

        if(studentNo){
            this.getStudentDetais(studentNo);
        }
    }

    searchOpporutnity() {
        this.isSearchChangeExecuted = false;
        this.currentpage = 1;
    }

    clearSearchCriteria(){
        this.searchFields = {studentNo:'',studentName:'',name: '',semester: '',session: '',
                    year: '',oppStage:'', chooseProgram:''};
        this.isSearchChangeExecuted= false;
    }
    
    getStudentDetais(studentNumber){
        getToken({sapId : studentNumber})
        .then(result => {
            this.generatedToken= result;
            console.log('result '+JSON.stringify(this.generatedToken) );
            if(this.generatedToken){
                window.open("http://studentzone-ngasce.nmims.edu/studentportal/viewStudentDetailsDashBoard?sapId="+studentNumber+"&token="+this.generatedToken);
            }
        })
        .catch(error => {
            console.log("error", error);
            this.showHtmlMessage('Error!',error.body.message,'error');
        });
    }

	renderedCallback() {
        console.log('this.isSearchChangeExecuted ==>'+this.isSearchChangeExecuted);
		// This line added to avoid duplicate/multiple executions of this code.
		if (this.isSearchChangeExecuted && this.localCurrentPage === this.currentpage) {
			return;
        }
        // to load the spinner
        this.loadSpinner = true;
		this.isSearchChangeExecuted = true;
        this.localCurrentPage = this.currentpage;
        let searchKey = JSON.stringify(this.searchFields);
        console.log(searchKey);
        console.log(this.centerId);
		getOpportunityCount({ centerId: this.centerId, searchString: searchKey })
			.then((recordsCount) => {
				this.totalrecords = recordsCount;
				if (recordsCount !== 0 && !isNaN(recordsCount)) {
					this.totalpages = Math.ceil(recordsCount / this.pagesize);
					getOpportunityList({
						pagenumber: this.currentpage,
						numberOfRecords: recordsCount,
						pageSize: this.pagesize,
                        searchString: searchKey,
                        centerId: this.centerId
					})
						.then((opportunityList) => {
                            this.lstOpportunity = opportunityList;
                            console.log(JSON.stringify(this.lstOpportunity));
                            this.error = undefined;
                            this.loadSpinner = false;
						})
						.catch((error) => {
							this.error = error;
                            this.lstOpportunity = undefined;
                            console.log('error on list');
                            console.log(error);
                            this.loadSpinner = false;
                            this.showHtmlMessage('Invalid!',error,'error');
						});
				} else {
					this.lstOpportunity = [];
					this.totalpages = 1;
                    this.totalrecords = 0;
                    this.loadSpinner = false;
                    this.showHtmlMessage('No Record Found!','zero recod found','error');
				}
				const event = new CustomEvent('recordsload', {
					detail: recordsCount
				});
				this.dispatchEvent(event);
			})
			.catch((error) => {
				this.error = error;
                this.totalrecords = undefined;
                console.log('error on count');
                console.log(error);
                this.loadSpinner = false;
                this.showHtmlMessage('Invalid!',error,'error');
			});
    }
    
    // To show Toast message
	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
	}
}