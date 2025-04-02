/**
 * @File Name          : SforceOpportunityRevisedController.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 12/21/2019, 1:47:40 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/16/2019   shubhranshu     Initial Version
**/
public without sharing class SforceOpportunityRevisedController {

    /**
    * @description 
      check AEP with its vendorcode and customercode with allow for SforceOpportunity 
    * @author shubhranshu | 12/19/2019 
    * @param vendorId 
    * @return nm_Centers__c 
    **/
    @AuraEnabled
    public static nm_Centers__c searchVendor(String emailId, String password){
        System.debug('emailId '+emailId +' password '+password);
        if(String.isNotBlank(emailId) && String.isNotBlank(password)) {
            return  [SELECT id FROM nm_Centers__c WHERE Email__c=:emailId AND Password__c=:password AND Allow_for_SforceOpportunity__c=true LIMIT 1];
        }
        return null;
        
    }

    /**
    * @description 
      filter the query on the basis of search string and get the finalize opportunity list data
    * @author shubhranshu | 12/19/2019 
    * @param pagenumber 
    * @param numberOfRecords 
    * @param pageSize 
    * @param searchString 
    * @param centerId 
    * @return List<Opportunity> 
    **/
    @AuraEnabled(cacheable = true)  
    public static List<Opportunity> getOpportunityList(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String searchString, String centerId) {  
        if(String.isNotBlank(centerId)) {
            String query = 'SELECT id,Name,nm_Semester__c,Loan_Type__c,Down_Payment_Made__c,Loan_Amount__c,Loan_Order_Id__c,Loan_Order_Status__c,EduVanz_Current_Stage_Name__c,ChooseProgram__c,nm_Session__c,nm_Year__c,Account.nm_Centers__c,StageName,nm_Fee_Type__c,nm_Program__c,nm_Program__r.Name,Account.nm_StudentStatus__c,Account.nm_StudentNo__c,' +
            ' Choose_a_Program__c,Actual_Amount__c,Total_Amount_Received__c,ActualPendingAmount__c,Dispatch_Order_For_Student__c,Program_Name__c,Launch_Year__c,Fee_Receipt_Dispatched_Date__c,Fee_Receipt_Dispatched__c,Final_Status_Of_Dispatch__c,nm_SelfLearningMaterial__c,' +
            ' Delivery_Date_time__c,Other_Courier_Service_Opportunity__c,No_Of_Attempt__c,Opportunity_Status__c,Next_Follow_Up_Date_Time__c,Opportunity_Description__c,Is_Re_Registration_Payment__c,History_Tracking__c,DescriptionforOther__c,' +
            ' Account.Name,Account.Valid_Upto__c,Account.PersonEmail,Account.PersonMobilePhone FROM Opportunity WHERE Account.nm_StudentStatus__c =\'Confirmed\' AND Account.nm_Centers__c=:centerId AND Is_Re_Registration_Payment__c = true AND StageName != \'Closed Lost\' AND StageName != \'Closed Won\'';
    
            if (String.isNotBlank(searchString)) {  
                Map<String,Object> mapOfSearchParameters = (Map<String,Object>)Json.deserializeuntyped(searchString);
                if(mapOfSearchParameters.containsKey('studentName') && mapOfSearchParameters.get('studentName') != null && mapOfSearchParameters.get('studentName') != ''){
                    String studentName = (String)mapOfSearchParameters.get('studentName');
                    query = query + ' AND Account.Name LIKE \'%' + studentName + '%\' ';
                }
                if(mapOfSearchParameters.containsKey('studentNo') && mapOfSearchParameters.get('studentNo') != null && mapOfSearchParameters.get('studentNo') != ''){
                    String studnetNo = (String)mapOfSearchParameters.get('studentNo');
                    query = query + ' AND Account.nm_StudentNo__c =:studnetNo ';
                }
                if(mapOfSearchParameters.containsKey('name') && mapOfSearchParameters.get('name') != null && mapOfSearchParameters.get('name') != ''){
                    String oppName = (String)mapOfSearchParameters.get('name');
                    query = query + ' AND Name LIKE \'%' + oppName + '%\' ';
                }
                if(mapOfSearchParameters.containsKey('semester') && mapOfSearchParameters.get('semester') != null && mapOfSearchParameters.get('semester') != ''){
                    String sem = (String)mapOfSearchParameters.get('semester');
                    query = query + ' AND nm_Semester__c =:sem ';
                }
                if(mapOfSearchParameters.containsKey('session') && mapOfSearchParameters.get('session') != null && mapOfSearchParameters.get('session') != ''){
                    String oppSession = (String)mapOfSearchParameters.get('session');
                    query = query + ' AND nm_Session__c =:oppSession ';
                }
                if(mapOfSearchParameters.containsKey('year') && mapOfSearchParameters.get('year') != null && mapOfSearchParameters.get('year') != ''){
                    Integer oppYear = Integer.valueOf(mapOfSearchParameters.get('year'));
                    query = query + ' AND nm_Year__c =:oppYear ';
                }
                if(mapOfSearchParameters.containsKey('oppStage') && mapOfSearchParameters.get('oppStage') != null && mapOfSearchParameters.get('oppStage') != ''){
                    String opportunitySatge = (String)(mapOfSearchParameters.get('oppStage'));
                    query = query + ' AND StageName =:opportunitySatge ';
                }
                if(mapOfSearchParameters.containsKey('chooseProgram') && mapOfSearchParameters.get('chooseProgram') != null && mapOfSearchParameters.get('chooseProgram') != ''){
                    String ChooseProrgramName = (String)(mapOfSearchParameters.get('chooseProgram'));
                    query = query + ' AND ChooseProgram__c =:ChooseProrgramName';
                }
            }

            query += ' LIMIT ' + pageSize + ' OFFSET ' + (pageSize * (pagenumber - 1));  
            return Database.query(query);  
        }
        return null;
    }  

    /**
    * @description 
      get opportunity count on the basis of searchstring and center id
    * @author shubhranshu | 12/19/2019 
    * @param searchString 
    * @param centerId 
    * @return Integer 
    **/
    @AuraEnabled(cacheable = true)  
    public static Integer getOpportunityCount(String searchString, String centerId) {
        if(String.isNotBlank(centerId)) {
            String query = 'SELECT count() FROM Opportunity WHERE Account.nm_StudentStatus__c =\'Confirmed\' AND Account.nm_Centers__c=:centerId AND Is_Re_Registration_Payment__c = true AND StageName != \'Closed Lost\' AND StageName != \'Closed Won\'';
            if (String.isNotBlank(searchString)) {  
                Map<String,Object> mapOfSearchParameters = (Map<String,Object>)Json.deserializeuntyped(searchString);
                if(mapOfSearchParameters.containsKey('studentName') && mapOfSearchParameters.get('studentName') != null && mapOfSearchParameters.get('studentName') != ''){
                    String studentName = (String)mapOfSearchParameters.get('studentName');
                    query = query + ' AND Account.Name LIKE \'%' + studentName + '%\' ';
                }
                if(mapOfSearchParameters.containsKey('studentNo') && mapOfSearchParameters.get('studentNo') != null && mapOfSearchParameters.get('studentNo') != ''){
                    String studnetNo = (String)mapOfSearchParameters.get('studentNo');
                    query = query + ' AND Account.nm_StudentNo__c =:studnetNo ';
                }
                if(mapOfSearchParameters.containsKey('name') && mapOfSearchParameters.get('name') != null && mapOfSearchParameters.get('name') != ''){
                    String oppName = (String)mapOfSearchParameters.get('name');
                    query = query + ' AND Name LIKE \'%' + oppName + '%\' ';
                }
                if(mapOfSearchParameters.containsKey('semester') && mapOfSearchParameters.get('semester') != null && mapOfSearchParameters.get('semester') != ''){
                    String sem = (String)mapOfSearchParameters.get('semester');
                    query = query + ' AND nm_Semester__c =:sem ';
                }
                if(mapOfSearchParameters.containsKey('session') && mapOfSearchParameters.get('session') != null && mapOfSearchParameters.get('session') != ''){
                    String oppSession = (String)mapOfSearchParameters.get('session');
                    query = query + ' AND nm_Session__c =:oppSession ';
                }
                if(mapOfSearchParameters.containsKey('year') && mapOfSearchParameters.get('year') != null && mapOfSearchParameters.get('year') != ''){
                    Integer oppYear = Integer.valueOf(mapOfSearchParameters.get('year'));
                    query = query + ' AND nm_Year__c =:oppYear ';
                }
                if(mapOfSearchParameters.containsKey('oppStage') && mapOfSearchParameters.get('oppStage') != null && mapOfSearchParameters.get('oppStage') != ''){
                    String opportunitySatge = (String)(mapOfSearchParameters.get('oppStage'));
                    query = query + ' AND StageName =:opportunitySatge ';
                }
                if(mapOfSearchParameters.containsKey('chooseProgram') && mapOfSearchParameters.get('chooseProgram') != null && mapOfSearchParameters.get('chooseProgram') != ''){
                    String ChooseProrgramName = (String)(mapOfSearchParameters.get('chooseProgram'));
                    query = query + ' AND ChooseProgram__c =:ChooseProrgramName';
                }
            }  
            return Database.countQuery(query);  
        }  
        return 0;
        
    } 

    /**
    * @description 
     update opportunity with opportunity id
    * @author shubhranshu | 12/19/2019 
    * @param opp 
    * @param oppId 
    * @return Opportunity 
    **/
    @AuraEnabled
    public static Opportunity updateOpportunity(Opportunity opp,String oppId){
        System.debug('opp '+opp+' oppId '+oppId);
        try{ 
            opp.id = oppId;
            update opp;
            System.debug('Opportunity is updated...');
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return opp;
    }

    /**
    * @description 
      geerate token using student no.
    * @author shubhranshu | 12/19/2019 
    * @param sapId 
    * @return String 
    **/
    @AuraEnabled
    public static String getToken(String sapId)
    {
        // generate Time Token
        DateTime myDateTime = DateTime.now();
        Blob key = EncodingUtil.base64Decode(Label.studentZone_PrivateKey); // privateKey
        Blob data = Blob.valueOf(sapId+'~'+myDateTime.getTime());
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);
        String token = EncodingUtil.base64Encode(encryptedData);
        String urlEncodedToken = EncodingUtil.urlEncode(token, 'UTF-8');
        urlEncodedToken = EncodingUtil.urlDecode(urlEncodedToken, 'UTF-8');
        return urlEncodedToken ;
    }       

}