/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-30-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-25-2021   shubhranshu   Initial Version
**/
public class AEPInvoiceTriggerHandler {
    public static Boolean isFirstTime = true;
    Map<String,nm_UserMapping__c> mapOfUserIdVsCenterUser = new Map<String,nm_UserMapping__c>();
    List<nm_UserMapping__c> lstUserCenterMapping = new List<nm_UserMapping__c> ();
    List<IC_Payment__c> lstICPayment = new List<IC_Payment__c>();
    Map<String,String> mapOfIcPayemntVsCenterId = new Map<String,String>();

    public void BeforeInsert(List<AEPInvoice__c> triggerNew, map<id, AEPInvoice__c> mapAepInvoiceOldMap){
        ICAutoSelection(triggerNew);
        updateAEPAndInvoicePaymentvs2(triggerNew);
    }

    public void AfterInsert(List<AEPInvoice__c> triggerNew, map<id, AEPInvoice__c> mapAepInvoiceNewMap){
        updateAEPAndInvoicePayment(triggerNew);
    }

    public void AfterUpdate(List<AEPInvoice__c> triggerNew, map<id, AEPInvoice__c> mapAepInvoiceOldMap){
        updateAEPAndInvoicePayment(triggerNew);
    }

    public void updateAEPAndInvoicePayment(List<AEPInvoice__c> aepInvoicelst){
        set<string> AepInvid=new set<string>();  
        if(aepInvoicelst.size()>0){
            for(AEPInvoice__c obj:aepInvoicelst){
                AepInvid.add(obj.Id);
                system.debug('AEP Invoice id is'+AepInvid);
                system.debug('AEP  id is'+obj.AEP__c);
            } 
        }
        List<AEPInvoice__c> updateLstInvoice = new List<AEPInvoice__c>();
        List<AEPInvoice__c> invalidLstInvoice = new List<AEPInvoice__c>();
        Map<String,String> mapOfIcPayemntVsCenter = getmapOfIcPayemntVsCenterId();
         
        if(AepInvid.size()>0){
            List<AEPInvoice__c> lst=[select Id,AEP__c,Pay_Month__c,Payment_Year__c,IC_Payment__c from AEPInvoice__c where Id In :AepInvid];
            if(lst.size()>0){
                    
                for(AEPInvoice__c objAEPInvoice : lst){
                    System.debug('ICAutoselect AEPInvoice--'+objAEPInvoice.AEP__c +'----Pay_Month__c---'+objAEPInvoice.Pay_Month__c+'----Payment_Year__c---'+objAEPInvoice.Payment_Year__c);
                    System.debug('mapOfIcPayemntVsCenter---'+mapOfIcPayemntVsCenter.containsKey(objAEPInvoice.AEP__c+'-'+objAEPInvoice.Pay_Month__c+'-'+objAEPInvoice.Payment_Year__c));
                    if(objAEPInvoice.IC_Payment__c == null ){// added check to avoid setting LeadOwner while inserting records from DataLoader
                        if(mapOfIcPayemntVsCenter.containsKey(objAEPInvoice.AEP__c+'-'+objAEPInvoice.Pay_Month__c+'-'+objAEPInvoice.Payment_Year__c)){
                            objAEPInvoice.IC_Payment__c = mapOfIcPayemntVsCenter.get(objAEPInvoice.AEP__c+'-'+objAEPInvoice.Pay_Month__c+'-'+objAEPInvoice.Payment_Year__c);
                            system.debug('objAEPInvoice.IC_Payment__c --->'+objAEPInvoice.IC_Payment__c );
                            updateLstInvoice.add(objAEPInvoice);
                        }else{
                            System.debug('No Invoice Payment Found.');
                            invalidLstInvoice.add(objAEPInvoice);
                            // objAEPInvoice.addError('No Invoice Payment Found.');
                            AEPInvoice__c actualRecord = (AEPInvoice__c)Trigger.newMap.get(objAEPInvoice.Id); 
                            actualRecord.addError('No Invoice Payment Found.'); 
                        }
                    }
                }
        
                if(updateLstInvoice.size()>0){
                    System.debug('updateLstInvoice '+updateLstInvoice);
                    try {
                        update updateLstInvoice;
                    } catch (DmlException e) {
                        System.debug('error '+e.getMessage());
                    }
                }
            }
        }
        
    }
       
    public void updateAEPAndInvoicePaymentvs2(List<AEPInvoice__c> aepInvoicelst){
        // set<string> AepInvid=new set<string>();
        List<AEPInvoice__c> updateLstInvoice = new List<AEPInvoice__c>();  
        if(aepInvoicelst.size()>0){
      
            Map<String,String> mapOfIcPayemntVsCenter = getmapOfIcPayemntVsCenterId();
         
       
         //   List<AEPInvoice__c> lst=[select Id,AEP__c,Pay_Month__c,Payment_Year__c,IC_Payment__c from AEPInvoice__c where Id In :AepInvid];
        
                for(AEPInvoice__c objAEPInvoice : aepInvoicelst){
                    System.debug('ICAutoselect AEPInvoice--'+objAEPInvoice.AEP__c +'----Pay_Month__c---'+objAEPInvoice.Pay_Month__c+'----Payment_Year__c---'+objAEPInvoice.Payment_Year__c);
                    System.debug('mapOfIcPayemntVsCenter---'+mapOfIcPayemntVsCenter.containsKey(objAEPInvoice.AEP__c+'-'+objAEPInvoice.Pay_Month__c+'-'+objAEPInvoice.Payment_Year__c));
                    system.debug(objAEPInvoice);
                    if(objAEPInvoice.IC_Payment__c == null ){// added check to avoid setting LeadOwner while inserting records from DataLoader
                        if(mapOfIcPayemntVsCenter.containsKey(objAEPInvoice.AEP__c+'-'+objAEPInvoice.Pay_Month__c+'-'+objAEPInvoice.Payment_Year__c)){
                            objAEPInvoice.IC_Payment__c = mapOfIcPayemntVsCenter.get(objAEPInvoice.AEP__c+'-'+objAEPInvoice.Pay_Month__c+'-'+objAEPInvoice.Payment_Year__c);
                            system.debug(' objAEPInvoice.IC_Payment__c--->'+ objAEPInvoice.IC_Payment__c);
                        //    updateLstInvoice.add(objAEPInvoice);
                        }else{
                            System.debug('No Invoice Payment Found.');
                            objAEPInvoice.addError('No Invoice Payment Found.');
                            // AEPInvoice__c actualRecord = (AEPInvoice__c)Trigger.oldMap.get(objAEPInvoice.Id); 
                            // actualRecord.adderror('No Invoice Payment Found.'); 
                        }
                    }
                }
        }
                //if(updateLstInvoice.size()>0){
                //    try {
                //        update updateLstInvoice;
              //     } catch (DmlException e) {
                 //       System.debug('error '+e.getMessage());
                    //}
                //}
            
        
        
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
       
        return query;
    }
    
    public List<nm_UserMapping__c> getlstUserCenterMapping(){
        if(lstUserCenterMapping.isEmpty()){
            system.debug('UserMaping call out');
            String queryUserCenterMapping = getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null and nm_Centers__r.RegistrationClosed__c =false','nm_Centers__r.Name,nm_user__r.Email,nm_user__r.id,nm_user__r.Name,nm_Centers__r.LC_email__c');
            lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
        }      
        return lstUserCenterMapping;
    }

    public List<IC_Payment__c> getlstIcPayment(){
        if(lstICPayment.isEmpty()){
            Integer year  = date.today().year(); 
            Set<string> setofyear = new Set<String> {String.valueof(year-1),String.valueof(year),String.valueof(year+1)};
            system.debug('IC Payment call out');
            String queryIcPayment = getQueryAllFieldSql('IC_Payment__c',' Centers__c !=null and Share_Processed__c=true and Payment_Year__c=:setofyear','');
            lstICPayment = DataBase.query(queryIcPayment);
        }      
        return lstICPayment;
    }
 
    public Map<String,nm_UserMapping__c> getMapOfUserIdVsCenter(){
       // String queryUserCenterMapping = getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null ',null);
        if(mapOfUserIdVsCenterUser.isEmpty()){
            //  List<nm_UserMapping__c> lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
            List<nm_UserMapping__c> lstUserCenterMapping = getlstUserCenterMapping();
            if(lstUserCenterMapping.size() > 0){
                for(nm_UserMapping__c objCenteruserMapping : lstUserCenterMapping){
                    mapOfUserIdVsCenterUser.put(objCenteruserMapping.nm_User__c, objCenteruserMapping);
                }
            }
        }
        return mapOfUserIdVsCenterUser;
    }

    public Map<String,String> getmapOfIcPayemntVsCenterId(){
        if(mapOfIcPayemntVsCenterId.isEmpty()){
            List<IC_Payment__c> lstIcPay = getlstIcPayment();
            if(lstIcPay.size() > 0){
                for(IC_Payment__c objIcPay : lstIcPay){
                    mapOfIcPayemntVsCenterId.put(objIcPay.Centers__c+'-'+objIcPay.Pay_Month__c+'-'+objIcPay.Payment_Year__c,objIcPay.Id);
                }
            }
        }
        System.debug('mapOfIcPayemntVsCenterId '+mapOfIcPayemntVsCenterId);
        return mapOfIcPayemntVsCenterId;
    }

    public void ICAutoSelection (list<AEPInvoice__c> lstAEPInvoice){
        Map<String,nm_UserMapping__c> mapOfUserIdVsCenterUser = getMapOfUserIdVsCenter();
        for(AEPInvoice__c objAEPInvoice : lstAEPInvoice){
            System.debug('ICAutoselect AEPInvoice--'+objAEPInvoice.AEP__c +'----OwnerId---'+objAEPInvoice.OwnerId);
            System.debug('mapOfUserIdVsCenterUser---'+mapOfUserIdVsCenterUser.containsKey(objAEPInvoice.OwnerId));
            if(objAEPInvoice.AEP__c == null ){// added check to avoid setting LeadOwner while inserting records from DataLoader
                if(mapOfUserIdVsCenterUser.containsKey(objAEPInvoice.OwnerId)){
                    objAEPInvoice.AEP__c = mapOfUserIdVsCenterUser.get(objAEPInvoice.OwnerId).nm_Centers__c;
                    objAEPInvoice.LC_Email_Address__c = mapOfUserIdVsCenterUser.get(objAEPInvoice.OwnerId).nm_Centers__r.LC_email__c;
                }
            }
        }
        // updateAEPAndInvoicePayment(lstAEPInvoice);
    }
}