/**
 * @File Name          : purchaseLicenseForAEPController.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 16-04-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    19/3/2020   shubhranshu     Initial Version
**/
public without sharing class purchaseLicenseForAEPController {

    @AuraEnabled(Cacheable=true)  
    public static nm_UserMapping__c getCenterUserData(String userId) {
    
        nm_UserMapping__c centerUser = new nm_UserMapping__c();
        try{
            String profileName = [SELECT Profile.Name FROM User WHERE Id =:UserInfo.getUserId()].Profile.Name;
            System.debug('userId -->'+userId);
            List<nm_UserMapping__c> lstcenterDetails = new List<nm_UserMapping__c>();
            if(String.isNotBlank(profileName) && (profileName.startsWith('Information Center') || profileName.startsWith('pp profile'))) {
                lstcenterDetails = [SELECT Id, nm_Centers__c, nm_Centers__r.Name,nm_Centers__r.recordtype__c,
                nm_Centers__r.Center_Name__c,nm_Head__c,UserId__c,nm_Centers__r.Password__c FROM nm_UserMapping__c WHERE 
                UserId__c =:userId AND nm_User__r.UserRole.Name LIKE '%Executive' ORDER BY CreatedDate DESC LIMIT 1];
            } else if(String.isNotBlank(profileName) && profileName.startsWith('Learning Center')) {
                lstcenterDetails = [SELECT Id, nm_Centers__c, nm_Centers__r.Name,nm_Centers__r.recordtype__c,
                nm_Centers__r.Center_Name__c,nm_Head__c,UserId__c,nm_Centers__r.Password__c FROM nm_UserMapping__c WHERE 
                UserId__c=:userId AND nm_Head__c=true AND nm_Centers__r.recordtype__c='Learning Center' ORDER BY CreatedDate DESC LIMIT 1];
            }
            
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
    public static List<nm_Centers__c> getAEPCenterData(String centerId) {
        List<nm_Centers__c> lstcenterDetails = null;
        try{
            if(String.isNotBlank(centerId)) {
                lstcenterDetails = [SELECT Id,Name FROM nm_Centers__c WHERE nm_LearningCenter__c=:centerId AND Nm_Active__c=true AND recordtype__c='Information Center'];
            }
            System.debug('lstcenterDetails-->'+lstcenterDetails);
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }   
        return lstcenterDetails;
    }

    @AuraEnabled(Cacheable = true) 
    public static nm_UserMapping__c getCenterUserDatav2(String userId) {
        nm_UserMapping__c centerUser = new nm_UserMapping__c();
        try{
            System.debug('userId -->'+userId);
            List<nm_UserMapping__c> lstcenterDetails = [SELECT Id, nm_Centers__c, nm_Centers__r.Name,
            nm_Centers__r.Center_Name__c,nm_Head__c,UserId__c,nm_Centers__r.Password__c FROM nm_UserMapping__c WHERE 
            UserId__c =:userId LIMIT 1];
            System.debug('lstcenterDetails-->'+lstcenterDetails);
            if(lstcenterDetails.size()>0){
                centerUser = lstcenterDetails[0];
                System.debug('lstcenterDetails-->'+lstcenterDetails);
            }
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }   
        return centerUser;
    }

    @AuraEnabled
    public static Map<String,Object> getCPDetails(String centerId){
        List<Counsellor_Profile__c> lstCP = new List<Counsellor_Profile__c>();
        Map<String,Object> mapOfCpdata = new Map<String,Object>();
        Set<String> setofcontactCPid = new Set<String>();
        try {

            List<Contact> lstcontact = [SELECT Id,Name, AccountId,Email,MobilePhone,Counselor_Profile__c FROM Contact where Counselor_Profile__c != null];

            if(lstcontact.size() > 0){
                for(Contact con:lstcontact){
                    setofcontactCPid.add(con.Counselor_Profile__c);
                }
            }
            if(String.isNotBlank(centerId)) {
                System.debug('centerId -->'+centerId);
                lstCP = [SELECT Id,Name, Salutation__c, First_Name__c, Middle_Name__c, Last_Name__c,Counselor_Image__c,Employee_Image_URL__c,Email__c,MobilePhone__c,nm_ChooseaProgram__c FROM  Counsellor_Profile__c WHERE IsActive__c = false and Counselor_Image__c != null and Employee_Image_URL__c != null and AEP_Name__c =:centerId and MobilePhone__c != null and Email__c != null] ;
            }

            if(lstCP.size() > 0){
                for(Counsellor_Profile__c cp:lstCP){
                    mapOfCpdata.put(cp.Id,cp);
                }
            }else{
                mapOfCpdata.put('error',null);
            }

            System.debug('setofcontactCPid '+setofcontactCPid);
            for(String str:mapOfCpdata.keySet()){
                if(setofcontactCPid.contains(str)){
                    mapOfCpdata.remove(str);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('mapOfCpdata '+mapOfCpdata);
        return mapOfCpdata;
    }


    @AuraEnabled
    public static List<Contact> saveContacts(List<Contact> lstContactInsert) {
        try {
            if(lstContactInsert.size() > 0) {
                System.debug('lstContactInsert '+lstContactInsert);
                insert lstContactInsert;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstContactInsert;
    }
    
    @AuraEnabled
    public static nm_Centers__c saveCentersDetails(Integer numberOflicense , String centerId) {
        
        nm_Centers__c centerObj = new nm_Centers__c();
        try {
            centerObj.TotalLicensesRequired__c = numberOflicense;
            centerObj.Id = centerId;
            System.debug('centerObj '+centerObj);
            update centerObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return centerObj;
    }

    // rollback changes if any error occured
    // @AuraEnabled
    // public static nm_Centers__c rollbackCentersDetails(Integer numberOflicense , String centerId){
    //     nm_Centers__c centerObj = new nm_Centers__c();
    //     try {
    //         centerObj.TotalLicensesRequired__c = numberOflicense;
    //         centerObj.Id = centerId;
    //         System.debug('centerObj '+centerObj);
    //         update centerObj;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return centerObj;   
    // }

    // for online payment method
    @AuraEnabled
    public static nm_Centers__c saveCentersDetailsForOnline(Integer numberOflicense , Decimal amount ,String cpusers, String centerId) {
        
        nm_Centers__c centerObj = new nm_Centers__c();
        try {
            centerObj.TotalLicensesRequired__c = numberOflicense;
            centerObj.amount_For_new_License__c = amount;
            centerObj.Partner_User_list__c = cpusers;
            centerObj.Id = centerId;
            System.debug('centerObj '+centerObj);
            update centerObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return centerObj;
    }

    @AuraEnabled
    public static String DebitShareEntry(String AEPId,Decimal licensesFee){
        Date today = Date.Today();
        System.debug('AEPId--->'+AEPId+' licensesFee--->'+licensesFee);
        List<IC_Payment__c> lstofICPayment = [select id,Payment_Month__c,Payment_Year__c,Amount__c,Payment_Due_Date__c,
                                                Centers__c,nm_CenterName__c ,Net_Amount__c,Payment_Month_and_Year_to_Date__c
                                                from IC_Payment__c where Centers__c  =:AEPId
                                                and Net_Amount__c >=: licensesFee and  Share_Processed__c = false 
                                                ORDER BY Payment_Month_and_Year_to_Date__c ASC limit 1];

        if(lstofICPayment.size()>0)
        {
            try{          
                IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();        
                ip.Amount__c =  licensesFee;
                ip.Narration__c = 'Community Licenses Fee - AdjustmentDebit'  ;
                ip.IC_Payment__c = lstofICPayment[0].Id;   
                ip.Transaction_Type__c = 'Adjustment - Debit';
                ip.Due_Date__c = lstofICPayment[0].Payment_Due_Date__c;
                ip.Date__c = today;
                insert ip;
                // return new pageReference(Label.Site_Url+ 'nmRegistrationThankYou?id='+ip.id);
                return 'success '+ip.id;
            } catch(DmlException e){
                System.debug(e.getMessage());
                return e.getMessage();
            }
        }
        else
        {
            return 'No Credit Found to Debit Licenses Fee';           
        }
    }

    // rollback changes if any error occured
    @AuraEnabled
    public static String rollbackDebitShareEntry(String AEPId){
        System.debug('AEPId--->'+AEPId);
        List<IC_Payment_Transaction__c > lstICPaymentTran = [Select Id ,Amount__c , Narration__c ,IC_Payment__c , Transaction_Type__c , Due_Date__c, Date__c
                                                            From IC_Payment_Transaction__c Where Narration__c = 'Community Licenses Fee - AdjustmentDebit' and 
                                                            Transaction_Type__c = 'Adjustment - Debit' and (Date__c = today OR CreatedDate = TODAY) order by Date__c ASC];
        if(lstICPaymentTran.size()>0)
        {
            try{          
                delete lstICPaymentTran;
                return 'IC Paymnet Transaction record deleted';
            } catch(DmlException e){
                System.debug(e.getMessage());
                return e.getMessage();
            }
        }
        else
        {
            return 'No record Found to delete';           
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getNoOfMonths() {
        Date expiryDate;
        Decimal monthsBetween = 0;
        List<PermissionSetLicense> lstUserLicense = [SELECT id,ExpirationDate FROM PermissionSetLicense WHERE Status = 'Active' LIMIT 1];
        if(lstUserLicense.size()>0) {
            Decimal daysBetween = 0;
            Decimal totalDays = Date.isLeapYear(System.today().year()) ? 366 : 365;
            // expiryDate = lstUserLicense[0].ExpirationDate;
            expiryDate = Date.parse(System.Label.ExpireDatePurchaseLicense);
            daysBetween = (expiryDate!=null ? System.today().daysBetween(expiryDate) : 0) - 1;
            monthsBetween = daysBetween / totalDays * 12;
        }  
        return monthsBetween.setScale(2);                        
    }

    @AuraEnabled
    public static string sendNotificationEmail(String aepName,String noOfLicense,String amount,String timeperiod,List<Contact> listofContact,String receiptLink,String paymentType){
        String result = '';
        System.debug('listofContact.....=>'+listofContact);
        OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE'LIMIT 1 ];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] bccAddress = System.Label.setBccAdderess.split(',');
        email.setBccAddresses(bccAddress);
        System.debug('bccAddress '+bccAddress);
        string[] toAddress = System.Label.EmailAddressForAEPPurchase.split(','); 
        email.setToAddresses(toAddress);
        System.debug('toAddress '+toAddress);
        email.setSubject('New Community License Request '+aepName);
        // email.setHtmlBody('Hello, <br/><br/>This is the test mail that you generated. <br/>The Email Id for which this mail was generated by '+toMail+'<br/><br/>Regards<br/> Developer');
        email.setOrgWideEmailAddressId(owe.id);
        email.setHtmlBody(gethtmlBodyContent(aepName,noOfLicense,amount,timeperiod,listofContact,receiptLink,paymentType));
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

    public static String gethtmlBodyContent(String aepName,String noOfLicense,String amount,String timeperiod ,List<Contact> listofContact,String receiptLink,String paymentType){
        // set a table for user list 
        String userListhtmlBody = '';

        userListhtmlBody = '<table cellpadding = "2" cellspacing = "2"><tr><th>Counsellor Name</th><th>Role</th></tr>';
        for(Contact con : listofContact){
            String userName = con.FirstName+' '+con.LastName; if(con.FirstName == null || con.LastName == null){userName = '[Not Provided]';}
            String userRole = con.User_Role__c; if(con.User_Role__c == null){userRole = '[Not Provided]';}
            userListhtmlBody += '<tr><td align="center">' + userName + '</td><td align="center">' + userRole + '</td></tr>';
        }
        userListhtmlBody += '</table>';


        String message =  '<!doctype html>'+
                    '<html>'+
                    ''+
                    '<head>'+
                    '    <meta charset="utf-8">'+
                    '    <meta http-equiv="Content-Type" content="text/html charset=UTF-8" />'+
                    '    <title>Untitled Document</title>'+
                    '    <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />'+
                    '</head>'+
                    ''+
                    '<body>'+
                    ''+
                    '    <table width="700" border="0" align="center" cellpadding="0" cellspacing="0" style="border: 1px solid #A09999; display:table">'+
                    '        <tbody>'+
                    '            <tr>'+
                    '                <td width="700">'+
                    '                    <table width="700" border="0" align="left" cellpadding="0" cellspacing="0" style="font-family:\'Helvetica Neue\', Helvetica, Arial, \'sans-serif\'">'+
                    '                        <tbody>'+
                    '                            <tr>'+
                    '                                <td width="5" height="100" align="left">'+
                    '                                    <a href="'+Label.Student_Portal+'" style="color: #aa1f24">'+
                    '                                        <img WIDTH=720 HEIGHT=100 alt="" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAV&oid=00D90000000s6BL&lastMod=1603953932000" style=" display: table"></a>'+
                    '                                </td>'+
                    '                            </tr>'+
                    '                        </tbody>'+
                    '                    </table>'+
                    '                    <!-- End Template Header  -->'+
                    '                </td>'+
                    '            </tr>'+
                    '            <tr>'+
                    '                <td> </td>'+
                    '                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
                    '                <td> </td>'+
                    '            </tr>'+
                    '            <tr>'+
                    '                <td align="center" style="border-collapse: collapse;" valign="top">'+
                    '                    <!-- Begin Template Body  -->'+
                    '                    <table border="0" cellpadding="0" cellspacing="0" id="templateBody" width="600">'+
                    '                        <tbody>'+
                    '                            <tr>'+
                    '                                <td height="200" valign="top">'+
                    '                                    <table border="0" cellpadding="0" cellspacing="0" width="600">'+
                    '                                        <tbody>'+
                    '                                            <tr>'+
                    '                                                <td width="20"><img alt="" height="44" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000" width="22"></td>'+
                    '                                                <td pardot-region="" style="font-size: 16px; color: #464648; line-height: 24px;" valign="top" width="708">Dear Ma&#39;am &#44;	'+
                    '                                                    <br>'+
                    '                                                    <br> Greetings from NMIMS Center For Distance And Online Education'+
                    '                                                    <br>'+
                    '                                                    <br> '+aepName+' has requested for '+noOfLicense+' new community licenses to be issued for their team members:'+
                    '                                                    <br>'+
                    '                                                    <br>'+userListhtmlBody +
                    '                                                    <br>'+
                    //'                                                    <br> The AEP has <paid online / will pay from IC share> an amount of Rs. <12312> for the licenses for a period of <10.75> months starting from today. Kindly purchase and allot the new licenses at the earliest.'+
                    '                                                    <br> The AEP has paid via '+paymentType+' an amount of Rs. '+amount+' for the licenses for a period of '+timeperiod+' months starting from today. Kindly purchase and allot the new licenses at the earliest.'+
                    '                                                    <br>'+
                    '                                                    <br> Click <a href="'+receiptLink+'" style="color: #aa1f24">here</a> to refer payment receipt.'+
                    '                                                    <br>'+
                    '                                                    <br> Thanks and Regards,'+
                    '                                                    <br>'+
                    '                                                    <span><b>NMIMS CDOE</b></span>'+
                    ''+
                    '                                                </td>'+
                    '                                                <td width="22"><img alt="" height="44" src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000" width="22"></td>'+
                    ''+
                    '                                            </tr>'+
                    ''+
                    '                                            <tr>'+
                    '                                                <td> </td>'+
                    '                                                <td style="font-size: 16px; color: #464648; line-height: 24px;" valign="top"> </td>'+
                    '                                                <td> </td>'+
                    '                                            </tr>'+
                    '                                            <tr>'+
                    '                                                <td> </td>'+
                    '                                                <td colspan="3" height="20" valign="top"><img src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAp&oid=00D90000000s6BL&lastMod=1603954244000" style="display: table" width="750"></td>'+
                    '                                                <td> </td>'+
                    '                                            </tr>'+
                    '                                            <tr>'+
                    '                                                <td> </td>'+
                    '                                                <td colspan="2" id="utility" style="border-collapse: collapse;background-color: #FFFFFF;border: 0;" valign="middle">'+
                    '                                                    <div style="font-size:2;height:100px; font-family:Calibri, \'sans-serif\'; width: 700px;padding-left:10px;">'+
                    ''+
                    '                                                        You are receiving this email because you had signed up to receive emails from NMIMS CDOE.'+
                    '                                                        <br>'+
                    ''+
                    '                                                        Please do not reply to this email, as this inbox is not monitored|Toll Free:<a href="tel:18001025136" style="color: #aa1f24"> 18001025136</a>'+
                    '                                                    </div>'+
                    '                                                </td>'+
                    '                                                <td> </td>'+
                    '                                            </tr>'+
                    ''+
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
                    ''+
                    '</body>'+
                    ''+
                    '</html>';
        return message;
    }

    // ---------------------------------------- For Payment Details Method --------------------

    @AuraEnabled
    public static List<IC_Payment_Transaction__c> getPaymentDetails(PaymentValueWrapper objWrapper){
        List<IC_Payment_Transaction__c> reportResultList = new List<IC_Payment_Transaction__c>();

        Date fromDate = Date.valueOf(objWrapper.fromMonthYear + '-01');
        Date toDate = Date.valueOf(objWrapper.toMonthYear + '-01').addMonths(1);

        try {
            reportResultList = [SELECT Date__c, Student_No__c,Narration__c,Reference_Number__c,Due_Date__c,Amount__c,Transaction_Type__c,Opportunity__c,
                               Opportunity__r.Is_Re_Registration_Payment__c,Transaction_Category__c FROM IC_Payment_Transaction__c 
                               WHERE IC_Payment__r.Centers__c = :objWrapper.centerId 
                               AND ic_payment__r.Payment_Month_and_Year_to_Date__c >= :fromDate
                               AND ic_payment__r.Payment_Month_and_Year_to_Date__c < :toDate
                               ORDER BY  ic_payment__r.Payment_Month_and_Year_to_Date__c ASC];
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        if(reportResultList.size() > 0) {
            return reportResultList;
        }
        return null;
    }
    
    public with sharing class PaymentValueWrapper {
        @auraEnabled public String fromMonthYear  {get;set;}
        @auraEnabled public String toMonthYear  {get;set;}
        @auraEnabled public String centerId {get;set;}
    }

    // ---------------------------------------- For My Deleted Leads ----------------------------------------

    @AuraEnabled(cacheable=true)
    public static List<Lead> getDeletedLeads(){
        List<Lead> lstLead = new List<Lead>();
        String UserId = UserInfo.getUserId();
        try {
            nm_UserMapping__c centerUser = [SELECT Id,nm_Centers__c,nm_User__c, UserId__c from nm_UserMapping__c WHERE UserId__c=:UserId];
            if(centerUser != null){
                lstLead = [SELECT id,name,email,mobilePhone,nm_OtherLeadSources__c,LeadSource,nm_ChooseaProgram__c,IC_Name__c,CreatedDate,CreatedById,LastModifiedDate 
                FROM Lead WHERE (CreatedById =:UserId OR nm_InformationCenter__c =:centerUser.nm_Centers__c) AND isDeleted=true ALL ROWS];
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        if(lstLead.size() > 0) {
            return lstLead;
        }
        return null;
    }
    // ---------------------------------------- For Email Messages ----------------------------------------

    @AuraEnabled(cacheable=true)
    public static List<EmailMessagesResponseWrapper> getEmailMessage(String parentId) { 
        Id recordId = parentId;
        System.debug('recordId ===>'+recordId);
        List<EmailMessagesResponseWrapper> lstOfEmails = UploadStudentProfileDocument.getCaseEmails(recordId);
        System.debug(lstOfEmails);
        return lstOfEmails;
    }

    // --------------------------------------- For Bachelor Program Tab--------------------------------------

    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeads() {
        String UserId = UserInfo.getUserId();

        List<Lead> lstLeads = new List<Lead>();
        String arcLinkForDocsSql = getQueryAllFieldSql('Lead','nm_ChooseaProgram__c=\'Bachelor Programs\' AND isConverted=false AND OwnerId=:UserId',null);
        // List<Lead> lstLeads = [SELECT id,nm_ChooseaProgram__c,nm_InformationCenter__c,Status,LeadSource,MobilePhone,nm_RegistrationNo__c,Lead_Description__c,Next_Follow_up__c,
        // Email,Name,Owner.Name,CreatedDate,Program_Type__c FROM Lead WHERE nm_ChooseaProgram__c='Bachelor Programs' AND isConverted=false AND OwnerId=:UserId];
        System.debug(lstLeads);
        return lstLeads;


        // List<Lead> resultOfLeads = new List<Lead>();
        // List<Set<String>> lstWrapper = new List<Set<String>>();
        // List<List<Lead>> lstWrapperLeads = new List<List<Lead>>();
        // List<Lead> lstLeads = [SELECT id,nm_ChooseaProgram__c,nm_InformationCenter__c,Status,LeadSource,MobilePhone,nm_RegistrationNo__c,Lead_Description__c,Next_Follow_up__c,
        // Email,Name,Owner.Name,CreatedDate,Program_Type__c FROM Lead  ORDER BY Name ASC NULLS FIRST];
        
        // for(Integer i = 0 ; i < (lstLeads.size() / 200) + 1 ; i++){
        //     Set<String> setOfLeads = new Set<String>();
        //     List<Lead> setOfLeadList = new List<Lead>();
        //     for(Integer j=(i*200); (j<(i*200)+200) && j < lstLeads.size(); j++){
        //         setOfLeads.add(lstLeads.get(j).Id);
        //         setOfLeadList.add(lstLeads.get(j));
        //     }
        //     lstWrapper.add(setOfLeads);
        //     lstWrapperLeads.add(setOfLeadList);
        // }
        // String userId = UserInfo.getUserId();

        // Integer count = 0;
        // for(Set<String> setOfLeads : lstWrapper) {
        //     List<Lead> setOfLeadList = lstWrapperLeads[count];
        //     List<UserRecordAccess> lst = [SELECT RecordId, HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, HasTransferAccess 
        //                                     FROM UserRecordAccess where UserId =:userId and RecordId IN :setOfLeads];
        //     for(UserRecordAccess usr : lst){
        //         for(Lead obj:setOfLeadList){
        //             if(obj.Id == usr.RecordId && usr.HasReadAccess){
        //                resultOfLeads.add(obj); 
        //             }
        //         }
        //     }
        //     count++;
        // }
        // if(resultOfLeads.size() > 0){
        //     return resultOfLeads;
        // }
        // return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Archived_Document__b> getArchiveLinkforDocuments(String parentId) { 
        Id recordId = parentId;
        System.debug('recordId ===>'+recordId);
        List<Archived_Document__b> lstOfLinkOfDocs = new List<Archived_Document__b>();
        String arcLinkForDocsSql = getQueryAllFieldSql('Archived_Document__b','Account__c=:recordId',null);
        System.debug('arcLinkForDocsSql '+arcLinkForDocsSql);
        lstOfLinkOfDocs = DataBase.query(arcLinkForDocsSql);
        System.debug(lstOfLinkOfDocs);
        return lstOfLinkOfDocs;
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
}