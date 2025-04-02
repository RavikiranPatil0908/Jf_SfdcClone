public class nmDocVerification 
{
    //Define properties
    public Account objAccount{get;set;}
    public id AccountID{get;set;}
    public list<nm_LinksForDocuments__c> lstLinkForDocument{get;set;} 
    public list<string> lstCenterEmail{get;set;}
    public boolean show{get;set;}
    
    public nmDocVerification() 
    {
        objAccount = new Account();
      
        lstCenterEmail = new list<string>();
        lstLinkForDocument = new list<nm_LinksForDocuments__c>();
        show = false;
        if(ApexPages.currentPage().getParameters().get('id') != null)
            AccountID = ApexPages.currentPage().getParameters().get('id');
        
        if(AccountID != null)
         {
            GetDocumentRelatedData();                      
         }        
     }
    
    public void GetDocumentRelatedData()
    {
     list<Account> lstAcc = [select id, firstname, Owner.Email, lastname,nm_StudentStatus__c, nm_ReasonforProvisionalNoAdmission__c, PersonEmail,
                            (select id,DocumentQuerySubmitted__c, nm_DocumentName__c, nm_AccountEmail__c, nm_DocumentLink__c,Document_Query__c, nm_ReasonforDisapprove__c,
                             nm_Status__c, nm_URLforDocuments__c ,nm_URLforIncorrectDocuments__c from Links_For_Documents__r)
                            from Account where id =: AccountID];
                                                
            if(lstAcc != null && lstAcc.size() > 0 && lstAcc[0].nm_StudentStatus__c !='Not Eligible')
            {
                objAccount = lstAcc[0];
              
                if(lstAcc[0].Links_For_Documents__r != null && lstAcc[0].Links_For_Documents__r.size() > 0)
                {
                    lstLinkForDocument =  lstAcc[0].Links_For_Documents__r;
                }
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning,'You cannot verify these documents if student status is not eligible ');
                ApexPages.addMessage(myMsg);
            }
        }
    
    public PageReference ChangeDocumentsStatus()
    {
       
       
        // call method to validate Document Status if Document Status is Disapproved then Reason make Manadtory
        ValidateDocumentStatus();
        
     
       
        if(lstLinkForDocument != null && lstLinkForDocument.size() >0)
        {
            set<string> setDisapproved = new set<string>();
            set<string> setProvisional = new set<string>();
            set<string> setStatus = new set<string>();
            set<string> setApplicable = new set<string>();
            set<string> setResubmitted = new set<string>();
            set<string> setOfIncomplete = new set<string>();
            integer flag = 0;
            for(nm_LinksForDocuments__c objDocuments : lstLinkForDocument )
            {
                if(objDocuments.nm_Status__c == 'Disapproved')
                    setDisapproved.add(objDocuments.nm_DocumentName__c);
                
                if(objDocuments.nm_Status__c == 'Admission Form & Documents Provisional')
                {
                    if(string.valueof(objDocuments.nm_DocumentName__c).Contains('Aadhaar') || string.valueof(objDocuments.nm_DocumentName__c).Contains('Degree Certificate') ||string.valueof(objDocuments.nm_DocumentName__c).Contains('Degree Mark Sheet') )
                        setProvisional.add(objDocuments.nm_DocumentName__c); 
                    else
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning,'' + objDocuments.nm_DocumentName__c + ' cannot be provisional');
                        ApexPages.addMessage(myMsg);
                        return null;  
                    }
                }
                
                if(objDocuments.nm_Status__c == 'Approved')
                setStatus.add(objDocuments.nm_DocumentName__c);
                
                if(objDocuments.nm_Status__c != 'Disapproved')
                objDocuments.nm_ReasonforDisapprove__c = null;
                
                if(objDocuments.nm_Status__c == 'Not Applicable')
                setApplicable.add(objDocuments.nm_DocumentName__c);
                
                if(objDocuments.nm_Status__c == 'Re-Submited')
                setResubmitted.add(objDocuments.nm_DocumentName__c);
                
                if(objDocuments.nm_Status__c == 'Documents incorrect')
                {
                    setOfIncomplete.add(objDocuments.nm_DocumentName__c);
                }
                
                
            }
            
        /*    if(lstLinkForDocument.size() == setStatus.size())
                objAccount.nm_StudentStatus__c = 'Admission form & documents Approved';
            
          
           if(setResubmitted.size()>0)
            {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning,'Please Change the status from resubmitted');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            if(setDisapproved.size() > 0)
            {
                 objAccount.nm_StudentStatus__c = 'Documents Disapproved';
            }    
            if(setOfIncomplete.size()>0 && setDisapproved.size()==0 )  
            {
                objAccount.nm_StudentStatus__c = 'Registered'; 
            }                
            if(setProvisional.size() > 0  && setDisapproved.size()==0 && setOfIncomplete.size()==0)
            {
                objAccount.nm_StudentStatus__c = 'Admission Form & Documents Provisional';
            }
            else if(setApplicable.size()>0 && setDisapproved.size()==0 && setOfIncomplete.size()==0)
            {
                objAccount.nm_StudentStatus__c = 'Admission form & documents Approved';
            }*/
        
                
        }
        return null;
    }
    
    
    
    
    public PageReference save()
    {
        // call method to validate Document Status if Document Status is Disapproved then Reason make Manadtory
        ValidateDocumentStatus();
        String urlvalue;
        if(lstLinkForDocument != null && lstLinkForDocument.size() >0)
        {
            set<string> setTotalApproved = new set<string>();
            for(nm_LinksForDocuments__c objDocuments : lstLinkForDocument )
            {
                if(objDocuments.nm_Status__c == 'Approved')
                setTotalApproved .add(objDocuments.nm_DocumentName__c);
                System.debug('objDocuments.nm_DocumentName__c+'+objDocuments.nm_DocumentName__c);
                System.debug('objDocuments.nm_DocumentLink__c +'+objDocuments.nm_DocumentLink__c );
              /*  if((objDocuments.nm_DocumentName__c == 'AIU Certificate (For Foreign University)' && objDocuments.nm_DocumentLink__c == null && objDocuments.nm_Status__c!='Not Applicable') 
                || (objDocuments.nm_DocumentName__c == 'Degree Certificate' && objDocuments.nm_DocumentLink__c == null))
                {
                    if(objAccount.nm_StudentStatus__c == 'Admission form & documents Approved')
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning, 'AIU/Degree Certificate Documents are not available. You cannot approved the Admission.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                } */
                 if (objDocuments.nm_Status__c == 'Documents incorrect')
                    {                                          
                       if(objDocuments.nm_URLforDocuments__c!='' && objDocuments.nm_URLforDocuments__c!=null){
                           urlvalue = objDocuments.nm_URLforDocuments__c;
                           objDocuments.nm_URLforIncorrectDocuments__c = urlvalue;  
                           
                           if(objDocuments.nm_URLforIncorrectDocuments__c!='' &&  objDocuments.nm_URLforIncorrectDocuments__c !=null)
                           {
                                objDocuments.nm_URLforDocuments__c ='';
                           }
                                objDocuments.DocumentQuerySubmitted__c = System.Today();                       
                           }                                       
                    }                
            }
            
            if(lstLinkForDocument.size() == setTotalApproved .size() && objAccount.nm_StudentStatus__c == 'Not Eligible')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning,'All documents of this student are approved you cannot set status of this student \'Not eligible\'.');
                ApexPages.addMessage(myMsg);
                return null;
            }
             
        }
    
        update lstLinkForDocument;
       // update objAccount;
       // if(objAccount.nm_StudentStatus__c == 'Admission Form & Documents Provisional')
       // SendMail();
        
        return new PageReference('/'+AccountID);
    }
    
  /*  public void SendMail()
    {
        string strBody = 'Dear Student, <br/><br/>';
               strBody += 'Kindly visit the link http://ngasce.force.com/nmlogin for making the payment of Program fee.<br/>';
               strBody += 'Kindly forward the print of the Admission form with duly signed Declaration (included in the Admission form) to the Information center along with the Program fee payment acknowledgment receipt at the earliest.<br/>';
               strBody += 'You will have to submit the below mentioned documents to change your Admission status from Admission Form & Documents Provisional to Confirm Admission.<br/>';
               strBody += objAccount.nm_ReasonforProvisionalNoAdmission__c +'<br/><br/>';
               strBody += ' Thanks & regards,<br/><br/>';
               strBody += ' SVKM’s NMIMS';
        OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS Distance Education' LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(owe.id); 
      //  mail.setSenderDisplayName('NMIMS Admissions'); 
        mail.setCCAddresses(lstCenterEmail);
        mail.setToAddresses(lststrEmail);
        mail.setSubject('Provisional Admission');
        mail.setHtmlBody(strBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});    
    }
    
   */ 
   
       public void ValidateDocumentStatus()
       {
            if(lstLinkForDocument != null && lstLinkForDocument.size() >0)
            {
                for(nm_LinksForDocuments__c objDocuments : lstLinkForDocument )
                {
                    system.debug('sdssdsd'+objDocuments);
                    if(objDocuments.nm_Status__c=='Disapproved' && objDocuments.nm_ReasonforDisapprove__c=='')
                    {
                         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide reason for Disapprove ');
                         ApexPages.addMessage(myMsg);
                    }
                     if(objDocuments.nm_Status__c=='Re-Submited' )
                    {
                         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please Change status from Re-Submited');
                         ApexPages.addMessage(myMsg);
                    }
                     if(objDocuments.nm_Status__c=='Documents incorrect' && objDocuments.Document_Query__c=='')
                    {
                         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide Document Query');
                         ApexPages.addMessage(myMsg);
                    }
                }
            }
       }
    public list<selectOption> getLstOptionStatus()
    {
        list<selectOption> lstOptionStatus1 = new list<selectOption>();         
        lstOptionStatus1.add(new selectOption('Documents Disapproved', 'Documents Disapproved'));
        lstOptionStatus1.add(new selectOption('Admission form & documents Approved', 'Admission form & documents Approved'));
        lstOptionStatus1.add(new selectOption('Not Eligible', 'Not Eligible'));
        lstOptionStatus1.add(new selectOption('Admission Form & Documents Provisional', 'Admission Form & Documents Provisional'));
        lstOptionStatus1.add(new selectOption('Documents incorrect', 'Documents incorrect'));
        lstOptionStatus1.add(new selectOption('Registered', 'Registered'));
    
        
        return lstOptionStatus1;
    }

    public PageReference Back()
    {

        return new PageReference('/'+AccountID);
    }
    
}