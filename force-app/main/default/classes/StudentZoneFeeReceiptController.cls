public without sharing class StudentZoneFeeReceiptController {
  public String strStudentNo{get;set;}
  public String strStudentSem{get;set;}
  public Map<String,String> mapOfStudentSem {get;set;}
  
  public StudentZoneFeeReceiptController()
  {
      strStudentNo=apexpages.currentpage().getparameters().get('StudentNo');
      strStudentSem=apexpages.currentpage().getparameters().get('Sem'); 
      mapOfStudentSem =new map<String,String>();
      // get all data from SFDC related to Account and Put it in Map then Query Particualr Account Based Upon Student Number and Semester
      GetData();
  }
  
  public void GetData()
  {
      String Key;
      List<nm_Payment__c> lstPayment =[select id,nm_Amount__c,nm_OpportunityNew__r.Account.nm_StudentNo__c,nm_OpportunityNew__r.nm_Semester__c from nm_Payment__c where (NOT nm_OpportunityNew__r.Account.nm_StudentNo__c Like 'Lost_%') and (NOT nm_OpportunityNew__r.Account.nm_StudentNo__c Like 'Cancel_%') and nm_PaymentType__c ='Admission' and nm_PaymentStatus__c ='Payment Approved' and nm_OpportunityNew__r.Account.nm_StudentNo__c =:strStudentNo];
      for(nm_Payment__c objPayment :lstPayment)
      {
        Key =objPayment.nm_OpportunityNew__r.Account.nm_StudentNo__c +'-'+objPayment.nm_OpportunityNew__r.nm_Semester__c;
        mapOfStudentSem.put(Key,objPayment.id);
      }
     
     if(!mapOfStudentSem.containsKey(strStudentNo+'-'+strStudentSem))
     {
        mapOfStudentSem.put(strStudentNo+'-'+strStudentSem,'N');
        System.debug('No Such Type Of Payment Record Found--->'+mapOfStudentSem.get(strStudentNo+'-'+strStudentSem));
     }  
        System.debug('------>'+strStudentNo+'-'+strStudentSem);
  } 
    
}