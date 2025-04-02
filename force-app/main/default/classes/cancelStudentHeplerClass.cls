/**
 * @File Name          : cancelStudentHeplerClass.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20-03-2023
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/17/2019   shubhranshu     Initial Version
**/
public without sharing class cancelStudentHeplerClass {
    
    
    /**
    * @description 
    * @author shubhranshu | 9/17/2019 
    * @param lstAccount 
    * @param accountOldMap 
    * @return void 
    **/
    public void intializaCancelAdmissionProcess(List<Account> lstAccount,Map<Id,Account> accountOldMap){
        set<id> stid=new set<id>();
        Set<Id> accountIds = new Set<Id>();
        // set of current email to avoid lead insertion
        Set<String> setofEmail = new Set<String>();
        Set<String> setofMobile = new Set<String>();
        // set of cuurent mobile to avoid lead insertion 
        Set<String> setofCurrentMobile = new Set<String>();
        Set<Id> oppsIds = new Set<Id>();
        Set<string> leadId = new Set<string>();
        Boolean Installmentdone;
        Boolean downpaymentdone = false;
        Boolean createICShareDebitEntries=false;
        Map<String, Opportunity> mapStringVsObjoppClone= new Map<String, Opportunity>();
        Boolean initalformaster = false;
        Boolean initalPaymentDone = false;
        Boolean documentsApproved = false;
        List<nmRefund_Payment__c> refund = new List<nmRefund_Payment__c>();
        String strEmailid;
        Boolean Dispatchcreated = false;
        String AccountStage;
        String interviewStatus;
        String typerefund;
        String opportunityStatusToupdate;
        String appendedStudentStatus;
        
        for(Account ac : lstAccount){    
            System.debug('accountOldMap '+accountOldMap.get(ac.id).nm_StudentStatus__c +' ac.nm_StudentStatus__c '+ac.nm_StudentStatus__c+' InActiveTrigger__c'+!ac.InActiveTrigger__c);
            if(((ac.nm_StudentStatus__c=='Admission Cancelled' || ac.nm_StudentStatus__c=='Registration Cancelled' || ac.nm_StudentStatus__c=='Rusticated') && (!ac.InActiveTrigger__c) && (ac.nm_StudentStatus__c != accountOldMap.get(ac.id).nm_StudentStatus__c )) 
              || (ac.Interview_Status__c =='Rejected' && accountOldMap.get(ac.id).Interview_Status__c != ac.Interview_Status__c && ac.nm_ChooseaProgram__c == 'Master Programs' && ac.nm_StudentStatus__c!='Confirmed' ))
            {
                AccountStage=ac.nm_StudentStatus__c;
                interviewStatus = ac.Interview_Status__c;
                accountIds.add(ac.Id);
                setofEmail.add(ac.PersonEmail);
                setofMobile.add(ac.PersonMobilePhone);
                setofMobile.add(ac.PersonMobilePhone+'0000');
                setofCurrentMobile.add(ac.PersonMobilePhone);
                leadId.add(ac.nm_LeadId__c);
            }

            if(interviewStatus=='Rejected' && ac.nm_ChooseaProgram__c == 'Master Programs' && ac.nm_StudentStatus__c!='Confirmed'){
                appendedStudentStatus = 'Rejected';
                opportunityStatusToupdate ='Rejected';
            }

            if(ac.nm_StudentStatus__c =='Admission Cancelled' || ac.nm_StudentStatus__c=='Registration Cancelled'){
                appendedStudentStatus = 'Cancel';
                opportunityStatusToupdate = '';
            }

            if(ac.nm_StudentStatus__c =='Rusticated'){
                appendedStudentStatus = 'Rusticated';
                opportunityStatusToupdate = 'Rusticated';
            }
        }

        System.debug('CancelAdmission: accountIds = '+accountIds);
        if(accountIds.size()>0){
            List<Opportunity> lstAppOpportuniyties = new List<Opportunity>();
            list<Opportunity> lstUpdate=new list<Opportunity>();
            list<nmRefund_Payment__c> lstRefundpayment=new list<nmRefund_Payment__c>();
            lstAppOpportuniyties=[select id,nm_InformationCenters__c,Account.PersonEmail,nm_Allowed_Installment__c,
                                    nm_Program__r.nm_Type__c,Amount,StageName,Processed__c,nm_Session__c,nm_Semester__c,nm_StudentSession__c,
                                    AccountId,Name, Account.nm_Centers__c,Account.Name, Dispatch_Order_For_Student__c,ChooseProgram__c, Specialisation__c, IC__c,
                                    (select id,nm_ModeOfPayment__c,nm_Amount__c,nm_PaymentType__c,
                                    nm_PaymentStatus__c from Opportunities__r where nm_PaymentType__c!='Registration') 
                                    from Opportunity where AccountId in: accountIds order by nm_Semester__c asc];
            
            list<Opportunity> lstToUpdate=new list<Opportunity>();
            
            System.debug('lstAppOpportuniyties '+lstAppOpportuniyties);
            if(lstAppOpportuniyties.size()>0)
            {
                strEmailid=lstAppOpportuniyties[0].Account.PersonEmail;        
                Dispatchcreated=lstAppOpportuniyties[0].Dispatch_Order_For_Student__c;
                System.debug('Dispatchcreated'+Dispatchcreated);
                System.debug('lstAppOpportuniyties[0].Dispatch_Order_For_Student__c'+lstAppOpportuniyties[0].Dispatch_Order_For_Student__c);
                System.debug('AccountStage '+AccountStage );
                system.debug('lstAppOpportuniyties[0].StageName'+lstAppOpportuniyties[0].StageName);
                
                
                nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
                Integer intTotalMountTorefund=0;
                Integer Additionalamount=0;
                // String DescriptiZon =AccountStage ;
                
                String ModeofPaymentSem1;
                lstToUpdate.addAll(lstAppOpportuniyties);

                integer intLatefees=0;
                Installmentdone = false;
                if(lstToUpdate.size()>0)
                {
                    for(opportunity objOpp:lstToUpdate)
                    {
                        oppsIds.add(objOpp.id);                             
                        mapStringVsObjoppClone.put(objOpp.Id, objOpp) ;                          
                        for(nm_Payment__c objPayment:objOpp.Opportunities__r)
                        {    
                            /* no need as we will add all payment in refund process exclude registration fee */
                            // if(objPayment.nm_PaymentStatus__c=='Payment Made'){
                            //     System.debug('You can not proceed further as payment status is :---'+objPayment.nm_PaymentStatus__c);
                            //     return;
                            // }

                            if(objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made')
                            {
                                if((objPayment.nm_PaymentType__c=='Admission' )                             
                                        &&(objPayment.nm_ModeOfPayment__c!='NEFT - Capital Float' || objPayment.nm_ModeOfPayment__c!='NEFT - Zest' || objPayment.nm_ModeOfPayment__c!='NEFT - EduVanz' || objPayment.nm_ModeOfPayment__c !='NEFT - LiquiLoans'))
                                {
                                    ModeofPaymentSem1 = objPayment.nm_ModeOfPayment__c;
                                    intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                    System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }
                                if(objPayment.nm_PaymentType__c.contains('DownPayment'))
                                {   
                                    downpaymentdone = true;
                                    ModeofPaymentSem1 = objPayment.nm_ModeOfPayment__c;
                                    intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                    System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }                               
                                if(objPayment.nm_PaymentType__c.contains('Additional Charge'))
                                {
                                    ModeofPaymentSem1 = objPayment.nm_ModeOfPayment__c;
                                    intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                    System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }
                                if (objPayment.nm_PaymentType__c == 'Installment' )
                                {
                                    ModeofPaymentSem1=objPayment.nm_ModeOfPayment__c;
                                    intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                    Installmentdone=true;
                                    System.debug('intTotalMountTorefund'+intTotalMountTorefund);
                                }
                                if(objPayment.nm_PaymentType__c=='Initial Payment')
                                {   
                                    if(interviewStatus=='Rejected'){
                                        initalformaster = true;
                                    }
                                    initalPaymentDone = true;
                                    Installmentdone = true;
                                    ModeofPaymentSem1=objPayment.nm_ModeOfPayment__c;
                                    intTotalMountTorefund+=Integer.valueof(objPayment.nm_Amount__c);
                                    System.debug('Initial refund Payment'+intTotalMountTorefund);
                                } 
                                if(objPayment.nm_PaymentType__c=='Late Fees')
                                {
                                    intLatefees+=Integer.valueof(objPayment.nm_Amount__c);
                                    System.debug('intLatefees'+intLatefees);
                                } 
                                
                                // if(objPayment.nm_PaymentType__c=='Admission' && objOpp.StageName == 'Closed Won' && objOpp.Processed__c && (objPayment.nm_PaymentStatus__c=='Payment Made' || objPayment.nm_PaymentStatus__c=='Payment Approved'))
                                // {
                                //    // handler.createICShareDebitEntries(objOpp);
                                //     createICShareDebitEntries =true;
                                //     mapStringVsObjoppClone.put(objOpp.Id, objOpp) ;
                                // } 
                            }
                        }
                        
                    }
                
                }
                
                
                List<nmRefund_Payment__c> lstrefund = [Select id ,Additional_Deduction__c,Opportunity__c,Type_of_Refund__c from nmRefund_Payment__c where (Type_of_Refund__c='Admission Cancellation' or Type_of_Refund__c='Registration Cancellation') and Opportunity__c =:mapStringVsObjoppClone.keySet() ];
                System.debug('lstrefund '+lstrefund);
                System.debug('lstAppOpportuniyties[0].StageName  '+lstAppOpportuniyties[0].StageName);

                String accountOldStatus = accountOldMap.containsKey(lstAppOpportuniyties[0].AccountId) ? accountOldMap.get(lstAppOpportuniyties[0].AccountId).nm_StudentStatus__c : null;
                if(String.isNotBlank(accountOldStatus) && (accountOldStatus.endsWithIgnoreCase('Admission form & documents Approved') || accountOldStatus.endsWithIgnoreCase('Admission Form & Documents Provisional'))) {
                    documentsApproved = true;
                }
                System.debug('documentsApproved ==>'+documentsApproved + 'accountOldStatus ==>'+accountOldStatus);

                Map<String, Integer> mapOfOppAndAdditionalAmount = new Map<String, Integer>();
                if (lstrefund.size()>0) {
                        for(nmRefund_Payment__c rePay : lstrefund) {
                            if(mapStringVsObjoppClone.containsKey(rePay.Opportunity__c)) {
                            if(!mapOfOppAndAdditionalAmount.containsKey(rePay.Opportunity__c)) {
                                mapOfOppAndAdditionalAmount.put(rePay.Opportunity__c, 0);
                            }
                            mapOfOppAndAdditionalAmount.put(rePay.Opportunity__c, mapOfOppAndAdditionalAmount.get(rePay.Opportunity__c) + Integer.valueof(String.isNotBlank(String.valueOf(rePay.Additional_Deduction__c) ) ? rePay.Additional_Deduction__c: 0  ));
                                stid.add(rePay.id);
                                }

                            }
                }



                // if(lstrefund.size()>0)
                //     {
                //         Map<String, Integer> mapOfOppAndAdditionalAmount = new Map<String, Integer>();
                //         for(nmRefund_Payment__c rePay : lstrefund) {
                //             if(mapStringVsObjoppClone.containsKey(rePay.Opportunity__c)) {
                //                 if(!mapOfOppAndAdditionalAmount.containsKey(rePay.Opportunity__c)) {
                //                     mapOfOppAndAdditionalAmount.put(rePay.Opportunity__c, 0);
                //                 }
                //                 mapOfOppAndAdditionalAmount.put(rePay.Opportunity__c, mapOfOppAndAdditionalAmount.get(rePay.Opportunity__c) + Integer.valueof(rePay.Additional_Deduction__c));
                //                 stid.add(rePay.id);
                //             }

                //         }
                //         if(mapOfOppAndAdditionalAmount.size() > 0) {
                //             for(String oppKey : mapOfOppAndAdditionalAmount.keySet()) {
                //                 if(createICShareDebitEntries)
                //                 {
                //                     handler.createICShareDebitEntries(mapStringVsObjoppClone.get(oppKey),mapOfOppAndAdditionalAmount.get(oppKey));
                //                 }

                //             }
                //         }
                //     }
                if (!mapStringVsObjoppClone.isEmpty() && appendedStudentStatus!='Rusticated') {
                    for (String oppId : mapStringVsObjoppClone.keySet()) {
                        if (mapOfOppAndAdditionalAmount.containsKey(oppId)) {
                            handler.createICShareDebitEntries(mapStringVsObjoppClone.get(oppId),mapOfOppAndAdditionalAmount.get(oppId));
                        } else {
                            handler.createICShareDebitEntries(mapStringVsObjoppClone.get(oppId),0);
                        }
                    }
                }

                if(lstrefund.size() == 0 && appendedStudentStatus!='Rusticated')
                {
                    if(lstAppOpportuniyties[0].StageName=='Closed Won'){
                            lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,AccountStage,Installmentdone,strEmailid,documentsApproved,initalPaymentDone));
                            System.debug('intTotalMountTorefund for closed won'+intTotalMountTorefund);
                            System.debug('intLatefees'+intLatefees);
                    }

                    if(lstAppOpportuniyties[0].StageName=='Closed'){
                            Installmentdone=false;
                            lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,AccountStage,Installmentdone,strEmailid,documentsApproved,initalPaymentDone));
                            System.debug('intTotalMountTorefund for closed'+intTotalMountTorefund);
                            System.debug('intLatefees'+intLatefees);
                    }

                    if(lstAppOpportuniyties[0].StageName.contains('Pending Payment' ) && ( Installmentdone || downpaymentdone || initalformaster)){
                            if(AccountStage == 'Registration Cancelled'){
                                lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,'Registration Cancellation',Installmentdone,strEmailid,documentsApproved,initalPaymentDone));
                            }else{
                                lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,AccountStage,Installmentdone,strEmailid,documentsApproved,initalPaymentDone));
                            }
                            System.debug('intTotalMountTorefund for pending pay with install or downpay or initialformaster'+intTotalMountTorefund);
                            System.debug('intLatefees'+intLatefees);
                    }else if((lstAppOpportuniyties[0].StageName.contains('Pending Payment' ) || lstAppOpportuniyties[0].StageName=='Registration Done')  && (AccountStage =='Registration Cancelled')){
                        lstRefundpayment.add(InsertRefundRecord(lstAppOpportuniyties[0],ModeofPaymentSem1,(intTotalMountTorefund+intLatefees),Dispatchcreated,'Registration Cancellation',Installmentdone,strEmailid,documentsApproved,initalPaymentDone));
                        System.debug('intTotalMountTorefund for  reg cancel'+intTotalMountTorefund);
                        System.debug('intLatefees'+intLatefees);
                    }
                }  
                
            
            }
            if(lstRefundpayment.size()>0)
            {     
                try{  
                    insert lstRefundpayment;
                    System.debug('lstRefundpayment inserted..');
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
                for(nmRefund_Payment__c objRfPay:lstRefundpayment)
                {
                    stid.add(objRfPay.id);
                }
                
            }

            if(leadId.size() > 0){
            // if(strEmailid !=null && strEmailid !=''){
                deletePreviousLead(setofEmail,setofMobile,leadId);
            }
            
            // check whether already similar lead is present for current email or mobile and status contains fee paid 
            List<Lead> lstExistLead = [select Id,FirstName,LastName from Lead where (Email IN :setofEmail OR MobilePhone IN : setofCurrentMobile) and Id NOT IN : leadId and  Status Like'%Fee paid%' ];
            System.debug('lstExistLead '+lstExistLead.size());
            // list size not check as want to update account details any how :) 
            CancelFutureHandler.CancelAdmission(accountIds,stid,lstExistLead,appendedStudentStatus, '', null);
        
            // update Opportunity Stage
            updateOpportunityStage(lstToupdate,opportunityStatusToupdate,AccountStage);
                
        }
   }

    /**
    *  description
    *  check if lead id and isConverted is true 
       OR check if set of email ,set of mobile (reborn cases included) , status not contains fee paid and isConverted is false
       if one of the above scenario is matched then previuos lead should be deleted !!! 
    * @author shubhranshu | 9/17/2019 
    * @return void 
    **/
    public void deletePreviousLead(Set<String> setofEmailId,Set<String> setofMobileNo ,Set<String> setofLeadId){
        List<lead> lstLead=[select id from lead where  (id=:setofLeadId and isConverted=true ) ];
        // List<lead> lstLead=[select id from lead where  (id=:setofLeadId and isConverted=true ) or ( (Email =:setofEmailId or MobilePhone =:setofMobileNo) and (Not Status Like'%Fee paid%') and isConverted= false)];
        if(lstLead.size()>0)
        {
                try{
                    delete lstLead;
                    System.debug('Previous lead deleted...');
                }catch(DmlException e){  
                    System.debug(e.getMessage());
                }
        }
    }

    /**
    * @description 
    * @author shubhranshu | 9/17/2019 
    * @param lstToOppUpdate 
    * @param OppStage 
    * @return void 
    **/
    public void updateOpportunityStage(List<Opportunity> lstToOppUpdate,String OppStage,String accStageName){
        for(Opportunity objOppUpdat:lstToOppUpdate){   

            if(String.isNotBlank(OppStage)){
                objOppUpdat.StageName = OppStage;
            }else{
                if(objOppUpdat.StageName=='Closed' || ((objOppUpdat.StageName.contains('Pending Payment' )) || (objOppUpdat.StageName=='Registration Done' ) && accStageName =='Registration Cancelled'))
                {
                    objOppUpdat.StageName='Registration Cancelled';                    
                }else{
                    objOppUpdat.StageName='Admission Cancelled';                       
                }
            }
        }

        try{
            update lstToOppUpdate;
        }catch(DmlException e){
            System.debug(e.getMessage());
        }             
    }

    /**
    * @description 
    * @author shubhranshu | 9/14/2019 
    * @param objOpps 
    * @param ModeofPaymentSem1 
    * @param intTotalMountTorefund 
    * @param Dispatchcreated 
    * @param AccountStage 
    * @param InstallmentdoneFlag 
    * @param email 
    * @return nmRefund_Payment__c 
    **/
    public nmRefund_Payment__c InsertRefundRecord(Opportunity objOpps,String ModeofPaymentSem1,Integer intTotalMountTorefund,Boolean Dispatchcreated,String AccountStage,Boolean InstallmentdoneFlag,String email,Boolean documentsApproved,Boolean initalPaymentDone){
        nmRefund_Payment__c objRefundPayment=new nmRefund_Payment__c();
        objRefundPayment.Total_Refund_Amount__c=intTotalMountTorefund;
        objRefundPayment.nm_Payment_Status__c='Refund Initiated';
        objRefundPayment.Account__c=objOpps.Accountid;
        objRefundPayment.Mode_Of_Payment__c=ModeofPaymentSem1;
        objRefundPayment.Instalment_done__c= InstallmentdoneFlag;
        objRefundPayment.Study_Kit__c= Dispatchcreated;
        objRefundPayment.nm_Information_Center__c=objOpps.nm_InformationCenters__c;
        objRefundPayment.nm_Student_E_mail__c=email;
        objRefundPayment.Documents_Approved__c=documentsApproved;
        objRefundPayment.Initial_Payment_done__c=initalPaymentDone;
 
        if(AccountStage!='' && AccountStage!=null)
        {
            objRefundPayment.Type_of_Refund__c = AccountStage !='' ? AccountStage: '';
        }
        
        objRefundPayment.Opportunity__c = objOpps.id;
        
        return objRefundPayment;
    }

}