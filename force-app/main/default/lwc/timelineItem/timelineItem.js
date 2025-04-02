import { LightningElement, api, track, wire } from 'lwc';
import getEmailDetails from '@salesforce/apex/salesCadenceController.getEmailDetails';
import CURRENT_USER_ID from '@salesforce/user/Id';
import { formatDate } from 'c/formatedDate';

export default class TimelineItem extends LightningElement {
    @api task;
    @api recordId;
    @api description;
    @track expanded;
    @api assignedToName;
    @api ownerId;
    @api whoId;
    @api whoToName;

    @wire(getEmailDetails,{taskId:'$recordId'})
    emailMessage ({ error, data }) {
        if (data) {
            console.log(data);
            this.assignedToName=this.task.OwnerId===CURRENT_USER_ID?'You':data.FromName;
            this.description=data.TextBody;
            let emailRelations = data.EmailMessageRelations;
            if(emailRelations && emailRelations.length>=1){
                emailRelations.forEach(element => {
                    if(element.RelationType === 'ToAddress') {
                        this.whoToName=element.Relation.Name;
                        this.whoId=element.RelationId;
                        this.ownerId=element.RelationId;
                    }
                });
            }
        } 
    };

    get itemStyle() {
        if(this.task.TaskSubtype === "Task"){
            return this.expanded ? "slds-timeline__item_expandable slds-timeline__item_task slds-is-open" : "slds-timeline__item_expandable slds-timeline__item_task";
        }else if(this.task.TaskSubtype === "Call"){
            return this.expanded ? "slds-timeline__item_expandable slds-timeline__item_call slds-is-open" : "slds-timeline__item_expandable slds-timeline__item_call";
        }else if(this.task.TaskSubtype === "Email"){
            return this.expanded ? "slds-timeline__item_expandable slds-timeline__item_email slds-is-open" : "slds-timeline__item_expandable slds-timeline__item_email";
        }else{
            return this.expanded ? "slds-timeline__item_expandable slds-is-open" : "slds-timeline__item_expandable";
        }
        
    }

    get iconName(){
        if(this.task.TaskSubtype === "Call"){
            return "standard:log_a_call"
        }else if(this.task.TaskSubtype === "Email"){
            return "standard:email";
        }else{
            return "standard:task";
        }
    }

    get dateValue(){
        let date = new Date(this.task.CreatedDate);
        return formatDate(date,'h:mmtt | d/M/yy','');
    }

    get isCall(){
        return this.task.TaskSubtype === "Call";
    }

    get isEmail(){
        return this.task.TaskSubtype === "Email";
    }

    get isTask(){
        if(!this.isCall && !this.isEmail) {
            return true;
        } else {
            return false;
        }
    }

    get isFutureTask(){
        var dtVal = Date.parse(this.task.ActivityDate);
        return dtVal > new Date().getTime();
    }

    get hasWhoTo(){
        return this.whoId!=null;
    }

    get activityDate() {
        var dtVal = new Date(this.task.ActivityDate);
        return formatDate(dtVal,'MMMM dd, yyyy','');
    }

    toggleDetailSection() {
        this.expanded = !this.expanded;
    }
}