/**
 * @File Name          : lightningButtonController.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 13-09-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    26/3/2020   shubhranshu     Initial Version
**/
public without sharing class lightningButtonController {
    
    public User userObj {get;set;}
    public List<User> lst{get;set;}
    public lightningButtonController(){
        userObj = new User();
        lst = new List<User>();
    }
    @AuraEnabled(Cacheable = true)
    public static String getObjectApiNameUsingRecordId(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        return sObjName;
    }

    @AuraEnabled  
    public static Map<String,String> getPickListValuesForChooseProg(String choosedProgValue){
        Map<String,String> pickMapOfListValues = new  Map<String,String>();
        System.debug('choosedProgValue '+choosedProgValue );
        if(String.isNotBlank(choosedProgValue)){
            List<nm_Program__c> lstActiveProgram = [SELECT id,nm_ProgramName__c FROM nm_Program__c WHERE nm_Type__c=:choosedProgValue AND nmIsActive__c=true ORDER BY Name ASC];
            System.debug('lstActiveProgram--'+lstActiveProgram);
            if(lstActiveProgram.size() > 0){
                for(nm_Program__c objProgram : lstActiveProgram){
                    pickMapOfListValues.put(objProgram.Id,objProgram.nm_ProgramName__c);
                }
            }
        }
        System.debug('pickMapOfListValues '+pickMapOfListValues);
        return pickMapOfListValues;
    }

    @AuraEnabled         
    public static Map<Id,String> getEligiblityCriteria(String choosedProgValue){
        Map<Id,String> pickMapOfListValuesForEliCriteria = new  Map<Id,String>();
        if(String.isNotBlank(choosedProgValue)){
            List<nm_EligiblityCriteria__c> lstActiveEligibleCriteria = [SELECT Id,nm_EligiblityCriteria__c FROM nm_EligiblityCriteria__c WHERE nm_Program__c=:choosedProgValue AND Is_Active__c=true ORDER BY Name ASC];
            System.debug('lstActiveEligibleCriteria without program type--'+lstActiveEligibleCriteria);
            if(lstActiveEligibleCriteria.size() > 0){
                for(nm_EligiblityCriteria__c objELi : lstActiveEligibleCriteria){
                    pickMapOfListValuesForEliCriteria.put(objELi.Id,objELi.nm_EligiblityCriteria__c);
                }
            }
        }  
        return pickMapOfListValuesForEliCriteria;
    }

    @AuraEnabled
    public static Lead saveLeadDetails(Lead lead){
        
        try{    
            insert lead;
            System.debug('objLead is inserted ...');
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return lead;
    }

    @AuraEnabled(Cacheable = true)  
    public static nm_UserMapping__c getCenterUserData(String userId) {
    
        nm_UserMapping__c centerUser = new nm_UserMapping__c();
        try{
            System.debug('userId -->'+userId);
            List<nm_UserMapping__c> lstcenterDetails = [SELECT Id, nm_Centers__c, nm_Centers__r.Name,
            nm_Centers__r.Center_Name__c,nm_Centers__r.Allow_Bachelor__c,nm_Head__c,UserId__c,nm_Centers__r.Password__c FROM nm_UserMapping__c WHERE 
            UserId__c =:userId ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('lstcenterDetails-->'+lstcenterDetails);
            if(lstcenterDetails.size()>0){
                centerUser = lstcenterDetails[0];
                System.debug('lstcenterDetails-->'+lstcenterDetails);
            }
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }   
        return centerUser;
    }

    @AuraEnabled
    public static Map<String,String> getCPDetails(String centerId){
        List<Counsellor_Profile__c> lstCP = new List<Counsellor_Profile__c>();
        Map<String,String> mapOfCpdata = new Map<String,String>();
        Set<String> setofcontactCPid = new Set<String>();
        try {
            if(String.isNotBlank(centerId)) {
                System.debug('centerId -->'+centerId);
                lstCP = [SELECT Id,Name, Salutation__c, First_Name__c, Middle_Name__c, Last_Name__c,Counselor_Image__c,Employee_Image_URL__c,Email__c,MobilePhone__c FROM  Counsellor_Profile__c WHERE IsActive__c = false and Counselor_Image__c != null and Employee_Image_URL__c != null and AEP_Name__c =:centerId and MobilePhone__c != null and Email__c != null] ;
            }

            if(lstCP.size() > 0){
                for(Counsellor_Profile__c cp:lstCP){
                    mapOfCpdata.put(cp.Id,cp.First_Name__c+' '+cp.Last_Name__c);
                }
            }else{
                mapOfCpdata.put('error','');
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('mapOfCpdata '+mapOfCpdata);
        return mapOfCpdata;
    }

    public pageReference Login(){
      System.debug('userObj.Username '+userObj.Username);
      pageReference pg;
      if(String.isNotBlank(userObj.Username)){
        lst = [SELECT Id,Username,ContactId from User WHERE IsActive = TRUE and ContactId !=null and Username =:userObj.Username ];
        System.debug('lst '+lst);
        if(lst.size() > 0){
           userObj.ContactId = lst[0].ContactId;
           List<Contact> lstcontact = [Select Id, Counselor_Profile__c from Contact WHERE Id=:userObj.ContactId and Counselor_Profile__r.IsActive__c=false limit 1];
            //    Datetime myDT = Datetime.now();
            //    String Timestamp = myDT.format('yyyy-MM-dd hh:mm:ss');
            //    System.debug('Timestamp ==>'+Timestamp);
            //    String Checksum = generateCheckSum(lst[0].Id,lst[0].FirstName,lst[0].LastName,lst[0].Email,Timestamp);
            //    ld.Application_Auth_Token__c = Checksum;
            if(lstcontact.size()>0){
                System.debug('lstcontact '+lstcontact);
                pg=new pageReference('https://sandbox-nga-sce.cs5.force.com/AEPorg/CommunitiesLogin');
                pg.setRedirect(true); 
                return pg;
            }   
        }
       }else{          
           System.debug('Error -->Please Enter Email ...');
       }
       return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getCourseName(String opportunityId){
        List<String> lstOfBooks = new List<String>();
        try {
            if(String.isNotBlank(opportunityId)){
                List<Opportunity> opplst = [SELECT Id,nm_Semester__c,nm_Drive_Name__c,Program_Name__c,Program_Structure__c,nm_Program__c,ConsumerType__c from Opportunity WHERE Id=:opportunityId LIMIT 1];

                if((opplst.size()>0)){
                    list<Stock_Keeping_Units__c> listStock = [select id,Program__c,Semester__c,Launch_Year__c,CM_Books__c from Stock_Keeping_Units__c];
                    System.debug('Values from opportunity------->Program'+opplst[0].Program_Name__c+'Semester----->'+opplst[0].nm_Semester__c+'LaunchYear------->'+opplst[0].Program_Structure__c);
                    for(Stock_Keeping_Units__c sku:listStock)
                    {
                        // System.debug('SKU values------->Launch Year'+sku.Launch_Year__c+'Semester--------->'+sku.Semester__c);
                        if( sku.Launch_Year__c  ==  opplst[0].Program_Structure__c &&  sku.Semester__c ==  opplst[0].nm_Semester__c){
                            List<String> programs = sku.Program__c.split(';');
                            System.debug('<-------------listOfProg---------->'+programs);
                            for(String p : programs)
                            {   
                                // System.debug('p '+p+' opp prog '+opplst[0].Program_Name__c);
                                if(p == opplst[0].Program_Name__c){
                                    lstOfBooks = sku.CM_Books__c.split(';');
                                }
                            }
                        }
                        
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('lstOfBooks '+lstOfBooks);
        return lstOfBooks;
    }

    @AuraEnabled
    public static Map<String,List<String>> getStocksCenters(List<String> Booksname){
        Map<String,List<String>>  mapOfstock = new Map<String,List<String>>();
        try {
            List<Stock__c> lststock = [SELECT Id, CenterName__c, Centers__c, Course_Master__c, Course_Master_Name__c , Incoming_Quantity__c, Quantity__c, SKU__c,Stock_Keeping_Unit__c, Stock_ID__c from Stock__c WHERE Course_Master_Name__c IN:Booksname and Quantity__c > 0]; 
            if(lststock.size()>0){
                for(Stock__c stk:lststock){
                    List<String> uniqueStockslst = mapOfstock.size()>0 && mapOfstock.containsKey(stk.Course_Master_Name__c) ? mapOfstock.get(stk.Course_Master_Name__c) : new List<String>();
                    uniqueStockslst.add(stk.CenterName__c);
                    mapOfstock.put(stk.Course_Master_Name__c,uniqueStockslst);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return mapOfstock;
    }

   @AuraEnabled
    public static string generateLooseBooksDO(String centerName,List<String> booksname,String opportunityId, Integer qty, String accountId){
        String result = '';
        try {
            Map<String,Stock__c> mapOfstock = new Map<String,Stock__c>();
            List<Stock__c> stockUpdate = new List<Stock__c>();

            if(booksname.size()>0){
                List<Stock__c> lst = [SELECT Id, CenterName__c, Centers__c, Course_Master__c, Course_Master_Name__c , Incoming_Quantity__c, Quantity__c, SKU__c,Stock_Keeping_Unit__c, Stock_ID__c from Stock__c WHERE Course_Master_Name__c IN:booksname and Quantity__c > 0];
                
                if(lst.size()>0){
                    for(Stock__c stk:lst){
                        mapOfstock.put(stk.CenterName__c,stk);
                    }
                }

                System.debug('mapOfstock '+mapOfstock);

                Dispatch_Order__c disord = new Dispatch_Order__c();
                disord.Initiated_by__c = 'Logistics';
                disord.From_Centers__c = mapOfstock.containsKey(centerName) ? mapOfstock.get(centerName).Centers__c : null;
                disord.Opportunity__c = opportunityId;
                disord.To_Student__c = accountId;
                disord.Quantity__c = qty;
                disord.Order_Type__c = 'Loose Books';
                disord.Loose_Books_Name__c = String.valueOf(booksname);

               
                for(Stock__c stk: lst){
                    for(String str:booksname){
                        if(stk.Course_Master_Name__c == str && stk.CenterName__c == centerName){
                            stk.Quantity__c = stk.Quantity__c - qty;
                            stockUpdate.add(stk);
                        }
                    }
                }

                System.debug('stockUpdate '+stockUpdate);
                try {
                    update stockUpdate;

                    try {
                        insert disord;
                    } catch (DMLException e) {
                        System.debug('Error '+e.getMessage());
                    }

                    result = disord.id;
                } catch (DMLException e) {
                    System.debug('Error '+e.getMessage());
                }
            } 
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }

       return result;
   }

    @AuraEnabled(Cacheable = true) 
    public static List<AEPInvoice__c> getInvoiceDetails(String invoiceId){
        List<AEPInvoice__c> lstAEPInvoice = new List<AEPInvoice__c>();
        try {
            lstAEPInvoice = [SELECT id,AEP__c,Amount__c,IC_Payment__c,Invoice_Date__c,Invoice_Number__c,Pay_Month__c,Invoice_Link__c,Debit_Date__c,
            Debit_Number__c,Credit_Note_Link__c,Payment_Year__c,Program_Type__c,Status__c,Unique_Invoice_Check__c,AEP__r.Name FROM AEPInvoice__c 
            WHERE id =: invoiceId LIMIT 1]; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstAEPInvoice;
    }

    @AuraEnabled(Cacheable = true) 
    public static List<AEP_Request__c> getAEPRequestDetails(String aepRequestID){
        List<AEP_Request__c> lstAEPRequest = new List<AEP_Request__c>();
        try {
            lstAEPRequest = [SELECT id,Description__c,Subject__c,Reason_For_Exemption__c, RegistrationNumber__c, StudentName__c FROM AEP_Request__c WHERE id =: aepRequestID LIMIT 1]; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstAEPRequest;
    }

    @AuraEnabled
    public static String uploadFile(String base64, String filename){
        String ProfileImageURL = '';
        
		try {
            if(String.isBlank(base64)) {
                System.debug('base64 -->'+base64);
                return null;
            }
            Blob file_body = EncodingUtil.base64Decode(base64);
            String boundary = '----------------------------741e90d31eff';
            String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+filename+'";\nContent-Type: application/octet-stream';
            // GW: Do not prepend footer with \r\n, you'll see why in a moment
            // String footer = '\r\n--'+boundary+'--'; 
            String footer = '--'+boundary+'--';             
            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
            while(headerEncoded.endsWith('=')) {
                header+=' ';
                headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
            }
            String bodyEncoded = EncodingUtil.base64Encode(file_body);
            // GW: Do not encode footer yet
            // String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        
            Blob bodyBlob = null;
            String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
            // GW: replacement section to get rid of padding without corrupting data
            if(last4Bytes.endsWith('==')) {
                last4Bytes = last4Bytes.substring(0,2) + '0K';
                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                // We have appended the \r\n to the Blob, so leave footer as it is.
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
            } else if(last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0,3) + 'N';
                bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
                footer = '\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
            } else {
                // Prepend the CR LF to the footer
                footer = '\r\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
            }
        
            HttpRequest req = new HttpRequest();
            String EndPoint = System.Label.AEPInvoiceFilePath;
            req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
            req.setMethod('POST');
            req.setEndpoint(EndPoint);
            req.setBodyAsBlob(bodyBlob);
            req.setTimeout(120000);
        
            Http http = new Http();
            HTTPResponse res = http.send(req);

            String result = res.getBody();
            System.debug('result -->'+result);
            Map<String, Object> mapOfAPIResponse = (Map<String, Object>)JSON.deserializeUntyped(result);
            if(mapOfAPIResponse.get('status') == 'success'){ 
                ProfileImageURL = (String)mapOfAPIResponse.get('documentUrl');
            } else {
                ProfileImageURL = null;
            }
        } catch (Exception e) {
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
			return null;
        }
        return ProfileImageURL;
    }

    @AuraEnabled
    public static Boolean updateInvoice(String invoiceId, String invoiceLink, Boolean isInvoice){
        try {
            list<AEPInvoice__c> lstInvoice = [SELECT id,Invoice_Link__c,Credit_Note_Link__c,Status__c FROM AEPInvoice__c WHERE id=:invoiceId LIMIT 1];
            if(lstInvoice.size() > 0) {
                if(isInvoice) {
                    lstInvoice[0].Invoice_Link__c = invoiceLink;
                } else {
                    lstInvoice[0].Credit_Note_Link__c = invoiceLink;
                }
                // if(String.isNotBlank(lstInvoice[0].Credit_Note_Link__c) && String.isNotBlank(lstInvoice[0].Invoice_Link__c)) {
                if(String.isNotBlank(lstInvoice[0].Invoice_Link__c)) {
                    lstInvoice[0].Status__c = 'Submitted';
                }
                update lstInvoice;
                return true;
            } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    @AuraEnabled
    public static String updateAEPRequest(String aepRequestId, String documentLink){
        try {
            AEP_Request__c objAEpRequest = new AEP_Request__c();
            objAEpRequest.id = aepRequestId;
            objAEpRequest.Document_Link__c = documentLink;
            update objAEpRequest;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'Success';
    }


    @AuraEnabled
    public static String onSubmitApproval(String approve, String comment, String AccountId){
        system.debug('approve | comment | AccountId +' + approve + ' ' + comment + ' ' + AccountId);
        // try {
        //     String recordId = AccountId;
        //     List<ProcessInstanceWorkitem> workItems = [
        //         SELECT Id, ProcessInstanceId 
        //         FROM ProcessInstanceWorkitem 
        //         WHERE ProcessInstance.TargetObjectId = :recordId 
        //     ];
        //     List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        //     for(ProcessInstanceWorkitem workItem : workItems){
        //     Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        //     req.setWorkitemId(workItem.Id);
        //     //Valid values are: Approve, Reject, or Removed. 
        //     //Only system administrators can specify Removed.
        //     req.setAction(approve);
        //     req.setComments(comment);
        //     requests.add(req);
        //     }
        //     Approval.ProcessResult[] processResults = Approval.process(requests);
        //     system.debug('processResults --> ' + processResults);

        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }

        // Account objAccount = [Select Id FROM Account WHERE Id = :AccountId];
        try {
             Account objAccount = [Select Id, Name, nm_ReasonForICChange__c FROM Account WHERE Id = :AccountId];
            String InterviewComment = String.isNotBlank(objAccount.nm_ReasonForICChange__c) ? objAccount.nm_ReasonForICChange__c : '';

            Account upAccount = new Account();
            upAccount.Id = AccountId;
            approve =  approve == 'Rejected' ? 'On Hold-Rejected' : approve;
            upAccount.Interview_Status__c = approve;
            if(approve != 'On Hold-Rejected') {
                upAccount.nm_ReasonForICChange__c = String.isNotBlank(InterviewComment) ? 
                    InterviewComment + '\n ' + UserInfo.getName() +' : '+ comment + ' : ' + Datetime.now().format('MMM dd, yyyy hh:mm a') : + UserInfo.getName() +' : '+ comment + ' : ' + Datetime.now().format('MMM dd, yyyy hh:mm a');
            }
            update upAccount;
            if(approve == 'On Hold-Rejected') {
                String linkOfStudent = URL.getSalesforceBaseUrl().toExternalForm() + '/'  + objAccount.Id;
                sendEmailForRejection(objAccount.Name, linkOfStudent);
            }
         } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        

        return 'Success';
    }

    // for studentInterviewRating

    @AuraEnabled(Cacheable = true) 
    public static List<Account> getAccountDetails(String AccountId){
        system.debug('AccountId ---> ' + AccountId);
         List<Account> lstAccount = new List<Account>();
        // try {
        //     lstAccount = [SELECT id, Name FROM Account WHERE id =: AccountId LIMIT 1]; 
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
        // return lstAccount;
         String AccountQuery = getQueryAllFieldSql('Account','ID=:AccountId','Interview_Slot__r.Faculty_name_1__c,nm_Program__r.nm_ProgramName__c,nm_EligiblityCriteria__r.Experience_Required_In_Year__c, nm_EligiblityCriteria__r.Graduation_Percentage__c');
         try {
             lstAccount = DataBase.query(AccountQuery);
         } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('lstAccount --> ' + lstAccount);
        return lstAccount;
    }

    @AuraEnabled(Cacheable = true) 
    public static List<nm_WorkExperience__c> getWorkExperience(String AccountId){
        system.debug('AccountId ---> ' + AccountId);
        String lstWorkExperienceQuery = getQueryAllFieldSql('nm_WorkExperience__c','nm_Student__c=:AccountId',null);
        List<nm_WorkExperience__c> lstWorkExperience = new List<nm_WorkExperience__c>();
        system.debug('lstWorkExperience --> ' + lstWorkExperience);
        try {
            lstWorkExperience = DataBase.query(lstWorkExperienceQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstWorkExperience;
    }
    @AuraEnabled(Cacheable = true) 
    public static List<Student_Rating__c> getStudentRating(String AccountId){
        system.debug('AccountId ---> ' + AccountId);
        try {
            String lstStudentRatingQuery = getQueryAllFieldSql('Student_Rating__c','Student__c=:AccountId order by Interview_Date__c desc',null);
            List<Student_Rating__c> lstStudentRating = new List<Student_Rating__c>();
                system.debug('lstStudentRating --> ' + lstStudentRating);
            lstStudentRating = DataBase.query(lstStudentRatingQuery);
            return lstStudentRating;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled(Cacheable = true) 
    public static Map<Id, AccountAndRating> getInterviewList(){
        // List<ProcessInstance> lstProcessInstance =  [SELECT Id, TargetObjectId,ProcessDefinitionId  FROM ProcessInstance WHERE Status = 'Pending'];
        // system.debug('lstProcessInstance --> ' + lstProcessInstance );
        Set<Id> accountIds = new Set<Id>();
        
        List<Account> lstAcc = new List<Account>();
        List<Student_Rating__c> lstStudentRating = new List<Student_Rating__c>();
        Map<Id, AccountAndRating> mapOfAccountAndRating = new Map<Id, AccountAndRating>();
        
        try {
            lstAcc = [SELECT Id, Name, LinkedIn_URL__c, nm_DateOfBirth__c, nm_Gender__c, Interview_Status__c, Age__c, nm_StudentStatus__c FROM Account WHERE  (Interview_Status__c = 'Approval Pending' OR Interview_Status__c = 'On Waiting List') AND nm_StudentStatus__c != 'Registration Cancelled' ORDER BY Interview_Status__c ASC];
            system.debug('lstAcc --> ' + lstAcc);
            if(lstAcc.size() > 0) {
                for(Account objAcc : lstAcc) {
                    accountIds.add(objAcc.Id);
                }
                lstStudentRating = [Select Name,Student__c From Student_Rating__c Where Student__c In :accountIds];
            }
            
            if(lstAcc.size() > 0 ) {
                for(Account objAcc : lstAcc) {
                    Integer total = 0;
                    if(lstStudentRating.size() > 0) {
                        for(Student_Rating__c objSt : lstStudentRating) {
                            if (objSt.Student__c == objAcc.Id) {
                                total ++;
                            }
                        }
                    }
                    AccountAndRating objAccountAndRating = new AccountAndRating();
                    objAccountAndRating.lstAccount = objAcc;
                    objAccountAndRating.totalRating = total;
                    mapOfAccountAndRating.put(objAcc.Id, objAccountAndRating);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
       
        
        return mapOfAccountAndRating;
    }

    @AuraEnabled
    public static string sendEmailForRejection(String studentName,String studentLink){
        String result = '';
        OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1 ];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] sendingToAddress = new List<String>();
        if(System.Label.Environment == 'Sandbox') {
            sendingToAddress.add('suyog.deshmukh.ext@nmims.edu');
            sendingToAddress.add('dsuyog2013@gmail.com');
        } else if(System.Label.Environment == 'Production') {
            sendingToAddress.add('manasvi.malve@nmims.edu');
        }
        string[] bccAddress = new List<String>{'suyog.deshmukh.ext@nmims.edu'};
        email.setBccAddresses(bccAddress);
        System.debug('bccAddress '+bccAddress);
        
        email.setToAddresses(sendingToAddress);
        System.debug('sendingToAddress '+sendingToAddress);
        email.setSubject('Student Interview Rejection by Sir ');
        // email.setHtmlBody('Hello, <br/><br/>This is the test mail that you generated. <br/>The Email Id for which this mail was generated by '+toMail+'<br/><br/>Regards<br/> Developer');
        email.setOrgWideEmailAddressId(owe.id);
        email.setHtmlBody(gethtmlBodyContent(studentName,studentLink));
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            result = 'success';
        }catch(exception e){
            result = e.getMessage();
           // apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
            System.debug('error occured '+e.getMessage());
        }
        return result;
    }

    public Static String gethtmlBodyContent(String studentName,String studentLink) {
        
        String message = '<html>'+
        ''+
        '<head>'+
        '    <meta charset="UTF-8" />'+
        '    <meta http-equiv="X-UA-Compatible" content="IE=edge" />'+
        '    <meta name="viewport" content="width=device-width, initial-scale=1.0" />'+
        '    <title>Document</title>'+
        '</head>'+
        ''+
        '<body>'+
        '    <table width="700" border="0" align="center" cellpadding="0" cellspacing="0"'+
        '        style="border: 1px solid #A09999; display:table">'+
        '        <tbody>'+
        '            <tr>'+
        '                <td width="700">'+
        '                    <table width="700" border="0" align="left" cellpadding="0" cellspacing="0"'+
        '                        style="font-family:\'Helvetica Neue\', Helvetica, Arial, \'sans-serif\'">'+
        '                        <tbody>'+
        '                            <tr>'+
        '                                <td width="5" height="100" align="left">'+
        '                                    <a href="'+Label.Student_Portal+'" style="color: #aa1f24">'+
        '                                        <img WIDTH="720" HEIGHT="100" alt=""'+
        '                                            src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAV&oid=00D90000000s6BL"'+
        '                                            style=" display: table" /></a>'+
        '                                </td>'+
        '                            </tr>'+
        '                        </tbody>'+
        '                    </table>'+
        '                </td>'+
        '            </tr>'+
        '            <tr>'+
        '                <td> </td>'+
        '                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
        '                <td> </td>'+
        '            </tr>'+
        '            <tr>'+
        '                <td align="center" style="border-collapse: collapse;" valign="top">'+
        '                    <table border="0" cellpadding="0" cellspacing="0" id="templateBody" width="600">'+
        '                        <tbody>'+
        '                            <tr>'+
        '                                <td height="200" valign="top">'+
        '                                    <table border="0" cellpadding="0" cellspacing="0" width="600">'+
        '                                        <tbody>'+
        '                                            <tr>'+
        '                                                <td>&emsp;</td>'+
        '                                                <!-- <td> </td> -->'+
        '                                                <td style="font-size: 16px; color: #333333; line-height: 16px;"'+
        '                                                    valign="top">'+
        '                                                    Hi Ma\'am,'+
        '                                                    <br />'+
        '                                                    <br />'+
        '                                                    Please find below student, which has been rejected by sir.'+
        '                                                    <br />'+
        '                                                    <br />'+
        '                                                    <a style="color: rgb(190, 10, 10)" href="' + studentLink+'">'+ studentName+'</a>'+
        '                                                    <br />'+
        '                                                    <br />'+
        '                                                    '+
        '                                                '+
        '                                                        Regards,<br />'+
        '                                                        NMIMS CDOE'+
        ''+
        '                                                    </p>'+
        '                                                    <br />'+
        '                                                </td>'+
        '                                                <td>&emsp;</td>'+
        '                                            </tr>'+
        '                                            <tr>'+
        '                                                <td> </td>'+
        '                                                <td colspan="3" height="20" valign="top"><img'+
        '                                                        src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAp&oid=00D90000000s6BL&lastMod=1603954244000"'+
        '                                                        style="display: table" width="750" /></td>'+
        '                                                <td> </td>'+
        '                                            </tr>'+
        '                                            <tr>'+
        '                                                <td> </td>'+
        '                                                <td colspan="2" id="utility"'+
        '                                                    style="border-collapse: collapse;background-color: #FFFFFF;border: 0;"'+
        '                                                    valign="middle">'+
        '                                                </td>'+
        '                                                <td> </td>'+
        '                                            </tr>'+
        '                                        </tbody>'+
        '                                    </table>'+
        '                                </td>'+
        '                            </tr>'+
        '                        </tbody>'+
        '                    </table>'+
        '                </td>'+
        '            </tr>'+
        '        </tbody>'+
        '    </table>'+
        '</body>'+
        ''+
        '</html>';
            
        return message;
    }

    public static String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }

    public with sharing class AccountAndRating {
        @auraEnabled public Integer totalRating {get;set;}
        @auraEnabled public Account lstAccount {get;set;}
    }
}