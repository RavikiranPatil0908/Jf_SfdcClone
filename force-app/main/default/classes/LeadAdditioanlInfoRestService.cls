/**
 * @File Name          : LeadAdditioanlInfoRestService.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : Balakrishnan
 * @Last Modified On   : 26/3/2019, 3:27:10 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    26/3/2019, 3:19:09 PM   Balakrishnan     Initial Version
**/
@RestResource(UrlMapping ='/LeadAdditioanlInfo/*')
global class LeadAdditioanlInfoRestService{
    
    global class WapperClass{
        public String SalesaforceLeadId {get;set;}
        public String Message {get;set;}
        public String result {get;set;}
        
        public WapperClass(String LeadId,String Message,String result){
            this.SalesaforceLeadId = LeadId;
            this.Message =  Message;
            this.result = result;
        }
    }
    
    @HttpPost
    global static WapperClass doPost(){
        String jsonString = RestContext.request.requestbody.toString();
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        WapperClass wapper = null;
        
        if(!mapOfResponseParameters.IsEmpty()){
            String LeadId = checkMapContainsKeyOrNot('LeadId',mapOfResponseParameters);
            Map<String,Object> updateResponse = checkFieldValidation(mapOfResponseParameters);
            if(LeadId != null && LeadId != ''){
                try{
                    Lead objLead = new Lead(id=LeadId);

                    for(String key : updateResponse.keySet()) {
                        if(key == 'Risk_Course__c') {
                            Integer value = updateResponse.get(key)!=null && updateResponse.get(key)!=''?Integer.valueof(updateResponse.get(key)):0;
                            objLead.put(key,value);
                        }else{
                            String value = String.valueOf(updateResponse.get(key));
                            objLead.put(key,value);
                        }
                    }
                    update objLead;
                    wapper = new WapperClass(LeadId,'Record Updated Successfully..','Success'); 
                }catch(Exception e){
                    wapper = new WapperClass(LeadId,e.getMessage(),'Error'); 
                }
            }else{
                wapper = new WapperClass(LeadId,'Please provide LeadId.','Error');
            }
        }
        return wapper;
    }

    /**
    * @description
    * @author Balakrishnan | 26/3/2019
    * @param Map<String, Object> mapOfResponseParameters
    * @return Map<String, Object>
    */
    global static Map<String,Object> checkFieldValidation(Map<String,Object> mapOfResponseParameters) {
        Map<String,String> newRequestMapOfKey = new Map<String,String> 
        {'Industry'=>'Industry','workExp'=>'nm_WorkExperience__c','designation'=>'nm_Designation__c','city'=>'nm_City_P__c',
        'higestQualification'=>'Highest_Qualification__c','gender'=>'nm_Gender__c','requestavisit'=>'Request_a_visit__c',
        'fraud'=>'Fraud__c','riskcourse'=>'Risk_Course__c','company'=>'nm_Company_Name__c','income'=>'nm_IncomeInLacs__c'};
        Map<String,Object> updateRequestMap = new Map<String,Object>();

        for(String key : mapOfResponseParameters.keySet()) {
            if(newRequestMapOfKey.containsKey(key) && String.isNotBlank(newRequestMapOfKey.get(key))) {
                updateRequestMap.put(newRequestMapOfKey.get(key),mapOfResponseParameters.get(key));
            }
        }

        return updateRequestMap;
    }
    
    global static String checkMapContainsKeyOrNot(String field ,Map<String,Object> mapOfResponseParameters){
        if(mapOfResponseParameters.containsKey(field)){
            return String.valueOf(mapOfResponseParameters.get(field));
        }
        return null;
    }
}