/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 26-11-2024
 * @last modified by  : @BK
**/
global class FindabilityWebService {
    
    webService static String URLMatchvs2(String AccountId,String DocName){
        system.debug('accountId ---> ' + accountId);   
        List<Account> lstAccountsToUpdate = new List<Account>();
        String jsonString ;
        String MatchLink='' ;
        String RegistrationNo='' ;
        String StudentImage='' ;
        Account objAccount = new Account();
        Map<String,String> result = new Map<String, String>();
        
    
        if(String.isNotBlank(DocName) && (DocName =='Aadhaar Card' || DocName == 'Photo ID proof') ){
            List<nm_LinksForDocuments__c> lstLinkDocument = [SELECT Id, nm_Account__r.id,nm_URLforDocuments__c,nm_Account__r.nm_StudentImageUrl__c,nm_Account__r.Student_Image_Url2__c ,nm_Account__r.nm_RegistrationNumber__c,Document_Upload_Mode__c,Updated_document_link__c FROM nm_LinksForDocuments__c WHERE Name =:DocName AND nm_Account__c =:accountId  and nm_URLforDocuments__c!='' ORDER BY CreatedDate DESC LIMIT 1];
            system.debug('lstLinkDocument ---> ' + lstLinkDocument); 
            if(lstLinkDocument.size() > 0){  
                MatchLink = lstLinkDocument[0].Document_Upload_Mode__c == 'Upload via DigiLocker' && String.isNotBlank(lstLinkDocument[0].Updated_document_link__c) ? lstLinkDocument[0].Updated_document_link__c : lstLinkDocument[0].nm_URLforDocuments__c;
                RegistrationNo = lstLinkDocument [0].nm_Account__r.nm_RegistrationNumber__c;
                StudentImage = lstLinkDocument [0].nm_Account__r.nm_StudentImageUrl__c;        
            }
        }else if(String.isNotBlank(DocName) && DocName =='Student Image 2') {
            List<Account> lstAcc =[select id,Student_Image_Url2__c,nm_RegistrationNumber__c,nm_StudentImageUrl__c from Account where id=:accountId and Student_Image_Url2__c!='' limit 1];
            if(lstAcc.size()>0) { 
                MatchLink = lstAcc[0].Student_Image_Url2__c;
                RegistrationNo = lstAcc[0].nm_RegistrationNumber__c;
                StudentImage = lstAcc[0].nm_StudentImageUrl__c;  
            }
        }

        if(MatchLink!=null&& MatchLink!='' ) { 
            result.put('apiKey',system.label.API_KEY_FindabilityFaceMatch);            
            result.put('photoIdLocationLink',MatchLink);
            result.put('regNo',RegistrationNo);
            result.put('photoLocationLink', StudentImage);
            jsonString = System.JSON.serialize(result);
            system.debug('jsonString --->'+jsonString );
            objAccount = postResult(jsonString,AccountId,DocName);
            system.debug('objAccount--->'+objAccount );
                if(objAccount!= null ) {
                    lstAccountsToUpdate.add(objAccount);
                }
        }
                
        if(lstAccountsToUpdate.size() > 0) {
            system.debug('lstAccountsToUpdate--->'+lstAccountsToUpdate);
            update lstAccountsToUpdate;
            if((DocName=='Additional PhotoID' || DocName == 'Photo ID proof') && objAccount.Findability_Message__c !='')
            {
                system.debug('objAccount--->'+objAccount );
                return objAccount.Findability_Message__c;
            }else if (DocName =='Aadhaar Card' && objAccount.Findability_Aadhaar_Card__c!='')
            {
                system.debug('objAccount--->'+objAccount );
                return objAccount.Findability_Aadhaar_Card__c;
            }else if(DocName =='Student Image 2' && objAccount.Findability_Image2__c!='')
            {
                system.debug('objAccount--->'+objAccount );
                return objAccount.Findability_Image2__c;
            }
                return null;
        } else {
            return null;
        }                   
    }

    public static Account postResult(String jsonString, String accId,String DocName) {
        if(String.isNotBlank(jsonString)) {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
        //    String Uri = 'http://dashboard.findabilitysciences.com:5070/FSPhotoIdMatch/api/fsPhotoIdMatch';
            req.setEndpoint(System.label.FaceMatchURL);
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setHeader('Content-Type', 'application/json');
            // req.setHeader('Accept', 'application/json');
            // req.setHeader('End Point', 'api/fsPhotoIdMatch');
            System.debug('jsonstring ==>');
            System.debug(jsonstring);
            req.setBody(jsonstring);
            try {
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('statusCode = '+statusCode);
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                String message = (String)responseBody.get('message');
                System.debug('message --> ' + message);
                if(statusCode == 200) {
                    String accuracyWithMessage = (String)responseBody.get('accuracyWithMessage');
                    Account objAccount = new Account();
                    objAccount.Id = accId;
                    DateTime dt = Datetime.now();
                    String strTimeInAMorPM = dt.format('MMMMM dd, yyyy hh:mm:ss a');
                //  System.debug('time in am and pm ==> '+strTimeInAMorPM); 
                    if(DocName=='Photo ID proof' || DocName=='Additional PhotoID'){
                         objAccount.Findability_Message__c = accuracyWithMessage+' : '+strTimeInAMorPM;
                    }else if(DocName=='Aadhaar Card'){
                        objAccount.Findability_Aadhaar_Card__c = accuracyWithMessage+' : '+strTimeInAMorPM;
                    }else if(DocName=='Student Image 2'){
                        objAccount.Findability_Image2__c = accuracyWithMessage+' : '+strTimeInAMorPM;
                    }
                    return objAccount;

                } else {
                    API_Request__c apiReq = new API_Request__c();
                    apiReq.Account__c = accId;
                    apiReq.API_Name__c = 'Findability API';
                    apiReq.Request__c = jsonString;
                    apiReq.Response__c = resp.getBody();
                    apiReq.Success__c = responseBody.get('message') == 'SUCCESS' ? true : false;
                    insert apiReq;
                    return null;
                }
            }catch (Exception e) {
                System.debug(e);
                return null;
            }
        } else {
            return null;
        }
    }

    webService static String ImageVsPhotoID(String AccountId,String DocName){
        system.debug('accountId ---> ' + accountId);   
        List<Account> lstAccountsToUpdate = new List<Account>();
        String jsonString ;
        String MatchLink='' ;
        String RegistrationNo='' ;
        String StudentImage='' ;
        Account objAccount = new Account();
        Map<String,String> result = new Map<String, String>();

        List<nm_LinksForDocuments__c> lstLinkDocument = [Select Id,Name, nm_Account__r.nm_RegistrationNumber__c, nm_Account__r.Student_Image_Url2__c,nm_Account__r.nm_StudentImageUrl__c,nm_URLforDocuments__c from nm_LinksForDocuments__c where Name =: DocName and nm_URLforDocuments__c !=null and nm_Account__c =:AccountId];
        
        system.debug('lstLinkDocument ---> ' + lstLinkDocument); 
        
        if(lstLinkDocument.size() > 0){ 
            for (nm_LinksForDocuments__c ObjDoc : lstLinkDocument) {
                if(ObjDoc.Name != '' && String.isNotBlank(ObjDoc.nm_URLforDocuments__c)){
                    MatchLink =  ObjDoc.nm_URLforDocuments__c;
                }
            }
            RegistrationNo = lstLinkDocument [0].nm_Account__r.nm_RegistrationNumber__c;
            StudentImage = lstLinkDocument [0].nm_Account__r.Student_Image_Url2__c;
        }
    
           
        if(MatchLink!=null&& MatchLink!='' ) { 
            result.put('apiKey',system.label.API_KEY_FindabilityFaceMatch);            
            result.put('photoIdLocationLink',MatchLink);
            result.put('regNo',RegistrationNo);
            result.put('photoLocationLink', StudentImage);
            jsonString = System.JSON.serialize(result);
            system.debug('jsonString --->'+jsonString );
            objAccount = postResult(jsonString,AccountId ,DocName);
            if(objAccount != null ) {
                lstAccountsToUpdate.add(objAccount);
            }
        }
            
        if(lstAccountsToUpdate.size() > 0) {
            update lstAccountsToUpdate;
            if(objAccount.Findability_Message__c !=''){
                return objAccount.Findability_Message__c;
            }
            return null;
        } else {
            return null;
        }                   
    }

/* public static Account postResults(String jsonString, String accId,String DocName) {
    if(String.isNotBlank(jsonString)) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
    //    String Uri = 'http://dashboard.findabilitysciences.com:5070/FSPhotoIdMatch/api/fsPhotoIdMatch';
        req.setEndpoint(System.label.FaceMatchURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        // req.setHeader('Accept', 'application/json');
        // req.setHeader('End Point', 'api/fsPhotoIdMatch');
        System.debug('jsonstring ==>');
        System.debug(jsonstring);
        req.setBody(jsonstring);
        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('statusCode = '+statusCode);
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            String message = (String)responseBody.get('message');
            System.debug('message --> ' + message);
            if(statusCode == 200) {
                String accuracyWithMessage = (String)responseBody.get('accuracyWithMessage');

                Account objAccount = new Account();
                    objAccount.Id = accId;
                    DateTime dt = Datetime.now();
                    String strTimeInAMorPM = dt.format('MMMMM dd, yyyy hh:mm:ss a');
                //  System.debug('time in am and pm ==> '+strTimeInAMorPM); 
                    objAccount.Findability_Message__c = accuracyWithMessage+' : '+strTimeInAMorPM;
                    return objAccount;

            } else {
                API_Request__c apiReq = new API_Request__c();
                apiReq.Account__c = accId;
                apiReq.API_Name__c = 'Findability API';
                apiReq.Request__c = jsonString;
                apiReq.Response__c = resp.getBody();
                apiReq.Success__c = responseBody.get('message') == 'SUCCESS' ? true : false;
                insert apiReq;
                return null;

            }

        }catch (Exception e) {
            System.debug(e);
            return null;
        }
    } else {
        return null;
    }
}*/
            
    
    // webService static void FSPhotoIDMatchAPI(String lstAccountIds) {
    //     system.debug('lstAccountIds ---> ' + lstAccountIds);
    //     String lstIds = lstAccountIds.contains('{') ? lstAccountIds.substring(1, lstAccountIds.length()-1) : lstAccountIds;
    //     List<String> lstOfAccId = lstIds.split(',');      
    //     List<Account> lstAccountsToUpdate = new List<Account>();
    //     Set<String> setallAccount = new Set<String>();
    //     if(lstOfAccId.size() > 0) {
    //         setallAccount.addAll(lstOfAccId);
    //     }

    //     if(setallAccount.size()>0){
    //            // nm_LinksForDocuments__c objLinksForDocument = new nm_LinksForDocuments__c();
    //             List<nm_LinksForDocuments__c> lstLinkDocument = [SELECT Id, nm_Account__r.id,nm_URLforDocuments__c,nm_Account__r.nm_StudentImageUrl__c, nm_Account__r.nm_RegistrationNumber__c FROM nm_LinksForDocuments__c WHERE Name = 'Photo ID proof' AND nm_Account__c =:setallAccount  and nm_URLforDocuments__c!='' ORDER BY CreatedDate DESC LIMIT 1];
    //             if(lstLinkDocument.size() > 0) {
    //                 for( nm_LinksForDocuments__c objLinksForDocument : lstLinkDocument){
    //                  if(String.isNotBlank(objLinksForDocument.nm_URLforDocuments__c) && String.isNotBlank(objLinksForDocument.nm_Account__r.nm_StudentImageUrl__c)) {
    //                      Map<String,String> result = new Map<String, String>();
    //                    // result.put('apiKey', '39632265c8b57d1413acb49be1e2a385');
    //                    result.put('apiKey',system.label.API_KEY_FindabilityFaceMatch);
    //                     result.put('regNo', objLinksForDocument.nm_Account__r.nm_RegistrationNumber__c);
    //                     result.put('photoLocationLink', objLinksForDocument.nm_Account__r.nm_StudentImageUrl__c);
    //                     result.put('photoIdLocationLink', objLinksForDocument.nm_URLforDocuments__c);
    //                      String jsonString = System.JSON.serialize(result);
    //                      Account objAccount = postResult(jsonString, objLinksForDocument.nm_Account__r.id);
    //                      if(objAccount != null ) {
    //                          lstAccountsToUpdate.add(postResult(jsonString, objLinksForDocument.nm_Account__r.id));
    //                      }
    //                 }
    //             }
    //         }
    //     }
    //     if(lstAccountsToUpdate.size() > 0) {
    //         update lstAccountsToUpdate;
    //     }
    // }

    // webService static String FSPhotoIDMatchAPIForSingle(String accountId) {
    //     system.debug('accountId ---> ' + accountId);   
    //     List<Account> lstAccountsToUpdate = new List<Account>();
    //     Set<String> setallAccount = new Set<String>();

    //     if(String.isNotBlank(accountId)){
    //             List<nm_LinksForDocuments__c> lstLinkDocument = [SELECT Id, nm_Account__r.id,nm_URLforDocuments__c,nm_Account__r.nm_StudentImageUrl__c, nm_Account__r.nm_RegistrationNumber__c FROM nm_LinksForDocuments__c WHERE Name = 'Photo ID proof' AND nm_Account__c =:accountId  and nm_URLforDocuments__c!='' ORDER BY CreatedDate DESC LIMIT 1];
    //             if(lstLinkDocument.size() > 0) {
    //                 for( nm_LinksForDocuments__c objLinksForDocument : lstLinkDocument){
    //                  if(String.isNotBlank(objLinksForDocument.nm_URLforDocuments__c) && String.isNotBlank(objLinksForDocument.nm_Account__r.nm_StudentImageUrl__c)) {
    //                      Map<String,String> result = new Map<String, String>();
    //                    // result.put('apiKey', '39632265c8b57d1413acb49be1e2a385');
    //                    result.put('apiKey',system.label.API_KEY_FindabilityFaceMatch);
    //                     result.put('regNo', objLinksForDocument.nm_Account__r.nm_RegistrationNumber__c);
    //                     result.put('photoLocationLink', objLinksForDocument.nm_Account__r.nm_StudentImageUrl__c);
    //                     result.put('photoIdLocationLink', objLinksForDocument.nm_URLforDocuments__c);
    //                      String jsonString = System.JSON.serialize(result);
    //                      Account objAccount = postResult(jsonString, objLinksForDocument.nm_Account__r.id);
    //                      if(objAccount != null ) {
    //                         lstAccountsToUpdate.add(postResult(jsonString, objLinksForDocument.nm_Account__r.id));
    //                      }
    //                 }
    //             }
    //         }
    //     }

       
    //     if(lstAccountsToUpdate.size() > 0) {
    //         update lstAccountsToUpdate;
    //         return lstAccountsToUpdate[0].Findability_Message__c;
    //     } else {
    //         return null;
    //     }
    // }

//     webService static String URLMatch(String AccountId,String Name){
//         system.debug('accountId ---> ' + accountId);   
//         List<Account> lstAccountsToUpdate = new List<Account>();
//         Set<String> setallAccount = new Set<String>();
//         if(String.isNotBlank(accountId)){
//                 List<nm_LinksForDocuments__c> lstLinkDocument = [SELECT Id, nm_Account__r.id,nm_URLforDocuments__c,nm_Account__r.nm_StudentImageUrl__c,nm_Account__r.Student_Image_Url2__c ,nm_Account__r.nm_RegistrationNumber__c FROM nm_LinksForDocuments__c WHERE ((Name = 'Photo ID proof') OR (Name ='Aadhaar Card')) AND nm_Account__c =:accountId  and nm_URLforDocuments__c!='' ORDER BY CreatedDate DESC LIMIT 1];
//                 system.debug('lstLinkDocument ---> ' + lstLinkDocument); 
//                 String Matchlink ='';
//                if(lstLinkDocument.size() > 0){
//                 Matchlink = lstLinkDocument [0].nm_URLforDocuments__c;
//                }
                
//                 if(lstLinkDocument.size() > 0) {
//                     for( nm_LinksForDocuments__c objLinksForDocument : lstLinkDocument){
//                      if(String.isNotBlank(objLinksForDocument.nm_URLforDocuments__c) && String.isNotBlank(objLinksForDocument.nm_Account__r.Student_Image_Url2__c)) {
//                          Map<String,String> result = new Map<String, String>();
//                          result.put('apiKey',system.label.API_KEY_FindabilityFaceMatch);
//                          result.put('regNo', objLinksForDocument.nm_Account__r.nm_RegistrationNumber__c);
//                          result.put('photoLocationLink', objLinksForDocument.nm_Account__r.nm_StudentImageUrl__c);
//                          result.put('photoIdLocationLink',Matchlink);
//                          String jsonString = System.JSON.serialize(result);
//                          Account objAccount = postResult(jsonString, objLinksForDocument.nm_Account__r.id);
//                          if(objAccount != null ) {
//                             lstAccountsToUpdate.add(postResult(jsonString, objLinksForDocument.nm_Account__r.id));
//                          }
//                     }
//                 }
//             }
          
//     }
//     if(lstAccountsToUpdate.size() > 0) {
//         update lstAccountsToUpdate;
//         return lstAccountsToUpdate[0].Findability_Image2__c;
//     } else {
//         return null;
//     }

// }

    // public static Account postResult(String jsonString, String accId) {
    //     if(String.isNotBlank(jsonString)) {
    //         HttpRequest req = new HttpRequest();
    //         HttpResponse resp = new HttpResponse();
    //         Http http = new Http();
    //     //    String Uri = 'http://dashboard.findabilitysciences.com:5070/FSPhotoIdMatch/api/fsPhotoIdMatch';
    //         req.setEndpoint(System.label.FaceMatchURL);
    //         req.setMethod('POST');
    //         req.setHeader('Content-Type', 'application/json');
    //         // req.setHeader('Accept', 'application/json');
    //         // req.setHeader('End Point', 'api/fsPhotoIdMatch');
    //         System.debug('jsonstring ==>');
    //         System.debug(jsonstring);
    //         req.setBody(jsonstring);
    //         try {
    //             resp = http.send(req);
    //             Integer statusCode = resp.getStatusCode();
    //             System.debug('statusCode = '+statusCode);
    //             Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
    //             String message = (String)responseBody.get('message');
    //             System.debug('message --> ' + message);
    //             if(statusCode == 200) {
    //                 String accuracyWithMessage = (String)responseBody.get('accuracyWithMessage');
                    

    //                 Account objAccount = new Account();
    //                 objAccount.Id = accId;
    //                 objAccount.Findability_Message__c = accuracyWithMessage;
    //                 return objAccount;

    //             } else {
    //                 API_Request__c apiReq = new API_Request__c();
    //                 apiReq.Account__c = accId;
    //                 apiReq.API_Name__c = 'Findability API';
    //                 apiReq.Request__c = jsonString;
    //                 apiReq.Response__c = resp.getBody();
    //                 apiReq.Success__c = responseBody.get('message') == 'SUCCESS' ? true : false;
    //                 insert apiReq;
    //                 return null;

    //             }

    //         }catch (Exception e) {
    //             System.debug(e);
    //             return null;
    //         }
    //     } else {
    //         return null;
    //     }
    // }


}