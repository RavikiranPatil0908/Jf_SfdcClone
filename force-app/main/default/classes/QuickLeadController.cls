public class QuickLeadController {
    
    private final Lead objLead;
    public String selectedProgram {get;set;}
    
    public QuickLeadController(ApexPages.StandardController stdController) {
        this.objLead = (Lead)stdController.getRecord();
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName, String conditionString, String relatedField){
        Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
        Map<String, schema.SObjectField> fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List<String> fieldNames = new List <String>(fieldMap.keyset());
        if(relatedField != null && relatedField != ''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join(fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    } 
    
    public List<SelectOption> getProgramsList() {
        System.debug('====='+selectedProgram);
        List<SelectOption> lstProgramsOptions = new List<SelectOption>();
        lstProgramsOptions.add(new SelectOption('', 'Choose Program'));
        String chooseProgram=objLead.nm_ChooseaProgram__c;
        if(String.isBlank(objLead.nm_ChooseaProgram__c)) {
            if(String.isBlank(selectedProgram)){
                chooseProgram='Post Graduate Diploma Programs';
            }else{
                chooseProgram=selectedProgram;
            }
        }
        System.debug('chooseProgram---------->'+chooseProgram);
        String queryProgram=getQueryAllFieldSql('nm_Program__c','nm_Type__c =: chooseProgram and nmIsActive__C = true order by Name asc',null);
        List<nm_Program__C> lstActiveProgram=DataBase.query(queryProgram);
        System.debug('lstActiveProgram--'+lstActiveProgram);
        if(lstActiveProgram.size() > 0){
            for(nm_Program__C objProgram : lstActiveProgram) {
                lstProgramsOptions.add(new SelectOption(objProgram.id, objProgram.nm_ProgramName__c));
            }
        }
        return lstProgramsOptions;
    }

    public List<SelectOption> getCounselorList() {
        List<SelectOption> lstCounselorOptions = new List<SelectOption>();
        lstCounselorOptions.add(new SelectOption('', 'Choose Counselor'));
        String UserId = UserInfo.getUserId();
        String queryCounselor=getQueryAllFieldSql('Counsellor_Profile__c','OwnerId =:UserId order by Name asc',null);
        List<Counsellor_Profile__c> lstCounselor=DataBase.query(queryCounselor);
        System.debug('lstCounselor--'+lstCounselor);
        if(lstCounselor.size() > 0){
            for(Counsellor_Profile__c objCounselor : lstCounselor) {
                lstCounselorOptions.add(new SelectOption(objCounselor.id, objCounselor.Name));
            }
        }
        return lstCounselorOptions;
    }
    

}