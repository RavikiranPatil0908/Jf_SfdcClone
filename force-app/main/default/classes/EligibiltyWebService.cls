global  class EligibiltyWebService {
  
    webService static  void addAdmissionCordinator(String RecId) { 
        System.debug('Entered in addAdmissionCordinator Method');

       List <Account> lstAccounts = [SELECT id,nm_ProgramType__c,nm_ChooseaProgram__c,Program_Type__c,nm_StudentStatus__c,Admission_Co_ordinator__c,nm_DocumentSubmittedDate__c FROM Account where Id=:RecId];
        Map<String,List<String>> mapOfProgramVsProfiles = new Map<String,List<String>>();
        List<Account> lstOfAccountUpdate = new List<Account>();
        Map<String,Integer> mapOfProfileVsCount = new Map<String,Integer>();
        List<Account> lstAssignedAccount = [SELECT id,Admission_Co_ordinator__c,nm_ProgramType__c,Program_Type__c FROM Account WHERE nm_StudentStatus__c!='Documents Re-submitted' AND Admission_Co_ordinator__c!=null AND nm_DocumentSubmittedDate__c=TODAY];
        List<Counsellor_Profile__c> lstProfile = [SELECT id,Program_Offered__c FROM Counsellor_Profile__c WHERE IsActive__c=false AND BusinessAccount__r.Name='Head Office'];
        if(lstProfile.size() > 0) {
            for (Counsellor_Profile__c objProfile : lstProfile) {
                String programOffered = objProfile.Program_Offered__c;
                List<String> lstProgramOffered = String.isNotBlank(programOffered) ? programOffered.split(';') : new List<String>();
                for(String program : lstProgramOffered) {
                    List<String> lstProfileId = mapOfProgramVsProfiles.containsKey(program) ? mapOfProgramVsProfiles.get(program) : new List<String>();
                    lstProfileId.add(objProfile.id);
                    mapOfProgramVsProfiles.put(program,lstProfileId);
                }
            }
            System.debug('mapOfProgramVsProfiles.size() ==>'+mapOfProgramVsProfiles.size());
        }

        if(lstAssignedAccount.size() > 0) {
            for(Account objAcc : lstAssignedAccount) {
                mapOfProfileVsCount = updateMapProfileVsCount(mapOfProfileVsCount,objAcc.Admission_Co_ordinator__c);
            }
        }
        
        for(Account objAcc : lstAccounts) {
            String programName = objAcc.nm_ChooseaProgram__c == 'Master Programs' ? objAcc.Program_Type__c : objAcc.nm_ChooseaProgram__c;
            System.debug('programName ==>'+programName);
            if(mapOfProgramVsProfiles.containsKey(programName)) {
                Account objAccountUpdate = new Account();
                objAccountUpdate.id = objAcc.id;
                List<String> lstProfileId = mapOfProgramVsProfiles.get(programName);
                System.debug('lstProfileId size ==>'+lstProfileId.size());
                System.debug('lstProfileId ==>'+lstProfileId);
                if(lstProfileId.size() > 1 && mapOfProfileVsCount.size() > 0) {
                    System.debug('Entered if condition');
                    String lowKey = mapOfProfileVsCount.isEmpty() ? null : new List<String>(mapOfProfileVsCount.keySet())[0];
                    String noKey = null;
                    for (String profileId : lstProfileId) {
                        if(mapOfProfileVsCount.containsKey(profileId)) {
                            lowKey = mapOfProfileVsCount.containsKey(profileId) && mapOfProfileVsCount.get(profileId) < mapOfProfileVsCount.get(lowKey) ? profileId : lowKey;
                        } else {
                            noKey = profileId;
                            break;
                        }
                    }
                    objAccountUpdate.Admission_Co_ordinator__c = String.isNotBlank(noKey) ? noKey : lowKey;
                } else {
                    System.debug('Entered else condition');
                    objAccountUpdate.Admission_Co_ordinator__c = lstProfileId[0];
                    System.debug('Random element: '+lstProfileId[0]);
                }
                lstOfAccountUpdate.add(objAccountUpdate);
                mapOfProfileVsCount = updateMapProfileVsCount(mapOfProfileVsCount,objAccountUpdate.Admission_Co_ordinator__c);
            }
        }

        if(lstOfAccountUpdate.size() > 0) {
            update lstOfAccountUpdate;
        }

    }


    public static  Map<String,Integer> updateMapProfileVsCount(Map<String,Integer> mapOfProfileVsCount, String recId) {
        Integer count = mapOfProfileVsCount.containsKey(recId) ? mapOfProfileVsCount.get(recId) : 0;
        count++;
        mapOfProfileVsCount.put(recId,count);
        return mapOfProfileVsCount;
    }
    
    
}