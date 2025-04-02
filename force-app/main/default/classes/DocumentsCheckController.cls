/**
 * @File Name          : DocumentsCheckController.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 10-14-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    21/7/2019, 4:50:48 PM   shubhranshu     Initial Version
**/
public class DocumentsCheckController {
    //Define properties
public static Account objAccount{get;set;}
public static id accountID{get;set;}
public static list<nm_LinksForDocuments__c> lstLinkForDocuments{get;set;} 
public list<string> lstCenterEmail{get;set;}
public boolean show {get;set;}
public static String studStatus {get;set;}
public static Map<String,nm_LinksForDocuments__c> mapDocumentIdVsDocument {get;set;}
public static Map<String,String> mapUserIdVsCounselorId {get;set;}
public String jsonMapOfUserId {get;set;}
public static list<nm_WorkExperience__c> lstWorkExperience {get;set;}
public String jsonMap {get;set;}
public String errorMsg {get;set;}

public DocumentsCheckController() {
    objAccount = new Account();
    lstWorkExperience = new list<nm_WorkExperience__c>();
    lstCenterEmail = new list<string>();
    lstLinkForDocuments = new list<nm_LinksForDocuments__c>();
    mapUserIdVsCounselorId = new Map<String,String>();
    show = false;
    errorMsg = '';
    studStatus= '';
  
    if(String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))){
        accountID = ApexPages.currentPage().getParameters().get('id');
        getDocumentRelatedData(accountID);
    }
}

/**
* @description
* @author @BK | 25/7/2019
* @param String accId
* @return void
*/
public void getDocumentRelatedData(String accId) {
    if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.nm_LinksForDocuments__c.isAccessible() && Schema.sObjectType.nm_WorkExperience__c.isAccessible()) {
        mapDocumentIdVsDocument = new Map<String,nm_LinksForDocuments__c>();
        lstWorkExperience = new list<nm_WorkExperience__c>();

        String queryforAcc = getQueryAllFieldSql('Account' ,'Id =:accId','nm_Program2__r.Name,nm_Program__r.Name,(SELECT id,DocumentQuerySubmitted__c, nm_DocumentName__c, nm_AccountEmail__c, nm_DocumentLink__c,Document_Query__c,nm_ReasonforDisapprove__c,nm_Status__c, nm_URLforDocuments__c, nm_Old_URL_for_Documents__c, nm_Old_Status__c ,nm_URLforIncorrectDocuments__c,nm_Account__c,nm_Account__r.Admission_Co_ordinator__c,Document_Upload_Mode__c FROM Links_For_Documents__r)' );
        list<Account> lstAcc = DataBase.query(queryforAcc);
        if(lstAcc != null && lstAcc.size() > 0 && lstAcc[0].nm_StudentStatus__c !='Not Eligible') {
            objAccount = lstAcc[0];
            System.debug('objAccount--'+objAccount.firstname);
            System.debug('objAccount.id -->'+objAccount.id);
            studStatus = objAccount.nm_StudentStatus__c;
            if(lstAcc[0].Links_For_Documents__r != null && lstAcc[0].Links_For_Documents__r.size() > 0)
            {
                lstLinkForDocuments =  lstAcc[0].Links_For_Documents__r;
                for (nm_LinksForDocuments__c linksForDocument : lstLinkForDocuments) {
                    mapDocumentIdVsDocument.put(linksForDocument.id, linksForDocument);
                }
                jsonMap = JSON.serialize(mapDocumentIdVsDocument);
            }
            lstWorkExperience = [SELECT id,nm_Student__c,nm_TotalMonths__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c FROM nm_WorkExperience__c WHERE nm_Student__c=:objAccount.id];
            List<Counsellor_Profile__c> lstProfile = [SELECT id,OwnerId FROM Counsellor_Profile__c WHERE IsActive__c=false AND BusinessAccount__r.Name='Head Office'];
            if(lstProfile.size() > 0) {
                for (Counsellor_Profile__c objProfile : lstProfile) {
                    mapUserIdVsCounselorId.put(objProfile.OwnerId,objProfile.id);
                }
                jsonMapOfUserId = JSON.serialize(mapUserIdVsCounselorId);
            }
            return;
        } else {
            show = true;
            errorMsg = 'You cannot verify these documents if student status is not eligible';
        }
    } else {
        show = true;
        errorMsg = 'You dont have permission for this page to access';
    }
}

/**
* @description
* @author @BK | 25/7/2019
* @param String studStatusForAcc
* @param String linkForDocumentId
* @param String documentStatus
* @param String docQuery
* @param String reasonIfDisapproved
* @return @RemoteAction
*/
@RemoteAction
public static String save(String studStatusForAcc,String linkForDocumentId,String documentStatus,String docQuery,String reasonIfDisapproved,String jsonMapDocumentIdVsDocument,String jsonMapUserIdVsCounselorId) {
    if(Schema.sObjectType.nm_LinksForDocuments__c.isUpdateable()) {
        mapDocumentIdVsDocument = new Map<String,nm_LinksForDocuments__c>();
        System.debug('enter to update');
        // call method to validate Document Status if Document Status is Disapproved then Reason make Manadtory
        String validationError = ValidateDocumentStatus(linkForDocumentId,documentStatus,docQuery,reasonIfDisapproved);
        if(String.isNotBlank(validationError)) {
            return validationError;
        }
        
        mapDocumentIdVsDocument = (Map<String,nm_LinksForDocuments__c>)JSON.deserialize(jsonMapDocumentIdVsDocument,Map<String,nm_LinksForDocuments__c>.class);
        System.debug('mapDocumentIdVsDocument '+mapDocumentIdVsDocument);
        if(mapDocumentIdVsDocument.containsKey(linkForDocumentId)) {
            nm_LinksForDocuments__c objDocuments = mapDocumentIdVsDocument.get(linkForDocumentId);
            objDocuments.nm_Status__c = documentStatus;
            if(documentStatus == 'None'){
               objDocuments.nm_Status__c = ''; 
            }
            objDocuments.Document_Query__c = docQuery;
            objDocuments.nm_ReasonforDisapprove__c = reasonIfDisapproved;
            System.debug('objDocuments.id -->'+objDocuments.id);
            System.debug('objDocuments.nm_DocumentName__c+'+objDocuments.nm_DocumentName__c);
            System.debug('objDocuments.nm_DocumentLink__c +'+objDocuments.nm_DocumentLink__c );
            if(objDocuments.nm_Status__c == 'Documents incorrect') {
                if(objDocuments.nm_URLforDocuments__c != '' && objDocuments.nm_URLforDocuments__c != null) {
                    String urlvalue = objDocuments.nm_URLforDocuments__c;
                    objDocuments.nm_URLforIncorrectDocuments__c = urlvalue;  
                    
                    if(objDocuments.nm_URLforIncorrectDocuments__c!='' &&  objDocuments.nm_URLforIncorrectDocuments__c !=null) {
                        objDocuments.nm_URLforDocuments__c = '';
                    }
                    objDocuments.DocumentQuerySubmitted__c = System.Today();                       
                }                                 
            } 
            
            if(studStatusForAcc == 'Not Eligible') {
                return 'All documents of this student are approved you cannot set status of this student Not eligible.';
            }

            try{
                update objDocuments;
                updateAccountCordinator(jsonMapUserIdVsCounselorId,objDocuments.nm_Account__c);
                return 'success_'+objDocuments.nm_Status__c;
            }catch(DmlException e){
                System.debug(e.getMessage());
                return e.getMessage();
            }
        } else{
            return 'Document not found for this Id';
        }
    } else {
        return 'You dont have permission for to update this record';
    }
}

@RemoteAction
public static AadhaarXmlParser.ExtractedData getAadhaarData(String url) {
    return AadhaarXmlParser.fetchAndParseXml(url);
}

public static void updateAccountCordinator(String jsonMapUserIdVsCounselorId,String accountId) {
    System.debug('jsonMapUserIdVsCounselorId ==>');
    System.debug(jsonMapUserIdVsCounselorId);
    System.debug(accountId);
    mapUserIdVsCounselorId = (Map<String,String>)JSON.deserialize(jsonMapUserIdVsCounselorId,Map<String,String>.class);
    List<Account> lstAccount = [SELECT id,Admission_Co_ordinator__c	FROM Account WHERE id=:accountId];
    String UserId = UserInfo.getUserId();
    if(mapUserIdVsCounselorId.size() > 0 && lstAccount.size() > 0 && mapUserIdVsCounselorId.containsKey(UserId) && lstAccount[0].Admission_Co_ordinator__c != mapUserIdVsCounselorId.get(UserId)) {
        System.debug('Entered for update');
        lstAccount[0].Admission_Co_ordinator__c = mapUserIdVsCounselorId.get(UserId);
        update lstAccount;
    }
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

/**
* @description
* @author @BK | 25/7/2019
* @param String linkForDocumentId
* @param String documentStatus
* @param String docQuery
* @param String reasonIfDisapproved
* @return String
*/
public static String ValidateDocumentStatus(String linkForDocumentId,String documentStatus,String docQuery, String reasonIfDisapproved) {

    System.debug('ValidateDocumentStatus eneter '+linkForDocumentId + documentStatus+ docQuery + reasonIfDisapproved);
    if(String.isNotBlank(linkForDocumentId) && String.isNotBlank(documentStatus))
    {
        if(documentStatus.equals('Disapproved') && String.isBlank(reasonIfDisapproved))
        {
            return 'Please provide reason for Disapprove';
        }
        
        if(documentStatus.equals('Re-Submited'))
        {
            return 'Please Change status from Re-Submited';
        }

        if(documentStatus.equals('Documents incorrect') && String.isBlank(docQuery))
        {
            return 'Please provide Document Query';
        }

        if(documentStatus.equals('Admission Form & Documents Provisional') && String.isBlank(reasonIfDisapproved)){

            return 'Please provide reason for Documents Provisional';
        }
        return null;
    } else {
        return 'Please provide Document Status';
    }
}

 public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
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