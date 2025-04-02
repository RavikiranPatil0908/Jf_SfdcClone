/**
 * @File Name          : nmOpportunityTriggerHandler.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20-08-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    15/7/2019, 4:40:01 PM   @BK     Initial Version
**/
// This Class is used as a trigger handler for trigger on Opportunity
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        5-Mar-2014      Neeraj Chauhan           Initial Version
// ---------------------------------------------------------------------------------------------

public class nmOpportunityTriggerHandler
{
    public static boolean IsAfterUpdateRunOnce = false;
    public static boolean IsAfterUpdateRunOncevs2 = false;

    List<Calender__c> lstCalender = new List<Calender__c>();
    List<Calender__c> lstActiveCalender = new List<Calender__c>();
    Map<String,String> mapOfCalenderVsSessionYear = new Map<String,String>();
   //Method to handle all Before insert call on opportunity        
    public void BeforeInsert(List<Opportunity> triggerNew, map<id, Opportunity> NewMap) 
    {
        //GetEmailFromAccount(triggerNew);
        //Added by Vikas 4-12-2015 to update Receipt No. on payment when Opps Stage Becomes Closed Won//
        // changeCurrencyISO(triggerNew, newMap);
    }
    //Method to handle all before update call on opportunity
    public void BeforeUpdate(List<Opportunity> triggerNew, map<id, Opportunity> OldMap)
    {  
      // GetEmailFromAccount(triggerNew);
       insertStudentNoVer2(triggernew);
       callWebserviveForClosedLost(triggerNew,OldMap);

       validateFeeTypeVsProgram(triggerNew, OldMap);
       
       //If student has paid for 4 semester fees and opportunity is closed won, then create next 3 semester opportunities as well
        nmPGAllSemFee helper = new nmPGAllSemFee();
        helper.createNextSemOpportunityOnClosedWonForFullFee(triggerNew, oldMap);
          //If student has paid for 4 semester fees and opportunity is closed won, then create next 3 semester opportunities as well
       // MBA (WX)
        MBAallTermfee MBAhelper = new MBAallTermfee ();
        MBAhelper.createNextSemOpportunityOnClosedWonForFullFee(triggerNew, oldMap);
      
        
        //If student has paid Annual fees and opportunity is closed won, then create next semester opportunities as well
      //  nmAnnualFee annualFeeHelper = new nmAnnualFee();
       // annualFeeHelper.createNextSemOpportunityOnClosedWonForAnnualFee(triggerNew, oldMap);
        
        // nmMultipleFee multiple = new nmMultipleFee();
      //   multiple.createNextSemOpportunityOnClosedWonForMultipleSem(triggerNew, oldMap);
        
        //Added by Sanket 27-Jul-2015, to mark Today date as Closed Date, if Opportunity is Closed Won
        setClosedDateIfClosedWon(triggerNew, oldMap);       
       
       // call method to keep track of change in Opportunity Status and Description  
       historyTrackingOnNextFollow(triggerNew,oldMap);
       
       // call method to send Payment Invoice as Attachment and Create Attachment under Opportunity 
       sendPaymentInvoiceAsAttachmentToCapitalFloat(triggerNew,oldMap);

       // Track Loan Dates
       captureLoanStatusChangeDates(triggerNew,oldMap);

    //    checkCourseListAreValid(triggerNew,oldMap);
    }
  
   //If Opportunity is marked as Closed-Won, then Close Date need to be today.
   public void setClosedDateIfClosedWon(list<Opportunity> lstNewOpp, Map<id, Opportunity> OldOppMap){
        if(checkRecursive.runBeforeOnce())
        {
            return;
        }
        
        for( Opportunity objNewOpp: lstNewOpp){
            Opportunity oldOpportunity = OldOppMap.get(objNewOpp.Id);
            String newStage = objNewOpp.StageName;
            String oldStage = oldOpportunity.StageName;
            
            if(newStage != oldStage && newStage == 'Closed Won' ){
                objNewOpp.CloseDate = System.Today();
                //Update Statement not needed, since this is a Before trigger
                // method to update Program and Ic change Request after Opportunity Closed won
             //   ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objNewOpp);
            }
        }
   }
   //Query all the field
   /* public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }*/
    // method to Update Student Program after Opportunity Stage get Closed Won
  public  void ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(Opportunity objOpp) 
    {
        list<nm_StudentProgram__c> lstUpdateStudentProgram = new list<nm_StudentProgram__c>();
        set<nm_StudentProgram__c> setOfStudentProgram = new set<nm_StudentProgram__c>();
        list<Account> lstUpdateAccount = new list<Account>();
        
        list<IC_Change_Request__c> lstICR=[select id,Student__c,nm_Reson__c,nm_TypeofRequest__c,New_Program__c,nm_Reason_for_Change_of_Program__c,New_Information_Center__c from IC_Change_Request__c where Student__c=:objOpp.Accountid and  Opportunity__c=:objOpp.id];
        
        if(ObjOpp.nm_StudentProgram__c !=null && ObjOpp.nm_Program__c !=null)
        {
            if(lstICR.size()>0)
            {
                for(IC_Change_Request__c objICChange : lstICR )
                {
                    if(objICChange.nm_TypeofRequest__c=='Program Change' && objICChange.New_Program__c !=null)  
                    {
                        nm_StudentProgram__c objStudentPro=new nm_StudentProgram__c(id=ObjOpp.nm_StudentProgram__c);
                        objStudentPro.nm_PreviousProgram__c=ObjOpp.nm_StudentProgram__r.nm_Program__c;
                        objStudentPro.nm_Program__c=objICChange.New_Program__c;
                        objStudentPro.nm_Reason_for_change_of_student_Program__c=objICChange.nm_Reason_for_Change_of_Program__c;
                        objStudentPro.nm_FeesPaidofSemester__c=Decimal.ValueOf(ObjOpp.nm_Semester__c);
                        setOfStudentProgram.add(objStudentPro);
                        UpdateICChangeStatusForPaymentApproved(ObjOpp,objICChange);
                    }
                    
                    if(objICChange.nm_TypeofRequest__c=='IC Change' && objICChange.New_Information_Center__c !=null && objICChange.Student__c !=null)   
                    {
                        Account objAccountUpdate=new Account(id=objICChange.Student__c);
                        // objAccountUpdate.nm_ReasonForICChange__c= objICChange.nm_Reson__c;
                        objAccountUpdate.nm_Centers__c=objICChange.New_Information_Center__c;
                        objAccountUpdate.OwnerId = getCenterUser(objICChange.New_Information_Center__c);
                        lstUpdateAccount.add(objAccountUpdate);
                        UpdateICChangeStatusForPaymentApproved(ObjOpp,objICChange);
                    }
                }
                
                if(lstUpdateAccount.size()>0 && !Test.isRunningTest())
                {
                    update lstUpdateAccount;
                }
                if(setOfStudentProgram.size()>0)
                {
                    lstUpdateStudentProgram = new List<nm_StudentProgram__c>(setOfStudentProgram );
                    update lstUpdateStudentProgram;
                }
                if(ObjOpp !=null && lstUpdateStudentProgram.size()>0)
                {
                    ObjOpp.nm_Program__c=lstUpdateStudentProgram[0].nm_Program__c;
                    //update ObjOpp;
                }
            }
        }
    }
  
    public void UpdateICChangeStatusForPaymentApproved(Opportunity ObjOpp,IC_Change_Request__c objICChange)
    {
      System.debug('<-------Entered UpdateICCHange method--------->');
        if(objOpp.StageName =='Closed Won')
        {
            objICChange.Status__c ='Approved';
            Update objICChange;
        }                
    }

    // public void CreateCareerService(list < Opportunity > lstOpp, map < id, Opportunity > OldMap) {
    //     for (Opportunity objOpp: lstOpp) {
    //         if (objOpp.StageName != OldMap.get(objOpp.id).StageName) {
    //             if (objOpp.StageName == 'Closed Won' && objOpp.Career_Service__c != null && objOpp.Career_Service__c != '') {
    //                 // CareerServiceProduct(objOpp.id, objOpp.AccountId);
    //                 System.enqueueJob(new CreateCareerServiceProduct(objOpp.AccountId, objOpp.id));
    //             }
    //         }
    //     }
    // }
 /*   public void CreateCareerService(list <Opportunity> lstOpp, map <id,Opportunity> OldMap) {
     if(IsAfterUpdateRunOncevs2){
            return;
        }        
        IsAfterUpdateRunOncevs2 = true;
           
          ProductHelper productHelper = new ProductHelper();
          Set<Id> OpportunityID = new  Set<Id>();
          Set<String> CareerServiceProduct = new Set<String>();
          Set<String> deleteoppId = new Set<String>();
          Map<String,Map<String,PriceBookEntry>> mapPricebook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
          OpportunityLineItem objopposItem  = new OpportunityLineItem (); 
          List<OpportunityLineItem> listLineitem = new List<OpportunityLineItem> ();
          list<OpportunityLineItem> deletelst = new list<OpportunityLineItem> ();

          for (Opportunity objOpp: lstOpp) {
              if (objOpp.StageName != OldMap.get(objOpp.id).StageName) {
                  if (objOpp.StageName == 'Closed Won' && objOpp.Career_Service__c != null && objOpp.Career_Service__c != '') {
                      // CareerServiceProduct(objOpp.id, objOpp.AccountId);
                      //  AccountID.add(objOpp.AccountId);
                      OpportunityID.add(objOpp.id);
                      CareerServiceProduct.add(objOpp.Career_Service__c);
                     
                  }
              }
              if(objOpp.Career_Service__c != null && objOpp.Career_Service__c != '' 
              && objOpp.Career_Service__c != OldMap.get(objOpp.id).Career_Service__c)
              {
                  //CareerServiceId.add(objOpp.Career_Service__c);
                  Map<String,PriceBookEntry> mapPricebook1 = mapPricebook.get(objOpp.Account.nm_Tagged_Pricebook__c); 
                  objopposItem = productHelper.CreateLineIteam(objOpp.Career_Service__c,mapPricebook1,objOpp.id);  
                  if(objopposItem!=null)
                  {
                      listLineitem.add(objopposItem);
                       deleteoppId.add(objOpp.Id);
                  }
  
                  
              }
              System.debug('old value--->'+OldMap.get(objOpp.id).Career_Service__c );
              System.debug('objOpp.Career_Service__c--->'+objOpp.Career_Service__c);

              if(objOpp.Career_Service__c != OldMap.get(objOpp.id).Career_Service__c && objOpp.Career_Service__c ==null && OldMap.get(objOpp.id).Career_Service__c!=null)
              {
                  system.debug('Entery to delete');
                  deleteoppId.add(objOpp.Id);
              }
          }
                                      
          if(OpportunityID.size()>0) {
          If( Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
             System.enqueueJob(new CreateCareerServiceProduct(OpportunityID,CareerServiceProduct));
             }
          }
          if(deleteoppId.size()>0)
          {
               deletelst = [select id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice from OpportunityLineItem where OpportunityId =:deleteoppId and Product_Name__c like 'Career%'];
              
              if(deletelst.size()>0)
              {
                  delete deletelst;
              }
              
          }
          if(listLineitem.size()>0)
          {
              insert listLineitem ;
          }

      }*/
      public void CreateCareerService(list <Opportunity> lstOpp, map <id,Opportunity> OldMap) {
        if(checkRecursive.runBeforeOnce())
          {
              return;
          }
           
         
          Set<Id> OpportunityID = new  Set<Id>();
          Set<String> CareerServiceProduct = new Set<String>();
      
          for (Opportunity objOpp: lstOpp) {
              if (objOpp.StageName != OldMap.get(objOpp.id).StageName) {
                  if (objOpp.StageName == 'Closed Won' && objOpp.Career_Service__c != null && objOpp.Career_Service__c != '') {
                      // CareerServiceProduct(objOpp.id, objOpp.AccountId);
                      //  AccountID.add(objOpp.AccountId);
                      OpportunityID.add(objOpp.id);
                      CareerServiceProduct.add(objOpp.Career_Service__c);
                      system.debug('Call career Service');
                     
                  }
              }
          }
                                      
          if(OpportunityID.size()>0) {
          If( Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
            system.debug('Call career Service queue');

             System.enqueueJob(new CreateCareerServiceProduct(OpportunityID,CareerServiceProduct));
             }
          }
      }
      /*public void CreateCareerServicevs2(list <Opportunity> lstOpp, map <id,Opportunity> OldMap) {
        if(IsAfterUpdateRunOncevs2){
               return;
           }        
           IsAfterUpdateRunOncevs2 = true;
              
             ProductHelper productHelper = new ProductHelper();
             Set<String> deleteoppId = new Set<String>();
             Map<String,Map<String,PriceBookEntry>> mapPricebook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
             List<OpportunityLineItem> listLineitem = new List<OpportunityLineItem> ();
             list<OpportunityLineItem> deletelst = new list<OpportunityLineItem> ();
   
             for (Opportunity objOpp: lstOpp) {
                 if(objOpp.Career_Service__c != null && objOpp.Career_Service__c != '' 
                 && objOpp.Career_Service__c != OldMap.get(objOpp.id).Career_Service__c)
                 {
                     //CareerServiceId.add(objOpp.Career_Service__c);
                     Map<String,PriceBookEntry> mapPricebook1 = mapPricebook.get(objOpp.Account.nm_Tagged_Pricebook__c); 
                    OpportunityLineItem objopposItem = productHelper.CreateLineIteam(objOpp.Career_Service__c,mapPricebook1,objOpp.id);  
                     if(objopposItem!=null)
                     {
                         listLineitem.add(objopposItem);
                          deleteoppId.add(objOpp.Id);
                     }                
                 }
                 System.debug('old value--->'+OldMap.get(objOpp.id).Career_Service__c );
                 System.debug('objOpp.Career_Service__c--->'+objOpp.Career_Service__c);
   
                 if(objOpp.Career_Service__c != OldMap.get(objOpp.id).Career_Service__c && objOpp.Career_Service__c ==null && OldMap.get(objOpp.id).Career_Service__c!=null)
                 {
                     system.debug('Entery to delete');
                     deleteoppId.add(objOpp.Id);
                 }
             }
                                         
             if(deleteoppId.size()>0)
             {
                  deletelst = [select id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice from OpportunityLineItem where OpportunityId =:deleteoppId and Product_Name__c like 'Career%'];
                 
                 if(deletelst.size()>0)
                 {
                     delete deletelst;
                 }
                 
             }
             if(listLineitem.size()>0)
             {
                 insert listLineitem ;
             }
   
       }*/
   
  
    
    public string getCenterUser(id centerId)
    {
        nm_UserMapping__c objUserMap = [select id,nm_User__c from nm_UserMapping__c where nm_Centers__c=:centerId];
        return objUserMap.nm_User__c;
    }
    
    //Method to handle all after insert call on opportunity
    public void AfterInsert(List<Opportunity> triggerNew, map<id, Opportunity> newMap)
    {
        //Method to create opportunity lineitem and payment record for Registration 
        CreateLineItem(triggerNew,newMap);
        
        //Method to create Student Program
        nmStudentProgramTriggerHandler studentclass = new nmStudentProgramTriggerHandler();
        studentclass.CreateStudentProgram(triggerNew);
        
        //Method to Update Opportunity
        UpdateOpportunityADDandStudentProgram(triggerNew);   
        updateBBAElectiveForSem6(triggerNew, newMap);
        updateBBAElective(triggerNew, newMap, 'INSERT');
    }
    
    //Method to handle all after update call on opportunity
    public void AfterUpdate(List<Opportunity> triggerNew, map<id, Opportunity> oldMap,map<id, Opportunity> newMap)
    {
        //Method to update semester on student program once opportunity status update to Fees Paid - Finance approved
        UpdateFeePaidSemesterOnStudentProgram(triggerNew, oldMap);
       
        //Added by Vikas 4-12-2015 to update Receipt No. on payment when Opps Stage Becomes Closed Won//
        GenerateSerialNumberOnPaymentForClosedWon(triggerNew,oldMap);
        
        //Newly Added to remove fixed debit record if dispatch is being made using other courier service //
        //  RemoveFixedDebitRecord(triggerNew,oldMap);
        //CallWebserivceforCloselost(triggerNew);
        UpdateOpportunityLineItemAfterFeetypeChange(triggerNew,oldMap);

        updateOpportunityOnLiveLectureTypeChange(triggerNew, oldMap);
        updateBBAElectiveForSem6(triggerNew, oldMap);

        updateBBAElective(triggerNew, oldMap, 'UPDATE');
        RepeatTerm(triggerNew,oldMap);
       //Career Service Record insert
       CreateCareerService(triggerNew,oldMap);
      // CreateCareerServicevs2(triggerNew,oldMap);

        UpdateStudentZoneProgramStatusForStageChange(triggerNew,oldMap);
        //Method to check for Debit entry or Credit entry required if share already reprocessed
         UpdateShare(triggerNew,oldMap);
        
        CreateICShareEntry(newMap,oldMap);

        // to call Liquiloans status update API in approved or rejected stage from our end
        callLoanStatusUpdate(newMap,oldMap);

        //re-registration cancelled
        //static function helper class 
        ReregCancellation.doReregistrationCancellation(triggerNew,oldMap); // re-reg cancellation
        
    }
    
    public void UpdateStudentZoneProgramStatusForStageChange(list<Opportunity> triggerNew,map<id,Opportunity> oldMap){
        System.debug('update UpdateStudentZoneProgramStatusForStageChange--->');
        Map<String,String> mapOfSapidVsStatus = new Map<String,String>();
        Map<String,String> mapOfSapidVsAccountId = new Map<String,String>();
        for(Opportunity opp : triggerNew){
            System.debug('opp StageName =>'+opp.StageName);
            System.debug('oldMap.get(opp.id).StageName =>'+oldMap.get(opp.id).StageName);
            String[] lstCancelStages = new String[] {'Admission Cancelled','Admission Cancellation','Rusticated'};
            if( oldMap.get(opp.id).StageName == 'Closed Won' && lstCancelStages.contains(opp.StageName)) {
                System.debug('Admission Cancelled called');                
                System.debug('opp.Student_Number__c ==>'+ opp.Student_Number__c);
                String sapid = opp.Student_Number__c;
                mapOfSapidVsStatus.put(sapid,opp.StageName);
                mapOfSapidVsAccountId.put(sapid,opp.AccountId);
            }
        }
        //Call out to test portal for updating the program status of the student//.
        for(String sapid : mapOfSapidVsAccountId.keySet()) {
            updateProgramStatusForStudentOnStudentPortal(sapid, mapOfSapidVsAccountId.get(sapid), mapOfSapidVsStatus.get(sapid)); 
            System.debug('Admission Cancelled/Rusticated called API'); 
        }
    }
    
    public void callWebserviveForClosedLost(list<Opportunity> triggerNew,map<id,Opportunity> OldMap)
    {
       for(Opportunity obj:triggerNew)
       {
          
          if(obj.StageName=='Registration Done' && obj.Close_lost__c && OldMap.get(obj.id).Close_lost__c != obj.Close_lost__c)
          {
            if(obj.Is_Re_Registration_Payment__c == false)
            {
                WebServiceForClosedLost.MakeStudentClosedLost(obj.AccountId,'Closed Lost','Lost'); 
                obj.StageName='Closed Lost';
            }
          }
          else if((obj.Close_lost__c && OldMap.get(obj.id).Close_lost__c != obj.Close_lost__c && obj.Is_Re_Registration_Payment__c ) 
                  ||
                  (obj.Opportunity_Status__c=='Closed lost forever' && OldMap.get(obj.id).Opportunity_Status__c != obj.Opportunity_Status__c && obj.Is_Re_Registration_Payment__c ))  
          {
              obj.StageName='Closed Lost';
          }
       }
    }
    
       
    
    
   /* public void RemoveFixedDebitRecord(list<Opportunity> triggerNew,map<id,Opportunity> oldMap)
    {
        set<id> accountIdForFixedDebitUpdate = new set<id>();
        boolean OldStageForOtherCourierOpps;
        decimal amountToBeUpdated = 0.00;
        for(Opportunity otp:triggerNew)
        {
            OldStageForOtherCourierOpps = oldMap.get(otp.id).Other_Courier_Service_Opportunity__c;
            if(otp.Other_Courier_Service_Opportunity__c == true && OldStageForOtherCourierOpps != true && otp.Other_Courier_Amount__c!=0.00)
            {
                accountIdForFixedDebitUpdate.add(otp.AccountId);
                amountToBeUpdated = otp.Other_Courier_Amount__c;
            }
        }
        if(accountIdForFixedDebitUpdate.size()>0)
        {
            list<IC_Payment_Transaction__c> fixedDebitList = [select id from IC_Payment_Transaction__c where Narration__c LIKE '%Book Courier Charges' and (Amount__c = 55.00 OR Amount__c = 59.00) and Account__c in:accountIdForFixedDebitUpdate];
            if(fixedDebitList.size()>0 && fixedDebitList!=null)
            {
                for(IC_Payment_Transaction__c icPayment :fixedDebitList)
                {
                     icPayment.Amount__c = amountToBeUpdated;
                     update icPayment;
                }
            }
        }    
    }*/

    // code moved to stockDeductionsTriggerHandler 
    /*public void RemoveFixedDebitRecord(list<Opportunity> triggerNew,map<id,Opportunity> oldMap)
    {
        set<id> accountIdForFixedDebitUpdate = new set<id>();
        set<id> oppId = new set<id>();
        boolean OldStageForOtherCourierOpps;
        decimal amountToBeUpdated = 0.00;
        Decimal DebitAmount;
        Decimal CreditAmount;
        Decimal CourierCharge;
        Date today = Date.Today(); 
        Integer CurrentYear = today.Year();
        Integer CurrentMonth = 0;
        
        for(Opportunity otp:triggerNew)
        {
            OldStageForOtherCourierOpps = oldMap.get(otp.id).Other_Courier_Service_Opportunity__c;
            System.debug('Other_Courier_Service_Opportunity__c '+otp.Other_Courier_Service_Opportunity__c +' OldStageForOtherCourierOpps'+OldStageForOtherCourierOpps+' Other_Courier_Amount__c'+otp.Other_Courier_Amount__c);
            if(otp.Other_Courier_Service_Opportunity__c == true && OldStageForOtherCourierOpps != true && otp.Other_Courier_Amount__c!=0.00 )
            {
                accountIdForFixedDebitUpdate.add(otp.AccountId);
                oppId.add(otp.id);
                amountToBeUpdated = otp.Other_Courier_Amount__c;
                
            }
        }
        if(accountIdForFixedDebitUpdate.size()>0)
        {
            list<IC_Payment_Transaction__c> fixedDebitList = [select id,IC_name__c,Amount__c,Opportunity__c,Share_Processed__c,Opportunity__r.Account.Name,Opportunity__r.AccountId,Opportunity__r.id from IC_Payment_Transaction__c where Narration__c LIKE '%Book Courier Charges' and Opportunity__c in:oppId];
            
        system.debug('fixedDebitList--->'+fixedDebitList.size());
            
            CourierCharge = Integer.ValueOf(Label.Courier_charge); 
           if(fixedDebitList!=null)
            {
                if(fixedDebitList.size()==1 )
                {      
                    if(amountToBeUpdated == 0 && !fixedDebitList[0].Share_Processed__c)
                    {
                        Delete fixedDebitList;
                    }
                    else if(amountToBeUpdated >0 && !fixedDebitList[0].Share_Processed__c)
                    {
                        fixedDebitList[0].Amount__c = amountToBeUpdated;
                        update fixedDebitList;

                    }
                    else if(amountToBeUpdated > CourierCharge && fixedDebitList[0].Share_Processed__c )    
                    {
                        DebitAmount = amountToBeUpdated  -  CourierCharge;  
                    }
                    else if (CourierCharge > amountToBeUpdated  && fixedDebitList[0].Share_Processed__c )   
                    {
                        CreditAmount =  CourierCharge - amountToBeUpdated ;  
                    }
                    else if(amountToBeUpdated == 0 && fixedDebitList[0].Share_Processed__c)
                    {
                        CreditAmount = fixedDebitList[0].Amount__c ;
                    }                 
                  
                }  
                else if(fixedDebitList.size()>1 && amountToBeUpdated>0)
                {
                    DebitAmount = amountToBeUpdated ; 
                }
                
              
                if(DebitAmount>0 || CreditAmount>0)
                {
                    Opportunity objOpp = new Opportunity (id = fixedDebitList[0].Opportunity__c );
                    String ICName = fixedDebitList[0].IC_name__c;
                    String Narration = 'Book Courier Charges';
                    nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
                    
                      if(today.day() <= 10 ){
                        CurrentMonth =today.Month();
                        }else{
                        CurrentMonth = today.Month() + 1;
                        }
                    if(CurrentMonth >=13)
                    {
                        CurrentMonth = CurrentMonth - 12;
                        CurrentYear = today.Year()+1;
                    }
                    if (DebitAmount>0)
                    {                            
                        handler.createICTransactionDebitEntry(objOpp, CurrentYear, CurrentMonth,DebitAmount,ICName,Narration);
                    }
                    else if(CreditAmount>0)
                    {
                        handler.createICTransactionCreditEntry(objOpp, CurrentYear, CurrentMonth,CreditAmount,ICName,Narration);
                    }
                   
                }
                
                
            }

            
        }    
    }*/
    public void GenerateSerialNumberOnPaymentForClosedWon(list<Opportunity> triggerNew,map<id,Opportunity> oldMap) //newly added by vikas on 04-12-2015//
    {
        System.debug('<-------GenerateSerialNumberOnPaymentForClosedWon------------------>'+triggerNew);
         set<id> idOfNewOpportunity = new set<id>();
        list<nm_Payment__c> listPaymentRelated = new list<nm_Payment__c>();
        boolean isCertificate = false;
                
        for(Opportunity opps:triggerNew)
        {
            if((opps.StageName =='Closed Won' && opps.StageName !=oldMap.get(opps.id).StageName) || (opps.StageName == 'Closed Won - Re-registration Pending'))
            {
                idOfNewOpportunity.add(opps.id);
            }
            if(opps.Choose_a_Program__c =='C')
            {
                isCertificate = true;
            }
            else
            {
                isCertificate = false;
            }
        }
        if(idOfNewOpportunity.size()>0)
        {
           System.debug('Opportunity Ids'+idOfNewOpportunity);
            list<Opportunity> oppsSerialNumber = [select id,StageName,(select Semester_Line_Item__c,Currency_To_Words__c,nm_PaymentType__c ,Receipt_Number__c,nm_PaymentStatus__c from Opportunities__r) from Opportunity where id in:idOfNewOpportunity];
            for(Opportunity obj:oppsSerialNumber)
            {
                if((obj.StageName =='Closed Won' || obj.StageName == 'Closed Won - Re-registration Pending')) 
                {   
                        System.debug('Entered Closed Won Or Block');
                        listPaymentRelated = obj.Opportunities__r;
                        System.debug('<-----------listPaymentRelated----------------->'+listPaymentRelated);
                        UpdatePaymentAndSerialNum(listPaymentRelated,isCertificate);
                        
                 }
             } 
         }       
    }
     public void UpdatePaymentAndSerialNum(list<nm_Payment__c> listPayment,boolean isCertificate)
    {
         List<nm_Payment__c> lstMaxReceipt = new List<nm_Payment__c>();
         String maxNMATReceiptNo = 'SDLC-1718'+'00000';
         System.debug('Receipt Number Method Called');
         for(nm_Payment__c newPayment:listPayment)
         {
            System.debug('<----------newPayment.Receipt_Number__c--------->'+newPayment.Receipt_Number__c);
             if(newPayment.Receipt_Number__c ==null && newPayment.nm_PaymentType__c =='Admission' && newPayment.nm_PaymentStatus__c =='Payment Approved')
             {      
                 if(isCertificate == false)
                 {
                     String year = string.valueof(System.now().year()).substring(2,4);
                     String month = string.valueof(System.now().month()).length() <2 ? '0'+string.valueof(System.now().month()):string.valueof(System.now().month());
                     String day = string.valueof(System.now().day()).length() <2 ? '0'+string.valueof(System.now().day()) : string.valueof(System.now().day());
                     String todaysdate = year+month+day;
                     if(todaysdate.length()<2)
                     {
                         todaysdate = '0'+ todaysdate;
                     }  
                     String ReceiptNo = '200'+todaysdate;
                     String UniqueReceipNumber  = ReceiptNo +(Integer)Math.floor(100000 + Math.random()*900000);
                     newPayment.Receipt_Number__c = FindDuplicateReceiptNumber(UniqueReceipNumber,ReceiptNo);
                     update newPayment;
                 }
                 else if(isCertificate == true)
                 {
                      
                      lstMaxReceipt = [select id,Receipt_Number__c from nm_Payment__c where Receipt_Number__c!='' and Receipt_Number__c Like :('SDLC-1718%') order by Receipt_Number__c desc limit 1];
                      if(lstMaxReceipt.size()>0)
                     {
                        maxNMATReceiptNo = lstMaxReceipt[0].Receipt_Number__c;
                     }
                     
                     Long uniqueNMATMaxNumber = Long.valueOf(maxNMATReceiptNo.split('-')[1]);
                     uniqueNMATMaxNumber = uniqueNMATMaxNumber + 1; 
                     newPayment.Receipt_Number__c ='SDLC-'+uniqueNMATMaxNumber;
                     update newPayment;
                 }
             }
         }
    }
    
    public string FindDuplicateReceiptNumber(String ReceiptNumber , String ReceiptNo)
    {
        // query Payment to check Duplicate Receipt Number
        List<nm_Payment__c> lstPayment = [select id,Receipt_Number__c from nm_Payment__c where Receipt_Number__c =: ReceiptNumber and createddate=today];
        if(lstPayment.size()>0)
        {
            // if Duplicate Receipt number found then call same method by adding 1 in ReceiptNumber
            ReceiptNumber = ReceiptNo +(Integer)Math.floor(100000 + Math.random()*900000);
            return FindDuplicateReceiptNumber(ReceiptNumber , ReceiptNo);
        }
        else
        {
            //Receipt number is Unique
            
            return ReceiptNumber;
        }
    }    
    
    // code commented as not deployed international form
    // public void changeCurrencyISO(list<Opportunity> lst,map<id, Opportunity> newMap) {
    //     Set<Id> accoundIds = new Set<Id>();
        


    //     for(Opportunity objopp:lst) {
    //         accoundIds.add(objopp.AccountId);
    //         system.debug('objOpp.Form_Id__c --> ' +objopp.Form_Id__c);
    //         // if(objopp.Form_Id__c == 'INTERNATIONAL_FORM') {
    //         //     objopp.CurrencyIsoCode = 'USD';
    //         // }
    //     }
    //     Map<Id, Account> mapOfAccIdVsAcc = new Map<Id, Account>([SELECT Id, Form_Id__c FROM Account Where id IN :accoundIds]);

    //     for(Opportunity objopp:lst) {
    //         system.debug('objOpp.Form_Id__c --> ' +objopp.Form_Id__c);
    //         if(mapOfAccIdVsAcc.containsKey(objopp.AccountId)) {
    //             system.debug(' mapOfAccIdVsAcc.get(objopp.AccountId).Form_Id__c --> ' + mapOfAccIdVsAcc.get(objopp.AccountId).Form_Id__c);
    //             String formId = mapOfAccIdVsAcc.get(objopp.AccountId).Form_Id__c;
    //             if(formId == 'INTERNATIONAL_FORM') {
    //                 objopp.CurrencyIsoCode = 'USD';
    //             }
    //         }
    //         // if(objopp.Form_Id__c == 'INTERNATIONAL_FORM') {
    //         //     objopp.CurrencyIsoCode = 'USD';
    //         // }
    //     }
    //     system.debug('lstOfOppor --> ' );
    //     // if(lstOfOppor.size() > 0) {
    //     //     update lstOfOppor;
    //     // }

    // }

    public void CreateLineItem(list<Opportunity> lst,map<id, Opportunity> newMap)
    {
        ProductHelper productHelper = new ProductHelper();
        set<String> setOfOppsId = new set<String>();
        set<String> setOfAccountId = new set<String>();
        OpportunityLineItem objopposItem  = new OpportunityLineItem (); 
        List<OpportunityLineItem> listLineitem = new List<OpportunityLineItem> ();
        
        for(String OppsId : newMap.keySet())
        {
            setOfOppsId.add(OppsId);
        }
        for(Opportunity objOpps : lst)
        {
            setOfAccountId.add(objOpps.AccountId);
        }
        Map<String,Map<String,PriceBookEntry>> mapPricebook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<Id,Account> mapOfOppsVsAccount = productHelper.getOpportunityRelatedAccount(setOfAccountId);
        Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = productHelper.getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId);
        for(Opportunity objopp:lst)
        {
            String AccountPriceBookId = mapOfOppsVsAccount.get(objopp.AccountId).nm_Tagged_Pricebook__c;
            String taggedPriceBookId = String.isBlank(AccountPriceBookId) ? objopp.nm_Tagged_Pricebook__c : AccountPriceBookId;
            System.debug('AccountPriceBookId =>'+AccountPriceBookId);
            System.debug('taggedPriceBookId =>'+taggedPriceBookId);
            System.debug('Repeated term--->'+objopp.TermRepeated__c);
            //   system.debug('CurrencyIsoCode--->'+objopp.CurrencyIsoCode);
            System.debug('Lst Opportunity Size In Insert Line Item---->'+mapPricebook.keySet());
            if(!objopp.TermRepeated__c)
            {
                productHelper.CreateSemesterLineIteam(objopp,mapPricebook,mapOfOppsVsAccount,mapOfOppsIdVsOpportunityLineItem );
            }else if(objopp.TermRepeated__c) {
                Map<String,PriceBookEntry> mapPricebook1 = mapPricebook.get(taggedPriceBookId); 
                objopposItem = productHelper.CreateLineIteam('Repeat Term',mapPricebook1,objopp.id);  
                if(objopposItem!=null) {
                    listLineitem.add(objopposItem);
                }
            }
            if((objopp.LiveLecturesType__c!=null && objopp.LiveLecturesType__c!='No') || (objopp.BacklogList__c!=null))
            {
                Map<String,PriceBookEntry> mapPricebook2 = mapPricebook.get(taggedPriceBookId);
                Decimal unitpriceLiveLecture = productHelper.ActualUnitpriceLiveLecture(objopp,mapPricebook2);
                if(objopp.LiveLecturesType__c!=null && objopp.LiveLecturesType__c!='No') {
                    OpportunityLineItem objopposItemLiveLecture = new OpportunityLineItem(); 
                    objopposItemLiveLecture.OpportunityId = objopp.id;
                    objopposItemLiveLecture.PriceBookEntryId = mapPricebook2.get('Live Lectures').id;
                    objopposItemLiveLecture.Quantity = 1.00;
                    objopposItemLiveLecture.UnitPrice = productHelper.UnitpriceLiveLecture(objopp,objopp.LiveLecturesType__c,mapPricebook2);
                    objopposItemLiveLecture.ActualSalePrice__c =unitpriceLiveLecture ;         
                    
                    if(objopposItemLiveLecture!=null)
                    {
                        listLineitem.add(objopposItemLiveLecture);
                    }
                }
                if(objopp.BacklogList__c!=null) {
                    OpportunityLineItem objopposItemLiveLecture1 = new OpportunityLineItem();
                    Decimal BacklogPrice = mapPricebook2.containskey('Backlog') ? mapPricebook2.get('Backlog').UnitPrice : 0; 
                    
                    Decimal nosubj=0;
                    nosubj = productHelper.BacklogUnitPrice(objopp.BacklogList__c);
                
                    Decimal unitprice = BacklogPrice * nosubj;
                                    
                    objopposItemLiveLecture1.OpportunityId = objopp.id;
                    objopposItemLiveLecture1.PriceBookEntryId = mapPricebook2.get('Backlog').id;
                    objopposItemLiveLecture1.Quantity = 1.00;
                    objopposItemLiveLecture1.UnitPrice = unitprice;
                    objopposItemLiveLecture1.ActualSalePrice__c = unitprice ;         

                    if(objopposItemLiveLecture1!=null)
                    {
                        listLineitem.add(objopposItemLiveLecture1);
                    }
                }
            }    
        }
        if(listLineitem.size()>0) {
            insert listLineitem ;
        }
    }
        
    //Method to update semester on student program once opportunity status update to Fees Paid - Finance approved
   /* public void UpdateFeePaidSemesterOnStudentProgram(List<Opportunity> lstOpportunity, map<id, Opportunity> mapOldOpportunity)
    {
        System.debug('<---entered UpdateFeePaidSemesterOnStudentProgram--->');
        
        if(lstOpportunity != null && lstOpportunity.size() > 0)
        {
            System.debug('lstOpportunity.size>0');
            //Map to store highest sem against student program
            map<id, integer> mapSPandSemNumber = new map<id, integer>();  
            //Filling map mapSPandSemNumber
            for(Opportunity objOpp : lstOpportunity)
            {
                System.debug('<-----objOpp----->'+objOpp);
                System.debug('<-----objOpp.StageName----->'+objOpp.StageName+'<-------mapOldOpportunity.get(objOpp.id).StageName--->'+mapOldOpportunity.get(objOpp.id).StageName);
                if(objOpp.StageName == 'Closed Won' 
                    && mapOldOpportunity.get(objOpp.id).StageName != 'Closed Won' 
                    && objOpp.nm_StudentProgram__c != null 
                    && objOpp.nm_Semester__c != null)
                {
                    integer newSem = integer.valueOf(objOpp.nm_Semester__c);
                    System.debug('<---newSem--->'+newSem);
                    if(mapSPandSemNumber.get(objOpp.nm_StudentProgram__c) == null)
                    {
                        mapSPandSemNumber.put(objOpp.nm_StudentProgram__c, newSem);
                        system.debug('mapSPandSemNumber'+mapSPandSemNumber.get(objOpp.nm_StudentProgram__c));
                    }    
                    else
                    {
                        //Checking if already filled sem is greater than new one
                        if(mapSPandSemNumber.get(objOpp.nm_StudentProgram__c) < newSem)
                        {
                            mapSPandSemNumber.put(objOpp.nm_StudentProgram__c, newSem);
                           system.debug('mapSPandSemNumber else'+mapSPandSemNumber.get(objOpp.nm_StudentProgram__c));
                        }     
                    }
                }
            } 
            System.debug('<---mapSPandSemNumber.size()---->'+mapSPandSemNumber.size());
            if(mapSPandSemNumber.size() > 0)
            {
                //Fetching all Student programs to update fee paid semesters
                List<nm_StudentProgram__c> lstStudentProgram = [select id, 
                                                                       Name, 
                                                                       nm_FeesPaidofSemester__c 
                                                                       from nm_StudentProgram__c
                                                                       where id in: mapSPandSemNumber.keyset()];
                 System.debug('<----lstStudentProgram--->'+lstStudentProgram );                                                      
                if(lstStudentProgram != null && lstStudentProgram.size() > 0)
                {
                    //updating new semester in fee paid sem fiels of student program
                    for(nm_StudentProgram__c objSP : lstStudentProgram)
                    {
                        System.debug('<---------mapSPandSemNumber.get(objSP.id)------------------>'+mapSPandSemNumber.get(objSP.id)+'<---------objSP.nm_FeesPaidofSemester__c----->'+objSP.nm_FeesPaidofSemester__c+'<--mapSPandSemNumber.get(objSP.id)--->'+mapSPandSemNumber.get(objSP.id));
                        if(mapSPandSemNumber.get(objSP.id) != null && objSP.nm_FeesPaidofSemester__c < mapSPandSemNumber.get(objSP.id))
                        {
                            objSP.nm_FeesPaidofSemester__c = mapSPandSemNumber.get(objSP.id); 
                        }
                    }
                    
                    //Updating student program
                    update lstStudentProgram;
                }                                                                      
            }
        }
    }*/
  //Method to update semester on student program once opportunity status update to Fees Paid - Finance approved
 //Method to update semester on student program once opportunity status update to Fees Paid - Finance approved
       public void UpdateFeePaidSemesterOnStudentProgram(List<Opportunity> lstOpportunity, map<id, Opportunity> mapOldOpportunity)
       {
           List<nm_StudentProgram__c> lstStudentProgram = new List<nm_StudentProgram__c>();
           
           if(lstOpportunity != null && lstOpportunity.size() > 0)
           {
               System.debug('lstOpportunity.size>0');
               //Map to store highest sem against student program             
               Id Studprg; 
               //Filling map mapSPandSemNumber
               for(Opportunity objOpp : lstOpportunity)
               {
                   System.debug('<-----objOpp----->'+objOpp);
                   System.debug('<-----objOpp.StageName----->'+objOpp.StageName+'<-------mapOldOpportunity.get(objOpp.id).StageName--->'+mapOldOpportunity.get(objOpp.id).StageName);
                   if(objOpp.StageName == 'Closed Won' 
                       && mapOldOpportunity.get(objOpp.id).StageName != 'Closed Won' 
                       && objOpp.nm_StudentProgram__c != null 
                       && objOpp.nm_Semester__c != null)
                   {
                        integer newSem = integer.valueOf(objOpp.nm_Semester__c);
                        integer CurrentSem = integer.valueOf(objOpp.nm_FeesPaidofSemester__c);
                        Studprg = objOpp.nm_StudentProgram__c;
                        nm_StudentProgram__c objSP = new nm_StudentProgram__c(id = Studprg);
                        objSP.nm_FeesPaidofSemester__c = CurrentSem < newSem ? newSem:CurrentSem; 
                        lstStudentProgram.add(objSP);
                   }
                }                                                            
               if(lstStudentProgram != null && lstStudentProgram.size() > 0)
               {
                   //Updating student program
                   update lstStudentProgram;
               }                                                                      
               
           }
        }
      
          
    //Updating Opportunity with student program and opportuniy
    // --------------------------------------------------------------------------------------------- 
    // Version#     Date             Author                  Description
    // ---------------------------------------------------------------------------------------------
    // 1.0        -April-2014     Sumit Banarji           Initial Version
    // ---------------------------------------------------------------------------------------------            
   
    public void UpdateOpportunityADDandStudentProgram(list<Opportunity> lstOpportunity)
    {
        if(lstOpportunity != null)
        {
            set<id> setAccId = new set<id>();
            for(Opportunity objOpportunity : lstOpportunity)
            {
                setAccId.add(objOpportunity.AccountID);
            }
            
           list<nm_StudentProgram__c> lstStudentProgram = [select id, nm_Program__c, nm_Student__c from nm_StudentProgram__c where nm_Student__c in: setAccId];
           
           //Nested map for Student program id and program on respect of Account id
           map<id,map<id,id>> mapAccIdAndStudentProgram = new map<id,map<id,id>>();
           //used as inner map of student program id respect of program
           map<id,id> tempMapProgramStdProg;
           
           //Adding data in nested map
           if(lstStudentProgram != null)
           for(nm_StudentProgram__c objStudentProgrm : lstStudentProgram)
           {
                if(mapAccIdAndStudentProgram != null)
                {
                    if(mapAccIdAndStudentProgram.get(objStudentProgrm.nm_Student__c) != null)
                    {
                        tempMapProgramStdProg = mapAccIdAndStudentProgram.get(objStudentProgrm.nm_Student__c);
                        
                        tempMapProgramStdProg.put(objStudentProgrm.nm_Program__c,objStudentProgrm.id);
                        
                        mapAccIdAndStudentProgram.put(objStudentProgrm.nm_Student__c,tempMapProgramStdProg);
                    }
                    else
                    {
                        tempMapProgramStdProg = new map<id,id>();
                        
                        tempMapProgramStdProg.put(objStudentProgrm.nm_Program__c,objStudentProgrm.id);
                        
                        mapAccIdAndStudentProgram.put(objStudentProgrm.nm_Student__c,tempMapProgramStdProg);
                    }
                }
                else
                {
                    tempMapProgramStdProg = new map<id,id>();
                    
                    tempMapProgramStdProg.put(objStudentProgrm.nm_Program__c,objStudentProgrm.id);
                    
                    mapAccIdAndStudentProgram.put(objStudentProgrm.nm_Student__c,tempMapProgramStdProg);
                }
                
           }
           
           //Map of Admission Drive Date respect of program id
        //    map<id,nm_AdmissionDriveDate__c> mapADD = new map<id,nm_AdmissionDriveDate__c>(); 
           
        //    date dt = date.newInstance(system.now().year(),system.now().month(),system.now().day());
           
        //    list<nm_AdmissionDriveDate__c> lstADD = [select name, nm_Batch__c, nm_Program__c,
        //                                             nm_DriveDate__c, nm_Year__c 
        //                                             from nm_AdmissionDriveDate__c 
        //                                             where nm_DriveDate__c >=: dt ];
        //    if(lstADD != null)
        //    {                                                                                        
        //        for(nm_AdmissionDriveDate__c objADD : lstADD)
        //         {
        //             mapADD.put(objADD.nm_Program__c,objADD);
        //         }
        //    }
           
           //List of opportunities to update         
           List<Opportunity> lstOppToUpdate = new List<Opportunity>();
            
           for(Opportunity objOpportunity : lstOpportunity)
           {
                Opportunity objOppToUpdate = new Opportunity(id=objOpportunity.id);
                
                //Inserting Student Program
                if(mapAccIdAndStudentProgram.get(objOpportunity.AccountId) != null)
                    objOppToUpdate.nm_StudentProgram__c = mapAccIdAndStudentProgram.get(objOpportunity.AccountId).get(objOpportunity.nm_Program__c);
                    
                //inserting Admission Drive date
                // if(mapADD != null)
                // {
                //     if(mapADD.get(objOpportunity.nm_Program__c) != null &&  objOpportunity.nm_Semester__c == '1')
                //     objOppToUpdate.nm_AdmissionDriveDate__c = mapADD.get(objOpportunity.nm_Program__c).id;  
                // }
                    
                if(objOppToUpdate.nm_StudentProgram__c != null)
                        lstOppToUpdate.add(objOppToUpdate);
            }
            
            //Update opportunities
            if(lstOppToUpdate != null)
                update lstOppToUpdate;
        }
    }   
    
     //Method to update Student No on Account
    // --------------------------------------------------------------------------------------------- 
    // Version#     Date             Author                  Description
    // ---------------------------------------------------------------------------------------------
    // 2.0        08-May-2014     Sumit Banarji           Edited Version
    // ---------------------------------------------------------------------------------------------
    
    /*  public void insertStudentNoVer2(list<Opportunity> lstOpp)
    {
         if(checkRecursive.StopRecurrenceOnOpp != 1)
        {
            checkRecursive.StopRecurrenceOnOpp = 1;
        }
        else
        {
            return;
        }
        
        if(lstOpp != null )
        {
            set<id> setAccountID = new set<id>();  
            string strPreStudentID = '77';
            String StudentNo;
            String strSession;
              Integer intYesr;
             list<Account> lstAccountToUpdate = new list<Account>();
             
            
               list< Calender__c > lstCalender = [select Session_End_Date__c,nm_Type__c,Category__c, Session_Start_Date__c,Session__c,Year__c from Calender__c where Category__c ='Admission' and Session_Start_Date__c <= : date.Today() 
                                                and Session_End_Date__c >= : date.Today()];
    
               system.debug('lstCalender'+lstCalender);            
            for(Opportunity objOpp : lstOpp)
            {
                Date DtToday=system.today();
                
                setAccountID.add(objOpp.AccountId);
                if(lstCalender.size()>0)
                {
            for(Calender__c objcal:lstCalender)
            {
                system.debug('objOpp.ChooseProgram__c'+objOpp.ChooseProgram__c);
                system.debug('objcal.nm_Type__c'+objcal.nm_Type__c);
                   if('Executive Programs'.equalsIgnoreCase(objcal.nm_Type__c) && 'Executive Programs'.equalsIgnoreCase(objOpp.ChooseProgram__c ))
                    {
                        if(!IsNullOrEmpty(objcal.Session__c) && objcal.Year__c !=null  )
                        {
                            strSession=objcal.Session__c;
                            intYesr=Validyear(objcal.Session__c,objcal.Year__c).intValue();
                            system.debug(strSession+''+intYesr);
                        }
                       break;
                    }
                    else if('Executive MBA'.equalsIgnoreCase(objcal.nm_Type__c) && 'Executive MBA'.equalsIgnoreCase(objOpp.ChooseProgram__c ))
                    {
                        if(!IsNullOrEmpty(objcal.Session__c) && objcal.Year__c !=null  )
                        {
                            strSession=objcal.Session__c;
                            intYesr=Validyear(objcal.Session__c,objcal.Year__c).intValue();
                            system.debug(strSession+''+intYesr);
                        }
                       break;
                    }   
                    else if('Certificate Programs'.equalsIgnoreCase(objcal.nm_Type__c) && 'Certificate Programs'.equalsIgnoreCase(objOpp.ChooseProgram__c ))
                    {
                        if(!IsNullOrEmpty(objcal.Session__c) && objcal.Year__c !=null  )
                        {
                            strSession=objcal.Session__c;
                            intYesr=Validyear(objcal.Session__c,objcal.Year__c).intValue();
                            system.debug(strSession+''+intYesr);
                        }
                       break;
                    }                   
                    else if ('Admission'.equalsIgnoreCase(objCal.Category__c) && IsNullOrEmpty(objCal.nm_Type__c))
                    {
                        if(!IsNullOrEmpty(objcal.Session__c) && objcal.Year__c !=null  )
                        {
                            strSession=objcal.Session__c;
                            intYesr=Validyear(objcal.Session__c,objcal.Year__c).intValue();
                            system.debug(strSession+''+intYesr);
                        }
                    }                                                                       
                }
                  
                }
                if(strSession == 'July')
                {
                    strPreStudentID = strPreStudentID + '1' + string.valueof(intYesr).substring(2,4);
                }
                else if(strSession == 'January')
                {
                    strPreStudentID = strPreStudentID + '2' + string.valueof(intYesr).substring(2,4);
                }
                 else if(strSession == 'April')
                {
                    strPreStudentID = strPreStudentID + '3' + string.valueof(intYesr).substring(2,4);
                }
                 else if(strSession == 'October')
                {
                    strPreStudentID = strPreStudentID + '4' + string.valueof(intYesr).substring(2,4);
                }
                system.debug(strSession+'final'+intYesr);
            }
             StudentNo = strPreStudentID +(Integer)Math.floor(100000 + Math.random()*900000);
             
             // call method to get Unique Student Number
             String UniqueStudentNo =FindDuplicateStudentNo(StudentNo,strPreStudentID );
             system.debug('UniqueStudentNo'+UniqueStudentNo );
             
             // Newly added by Phalguni on 2-9-2016
            // section to update Serial number on Confirmed Account
            nmSerialNo__c  objSerialNo=[select id,nm_MaxGenratedNo__c,LastModifiedDate from nmSerialNo__c where nm_name__c='Reference Number' limit 1]; 
            
             DateTime lastModDate;
             Date lastModifiedMonth;    
                    
            System.debug('<------objSerialNo--------->'+objSerialNo);
            if( objSerialNo != null )
            {       
                lastModDate = Datetime.valueOf(objSerialNo.LastModifiedDate);
                lastModifiedMonth = date.newinstance(lastModDate.year(),lastModDate.month(),lastModDate.day());
                System.debug('lastModifiedMonth.month()------'+lastModifiedMonth.month());  
                     
                if(lastModifiedMonth.day() != datetime.now().day() )
                {
                  System.debug('lastModifiedMonth.month()------'+lastModifiedMonth.month());
                  System.debug('datetime.now().month()'+datetime.now().month());
                  objSerialNo.nm_MaxGenratedNo__c = 0;                
                }               
                else
                {
                  objSerialNo.nm_MaxGenratedNo__c += 1;   
                                
                }
            }
            
            if(UniqueStudentNo !=null)
            {
                map<id,Account> objAccountChk = new map<id,Account> ([Select id,nm_StudentNo__c from Account where id in: setAccountID and (nm_StudentNo__c = null or nm_StudentNo__c = '')]);
                system.debug('objAccountChk'+objAccountChk );
                   //boolean IsAdharNumberPresent=CheckIsAdharNumberPresent(lstOpp);
                  
                for(Opportunity objOpp : lstOpp)
                {
                    if(objAccountChk.get(objOpp.AccountID) != null)
                    {
                       System.debug('objOpp.StageName-->'+objOpp.StageName);
                       if(objOpp.StageName == 'Closed Won')
                       {  
                          system.debug('enter in true section'); 
                          Account objAccount = new Account(id = objOpp.AccountID);
                          objAccount.nm_StudentNo__c = UniqueStudentNo;
                          objAccount.nm_PreStudentNo__c =strPreStudentID;
                        // objAccount.b__c= strSession.left(3)+'/n'+intYesr;
                           String ReferencenceCode = String.valueOf( datetime.now().day())+String.valueOf( datetime.now().month())+String.valueOf(objSerialNo.nm_MaxGenratedNo__c);
                          String UniqueRefCode =FindDuplicateRefCode(ReferencenceCode);
                          objAccount.Ref__c = UniqueStudentNo ;
                          objAccount.nm_NewPassword__c = generatePassword();
                          lstAccountToUpdate.add(objAccount);
                          update objSerialNo;
                        }
                        
                    }
                }
            }
            if(lstAccountToUpdate != null && lstAccountToUpdate.size() > 0)
            {
                update lstAccountToUpdate;
            }
        }
    }*/
    public void insertStudentNoVer2(list<Opportunity> lstOpp)
    {
        if(checkRecursive.StopRecurrenceOnOpp != 1)
        {
            checkRecursive.StopRecurrenceOnOpp = 1;
        }
        else
        {
            return;
        }
         if(lstOpp != null )
        {
            set<id> setAccountID = new set<id>();  
            string strPreStudentID = '77';
            String StudentNo;
            String strSession;
            Integer intYesr;
            Integer batchmonth;
            Integer batchyear;
            
            ProductHelper helper =new ProductHelper();
            list<Account> lstAccountToUpdate = new list<Account>();
            for(Opportunity objOpp : lstOpp)
            {
                Date DtToday=system.today();                
                setAccountID.add(objOpp.AccountId);
                
                if(!IsNullOrEmpty(objOpp.nm_Session__c) && objOpp.nm_Year__c!=null )
                {
                    strSession = objOpp.nm_Session__c;
                    intYesr = Validyear(objOpp.nm_Session__c,objOpp.nm_Year__c).intValue();
                    batchyear = Integer.valueof(objOpp.nm_Year__c);
                    system.debug(strSession+''+intYesr);
                }
                if(strSession == 'July')
                {
                    strPreStudentID = strPreStudentID + '1' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 07;
                }
                else if(strSession == 'January')
                {
                    strPreStudentID = strPreStudentID + '2' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 01;
                }
                 else if(strSession == 'March')
                {
                    strPreStudentID = strPreStudentID + '3' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 03;
                }
                 else if(strSession == 'April')
                {
                    strPreStudentID = strPreStudentID + '4' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 04;
                }
                 else if(strSession == 'September')
                {
                    strPreStudentID = strPreStudentID + '5' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 09;
                }
               // system.debug(strSession+'final'+intYesr);
                else if(strSession == 'June')
                {
                    strPreStudentID = strPreStudentID + '6' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 06;
                }
                else if(strSession == 'October')
                {
                    strPreStudentID = strPreStudentID + '7' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 10;
                }
                else if(strSession == 'December')
                {
                    strPreStudentID = strPreStudentID + '8' + string.valueof(intYesr).substring(2,4);
                    batchmonth = 12;
                }
                system.debug(strSession+'final'+intYesr);
                
            }
             StudentNo = strPreStudentID +(Integer)Math.floor(100000 + Math.random()*900000);
             
             // call method to get Unique Student Number
             String UniqueStudentNo =FindDuplicateStudentNo(StudentNo,strPreStudentID );
             system.debug('UniqueStudentNo'+UniqueStudentNo );            
              List<nmSerialNo__c> listtoupdate = new List<nmSerialNo__c>();
            if(UniqueStudentNo !=null)
            {
             //  map<id,Account> objAccountChk = new map<id,Account> ([Select id,nm_StudentNo__c,Sem__c from Account where id in: setAccountID and (nm_StudentNo__c = null or nm_StudentNo__c = '')]);
               // system.debug('objAccountChk'+objAccountChk );
                   //boolean IsAdharNumberPresent=CheckIsAdharNumberPresent(lstOpp);
             
                 for(Opportunity objOpp : lstOpp)
                {
                    
                       System.debug('objOpp.StageName-->'+objOpp.StageName);
                       system.debug('objOpp.Student_Number__c--->'+objOpp.Student_Number__c);
                       if(objOpp.StageName == 'Closed Won' && objOpp.Student_Number__c==null )
                       {  
                          system.debug('enter in true section'); 
                          Account objAccount = new Account(id = objOpp.AccountID);
                          nmSerialNo__c  objSerialNo =  MaxGenratedNo();
                          nm_Program__c  objprogram = GetProgram(objOpp);
                          objAccount.nm_StudentNo__c = UniqueStudentNo;
                          objAccount.nm_PreStudentNo__c =strPreStudentID;
                          objAccount.BatchStartD__c = date.newinstance(batchyear,batchmonth,01);
                          objAccount.ValidUptoR__c = helper.Validity(date.newinstance(batchyear,batchmonth,01),objprogram,Integer.valueof(objOpp.nm_Semester__c));
                        // objAccount.b__c= strSession.left(3)+'/n'+intYesr;
                           String ReferencenceCode = String.valueOf( datetime.now().day())+String.valueOf( datetime.now().month())+String.valueOf(objSerialNo.nm_MaxGenratedNo__c);
                          String UniqueRefCode =FindDuplicateRefCode(ReferencenceCode);
                          objAccount.Ref__c = UniqueStudentNo ;
                          objAccount.nm_NewPassword__c = generatePassword();
                          lstAccountToUpdate.add(objAccount);
                          listtoupdate.add(objSerialNo);
                        }
                        
                   
                }
            }
            if(lstAccountToUpdate != null && lstAccountToUpdate.size() > 0)
            {
                update lstAccountToUpdate;
                
            }
            if(listtoupdate !=null && listtoupdate.size() > 0)
            {
                update listtoupdate;
            }
        }
    }
        public Decimal Validyear (String Session,Decimal Year)
        {
            decimal intYesr;
            if('January'.equalsIgnoreCase(Session))
            {
                intYesr = Integer.ValueOf(Year)-1;
            }
            else
            {
                intYesr=Integer.ValueOf(Year);
            }
            return intYesr;
        }
           
    public nmSerialNo__c MaxGenratedNo() {
       // Newly added by Phalguni on 2-9-2016
        // section to update Serial number on Confirmed Account
        List<nmSerialNo__c> lstSerialNo=[select id,nm_MaxGenratedNo__c,LastModifiedDate from nmSerialNo__c where nm_name__c='Reference Number' limit 1]; 
        
        DateTime lastModDate;
        Date lastModifiedMonth;    
                
        System.debug('<------lstSerialNo--------->'+lstSerialNo);
        if(lstSerialNo.size() > 0) {       
            nmSerialNo__c objSerialNo = lstSerialNo[0];
            lastModDate = Datetime.valueOf(objSerialNo.LastModifiedDate);
            lastModifiedMonth = date.newinstance(lastModDate.year(),lastModDate.month(),lastModDate.day());
            System.debug('lastModifiedMonth.month()------'+lastModifiedMonth.month());  
                    
            if(lastModifiedMonth.day() != datetime.now().day() ) {
                System.debug('lastModifiedMonth.month()------'+lastModifiedMonth.month());
                System.debug('datetime.now().month()'+datetime.now().month());
                objSerialNo.nm_MaxGenratedNo__c = 0;                
            } else {
                objSerialNo.nm_MaxGenratedNo__c += 1;                                  
            }
            return objSerialNo;
        }
        return null;
    }

    public String FindDuplicateRefCode(String ReferencenceCode )//StudentNo is equal to PreStudentNo+randomNumber; 
    {
          // query Account to check Duplicate Student Number In current Session
        List<Account> lstAccount =[select id from Account where Ref__c =:ReferencenceCode ];
        if(lstAccount.size()>0)
        {
            // if Duplicate reference number found then call same method 
            ReferencenceCode = ReferencenceCode + 1;
            System.debug('Enter in method of Find Duplicate-->');
            return FindDuplicateRefCode(ReferencenceCode);
        }
        else{
         // if reference code number is Unique 
            System.debug(' Reference Code--->'+ReferencenceCode);
            return ReferencenceCode;
        }
    } 
    
    public String FindDuplicateStudentNo(String StudentNo,String strPreStudentID )//StudentNo is equal to PreStudentNo+randomNumber; 
    {
        // query Account to check Duplicate Student Number In current Session
        // also taking consideration of cancel and deregistred  while generating student no in order to avoid duplicate student 
        List<Account> lstAccount =[select id from Account where nm_StudentNo__c Like :('%'+StudentNo+'%') and nm_PreStudentNo__c=:strPreStudentID];
        if(lstAccount.size()>0)
        {
            // if Duplicate Student number found then call same method by applying random function
            StudentNo = strPreStudentID +(Integer)Math.floor(100000 + Math.random()*900000);
            System.debug('Enter in method of Find Duplicate-->');
            return FindDuplicateStudentNo(StudentNo,strPreStudentID);
        }
        else
        {
         // if Student number is Unique 
            System.debug('Return Student No--->'+StudentNo);
            return StudentNo;
        }
    }
    
 
    
 /*  public void UpdateOpportunityLineItemAfterFeetypeChange(list<Opportunity>lstOpp,map<id,Opportunity>OldMap)
    {
        list<OpportunityLineItem> lstOppLineItem=new list<OpportunityLineItem>();
        ProductHelper producthelperclass = new ProductHelper();
      
        for(Opportunity objOpp:lstOpp)
          {
             
             if(objOpp.nm_Fee_Type__c!=OldMap.get(objOpp.id).nm_Fee_Type__c ) 
             {
                  system.debug('Enter in Loop');
                  producthelperclass.UpdateOpportunityLineItemAfterFeetypeChange(objOpp);
             }
             
        
          }
         
    }*/    
        
    public void UpdateOpportunityLineItemAfterFeetypeChange(list<Opportunity>lstOpp , map<id,Opportunity>OldMap)
    {
        list<OpportunityLineItem> lstOppLineItem=new list<OpportunityLineItem>();
        ProductHelper producthelperclass = new ProductHelper();
        
        Set<Id> lstOppIds = new Set<Id>();
        set<Id> lstAccounts = new Set<Id>();
        Map<Id, List<Opportunity>> mapOfListOpp = new Map<Id, List<Opportunity>>();
        for(Opportunity objOppe:lstOpp) {
            lstOppIds.add(objOppe.Id);
            lstAccounts.add(objOppe.AccountId);
        }
        List<Opportunity> lstOpportunityToUpdateAfterNO = new List<Opportunity>();
        Set<Id> listOppId = new Set<Id>();
        // List<Opportunity> lstOpportunity = [Select Id, AccountId, LiveLecturesType__c From Opportunity Where AccountId IN :lstAccounts AND LiveLecturesType__c Like '%-Considered'];
        // system.debug('lstOpportunity ---> ' + lstOpportunity);

        // for(Id ids : lstAccounts) {
        //     List<Opportunity> lstOpportunityWithAccount = new List<Opportunity>();
        //     for(Opportunity opp: lstOpportunity) {
        //         system.debug('opp.AccountId ---> ' + opp.AccountId );
        //         system.debug('ids ---> ' + ids );
        //         if(opp.AccountId == ids) {
        //             lstOpportunityWithAccount.add(opp);
        //         }
        //     }
        //     mapOfListOpp.put(ids, lstOpportunityWithAccount);
        // }
        system.debug('UpdateOpportunityLineItemAfterFeetypeChange ---> ');
        system.debug('mapOfListOpp --> ' + mapOfListOpp);

        for(Opportunity objOpp:lstOpp)
        {
    
            if(objOpp.nm_Fee_Type__c!=OldMap.get(objOpp.id).nm_Fee_Type__c 
            ||( objOpp.LiveLecturesType__c!='' && objOpp.LiveLecturesType__c!=OldMap.get(objOpp.id).LiveLecturesType__c)
            ||( objOpp.LiveLecturesType__c=='Custom' && objOpp.CourseList__c!='' && objOpp.CourseList__c!=OldMap.get(objOpp.id).CourseList__c)
            ||( objOpp.BacklogList__c!='' && objOpp.BacklogList__c!=OldMap.get(objOpp.id).BacklogList__c)
            ||( objOpp.Coursera__c!=OldMap.get(objOpp.id).Coursera__c))
            {
                system.debug('Enter in Loop-->'+objOpp.nm_Program__c);                
                nm_Program__c  objprogram = GetProgram(objOpp);
                String specialEventType = objOpp.LiveLecturesType__c!='' && objOpp.LiveLecturesType__c!=OldMap.get(objOpp.id).LiveLecturesType__c ? 'LiveLectureTypeChange' : null;
                String specialPriorValue = String.isNotBlank(specialEventType) && specialEventType == 'LiveLectureTypeChange' ? OldMap.get(objOpp.id).StageName : null;
                
                if(objprogram !=null)
                {
                    system.debug('objOpp ----------->'+objOpp);
                    producthelperclass.UpdateOpportunityLineItemAfterFeetypeChange(objOpp,objprogram, specialEventType, specialPriorValue);
                    system.debug('objOpp.StageName---->'+objOpp.StageName);
                }
            }
            
            if((objOpp.LiveLecturesType__c=='Custom' && String.isBlank(objOpp.CourseList__c)  && objOpp.CourseList__c!=OldMap.get(objOpp.id).CourseList__c) ||
            (objOpp.LiveLecturesType__c=='No' && objOpp.LiveLecturesType__c!=OldMap.get(objOpp.id).LiveLecturesType__c  ) 
            ) {
                listOppId.add(objOpp.Id);
            }

            system.debug('objOpp.LiveLecturesType__c ---> ' + objOpp.LiveLecturesType__c);
            system.debug('OldMap.get(objOpp.id).LiveLecturesType__c ---> ' + OldMap.get(objOpp.id).LiveLecturesType__c);
            

            // if(objOpp.LiveLecturesType__c=='No'  
            //     && objOpp.LiveLecturesType__c!=OldMap.get(objOpp.id).LiveLecturesType__c 
            //     && OldMap.get(objOpp.id).LiveLecturesType__c.containsIgnoreCase('SemLecturesFee') 
            //     && !OldMap.get(objOpp.id).LiveLecturesType__c.containsIgnoreCase('-Considered')) {
            //         system.debug('inside of livelec --> ');
            //         if(mapOfListOpp.containsKey(objOpp.AccountId)) {
            //             List<Opportunity> mapOpp = mapOfListOpp.get(objOpp.AccountId);
            //             for(Opportunity oppds : mapOpp) {
            //                 system.debug('oppds ---> ' + oppds);
            //                 if(oppds.LiveLecturesType__c.containsIgnoreCase('SemLecturesFee-Considered')) {
            //                     Opportunity oppsId = new Opportunity();
            //                     oppsId.Id = oppds.Id;
            //                     oppsId.LiveLecturesType__c = 'No';
            //                     lstOpportunityToUpdateAfterNO.add(oppsId);
            //                 }
            //             }
            //         }

            // }
    
        }
        
        if(listOppId.size() > 0 && System.isFuture() == false ) {
            updatePaymentRecordOnCourseListChange(listOppId);
        }
        if(lstOpportunityToUpdateAfterNO.size() > 0) {
            update lstOpportunityToUpdateAfterNO;
        }
    }

    public void updateOpportunityOnLiveLectureTypeChange(list<Opportunity>lstOpp , map<id,Opportunity>OldMap) {
        Map<String, String> mapOfaccountIdVsCurrentOppAndLectureType = new Map<String, String>();
        Map<String, List<Opportunity>> mapOfAccountAndlstOpp = new Map<String, List<Opportunity>>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        if(lstOpp.size() > 0) {
            for (Opportunity objOpp : lstOpp) {
                if( objOpp.LiveLecturesType__c!=OldMap.get(objOpp.id).LiveLecturesType__c) {
                    String oldLiveLectureType = String.isNotBlank(OldMap.get(objOpp.id).LiveLecturesType__c) ? OldMap.get(objOpp.id).LiveLecturesType__c : 'No';
                    String newLiveLectureType = String.isNotBlank(objOpp.LiveLecturesType__c) ? objOpp.LiveLecturesType__c : 'No';
                    // AccountId-Semester-OldLiveLectureType-NewLiveLectureType
                    Boolean isValueChangedAndNotConsidered = String.isNotBlank(objOpp.LiveLecturesType__c) && objOpp.LiveLecturesType__c.contains('Considered') ? false : true;
                    if (isValueChangedAndNotConsidered) {
                        mapOfaccountIdVsCurrentOppAndLectureType.put(objOpp.AccountId, objOpp.AccountId + '-' + objOpp.nm_Semester__c + '-' + oldLiveLectureType + '-' + newLiveLectureType);
                    }
                }
            }
        }
        if (mapOfaccountIdVsCurrentOppAndLectureType.size() > 0) {
            List<Opportunity> lstOfallOpp = [SELECT Id, LiveLecturesType__c, nm_Semester__c, AccountId From Opportunity WHERE AccountId = :mapOfaccountIdVsCurrentOppAndLectureType.keySet()];
            if (lstOfallOpp.size() > 0 ) {
                for (Opportunity opp : lstOfallOpp) {
                    if(mapOfaccountIdVsCurrentOppAndLectureType.containsKey(opp.AccountId)) {
                        String key = mapOfaccountIdVsCurrentOppAndLectureType.get(opp.AccountId);
                        System.debug('key --> ' + key);
                        Integer getlowestSemester = Integer.valueOf(key.split('-')[1]);

                        String newLiveLectureType = key.split('-')[3].left(1);
                        Integer newLiveLectureNumber =newLiveLectureType.isNumeric() ? Integer.valueOf(newLiveLectureType) : 0;
                        Integer semesterValueFornew = newLiveLectureNumber > 0 ? getlowestSemester + (newLiveLectureNumber - 1) : getlowestSemester;
                        System.debug('semesterValueFornew --> ' + semesterValueFornew);
                        
                        String oldLiveLectureType = key.split('-')[2].left(1);
                        Integer oldLiveLectureNumber =oldLiveLectureType.isNumeric() ? Integer.valueOf(oldLiveLectureType) : 0;
                        Integer semesterValueForold = oldLiveLectureNumber > 0 ? getlowestSemester + (oldLiveLectureNumber - 1) : getlowestSemester;
                        System.debug('semesterValueForold --> ' + semesterValueForold);

                        if (getlowestSemester < Integer.valueOf(opp.nm_Semester__c) &&  Integer.valueOf(opp.nm_Semester__c) <= semesterValueFornew) {
                            lstOppToUpdate.add(new Opportunity(Id = opp.Id, LiveLecturesType__c = key.split('-')[3] + '-Considered'));
                        } else if(semesterValueFornew <= Integer.valueOf(opp.nm_Semester__c) && getlowestSemester < Integer.valueOf(opp.nm_Semester__c) && Integer.valueOf(opp.nm_Semester__c) <= semesterValueForold) {
                            lstOppToUpdate.add(new Opportunity(Id = opp.Id, LiveLecturesType__c = null));
                        }

                    }
                }
            }
        }
        if (lstOppToUpdate.size() > 0) {
            system.debug('lstOppToUpdate --> ' + lstOppToUpdate);
            update lstOppToUpdate;
        }
    }
    public static void sendEmailToFinanceDepartmentOnPaymentCreation(String paymentId, String merchantTrackId, String studentName) {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
        String url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + paymentId;
        system.debug('url -----> ' + url);
          String[] sendingToAddress = new List<String>();
      String sendingTocAddress = ''; 
      if(System.Label.Environment == 'Sandbox') {
        sendingToAddress.add('suyog.deshmukh.ext@nmims.edu');
        sendingToAddress.add('dsuyog2013@gmail.com');
      } else if(System.Label.Environment == 'Production') {
          sendingToAddress.add('tushar.jadhav@nmims.edu');
        sendingToAddress.add('manasvi.malve@nmims.edu');
      }
      semail.setToAddresses(sendingToAddress); 
        semail.setOrgWideEmailAddressId(owe.id); 
        semail.setReplyTo(owe.Address); 
        semail.setSubject('Live Lecture Adjust payment'); 
        String messageBody = '<html><p>Dear Team,</p>'
                                  +'<p>Kindly Approve payment record for the following Installment</p>'
                                  +'<p>Student name = '+ studentName +'</p>'
                                  +'<p>Payment Merchant Track Id = '+ merchantTrackId +'</p>'
                                  +'<p>Please click <a href="'+url+'" >here</a> to navigate to payment record</p>'
                                  +'<p>Thanks and Regards,</p>'
                                  +'<p>NMIMS CDOE</p></html>';
          semail.setHtmlBody(messageBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
    }
      public nm_Program__c GetProgram (Opportunity objOpps)
        {
            nm_Program__c objprogram = new nm_Program__c (id = objOpps.nm_Program__c);
            objprogram.Name = objOpps.Program_Name__c;
            objprogram.nm_Type__c = objOpps.ChooseProgram__c;
            objprogram.Specialisation__c = objOpps.Specialisation__c;
            objprogram.PVM__c= objOpps.PVM__c;
            objprogram.nm_TotalSemesters__c= objOpps.Total_Sem__c;
            objprogram.IsTerm__c= objOpps.IsTerm__c;
            return objprogram;
            
        }  
 
       public void UpdateShare(list<Opportunity>lstOpp,map<id,Opportunity>OldMap)
        {              
            set<String> setOfOppsId = new set<String>();       
            Date today = Date.Today(); 
            Integer CurrentYear = today.Year();
            Integer CurrentMonth = 0;
            double DebitAmount;
            double CreditAmount;
            double Shareforwarded;
            double RequiredShare;
            String Narration;
            double  ActualSaleprice;
            ProductHelper helper =new ProductHelper();
           for(Opportunity objOpp:lstOpp)
            {
                    setOfOppsId.add(objOpp.id);
                //Stage change 
                 if(objOpp.StageName!=OldMap.get(objOpp.id).StageName)
                {//Check whether share processed or not
                    if( objOpp.StageName=='Closed Won' && objOpp.Processed__c == true && !objOpp.nm_Fee_Type__c.contains('-Considered')) 
                    {                                                                              
                            Shareforwarded = helper.getCreditSum(setOfOppsId) - helper.getDebitSum(setOfOppsId) ;                   
                            system.debug('Shareforwarded'+Shareforwarded);    
                            
                            RequiredShare = helper.getRequiredShare(setOfOppsId,objOpp.ChooseProgram__c,objOpp);
                            
                            double  ActualAmountReceived = objOpp.ActualAmountReceived__c + objOpp.E_S_charge__c - objOpp.RegistrationFee__c - objOpp.late_fee__c - objOpp.CareerServiceFee__c;
                            
                        
                         if(today.day() <= 10 ){
                            CurrentMonth =today.Month();
                            }else{
                            CurrentMonth = today.Month() + 1;
                            }
                        if(CurrentMonth >=13)
                        {
                            CurrentMonth = CurrentMonth - 12;
                            CurrentYear = today.Year()+1;
                        }
                        
                            
                        if( Shareforwarded > RequiredShare)                 
                        {  
                           System.debug('Shareforwarded '+Shareforwarded );
                            nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
                            DebitAmount = Shareforwarded - RequiredShare;
                            Narration='Adjustment Debit';
                              // For Insofee check with 2 AEP      
                           
                            if((objOpp.ChooseProgram__c =='Master Programs' && objOpp.Specialisation__c ==  'M.Sc. (AI & ML Ops)' )
                            || (objOpp.ChooseProgram__c =='Certificate Programs' && objOpp.Specialisation__c ==  'PC Term 2' )
                            || (objOpp.ChooseProgram__c =='Professional Programs' && objOpp.Specialisation__c ==  'PD Term 4' )
                            ||(objOpp.ChooseProgram__c =='Master Programs' && objOpp.Specialisation__c ==  'M.Sc. (AI)' )
                            )
                           {
                               double DebitAmount1;
                               double DebitAmount2;
                               double Shareforwarded1;
                               double Shareforwarded2;
                               double RequiredShareIC;
                               double RequiredShareInfo;
 
                            //  List<OpportunityLineItem> lstItem = [SELECT ActualSalePrice__c,FORMAT(convertCurrency(ActualSalePrice__c)) amount FROM OpportunityLineItem WHERE OpportunityId =:setOfOppsId
                            // AND (Product_Name__c LIKE 'Semester%' OR Product_Name__c LIKE 'Certificate Service Tax%' OR Product_Name__c LIKE 'GST%' OR Product_Name__c Like'Live%')];
                            // if(lstItem.size()>0)
                            // {
                            //     for (OpportunityLineItem record : lstItem) {
                            //         ActualSaleprice += (Decimal)record.get('ActualSalePrice__c');
                            //     }
                            // }

                            //     System.debug('ActualSaleprice ==>'+ActualSaleprice ); 
                            ActualSaleprice =(Decimal)[select Sum(ActualSalePrice__c)saleprice 
                                                        from OpportunityLineItem
                                                        where OpportunityId =:setOfOppsId
                                                        and (Product_Name__c Like'Semester%' OR Product_Name__c Like'Certificate Service Tax%' OR Product_Name__c Like'Live%' OR Product_Name__c Like'GST%'  )][0].get('saleprice');
                                    System.debug('ActualSaleprice---> '+ActualSaleprice);                                                     

                               if(objOpp.Down_Payment_Made__c &&  objOpp.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objOpp.WaivedOffAmount__c > objOpp.E_S_charge__c )
                                {
                                    RequiredShareIC = ActualAmountReceived *Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                                    RequiredShareInfo = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_MSC); 
                                    System.debug('RequiredShareIC---> '+RequiredShareIC);
                                    System.debug('RequiredShareInfo---> '+RequiredShareInfo);
                                }else if(objOpp.Down_Payment_Made__c &&  objOpp.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objOpp.WaivedOffAmount__c == objOpp.E_S_charge__c){
                                    RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                                    RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                                    System.debug('RequiredShareIC---> '+RequiredShareIC);
                                    System.debug('RequiredShareInfo---> '+RequiredShareInfo);
                                }
                                else{
                                    RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                                    RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                                    System.debug('RequiredShareIC---> '+RequiredShareIC);
                                    System.debug('RequiredShareInfo---> '+RequiredShareInfo);
                                }  

                               
                               Shareforwarded1 = helper.getCreditSum(setOfOppsId,objOpp.IC__c) - helper.getDebitSum(setOfOppsId,objOpp.IC__c) ; 
                               Shareforwarded2 = helper.getCreditSum(setOfOppsId,'Insofe') - helper.getDebitSum(setOfOppsId,'Insofe'); 
                               System.debug('Shareforwarded1---> '+Shareforwarded1);
                               System.debug('Shareforwarded2---> '+Shareforwarded2);
                               if( Shareforwarded1 > RequiredShareIC)                 
                               {
                                   DebitAmount1 = Shareforwarded - RequiredShareIC;            
                                   handler.createICTransactionDebitEntry(objOpp , CurrentYear, CurrentMonth,DebitAmount1,objOpp.IC__c,'Adjustment Debit');
                                   System.debug('DebitAmount1---> '+DebitAmount1);
                                }
                               if(Shareforwarded2 > RequiredShareInfo)
                               {
                                   DebitAmount2 = Shareforwarded2 - RequiredShareInfo;
                                    handler.createICTransactionDebitEntry(objOpp , CurrentYear, CurrentMonth,DebitAmount2,'Insofe','Adjustment Debit');
                                    System.debug('DebitAmount2---> '+DebitAmount2);
                                }

                           
                           }else{
                                handler.createICTransactionDebitEntry(objOpp , CurrentYear, CurrentMonth,DebitAmount,objOpp.IC__c,'Adjustment Debit');
                           }
                       
                        }
                     else if(RequiredShare > Shareforwarded )
                        {
                            System.debug('Shareforwarded '+Shareforwarded ); 
                            nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
                            CreditAmount =  RequiredShare - Shareforwarded;
                            Narration= 'Pending Commission';
                           // handler.createICTransactionCreditEntry(objOpp, CurrentYear, CurrentMonth,CreditAmount,objOpp.IC__c,Narration);
                     system.debug('objOpp.ChooseProgram__c--->'+objOpp.ChooseProgram__c);
                     system.debug('objOpp.Specialisation__c--->'+ objOpp.Specialisation__c);
                        if((objOpp.ChooseProgram__c =='Master Programs' && objOpp.Specialisation__c ==  'M.Sc. (AI & ML Ops)' )
                            || (objOpp.ChooseProgram__c =='Certificate Programs' && objOpp.Specialisation__c ==  'PC Term 2' )
                            || (objOpp.ChooseProgram__c =='Professional Programs' && objOpp.Specialisation__c ==  'PD Term 4' )
                            ||(objOpp.ChooseProgram__c =='Master Programs' && objOpp.Specialisation__c ==  'M.Sc. (AI)' )
                            )
                       {
                           double CreditAmount1;
                           double CreditAmount2;
                           double Shareforwarded1;
                           double Shareforwarded2;
                           double RequiredShareIC;
                           double RequiredShareInfo;
                           system.debug('enter in loop1 msc');
                           
                        
                            //  List<OpportunityLineItem> lstItem = [SELECT ActualSalePrice__c,FORMAT(convertCurrency(ActualSalePrice__c)) amount 
                            //                                          FROM OpportunityLineItem WHERE OpportunityId =:setOfOppsId
                            //                                         AND (Product_Name__c LIKE 'Semester%' OR Product_Name__c LIKE 'Certificate Service Tax%' 
                            //                                         OR Product_Name__c LIKE 'GST%' OR Product_Name__c Like'Live%')];
                            // if(lstItem.size()>0)
                            // {
                            //     for (OpportunityLineItem record : lstItem) {
                            //         ActualSaleprice += (Decimal)record.get('ActualSalePrice__c');
                            //     }
                            // }
                            ActualSaleprice =(Decimal)[select Sum(ActualSalePrice__c)saleprice 
                                                        from OpportunityLineItem
                                                        where OpportunityId =:setOfOppsId
                                                        and (Product_Name__c Like'Semester%' OR Product_Name__c Like'Certificate Service Tax%' OR Product_Name__c Like'Live%' OR Product_Name__c Like'GST%' )][0].get('saleprice');
                                    System.debug('ActualSaleprice---> '+ActualSaleprice);

                                System.debug('ActualSaleprice==>'+ActualSaleprice);
                          
                          if(objOpp.Down_Payment_Made__c &&  objOpp.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objOpp.WaivedOffAmount__c > objOpp.E_S_charge__c )
                            {
                                RequiredShareIC = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                                RequiredShareInfo = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_MSC); 
                                System.debug('RequiredShareIC---> '+RequiredShareIC);
                                System.debug('RequiredShareInfo---> '+RequiredShareInfo);
                            }else if(objOpp.Down_Payment_Made__c &&  objOpp.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objOpp.WaivedOffAmount__c == objOpp.E_S_charge__c){
                                RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                                RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                                System.debug('RequiredShareIC---> '+RequiredShareIC);
                                System.debug('RequiredShareInfo---> '+RequiredShareInfo);
                            }
                            else{
                                RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                                RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                                System.debug('RequiredShareIC---> '+RequiredShareIC);
                                System.debug('RequiredShareInfo---> '+RequiredShareInfo);
                            }   
                           
                           Shareforwarded1 = helper.getCreditSum(setOfOppsId,objOpp.IC__c) - helper.getDebitSum(setOfOppsId,objOpp.IC__c) ; 
                           Shareforwarded2 = helper.getCreditSum(setOfOppsId,'Insofe') - helper.getDebitSum(setOfOppsId,'Insofe') ; 
                           system.debug('ActualAmountReceived-->'+ActualAmountReceived);
                           system.debug('Shareforwarded1-->'+Shareforwarded1);
                           system.debug('Shareforwarded2-->'+Shareforwarded2);
                           if(RequiredShareIC > Shareforwarded1 )                 
                           {
                               CreditAmount1 = RequiredShareIC - Shareforwarded1;  
                               System.debug('CreditAmount1---> '+CreditAmount1);          
                               handler.createICTransactionCreditEntry(objOpp , CurrentYear, CurrentMonth,CreditAmount1,objOpp.IC__c,'Pending Commission');
                           }
                           if(RequiredShareInfo > Shareforwarded2 )
                           {
                               CreditAmount2 = RequiredShareInfo - Shareforwarded2;
                               System.debug('CreditAmount2---> '+CreditAmount2); 
                                handler.createICTransactionCreditEntry(objOpp , CurrentYear, CurrentMonth,CreditAmount2,'Insofe','Pending Commission');
                           }

                           }else{
                               system.debug('Default clause');
                               handler.createICTransactionCreditEntry(objOpp , CurrentYear, CurrentMonth,CreditAmount,objOpp.IC__c,'Pending Commission');        
                           }
                  
                        }                 
                    }                                                 
                } 
            }       
        }
   /*  Code transfer to producthelper
   public void CheckForAdjustmentDebit(Set<String> setOfOppsId,Opportunity ObjOpp)
    {                          
        Date today = Date.Today(); 
        Integer CurrentYear = today.Year();
        Integer CurrentMonth = 0;
       
        double DebitAmount;
        double Shareforwarded;
        double RequiredShare;
                                                                                         
         Shareforwarded = getCreditSum(setOfOppsId) - getDebitSum(setOfOppsId) ;                   
         system.debug('Shareforwarded'+Shareforwarded);                                    
         RequiredShare = getRequiredShare(setOfOppsId);
        
        if(today.day() <= 10 ){
                        CurrentMonth =today.Month();
                        }else{
                        CurrentMonth = today.Month() + 1;
                        }
        if(CurrentMonth >=13)
        {
            CurrentMonth = CurrentMonth - 12;
            CurrentYear = today.Year()+1;
        }
       
            
          if(Shareforwarded > RequiredShare)                 
            {  
                System.debug('Shareforwarded '+Shareforwarded );
                nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
                DebitAmount = Shareforwarded - RequiredShare;
                handler.createICTransactionDebitEntry(objOpp, CurrentYear, CurrentMonth,DebitAmount,objOpp.IC__c);

            }                                      
            
                
    }
    public void CheckForAdmissionComission(Set<String> setOfOppsId,Opportunity ObjOpp)
    {                          
        Date today = Date.Today(); 
        Integer CurrentYear = today.Year();
        Integer CurrentMonth = 0;
       
        double CreditAmount;
        double Shareforwarded;
        double RequiredShare;
                                                                                         
         Shareforwarded = getCreditSum(setOfOppsId) - getDebitSum(setOfOppsId) ;                   
         system.debug('Shareforwarded'+Shareforwarded);                                    
         RequiredShare = getRequiredShare(setOfOppsId);
        
        if(today.day() <= 10 ){
                        CurrentMonth =today.Month();
                        }else{
                        CurrentMonth = today.Month() + 1;
                        }
        if(CurrentMonth >=13)
        {
            CurrentMonth = CurrentMonth - 12;
            CurrentYear = today.Year()+1;
        }
        
            
          if(RequiredShare > Shareforwarded )
            {
                System.debug('Shareforwarded '+Shareforwarded ); 
                nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
                CreditAmount =  RequiredShare - Shareforwarded;
                handler.createICTransactionCreditEntry(objOpp, CurrentYear, CurrentMonth,CreditAmount,objOpp.IC__c);
            }                                                   
            
                
    }
   
     public double getCreditSum(Set<String> setOfOppsId)    
    {  
       double  CreditSum;
       
         CreditSum = (Decimal)[Select Sum(Amount__c)total 
                      FROM  IC_Payment_Transaction__c  
                      where Transaction_Type__c='Admission Commision - Credit'
                      and Opportunity__c =:setOfOppsId and NonAdmissionShare__c=false][0].get('total');      

       if(CreditSum>0)
        {
            system.debug('GET CreditSum AMOUNT-->'+CreditSum);
            return CreditSum;          
        }
        else 
        {
            return 0;
        }   
        
    }
    public double getDebitSum(Set<String> setOfOppsId)    
    {  
       double  DebitSum;
       
      DebitSum = (Decimal) [Select Sum(Amount__c)debitsum 
                            FROM  IC_Payment_Transaction__c 
                            where Transaction_Type__c='Adjustment - Debit' and Opportunity__c =:setOfOppsId 
                            and NonAdmissionShare__c =false and ( NOT Narration__c LIKE '%Book Courier Charges')][0].get('debitsum');     

     if(DebitSum>0)
        {
             system.debug('GET DebitSum AMOUNT-->'+DebitSum);
             return DebitSum;          
        }
        else 
        {
            return 0;
        }   
        
    }
    public double getRequiredShare(Set<String> setOfOppsId)    
    {  
       double  ActualSaleprice;
       double RequiredShare;
       
      ActualSaleprice =(Decimal)[select Sum(ActualSalePrice__c)saleprice 
                                    from OpportunityLineItem
                                    where OpportunityId =:setOfOppsId
                                    and Product_Name__c Like'Semester%'][0].get('saleprice');    

      if(ActualSaleprice>0)
        {
             RequiredShare = ActualSaleprice*0.35;
             return RequiredShare;          
        }
        else 
        {
            return 0;
        }   
        
    }*/
     public void historyTrackingOnNextFollow(List<Opportunity> lstOpportunity,Map<id,Opportunity> oldMap)
    {
        // if(checkRecursive.runbefore ==true)
        //  {
        //       checkRecursive.runbefore =false;
        //  }
        //  else
        //  {
        //       return;
        //  }
         
        if(lstOpportunity.size() > 0)
        {
            for(Opportunity newOpps : lstOpportunity)
            {
                Opportunity oldOpps = oldMap.get(newOpps.id);
                if((newOpps.Opportunity_Status__c !=null && newOpps.Opportunity_Status__c != oldOpps.Opportunity_Status__c)
                   ||
                  (newOpps.Opportunity_Description__c !=null && newOpps.Opportunity_Description__c != oldOpps.Opportunity_Description__c)
                  ||
                  (newOpps.Next_Follow_Up_Date_Time__c !=null && newOpps.Next_Follow_Up_Date_Time__c != oldOpps.Next_Follow_Up_Date_Time__c)
                  )
                {
                    if(newOpps.History_Tracking__c == null || newOpps.History_Tracking__c =='' || oldOpps.History_Tracking__c == null || oldOpps.History_Tracking__c == '')
                    {
                        // avoid null in description field 
                         newOpps.History_Tracking__c ='';
                    }
                    // List<User> usr = [SELECT Id, Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
                  //   String MyProflieName = usr[0].Name;
                    newOpps.History_Tracking__c +='\n';
                    if(newOpps.Next_Follow_Up_Date_Time__c !=null && newOpps.Next_Follow_Up_Date_Time__c != oldOpps.Next_Follow_Up_Date_Time__c)
                    {
                        newOpps.History_Tracking__c += '\n Next Follow Date - '+newOpps.Next_Follow_Up_Date_Time__c.format('yyyy-MM-dd hh:mm a')+'\n';
                    }
                    
                    if(newOpps.Opportunity_Description__c !=null && newOpps.Opportunity_Description__c != oldOpps.Opportunity_Description__c)
                    {
                        newOpps.History_Tracking__c += '\n Descripion - '+newOpps.Opportunity_Description__c+'\n';
                    }
                    if(newOpps.Opportunity_Status__c !=null && newOpps.Opportunity_Status__c != oldOpps.Opportunity_Status__c)
                    {
                         newOpps.History_Tracking__c += ' \n Status - '+newOpps.Opportunity_Status__c+'\n';
                    }
                    newOpps.History_Tracking__c +='Modified By - '+ UserInfo.getFirstName()+' '+UserInfo.getLastName()
                                                +'\n Modified Date/Time - '+System.now().format('yyyy-MM-dd hh:mm a');
                                                
                    if(newOpps.No_Of_Attempt__c ==null )
                    {
                        newOpps.No_Of_Attempt__c = 0;
                    }
                    
                    newOpps.No_Of_Attempt__c = Integer.valueOf(newOpps.No_Of_Attempt__c)+1;
                }
            }
        }
    }
       
    public void CreateICShareEntry(map<id,Opportunity> newMap ,map<id,Opportunity>OldMap)
    {
        for(String OppsId : newMap.keySet())
        {
            Opportunity objOpps = newMap.get(OppsId);
            System.debug('CreateICShareEntry --*****'+objOpps);
            if( objOpps.StageName =='Closed Won' && objOpps.processed__c ==false && OldMap.get(ObjOpps.id).StageName != objOpps.StageName)
            {
                nmICPaymentTriggerHandler objICPayment = new nmICPaymentTriggerHandler();
                objICPayment.AfterUpdate(newMap,oldMap);
            }
        } 
    }

    public void validateFeeTypeVsProgram(List<Opportunity> lstOpportunity,Map<Id,Opportunity> oldMap) {
        Set<String> oppIds = new set<String>();
        for(Opportunity opp: lstOpportunity) {
            if (opp.nm_Fee_Type__c != oldMap.get(opp.Id).nm_Fee_Type__c) {
                ProductHelper productHelper = new ProductHelper();
                Boolean programValide = opp.Ignore_Fee_Type_Validation__c ? true : productHelper.ValidateFeeType(opp.Total_Sem__c, opp.nm_Fee_Type__c, opp.LiveLecturesType__c, opp.IsTerm__c);
                if(!programValide) {
                    opp.addError('Fee Type not possible for program');
                }
                if (opp.Ignore_Fee_Type_Validation__c) {
                    oppIds.add(opp.Id);
                }
            }
        }
        if (oppIds.size() > 0 && System.isFuture() == false) {
            updateIgnoreFeeTypeValidationToFalse(oppIds);
        }
    }
   
    /**
    * @description 
     check for loan approved or cancel trigger and same update using liquiloans Status Update API
    * @author shubhranshu | 12/7/2019 
    * @param newMap 
    * @param OldMap 
    * @return void 
    **/
    public void callLoanStatusUpdate(map<id,Opportunity> newMap ,map<id,Opportunity>OldMap){
        
        if(checkRecursive.runBeforeOnce())
        {
            return;
        }

        for(String OppsId : newMap.keySet()){
            Opportunity objOpps = newMap.get(OppsId);
            System.debug('callLoanStatusUpdate --'+objOpps);
            if(objOpps.Loan_Type__c =='LiquiLoans') {
                if(objOpps.Loan_Approved__c && OldMap.get(ObjOpps.id).Loan_Approved__c != objOpps.Loan_Approved__c)
                {
                    liquiLoansStatusUpdate(objOpps.EduVanz_lead_id__c,'Y',objOpps.Id);  // used eduvanz field to avoid extra field creation for same functionality & Y is used for approved stage
                }else if(objOpps.Loan_Application_Cancelled__c  && OldMap.get(ObjOpps.id).Loan_Application_Cancelled__c != objOpps.Loan_Application_Cancelled__c 
                            &&  OldMap.get(ObjOpps.id).Loan_Order_Status__c != 'Rejected' && ObjOpps.Loan_Order_Status__c != 'Rejected'){
                    liquiLoansStatusUpdate(objOpps.EduVanz_lead_id__c,'N',objOpps.Id);  // used eduvanz field to avoid extra field creation for same functionality & N is used for recjected stage
                }
            } else if(objOpps.Loan_Type__c =='Propelld' && objOpps.Loan_Approved__c && OldMap.get(ObjOpps.id).Loan_Approved__c != objOpps.Loan_Approved__c) {
                propelldStatusUpdate(objOpps.EduVanz_lead_id__c,true,objOpps.Id);
            } else if(objOpps.Loan_Type__c =='GrayQuest' 
               && objOpps.Loan_Approved__c && OldMap.get(ObjOpps.id).Loan_Approved__c != objOpps.Loan_Approved__c) {                   
                GrayQuestStatusUpdate(objOpps.EduVanz_lead_id__c,objOpps.Id);
            } else if (objOpps.Loan_Type__c =='EzCred' ){
                if(objOpps.Loan_Approved__c && OldMap.get(ObjOpps.id).Loan_Approved__c != objOpps.Loan_Approved__c)
                {
                    EzcredLoanStatusUpdate(objOpps.Loan_Account_number__c,'APPROVED',objOpps.Id);  
                }else if(objOpps.Loan_Application_Cancelled__c && OldMap.get(ObjOpps.id).Loan_Application_Cancelled__c != objOpps.Loan_Application_Cancelled__c 
                            &&  OldMap.get(ObjOpps.id).Loan_Order_Status__c != 'REJECTED'){
                    EzcredLoanStatusUpdate(objOpps.Loan_Account_number__c,'REJECTED',objOpps.Id);
                }
            } else if(objOpps.Loan_Type__c == 'Zest' && objOpps.Loan_Approved__c && OldMap.get(ObjOpps.id).Loan_Approved__c != objOpps.Loan_Approved__c) {
                Boolean isSubventionScheme = String.isNotBlank(objOpps.Interest_Rate__c) && (objOpps.Interest_Rate__c == '0' || objOpps.Interest_Rate__c == '0.0') ? true : false;
                ZestLoanStatusUpdate(objOpps.Loan_Order_Id__c, objOpps.Id, isSubventionScheme);
            } else if (objOpps.Loan_Type__c == 'Avanse' && objOpps.Loan_Approved__c && OldMap.get(objOpps.id).Loan_Approved__c != objOpps.Loan_Approved__c) {
                avanseStatusUpdate(objOpps.EduVanz_lead_id__c,objOpps.Id);
            }
        } 
    }

   
 /*   public Map<String,String> getMapOfRepeatTermSessionandYear(List<Calender__c> lstActiveCalender){
        if(this.mapOfCalenderVsSessionYear.isEmpty()){
            //String querynmSerialNo = getQueryAllFieldSql('nmSerialNo__c',' nm_name__c !=null ',null);
          //  List<nmSerialNo__c> lstActiveCalender = DataBase.query(querynmSerialNo);
            if(this.lstActiveCalender.size() > 0){
                for(Calender__c objCalender : lstActiveCalender){
                    this.mapOfCalenderVsSessionYear.put(objCalender.Category__c+'_'+objCalender.nm_Type__c+'_'+objCalender.Specialisation__c,objCalender.Session__c+'_'+objCalender.Year__c);
                }
            }
        }
        return this.mapOfCalenderVsSessionYear;
    }*/
   /* public List<Calender__c> lstCalender(Boolean activeRecords){
        if(this.lstCalender.isEmpty()){
            String calenderQuery = getQueryAllFieldSql('Calender__c','Session_End_Date__c >=Today  and Category__c = \'Repeat Term\' ',null);
            this.lstCalender = DataBase.query(calenderQuery);
        }
        if(this.lstCalender.size() > 0 && activeRecords ) {
            if(this.lstActiveCalender.isEmpty()) {
                for(Calender__c objCal : lstCalender) {
                    if(objCal.Session_Start_Date__c <= System.today()) {
                        lstActiveCalender.add(objCal);
                    }
                }
            }
            return this.lstActiveCalender;
        }
        return this.lstCalender;
    }*/
  /*   public void RepeatTerm(List<Opportunity> lstOpportunity, map<id, Opportunity> mapOldOpportunity)
 {  
   if(IsAfterUpdateRunOnce){
            return;
        }
        
        IsAfterUpdateRunOnce = true;
        
        Integer CurrentSem;
        System.debug('<---RepeatTerm--->');
        set<id> accountid = new set<id> ();
        ProductHelper productHelper = new ProductHelper();
        Map<Id,String> mappofAccountidvsSemester = new Map<Id,String> ();
        list<Opportunity>  lstopportunityproductinsert  = new list<Opportunity> ();
        if(lstOpportunity != null && lstOpportunity.size() > 0)
        {
             System.debug('lstOpportunity.size>0');
             Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            for(Opportunity objOpp : lstOpportunity)
            {
                CurrentSem = Integer.valueof(objOpp.nm_Semester__c);
                System.debug('<-----objOpp----->'+objOpp);
                System.debug('<-----objOpp.Term_Cleared__c----->'+objOpp.Term_Cleared__c+'<-------mapOldOpportunity.get(objOpp.id).Term_Cleared__c--->'+mapOldOpportunity.get(objOpp.id).Term_Cleared__c);
              if(objOpp.Term_Cleared__c == 'No' 
                && mapOldOpportunity.get(objOpp.id).Term_Cleared__c != 'No' 
                && objOpp.Term_Cleared__c != null 
                && objOpp.Term_Cleared__c != '')
                {
                 
                    Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objOpp.Pricebook2Id );
                    system.debug('Insert Repeat Term product in future opportunity--->');
                    accountid.add(objOpp.AccountId);
                    mappofAccountidvsSemester.put(objOpp.AccountId,String.valueof(CurrentSem+1));
                    
                }               
            }
            if(!mappofAccountidvsSemester.IsEmpty())
            {
                lstopportunityproductinsert = Returnopportunity(accountid,mappofAccountidvsSemester);
                 if(lstopportunityproductinsert.size()>0)
                 {
                     //call queue to insertproduct 
                      System.enqueueJob(new callQueueToinsertProduct(lstopportunityproductinsert));
                 }
            }
        
        }
    
 } 
  public List<Opportunity> Returnopportunity(Set<id>accountid, Map<Id,String> mappofAccountidvsSemester)
 {
     List<Opportunity> lstopportunity = [select id,AccountID,nm_Semester__c ,Pricebook2Id ,Account.nm_Tagged_Pricebook__c  from Opportunity where AccountID=:accountid];
     list<Opportunity> lsttoinsertListopps = new list<Opportunity> ();
     if(lstopportunity.size()>0)
     {
         for(Opportunity objOpp : lstopportunity )
         {
             if(objOpp!=null && objOpp.nm_Semester__c.equalsIgnoreCase(mappofAccountidvsSemester.get(objOpp.AccountID)))
             {
                lsttoinsertListopps.add(objOpp); 
             }
         }
     }
     if(lsttoinsertListopps.size()>0)
     {
         return lsttoinsertListopps;
     }else
     {
         return null;
     }
 }   
 public class callQueueToinsertProduct implements Queueable {
    
    private List<Opportunity> opps;

    
    public callQueueToinsertProduct(List<Opportunity> records) {
        this.opps = records;
        
    }
    public void execute(QueueableContext context) {
        
        ProductHelper helper =new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = helper.getMapOfPriceBookIdProductVsPriceBookEntry();
        List<OpportunityLineItem> listLineitem = new List<OpportunityLineItem> ();

        for (opportunity objopps : opps) {
            
            Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objopps.Account.nm_Tagged_Pricebook__c); 
            system.debug('mapPricebook--->'+mapPricebook );
            OpportunityLineItem objopposItem = helper.CreateLineIteam('Repeat Term',mapPricebook,objopps.id);
            
            if(objopposItem!=null)
            {
                listLineitem.add(objopposItem);
            }
        }
        
        if(listLineitem.size()>0)
        {
            insert listLineitem ;
        }
        
    }
    
}*/
 /*Phalguni   
  public void RepeatTerm(List<Opportunity> lstOpportunity, map<id, Opportunity> mapOldOpportunity)
 {  
     if(IsAfterUpdateRunOnce){
            return;
        }        
        IsAfterUpdateRunOnce = true;

        ProductHelper productHelper = new ProductHelper();
        String SessionAndYear;
        string Session;
        String Year;
        Integer CurrentSem ;
        list<Opportunity>  lstopportunityproductinsert  = new list<Opportunity> ();
        
        if(lstOpportunity != null && lstOpportunity.size() > 0)
        {
             System.debug('lstOpportunity.size>0');
           //  Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
          //   List<Calender__c> lstActiveCalender = lstCalender(true);
         //   Map<String,String> mapOfCalenderVsSessionYear = getMapOfRepeatTermSessionandYear(lstActiveCalender);
            for(Opportunity objOpp : lstOpportunity)
            {
               CurrentSem = Integer.valueof(objOpp.nm_Semester__c);
                System.debug('<-----objOpp----->'+objOpp);
                System.debug('<-----objOpp.Term_Cleared__c----->'+objOpp.Term_Cleared__c+'<-------mapOldOpportunity.get(objOpp.id).Term_Cleared__c--->'+mapOldOpportunity.get(objOpp.id).Term_Cleared__c);
              if(objOpp.Term_Cleared__c == 'No' 
                && mapOldOpportunity.get(objOpp.id).Term_Cleared__c != 'No' 
                && objOpp.Term_Cleared__c != null 
                && objOpp.Term_Cleared__c != '')
                {
                  //  SessionAndYear = mapOfCalenderVsSessionYear.get('Repeat Term'+'_'+objOpp.ChooseProgram__c+'_'+objOpp.Specialisation__c);                  
                    //String[] responseParameters = SessionAndYear.split('\\_');
                    
                    SessionAndYear = OngoingSessionYear(objOpp.nm_Session__c ,objOpp.nm_Year__c );
                    if(String.isNotBlank(SessionAndYear)){
                        Session = SessionAndYear.substring(0, SessionAndYear.indexOf('_'));
                        Year = SessionAndYear.right(4);                 
                    }
                  Opportunity objopps =  insertopportunity(objOpp,Session,Year); 
                                          if(objopps != null){                
                        lstopportunityproductinsert.add(objopps);   
                      } 
              //  boolean validateregistered = Validity(objOpp.BatchStartD__c,objopps,objOpp);
                  

                }else if (objOpp.Term_Cleared__c == 'Yes' 
                && mapOldOpportunity.get(objOpp.id).Term_Cleared__c != 'Yes' 
                && objOpp.Term_Cleared__c != null 
                && objOpp.Term_Cleared__c != ''){
                
                  UpdatefutureOpportunityCloseWon(objOpp.AccountId,String.valueof(CurrentSem+1));
                }               
            }
            if(lstopportunityproductinsert.size()>0)
            {   
                try{
                    insert lstopportunityproductinsert;
                    MBAallTermfee.updatefutureSessionyear(lstopportunityproductinsert[0].AccountID,
                                         Integer.valueof(lstopportunityproductinsert[0].nm_Semester__c),
                                         lstopportunityproductinsert[0].nm_Session__c,
                                         Integer.valueof(lstopportunityproductinsert[0].nm_Year__c));
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
                
            }
          
        
        }
    
 }*/
 public void RepeatTerm(List<Opportunity> lstOpportunity, map<id, Opportunity> mapOldOpportunity)
 {  
     if(IsAfterUpdateRunOnce){
            return;
        }        
        IsAfterUpdateRunOnce = true;

        ProductHelper productHelper = new ProductHelper();
        String SessionAndYear;
        string Session;
        String Year;
        Integer CurrentSem ;
        
        list<Opportunity>  lstopportunityproductinsert  = new list<Opportunity> ();
        Set<String> deleteoppId = new Set<String>();
        List<OpportunityLineItem> listLineitem = new List<OpportunityLineItem> ();
        list<OpportunityLineItem> deletelst = new list<OpportunityLineItem> ();

        
        if(lstOpportunity != null && lstOpportunity.size() > 0)
        {
             System.debug('lstOpportunity.size>0');
             String PriceBookId ;
             Map<String,Map<String,PriceBookEntry>> mapPricebook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
            for(Opportunity objOpp : lstOpportunity)
            {
               CurrentSem = Integer.valueof(objOpp.nm_Semester__c);
                System.debug('<-----objOpp----->'+objOpp);
                System.debug('<-----objOpp.Term_Cleared__c----->'+objOpp.Term_Cleared__c+'<-------mapOldOpportunity.get(objOpp.id).Term_Cleared__c--->'+mapOldOpportunity.get(objOpp.id).Term_Cleared__c);
              if(objOpp.Term_Cleared__c == 'No' 
                && mapOldOpportunity.get(objOpp.id).Term_Cleared__c != 'No' 
                && objOpp.Term_Cleared__c != null 
                && objOpp.Term_Cleared__c != '')
                {
                    SessionAndYear = OngoingSessionYear(objOpp.nm_Session__c ,objOpp.nm_Year__c );
                    if(String.isNotBlank(SessionAndYear)){
                        Session = SessionAndYear.substring(0, SessionAndYear.indexOf('_'));
                        Year = SessionAndYear.right(4);                 
                    }
                         Opportunity objopps =  insertopportunity(objOpp,Session,Year); 
                        if(objopps != null){                
                        lstopportunityproductinsert.add(objopps);   
                      } 
                }else if (objOpp.Term_Cleared__c == 'Yes' 
                && mapOldOpportunity.get(objOpp.id).Term_Cleared__c != 'Yes' 
                && objOpp.Term_Cleared__c != null 
                && objOpp.Term_Cleared__c != ''){
                
                  UpdatefutureOpportunityCloseWon(objOpp.AccountId,String.valueof(CurrentSem+1));
                }

               if(objOpp.Career_Service__c != null && objOpp.Career_Service__c != '' 
              && objOpp.Career_Service__c != mapOldOpportunity.get(objOpp.id).Career_Service__c)
              {
                  //CareerServiceId.add(objOpp.Career_Service__c);
                   PriceBookId = String.valueOf(objOpp.Pricebook2Id).substring(0, 15);
                  Map<String,PriceBookEntry> mapPricebook1 = mapPricebook.get(PriceBookId);                 
                 OpportunityLineItem objopposItem = productHelper.CreateLineIteam(objOpp.Career_Service__c,mapPricebook1,objOpp.id);  
                  if(objopposItem!=null)
                  {
                      listLineitem.add(objopposItem);
                       deleteoppId.add(objOpp.Id);
                  }                
              }
              System.debug('old value--->'+mapOldOpportunity.get(objOpp.id).Career_Service__c );
              System.debug('objOpp.Career_Service__c--->'+objOpp.Career_Service__c);

              if(objOpp.Career_Service__c != mapOldOpportunity.get(objOpp.id).Career_Service__c && objOpp.Career_Service__c ==null && mapOldOpportunity.get(objOpp.id).Career_Service__c!=null)
              {
                  system.debug('Entery to delete');
                  deleteoppId.add(objOpp.Id);
              }
                
            }
            if(lstopportunityproductinsert.size()>0)
            {   
                try{
                    insert lstopportunityproductinsert;
                    MBAallTermfee.updatefutureSessionyear(lstopportunityproductinsert[0].AccountID,
                                         Integer.valueof(lstopportunityproductinsert[0].nm_Semester__c),
                                         lstopportunityproductinsert[0].nm_Session__c,
                                         Integer.valueof(lstopportunityproductinsert[0].nm_Year__c));
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
                
            }
          if(deleteoppId.size()>0)
          {
               deletelst = [select id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice from OpportunityLineItem where OpportunityId =:deleteoppId and Product_Name__c like 'Career%'];
              
              if(deletelst.size()>0)
              {
                  delete deletelst;
              }
              
          }
          if(listLineitem.size()>0)
          {
              insert listLineitem ;
          }
        
        }
    
 }
 

 
   public Opportunity insertopportunity(Opportunity objOpp,String session ,String year)
   {
      if(objOpp!=null)
        {
        Map<String,Integer> MonthStringvsInteger = new Map<String,Integer>();
        Integer SessionMonth ;
        Integer CurrentSessionMonth ;

         if( MonthStringvsInteger.IsEmpty() )
        {
            MonthStringvsInteger.put('January',01);
            MonthStringvsInteger.put('February',02);
            MonthStringvsInteger.put('March',03);
            MonthStringvsInteger.put('April',04);
            MonthStringvsInteger.put('May',05);
            MonthStringvsInteger.put('June',06);
            MonthStringvsInteger.put('July',07);
            MonthStringvsInteger.put('August',08);
            MonthStringvsInteger.put('September',09);
            MonthStringvsInteger.put('October',10);
            MonthStringvsInteger.put('November',11);
            MonthStringvsInteger.put('December',12);
        }
           SessionMonth = MonthStringvsInteger.get(objOpp.Expiry_Session__c);
           date validityExpiredDate = date.newinstance(Integer.valueof(objOpp.Expiry_Year__c),SessionMonth ,01) ;   
           CurrentSessionMonth = MonthStringvsInteger.get(session);
           date currentdate = date.newinstance(Integer.valueof(year),CurrentSessionMonth ,01)  ;

            system.debug('validityExpiredDate --->'+validityExpiredDate );
             system.debug('currentdate--->'+currentdate);

            
            if(!IsNullOrEmpty(session) && !IsNullOrEmpty(year) && validityExpiredDate >currentdate)
            {
                Opportunity nextSemOpportunity = new Opportunity();
                nextSemOpportunity.nm_Session__c = session;
                nextSemOpportunity.nm_Year__c = Integer.valueof(year);
                nextSemOpportunity.nm_Semester__c = objOpp.nm_Semester__c;
                nextSemOpportunity.Name = 'Repeatterm';
                nextSemOpportunity.StageName = 'Closed Won';
                nextSemOpportunity.CloseDate =System.today();
                nextSemOpportunity.nm_Fee_Type__c = 'MBAallTermfee-Considered';
                nextSemOpportunity.nm_StudentProgram__c=objOpp.nm_StudentProgram__c;
                nextSemOpportunity.nm_Program__c=objOpp.nm_Program__c;       
                nextSemOpportunity.Is_Re_Registration_Payment__c = true;
                 nextSemOpportunity.AccountId=objOpp.AccountId;
                nextSemOpportunity.nm_Future_Sems_Created__c = false;
                nextSemOpportunity.nm_Payment_Approved__c= true;
                nextSemOpportunity.TermRepeated__c =true;
                system.debug('nextSemOpportunity--->'+nextSemOpportunity );
                return nextSemOpportunity;
            }
            return null;
        }
        return null;
   }

    @future
    public static void UpdatefutureOpportunityCloseWon(Id accid,String sem ) {
        Map<String,Integer> MonthStringvsInteger = new Map<String,Integer>();
        Integer SessionMonth;
        Integer CurrentSessionMonth ;

        if( MonthStringvsInteger.IsEmpty() ) {
            MonthStringvsInteger.put('January',01);
            MonthStringvsInteger.put('February',02);
            MonthStringvsInteger.put('March',03);
            MonthStringvsInteger.put('April',04);
            MonthStringvsInteger.put('May',05);
            MonthStringvsInteger.put('June',06);
            MonthStringvsInteger.put('July',07);
            MonthStringvsInteger.put('August',08);
            MonthStringvsInteger.put('September',09);
            MonthStringvsInteger.put('October',10);
            MonthStringvsInteger.put('November',11);
            MonthStringvsInteger.put('December',12);
        }

        
        List<Opportunity> lstopps  = [SELECT id,nm_Semester__c,AccountId,StageName,BatchStartD__c,Sem__c,
                        nm_Year__c,nm_Session__c,Account.Validity_Month__c,Account.Validity_Year__c,Account.Program_Type__c 
                        FROM Opportunity WHERE AccountId=:accid AND ((nm_Semester__c=:sem AND StageName ='Closed Won - Re-registration Pending') 
                        OR nm_Semester__c='1') ORDER BY Sem__c DESC LIMIT 2];
        Opportunity updateOpp = lstopps.size() > 0 && lstopps[0].Sem__c > 1 ? lstopps[0] : null;                                                                                                                                                 
        if(updateOpp != null) {
            Boolean checkFullPayment = true; // to check if part payment made.
            if(updateOpp.Account.Program_Type__c == 'M.Sc. (AI & ML Ops)') {
                Id firstSemOppId = lstopps[1].id;
                List<nm_Payment__c> lstPayments = [SELECT id,nm_PaymentStatus__c FROM nm_Payment__c WHERE nm_OpportunityNew__c=:firstSemOppId AND nm_OpportunityNew__c!=null AND nm_PaymentStatus__c='Waived Off' AND nm_PaymentType__c='Additional Charge'];
                if(lstPayments.size() > 0 && Integer.valueOf(sem) > 4) {
                    checkFullPayment = false;
                }
            }
            SessionMonth = MonthStringvsInteger.get(updateOpp.Account.Validity_Month__c);
            Date validityExpiredDate = Date.newinstance(Integer.valueof(updateOpp.Account.Validity_Year__c),SessionMonth ,01) ;   
            CurrentSessionMonth = MonthStringvsInteger.get(updateOpp.nm_Session__c);
            Date currentdate = Date.newinstance(Integer.valueof(updateOpp.nm_Year__c),CurrentSessionMonth ,01)  ;
            if(validityExpiredDate > currentdate && checkFullPayment) {
                updateOpp.StageName = 'Closed Won';
                update lstopps;
            }
        }
    }

    public String OngoingSessionYear (string currentSession,Decimal currentYear) {
        String session;
        decimal year;
        if(currentsession=='January'){
            session =  'April';                     
            year = currentyear;
            system.debug('s1');                   
        }else if(currentsession == 'April'){
            session = 'July';                     
            year = currentyear;
            system.debug('s2');
        }else if(currentsession == 'July'){
            session = 'October';                     
            year = currentyear;
            system.debug('s3');
        }else if(currentsession == 'October'){
            session = 'January';
            year = currentyear+1;
            system.debug('s4');                  
            
        }else if(currentsession == 'September'){
            session = 'December';
            year = currentyear;                     
            system.debug('s4');             
        }else if(currentsession == 'June'){
            session = 'September';
            year = currentyear;
            system.debug('s4');                     
        }else if(currentsession == 'March'){
            session = 'June';
            year = currentyear;
            system.debug('s4');                     
        }else if(currentsession == 'December'){
            session = 'March';
            year = currentyear+1;
            system.debug('s4');                     
        }
        return session+'_'+year;
    }


    public void updateBBAElective(List<Opportunity> lstOpportunity, map<id, Opportunity> mapOfIdVsOldOpp, String activity) {
        Set<String> setOfOpp = new Set<String>();
        if (lstOpportunity.size() > 0) {
            for (Opportunity objOpp : lstOpportunity) {
                if(String.isNotBlank(objOpp.Elective_Subject_Type__c) && ((activity == 'UPDATE' && objOpp.Elective_Subject_Type__c != mapOfIdVsOldOpp.get(objOpp.Id).Elective_Subject_Type__c)|| activity =='INSERT' ) ) {
                    setOfOpp.add(objOpp.Id);
                }
            }
        }
        if (setOfOpp.size() > 0) {
            updateElectiveInStudentPortal(setOfOpp);
        }
    }

    public void updateBBAElectiveForSem6(List<Opportunity> lstOpportunity, map<id, Opportunity> mapOfIdVsOldOpp) {
        Map<String, String> mapOfAccIDVsOppId = new Map<String, String>();
        List<Opportunity> lstOppToUpdate= new List<Opportunity>();
        if (lstOpportunity.size() > 0) {
            for (Opportunity objOpp : lstOpportunity) {
            if (String.isBlank(objOpp.Elective_Subject_Type__c) && objOpp.StageName == 'Closed Won' && objOpp.nm_Semester__c == '6' && objOpp.Program_Name__c == 'BBA' ) {
                mapOfAccIDVsOppId.put(objOpp.AccountId, objOpp.Id);
            }
        }

        if(!mapOfAccIDVsOppId.isEmpty()) {
            for (Opportunity opp : [SELECT Id,AccountId, Elective_Subject_Type__c FROM Opportunity WHERE AccountId = :mapOfAccIDVsOppId.keySet() AND nm_Semester__c = '5' AND Elective_Subject_Type__c != Null ]) {
                Map<String, String> mapOfElectiveVsSubject = getMapOfElectiveVsSubject();
                if (mapOfElectiveVsSubject.containsKey(opp.Elective_Subject_Type__c)) {
                    lstOppToUpdate.add(new Opportunity(Id= mapOfAccIDVsOppId.get(opp.AccountId), Elective_Subject_Name__c = mapOfElectiveVsSubject.get(opp.Elective_Subject_Type__c) ));
                }
            }
        }
        
        if(lstOppToUpdate.size()>0)
            {
                update lstOppToUpdate;
            }
        }
    }

    public Map<String, String> getMapOfElectiveVsSubject() {
        Set<String> cousreId = new Set<String>();
        Map<String, Set<String>> mapOfElectiveVsSetSubject = new Map<String, Set<String>>(); 
        Map<String, String> mapOFElectiveVsSubject = new Map<String, String>();
        for(nm_Courses__c objCourse : [SELECT Id, Student_Zone_Course_Id__c, Name, Elective__c FROM nm_Courses__c WHERE Elective__c != null AND Sem__c= '6']) {
            Set<String> setOfSub = mapOfElectiveVsSetSubject.containsKey(objCourse.Elective__c) ? mapOfElectiveVsSetSubject.get(objCourse.Elective__c) : new Set<String>();
            setOfSub.add(objCourse.Name);
            mapOfElectiveVsSetSubject.put(objCourse.Elective__c, setOfSub);
        }
        for (String elective: mapOfElectiveVsSetSubject.keySet()) {
            mapOFElectiveVsSubject.put(elective,  String.join(new List<String>(mapOfElectiveVsSetSubject.get(elective)) , ';'));
        }
        return mapOFElectiveVsSubject;
    }

    @future (callout = true)
    public Static void updateElectiveInStudentPortal(Set<String> setOfOpp) {
        Map<String,String> mapOfNameVsType = new Map<String, String>();
        for (nm_Courses__c objCou : [SELECT Id, Elective__c, Name FROM nm_Courses__c WHERE Elective__c != null]) {
            if(String.isNotBlank(objCou.Elective__c)) {
                mapOfNameVsType.put(objCou.Name, objCou.Elective__c);
            }
        }
        List<API_Request__c> lstAPIRequests = new List<API_Request__c>();
        if(setOfOpp.size() > 0) {
            for (Opportunity objOpp : [SELECT Id, Session_for_Student_Zone__c,nm_Semester__c, Account.nm_StudentNo__c, nm_Year__c, Elective_Subject_Name__c FROM Opportunity WHERE Id IN :setOfOpp ]) {
                if (String.isNotBlank(objOpp.Elective_Subject_Name__c)) {
                    API_Request__c apiReq = new API_Request__c();
                    apiReq.Opportunity__c = objOpp.Id;
                    apiReq.Type_of_Request__c = 'Elective Sync';
                    apiReq.API_Name__c = 'BBA Elective Sync';
                    String elective = objOpp.Elective_Subject_Name__c.split(';')[0];
                    Map<String, String> result = new Map<String, String>();
                    result.put('sapId', objOpp.Account.nm_StudentNo__c);
                    result.put('electiveSubjectType', mapOfNameVsType.get(elective));
                    result.put('sem', objOpp.nm_Semester__c);
                    result.put('regMonth', objOpp.Session_for_Student_Zone__c);
                    result.put('regYear', String.valueOf(objOpp.nm_Year__c));
                    String jsonMap =  System.JSON.serialize(result);
                    HttpRequest req = new HttpRequest();
                    HttpResponse resp = new HttpResponse();
                    Http http = new Http();
                    req.setEndpoint(System.Label.DOCUMENT_SERVER+'updateElectiveSubjectsFromSFDC');
                    req.setMethod('POST');
                    req.setHeader('content-type', 'application/json');
                    System.debug('jsonstring ==>');
                    System.debug(jsonMap);
                    req.setBody(jsonMap);
                    apiReq.Request__c = jsonMap;
                    try {
                        resp = http.send(req);
                        apiReq.Response__c = resp.getBody();
                        Integer statusCode = resp.getStatusCode();
                        if(statusCode == 200) {
                            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                            String message = responseBody.containsKey('success') ? (String)responseBody.get('success') : '';
                            if (message == 'true') {
                                apiReq.Success__c = true;
                            } else {
                                apiReq.Success__c = false;
                            }
                            lstAPIRequests.add(apiReq);
                        }
                        System.debug('statusCode = '+statusCode);
                        System.debug('resp.getBody() = '+resp.getBody());
                    }catch (Exception e) {
                        apiReq.Response__c = resp.getBody() + ' \n ' + e.getMessage();
                        apiReq.Success__c = false;
                        lstAPIRequests.add(apiReq);
                        System.debug(e);
                    }
                }
            }
        }
        if(lstAPIRequests.size() > 0) {
            insert lstAPIRequests;
        }
    }
    
    @future (callout=true)
    public static void updateProgramStatusForStudentOnStudentPortal(String sapid, String accountId, String status)
    {
        // status = String.isNotBlank(status) && status.equalsIgnoreCase('Rusticated') ? 'Rusticated' : 'Program Terminated';
        status = 'Program Terminated';
        sapid = String.isNotBlank(sapid) ? sapid.substringAfter('_') : sapid;
        System.debug('updateProgramStatusForStudentOnStudentPortal Called with sapid --->'+sapid);
        Map<String,String> mapOfRequest = new Map<String,String>();
        mapOfRequest.put('sapid',sapid);
        mapOfRequest.put('programStatus',status);
        string jsonstring = JSON.serialize(mapOfRequest);
        
        API_Request__c apiReq = new API_Request__c();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(System.Label.Student_Portal+'m/updateStudentPortalProgramStatus');
        req.setHeader('content-type', 'application/json');
        req.setBody(jsonstring);
        req.setMethod('POST');

        apiReq.Request__c = req.getBody();
        apiReq.Account__c = accountId;
        apiReq.Type_of_Request__c= 'PortalAPI';
        apiReq.API_Name__c='updateStudentStatus';

        try {
            res = http.send(req);
            apiReq.Response__c = res.getBody();
            if(res.getStatusCode() == 200){
                apiReq.Success__c = true;
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            apiReq.Response__c = res.getBody();
        }
        apiRequestsInsertion(apiReq);
    }
    
    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

     public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }

    public void sendPaymentInvoiceAsAttachmentToCapitalFloat(List<Opportunity> lstOpportunity,Map<Id,Opportunity> oldMap){
        if(oldMap !=null){
           for(Opportunity objOpps : lstOpportunity){
               if(objOpps.Loan_Type__c !=null){
                   if(objOpps.Loan_Type__c.contains('Capital Float')){
                       if((objOpps.Loan_Approved__c && oldMap.get(objOpps.id).Loan_Approved__c != objOpps.Loan_Approved__c)
                           ||
                           (objOpps.Loan_Sanctioned__c && oldMap.get(objOpps.id).Loan_Sanctioned__c != objOpps.Loan_Sanctioned__c)
                         ){
                           if(objOpps.Loan_Sanctioned__c && objOpps.Loan_Approved__c){
                               sendEmailWithAttachments(objOpps.id,objOpps.AccountId);
                           }
                       }
                   }
               }
           } 
        }
    }

    /**
    * @description 
    * @author @BK | 10-01-2023 
    * @param lstOpportunity 
    * @param oldMap 
    **/
    public void captureLoanStatusChangeDates(List<Opportunity> lstOpportunity, Map<Id,Opportunity> oldMap) {
        for (Opportunity objOpps : lstOpportunity) {
            if(objOpps.Loan_Order_Id__c!=oldMap.get(objOpps.id).Loan_Order_Id__c && String.isNotBlank(objOpps.Loan_Order_Id__c)) {
                objOpps.Loan_applied_date__c = System.now();
            } 
            if(objOpps.Loan_Approved__c!=oldMap.get(objOpps.id).Loan_Approved__c && objOpps.Loan_Approved__c) {
                objOpps.Loan_approval_date__c = System.now();
            } 
            if(objOpps.Loan_Sanctioned__c!=oldMap.get(objOpps.id).Loan_Sanctioned__c && objOpps.Loan_Sanctioned__c) {
                objOpps.Loan_disbursed_date__c = System.now();
            } 
            if(objOpps.Loan_Application_Cancelled__c!=oldMap.get(objOpps.id).Loan_Application_Cancelled__c && objOpps.Loan_Application_Cancelled__c) {
                objOpps.Loan_Rejection_Date__c = System.now();
            }
        }
    }
    // @future
    // public static void CareerServiceProduct(id opportunityId, id AccountId) {
    //     List < OpportunityLineItem > lstOpportunityLinIteam = new List < OpportunityLineItem > ();
    //     List < OpportunityLineItem > lstOpportunityLintoDelete = new List < OpportunityLineItem > ();
    //     Decimal CareerServiceCharge;
    //     Opportunity objOpp = [select id, Career_Service__c, Total_Amount_Received__c, StageName, nm_TotalApprovedPayment__c,nm_StudentEmail__c from Opportunity where id = : opportunityId];
    //     if (objOpp != null) {
    //         if (objOpp.Career_Service__c != null) {
    //             system.debug('objOpp.Career_Service__c--->' + objOpp.Career_Service__c);
    //             lstOpportunityLinIteam = [select id, OpportunityId, Product_Name__c, PriceBookEntryId, UnitPrice from OpportunityLineItem where OpportunityId = : opportunityId];
    //             if (lstOpportunityLinIteam.size() > 0) {
    //                 for (OpportunityLineItem obj: lstOpportunityLinIteam) {
    //                     if (objOpp.Career_Service__c.equalsIgnorecase(obj.Product_Name__c)) {
    //                         CareerServiceCharge = obj.UnitPrice;
    //                         lstOpportunityLintoDelete.add(obj);
    //                         break;
    //                     } else {
    //                         continue;
    //                     }
    //                 }
    //             }
    //             if (lstOpportunityLintoDelete.size() > 0) {
    //                 Career_Service_Package__c obcsp = [select id, Name, Package_Name__c from Career_Service_Package__c where Package_Name__c = : objOpp.Career_Service__c and Group_Name__c = 'Normal' limit 1];

    //                 if (obcsp != null) {
    //                     System.debug('obcsp -->' + obcsp);
    //                     Career_Service_Program__c obcspp = new Career_Service_Program__c();
    //                     obcspp.Account__c = AccountId;
    //                     obcspp.Opportunity__c = opportunityId;
    //                     obcspp.CareerServiceProgram__c = obcsp.id;
    //                     obcspp.Stage__c = 'Payment Done';
    //                     obcspp.Student_E_mail_Address__c = objOpp.nm_StudentEmail__c;
    //                     insert obcspp;

    //                     if (obcspp != null) {

    //                         nm_Payment__c objpayment = [select id, nm_OpportunityNew__c from nm_Payment__c where nm_OpportunityNew__c = : opportunityId and nm_PaymentType__c = 'Career Service' and nm_PaymentStatus__c ='Payment Approved' limit 1];
    //                         if (objpayment != null) {
    //                             objpayment.nm_OpportunityNew__c = null;
    //                             objpayment.CareerServiceProgram__c = obcspp.id;
    //                             update objpayment;

    //                             objOpp.Career_Service__c = '';
    //                             objOpp.Total_Amount_Received__c = objOpp.Total_Amount_Received__c - CareerServiceCharge;
    //                             objOpp.nm_TotalApprovedPayment__c = objOpp.nm_TotalApprovedPayment__c - CareerServiceCharge;
    //                             update objOpp;

    //                             delete lstOpportunityLintoDelete;

    //                         }

    //                     }

    //                 }

    //             }
    //         }
    //     }

    // }

    public class CreateCareerServiceProduct implements Queueable {

       
        public Set<Id> opportunityId;
        public Set<String> CareerServiceProduct;
                      
        public CreateCareerServiceProduct(Set<Id> opportunityId,Set<String> CareerServiceProduct) {
          
            this.opportunityId = opportunityId;
            this.CareerServiceProduct = CareerServiceProduct;
        }
        
        public void execute(QueueableContext queCont) {
            List <Opportunity> lstOpportunitytoupdate = new List <Opportunity> ();
            List <Opportunity> lstopportunity = new List <Opportunity> ();
            List <OpportunityLineItem> lstOpportunityLintoDelete = new List < OpportunityLineItem > ();
            List <Career_Service_Package__c> listCareerService = new List <Career_Service_Package__c>();
            Map<Id, Decimal> mapOfOppsIdVsCareerServiceUnitPrice = new  Map<Id, Decimal>();
            Map<String,Id> mapOfCareerServiceNameVsCareerServiceId = new  Map<String,Id>();
            List<Career_Service_Program__c> listCSP = new List<Career_Service_Program__c>();
            List<nm_Payment__c> listOfCareerServicePayment = new List<nm_Payment__c> ();
            List<nm_Payment__c> listOfCareerServicePaymentUpdate = new List<nm_Payment__c> ();
                                                
            Decimal CareerServiceCharge;
          lstopportunity = [select id, Career_Service__c,CareerServiceProgram__c,AccountId, Total_Amount_Received__c, StageName, nm_TotalApprovedPayment__c,nm_StudentEmail__c from Opportunity where id = : opportunityId];
                                                
            if(lstopportunity.size()>0)
            {
                lstOpportunityLintoDelete = [select id,PricebookEntry.Product2Id,OpportunityId ,
                                                                            ActualSalePrice__c,Product_Name__c,PriceBookEntryId ,
                                                                            UnitPrice,ListPrice,Quantity,TotalPrice,
                                                                            ProgramName2__c,PricebookEntry.Name
                                                                            from OpportunityLineItem where OpportunityId !=null 
                                                                            and Product_Name__c =:CareerServiceProduct
                                                                            and OpportunityId In : opportunityId];
                if (lstOpportunityLintoDelete.size() > 0) {
                    for (OpportunityLineItem obj: lstOpportunityLintoDelete) {
                        mapOfOppsIdVsCareerServiceUnitPrice.put(obj.OpportunityId,obj.UnitPrice);
                    }
                }
    
                if(!mapOfOppsIdVsCareerServiceUnitPrice.isEmpty())
                {
                    listCareerService = [select id, Name, Package_Name__c from Career_Service_Package__c where Package_Name__c = : CareerServiceProduct and Group_Name__c = 'Normal'];
                    if(listCareerService.size()>0)
                    {
                        for(Career_Service_Package__c objcsp:listCareerService)
                        {
                            mapOfCareerServiceNameVsCareerServiceId.put(objcsp.Package_Name__c,objcsp.id);
                        }
                    }
                                                                                                    
                    Map<Id,Career_Service_Program__c> mapOfOppIdVsCSP = new Map<Id,Career_Service_Program__c>();
                    for(Opportunity objopp:lstopportunity)
                    {
                                
                        Career_Service_Program__c obcspp = new Career_Service_Program__c();
                        obcspp.Account__c = objopp.AccountId;
                        obcspp.Opportunity__c = objopp.Id;
                        obcspp.CareerServiceProgram__c =objopp.CareerServiceProgram__c!=null?objopp.CareerServiceProgram__c : mapOfCareerServiceNameVsCareerServiceId.get(objOpp.Career_Service__c);
                        obcspp.Stage__c = 'Register';
                        obcspp.Student_E_mail_Address__c = objOpp.nm_StudentEmail__c;
                        objOpp.Total_Amount_Received__c = objOpp.Total_Amount_Received__c - mapOfOppsIdVsCareerServiceUnitPrice.get(objopp.id);
                        objOpp.nm_TotalApprovedPayment__c = objOpp.nm_TotalApprovedPayment__c - mapOfOppsIdVsCareerServiceUnitPrice.get(objopp.id);
                        lstOpportunitytoupdate.add(objOpp);
                      listCSP.add(obcspp);
                    //  mapOfOppIdVsCSP.put(objopp.Id,obcspp);
                    }
                                                                                                    
                    if(listCSP.size()>0)
                    {
                        insert listCSP;
                        for (Career_Service_Program__c objCSP : listCSP) {
                            mapOfOppIdVsCSP.put(objCSP.Opportunity__c,objCSP);
                            System.debug('objCSP.Opportunity__c ==>'+objCSP.Opportunity__c);
                        }
                    }
                        system.debug('mapOfOppIdVsCSP-->'+mapOfOppIdVsCSP);
                        system.debug('mapOfOppIdVsCSP-->'+mapOfOppIdVsCSP.keySet());
                        system.debug('opportunityId--->'+opportunityId);
                        system.debug('listCSP--->'+listCSP);
                       /* System.debug('Insert in');
                        Database.SaveResult[] CareerServiceList = Database.insert(listCSP,false);
                        system.debug('CareerServiceList size '+CareerServiceList.size());
                        system.debug('CareerServiceList '+CareerServiceList );
                          
                         
                        for (Database.SaveResult csp : CareerServiceList) 
                        {
                           system.debug('csp.isSuccess()'+csp.isSuccess());
                                if (csp.isSuccess()) 
                                {
                                    mapOfOppIdVsCSP.put(csp.Opportunity__c,csp.getId());
                                }
                              else                                  
                                {
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : csp.getErrors()) 
                                    {                                                                          
                                        System.debug('The following error has occurred.');                    
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                        System.debug('Fields that affected this error: ' + err.getFields());
                                    }
                                } 
                          
                          } */

                      //  mapOfOppIdVsCSP.put(objopp.Id,obcspp);
                      if(!mapOfOppIdVsCSP.IsEmpty()){
                          system.debug('mapOfOppIdVsCSP--->'+mapOfOppIdVsCSP);
                            listOfCareerServicePayment = [select id, nm_OpportunityNew__c from nm_Payment__c
                                                            where nm_OpportunityNew__c = : opportunityId and nm_PaymentType__c = 'Career Service' 
                                                            and nm_PaymentStatus__c ='Payment Approved' ];
                            system.debug('listOfCareerServicePayment--->'+listOfCareerServicePayment);

                            if(listOfCareerServicePayment.size()>0)
                            {
                                for(nm_Payment__c objpayment : listOfCareerServicePayment)
                                {
                                    Career_Service_Program__c ObjCsp;
                                    system.debug('objpayment.nm_OpportunityNew__c--->'+objpayment.nm_OpportunityNew__c);
                                   
                                    if(mapOfOppIdVsCSP.containsKey(objpayment.nm_OpportunityNew__c)) {
                                        ObjCsp = mapOfOppIdVsCSP.get(objpayment.nm_OpportunityNew__c);
                                        System.debug('ObjCsp ==>' +ObjCsp);
                                    }
                                    objpayment.CareerServiceProgram__c = mapOfOppIdVsCSP.get(objpayment.nm_OpportunityNew__c).id;
                                     objpayment.nm_OpportunityNew__c = null;
                                    listOfCareerServicePaymentUpdate.add(objpayment);
                                }
                                if(listOfCareerServicePaymentUpdate.size()>0)
                                {
                                    update listOfCareerServicePaymentUpdate;                
                                    update lstOpportunitytoupdate;
                                    if(lstOpportunityLintoDelete.size()>0)
                                    {
                                        delete lstOpportunityLintoDelete;
                                    }
                                }
                            }
                        }
                    
                }
            }
        }
    }

  /* code transfer
   public static void CareerServiceProduct(id opportunityId, id AccountId) {
        List < OpportunityLineItem > lstOpportunityLinIteam = new List < OpportunityLineItem > ();
        List < OpportunityLineItem > lstOpportunityLintoDelete = new List < OpportunityLineItem > ();
        Decimal CareerServiceCharge;
        Opportunity objOpp = [SELECT id,Career_Service__c,Total_Amount_Received__c,StageName,nm_TotalApprovedPayment__c,nm_Semester__c FROM Opportunity WHERE id=:opportunityId];
        if (objOpp != null) {
            if (objOpp.Career_Service__c != null) {
                system.debug('objOpp.Career_Service__c--->' + objOpp.Career_Service__c);
                lstOpportunityLinIteam = [SELECT id,OpportunityId,Product_Name__c,PriceBookEntryId,UnitPrice FROM OpportunityLineItem WHERE OpportunityId=:opportunityId];
                if (lstOpportunityLinIteam.size() > 0) {
                    for (OpportunityLineItem obj: lstOpportunityLinIteam) {
                        if (objOpp.Career_Service__c.equalsIgnorecase(obj.Product_Name__c)) {
                            CareerServiceCharge = obj.UnitPrice;
                            lstOpportunityLintoDelete.add(obj);
                            break;
                        } else {
                            continue;
                        }
                    }
                }
                if (lstOpportunityLintoDelete.size() > 0) {
                    String semester = objOpp.nm_Semester__c;
                    Career_Service_Package__c obcsp = [SELECT id,Name,Package_Name__c FROM Career_Service_Package__c WHERE isActive__c=true AND Package_Name__c=:objOpp.Career_Service__c AND nm_Semester__c INCLUDES(:semester) LIMIT 1];
                    if (obcsp != null) {
                        System.debug('obcsp -->' + obcsp);
                        Career_Service_Program__c obcspp = new Career_Service_Program__c();
                        obcspp.Account__c = AccountId;
                        obcspp.Opportunity__c = opportunityId;
                        obcspp.CareerServiceProgram__c = obcsp.id;
                        obcspp.Stage__c = 'Payment Done';
                        insert obcspp;

                        if (obcspp != null) {
                            nm_Payment__c objpayment = [SELECT id,nm_OpportunityNew__c FROM nm_Payment__c WHERE nm_OpportunityNew__c=:opportunityId AND nm_PaymentType__c='Career Service' AND nm_PaymentStatus__c ='Payment Approved' LIMIT 1];
                            if (objpayment != null) {
                                objpayment.nm_OpportunityNew__c = null;
                                objpayment.CareerServiceProgram__c = obcspp.id;
                                update objpayment;

                                objOpp.Career_Service__c = '';
                                objOpp.Total_Amount_Received__c = objOpp.Total_Amount_Received__c - CareerServiceCharge;
                                objOpp.nm_TotalApprovedPayment__c = objOpp.nm_TotalApprovedPayment__c - CareerServiceCharge;
                                update objOpp;

                                delete lstOpportunityLintoDelete;
                            }
                        }
                    }
                }
            }
        }
    }*/
    
    /**
    * @description 
    future callout for liquiloans status update API
    * @author shubhranshu | 12/7/2019 
    * @param LoanId 
    * @param LoanStatus 
    * @return void 
    **/
    @future (callout=true)
    public static void liquiLoansStatusUpdate(String LoanId,String LoanStatus,String OppId){
        liquiLoansStatusUpdateAPI.statusUpdateForLoan(LoanId,LoanStatus,OppId,'Opportunity'); 
    }

    /**
    * @description 
    * @author @BK | 01-31-2022 
    * @param quoteId 
    * @param loanStatus 
    * @param oppId 
    **/
    @future(callout=true)
    public static void propelldStatusUpdate(String quoteId, Boolean loanStatus, String oppId){
        PropelldWebService objPropelldWebService = new PropelldWebService();
        objPropelldWebService.updateStatusByQuoteId(quoteId,loanStatus,oppId,'Opportunity'); 
    }

    @future(callout=true)
    public static void avanseStatusUpdate(String quoteId, String oppId){
        AvanseWebService objAvanseWebService = new AvanseWebService();
        objAvanseWebService.updateAvanseLoanStatus(quoteId,'Opportunity',oppId); 
    }

    /**
    * @description 
    * @author shubhranshu | 01-31-2022 
    * @param LoanId 
    * @param oppId 
    **/
    @future (callout=true)
    public static void GrayQuestStatusUpdate(String LoanId,String oppId){       
        GrayQuestWebService.approvedLoan(LoanId,oppId,'Opportunity'); 
    }
    
    /**
    * @description 
    * @author shubhranshu | 01-31-2022 
    * @param LoanAccountId 
    * @param Type 
    * @param OppId 
    **/
    @future (callout=true)
    public static void EzcredLoanStatusUpdate(String LoanAccountId,String Type,String OppId){
        if(Type == 'REJECTED'){
            EzcredWebService.cancelLoan(LoanAccountId,OppId,'Opportunity'); 
        }else if(Type == 'APPROVED'){
            EzcredWebService.approvedLoan(LoanAccountId,OppId,'Opportunity'); 
        }
        
    }

    /**
    * @description 
    * @author @BK | 01-31-2022 
    * @param LoanAccountId 
    * @param OppId 
    * @param isSubventionScheme 
    **/
    @future (callout=true)
    public static void ZestLoanStatusUpdate(String LoanAccountId,String OppId,Boolean isSubventionScheme) {
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.getOrderDeliveryReportByOrderId(LoanAccountId,'Delivered',isSubventionScheme,OppId,'Opportunity');
    }
    
    @future(callout=true)
    public static void sendEmailWithAttachments(String opportunityId ,String AccountId){
        String paymentId = '';
        List<nm_Payment__c> lstDownPaymentMade = [select id from nm_Payment__c where (nm_PaymentStatus__c ='Payment Made' or nm_PaymentStatus__c ='Payment Approved') and nm_OpportunityNew__c=:opportunityId and nm_PaymentType__c like '%DownPayment%'];
        if(lstDownPaymentMade.size() > 0){
            paymentId = lstDownPaymentMade[0].id;
        }
        
        if(paymentId !='' && paymentId !=null){
            PageReference pdf = Page.Payment_Invoice;
            pdf.getParameters().put('paymentId',paymentId);
            System.debug('Save--->');
            Attachment attachment = new Attachment();
            Blob body;
            
            try{
            
                if (Test.IsRunningTest()) {
                    body  = Blob.valueOf('My awesome pdf, but txt');
                } else {
                    body = pdf.getContentAsPDF();
                }
                // returns the output of the page as a PDF
                body = pdf.getContentAsPDF();
        
                attachment.Body = body;
                // add the user entered name
                attachment.Name = 'Invoice.pdf';
                attachment.IsPrivate = false;
                // attach the pdf to the Lead
                attachment.ParentId = opportunityId;
                
               // pdf will be save only if State available 
                insert attachment ;
                  
             }catch(Exception e){
                System.debug('Error Occurs while Saving Attachment -->'+e.getMessage());
            }
            
            // attachment
             List<String> setOfEmailReceiver = new List<String>();
             String studentNo = '';
             List<String> setOfCCEmailIds = new List<String>();
             
             List<NM_Payment_Form_Configuration__c> lstFormConfiguration = [select id,Capital_Float_Invoice_Receiver_EmailId_s__c from NM_Payment_Form_Configuration__c where Capital_Float_Invoice_Receiver_EmailId_s__c !=null];
             if(lstFormConfiguration.size()>0){
                NM_Payment_Form_Configuration__c objFormConfiguration = lstFormConfiguration[0]; 
                setOfEmailReceiver = new List<String>(objFormConfiguration.Capital_Float_Invoice_Receiver_EmailId_s__c.split(','));
             }
             
             List<Account> lstAccount = [select id,nm_StudentNo__c ,ICemailaddress__c,LC_email_id__c,nm_RegistrationNumber__c from Account where id=:AccountId];
             if(lstAccount.size() > 0){
                 studentNo = lstAccount[0].nm_StudentNo__c != null ? lstAccount[0].nm_StudentNo__c: lstAccount[0].nm_RegistrationNumber__c;
                 if(lstAccount[0].ICemailaddress__c !=null){
                      setOfCCEmailIds.add(lstAccount[0].ICemailaddress__c);   
                 }if(lstAccount[0].LC_email_id__c !=null){
                     setOfCCEmailIds.add(lstAccount[0].LC_email_id__c ); 
                 }
             }
             
             setOfCCEmailIds.add('nelson.soans@nmims.edu');
             
             Messaging.Emailfileattachment emailfile = new Messaging.Emailfileattachment();
             emailfile.setFileName('Invoice'); 
             emailfile.setBody(body);
             emailfile.setContentType('application/pdf');
             
             String subject = 'Payment Invoice '+studentNo;
             String emailBody = 'Dear Team , <br/><br/>'
                               +' Please find attached the Invoice for Loan application no. '+studentNo+'<br/><br/>'
                               +'Team NGA-SCE';  
             
            OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
            Emailwithattch.setSubject(subject);
            Emailwithattch.setOrgWideEmailAddressId(owe.id); 
            Emailwithattch.setToaddresses(setOfEmailReceiver);
            Emailwithattch.setCcAddresses(setOfCCEmailIds);
            Emailwithattch.setReplyTo(owe.Address);
            Emailwithattch.setHtmlBody(emailBody);
    
            Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{emailfile});
    
            Messaging.SendEmailResult [] r =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailwithattch});
        }
    }
  
    public String generatePassword() {
        String SPECIAL_CHAR_PATTERN = '[^\\w\\*]';
        Pattern p = Pattern.compile(SPECIAL_CHAR_PATTERN);
        Integer getLength = 9;
        String charString = '!@#$%&*nopqr123456stuvwABCDPQ!@#$%&*RSTUVWXYZ0123456789abcdefghijkEFGHI0789JKLMNOlmxyz';
        String charString1 = '!@#$%^&*';
        String charString2 = 'ABCDPQRSTUVWXYZEFGHIJKLMNO';
        String charString3 = 'nopqrstuvw0123456789EFGHIJKLMNO';
        String charString4 = '0123456789';
        String randomNew = '';
        while (randomNew.length() < getLength) {
            Integer changeInt2 = Math.mod(Math.abs(Crypto.getRandomInteger()), charString2.length());
            randomNew += charString2.substring(changeInt2 , changeInt2 +1);
            Integer changeInt5 = Math.mod(Math.abs(Crypto.getRandomInteger()), charString.length());
            randomNew += charString.substring(changeInt5 , changeInt5 +1);
            Integer changeInt3 = Math.mod(Math.abs(Crypto.getRandomInteger()), charString3.length());
            randomNew += charString3.substring(changeInt3 , changeInt3 +1);
            Integer changeInt4 = Math.mod(Math.abs(Crypto.getRandomInteger()), charString4.length());
            randomNew += charString4.substring(changeInt4 , changeInt4 +1);
            Matcher pm = p.matcher(randomNew);
            if(!pm.find()){
                Integer changeInt = Math.mod(Math.abs(Crypto.getRandomInteger()), charString1.length());
                randomNew += charString1.substring(changeInt , changeInt +1);
            }
        }
        randomNew = randomNew.left(8);
        System.debug('randomNew-->'+randomNew);
        return randomNew;
    }


    // public void checkCourseListAreValid(List<Opportunity> lstOpportunity,Map<Id,Opportunity> oldMap) {
    //     Set<Integer> sem = new Set<Integer>();
    //     Set<String> programStructure = new Set<String>();
    //     Set<Id> programId = new Set<Id>();
    //     Set<String> consumerType = new Set<String>();
    //     for(Opportunity opp : lstOpportunity) {
    //         sem.add(Integer.valueOf(opp.Sem__c));
    //         programStructure.add(opp.Program_Structure__c);
    //         programId.add(opp.nm_Program__c);
    //         consumerType.add(opp.ConsumerType__c);
    //     }

    //     List<nm_Courses__c> lstCourse = [SELECT id,Name,Student_Zone_Course_Id__c, Semester__c, Program_Structure__c, Program__c, ConsumerType__c  FROM nm_Courses__c WHERE Semester__c IN :sem AND Program_Structure__c IN :programStructure AND Program__c IN :programId AND ConsumerType__c IN :consumerType];
    //     for(Opportunity objOpp : lstOpportunity) {
    //         if(String.isNotBlank(objOpp.CourseList__c) && objOpp.CourseList__c != oldMap.get(objOpp.Id).CourseList__c ) {
    //             List<String> courseListArray = String.isNotBlank(objOpp.CourseList__c) ? objOpp.CourseList__c.split(',') : new List<String>();
    //             // List<nm_Courses__c> lstObjCourse = new List<nm_Courses__c>();
    //             List<String> setCourseLst = new List<String>();
    //             for(nm_Courses__c objCourse : lstCourse) {
    //                 if(String.isNotBlank(String.valueOf(objCourse.Semester__c)) 
    //                     && String.isNotBlank(objCourse.Program_Structure__c) 
    //                     && String.isNotBlank(String.valueOf(objCourse.Program__c)) 
    //                     && String.isNotBlank(objCourse.ConsumerType__c)
    //                     && String.valueOf(objOpp.Sem__c) == String.valueOf( objCourse.Semester__c)
    //                     && String.valueOf(objOpp.Program_Structure__c) == String.valueOf( objCourse.Program_Structure__c)
    //                     && String.valueOf(objOpp.nm_Program__c) == String.valueOf( objCourse.Program__c)
    //                     && String.valueOf(objOpp.ConsumerType__c) == String.valueOf( objCourse.ConsumerType__c)
                    
    //                 ) {
    //                     setCourseLst.add(String.valueOf(objCourse.Student_Zone_Course_Id__c  ));
    //                 }
    //             }
    //             Boolean ISCourseListContains = (setCourseLst.size() >= courseListArray.size()) && checkCourseCountainAreTrue(courseListArray, setCourseLst) ? True : False;

    //             if(!ISCourseListContains) {
    //                 if (!Test.isRunningTest()) {
    //                     objOpp.addError('Invalid Course Id. Course Id can be only ' + setCourseLst.toString());
    //                 }
    //             }

    //         }
    //     }
    // }

    public Boolean checkCourseCountainAreTrue(List<String> TrueList, List<String> canBeFalseList) {
        system.debug('canBeFalseList ---> ' + canBeFalseList);
        system.debug('TrueList ---> ' + TrueList);
        Boolean val = false;
        if (TrueList.size() > 0) {
            for(String st : TrueList) {
                if(canBeFalseList.contains(st)) {
                    val = true;
                } else {
                    val = false;
                    break;
                }
            }
        } else {
            val = true;
        }
        return val;
    }

    @future
    public static void updateIgnoreFeeTypeValidationToFalse(set<String> oppIds) {
        List<Opportunity> lstOpp = new List<Opportunity>();
        for (String oppId : oppIds) {
            lstOpp.add(new opportunity(Id = oppId, Ignore_Fee_Type_Validation__c = false));
        }
        if (lstOpp.size() > 0) {
            update lstOpp;
        }
    }



    @future
    public static void updatePaymentRecordOnCourseListChange(Set<Id> oppIds) {
        List<Opportunity> lOpp = new List<Opportunity>();
        List<nm_Payment__c> lstPaymentToUpdate = new List<nm_Payment__c>();
        List<Opportunity> lstOpportunity = [SELECT Id FROM Opportunity WHERE ID = :oppIds ];


        
        List<nm_Payment__c> lstPayment = [Select Id, nm_PaymentType__c,nm_PaymentStatus__c,nm_Merchant_Track_Id__c,Candidate_Name__c, nm_OpportunityNew__c From nm_Payment__c Where nm_OpportunityNew__c IN :oppIds];
        
        for(Opportunity objOpp :lstOpportunity )  {
            for(nm_Payment__c objPay : lstPayment) {
                    if(objPay.nm_OpportunityNew__c == objOpp.Id && String.isNotBlank(objPay.nm_PaymentType__c) && objPay.nm_PaymentType__c == 'Live Lectures' && !'Transaction Failed'.equalsIgnoreCase(objPay.nm_PaymentStatus__c) ) {
                        nm_Payment__c newPay = new nm_Payment__c();
                        newPay.Id = objPay.Id;
                        newPay.nm_PaymentType__c ='Installment';
                        newPay.nm_PaymentStatus__c ='Payment Made';
                        sendEmailToFinanceDepartmentOnPaymentCreation(objPay.Id, objPay.nm_Merchant_Track_Id__c, objPay.Candidate_Name__c);
                        lstPaymentToUpdate.add(newPay);
                    }
            }

            Opportunity oppObj = new Opportunity();
            oppObj.Id = objOpp.Id;
            oppObj.LiveLecturesType__c = 'No';
            oppObj.CourseList__c = '';
            lOpp.add(oppObj);
        }
        if(lstPaymentToUpdate.size() > 0) {
            update lstPaymentToUpdate;
        }
        if(lOpp.size() > 0) {
            update lOpp;
        }
        
    }

}