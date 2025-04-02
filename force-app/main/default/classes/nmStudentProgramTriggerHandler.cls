/**
 * @File Name          : nmStudentProgramTriggerHandler.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 14-08-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/4/2019   shubhranshu     Initial Version
**/
public class nmStudentProgramTriggerHandler
{
    public void AfterUpdate(List<nm_StudentProgram__c> triggerNew, map<id, nm_StudentProgram__c> triggerOldMap)
    {
        updateEligibilityCriteriaOnAccount(triggerNew, triggerOldMap);   
        
        //call method to do not allowed to change student program of PGAllSem student to Diploma Program as PGALLSem not available to Diploma student 
       //  programUpdationFromPGToDiploma(triggerNew, triggerOldMap);
    }
    
    public void BeforeUpdate(List<nm_StudentProgram__c> triggerNew, map<id, nm_StudentProgram__c> triggerOldMap)
    {
        //call method to do not allowed to change student program of PGAllSem student to Diploma Program as PGALLSem not available to Diploma student 
        // programUpdationFromPGToDiploma(triggerNew, triggerOldMap);
    }
    /* Error not required
    public void programUpdationFromPGToDiploma(List<nm_StudentProgram__c> triggerNew, map<id, nm_StudentProgram__c> triggerOldMap)
    {
        Set<Id> accIds = new Set<Id>(); 
        Map<String,String> mapOfProgramIdAndProgramName = new Map<String,String>();
        // create Map of All Active Program 
        List<nm_Program__c> lstProgram = [select id,Name,nm_ProgramName__c from nm_Program__c where nmIsActive__c = true];
        if(lstProgram.size()>0)
        {
            for(nm_Program__c objProgram : lstProgram)
            {
                mapOfProgramIdAndProgramName.put(objProgram.id,objProgram.nm_ProgramName__c);
            }
        }
        
        Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
         
        for(nm_StudentProgram__c sp : triggerNew)
        {
           if(sp.nm_Program__c != triggerOldMap.get(sp.id).nm_Program__c)
           {
               // do not allowed to change Program for Other than System Admin to Diploma from PG 
               if(!ProfileName.Name.equals('System Administrator'))
               {
                   // checking Program Change to Diploma 
                   if(mapOfProgramIdAndProgramName.get(sp.nm_Program__c).startswith('Diploma'))
                   {
                       accIds.add(sp.nm_Student__c);
                   }
               }    
           }  
        }
        
        // do not allowed program change from pg to Diploma for PGALLSEM fee Paid Student 
        if(accIds.size()>0)
        {
            list<Opportunity> lstOpportunity =[select AccountId,Account.nm_Tagged_Pricebook__c,Choose_a_Program__c,Program_Name__c, Account.nm_DefencePersonnel__c,id,name,nm_Program__c,nm_Semester__c,nm_Fee_Type__c,StageName from Opportunity where AccountID In :accIds];
            if(lstOpportunity.size()>0)
            {
                for(Opportunity objOpp : lstOpportunity)
                {
                    if(objOpp.nm_Fee_Type__c.equalsIgnoreCase('PGAllSemFee'))
                    {
                        for(nm_StudentProgram__c sp : triggerNew)
                        {
                            if((sp.nm_Student__c).equals(objOpp.AccountId))
                            {
                                sp.addError('Program Change of PGALLSEM Fee student to Diploma Not allowed');
                            }    
                        }
                    }
                }
            }
        }
    }*/
    
    public void updateEligibilityCriteriaOnAccount(List<nm_StudentProgram__c> triggerNew,  map<id, nm_StudentProgram__c> triggerOldMap)
     {         
        Set<Id> accIds = new Set<Id>();   
        List<Account> listAccount = new List<Account>();
        
        for(nm_StudentProgram__c sp : triggerNew)
        {
           if(sp.nm_EligiblityCriteria__c != triggerOldMap.get(sp.id).nm_EligiblityCriteria__c)
           {
             accIds.add(sp.nm_Student__c);
           }  
        }
        
         if(accIds.size()>0)
        {
            for(nm_StudentProgram__c sp : triggerNew)
            {
                Account objAccountToUpdate =new Account(id=sp.nm_Student__c);
                objAccountToUpdate.nm_EligiblityCriteria__c = sp.nm_EligiblityCriteria__c;
                listAccount.add(objAccountToUpdate);
            }
            
            if(listAccount.size() > 0)
            {
                update listAccount;   
            }
        }
    }
    
    public void UpdateOppsOnProgChange(list<nm_StudentProgram__c> triggerNew,map<id,nm_StudentProgram__c> triggerOldMap){      
        
        set<id> NewstudentProgID =  new set<id>();
        set<String> setOfAccountId =new set<String>();
        set<id> idOfOpps = new set<id>();    
        nm_StudentProgram__c stdProgram;
        nm_StudentProgram__c newProgram;
        nm_StudentProgram__c oldProgram;
        integer sizeOfOppToUpdate;
        string NewProgramName;
        boolean ProgramChangeApplicable=false;
        decimal TotalSem;
        List<nm_Program__c> Lstofnewprogram = new List<nm_Program__c>();
    
        // new code customization
        Set<String> setofProgramIds = new Set<String>();
        Set<String> setofStudProgIds = new Set<String>();
        
        ProductHelper helper =new ProductHelper();
        for(nm_StudentProgram__c ob:triggerNew){
            if(ob.nm_Program__c !=triggerOldMap.get(ob.id).nm_Program__c){    
                setofProgramIds.add(ob.nm_Program__c);
                setofStudProgIds.add(ob.Id);
                stdProgram = ob;
            }       
        }   

        if(setofProgramIds.size() > 0 && setofStudProgIds.size() > 0){
        system.debug('setofStudProgIds---->'+setofStudProgIds );

            Lstofnewprogram =  [select id,name,IsTerm__c, nm_Type__c,nm_TotalSemesters__c ,Specialisation__c,nm_ProgramName__c,PVM__c from nm_Program__c where id IN: setofProgramIds ];
            list<Opportunity> lstofOpportunity =[select AccountId,Account.nm_Tagged_Pricebook__c,nm_Fee_Type__c, LiveLecturesType__c,IsTerm__c,
                                                    nm_Program__r.nm_Type__c,
                                                    Choose_a_Program__c,nm_StudentProgram__c,nm_Program__r.IsTerm__c,
                                                    nm_Semester__c,StageName
                                                    from Opportunity where nm_StudentProgram__c IN: setofStudProgIds ORDER BY nm_Semester__c DESC LIMIT 1];
            
            for(nm_Program__c prog:Lstofnewprogram){
                TotalSem = TotalSem > 0.0 ? TotalSem + prog.nm_TotalSemesters__c : prog.nm_TotalSemesters__c;
                NewProgramName = prog.name;     
            }
            
            //Validation for Fee type prior program change applied     
             system.debug('lstofOpportunity-->'+lstofOpportunity);   
            System.debug('TotalSem--->'+TotalSem); 
            System.debug('NewProgramName --->'+NewProgramName);
            system.debug('lstofOpportunity[0].nm_Fee_Type__c--->'+lstofOpportunity[0].nm_Fee_Type__c);   
            if(lstofOpportunity.size() > 0){   
                system.debug('lstofOpportunity[0].nm_Fee_Type__c--->'+lstofOpportunity[0].nm_Fee_Type__c);      
                system.debug('lstofOpportunity[0].LiveLecturesType__c--->'+lstofOpportunity[0].LiveLecturesType__c);      
                ProgramChangeApplicable = helper.ValidateFeeType(TotalSem,lstofOpportunity[0].nm_Fee_Type__c, lstofOpportunity[0].LiveLecturesType__c, lstofOpportunity[0].IsTerm__c	);
            }
            system.debug('ProgramChangeApplicable--->'+ProgramChangeApplicable);   
            if(ProgramChangeApplicable) { 
                for(nm_StudentProgram__c ob:triggerNew){
                    newProgram = ob;
                    oldProgram =triggerOldMap.get(ob.id);      
                    setOfAccountId.add(ob.nm_Student__c); 
                }    

                list<Opportunity> oppToUpdate=[select Account.Name,Processed__c,nm_StudentProgram__r.nm_FeesPaidofSemester__c , Account.OldStudentForExecutive__c,AccountId,IC__c,Account.nm_Tagged_Pricebook__c,nm_Program__r.nm_Type__c,Choose_a_Program__c,Program_Name__c,nm_Program__r.name,Account.nm_DefencePersonnel__c,id,name,nm_Program__c,nm_Semester__c,nm_Fee_Type__c,StageName,ActualPendingAmount__c from Opportunity where AccountID =:setOfAccountId Order by nm_Semester__c];
                System.debug('oppToUpdate[0].nm_StudentProgram__r.nm_FeesPaidofSemester__c--->'+oppToUpdate[0].nm_StudentProgram__r.nm_FeesPaidofSemester__c );
                
                // oppToUpdate.sort();
                sizeOfOppToUpdate = oppToUpdate.size()-1;
            
                Opportunity opp = oppToUpdate[sizeOfOppToUpdate];
                System.debug('<----------oppToUpdate-------------->'+opp);
                idOfOpps.add(opp.id);
                Boolean checkIsChangeApp = checkProgramIsChangesFromDiplomaToMBA(oldProgram.nm_Program__c, newProgram.nm_Program__c, opp);
                list<OpportunityLineItem> lst=[select product2.id,Quantity,OpportunityId from OpportunityLineItem where Product_Name__c LIKE 'Semester%' and OpportunityId in:idOfOpps];
                if(lst.size()>0){
                    try {
                        delete lst; 
                    } catch (DmlException e) {
                        System.debug('Exception --->'+e.getMessage());
                    }
                } 
                opp.nm_Program__c = newProgram.nm_Program__c;
                try {
                    update opp;
                } catch (DmlException e) {
                    System.debug('Exception --->'+e.getMessage());
                }
                //  UpdateRelatedProgram(opp.AccountId,newProgram.nm_Program__c);
                //   UpdateValidUpto(opp.AccountId,newProgram.nm_Program__c);
                If( Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
                    if (checkIsChangeApp) {
                        System.enqueueJob(new updateFutureAndSem1ProgramChange(opp.AccountId,newProgram.nm_Program__c));
                    } else {
                        System.enqueueJob(new UpdateOpportunityRelatedProgram(opp.AccountId,newProgram.nm_Program__c,Lstofnewprogram));
                    }
                }
                
                system.debug('opp.Program_Name__c'+opp.Program_Name__c);
                set<String> setOfOppsId = new set<String>{opp.id};
                    
                Map<String,Map<String,PriceBookEntry>> mapPricebook = helper.getMapOfPriceBookIdProductVsPriceBookEntry();
                Map<Id,Account> mapOfOppsVsAccount = helper.getOpportunityRelatedAccount(setOfAccountId);
                Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = helper.getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
                helper.CreateSemesterLineIteam(oppToUpdate[sizeOfOppToUpdate],mapPricebook,mapOfOppsVsAccount,mapOfOppsIdVsOpportunityLineItem );
                
                //Delete the CertificateServicetax Lineitem only admission payment not done  
                if((newProgram.ProgramType__c    =='Diploma Programs' || newProgram.ProgramType__c   =='MBA (Distance) Programs' || (newProgram.ProgramType__c == 'Master Programs' && newProgram.Specialisation__c == 'MBA') || newProgram.ProgramType__c =='Professional Programs' )
                && (oldProgram.ProgramType__c    == 'Certificate Programs' || oldProgram.ProgramType__c  =='Executive Programs') && opp.ActualPendingAmount__c>0){ 
                    helper.DeleteOpportunityLineItemAfterProgramChange(opp);
                    System.debug('DeleteOpportunityLineItemAfterProgramChange');
                }
                //Update the LineItem if old choose program is Certificate
                if(oldProgram.ProgramType__c     == 'Certificate Programs' || oldProgram.ProgramType__c  =='Executive Programs'){
                    system.debug('Lstofnewprogram[0]--->'+Lstofnewprogram[0]);
                    helper.UpdateOpportunityLineItemAfterFeetypeChange(opp,Lstofnewprogram[0], null, null);
                }
                system.debug('opp.Processed__c'+opp.Processed__c);
                //Update the stage depeding upon the program change ---Certificate are exclude as there stage gets updated while lineitem update
                if(oldProgram.ProgramType__c     != newProgram.ProgramType__c    && (oldProgram.ProgramType__c   != 'Certificate Programs' || oldProgram.ProgramType__c  !='Executive Programs')){
                    helper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(opp.id,'Program Change', null, null);
                }    
            }else{
                stdProgram.addError('Please change the fee type to change the program');
            }
        }

        
        
        // if(setOfAccountId.size()>0)
        // {
        //     list<Opportunity> oppToUpdate=[select Account.Name,Processed__c,nm_StudentProgram__r.nm_FeesPaidofSemester__c , Account.OldStudentForExecutive__c,AccountId,IC__c,Account.nm_Tagged_Pricebook__c,nm_Program__r.nm_Type__c,Choose_a_Program__c,Program_Name__c,nm_Program__r.name,Account.nm_DefencePersonnel__c,id,name,nm_Program__c,nm_Semester__c,nm_Fee_Type__c,StageName,ActualPendingAmount__c from Opportunity where AccountID =:setOfAccountId];
        //     System.debug('oppToUpdate[0].nm_StudentProgram__r.nm_FeesPaidofSemester__c--->'+oppToUpdate[0].nm_StudentProgram__r.nm_FeesPaidofSemester__c );
            
        //     oppToUpdate.sort();
        //     sizeOfOppToUpdate = oppToUpdate.size()-1;
        
        //     Opportunity opp = oppToUpdate[sizeOfOppToUpdate];
        //     System.debug('<----------oppToUpdate-------------->'+opp);
        //     idOfOpps.add(opp.id);
        //     list<OpportunityLineItem> lst=[select product2.id,Quantity,OpportunityId from OpportunityLineItem where Product_Name__c LIKE 'Semester%' and OpportunityId in:idOfOpps];
        //     if(lst.size()>0)
        //     {
        //       delete lst;
        //     } 
            
        //     opp.nm_Program__c = newProgram.nm_Program__c;
        //     update opp;
        //   //  UpdateRelatedProgram(opp.AccountId,newProgram.nm_Program__c);
        //  //   UpdateValidUpto(opp.AccountId,newProgram.nm_Program__c);
        //  If( Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
        //     System.enqueueJob(new  UpdateOpportunityRelatedProgram(opp.AccountId,newProgram.nm_Program__c,Lstofnewprogram));
        //     }
        
        //     system.debug('opp.Program_Name__c'+opp.Program_Name__c);
        //     set<String> setOfOppsId = new set<String>{opp.id};
            
    
        //    Map<String,Map<String,PriceBookEntry>> mapPricebook = helper.getMapOfPriceBookIdProductVsPriceBookEntry();
        //    Map<Id,Account> mapOfOppsVsAccount = helper.getOpportunityRelatedAccount(setOfAccountId);
        //    Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = helper.getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
        //    helper.CreateSemesterLineIteam(oppToUpdate[sizeOfOppToUpdate],mapPricebook,mapOfOppsVsAccount,mapOfOppsIdVsOpportunityLineItem );
        
        //      //Delete the CertificateServicetax Lineitem only admission payment not done  
        //     if((newProgram.nm_Choose_Program__c =='D' || newProgram.nm_Choose_Program__c =='P' )
        //     && (oldProgram.nm_Choose_Program__c == 'C' || oldProgram.nm_Choose_Program__c =='E') &&opp.ActualPendingAmount__c>0) 
        
        //     { 
        //        helper.DeleteOpportunityLineItemAfterProgramChange(opp);
        //        System.debug('DeleteOpportunityLineItemAfterProgramChange');
        //     }
        //     //Update the LineItem if old choose program is Certificate
        //      if(oldProgram.nm_Choose_Program__c == 'C' || oldProgram.nm_Choose_Program__c =='E') 
        //     {
        //         system.debug('Lstofnewprogram[0]--->'+Lstofnewprogram[0]);
        //         helper.UpdateOpportunityLineItemAfterFeetypeChange(opp,Lstofnewprogram[0]);
        //     }
        //     system.debug('opp.Processed__c'+opp.Processed__c);
        //     //Update the stage depeding upon the program change ---Certificate are exclude as there stage gets updated while lineitem update
        //     if(oldProgram.nm_Choose_Program__c != newProgram.nm_Choose_Program__c && (oldProgram.nm_Choose_Program__c != 'C' || oldProgram.nm_Choose_Program__c !='E')) 
        //     {
        //       helper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(opp.id,'Program Change');
        //     }    
            
        //    /* if(newProgram.nm_Choose_Program__c =='C' && oldProgram.nm_Choose_Program__c != 'C' && opp.StageName !='Registration Done')
        //     {                                                              
        //         lstPaymnetToinsertNotExist.add(CreateExtraFeeRecord(1000,oppToUpdate[0].id));                                     
        //         if(lstPaymnetToinsertNotExist.size()>0)
        //         {
        //             insert lstPaymnetToinsertNotExist;
        //         }            
        //     }
            
        //       if(oldProgram.nm_Choose_Program__c == 'C' || oldProgram.nm_Choose_Program__c =='A') 
        //     {
        //         helper.UpdateOpportunityLineItemAfterFeetypeChange(opp);
        //     }              
            
        //     move to producthelper but checking if earlier stage was Closed won then check for debit entry
        //      if(opp.StageName=='Closed Won' && opp.Processed__c == true &&  !opp.nm_Fee_Type__c.contains('-Considered')) 
        //     {                                                                            
        //          helper.CheckForAdjustmentDebit(setOfOppsId,opp); // calling method from OpportunityTriggerHandler//
        //     } */
        // }               
    }   

    public Boolean checkProgramIsChangesFromDiplomaToMBA(String oldProgramId, String newProgramId, Opportunity Opportunity) {
        List<String> setofProgramIds = new List<String>{oldProgramId, newProgramId};
        List<nm_Program__c> oldProg = new list<nm_Program__c>();
        List<nm_Program__c> newProg = new list<nm_Program__c>();
        for(nm_Program__c objProg :[select id,name,IsTerm__c, nm_Type__c,nm_TotalSemesters__c ,Specialisation__c,nm_ProgramName__c,PVM__c from nm_Program__c where id IN: setofProgramIds ]) {
            if (objProg.Id == oldProgramId) {
                oldProg.add(objProg);
            } else if (objProg.Id == newProgramId) {
                newProg.add(objProg);
            }
        }
        if (oldProg.size() > 0 && newProg.size() > 0 && oldProg[0].nm_Type__c == 'Diploma Programs' && (newProg[0].nm_Type__c == 'MBA (Distance) Programs' || (newProg[0].nm_Type__c == 'Master Programs' && newProg[0].Specialisation__c == 'MBA') ) && Opportunity.nm_Semester__c == '2') {
            for (Opportunity objOpp :  [SELECT Id FROM Opportunity WHERE AccountId = :Opportunity.AccountId AND nm_Semester__c = '1' AND StageName = 'Closed Won' AND nm_Fee_Type__c != 'admission' LIMIT 1]) {
                return true;
            }
        }
        return false;
    }
              
 //Method in Use
 public void CreateStudentProgram(List<Opportunity> lstOpportunity)
    {
        if(lstOpportunity != null && lstOpportunity.size() > 0 )
        {
            List<nm_StudentProgram__c> lstStudentProgram = new List<nm_StudentProgram__c>();
            
            for(Opportunity objOpportunity : lstOpportunity)
            {
                if(objOpportunity.nm_Semester__c == '1' && objOpportunity.nm_Program__c != null && objOpportunity.AccountId != null && !objOpportunity.TermRepeated__c  )
                {                   
                    lstStudentProgram.add(InsertStudentProgram(1,objOpportunity));     
                }
                else if(objOpportunity.nm_Semester__c != '1'&& objOpportunity.nm_Program__c != null && objOpportunity.AccountId != null && objOpportunity.nm_Category__c == 'Lateral Admission' && objOpportunity.StageName !='Closed Won - Re-registration Pending')
                {            
                    lstStudentProgram.add(InsertStudentProgram(Decimal.valueof(objOpportunity.nm_Semester__c),objOpportunity));    
                }               
            }
            
            if(lstStudentProgram != null && lstStudentProgram.size() > 0)
            {
                insert lstStudentProgram;
            }
                
        }
    }
     //Method  in Use
    public nm_StudentProgram__c InsertStudentProgram(Decimal CurrentSession,Opportunity objOpportunity)
    {
        nm_StudentProgram__c objStudentProgram = new nm_StudentProgram__c();                    
        objStudentProgram.nm_Student__c = objOpportunity.AccountId;
        objStudentProgram.nm_Program__c = objOpportunity.nm_Program__c;
        objStudentProgram.nm_EligiblityCriteria__c = objOpportunity.nm_EligiblityCriteriaid__c;
        objStudentProgram.nm_CurrentSession__c = CurrentSession;
        return objStudentProgram;
    }
    
    public class UpdateOpportunityRelatedProgram implements Queueable {
      
        public String AccountId;
        public Id program;
        public List<nm_Program__c> Lstprogram;
                      
        public UpdateOpportunityRelatedProgram(String AccountId ,ID program,List<nm_Program__c> Lstprogram) {
          
            this.AccountId = AccountId;
            this.program = program;
            this.Lstprogram = Lstprogram;
        }
        
        public void execute(QueueableContext queCont) {
             list<Opportunity> lstoppupdate = new  list<Opportunity> ();
             Set<String> oppsid = new Set<String> ();
             Set<String> setOfAccountId = new Set<String> {AccountId};
             
            list<Opportunity> lstopp =[select Account.Name,nm_Category__c ,
                                        Processed__c,nm_StudentProgram__r.nm_FeesPaidofSemester__c , 
                                        Account.OldStudentForExecutive__c,AccountId,IC__c,Account.nm_Tagged_Pricebook__c,
                                        nm_Program__r.nm_Type__c,Choose_a_Program__c,Program_Name__c,
                                        nm_Program__r.name,Account.nm_DefencePersonnel__c,id,name,nm_Program__c,nm_Semester__c,
                                        nm_Fee_Type__c,StageName,ActualPendingAmount__c from Opportunity where AccountID =:setOfAccountId];
            
             if(lstopp.size()>0)
             {
                 for (Opportunity objopps :lstopp )
                 {
                     if('Closed Won - Re-registration Pending'.equalsIgnoreCase(objopps.StageName))
                     {
                         objopps.nm_Program__c = program;
                         oppsid.add(objopps.id);                         
                         lstoppupdate.add(objopps);
                     }
                 }
                 
                 
                 
                if(lstoppupdate.size()>0 )
                {
                    update lstoppupdate;
                }
                
                list<OpportunityLineItem> lst=[select product2.id,Quantity,OpportunityId from OpportunityLineItem where (Product_Name__c LIKE 'Semester%' OR Product_Name__c LIKE 'Term%' ) and OpportunityId in:oppsid];
                
                if(lst.size()>0)
                {
                    delete lst;
                } 
                if(lstoppupdate.size()>0)
                {
                    ProductHelper helper =new ProductHelper();
                    
                    Map<String,Map<String,PriceBookEntry>> mapPricebook = helper.getMapOfPriceBookIdProductVsPriceBookEntry();
                    Map<Id,Account> mapOfOppsVsAccount = helper.getOpportunityRelatedAccount(setOfAccountId);
                    Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = helper.getOpportunityLineItemEntryRelatedToOpportuntiy(oppsid);
                    
                    if(lstoppupdate.size()>0)
                    {
                        for (Opportunity objopps :lstoppupdate)
                         {
                             helper.CreateSemesterLineIteam(objopps,mapPricebook,mapOfOppsVsAccount,mapOfOppsIdVsOpportunityLineItem );
                         }
                 
                    }
                }
                List<Account> lstAcc = [select id,BatchStartD__c, ValidUptoR__c,Sem__c from Account where nm_StudentStatus__c ='Confirmed' and id =:AccountId and BatchStartD__c!=null];
         
                if(lstAcc.size()>0)
                {
                    List<Account> lstAccupdate = new List<Account> ();
                    Integer Sem ;
                     
                    // List<nm_Program__c> Lstprogram = new List<nm_Program__c> ();
                     Account objaccount = lstAcc[0];   
                 
                    // Lstprogram =  [select id,name, nm_Type__c,nm_TotalSemesters__c ,Specialisation__c,nm_ProgramName__c,PVM__c from nm_Program__c where id =:program limit 1];      
                     nm_Program__c objprj = Lstprogram[0]; 
                     
                     ProductHelper helper =new ProductHelper();
                     
                     if(objaccount.Sem__c!=null && objaccount.Sem__c!='' )
                     {
                         Sem = Integer.valueof(objaccount.Sem__c);
                     }
                     else
                     {
                         Sem = 1;
                     }
                      
                    String Validupto = helper.Validity(objaccount.BatchStartD__c, objprj ,Sem) ;
                    
                    if(Validupto!=null && Validupto!='')
                    {
                        objaccount.ValidUptoR__c = Validupto;
                        lstAccupdate.add(objaccount);
                    }
                    if(lstAccupdate.size()>0)
                    {
                        update lstAccupdate;
                    }
                }
            }
            
        }
    }

    public class updateFutureAndSem1ProgramChange implements Queueable {
      
        public String AccountId;
        public String newProgramId;
        productHelper productHelper;
                      
        public updateFutureAndSem1ProgramChange(String AccountId ,String newProgramId) {
          
            this.AccountId = AccountId;
            this.newProgramId = newProgramId;
            productHelper = new productHelper();
        }

        public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
            Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
            Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
            List <String> fieldNames = new List <String> (fieldMap.keySet());
            if(relatedField !=null && relatedField !=''){
                fieldNames.add(relatedField);
            }
            String query = 'SELECT '+String.join( fieldNames, ',') +' FROM '+ SObjectAPIName +' WHERE '+conditionString;
            return query;
        }

        public decimal ProductPricing(Map<String,PriceBookEntry> mapOfPricebook, String programId,String programName,Integer multiplicationFactor,String programKey, Boolean isDefence){
            Decimal amount = 0;
            Integer sem = 1;
            System.debug('--programKey---'+programKey+'-programId-'+programId);            
            if(isDefence ){
                amount = mapOfPricebook.get(programId+'-1').UnitPrice;
                amount =  amount * multiplicationFactor * 0.8;
            }else{
                if(mapOfPricebook.containsKey(programKey)) {
                    System.debug('enter programName '+programKey);
                    amount = mapOfPricebook.get(programKey).UnitPrice;
                }else{
                    System.debug('not found '+programKey);
                }
            }
            return amount.setScale(2);
        }
    
        Map<String,String> mapOfFeeTypeVsFutureSem = new Map<String,String>{'PGAllSemFee' => 'All', 'AnnualFee' => 'Half', '2TermFee' => 'Half',
        'FullFee' => 'All', '3SemFee' => '3','3TermFee' => '3', '4SemFee' => '4', '5SemFee'=>'5', 'MultipleSemFee' => '3','FullFeeLoan' => 'All', 'AnnualFeeLoan' => 'Half'};
        
        
        public void execute(QueueableContext queCont) {
            Opportunity firstOpp;
            Opportunity secondOpp;
            Map<String,PriceBookEntry> mapOfPricebook = new Map<String,PriceBookEntry>();
            Set<String> setOfFeeTypeCanBe = new Set<String>{'3SemFee', 'FullFee'};
            Map<String, Decimal> mapOffeeTypeVsAmount =  new Map<String, Decimal>();
            String feeTypeToUse = '';
            Decimal totalSem;
            String oppQuery = getQueryAllFieldSql('Opportunity' ,'AccountId = :AccountId ORDER BY nm_Semester__c', 'Account.nm_DefencePersonnel__c ,Account.nm_Tagged_Pricebook__c');
            List<Opportunity> lstOpp = DataBase.query(oppQuery);
            for (Opportunity objOpp : lstOpp) {
                if (objOpp.nm_Semester__c == '1') {
                    firstOpp = objOpp;
                } else if(objOpp.nm_Semester__c == '2') {
                    secondOpp = objOpp;
                }
            }
            if(String.isBlank(firstOpp.Account.nm_Tagged_Pricebook__c)) {
                Map<String,Map<String,PriceBookEntry>> getMapOfPriceBookIdProductVsPriceBookEntry = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
                mapOfPricebook = getMapOfPriceBookIdProductVsPriceBookEntry.get(firstOpp.Account.nm_Tagged_Pricebook__c);
            } else {
                mapOfPricebook = productHelper.getMapOfProductVsPriceBookEntry(firstOpp.Account.nm_Tagged_Pricebook__c);
            }
            Decimal totalAmountRecieved = 0;
            Decimal liveLectureAmountRecieved = 0;
            Decimal getLiveLectureProductPrice = mapOfPricebook.containsKey('Live Lectures') ? mapOfPricebook.get('Live Lectures').UnitPrice : 0;
            for (nm_Payment__c objPay : [SELECT Id, nm_PaymentType__c, nm_Amount__c FROM nm_Payment__c WHERE nm_OpportunityNew__c =:firstOpp.Id and nm_PaymentStatus__c != 'Transaction Failed' and nm_PaymentStatus__c != null and nm_OpportunityNew__c !=null ]) {
                if (objPay.nm_PaymentType__c.contains('Admission') || objPay.nm_PaymentType__c =='Installment' || objPay.nm_PaymentType__c.contains('DownPayment') || objPay.nm_PaymentType__c.contains('Subvention') || objPay.nm_PaymentType__c.contains('Initial Payment') || objPay.nm_PaymentType__c =='Additional Charge') {
                    totalAmountRecieved += objPay.nm_Amount__c;
                } else if(objPay.nm_PaymentType__c == 'Live Lectures') {
                    liveLectureAmountRecieved += objPay.nm_Amount__c;
                }
            }

            string liveLectureFeeType = liveLectureAmountRecieved > 0 && getLiveLectureProductPrice > 0 ? (liveLectureAmountRecieved == 18000 ? '3SemLecturesFee' : liveLectureAmountRecieved == 24000 ? '4SemLecturesFee' : null ): null;

            for (String feeType : setOfFeeTypeCanBe) {
                String key = mapOfPricebook.containsKey(feeType+'-'+newProgramId) ? feeType+'-'+newProgramId : feeType == 'AnnualFee' ? 'Annual' : feeType;
                Decimal productPrice = ProductPricing(mapOfPricebook,newProgramId, Feetype,feeType.contains('FullFee') ? 4 : productHelper.getmultiplicationFactor(Feetype), key, firstOpp.Account.nm_DefencePersonnel__c == 'Yes' ? true : false);
                if (productPrice <= totalAmountRecieved) {
                    mapOffeeTypeVsAmount.put(feeType, productPrice);
                }
            }
            // String higgestFeeType = '';
            for (String feeType : mapOffeeTypeVsAmount.keySet()) {
                feeTypeToUse = String.isBlank(feeTypeToUse) ? feeType : feeTypeToUse;
                feeTypeToUse = mapOffeeTypeVsAmount.get(feeTypeToUse) > mapOffeeTypeVsAmount.get(feeType) ? feeTypeToUse : feeType;
            }
            system.debug('mapOffeeTypeVsAmount --> ' + mapOffeeTypeVsAmount);
            system.debug('feeTypeToUse --> ' + feeTypeToUse);

            // if (mapOffeeTypeVsAmount.size() == 1) {
            //     feeTypeToUse = new List<String>(mapOffeeTypeVsAmount.keySet())[0];
            // }
            if (String.isNotBlank(feeTypeToUse)) {
                nmPGAllSemFee nmPGAllSemFee = new nmPGAllSemFee();
                if(mapOfFeeTypeVsFutureSem.get(feeTypeToUse) == 'All') {
                    totalSem = 4;
                } else if(mapOfFeeTypeVsFutureSem.get(feeTypeToUse) == 'Half') {
                    totalSem = 2 ;
                } else {
                    totalSem = Decimal.valueOf(mapOfFeeTypeVsFutureSem.get(feeTypeToUse));
                }
                Map<Decimal,Opportunity> mapOfTermVsOpportunity = new Map<Decimal,Opportunity>();
                Opportunity newOpportunity = firstOpp;
                for(Decimal i =3; i <= totalSem; i++)
                {
                    Opportunity nextOpportunity = mapOfTermVsOpportunity.size() > 0 && mapOfTermVsOpportunity.containsKey(i - 1) ? mapOfTermVsOpportunity.get(i-1) : secondOpp;
                    Opportunity futureSem = nmPGAllSemFee.getNextSemOpportunity(nextOpportunity,4,feeTypeToUse,liveLectureFeeType);
                    mapOfTermVsOpportunity.put(i,futureSem);
                }
                if (mapOfTermVsOpportunity.values().size() > 0) {
                    insert mapOfTermVsOpportunity.values();
                }
                List<Opportunity> lstUpOpportunity = new List<Opportunity>();
                firstOpp.nm_Fee_Type__c = feeTypeToUse;
                firstOpp.LiveLecturesType__c = liveLectureFeeType;
                firstOpp.Ignore_Fee_Type_Validation__c = true;
                lstUpOpportunity.add(firstOpp);
                secondOpp.nm_Fee_Type__c = feeTypeToUse+'-Considered';
                secondOpp.LiveLecturesType__c = liveLectureFeeType!=null && liveLectureFeeType!=''  && liveLectureFeeType!='No'  && liveLectureFeeType!='Custom'? liveLectureFeeType+'-Considered':'';
                lstUpOpportunity.add(secondOpp);
                update lstUpOpportunity;
                productHelper productHelperNew = new productHelper();
                checkRecursive.isCheckRecurssiveforClosedandClosedOwn = true;
                productHelperNew.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(secondOpp.id,'FeeType Change', null, null);
            }


        }
    }







    //Method to update all those opportunity closed won re-reg pending
       @future     
         public static void UpdateRelatedProgram(String AccountId ,ID program){
             list<Opportunity> lstoppupdate = new  list<Opportunity> ();
             Set<String> oppsid = new Set<String> ();
             Set<String> setOfAccountId = new Set<String> {AccountId};
                list<Opportunity> lstopp =[select Account.Name,nm_Category__c ,Processed__c,nm_StudentProgram__r.nm_FeesPaidofSemester__c , Account.OldStudentForExecutive__c,AccountId,IC__c,Account.nm_Tagged_Pricebook__c,nm_Program__r.nm_Type__c,Choose_a_Program__c,Program_Name__c,nm_Program__r.name,Account.nm_DefencePersonnel__c,id,name,nm_Program__c,nm_Semester__c,nm_Fee_Type__c,StageName,ActualPendingAmount__c from Opportunity where AccountID =:setOfAccountId];
             if(lstopp.size()>0)
             {
                 for (Opportunity objopps :lstopp )
                 {
                     if('Closed Won - Re-registration Pending'.equalsIgnoreCase(objopps.StageName))
                     {
                         objopps.nm_Program__c = program;
                         oppsid.add(objopps.id);                         
                         lstoppupdate.add(objopps);
                     }
                 }
                 
                 
                 
                if(lstoppupdate.size()>0 )
                {
                    update lstoppupdate;
                }
                
                list<OpportunityLineItem> lst=[select product2.id,Quantity,OpportunityId from OpportunityLineItem where (Product_Name__c LIKE 'Semester%' OR Product_Name__c LIKE 'Term%' ) and OpportunityId in:oppsid];
                
                if(lst.size()>0)
                {
                    delete lst;
                } 
                if(lstoppupdate.size()>0)
                {
                    ProductHelper helper =new ProductHelper();
                    
                    Map<String,Map<String,PriceBookEntry>> mapPricebook = helper.getMapOfPriceBookIdProductVsPriceBookEntry();
                    Map<Id,Account> mapOfOppsVsAccount = helper.getOpportunityRelatedAccount(setOfAccountId);
                    Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = helper.getOpportunityLineItemEntryRelatedToOpportuntiy(oppsid);
                    
                    if(lstoppupdate.size()>0)
                    {
                        for (Opportunity objopps :lstoppupdate)
                         {
                             helper.CreateSemesterLineIteam(objopps,mapPricebook,mapOfOppsVsAccount,mapOfOppsIdVsOpportunityLineItem );
                         }
                 
                    }
               }
             }
             
         }
         
   
         //Method to update Valid upto at account Level
      @future 
     public static void UpdateValidUpto(String AccountId ,ID program ){
         
         List<Account> lstAcc = [select id,BatchStartD__c, ValidUptoR__c,Sem__c from Account where nm_StudentStatus__c ='Confirmed' and id =:AccountId and BatchStartD__c!=null];
         
        if(lstAcc.size()>0)
        {
            List<Account> lstAccupdate = new List<Account> ();
            Integer Sem ;
             
             List<nm_Program__c> Lstprogram = new List<nm_Program__c> ();
             Account objaccount = lstAcc[0];   
         
             Lstprogram =  [select id,name, nm_Type__c,nm_TotalSemesters__c ,Specialisation__c,nm_ProgramName__c,PVM__c from nm_Program__c where id =:program limit 1];      
             nm_Program__c objprj = Lstprogram[0]; 
             
             ProductHelper helper =new ProductHelper();
             
             if(objaccount.Sem__c!=null && objaccount.Sem__c!='' )
             {
                 Sem = Integer.valueof(objaccount.Sem__c);
             }
             else
             {
                 Sem = 1;
             }
              
            String Validupto = helper.Validity(objaccount.BatchStartD__c, objprj ,Sem) ;
            
            if(Validupto!=null && Validupto!='')
            {
                objaccount.ValidUptoR__c = Validupto;
                lstAccupdate.add(objaccount);
            }
          if(lstAccupdate.size()>0)
          {
              update lstAccupdate;
          }
        }
     }
}