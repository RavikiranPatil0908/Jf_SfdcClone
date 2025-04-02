/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10--03--2025
 * @last modified by  : @Ravi
**/
public without sharing class UpdateInternalCaseOwner {
    
   
    public static Boolean isAEPUser { get; set; } 
    public static String studentNumber { get; set; }

    public UpdateInternalCaseOwner(){
        isAEPUser=false;
        studentNumber='';
    }

    /**
    * @description 
    * @author @BK | 12-07-2024 
    * @param String caseId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean caseTransfer(String caseId , Boolean isAEPUser , String studentNumber ) {
        System.debug('Case Id --> ' + caseId);
        try {
            Map<String,String> mapCategoryVsUserNames = new Map<String,String>{
                'Finance' => 'Finance Department',
                'Marketing' => 'Mihhiir Lakhani' ,
                'Admissions' => 'Admission Dept.',
                'TEE' => 'NCDOE Exams - University',
                'Internal Exam' => 'Ngasce Exams',
                'Academics' => 'Ngasce Academics',
                'Career Services' => 'Varun Mathur',
                'Product' => 'Likesh Bhambhwani',
                'Logistics' => 'Logistics Department',
                'Student Support' => 'Sangeeta Shetty',
                'Bhaumik' => 'Bhaumik Shah',
                'Likesh' => 'Likesh Bhambhwani',
                'Snehal' => 'Snehal Paddalwar',
                'LC Mumbai' => 'LC Mumbai',
                'LC Lucknow' => 'LC Lucknow',
                'LC Chandigarh' => 'LC Chandigarh',
                'LC Ahmedabad' => 'LC Ahmedabad',
                'LC Hyderabad' => 'LC Hyderabad',
                'LC Indore' => 'LC Indore',
                'LC Bangalore' => 'LC Bangalore',
                'LC Pune' => 'LC Pune',
                'LC Kolkata' => 'LC Kolkata',
                'LC Delhi' => 'LC Delhi',
                'LC Chennai' => 'LC Chennai'
            };
                
            List<Case> lstCase = [SELECT id,FirstCaseAssigned__c,OwnerId,Status,Owner.Name,InternalCategory__c,CreatedBy.Name,sub_categories__c,RecordTypeId,InternalSub_Category__c FROM Case WHERE id=:caseId  LIMIT 1];
            if(lstCase.size() > 0) {
                String productCategoryUserName = lstCase[0].CreatedBy.Name;
                System.debug('Product category user name -->'+ productCategoryUserName);
                String category = lstCase[0].InternalCategory__c;
                System.debug('Case category --> ' + category);

                if(category == 'AEP Request') {
                    System.debug('isAEPUser::::'+isAEPUser);
                    string ownerName = UpdateInternalCaseOwner.transferAEPReqtoRespectiveLC( lstCase[0] , isAEPUser , studentNumber);
                    return updateCase(lstCase[0], category, ownerName ,productCategoryUserName );
                }

                // if(category == 'AEP Request' && isAEPUser == false) {
                //     
   
                // }}

                if(mapCategoryVsUserNames.containsKey(category) && category != 'AEP Request') {
                    category = getProductUser(category, productCategoryUserName);
                    System.debug('Updated category -->'+ category);
                    return updateCase(lstCase[0], category, mapCategoryVsUserNames.get(category), productCategoryUserName);
                }
            }
        } catch (Exception error) {
            System.debug('Error ==>'+ error.getMessage());
            System.debug('Error Line No :==>'+ error.getLineNumber());
        }
        return false;
    }


    /**
    * @description 
    * @author @BK | 12-07-2024 
    * @param Case objCase 
    * @param String category 
    * @param String userName 
    * @param String productCategoryUserName 
    * @return Boolean 
    **/
    public static Boolean updateCase(Case objCase, String category, String userName, String productCategoryUserName) {
        try {
            System.debug('User name: ' + userName);

            Boolean isOwnerChanged = false;
            
            // Query all users with the specified userName
            List<User> lstUser = [SELECT Id, Name, IsActive, Profile.Name FROM User WHERE Name = :userName];
            String userId = null;
            if(!lstUser.isEmpty()) {
                userId = lstUser[0].Id;
            }
    
            // Handle the 'Admissions' category specifically
            if (category == 'Admissions') {
                List<Group> lstQueues = [SELECT Id,Name,DeveloperName,Email,Type FROM Group WHERE Type='Queue' AND Name='Admissions Team' LIMIT 1];
                if(!lstQueues.isEmpty()) {
                    objCase.OwnerId = lstQueues[0].Id;
                    isOwnerChanged = true;
                }
            } else {
                // For other categories, set the owner from the userMap if available
                if (String.isNotBlank(userId)) {
                    objCase.OwnerId = userId;
                    isOwnerChanged = true;
                }
            }
    
            // Update the case if OwnerId was changed
            if (isOwnerChanged) {
                update objCase;
                System.debug('Case transfer result ==> true');
                return true;
            }
    
            System.debug('Case transfer result ==> false');
            return false;
    
        } catch (Exception error) {
            // Log the error message and line number for debugging
            System.debug('Error: ' + error.getMessage());
            System.debug('Error Line Number: ' + error.getLineNumber());
            return false;
        }
    }

    /**
    * @description 
    * @author @BK | 12-07-2024 
    * @param String category 
    * @param String userName 
    * @return String 
    **/
    public static String getProductUser(String category, String userName) {
        if(category == 'Product') {  
            category = 'Bhaumik';
            // if(userName.startsWith('LC ') || userName.contains('NCDOE Exams - University') 
            //     || userName.contains('Ngasce Exams') || userName.contains('Varun Mathur') 
            //     || userName.contains('Rajshree Pawar'))
            // {
            //     category = 'Harshad';
            // }

            // if(userName.contains('Finance Department') || userName.contains('Admission Dept.')) {
            //     category = 'Snehal';
            // }
        }
        return category;
    }

    /**
    * @description 
    * @author @BK | 13-07-2024 
    * @return String 
    **/
    @AuraEnabled
    public static String getLCName(){
        try {
             Id userId = UserInfo.getUserId();
            System.debug('userId: ' + userId);  
            List<nm_UserMapping__c> lst = [SELECT id,nm_Centers__r.Owner.Name FROM nm_UserMapping__c WHERE nm_User__c=:userId LIMIT 1];
            if(lst.size() > 0) {
                
                return lst[0].nm_Centers__r.Owner.Name;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 13-07-2024 
    * @param Case objCase 
    * @return String 
    **/
    @AuraEnabled
    public static String createCase(Case objCase){
        try {
            insert objCase;
            return objCase.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    
    /**
    * @description 
    * @author @Ravi | 09-04-2024 
    * @param sapId 
    * @return String 
    **/
    @AuraEnabled
    public static String verifyStudentAccount(String sapId , Boolean isAEP) {
        try {
            System.debug('isAEP in class :::'+isAEP);
            studentNumber = sapId;
            Id userId = UserInfo.getUserId();
            if (isAEP) {
                List<Account> lstStdAccForAEPReq = [SELECT Id, Name, nm_StudentNo__c, OwnerId FROM Account WHERE nm_StudentNo__c = :sapId AND OwnerId= :userId LIMIT 1];
                if(lstStdAccForAEPReq.size() > 0) {
                    System.debug('Account ID : ' + lstStdAccForAEPReq[0].Id);
                      return lstStdAccForAEPReq[0].Id;
                }   
            } else {
                //check student acc is valid and  user has read access
                 List<Account> lstStdAccForOtherUserReq = [SELECT Id, Name, nm_StudentNo__c, OwnerId FROM Account WHERE nm_StudentNo__c = :sapId  LIMIT 1];
                          
                 List<UserRecordAccess>  readAccessRecords = [SELECT RecordId FROM UserRecordAccess  WHERE RecordId = :lstStdAccForOtherUserReq[0].Id AND UserId = :userId AND HasReadAccess = true  LIMIT 1 ];
                   
                if(readAccessRecords.size() > 0) {
                    System.debug('Account ID : ' + readAccessRecords[0].Id);
                    return  readAccessRecords[0].Id;
                }     
            }    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
       return null;
}



   /**
   * @description 
   * @author @Ravi | 10--03--2025 
   * @param objCase 
   * @param isAepUser 
   * @param studentNumber 
   * @return String 
   **/
   public static String transferAEPReqtoRespectiveLC(Case objCase , Boolean isAepUser , string studentNumber) {
        String ownerName = '';       
           if(isAepUser) {
            ownerName = UpdateInternalCaseOwner.getLCName();
                    System.debug('ownerName --> ' + ownerName);   
                    return ownerName ;
           } else {
               //transfer AEP request to respective LC based on student account number
               List<Account> lstStdAccForAEPReq = [SELECT Id, Name, nm_Centers__r.Owner.Name , nm_Centers__r.RecordType.Name  FROM Account WHERE nm_StudentNo__c = :studentNumber LIMIT 1];       
               
               if(lstStdAccForAEPReq.size() > 0) {
                         ownerName = lstStdAccForAEPReq[0].nm_Centers__r.Owner.Name;
                        System.debug('ownerName -->'+ ownerName);
                    }
                    return ownerName;
           }  
}
}