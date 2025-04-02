import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import getAccountDetails from "@salesforce/apex/lightningButtonController.getAccountDetails";
import getWorkExperience from "@salesforce/apex/lightningButtonController.getWorkExperience";
import getStudentRating from "@salesforce/apex/lightningButtonController.getStudentRating";
import getInterviewList from "@salesforce/apex/lightningButtonController.getInterviewList";
import onSubmitApproval from "@salesforce/apex/lightningButtonController.onSubmitApproval";
import Environment from '@salesforce/label/c.Environment';
import faCss from '@salesforce/resourceUrl/fontawesome_icons';
import { loadStyle } from 'lightning/platformResourceLoader';

const columns = [
    // { label: 'Start Date', fieldName: 'nm_StartDate__c', type: 'date' },
    // { label: 'End Date', fieldName: 'nm_EndDate__c', type: 'date' },
    {
        label: 'Company Name', fieldName: 'nm_CompanyName__c', type: 'text'},
    { label: 'Designation', fieldName: 'nm_Designation__c' },
    {
        label: 'Start Date', fieldName: 'nm_StartDate__c', type: 'text', type: "date",
        typeAttributes: {
            year: "numeric",
            month: "short",
            day: "2-digit"
        } },
    {
        label: 'End Date', fieldName: 'nm_EndDate__c', type: 'text', type: "date",
        typeAttributes: {
            year: "numeric",
            month: "short",
            day: "2-digit"
        } },
    // { label: 'Total Months', fieldName: 'nm_TotalMonths__c', type: 'text' },
    { label: 'Annual Income', fieldName: 'Annual_Income__c', type: 'text' },
];

const EducationColumn = [
    { label: 'Qualification', fieldName: 'Qualification' },
    { label: 'Percentage', fieldName: 'Percentage' },
    { label: 'Board', fieldName: 'Board' },
    { label: 'Year', fieldName: 'Year' }
]

const RatingColumn = [
    { label: 'Interview Date', fieldName: 'Interview_Date__c', type: 'date' },
    { label: 'Communications', fieldName: 'Question_1_Student_Rating__c' },
    { label: 'Motivation', fieldName: 'Question_2_Student_Rating__c' },
    { label: 'Achievements', fieldName: 'Question_3_Student_Rating__c' },
    { label: 'Score', fieldName: 'Question_4_Student_Rating__c' },
    { label: 'Recommended', fieldName: 'Question_5_Student_Rating__c' },
    { label: 'Total Score', fieldName: 'Total_Score__c' },
    { label: 'Interviewer Name', fieldName: 'Interviewer_Name__c' }
]

export default class StudentInterviewRating extends NavigationMixin(LightningElement) {
    @track showPopup = { title: '', message: '', variant: '' };
    @api parameters;
    @api recordId;
    objAccount = {};
    objStudentRating = {};
    @track programName = '';
    @track experienceRequired;
    @track percentageRequired;
    @track monthTotal;
    HSC = false;
    diploma = false;
    bachelor = false;
    data = [];
    workExperience = [];
    dataEducation = [];
    RatingData = [];
    columns = columns;
    EducationColumn = EducationColumn;
    RatingColumn = [];
    ic;
    lc;
    address;
    @track mapData = [];
    @track mapDataForOnHold = [];
    @track isModalOpen = false;
    @track isModalApproved = false;
    @track isModalReject = false;
    @track isModalOnHold = false;
    @track isModalReInterview = false;
    @track comment;
    @track idPresent;

    @track isRatingModalOpen = false;
    @track isRatingDocumentModalOpen = false;

    @track ratingCount = false;
    @track ratingCountForRecordId;
    @track ratingCountForDataMap;

    @track ratingDocument = false;

    @track isRatingDocumentReviewModalOpen = false;
    @track documentToShow;

    isReInterviewButtonVisible = false;


    RatingColumnObject = [];
    ratingTransData = [];

    lastRatingArrayOfRatingTransData = []

    ratingLastTransMap = {};

    accountCreatedDate = null;




    commentChange(event) {
        console.log('commentChange');

        this.comment = event.target.value;
        console.log(event.target.value)
        let approveButton = this.template.querySelector('.approvalButtonApprove');
        let rejectButton = this.template.querySelector('.approvalButtonReject');
        let errorText = this.template.querySelector('.errortext');
        console.log('hghgh')
        console.log(approveButton)
        console.log(rejectButton)
        console.log(errorText)
        if (rejectButton) {
            if (this.comment) {

                if (rejectButton) {
                    rejectButton.removeAttribute('disabled')
                }
                if (errorText) {
                    errorText.classList.remove("slds-has-error");
                }
            }
            else {
                console.log('inside false coo')
                if (rejectButton) {
                    rejectButton.setAttribute('disabled', '')
                }
                if (errorText) {
                    errorText.classList.add("slds-has-error");
                }
            }
        }




    }


    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "https://ngasce--sandbox--c.cs5.visual.force.com/apex/StudentInterviewRating"
            }
        });
    }
    openModalApprove() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.isModalApproved = true;
        this.isModalReject = false;
        this.isModalOnHold = false;
        this.isModalReInterview = false;


    }
    openModalReject() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.isModalApproved = false;
        this.isModalReject = true;
        this.isModalOnHold = false;
        this.isModalReInterview = false;
    }
    openModalOnHold() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.isModalApproved = false;
        this.isModalReject = false;
        this.isModalOnHold = true;
        this.isModalReInterview = false;

    }
    openModalReInterview() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.isModalApproved = false;
        this.isModalReject = false;
        this.isModalOnHold = false;
        this.isModalReInterview = true;
    }






    closeModal() {
        // to close modal set isModalOpen tarck value as false

        console.log('closedddddddddddddddddddddd')
        this.isModalOpen = false;
    }

    openRatingTable() {
        this.isRatingModalOpen = true;
    }
    closeRatingModal() {
        this.isRatingModalOpen = false;
    }
    openRatingDocument() {
        this.isRatingDocumentModalOpen = true;
    }
    closeRatingDocument() {
        this.isRatingDocumentModalOpen = false;
    }

    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        console.log(this.comment);
        console.log(this.recordId);
        let accountId = this.recordId ? this.recordId : this.tempRecordId;
        let approve = this.isModalApproved ? 'Selected' : this.isModalReject ? 'Rejected' : this.isModalOnHold ? 'On Waiting List' : 'Re-Interview';
        if (  (this.isModalApproved || this.isModalReject || this.isModalOnHold || this.isModalReInterview) && approve) {

            onSubmitApproval({ approve: approve, comment: this.comment, AccountId: accountId })
                .then((response) => {
                    console.log(response)
                    if (response != null) {
                        // navigateToWebPage();
                        this[NavigationMixin.GenerateUrl]({
                            type: 'standard__webPage',
                            attributes: {
                                url: ''
                            }
                        }).then(url => {
                            console.log(url)
                            window.open("/apex/StudentInterviewRating", "_self");
                        });
                        // this.showHtmlMessage("Success!", "Invoice Document updated successfully", "success");
                    }
                })
                .catch((error) => {
                    console.log(error);
                    // this.showHtmlMessage("Something went wrong.", error, "error");
                });

        }

    }
    handleNavigate() {
        // const config = {
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: 'http://salesforcecasts.com'
        //     }
        // };
        // this[NavigationMixin.Navigate](config);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: ''
            }
        }).then(url => {
            console.log(url)
            window.open("https://ngasce--sandbox--c.cs5.visual.force.com/apex/StudentInterviewRating", "_self");
        });

    }


    connectedCallback() {
        console.log('GGGGGG')
        if (this.parameters) {
            console.dir(this.parameters);
        }
        
        if (Object.prototype.hasOwnProperty.call(this.parameters, "id")) {
            this.recordId = this.parameters.id;
            // this.idPresent = this.recordId != 'random' ? true : false;
        }
        console.log(faCss + '/font-awesome-4.7.0/css/font-awesome.css')
        // let backDr = this.template.querySelector(`.slds-backdrop_open`)
        // this.template.addEventListener('click', evt => {
        //     console.log('event called')
        //     if (evt.target.slds - backDr) {
        //         closeModal()
        //     }
        // });
    }

    renderedCallback() {

        Promise.all([
            loadStyle(this, faCss + '/font-awesome-4.7.0/css/font-awesome.css')
        ]).then(() => {
            console.log('Files loaded');
        })
            .catch(error => {
                console.log(error.body.message);
            });


        console.log(this.objStudentRating.imageUpload__c, 'rating document');
        this.ratingDocument = this.objStudentRating.imageUpload__c ? true : false;




        if(this.mapData.length > 0) {
            this.recordId ? this.template.querySelector(`[data-id="${this.recordId}"]`).classList.add('slds-is-active') : this.template.querySelector(`[data-id="${this.mapData[0].key}"]`).classList.add('slds-is-active');
            
        } else {
            if(this.mapDataForOnHold .length > 0) {
                this.recordId ? this.template.querySelector(`[data-id="${this.recordId}"]`).classList.add('slds-is-active') : this.template.querySelector(`[data-id="${this.mapDataForOnHold[0].key}"]`).classList.add('slds-is-active');

            }
        }
        let elm = this.template.querySelector('table')
        console.log('elm')
        console.log(elm)

        let elme = this.template.querySelector(`[data-id-key="a"]`)
        console.log('elme')
        console.log(elme)
        console.log('elme')

        this.dataEducation.forEach(education => {
            if (parseInt(education.Percentage) >= parseInt(this.percentageRequired)) {
                this.template.querySelector(`[data-id-key="${education.id}"]`).classList.add('passColor')
            } else {
                this.template.querySelector(`[data-id-key="${education.id}"]`).classList.add('failColor')
            }
        });

        if (this.experienceRequired == 2) {
            if (this.monthTotal >= 24) {
                this.template.querySelector(`.monthTotal`).classList.add('passColor')
            } else {
                this.template.querySelector(`.monthTotal`).classList.add('failColor')
            }
        }
        if (this.experienceRequired == 3) {
            if (this.monthTotal >= 36) {
                this.template.querySelector(`.monthTotal`).classList.add('passColor')
            } else {
                this.template.querySelector(`.monthTotal`).classList.add('failColor')
            }
        }

        let Question_1_Student_Rating__c = this.template.querySelector('.Question_1_Student_Rating__c');
        let Question_2_Student_Rating__c = this.template.querySelector('.Question_2_Student_Rating__c');
        let Question_3_Student_Rating__c = this.template.querySelector('.Question_3_Student_Rating__c');
        let Question_4_Student_Rating__c = this.template.querySelector('.Question_4_Student_Rating__c');
        let Question_5_Student_Rating__c = this.template.querySelector('.Question_5_Student_Rating__c');
        let Total_Score__c = this.template.querySelector('.Total_Score__c');

        console.log('this.objStudentRating')
        console.log('Question_1_Student_Rating__c --> ' + Question_1_Student_Rating__c);
        console.log(this.objStudentRating)
        console.log(this.objStudentRating.Question_1_Student_Rating__c);

        if (this.objStudentRating.Question_1_Student_Rating__c) {
            console.log('inside this.objStudentRating.Question_1_Student_Rating__c --> ' + this.objStudentRating.Question_1_Student_Rating__c);
            if (parseInt(this.objStudentRating.Question_1_Student_Rating__c) > 4) {
                console.log('inside this.objStudentRating.Question_1_Student_Rating__c --> ');
                Question_1_Student_Rating__c.classList.add("passColor");
            } else {
                Question_1_Student_Rating__c.classList.add("failColor");
            }
        }
        if (this.objStudentRating.Question_2_Student_Rating__c) {
            if (parseInt(this.objStudentRating.Question_2_Student_Rating__c) > 4) {
                Question_2_Student_Rating__c.classList.add("passColor");
            } else {
                Question_2_Student_Rating__c.classList.add("failColor");
            }
        }
        if (this.objStudentRating.Question_3_Student_Rating__c) {
            if (parseInt(this.objStudentRating.Question_3_Student_Rating__c) > 4) {
                Question_3_Student_Rating__c.classList.add("passColor");
            } else {
                Question_3_Student_Rating__c.classList.add("failColor");
            }
        }
        if (this.objStudentRating.Question_4_Student_Rating__c) {
            if (parseInt(this.objStudentRating.Question_4_Student_Rating__c) > 4) {
                Question_4_Student_Rating__c.classList.add("passColor");
            } else {
                Question_4_Student_Rating__c.classList.add("failColor");
            }
        }
        if (this.objStudentRating.Total_Score__c) {
            if (parseInt(this.objStudentRating.Total_Score__c) > 4) {
                Total_Score__c.classList.add("passColor");
            } else {
                Total_Score__c.classList.add("failColor");
            }
        }

        if (this.objStudentRating.Question_5_Student_Rating__c) {
            if (this.objStudentRating.Question_5_Student_Rating__c == 'Yes') {
                Question_5_Student_Rating__c.classList.add("passColor");
            } else {
                Question_5_Student_Rating__c.classList.add("failColor");
            }
        }


        let backDr = this.template.querySelector(`.slds-backdrop_open`)
        console.log('backDr --> ' + backDr);
        // this.template.addEventListener('click', evt => {
        //     console.log('event called from rendered')
        //     console.log(evt.target)
        //     console.log(backDr)
        //     if (evt.target == backDr) {
        //         closeModal()
        //     }
        // });

        let textArea = this.template.querySelector(`[data-id="textareaForApproval"]`)
        if (this.isModalApproved && textArea) {
            textArea.value = 'Selected';
            this.comment = 'Selected';
        } else if (this.isModalOnHold && textArea) {
            textArea.value = 'On Hold';
            this.comment = 'On Hold'
        } else if (this.isModalReInterview && textArea) {
            textArea.value = 'Re-Interview';
            this.comment = 'Re-Interview';
        } else if (this.isModalReInterview && textArea) {
            textArea.value = 'Rejected';
            this.comment = 'Rejected';
        }

        let formatedUrl = this.template.querySelectorAll(`lightning-datatable`);
        console.log('formatedUrl length', formatedUrl.length)
        formatedUrl.forEach(el => {
            console.log('formatedUrl', el)
        })


    }

    @wire(getAccountDetails, { AccountId: "$recordId" })
    getAccountDetails({ error, data }) {
        console.log("enter for get course details " + this.recordId);
        if (data) {
            console.log(data)
            // console.log(JSON.stringify(data));
            this.objAccount = data[0];
            this.programName = this.objAccount.nm_Program__r.nm_ProgramName__c;
            this.experienceRequired = this.objAccount.nm_EligiblityCriteria__r.Experience_Required_In_Year__c;
            this.percentageRequired = this.objAccount.nm_EligiblityCriteria__r.Graduation_Percentage__c;

            this.HSC = this.objAccount.nm_Class12OrDiploma__c == 'XII/HSC' ? true : false;
            this.diploma = this.objAccount.nm_Class12OrDiploma__c == 'Diploma' ? true : false;
            this.bachelor = this.objAccount.nm_BachelorsDegreeName__c ? true : false;
            
            this.accountCreatedDate = this.objAccount.CreatedDate;
            console.log(this.accountCreatedDate, ' -- --createdDate');
            console.log(Environment);
            if (Environment == 'Sandbox') {
                this.address = this.objAccount.address__c.replaceAll('<br>', ',');
                
            } else if (Environment == 'Production') {
                this.address = this.objAccount.Address__c.replaceAll('<br>', ',');
            }
            this.ic = this.objAccount.IC_Name__c;
            this.lc = this.objAccount.LC_Name__c;
            this.dataEducation = [
                {
                    id: 'a',
                    Qualification: '10th',
                    Percentage: this.objAccount.nm_10thPercentage__c,
                    Board: this.objAccount.nm_NameofBoard__c == 'State Boards/Others' ? this.objAccount.nm_NameofStateBoard10th__c : this.objAccount.nm_NameofBoard__c,
                    Year: this.objAccount.nm_YearofCompletion__c,
                },
                {
                    id: 'b',
                    Qualification: '12th',
                    Percentage: this.objAccount.nm_12thPercentage__c,
                    Board: this.objAccount.nm_NameofBoard12__c == 'State Boards/Others' ? this.objAccount.nm_NameofStateBoard12th__c : this.objAccount.nm_NameofBoard__c,
                    Year: this.objAccount.nm_YearofCompletion12__c,
                },
                {
                    id: 'c',
                    Qualification: 'Diploma',
                    Percentage: this.objAccount.nm_ResultDiploma__c,
                    Board: this.objAccount.nm_DiplomaSchoolCollegeUniversityname__c,
                    Year: this.objAccount.nm_DiplomaYearOfCompletion__c,
                },
                {
                    id: 'd',
                    Qualification: this.objAccount.nm_BachelorsDegreeName__c,
                    Percentage: this.objAccount.Percentage_Bachlor__c,
                    Board: this.objAccount.nm_NameofUniversity__c,
                    Year: this.objAccount.nm_YearofCollegeCompletion__c,
                },
                {
                    id: 'e',
                    Qualification: this.objAccount.Name_of_Program1__c,
                    Percentage: this.objAccount.Percentage1__c	,
                    Board: this.objAccount.Name_of_University1__c,
                    Year: this.objAccount.Year_of_Passing1__c,
                },
                {
                    id: 'f',
                    Qualification: this.objAccount.Name_of_Program2__c,
                    Percentage: this.objAccount.Percentage2__c,
                    Board: this.objAccount.Name_of_University2__c,
                    Year: this.objAccount.Year_of_Passing2__c,
                },
                {
                    id: 'g',
                    Qualification: this.objAccount.Name_of_Program3__c,
                    Percentage: this.objAccount.Percentage3__c,
                    Board: this.objAccount.Name_of_University3__c,
                    Year: this.objAccount.Year_of_Passing3__c,
                },
            ];
            console.log(this.dataEducation);
            this.dataEducation = this.dataEducation.filter(value => value.Percentage)
            // this.dataEducation = this.HSC ? this.dataEducation.splice(2, 1) : this.dataEducation.splice(1,1);
            // this.dataEducation = this.bachelor ? this.dataEducation : this.dataEducation.splice(2,1);

        } else if (error) {
            console.error(error);
            this.showHtmlMessage("Something went wrong.", error, "error");
            // this.checkData = false;
        }
    }

    @wire(getWorkExperience, { AccountId: "$recordId" })
    getWorkExperience({ error, data }) {
        console.log("enter for get course details " + this.recordId);
        if (data) {
            console.log(data)
            // console.log(JSON.stringify(data));
            this.workExperience = data;
            this.monthTotal = 0;
            console.log('this')
            this.workExperience.forEach(work => {
                let workNumber = parseInt(work.nm_TotalMonths__c) ? parseInt(work.nm_TotalMonths__c) : 0;
                this.monthTotal = this.monthTotal + workNumber;
            });
        } else if (error) {
            console.error(error);
            this.showHtmlMessage("Something went wrong.", error, "error");
            // this.checkData = false;
        }
    }


    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }

    //#region ***************** RESIZABLE COLUMNS *************************************/
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log("handlemousedown this._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown this._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }

    handlemousemove(e) {
        console.log("mousemove this._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {

        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }

    @wire(getStudentRating, { AccountId: "$recordId" })
    getStudentRating({ error, data }) {
        console.log("enter for get course details " + this.recordId);
        if (data) {
            this.ratingCountForRecordId = data.length;
            this.ratingCount = this.ratingCountForRecordId > 1 ? true : false;
            this.RatingData = data;
            let ratCount = 0;
            this.RatingData.forEach(rat => {
                if (rat.is_Rating_For_New__c) {
                    ratCount ++ ;
                }
            })
            console.log('ratCount ======> ', ratCount);
            this.isReInterviewButtonVisible = ratCount > 1 ? false : true; 
            let horTable = this.RatingData;
            let varTable = [
                { id: '1', fieldName: 'Interview_Date__c', label: 'Interview Date' },
                { id: '2', fieldName: 'Question_1_Student_Rating__c', label: 'Communications' },
                { id: '3', fieldName: 'Question_2_Student_Rating__c', label: 'Motivation' },
                { id: '4', fieldName: 'Question_3_Student_Rating__c', label: 'Achievements' },
                { id: '5', fieldName: 'Question_4_Student_Rating__c', label: 'Score' },
                { id: '6', fieldName: 'Question_5_Student_Rating__c', label: 'Recommended' },
                { id: '7', fieldName: 'Total_Score__c', label: 'Total Score' },
                { id: '8', fieldName: 'Interviewer_Name__c', label: 'Interviewer Name' },
                { id: '9', fieldName: 'Q5_text__c', label: 'Reason', type: 'text' },
                { id: '10', fieldName: 'imageUpload__c', label: 'Document' }
            ]


            varTable.forEach((vertical, verticalIndex) => {
                horTable.forEach((horizontal, horizontalIndex) => {
                    if (vertical.fieldName == 'Interview_Date__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        let da = new Date(horizontal.Interview_Date__c);
                        da = da.toLocaleString('en-US', {
                            day: 'numeric',
                            year: 'numeric',
                            month: 'short',
                        });
                        varTable[verticalIndex][RatingNo] = horizontal.Interview_Date__c ? da : '';
                    }
                    if (vertical.fieldName == 'Question_1_Student_Rating__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Question_1_Student_Rating__c
                    }
                    if (vertical.fieldName == 'Question_2_Student_Rating__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Question_2_Student_Rating__c
                    }
                    if (vertical.fieldName == 'Question_3_Student_Rating__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Question_3_Student_Rating__c
                    }
                    if (vertical.fieldName == 'Question_4_Student_Rating__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Question_4_Student_Rating__c
                    }
                    if (vertical.fieldName == 'Question_5_Student_Rating__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Question_5_Student_Rating__c
                    }
                    if (vertical.fieldName == 'Total_Score__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Total_Score__c
                    }
                    if (vertical.fieldName == 'Interviewer_Name__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Interviewer_Name__c
                    }
                    if (vertical.fieldName == 'Q5_text__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        varTable[verticalIndex][RatingNo] = horizontal.Q5_text__c
                    }
                    if (vertical.fieldName == 'imageUpload__c') {
                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                        let RatingNoForDocument = RatingNo + 'a';
                        varTable[verticalIndex][RatingNoForDocument] = horizontal.imageUpload__c
                        varTable[verticalIndex][RatingNo] = 'Document - ' + Number(parseInt(horizontalIndex) + 1) 
                    }


                })
            })

            console.log('varTable')
            console.log(varTable)
            console.log('varTable')


            let varColumnObject = Object.keys(varTable[0]);
            let forDeletion = ['id', 'fieldName'];



            varColumnObject = varColumnObject.filter(item => !forDeletion.includes(item))

            console.log('varColumnObject')
            console.log(varColumnObject)
            console.log('varColumnObject')

            let varColumTable = [];

            varColumnObject.forEach(item => {
                varColumTable.push({ label: item, fieldName: item, wrapText: true })
            })

            
            console.log(varColumTable)
            this.RatingColumn = varColumTable;
            this.RatingData = varTable;
            this.RatingColumnObject = varColumnObject;

            let transdata = [];
            this.RatingData.forEach(rate => {
                let pu = [];
                varColumnObject.forEach(col => {
                    pu.push(rate[col]);
                })
                transdata.push(pu)
            })
            let lastArrayOfVarTable = varTable[varTable.length - 1];
            console.log(lastArrayOfVarTable)
            let lastArrayOfTransdata = transdata[transdata.length - 1];

            let lastTransMap = {};
            lastArrayOfTransdata.forEach((data, index) => {
                if(data.includes('-')) {
                    let lhs = data.replace('Document', 'Rating');
                    let rhs = lhs + 'a';
                    console.log(data, 'data')
                    console.log(lastArrayOfVarTable[lhs]);
                    console.log(lastArrayOfVarTable[rhs]);
                    
                    lastTransMap[lastArrayOfVarTable[lhs]] = lastArrayOfVarTable[rhs]
                }
            })

            console.log('lastTransMap')
            console.log(lastTransMap)
            console.log('lastTransMap')

            this.ratingLastTransMap = lastTransMap;


            this.ratingTransData = transdata;
            this.ratingTransData.splice(9, 1)

            this.lastRatingArrayOfRatingTransData = lastArrayOfTransdata;
            this.lastRatingArrayOfRatingTransData.splice(0, 1);
            console.log('lastRatingArrayOfRatingTransData', this.HSClastRatingArrayOfRatingTransData);
            console.log('transdata',transdata);
            console.log('this.ratingTransData', this.ratingTransData);
            if (data.length > 0) {

                this.objStudentRating = data[0];
                
            }

        } else if (error) {
            console.error(error);
            this.showHtmlMessage("Something went wrong.", error, "error");
            // this.checkData = false;
        }
    }

    @wire(getInterviewList)
    getInterviewList({ error, data }) {
        console.log("enter for get course details ");
        if (data) {
            console.log('this.datatattt')
            console.log(Object.keys(data).length);
            // console.log(JSON.stringify(data));
            this.idPresent = Object.keys(data).length > 0 ? true  : false;
            this.data = data;
            for (const [key, value] of Object.entries(this.data)) {
                console.log(key, value)
                console.log(value['lstAccount'].Name);
                this.mapData.push({
                    value: value['lstAccount'].Name,
                    key: value['lstAccount'].Id,
                    url: '/apex/StudentInterviewRating?id=' + value['lstAccount'].Id,
                    gender: value['lstAccount'].nm_Gender__c == 'Male' ? 'M' : value['lstAccount'].nm_Gender__c == 'Female' ? 'F' : 'O',
                    linkedin: value['lstAccount'].LinkedIn_URL__c,
                    ratingCount: value['totalRating'] > 1 ? value['totalRating'] : '',
                    interviewStatus: value['lstAccount'].Interview_Status__c,
                    age: value['lstAccount'].Age__c
                });
            }
            console.log("mapData for get course details ");
            console.log('mapData ---> ' + this.mapData)
            // console.log('mapData ---> ' + this.mapData[0].key)

            this.mapData.sort((a, b) => {
                if (a.interviewStatus < b.interviewStatus)
                    return -1;
                if (a.interviewStatus > b.interviewStatus)
                    return 1;
                return 0;
            })

            let lstWithoutWaitingList = [];

            this.mapData.forEach(item => {
                if (item.interviewStatus != 'On Waiting List') {
                    lstWithoutWaitingList.push(item);
                } else {
                    this.mapDataForOnHold.push(item);
                }
            })

            this.mapData = lstWithoutWaitingList;


            if (!this.recordId) {
                this.tempRecordId = this.mapData.length > 0 ? this.mapData[0].key : this.mapDataForOnHold[0].key ;
                this.ratingCountForDataMap = this.mapData.length > 0 ? this.mapData[0].ratingCount : this.mapDataForOnHold[0].ratingCount;
                this.ratingCount = this.ratingCountForDataMap > 1 ? true : false;

                getAccountDetails({ AccountId: this.mapData.length > 0 ? this.mapData[0].key : this.mapDataForOnHold[0].key })
                    .then(data => {
                        if (data) {
                            console.log(data)
                            // console.log(JSON.stringify(data));
                            this.objAccount = data[0];
                            this.programName = this.objAccount.nm_Program__r.nm_ProgramName__c;
                            this.experienceRequired = this.objAccount.nm_EligiblityCriteria__r.Experience_Required_In_Year__c;
                            this.percentageRequired = this.objAccount.nm_EligiblityCriteria__r.Graduation_Percentage__c;
                            this.HSC = this.objAccount.nm_Class12OrDiploma__c == 'XII/HSC' ? true : false;
                            this.diploma = this.objAccount.nm_Class12OrDiploma__c == 'Diploma' ? true : false;
                            this.bachelor = this.objAccount.nm_BachelorsDegreeName__c ? true : false;
                            this.accountCreatedDate = this.objAccount.CreatedDate;
                            console.log(this.accountCreatedDate, ' -- --createdDate');
                            this.ic = this.objAccount.IC_Name__c;
                            this.lc = this.objAccount.LC_Name__c;
                            if (Environment == 'Sandbox') {
                                this.address = this.objAccount.address__c.replaceAll('<br>', ',');

                            } else if (Environment == 'Production') {
                                this.address = this.objAccount.Address__c.replaceAll('<br>', ',');
                            }
                            
                            console.log('this.isReInterviewButtonVisible --> ', this.objAccount.AttemptForInterview__c);
                            console.log('this.isReInterviewButtonVisible --> ', this.isReInterviewButtonVisible);
                            this.dataEducation = [
                                {
                                    id: 'a',
                                    Qualification: '10th',
                                    Percentage: this.objAccount.nm_10thPercentage__c,
                                    Board: this.objAccount.nm_NameofBoard__c == 'State Boards/Others' ? this.objAccount.nm_NameofStateBoard10th__c : this.objAccount.nm_NameofBoard__c,
                                    Year: this.objAccount.nm_YearofCompletion__c,
                                },
                                {
                                    id: 'b',
                                    Qualification: '12th',
                                    Percentage: this.objAccount.nm_12thPercentage__c,
                                    Board: this.objAccount.nm_NameofBoard12__c == 'State Boards/Others' ? this.objAccount.nm_NameofStateBoard12th__c : this.objAccount.nm_NameofBoard__c,
                                    Year: this.objAccount.nm_YearofCompletion12__c,
                                },
                                {
                                    id: 'c',
                                    Qualification: 'Diploma',
                                    Percentage: this.objAccount.nm_ResultDiploma__c,
                                    Board: this.objAccount.nm_DiplomaSchoolCollegeUniversityname__c,
                                    Year: this.objAccount.nm_DiplomaYearOfCompletion__c,
                                },
                                {
                                    id: 'd',
                                    Qualification: this.objAccount.nm_BachelorsDegreeName__c,
                                    Percentage: this.objAccount.Percentage_Bachlor__c,
                                    Board: this.objAccount.nm_NameofUniversity__c,
                                    Year: this.objAccount.nm_YearofCollegeCompletion__c,
                                },
                                {
                                    id: 'e',
                                    Qualification: this.objAccount.Name_of_Program1__c,
                                    Percentage: this.objAccount.Percentage1__c	,
                                    Board: this.objAccount.Name_of_University1__c,
                                    Year: this.objAccount.Year_of_Passing1__c,
                                },
                                {
                                    id: 'f',
                                    Qualification: this.objAccount.Name_of_Program2__c,
                                    Percentage: this.objAccount.Percentage2__c,
                                    Board: this.objAccount.Name_of_University2__c,
                                    Year: this.objAccount.Year_of_Passing2__c,
                                },
                                {
                                    id: 'g',
                                    Qualification: this.objAccount.Name_of_Program3__c,
                                    Percentage: this.objAccount.Percentage3__c,
                                    Board: this.objAccount.Name_of_University3__c,
                                    Year: this.objAccount.Year_of_Passing3__c,
                                },
                            ];
                            console.log(this.dataEducation);
                            console.log(this.dataEducation);
                            console.log(this.dataEducation);
                            this.dataEducation = this.dataEducation.filter(value => value.Percentage)

                            let elm = this.template.querySelector(`[data-id="a"]`)
                            // let elm = this.template.querySelector(`[data-row-key-value="a"]`).querySelector(`[data-label="Percentage"]`).querySelector(`[data-label="Percentage"]`)
                            //     .querySelector(`.slds-grid_align-spread`).querySelector(`.slds-grid_align-spread`).querySelector(`.slds-truncate`)

                            console.log('elm')
                            console.log('elmfgg')
                            console.log(elm)
                            console.log('elmfgg')



                            // this.dataEducation = this.HSC ? this.dataEducation.splice(2, 1) : this.dataEducation.splice(1,1);
                            // this.dataEducation = this.bachelor ? this.dataEducation : this.dataEducation.splice(2,1);

                        }
                    }).catch((error) => {
                        console.log(error);
                        this.showHtmlMessage('Something went wrong.', error, 'error');
                    });

                getStudentRating({ AccountId: this.mapData.length > 0 ? this.mapData[0].key : this.mapDataForOnHold[0].key })
                    .then(data => {
                        if (data) {
                            this.RatingData = data;
                            let ratCount = 0;
                            this.RatingData.forEach(rat => {
                                if (rat.is_Rating_For_New__c) {
                                    ratCount++;
                                }
                            })
                            console.log('ratCount ======> ', ratCount);
                            this.isReInterviewButtonVisible = ratCount > 1 ? false : true; 
                            let horTable = this.RatingData;
                            let varTable = [
                                { id: '1', fieldName: 'Interview_Date__c', label: 'Interview Date' },
                                { id: '2', fieldName: 'Question_1_Student_Rating__c', label: 'Communications' },
                                { id: '3', fieldName: 'Question_2_Student_Rating__c', label: 'Motivation' },
                                { id: '4', fieldName: 'Question_3_Student_Rating__c', label: 'Achievements' },
                                { id: '5', fieldName: 'Question_4_Student_Rating__c', label: 'Score' },
                                { id: '6', fieldName: 'Question_5_Student_Rating__c', label: 'Recommended' },
                                { id: '7', fieldName: 'Total_Score__c', label: 'Total Score' },
                                { id: '8', fieldName: 'Interviewer_Name__c', label: 'Interviewer Name' },
                                { id: '9', fieldName: 'Q5_text__c', label: 'Reason', type: 'text' },
                                { id: '10', fieldName: 'imageUpload__c', label: 'Document' }
                            ]


                            console.log('ffffffffffffffffff')
                            varTable.forEach((vertical, verticalIndex) => {
                                horTable.forEach((horizontal, horizontalIndex) => {
                                    if (vertical.fieldName == 'Interview_Date__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        let da = new Date(horizontal.Interview_Date__c);
                                        da = da.toLocaleString('en-US', {
                                            day: 'numeric',
                                            year: 'numeric',
                                            month: 'short',
                                        });
                                        varTable[verticalIndex][RatingNo] = horizontal.Interview_Date__c ? da : '';
                                    }
                                    if (vertical.fieldName == 'Question_1_Student_Rating__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Question_1_Student_Rating__c
                                    }
                                    if (vertical.fieldName == 'Question_2_Student_Rating__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Question_2_Student_Rating__c
                                    }
                                    if (vertical.fieldName == 'Question_3_Student_Rating__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Question_3_Student_Rating__c
                                    }
                                    if (vertical.fieldName == 'Question_4_Student_Rating__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Question_4_Student_Rating__c
                                    }
                                    if (vertical.fieldName == 'Question_5_Student_Rating__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Question_5_Student_Rating__c
                                    }
                                    if (vertical.fieldName == 'Total_Score__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Total_Score__c
                                    }
                                    if (vertical.fieldName == 'Interviewer_Name__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Interviewer_Name__c
                                    }
                                    if (vertical.fieldName == 'Q5_text__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        varTable[verticalIndex][RatingNo] = horizontal.Q5_text__c
                                    }
                                    if (vertical.fieldName == 'imageUpload__c') {
                                        let RatingNo = 'Rating - ' + Number(parseInt(horizontalIndex) + 1);
                                        let RatingNoForDocument = RatingNo + 'a';
                                        varTable[verticalIndex][RatingNoForDocument] = horizontal.imageUpload__c
                                        varTable[verticalIndex][RatingNo] = 'Document - ' + Number(parseInt(horizontalIndex) + 1)
                                    }


                                })
                            })

                            console.log('varTable')
                            console.log(varTable)
                            console.log('varTable')


                            let varColumnObject = Object.keys(varTable[0]);
                            let forDeletion = ['id', 'fieldName'];



                            varColumnObject = varColumnObject.filter(item => !forDeletion.includes(item))

                            console.log('varColumnObject')
                            console.log(varColumnObject)
                            console.log('varColumnObject')

                            let varColumTable = [];

                            varColumnObject.forEach(item => {
                                varColumTable.push({ label: item, fieldName: item, wrapText: true })
                            })


                            console.log(varColumTable)
                            this.RatingColumn = varColumTable;
                            this.RatingData = varTable;
                            this.RatingColumnObject = varColumnObject;

                            let transdata = [];
                            this.RatingData.forEach(rate => {
                                let pu = [];
                                varColumnObject.forEach(col => {
                                    pu.push(rate[col]);
                                })
                                transdata.push(pu)
                            })
                            let lastArrayOfVarTable = varTable[varTable.length - 1];
                            console.log(lastArrayOfVarTable)
                            let lastArrayOfTransdata = transdata[transdata.length - 1];

                            let lastTransMap = {};
                            lastArrayOfTransdata.forEach((data, index) => {
                                if (data.includes('-')) {
                                    let lhs = data.replace('Document', 'Rating');
                                    let rhs = lhs + 'a';
                                    console.log(data, 'data')
                                    console.log(lastArrayOfVarTable[lhs]);
                                    console.log(lastArrayOfVarTable[rhs]);

                                    lastTransMap[lastArrayOfVarTable[lhs]] = lastArrayOfVarTable[rhs]
                                }
                            })

                            console.log('lastTransMap')
                            console.log(lastTransMap)
                            console.log('lastTransMap')

                            this.ratingLastTransMap = lastTransMap;


                            this.ratingTransData = transdata;
                            this.ratingTransData.splice(9, 1)

                            this.lastRatingArrayOfRatingTransData = lastArrayOfTransdata;
                            this.lastRatingArrayOfRatingTransData.splice(0, 1);
                            console.log('lastRatingArrayOfRatingTransData', this.HSClastRatingArrayOfRatingTransData);
                            console.log('transdata', transdata);
                            console.log('this.ratingTransData', this.ratingTransData);
                            if (data.length > 0) {

                                this.objStudentRating = data[0];

                            }

                        } else if (error) {
                            console.error(error);
                            this.showHtmlMessage("Something went wrong.", error, "error");
                            // this.checkData = false;
                        }
                    }).catch((error) => {
                        console.log(error);
                        this.showHtmlMessage('Something went wrong.', error, 'error');
                    });


                getWorkExperience({ AccountId: this.mapData.length > 0 ? this.mapData[0].key : this.mapDataForOnHold[0].key })
                    .then(data => {
                        if (data) {
                            console.log(data)
                            // console.log(JSON.stringify(data));
                            this.workExperience = data;
                            this.monthTotal = 0;
                            this.workExperience.forEach(work => {
                                let workNumber = parseInt(work.nm_TotalMonths__c) ? parseInt(work.nm_TotalMonths__c) : 0;

                                this.monthTotal = this.monthTotal + workNumber;
                            });
                        }
                    }).catch((error) => {
                        console.log(error);
                        this.showHtmlMessage('Something went wrong.', error, 'error');
                    });
            }


            // getAccountDetails(this.mapData[0].key)
            // console.log('https://ngasce--sandbox--c.cs5.visual.force.com/apex/StudentInterviewRating?id=' + this.mapData[0].key)
            // window.open('https://ngasce--sandbox--c.cs5.visual.force.com/apex/StudentInterviewRating?id=' + this.mapData[0].key );
            console.log(this.mapData)
            console.log('JSON.stringify(this.parameters)')
            console.log(JSON.stringify(this.parameters))
        } else if (error) {
            console.error(error);
            this.showHtmlMessage("Something went wrong.", error, "error");
            // this.checkData = false;
        }
    }


    ratingDocumentButton(event) {
        let value = event.currentTarget.dataset.button;
        this.ratingLastTransMap;
        if (this.ratingLastTransMap[value]) {
            console.log(this.ratingLastTransMap[value], 'ratingDocumentButton')
            this.documentToShow = this.ratingLastTransMap[value];
            this.isRatingDocumentReviewModalOpen = true;
        }
    }
    closeRatingDocumentReviewModal() {
        this.isRatingDocumentReviewModalOpen = false;
    }

    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}