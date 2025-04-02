import { LightningElement, track, api, wire } from "lwc";
import First_Name from "@salesforce/schema/Lead.FirstName";
import Last_Name from "@salesforce/schema/Lead.LastName";
import EmailID from "@salesforce/schema/Lead.Email";
import MobilePhone from "@salesforce/schema/Lead.MobilePhone";
// import Information_Center from "@salesforce/schema/Lead.nm_InformationCenter__c";
import Lead_Source from "@salesforce/schema/Lead.LeadSource";
import Other_LeadSource from "@salesforce/schema/Lead.nm_OtherLeadSources__c";
import Lead_Status from "@salesforce/schema/Lead.Status";
import Lead_Description from "@salesforce/schema/Lead.Lead_Description__c";
import Reason_ForDeadLead from "@salesforce/schema/Lead.nm_Reason_for_Dead_Invalid_Leads__c";
import Choose_Program from "@salesforce/schema/Lead.nm_ChooseaProgram__c";
import Program from "@salesforce/schema/Lead.nm_Program__c";
import Lead_Action from "@salesforce/schema/Lead.Lead_Action__c";
import Counselor_Profile from "@salesforce/schema/Lead.Counselor_Profile__c";
import Gender from "@salesforce/schema/Lead.nm_Gender__c";
import DOB from "@salesforce/schema/Lead.nm_DateOfBirth__c";
import Stream from "@salesforce/schema/Lead.nm_Stream__c";
import Highest_Qualification from "@salesforce/schema/Lead.Highest_Qualification__c";
import Working from "@salesforce/schema/Lead.Working__c";
import Reason from "@salesforce/schema/Lead.Reason__c";
import WorkExperience from "@salesforce/schema/Lead.nm_WorkExperience__c";
import Industry from "@salesforce/schema/Lead.Industry";
import Designation from "@salesforce/schema/Lead.nm_Designation__c";
import Next_FollowUp from "@salesforce/schema/Lead.Next_Follow_up__c";
import Mother_Tongue from "@salesforce/schema/Lead.nm_Mother_Tongue__c";
import City_P from "@salesforce/schema/Lead.nm_City_P__c";
import Comment from "@salesforce/schema/Lead.Comment__c";
import getLeadsforRefresh from "@salesforce/apex/salesCadenceController.getLeadsforRefresh";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/pubsub";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class QuickLeadUpdate extends LightningElement {

    @track showPopup = { title: '', message: '', variant: '' };
    @track openmodel;
    @track refreshLeads;
    @api leadList;
    @wire(CurrentPageReference) pageRef;
    @api recordId;
    fields = [First_Name, Last_Name, EmailID, MobilePhone, Lead_Source, Other_LeadSource, Lead_Status,Lead_Description, 
              Reason_ForDeadLead, Choose_Program, Program, Lead_Action, Counselor_Profile, Gender, DOB, Stream, Highest_Qualification, 
              Working, Reason, WorkExperience, Industry, Designation, Next_FollowUp, Mother_Tongue, City_P, Comment];

    
    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        // this.openmodel = false;
        //dispatch a 'click' event so the parent component can handle it
        this.dispatchEvent(new CustomEvent("click", { detail: 'close' }));
    }

    onSubmitHandler(event){
        event.preventDefault();
        // Get data from submitted form
        const fields = event.detail.fields;
        // Here you can execute any logic before submit
        // and set or modify existing fields
        // fields.Name = fields.Name + fields.Phone
        // You need to submit the form after modifications
        this.template
            .querySelector('lightning-record-form').submit(fields);
        //alert("Successfully update !");
        this.getRefreshLeads();
        this.showHtmlMessage('Success','Successfully update !','success');
        // this.openmodal = false;
    }

     getRefreshLeads(){
        getLeadsforRefresh()
            .then((response) => {
                console.log('response '+JSON.stringify(response));
                this.refreshLeads = response;
                let updatedEvent = {
                    'leads' : this.refreshLeads,
                    'id' : this.leadList.Id
                };
                if (this.refreshLeads) {
                    fireEvent(this.pageRef, 'refreshLeadChangeEvent', updatedEvent);
                }
                this.closeModal();
            })
            .catch((error) => {
                // console.log('error occured ...'+error.body.message);
                this.showHtmlMessage('Error !', error, 'error');
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