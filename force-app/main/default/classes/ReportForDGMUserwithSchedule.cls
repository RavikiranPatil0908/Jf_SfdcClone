/**
 * @File Name          : ReportForDGMUserwithSchedule.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 06-04-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    1/2/2020   @BK     Initial Version
**/

public  class ReportForDGMUserwithSchedule implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public void execute(SchedulableContext sc) {
        ReportForDGMUserwithSchedule b = new ReportForDGMUserwithSchedule();
        Database.executebatch(b, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('ReportForDGMUserwithSchedule started');
        // String agencyId = 'a13O00000060eMP';
        String query = 'select id,Name,Email__c,Report_Id__c,Agency_Name__c ,EmailIdSet__c from Agency_Access__c where  Report_Id__c!= null and Email__c!=null and ScheduleReport__c =true and Agency_Name__c!=null';
         
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
      List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
      if(scope.size() > 0) { 
          system.debug('scope.size()==> ' + scope.size());
            for(SObject sc : scope){
                Agency_Access__c objagency = (Agency_Access__c)sc;
                if(String.isNotBlank(objagency.EmailIdSet__c)) {
                    Messaging.SingleEmailMessage objMssg = new Messaging.SingleEmailMessage ();
                    objMssg =  SendEmailMethod(objagency.Report_Id__c,objagency.EmailIdSet__c,objagency.Agency_Name__c,objagency.Name); 
                    lstMails.add(objMssg);
                }
                

            }
        } else {
            System.debug('No records found.');
        }
          system.debug('lstMails--->'+lstMails);
         if(lstMails.size()>0)
         {
             Messaging.sendEmail(lstMails);
         }
    }

    public void finish(Database.BatchableContext bc) {
    }
    public static Messaging.SingleEmailMessage SendEmailMethod(String ReportId,String SetEmail, String AgencyName,String Name){
       Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();   
        ApexPages.PageReference report1;
            Date today = Date.Today(); 
            if(Name=='Logistic Department')
            {
                report1 = new ApexPages.PageReference('/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId='+ReportId); 
                String reportName = AgencyName+'_'+today+'.xlsx';                   
                efa.setFileName(reportName);
                 efa.setContentType('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            }else{
            
                report1 = new ApexPages.PageReference('/'+ReportId+'?csv=1'); 
                String reportName = AgencyName+'.csv';
                efa.setFileName(reportName);
               efa.setContentType('text/csv');

    }
        
       
        if(Test.isRunningTest()) { 
          efa.setBody(Blob.valueof('Unit.Test'));
        } else {
        
            if(Name=='Logistic Department')
            {
                 efa.setBody(report1.getContent());
            }else{
                efa.setBody(Blob.valueof(report1.getContent().toString()));
            }        
              
        }           
            //  efa.setContentType('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');


        string subject = AgencyName+' '+today;
        string  body = 'Kindly check the attachment';
        string[] address = SetEmail.split(',');
        String[] sendingToBCCAddress = new List<String>{'suyog.deshmukh.ext@nmims.edu'};
        OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
        Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
        Emailwithattch.setSubject(subject);
        Emailwithattch.setOrgWideEmailAddressId(owe.id); 
        Emailwithattch.setToaddresses(address);
        Emailwithattch.setBccAddresses(sendingToBCCAddress);
        Emailwithattch.setReplyTo(owe.Address);
        //Emailwithattch.setSenderDisplayName('NMIMS Distance Education');
        Emailwithattch.setPlainTextBody(body);            
        Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
        return Emailwithattch;
    }
  }