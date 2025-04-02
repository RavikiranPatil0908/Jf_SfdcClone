/**
 * @File Name          : NMIMSSeminarRestService.cls
 * @Description        : 
 * @Author             : @Phalguni
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 9/9/2019, 11:29:17 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    20/4/2019, 11:10:33 AM   @Phalguni     Initial Version
**/
@RestResource(UrlMapping ='/NMIMSSeminar/*')
global class NMIMSSeminarRestService{
    
    global class WapperClass{
        public String ResponseURL {get;set;}
        public String Message {get;set;}
        public String result {get;set;}
        
        public WapperClass(String WRId,String Message,String result){
            this.ResponseURL = WRId;
            this.Message =  Message;
            this.result = result;
        }
    }

    @HttpPost
    global static WapperClass doPost(){
        String jsonString = RestContext.request.requestbody.toString();
        Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        WapperClass wapper = null;

        if(!mapOfResponseParameters.IsEmpty()){
            mapOfResponseParameters.put('SeminarID',System.Label.NMentor_SeminarId);
            String SeminarID = (String)mapOfResponseParameters.get('SeminarID');
            String Email = checkMapContainsKeyOrNot('Email',mapOfResponseParameters);
            String MobilePhone = checkMapContainsKeyOrNot('MobilePhone',mapOfResponseParameters);
            boolean Paymentdone = false;
            String ReturnUrl = System.Label.Site_Url+'nmAdditonalChargeRevised?&id=';
            
            Map<String,Object> updateResponse = checkFieldValidation(mapOfResponseParameters);
            if(!IsNullOrEmpty(SeminarID) && !IsNullOrEmpty(Email) && !IsNullOrEmpty(MobilePhone)){
        
                  try{                    
                      List<Referral__c> listofexistancewebinar = [select id,Email__c,Mobile_Number__c,City__c,Webinar__c 
                                                                from Referral__c where Webinar__c=:SeminarID
                                                                and (Email__c=:Email or Mobile_Number__c=:MobilePhone) limit 1 ];
                       Referral__c objWebinar = new Referral__c ();                                            
                      if(listofexistancewebinar.size()>0)
                      {
                         objWebinar = listofexistancewebinar[0];
                         
                         List<nm_Payment__c> lstpayment = [select id,Seminar__c,nm_PaymentType__c,nm_PaymentStatus__c
                                                             from nm_Payment__c where Seminar__c=:objWebinar.id 
                                                             and nm_PaymentType__c='Seminar Fee' and (nm_PaymentStatus__c='Payment Made' or nm_PaymentStatus__c='Payment Approved') limit 1];
                       if(lstpayment.size()>0)
                       {
                              nm_Payment__c objpayment = lstpayment[0];
                              Paymentdone = true;
                              ReturnUrl = System.Label.Site_Url+'nmRegistrationReceipt?id='+objpayment.id;
                       }
                    
                                                             
                      }

                    for(String key : updateResponse.keySet()){
                       {
                            String value = String.valueOf(updateResponse.get(key));
                            objWebinar.put(key,value);
                        }                       
                    }
                    
                    
                    if(listofexistancewebinar.size()>0)
                    {
                        //objWebinar.id = listofexistancewebinar[0].id; 
                        update objWebinar;
                        if(Paymentdone == true)
                        {
                             wapper = new WapperClass(ReturnUrl,'Record Updated Successfully..','Success'); 
                        }
                        else
                        {
                            wapper = new WapperClass(ReturnUrl+objWebinar.id,'Record Updated Successfully..','Success'); 
                        }
                    
                       
                    }
                    else
                    {
                        insert objWebinar;
                        wapper = new WapperClass(ReturnUrl+objWebinar.id,'Record Inserted Successfully..','Success'); 
                    }
                }
                catch(Exception e){
                    wapper = new WapperClass('No such record',e.getMessage(),'Error'); 
                }
                return wapper;
            }
            else{
                wapper = new WapperClass('Error','Invalid Request','400');
                return wapper;          
            }
            //  wapper = new WapperClass('400','Please provide correct Mobile Phone','Error');
        }
        wapper = new WapperClass('Error','Invalid Request','400');
        return wapper;
    }           

    global static   boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }  
                
    global static Map<String,Object> checkFieldValidation (Map<String,Object> mapOfResponseParameters) {
        Map<String,String> newRequestMapOfKey = new Map<String,String> 
        {'SeminarID'=>'Webinar__c','Campaign'=>'Campaign__c','Medium'=>'Medium__c','City'=>'City__c',
        'Source'=>'Source__c','Name'=>'Name__c','Email'=>'Email__c',
        'MobilePhone'=>'Mobile_Number__c','Company'=>'Company_Name__c','Designation'=>'Designation__c'};
        Map<String,Object> updateRequestMap = new Map<String,Object>();

        for(String key : mapOfResponseParameters.keySet()) {
            if(newRequestMapOfKey.containsKey(key) && String.isNotBlank(newRequestMapOfKey.get(key))) {
                updateRequestMap.put(newRequestMapOfKey.get(key),mapOfResponseParameters.get(key));
            }
        }

        return updateRequestMap;
    }
    
    global static String checkMapContainsKeyOrNot (String field ,Map<String,Object> mapOfResponseParameters){
        if(mapOfResponseParameters.containsKey(field)){
            return String.valueOf(mapOfResponseParameters.get(field));
        }
        return null;
    }
}