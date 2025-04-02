public class nmDocVerificationlead
{

   //Define properties
    public Lead objLead{get;set;}
    public id LeadID{get;set;}
    public list<nm_LinksForDocumentsLead__c> lstLinkForDocumentLead{get;set;}
    public list<string> lststrEmail{get;set;}
    public boolean show{get;set;}
    public nmDocVerificationlead() 
    {
        objLead = new Lead();
        lststrEmail = new list<string>();
        lstLinkForDocumentLead = new list<nm_LinksForDocumentsLead__c>();
        show = false;
        if(ApexPages.currentPage().getParameters().get('id') != null)
            LeadID = ApexPages.currentPage().getParameters().get('id');
        
        if(LeadID != null)
        {
            list<Lead> lstLead = [select id, firstname, lastname, Email,nm_StudentStatus__c,nm_ReasonforProvisionalNoAdmission__c,
                                    (select id, nm_DocumentName__c, nm_DocumentLink__c, nm_ReasonforDisapprove__c,
                                    nm_Status__c, nm_URLforDocuments__c 
                                    from Links_For_Documents_Lead__r) 
                                    from Lead where id =: LeadID];
                                    
            if(lstLead != null && lstLead.size() > 0 && lstLead[0].nm_StudentStatus__c !='Not Eligible' )
            {
                objLead = lstLead[0];
                lststrEmail.add(objLead.Email);
               
                
                if(lstLead[0].Links_For_Documents_Lead__r!= null && lstLead [0].Links_For_Documents_Lead__r.size() > 0)
                {
                    lstLinkForDocumentLead =  lstLead[0].Links_For_Documents_Lead__r;
                }
            }
              else
            {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning,'You cannot verify these documents if student status is not eligible ');
                ApexPages.addMessage(myMsg);
            }
        }
      }  
      public PageReference ChangeDocumentsStatus()
    {
       ValidateDocumentStatusonLead();
       CheckLeadlevelDocument();
                
              
        return null;
    }
      public PageReference ValidateDocumentStatusonLead()
    {
      if (lstLinkForDocumentLead != null && lstLinkForDocumentLead .size() > 0) {
            for (nm_LinksForDocumentsLead__c objDocuments: lstLinkForDocumentLead ) {
                system.debug('sdssdsd' + objDocuments);
                if (objDocuments.nm_Status__c == 'Disapproved' && objDocuments.nm_DocumentLink__c != null) {
                    system.debug('enter in Reason null');

                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide reason for Disapprove ');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                if (objDocuments.nm_Status__c == 'Re-Submited' && objDocuments.nm_DocumentLink__c != null) {
                    system.debug('enter in Re-submitted');
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please Change status from Re-Submited');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
        }
        return null;
    
    }
     public Pagereference CheckLeadlevelDocument() {
       system.debug('enter in method');
        map < string, string > MapforDocumentStatus = new map < string, string > ();
        list < Lead > lstLead = new list < Lead > ();
        set < string > SetStatus = new set < string > ();
         MapforDocumentStatus.clear();
        if (lstLinkForDocumentLead.size() > 0) {
            for (nm_LinksForDocumentsLead__c objDocLead: lstLinkForDocumentLead ) {
                if (objDocLead.nm_Status__c == 'Disapproved') 
                {
                    SetStatus.remove(objDocLead.nm_Status__c );
                    MapforDocumentStatus.put('Disapproved', objDocLead.nm_DocumentName__c);
                    system.debug(' Disapproved MapforDocumentStatus'+MapforDocumentStatus);
                }
                if (objDocLead.nm_Status__c == 'Admission Form & Documents Provisional') {
                    if (string.valueof(objDocLead.nm_DocumentName__c).Contains('Aadhaar') || string.valueof(objDocLead.nm_DocumentName__c).Contains('Degree Certificate')) {
                        MapforDocumentStatus.put('Provisional', objDocLead.nm_DocumentName__c);
                    } else {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning, '' + objDocLead.nm_DocumentName__c + ' cannot be provisional');
                        ApexPages.addMessage(myMsg);
                        return null;

                    }
                }
                system.debug('lstLinkForDocumentLead'+lstLinkForDocumentLead);
                system.debug('status'+objDocLead.nm_Status__c);
                if (objDocLead.nm_Status__c =='Approved') {
                    SetStatus.add(objDocLead.nm_DocumentName__c);
                    system.debug('SetStatus' + SetStatus.size());
                    system.debug('lstLinkForDocumentLead ' + lstLinkForDocumentLead.size());

                }
                if (objDocLead.nm_Status__c == 'Not Applicable') {
                    MapforDocumentStatus.put('NotApplicable', objDocLead.nm_DocumentName__c);
                    system.debug('NotApplicable MapforDocumentStatus'+MapforDocumentStatus);
                }
                if (objDocLead.nm_Status__c == 'Re-Submited') {
                    MapforDocumentStatus.put('ReSubmited', objDocLead.nm_DocumentName__c);
                }

            }
            
            if (lstLinkForDocumentLead.size() == SetStatus.size()) {
                    system.debug('lstLinkForDocumentLead'+lstLinkForDocumentLead.size());
                    system.debug('SetStatus'+SetStatus.size());
                    objLead.nm_StudentStatus__c = 'Admission form & documents Approved';
             }
             
        
                if (MapforDocumentStatus.Containskey('Disapproved')) {
                    system.debug('enter in Disapproved');
                    objLead.nm_StudentStatus__c = 'Documents Disapproved';
                   }

                else if (MapforDocumentStatus.Containskey('Provisional')) {
                    objLead.nm_StudentStatus__c = 'Admission Form & Documents Provisional';
                }
                else if (MapforDocumentStatus.Containskey('NotApplicable')) {
                    objLead.nm_StudentStatus__c = 'Admission form & documents Approved';
                }

            
        }
        return null;

    }
        public PageReference save()
    {
        ValidateDocumentStatusonLead();
         if(lstLinkForDocumentLead != null && lstLinkForDocumentLead.size() >0)
        {
            for(nm_LinksForDocumentsLead__c  objDocuments : lstLinkForDocumentLead )
            {
                system.debug('sdssdsd'+objDocuments);
                if(objDocuments.nm_Status__c=='Disapproved' && objDocuments.nm_ReasonforDisapprove__c=='')
                {
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide reason for Disapprove ');
                     ApexPages.addMessage(myMsg);
                     return null;
                }
                 else if(objDocuments.nm_Status__c=='Admission Form & Documents Provisional' && objDocuments.nm_ReasonforDisapprove__c=='')
                {
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please provide reason for Disapprove ');
                     ApexPages.addMessage(myMsg);
                     return null;
                }
            }
          }
        if(lstLinkForDocumentLead != null && lstLinkForDocumentLead.size() >0)
        {
            set<string> setTotalApproved = new set<string>();
            for(nm_LinksForDocumentsLead__c objDocuments : lstLinkForDocumentLead )
            {
                if(objDocuments.nm_Status__c == 'Approved')
                setTotalApproved .add(objDocuments.nm_DocumentName__c);
                System.debug('objDocuments.nm_DocumentName__c+'+objDocuments.nm_DocumentName__c);
                System.debug('objDocuments.nm_DocumentLink__c +'+objDocuments.nm_DocumentLink__c );
                 if((objDocuments.nm_DocumentName__c == 'AIU Certificate (For Foreign University)' && objDocuments.nm_DocumentLink__c == null && objDocuments.nm_Status__c!='Not Applicable') 
                || (objDocuments.nm_DocumentName__c == 'Degree Certificate' && objDocuments.nm_DocumentLink__c == null))
                {
                    if(objLead.nm_StudentStatus__c == 'Admission form & documents Approved')
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning, 'AIU/Degree Certificate Documents are not available. You cannot approved the Admission.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }                              
            }
              if(lstLinkForDocumentLead.size() == setTotalApproved .size() && objLead.nm_StudentStatus__c == 'Not Eligible')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.warning,'All documents of this student are approved you cannot set status of this student \'Not eligible\'.');
                ApexPages.addMessage(myMsg);
                return null;
            } 
          
             
        }
        update objLead;
        update lstLinkForDocumentLead;
        
        return new PageReference('/'+LeadID);
    }
      public list<selectOption> getLstOptionStatus()
    {
        list<selectOption> lstOptionStatus1 = new list<selectOption>();         
        lstOptionStatus1.add(new selectOption('Documents Disapproved','Documents Disapproved'));      
        lstOptionStatus1.add(new selectOption('Admission form & documents Approved','Admission form & documents Approved'));
        lstOptionStatus1.add(new selectOption('Not Eligible','Not Eligible'));
        lstOptionStatus1.add(new selectOption('Admission Form & Documents Provisional','Admission Form & Documents Provisional'));  
        lstOptionStatus1.add(new selectOption('Documents incomplete','Documents incomplete'));
    
        
        return lstOptionStatus1;
    }
    
     public PageReference Back()
    {
       return new PageReference('/'+LeadID);
    }
  }