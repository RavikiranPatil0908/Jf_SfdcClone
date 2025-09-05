/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 04--09--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   11--08--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/api/FetchPicklistValues/*')
global with sharing class GetPicklistValuesAPI {
   
    // fetch all picklist values
   @HttpGet
   global static void getPicklistValues() {
       try {
           RestResponse res = RestContext.response;
           RestRequest req = RestContext.request;
           
           res.addHeader('Content-Type', 'application/json;charset=UTF-8');
           String recordId = req.params.get('recordId');
           String objectType = recordId != null ? (recordId.startsWith('00Q') ? 'Lead' : 'Account') : null;
           
           // Initialize response
           PicklistResponse responseData = new PicklistResponse();
           
           if(objectType != null) {
               FormPageController controller = new FormPageController();
               
               if(objectType == 'Lead') {
                   controller.setLeadId(recordId);
               } else {
                   controller.setAccountId(recordId);
               }
               responseData.getDomicile = convertSelectOptions(controller.getDomicile());
               responseData.getProgramsList = convertSelectOptions(controller.getProgramsList());
               responseData.globalStateValue = getGlobalStateOptions();
               responseData.globalCountryValue = getGlobalCountryOptions();
               responseData.getWorkExpTimeList = convertSelectOptions(controller.getWorkExpTimeList());
               responseData.getProgramTypePicklistValues = convertSelectOptions(controller.getProgramTypePicklistValues());
               responseData.getElegibilityCriteriaList = convertSelectOptions(controller.getElegibilityCriteriaList());
               responseData.getSpecializationList = convertSelectOptions(controller.getSpecializationList());
               responseData.getGraduationDegreeModeMBA = convertSelectOptions(controller.getGraduationDegreeModeMBA());
               responseData.getGlobalLocalityOptionValues = getGlobalLocalityOptions();
           }
           
           BaseResponse response = new BaseResponse('Success', 'Picklist values fetched successfully', responseData); 
           res.responseBody = Blob.valueOf(JSON.serialize(response));
           
       } catch(Exception e) {
           BaseResponse errorResponse = new BaseResponse('Error', 'Error retrieving picklist values: ' + e.getMessage(), null);
           RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
       }
   }
   
 private static List<SelectOption> getGlobalStateOptions() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('','---None---'));
       
       for(Schema.PicklistEntry pe : Lead.State__c.getDescribe().getPicklistValues()) {
           options.add(new SelectOption(pe.getValue(), pe.getValue()));
       }
       return options;
 }
   
 private static List<SelectOption> getGlobalCountryOptions() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('','---None---'));
       
       for(Schema.PicklistEntry pe : Lead.Country__c.getDescribe().getPicklistValues()) {
           options.add(new SelectOption(pe.getValue(), pe.getValue()));
       }
       return options;
 }
   
 private static List<SelectOption> getGlobalLocalityOptions() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('','---None---'));
       
       for(Schema.PicklistEntry pe : Lead.Locality__c.getDescribe().getPicklistValues()) {
           options.add(new SelectOption(pe.getValue(), pe.getValue()));
       }
      return options;
 }
      
 /** Helper method to convert System.SelectOption to custom SelectOption
 * @description 
 * @author @Ravi | 11--08--2025 
 * @param List<System.SelectOption> options 
 * @return List<SelectOption> 
 **/
 private static List<SelectOption> convertSelectOptions(List<System.SelectOption> options) {
     if(options == null) return null;
     
     List<SelectOption> result = new List<SelectOption>();
     System.debug('Options====>'+options);
     System.debug('Options size====>'+options.size());
     for(System.SelectOption opt : options) {
         result.add(new SelectOption(opt.getValue(), opt.getLabel()));
     }
     System.debug('Options result====>'+result);
     return result;
 }
   
   // Response structure for picklists
   global class PicklistResponse {
         public List<SelectOption> getDomicile;
         public List<SelectOption> getProgramsList;
         public List<SelectOption> globalStateValue;
         public List<SelectOption> globalCountryValue;
         public List<SelectOption> getWorkExpTimeList;
         public List<SelectOption> getProgramTypePicklistValues;
         public List<SelectOption> getElegibilityCriteriaList;
         // public List<SelectOption> getLateralOptions;
         public List<SelectOption> getSpecializationList;
         public List<SelectOption> getGraduationDegreeModeMBA;
         public List<SelectOption> getGlobalLocalityOptionValues;
   }
   
   //
   global class SelectOption {
       public String value;
       public String label;
       
       public SelectOption(String value, String label) {
           this.value = value;
           this.label = label;
       }
   }
   
   global class BaseResponse {
       public String status;
       public String message;
       public Object data;
       
       public BaseResponse(String status, String message, Object data) {
           this.status = status;
           this.message = message;
           this.data = data;
       }
   } 
}