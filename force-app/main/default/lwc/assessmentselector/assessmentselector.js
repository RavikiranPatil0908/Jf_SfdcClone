import { LightningElement, track, api, wire } from 'lwc';
import getActiveSurveys from '@salesforce/apex/AssesmentSurveyController.getActiveSurveys';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ExamsiteUrl from '@salesforce/label/c.Site_Url';
export default class AssessmentSelector extends LightningElement {
    @track isModalOpen = false;
    @track assessmentOptions = [];
    @track selectedAssessment='';
    @api recordId;
    
    siteUrl=ExamsiteUrl;

  
// Fetch active surveys from Apex
    @wire(getActiveSurveys)
    wiredSurveys({ error, data }) {
        if (data) {
            this.assessmentOptions = data.map(survey => ({
                label: survey.Name,
                value: survey.Id
            }));
        } else if (error) {
            console.error('Error fetching surveys:', error);
        }
    }
 
    openModal() {
        console.log('Open modal Clicked');
        this.isModalOpen = true;
    }
 
    closeModal() {
        this.isModalOpen = false;
    }
 
    handleChange(event) {
        this.selectedAssessment = event.detail.value;
    }
 
    handleSubmit() {
        console.log(`Submitting with Record Id: ${this.recordId}`);
        if (!this.selectedAssessment) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select an assessment before proceeding.',
                    variant: 'error'
                })
            );
            return;
        }
 
        let random = Math.random();
        let url = `${this.siteUrl}ExamPortal?id=${this.selectedAssessment}&CounselorId=${this.recordId}&random=${random}`;
        window.open(url, '_blank');
        this.closeModal();
    }
}