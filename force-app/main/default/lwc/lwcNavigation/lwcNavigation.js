import { LightningElement, api } from 'lwc';

export default class LwcNavigation extends LightningElement {
    @api page;
    @api recordId;

    get checkAEPLiscencePage() {
        if(this.page === 'aepPurchaseLicense') {
            return true;
        }
        return false;
    }

    get checkAEPDeletedLeadPage() {
        if(this.page === 'aepDeletedLead') {
            return true;
        }
        return false;
    }

    get checkAEPSalesCadencePage() {
        if(this.page === 'salesCadence') {
            return true;
        }
        return false;
    }

    get checkAEPPaymentPage() {
        if(this.page === 'icTransactionDetails') {
            return true;
        }
        return false;
    }

    get checkemailListPage() {
        if(this.page === 'emailList') {
            return true;
        }
        return false;
    }

    get checklinkForDocumentsPage() {
        if(this.page === 'linkForDocuments') {
            return true;
        }
        return false;
    }

    get checkbachelorPage() {
        if(this.page === 'bachelorLeads') {
            return true;
        }
        return false;
    }

    get checkAssessmentPage() {
        if(this.page === 'createAssessment') {
            return true;
        }
        return false;
    }
    get ExamModelPage() {
        if(this.page === 'examModel') {
            return true;
        }
        return false;
    }
    get checkQuestionBankPage() {
        if(this.page === 'survayForm') {
            return true;
        }
        return false;
    }

    get checkOpportunityLineItemDataTablePage() {
        if(this.page === 'opportunityLineItemDataTable') {
            return true;
        }
        return false;
    }
}