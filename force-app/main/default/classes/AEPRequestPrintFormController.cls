public with sharing class AEPRequestPrintFormController {
  public AEP_Request__c objAEPRequest { get; set; }
  public Lead objLead { get; set; }
  public Account objAccount { get; set; }
  public String AepRequestId { get; set; }
  public String AccountId { get; set; }
  public String LeadId { get; set; }
  public List<nm_WorkExperience__c> lstWorkExperience { get; set; }
  public Integer workExperienceLength { get; set; }

  public AEPRequestPrintFormController() {
    objAEPRequest = null;
    AepRequestId = null;
    objAccount = null;
    AccountId = null;
    objLead = null;
    LeadId = null;
    workExperienceLength = 0;
    lstWorkExperience = new List<nm_WorkExperience__c>();
    AepRequestId = ApexPages.currentPage().getParameters().get('id');
    system.debug(AepRequestId);
    if (AepRequestId != '' && AepRequestId != null) {
      getAepRequestField();
    }
    if (AccountId != null && AccountId != '') {
      getAccountFields();
      getWorkExperienceFieldInAccount();
    } else if (LeadId != null && LeadId != '') {
      getLeadFields();
      getWorkExperienceFieldInLead();
    }
    System.debug(objAEPRequest);
  }

  public String getQueryAllFieldSql(String ObjectAPIName, String conditionString) {
    Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
    Map<String, schema.SObjectField> fieldMap = scemapMap.get(ObjectAPIName).getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());

    String query = 'Select ' + String.join(fieldNames, ',') + ' from ' + ObjectAPIName + ' where ' + conditionString;
    return query;
  }

  public void getAepRequestField() {
    String AepRequestQuery = getQueryAllFieldSql('AEP_Request__c', 'Id=:AepRequestId');
    System.debug('AepRequestQuery ==>' + AepRequestQuery);
    List<AEP_Request__c> lstAEPRequestRecord = DataBase.query(AepRequestQuery);
    if (lstAEPRequestRecord.size() > 0) {
      objAEPRequest = lstAEPRequestRecord[0];
      if (lstAEPRequestRecord[0].Student__c != null) {
        AccountId = lstAEPRequestRecord[0].Student__c;
      } else if (lstAEPRequestRecord[0].Lead__c != null) {
        LeadId = lstAEPRequestRecord[0].Lead__c;
      }
    }
  }

  public void getAccountFields() {
    String AccountQuery = getQueryAllFieldSql('Account', 'Id=:AccountId');
    List<Account> lstAccountRecord = Database.query(AccountQuery);
    if (lstAccountRecord.size() > 0) {
      objAccount = lstAccountRecord[0];
    }
  }
  public void getLeadFields() {
    String LeadQuery = getQueryAllFieldSql('Lead', 'Id=:LeadId');
    List<Lead> lstLeadRecord = Database.query(LeadQuery);
    if (lstLeadRecord.size() > 0) {
      objLead = lstLeadRecord[0];
    }
  }

  public void getWorkExperienceFieldInAccount() {
    List<nm_WorkExperience__c> lstWorkExperienceObj = [
      SELECT id, nm_CompanyName__c, nm_Designation__c, Currently_Working_Here__c, nm_TotalMonths__c, nm_StartDate__c
      FROM nm_WorkExperience__c
      WHERE nm_Student__c = :AccountId
      ORDER BY nm_StartDate__c ASC
    ];
    if (lstWorkExperienceObj.size() > 0) {
      system.debug(lstWorkExperienceObj);
      lstWorkExperience.addAll(lstWorkExperienceObj);
      workExperienceLength = lstWorkExperienceObj.size();
      system.debug(lstWorkExperience);
    }
  }
  public void getWorkExperienceFieldInLead() {
    List<nm_WorkExperience__c> lstWorkExperienceObj = [
      SELECT id, nm_CompanyName__c, nm_Designation__c, Currently_Working_Here__c, nm_TotalMonths__c, nm_StartDate__c
      FROM nm_WorkExperience__c
      WHERE nm_Lead__c = :LeadId
      ORDER BY nm_StartDate__c ASC
    ];
    if (lstWorkExperienceObj.size() > 0) {
      system.debug(lstWorkExperienceObj);
      lstWorkExperience.addAll(lstWorkExperienceObj);
      workExperienceLength = lstWorkExperienceObj.size();
      system.debug(lstWorkExperience);
    }
  }
}