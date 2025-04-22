/**
 * @File Name          : ProductHelper.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 02-14-2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    15/7/2019, 4:56:27 PM   @BK     Initial Version
**/
public class ProductHelper
{
  /*  // get all prcieBookEntry depending on PriceBookId 
    public Map<String,PriceBookEntry> getMapOfProductVsPriceBookEntry(String PriceBookId)
    {
        Map<String,PriceBookEntry> mapPricebook = new Map<String,PriceBookEntry>();
        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>();
        if(PriceBookId !=null)// PriceBookId is not null at time of Re-Registration 
        {
             lstPriceBookEntry = [select id, UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Semester__c
                                 from PriceBookEntry 
                                 where product2.isActive =: true 
                                 and pricebook2.isStandard = false
                                 and Pricebook2.id =:PriceBookId
                                 and Pricebook2.IsActive=true ];
        }else  // Price Book Id is null at time of Lead convert to Opportunity
        {
            //Fetching price book entry for registration fee product
                lstPriceBookEntry = [select id, UnitPrice, product2.Name, product2.nm_Program__c, product2.nm_Semester__c
                                     from PriceBookEntry 
                                     where product2.isActive =: true 
                                     and pricebook2.isStandard = false
                                     and Pricebook2.nmSession_Start_Date__c !=null
                                     and Pricebook2.nmSession_End_Date__c !=null
                                     and Pricebook2.nmSession_Start_Date__c <=Today 
                                     and Pricebook2.nmSession_End_Date__c >=Today 
                                     and Pricebook2.IsActive=true ];
        }
                                                 
       system.debug('lstPriceBookEntry '+lstPriceBookEntry );
        if(lstPriceBookEntry.size()>0)
        {
            for(PriceBookEntry objPriceBook : lstPriceBookEntry)
            {
                if(objPriceBook.product2.nm_Program__c == null)
                {
                    mapPricebook.put(objPriceBook.product2.name, objPriceBook);
                    system.debug('product2.nm_Program__c is null');
                }   
                else
                {
                    if(objPriceBook.product2.nm_Program__c != null)
                    {
                        string strKey = objPriceBook.product2.nm_Program__c + '-' + objPriceBook.product2.nm_Semester__c;
                        System.debug('!!!!!!!!inside else!!!!!!!!strKey+++'+strKey);
                        mapPricebook.put(strKey, objPriceBook);
                    }
                }
            }
        }
        
        return mapPricebook;
    }*/
    
    // caching Variable 
   public Map<String,Map<String,PriceBookEntry>> mapPricebook = new Map<String,Map<String,PriceBookEntry>>();
   public Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = new Map<String,List<nm_Payment__c>>();
   public Map<Id,Account> mapOfAccountIdVsAccount = new Map<Id,Account>(); 
   public Map<String,PriceBookEntry> mapOfPricebookEntry {get;set;}
 //  public Map<Id,PriceBookEntry> mapOfPriceBookEntryIdVsPriceBookEntry = new Map<Id,PriceBookEntry>(); 
   public List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>(); 
   public  List<Account> lstAccount = new  List<Account> ();
   public Boolean addLateFeeCheck = false;
   public Map<Id,nm_Courses__c> mapOfCourseidVsCourse = new  Map<Id,nm_Courses__c> ();  
   public Map<String,Set<String>> mapOfCourseKeyVsProgram = new Map<String,Set<String>>();
   public Map<String,Map<Id,nm_Courses__c>> mapOfCourseKeyVsCourseObj = new Map<String,Map<Id,nm_Courses__c>> ();
   public List<nm_Courses__c> lstAllProgramCourse = new List<nm_Courses__c>();
   
   public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }
   /* public Map<String,List<nm_Courses__c>> getMapOfProgramNamekeyVsCourses(){
        if(this.mapOfCourseKeyVsProgram.isEmpty() || this.mapOfCourseidVsCourse.isEmpty()){           
             List<nm_Courses__c>  lstcourse = getlstAllProgramCourses(); 
            if(lstcourse.size() > 0){
                for(nm_Courses__c objCourse : lstcourse){
                    String key = objCourse.Program_Structure__c+'_'+objCourse.Sem__c+'_'+objCourse.Program__c;
                    //this.mapOfCourseKeyVsProgram.put(key,objCourse);
                    if(!this.mapOfCourseKeyVsProgram.containsKey(key))
                    {
                        mapOfCourseKeyVsProgram.put(key,new List<nm_Courses__c>());
                    }
                    mapOfCourseKeyVsProgram.get(key).add(objCourse);
                  
                }
            }
        }
        return this.mapOfCourseKeyVsProgram;
    }*/
    public Map<String,Map<Id,nm_Courses__c>> getMapOfProgramNamekeyVsCourses(){
        if(this.mapOfCourseKeyVsCourseObj.isEmpty()){           
             List<nm_Courses__c>  lstcourse = getlstAllProgramCourses(); 
            if(lstcourse.size() > 0){
                for(nm_Courses__c objCourse : lstcourse){
                    String key = objCourse.Program__c+'-'+objCourse.Program_Structure__c+'-'+objCourse.Sem__c +'-'+ objCourse.ConsumerType__c;
                    //this.mapOfCourseKeyVsCourseObj.put(key,objCourse);
                   
                    if(!this.mapOfCourseKeyVsCourseObj.containsKey(key))
                    {
                        //system.debug('Coursekey---->'+key);
                        this.mapOfCourseKeyVsCourseObj.put(key,new Map<Id,nm_Courses__c>());
                    }
                    this.mapOfCourseKeyVsCourseObj.get(key).put(objCourse.id,objCourse);                     
                }
            }
        }
        return mapOfCourseKeyVsCourseObj;
    }
    public Map<String,Set<String>> getMapOfProgramNamekeyVsCoursesId(){
        if(mapOfCourseKeyVsProgram.isEmpty()){           
             List<nm_Courses__c>  lstcourse = getlstAllProgramCourses(); 
            if(lstcourse.size() > 0){
                for(nm_Courses__c objCourse : lstcourse){
                   // String key = objCourse.Program_Structure__c+'_'+objCourse.Sem__c+'_'+objCourse.Program__c;
                   String key = objCourse.Program__c+'-'+objCourse.Program_Structure__c+'-'+objCourse.Sem__c + '-'+objCourse.ConsumerType__c;
                   system.debug('key ==>'+key);
                   //this.mapOfCourseKeyVsProgram.put(key,objCourse);
                    if(!mapOfCourseKeyVsProgram.containsKey(key))
                    {
                        mapOfCourseKeyVsProgram.put(key,new Set<String>());
                    }
                   mapOfCourseKeyVsProgram.get(key).add(String.valueof(objCourse.Student_Zone_Course_Id__c));
                  // system.debug('mapOfCourseKeyVsProgram---->'+mapOfCourseKeyVsProgram.get(key));
                  
                }
            }
        }
        return mapOfCourseKeyVsProgram;
    }
    public List<nm_Courses__c> getlstAllProgramCourses(){
        if(this.lstAllProgramCourse.isEmpty()){
            String ProgramQuery = getQueryAllFieldSql('nm_Courses__c','IsActive__c =true and Program_Structure__c!=null ',null);
            this.mapOfCourseidVsCourse = new Map<id,nm_Courses__c>((List<nm_Courses__c>)DataBase.query(ProgramQuery));
               system.debug('mapOfCourseidVsCourse -->'+mapOfCourseidVsCourse );
            this.lstAllProgramCourse = mapOfCourseidVsCourse.values() ;
        }       
        return this.lstAllProgramCourse;
    }


   public List<PriceBookEntry> getlstPriceBookEntry (){
        if(this.lstPriceBookEntry.isEmpty()){
          /*  String PriceBookEntry = getQueryAllFieldSql('PriceBookEntry','product2.isActive =:true '
                                         +'and pricebook2.isStandard = false '
                                        + 'and Pricebook2.nmSession_Start_Date__c !=null '
                                        + 'and Pricebook2.nmSession_End_Date__c !=null '
                                        + 'and Pricebook2.IsActive=true ','Pricebook2.id,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c, product2.Name, product2.nm_Program__c, product2.nm_Semester__c');*/
            //   this.mapOfPriceBookEntryIdVsPriceBookEntry = new Map<id,PriceBookEntry>((List<PriceBookEntry>)DataBase.query(PriceBookEntry));
            //   system.debug('mapOfPriceBookEntryIdVsPriceBookEntry -->'+mapOfPriceBookEntryIdVsPriceBookEntry );
           // this.lstPriceBookEntry = mapOfPriceBookEntryIdVsPriceBookEntry.values() ;
             String PriceBookEntry = 'select id, UnitPrice,Pricebook2.id,Pricebook2.Name,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c, product2.Name, product2.nm_Program__c, product2.nm_Semester__c'+
                        +' from PriceBookEntry where product2.isActive = true '+
                        +'and pricebook2.isStandard = false and Pricebook2.nmSession_Start_Date__c !=null '+
                        +'and Pricebook2.nmSession_End_Date__c !=null ' +
                        +'and Pricebook2.IsActive=true ';
              System.debug('Query = '+PriceBookEntry);
              this.lstPriceBookEntry = DataBase.query(PriceBookEntry);

        }       
        return this.lstPriceBookEntry;
    }
    // get Map of PriceBookId vs all prcieBookEntry depending on PriceBookId 
    public Map<String,Map<String,PriceBookEntry>> getMapOfPriceBookIdProductVsPriceBookEntry()
    {
        System.debug('mapPricebook :-'+mapPricebook );
        if(this.mapPricebook.isEmpty()){
        System.debug('mapPricebook  Query :'+mapPricebook );
          //  List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>();
            
                //Fetching price book entry for registration fee product
                /*    lstPriceBookEntry = [select id, UnitPrice,Pricebook2.id,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c, product2.Name, product2.nm_Program__c, product2.nm_Semester__c
                                         from PriceBookEntry 
                                         where product2.isActive =: true 
                                         and pricebook2.isStandard = false
                                         and Pricebook2.nmSession_Start_Date__c !=null
                                         and Pricebook2.nmSession_End_Date__c !=null
                                         and Pricebook2.IsActive=true ];
            */
            lstPriceBookEntry = getlstPriceBookEntry();                                         
           system.debug('lstPriceBookEntry '+lstPriceBookEntry );
            if(lstPriceBookEntry.size()>0)
            {
                for(PriceBookEntry objPriceBook : lstPriceBookEntry)
                {
                    // convert PriceBookID 18 to 15 digit as Price Book Id present on Account is 15 digits
                    String PriceBookId = String.valueOf(objPriceBook.Pricebook2.id).substring(0, 15);
                    //Price BookID is Null in case of Lead convert so take Live price Book to add Product under Opportunity 
                    String LeadConvertNullTagPriceBookId =null;
                    
                    // Price Book Id is not Null in case of Re-Reg
                    if(objPriceBook.product2.nm_Program__c == null)
                    {
                        if(!this.mapPricebook.containsKey(PriceBookId))
                        {
                            this.mapPricebook.put(PriceBookId,new Map<String,PriceBookEntry>());
                           
                        }
                        
                        this.mapPricebook.get(PriceBookId).put(objPriceBook.product2.name,objPriceBook);
                       // this.mapPricebook.get(PriceBookId).put(PriceBookId + '-' + objPriceBook.product2.name,objPriceBook);
                       // system.debug('mapPricebookgetproduct--->'+PriceBookId + '-' + objPriceBook.product2.name);
                    }   
                    else if(objPriceBook.product2.nm_Program__c != null)
                    {  String strKey;
                        if(!this.mapPricebook.containsKey(PriceBookId))
                        {
                            this.mapPricebook.put(PriceBookId,new Map<String,PriceBookEntry>());
                        }
                        if(objPriceBook.product2.nm_Semester__c!=null)
                        {
                            strKey = objPriceBook.product2.nm_Program__c + '-' + objPriceBook.product2.nm_Semester__c;
                        }else
                        {
                            strKey = objPriceBook.product2.name + '-' + objPriceBook.product2.nm_Program__c;
                        }
                        this.mapPricebook.get(PriceBookId).put(strKey,objPriceBook);
                    }
                    
                    // Price Book Id is Null at time of Lead covert to Opportunity so Take Live Price Book 
                    if(objPriceBook.Pricebook2.nmSession_Start_Date__c <=System.Today() && objPriceBook.Pricebook2.nmSession_End_Date__c >= System.Today() && !objPriceBook.Pricebook2.Name.contains('Global') )
                    {
                        if(objPriceBook.product2.nm_Program__c == null)
                        {
                            if(!this.mapPricebook.containsKey(LeadConvertNullTagPriceBookId))
                            {
                                this.mapPricebook.put(LeadConvertNullTagPriceBookId,new Map<String,PriceBookEntry>());
                            }
                           
                            this.mapPricebook.get(LeadConvertNullTagPriceBookId).put(objPriceBook.product2.name,objPriceBook);
                            //system.debug('mapPricebookgetproduct--->'+mapPricebook.get(LeadConvertNullTagPriceBookId));
                        }   
                        else if(objPriceBook.product2.nm_Program__c != null)
                        {
                            string strKey;
                            if(!this.mapPricebook.containsKey(LeadConvertNullTagPriceBookId))
                            {
                                this.mapPricebook.put(LeadConvertNullTagPriceBookId,new Map<String,PriceBookEntry>());
                            }
                            if(objPriceBook.product2.nm_Semester__c!=null)
                            {
                                strKey = objPriceBook.product2.nm_Program__c + '-' + objPriceBook.product2.nm_Semester__c;
                            }else
                            {
                                strKey = objPriceBook.product2.name + '-' + objPriceBook.product2.nm_Program__c;
                            }
                            this.mapPricebook.get(LeadConvertNullTagPriceBookId).put(strKey,objPriceBook);
                        }
                    } 
                    // else if( objPriceBook.Pricebook2.Name.contains('Global')) {
                    //     LeadConvertNullTagPriceBookId = 'INTERNATIONAL_FORM';
                    //     if(objPriceBook.product2.nm_Program__c == null)
                    //     {
                    //         if(!this.mapPricebook.containsKey(LeadConvertNullTagPriceBookId))
                    //         {
                    //             this.mapPricebook.put(LeadConvertNullTagPriceBookId,new Map<String,PriceBookEntry>());
                    //         }
                           
                    //         this.mapPricebook.get(LeadConvertNullTagPriceBookId).put(objPriceBook.product2.name,objPriceBook);
                    //         //system.debug('mapPricebookgetproduct--->'+mapPricebook.get(LeadConvertNullTagPriceBookId));
                    //     }   
                    //     else if(objPriceBook.product2.nm_Program__c != null)
                    //     {
                    //         string strKey;
                    //         if(!this.mapPricebook.containsKey(LeadConvertNullTagPriceBookId))
                    //         {
                    //             this.mapPricebook.put(LeadConvertNullTagPriceBookId,new Map<String,PriceBookEntry>());
                    //         }
                    //         if(objPriceBook.product2.nm_Semester__c!=null)
                    //         {
                    //             strKey = objPriceBook.product2.nm_Program__c + '-' + objPriceBook.product2.nm_Semester__c;
                    //         }else
                    //         {
                    //             strKey = objPriceBook.product2.name + '-' + objPriceBook.product2.nm_Program__c;
                    //         }
                    //         this.mapPricebook.get(LeadConvertNullTagPriceBookId).put(strKey,objPriceBook);
                    //     }
                    // }
                }
            }
        }
        return mapPricebook;
    }

    /**
    * @description : get all the PricebookEntries of the PriceBook Id
    * @author @BK | 09-01-2022 
    * @param priceBookId 
    * @return Map<String, PriceBookEntry> 
    **/
    public Map<String,PriceBookEntry> getMapOfProductVsPriceBookEntry(String priceBookId) {
        Map<String,PriceBookEntry> mapOfPricebook = new Map<String,PriceBookEntry>();
        
        List<PriceBookEntry> lstPriceBookEntry = [SELECT id,UnitPrice,Pricebook2.id,Pricebook2.Name,Pricebook2.nmSession_Start_Date__c,Pricebook2.nmSession_End_Date__c,
            product2.Name,product2.nm_Program__c,product2.nm_Semester__c FROM PriceBookEntry WHERE Pricebook2.id=:priceBookId];
        
        for(PriceBookEntry objPriceBook : lstPriceBookEntry) {
            String programId = objPriceBook.product2.nm_Program__c;
            if(String.isBlank(programId)) {
                mapOfPricebook.put(objPriceBook.product2.name,objPriceBook);
            }
            else {
                String strKey;
                if(objPriceBook.product2.nm_Semester__c != null) {
                    strKey = programId + '-' + objPriceBook.product2.nm_Semester__c;
                } else {
                    strKey = objPriceBook.product2.name + '-' + programId;
                }
                mapOfPricebook.put(strKey,objPriceBook);
            }
        }
        return mapOfPricebook;
    }
    
   /* 
    //get OpportuntiyLineItem related to Opportunity 
    public List<OpportunityLineItem> getOpportunityLineItemEntryRelatedToOpportuntiy(String OppsId)
    {
         List<OpportunityLineItem> lstOpportunityLinIteam = new List<OpportunityLineItem>();
        
         lstOpportunityLinIteam  = [select id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice from OpportunityLineItem where OpportunityId =:OppsId ];
        
        return lstOpportunityLinIteam ;
    }
    
    public List<nm_Payment__c> getOpportunityRelatedPayment(String OppsId)
    {
        List<nm_Payment__c> lstOppsRelatedPayment = new List<nm_Payment__c>();
        
        lstOppsRelatedPayment = [select id,nm_Amount__c,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_TransactionDate__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c =: OppsId ];
        
        return lstOppsRelatedPayment;
    }
    
    // get Opportunity Related Account
    public Account getOpportunityRelatedAccount(String AccountId)
    {
       Account objAccount = [select id,PersonEmail,nm_StudentNo__c,nm_DefencePersonnel__c,PersonMobilePhone,Is_Lateral__c,nm_DocumentSubmittedDate__c,nm_StudentStatus__c,nm_Tagged_Pricebook__c from Account where id =: AccountId ];
        return objAccount;
    }*/
    public decimal TotalNumberOfSubject(Integer sem, String programStructure , String programId ,String liveLecturesType,String courseList,String consumerType  )
    {
        decimal nosubj=0;
      //  decimal sem;
        Set<String> setcourseId = new Set<String>();
        List<String> lstCourseList = new List<String>();
        Map<String,Set<String>> mapOfCourseKeyVsProgram1 = getMapOfProgramNamekeyVsCoursesId();
        List<nm_Courses__c>  lstCourseallList = new  List<nm_Courses__c>  ();
        
        String keyPa = programId+'-'+programStructure+'-'+sem +'-'+consumerType;
        String keyPa1 = programId+'-'+programStructure+'-'+(sem+1) +'-'+consumerType;
        String keyPa2 = programId+'-'+programStructure+'-'+(sem+2) +'-'+consumerType;
        String keyPa3 = programId+'-'+programStructure+'-'+(sem+3) +'-'+consumerType;
        if(!IsNullOrEmpty(liveLecturesType) && liveLecturesType=='Custom')
        {                
            Set<String> setofCourse = new Set<String>();
            nosubj=0; 
                if(courseList!=null && courseList!='')
                {
                    lstCourseList =  courseList.split(',');
                }                    
                if(lstCourseList.size()>0) 
                {
                    setofCourse.addAll(lstCourseList);
                }
                system.debug('SetofCourse'+setofCourse.size());
                nosubj = setofCourse.size()>0?setofCourse.size():0;
                system.debug('nosubj--->'+nosubj);
        }else if(!IsNullOrEmpty(liveLecturesType) && liveLecturesType=='1SemLecturesFee')
        {       Set<String> setcourseId1 = new Set<String>();
              
                nosubj=0;
                       
                system.debug('key--->'+keyPa);
                setcourseId1 = mapOfCourseKeyVsProgram1.containskey(keyPa)?mapOfCourseKeyVsProgram1.get(keyPa):setcourseId1 ;
                system.debug('setcourseId1--->'+setcourseId1);
                nosubj = setcourseId1.size()>0?setcourseId1.size():0;               
                nosubj= nosubj-1;
        }else if(!IsNullOrEmpty(liveLecturesType)  && liveLecturesType.contains('2SemLecturesFee'))
        {
            Set<String> setcourseId2 = new Set<String>();
            Set<String> setcourseId21 = new Set<String>();             
            nosubj=0;            
                  
            if(mapOfCourseKeyVsProgram1.containsKey(keyPa))
            {
                setcourseId21 = mapOfCourseKeyVsProgram1.get(keyPa);
                setcourseId2.addall(setcourseId21);
            }      
            if( mapOfCourseKeyVsProgram1.containsKey(keyPa1))
            { 
                setcourseId21 = mapOfCourseKeyVsProgram1.get(keyPa1);                       
                setcourseId2.addall(setcourseId21);        
            }
                nosubj = setcourseId2.size()>0? setcourseId2.size():0;
                system.debug('nosubj--->'+nosubj);
                system.debug('setcourseId21--->'+setcourseId21);
                nosubj= nosubj-2;
        }else if(!IsNullOrEmpty(liveLecturesType) && liveLecturesType.contains('3SemLecturesFee'))
        {   Set<String> setcourseId3 = new Set<String>();
            Set<String> setcourseId31 = new Set<String>();
            nosubj=0;
           
            if(mapOfCourseKeyVsProgram1.containsKey(keyPa))
            {
                setcourseId31 = mapOfCourseKeyVsProgram1.get(keyPa);
                setcourseId3.addall(setcourseId31);
            }
            if(mapOfCourseKeyVsProgram1.containsKey(keyPa1))
            {
               setcourseId31 = mapOfCourseKeyVsProgram1.get(keyPa1);
                setcourseId3.addall(setcourseId31);
            }
            if(mapOfCourseKeyVsProgram1.containsKey(keyPa2))
            {
               setcourseId31 = mapOfCourseKeyVsProgram1.get(keyPa2);
                setcourseId3.addall(setcourseId31);
            }
           
            nosubj = setcourseId3.size()>0?setcourseId3.size():0;
            system.debug('nosubj--->'+nosubj);
            system.debug('setcourseId3--->'+setcourseId3);
            nosubj = nosubj-3;
        }else if(!IsNullOrEmpty(liveLecturesType) && liveLecturesType.contains('4SemLecturesFee'))
        {   Set<String> setcourseId4 = new Set<String>();
            Set<String> setcourseId41 = new Set<String>();
            system.debug('setcourseId4--->'+setcourseId4);
            nosubj=0;
          
            if(mapOfCourseKeyVsProgram1.containsKey(keyPa))
            {
                setcourseId41 = mapOfCourseKeyVsProgram1.get(keyPa);
                setcourseId4.addall(setcourseId41);
            }
            if( mapOfCourseKeyVsProgram1.containsKey(keyPa1))
            {
                setcourseId41 = mapOfCourseKeyVsProgram1.get(keyPa1);
                setcourseId4.addall(setcourseId41);
            }
            if(mapOfCourseKeyVsProgram1.containsKey(keyPa2))
            {
                setcourseId41 = mapOfCourseKeyVsProgram1.get(keyPa2);
                setcourseId4.addall(setcourseId41);
            }
            if(mapOfCourseKeyVsProgram1.containsKey(keyPa3))
            {
               setcourseId41 = mapOfCourseKeyVsProgram1.get(keyPa3);
               setcourseId4.addall(setcourseId41);
            }

            nosubj = setcourseId4.size()>0 ?setcourseId4.size():0;
            system.debug('nosubj--->'+nosubj);
            system.debug('setcourseId4--->'+setcourseId4);
            nosubj= nosubj-4;
        }
        return nosubj;
            
    }
    //get Map of Opportunity Is vs OpportuntiyLineItem  
    public Map<String,List<OpportunityLineItem>> getOpportunityLineItemEntryRelatedToOpportuntiy(set<String> setOfOppsId)
    {
        Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = new Map<String,List<OpportunityLineItem>>();
        
        List<OpportunityLineItem> lstOpportunityLinIteam  = [select id,PricebookEntry.Product2Id,OpportunityId ,ActualSalePrice__c,Product_Name__c,PriceBookEntryId ,UnitPrice,ListPrice,Quantity,TotalPrice,ProgramName2__c,PricebookEntry.Name from OpportunityLineItem where OpportunityId !=null and OpportunityId In : setOfOppsId];
        
        if(lstOpportunityLinIteam.size()>0)
        {
            for(OpportunityLineItem objLineItem : lstOpportunityLinIteam)
            {
                if(!mapOfOppsIdVsOpportunityLineItem.containsKey(objLineItem.OpportunityId))
                {
                    mapOfOppsIdVsOpportunityLineItem.put(objLineItem.OpportunityId,new List<OpportunityLineItem>());
                }
                mapOfOppsIdVsOpportunityLineItem.get(objLineItem.OpportunityId).add(objLineItem);
            }
        }
        return mapOfOppsIdVsOpportunityLineItem ;
    }
    public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }
    // get Map of Opportunity Id Vs Payments 
    public Map<String,List<nm_Payment__c>> getOpportunityRelatedPayment(set<String> setOfOppsId)
    {
        System.debug('mapOfOppsIdVsPayments :-'+mapOfOppsIdVsPayments );
        if(this.mapOfOppsIdVsPayments.isEmpty() || (setOfOppsId.size() == 1 && !this.mapOfOppsIdVsPayments.containsKey(new List<String>(setOfOppsId)[0]))){
            System.debug('mapOfOppsIdVsPayments Query:-'+mapOfOppsIdVsPayments );
            List<nm_Payment__c> lstOppsRelatedPayment = [select id,nm_Amount__c,nm_OpportunityNew__c,nm_OpportunityNew__r.IC__c,IC_Name__c,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_TransactionDate__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_PaymentType__c,payment_Transaction_Mode__c from nm_Payment__c where nm_OpportunityNew__c In :setOfOppsId and nm_PaymentStatus__c !='Transaction Failed'];
            
            if(lstOppsRelatedPayment.size()>0)
            {
                for(nm_Payment__c objPayment : lstOppsRelatedPayment)
                {
                    if(!this.mapOfOppsIdVsPayments.containsKey(objPayment.nm_OpportunityNew__c))
                    {
                        this.mapOfOppsIdVsPayments.put(objPayment.nm_OpportunityNew__c,new List<nm_Payment__c>());
                    }
                    
                    this.mapOfOppsIdVsPayments.get(objPayment.nm_OpportunityNew__c).add(objPayment);
                }
            }
        }
        return mapOfOppsIdVsPayments;
    }
    
    // get Map of AccountId and Account Details
    public Map<Id,Account> getOpportunityRelatedAccount(set<String> setOfAccountId)
    {
        System.debug('mapOfAccountIdVsAccount :-'+mapOfAccountIdVsAccount );
        Set<String> v1 = setOfAccountId;
        boolean checkforAcc =false; 
        if(setOfAccountId.size()>0 && !this.mapOfAccountIdVsAccount.isEmpty())
        {
          for(String stid :setOfAccountId) 
          {
              if(!this.mapOfAccountIdVsAccount.containsKey(stid) )
              {
                  checkforAcc = true;
              }
          }
        }
    
        if(this.mapOfAccountIdVsAccount.isEmpty() || checkforAcc){
            System.debug('mapOfAccountIdVsAccount Query:-'+mapOfAccountIdVsAccount );
            // List<Account> lstAccount = [select id,Program_Type__c,Days_Since_For_Admission_Payment__c,DaysSinceForInitialPayment__c,PersonEmail,OldStudentForExecutive__c,nm_StudentNo__c,nm_DefencePersonnel__c,nm_IsEmailVerified__c,Is_Mobile_Verified__c ,PersonMobilePhone,Is_Lateral__c,nm_DocumentSubmittedDate__c,nm_StudentStatus__c,nm_Tagged_Pricebook__c,nmStudent_Program__c,nm_ChooseaProgram__c from Account where id in :setOfAccountId];
            // if(lstAccount.size()>0)
            // {
            //     for(Account objAccount : lstAccount)
            //     {
            //         this.mapOfAccountIdVsAccount.put(objAccount.id,objAccount);
            //     }
            // }
                    this.mapOfAccountIdVsAccount = new Map<id,Account>([select id,Program_Type__c,Days_Since_For_Admission_Payment__c,DaysSinceForInitialPayment__c,PersonEmail,OldStudentForExecutive__c,nm_StudentNo__c,nm_DefencePersonnel__c,nm_IsEmailVerified__c,Is_Mobile_Verified__c ,PersonMobilePhone,Is_Lateral__c,nm_DocumentSubmittedDate__c,nm_StudentStatus__c,nm_Tagged_Pricebook__c,nmStudent_Program__c,nm_ChooseaProgram__c from Account where id in :setOfAccountId]);
        }
        return mapOfAccountIdVsAccount;
    }
    
    //Method get Called from nmiCPaymenttriggerHandler
    // get Map of OppsId vs Opportunity
    // public Map<String,List<Opportunity>> getOpportunity()
    // {
    //     Map<String,List<Opportunity>> mapOfOppsIdVsOpp = new Map<String,List<Opportunity>>();
    //      List<Opportunity> lstOpps = [select nm_Fee_Type__c,Account.nm_Tagged_Pricebook__c, nm_Semester__c, StageName,CloseDate, Id,AccountId, nm_DemandDraftNumber__c,nm_TransactionID__c,Account.Name,Account.Account_Confirm_Date__c,
    //                                     Account.nm_StudentStatus__c,Account.nm_StudentNo__c, Account.nm_Centers__c,nm_Drive_Name__c,nm_Session__c,nm_Year__c,
    //                                     (select Product_Name__c, UnitPrice from OpportunityLineItems where Product_Name__c LIKE 'Semester%') 
    //                                     from Opportunity where processed__c = FALSE and StageName = 'Closed Won'];
            
    //     if(lstOpps.size()>0)
    //     {
    //         for(Opportunity objOpps :lstOpps)
    //         {
    //             if(!mapOfOppsIdVsOpp.containsKey(objOpps.id))
    //             {
    //                 mapOfOppsIdVsOpp.put(objOpps.id,new List<Opportunity>());
    //             }
    //             mapOfOppsIdVsOpp.get(objOpps.id).add(objOpps);
    //         }
    //     }
    //     return mapOfOppsIdVsOpp;
    // }
    
    //get Total Amount received 
    public decimal getTotalAmountReceived(String OppsId, Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments)
    {
        //Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment();
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(OppsId) !=null ?  mapOfOppsIdVsPayments.get(OppsId) : new List<nm_Payment__c>();
        decimal TotalAmountReceived = 0.0;
        
        for(nm_Payment__c objPayment : lstOppsRelatedPayment)
        {
            if((objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Waived Off'|| objPayment.nm_PaymentStatus__c =='Process Charge Back' ) &&  objPayment.nm_Amount__c != null)
            {
                TotalAmountReceived = TotalAmountReceived + objPayment.nm_Amount__c;
            }
        }
        System.debug('Total Amount Received--->'+TotalAmountReceived);
        return TotalAmountReceived;
    }
    //get Total Refunded Amount 
   /* public decimal getTotalAmountRefund(String OppsId,Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments)
    {
        
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(OppsId) !=null ?  mapOfOppsIdVsPayments.get(OppsId) : new List<nm_Payment__c>();
        decimal TotalAmountRefund = 0.0;
        System.debug('lst Payment in Approved --->'+lstOppsRelatedPayment);
        for(nm_Payment__c objPayment : lstOppsRelatedPayment)
        {
            if(objPayment.nm_PaymentStatus__c =='Process Charge Back' )
            {
                TotalAmountRefund  = TotalAmountRefund + objPayment.nm_Amount__c;
            }
        }
        System.debug('TotalAmountRefund--->'+TotalAmountRefund );
        return TotalAmountRefund ;
    }*/
     public decimal getTotalAmountRefund(String OppsId,Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments)
    {
        double  Refundamount;
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(OppsId) !=null ?  mapOfOppsIdVsPayments.get(OppsId) : new List<nm_Payment__c>();
        Refundamount = (Decimal)[select sum(Total_amount_to_refund__c)refund from nmRefund_Payment__c where Opportunity__c=:OppsId ][0].get('refund');
        decimal TotalAmountRefund = 0.0;
        System.debug('lst Payment in Approved --->'+lstOppsRelatedPayment);
        for(nm_Payment__c objPayment : lstOppsRelatedPayment)
        {
            if(objPayment.nm_PaymentStatus__c =='Process Charge Back' )
            {
                TotalAmountRefund  = TotalAmountRefund + objPayment.nm_Amount__c;
            }
        }
        system.debug('Refundamount---->'+Refundamount);
        if(Refundamount>0)
        {
        TotalAmountRefund = TotalAmountRefund + Refundamount;
        }
        System.debug('TotalAmountRefund--->'+TotalAmountRefund );
        return TotalAmountRefund ;
    }


    /**
    * @description 
    * @author @BK | 15-01-2025 
    * @param set<String> setOfOppsId 
    * @param Map<String List<nm_Payment__c>> mapOfOppsIdVsPayments 
    * @return Map<String, Decimal> 
    **/
    public Map<String,Decimal> getTotalAmountRefunded(set<String> setOfOppsId, Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments) {
        Map<String,Decimal> mapOfOppIdVsRefundAmount = new Map<String,Decimal>();

        AggregateResult[] groupedResults = [SELECT Opportunity__c, SUM(Total_amount_to_refund__c)refund
                                            FROM nmRefund_Payment__c
                                            WHERE Opportunity__c IN :setOfOppsId
                                            GROUP BY Opportunity__c];

        for (AggregateResult ar : groupedResults)  {
            String oppsId = (String)ar.get('Opportunity__c');
            List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.containsKey(oppsId) ? mapOfOppsIdVsPayments.get(oppsId) : new List<nm_Payment__c>();
            Decimal refundAmount = (Decimal)ar.get('refund');
            Decimal totalAmountRefund = 0;
            System.debug('lst Payment in Approved --->'+lstOppsRelatedPayment);
            for(nm_Payment__c objPayment : lstOppsRelatedPayment) {
                if(objPayment.nm_PaymentStatus__c == 'Process Charge Back') {
                    totalAmountRefund  = totalAmountRefund + objPayment.nm_Amount__c;
                }
            }
            System.debug('Refundamount---->'+refundAmount);
            if(refundAmount > 0) {
                totalAmountRefund = totalAmountRefund + refundAmount;
            }
            System.debug('TotalAmountRefund--->'+totalAmountRefund );
            mapOfOppIdVsRefundAmount.put(oppsId,totalAmountRefund);
        }

        return mapOfOppIdVsRefundAmount;
    }

    //get Total Approved Amount 
    public decimal getTotalApprovedAmount(String OppsId,Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments)
    {
        //Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment();
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(OppsId) !=null ?  mapOfOppsIdVsPayments.get(OppsId) : new List<nm_Payment__c>();
        decimal TotalApprovedAmount = 0.0;
        System.debug('lst Payment in Approved --->'+lstOppsRelatedPayment);
        for(nm_Payment__c objPayment : lstOppsRelatedPayment)
        {
            if((objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Waived Off' || objPayment.nm_PaymentStatus__c =='Process Charge Back') && objPayment.nm_Amount__c != null)
            {
                TotalApprovedAmount  = TotalApprovedAmount + objPayment.nm_Amount__c;
            }
        }
        System.debug('Total Amount Approved--->'+TotalApprovedAmount );
        return TotalApprovedAmount ;
    }
    //Total amount WaivedOFF
    public decimal getTotalAmountWaivedOff(String OppsId,Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments)
    {
        
         //Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment();
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(OppsId) !=null ?  mapOfOppsIdVsPayments.get(OppsId) : new List<nm_Payment__c>();
        decimal TotalWaivedOffAmount = 0.0;
        System.debug('lst Payment in Approved --->'+lstOppsRelatedPayment);
        for(nm_Payment__c objPayment : lstOppsRelatedPayment)
        {
            if(objPayment.nm_PaymentStatus__c =='Waived Off'  )
            {
                TotalWaivedOffAmount  = TotalWaivedOffAmount + objPayment.nm_Amount__c;
            }
        }
        System.debug('Total Amount Approved--->'+TotalWaivedOffAmount );
        return TotalWaivedOffAmount ;
    }
    
    // Method get Called from nmLogin_New class
    // get Total Pending Amount to Pay 
      public decimal getPendingAmount(String OppsId)
    {
      /*  set<String> setOfOppsId = new set<String>{OppsId};
        Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
        List<OpportunityLineItem> lstOpportunityLineIteam = mapOfOppsIdVsOpportunityLineItem.get(OppsId) !=null ?  mapOfOppsIdVsOpportunityLineItem.get(OppsId) : new List<OpportunityLineItem>();
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId );
        decimal TotalAmountReceived = getTotalAmountReceived(OppsId,mapOfOppsIdVsPayments);
        // query PriceBook
        Opportunity objOpps = [select id,Account.nm_Tagged_Pricebook__c,nm_Fee_Type__c,Program_Name__c,Account.nm_DefencePersonnel__c,Account.nmStudent_Program__c from Opportunity where id=:OppsId];
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objOpps.Account.nm_Tagged_Pricebook__c );
        
        decimal TotalPendingAmount = 0.0;
        decimal TotalProductAmount = 0.0;
        decimal SemesterAmount = 0.0;
        decimal serviceTax = 0.0;
        if(lstOpportunityLineIteam.size()>0)
        {
            for(OpportunityLineItem objLineIteam : lstOpportunityLineIteam )
            {
                if(objLineIteam.Product_Name__c == 'Registration Fee')
                {
                    TotalProductAmount = TotalProductAmount + objLineIteam.UnitPrice; 
                }else if(objLineIteam.Product_Name__c.contains('Semester'))
                {
                    SemesterAmount = SemesterAmount + objLineIteam.UnitPrice;// for Semester Fees 
                }else if(objLineIteam.Product_Name__c.contains('Certificate Service Tax'))
                {
                    serviceTax = serviceTax + objLineIteam.UnitPrice;// for Service Tax
                }else{
                    TotalProductAmount = TotalProductAmount + objLineIteam.UnitPrice; // for Ic ,Program Changes fees
                }
            }
        }
        
        //calculate Product Price Bases upon Feetype
        if(objOpps.nm_Fee_Type__c !=null && objOpps.nm_Fee_Type__c !='')
        {
            if(objOpps.nm_Fee_Type__c =='PGAllSemFee')
            {
                TotalProductAmount = TotalProductAmount + getProductPrice(objOpps.Account.nm_DefencePersonnel__c,mapPricebook.get('PG_All_Sem').UnitPrice);
                
            }else if(objOpps.nm_Fee_Type__c == 'AnnualFee')
            {
                // checking Student Program as Annaul Fee Option is available for Advance Certificate Program also with different Product Price 
                if(objOpps.Program_Name__c.startswith('AC'))
                {
                    TotalProductAmount = TotalProductAmount + getProductPrice(objOpps.Account.nm_DefencePersonnel__c,mapPricebook.get('Certificate_Annual').UnitPrice) + serviceTax *2 ; // taking serivce Tax both sem while making annual payment 
                }else
                {
                   TotalProductAmount = TotalProductAmount + getProductPrice(objOpps.Account.nm_DefencePersonnel__c,mapPricebook.get('Annual').UnitPrice);
                } 
                
            }else if(objOpps.nm_Fee_Type__c == 'MultipleSemFee')
            {
                TotalProductAmount = TotalProductAmount + getProductPrice(objOpps.Account.nm_DefencePersonnel__c,mapPricebook.get('Multiple Semester').UnitPrice);
                
            }else if(objOpps.nm_Fee_Type__c.contains('-Considered'))
            {
                TotalProductAmount = TotalProductAmount; // for considered fee typr take zero amount 
            }else
            {
                TotalProductAmount = TotalProductAmount + SemesterAmount;
                //adding service Tax to semester Product
                if(objOpps.Account.nmStudent_Program__c.Contains('Certificate'))
                {
                    TotalProductAmount = TotalProductAmount + serviceTax ; // taking serivce Tax both sem while making annual payment 
                }
            }
        }else{// In some cases fee type is Null so take Semester 
            TotalProductAmount = TotalProductAmount + SemesterAmount;
            //adding service Tax to semester Product
            if(objOpps.Account.nmStudent_Program__c.Contains('Certificate'))
            {
                TotalProductAmount = TotalProductAmount + serviceTax ; // taking serivce Tax both sem while making annual payment 
            }
        }
        
        if(TotalAmountReceived !=null && TotalProductAmount !=null)
        {
            TotalPendingAmount = TotalProductAmount - TotalAmountReceived;
        }
        System.debug('Total Pending Amount----->'+TotalPendingAmount);
        return TotalPendingAmount;*/
          decimal TotalPendingAmount = 0.0;
          Opportunity objOpps = [select id,IC__c,Account.nm_Tagged_Pricebook__c,nm_Fee_Type__c,Program_Name__c,ActualPendingAmount__c,Account.nm_DefencePersonnel__c,Account.nmStudent_Program__c from Opportunity where id=:OppsId];
          TotalPendingAmount = objOpps.ActualPendingAmount__c;
         return TotalPendingAmount;
    }
  
  
    // method added to Handle Defence Student as PGALLSEM,AnnaulSmeFee,MulipleSemFee option made available for them 
    public decimal getProductPrice(String IsDefence, decimal applicableAmount)
    {
        if(IsDefence =='Yes')
        {
            applicableAmount = applicableAmount * 0.8;
        }
        return applicableAmount;
    }
    
    //Method gets Called from nmICChangeTrigerHandler,nmPaymentTriggerHandler
    // Update Opportunity Stage To Pending Payment or Payment Made or Closed or Closed Won Depending On Pending Amount 
    public Opportunity UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(String OppsId,string eventName, String specialEvent, String specialPriorValue)
    {
        System.debug('eventName ==>'+eventName + ' OppsId ==>'+OppsId + ' specialEvent ==> ' + specialEvent + ' specialPriorValue ==> ' + specialPriorValue);
        decimal pendingAmount = 0.0;
        decimal totalAmountReceived =0.0;
        decimal totalAmountApproved =0.0;
        decimal pendingAmountToApproved = 0.0;       
        decimal pendingAdditionalCharge = 0.0; //in order to handle Additional Pending Payment 
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        boolean registrationPaymentDone = false;
        boolean admissionPaymentDone = false;
        boolean InstallmentPaymentDone = false;
        boolean DownPaymentDone = false;
        String programtype;
        String chooseprogram;
        String interviewstatus;
        List<String> AIComponent_opp;
        List<String> AIComponent_pro;
        boolean MBAClosewonCheck;
        // get Opportunity Related Payment 
        set<String> setOfOppsId = new set<String>{OppsId};
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId);
         List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(OppsId) !=null ?  mapOfOppsIdVsPayments.get(OppsId) : new List<nm_Payment__c>();
         
         //opportunity lineitem required to get all pending fees
            Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );     
            
        
        // checking Payment Type as Opportunity Stage to be Registration Done in case of Only Registration Fee paid and Should be Pending Payment In case of Installment or Admission Depending upon Product Price 
       if(lstOppsRelatedPayment.size()>0)
       {
            for(nm_Payment__c objPayment : lstOppsRelatedPayment)
            {
                if(objPayment.nm_PaymentType__c =='Additional Charge' && objPayment.nm_PaymentStatus__c =='Pending Extra Fees')
                {
                    pendingAdditionalCharge = objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c =='Admission' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made'))
                {
                    admissionPaymentDone = true;
                }else if((objPayment.nm_PaymentType__c == 'Installment' || objPayment.nm_PaymentType__c == 'Initial Payment') && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made'))
                {
                    InstallmentPaymentDone = true;
                }
                else if((objPayment.nm_PaymentType__c!= null && objPayment.nm_PaymentType__c.contains('DownPayment') )&& (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made'))
                {
                    DownPaymentDone =true;
                }
                else if(objPayment.nm_PaymentType__c == 'Registration' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made'))
                {
                    registrationPaymentDone = true;
                }
            }
         }   
       //get Opportunity Deatils 
        Opportunity objOpp = [select id,Account.AI_Component__c,isLiveLecture__c,IsTerm__c,nm_SelfLearningMaterial__c,Account.nm_Nationality__c,Dispatch_Order_For_Student__c,nm_Program__r.AI_Component__c,nm_Session__c,nm_Year__c,Down_Payment_Made__c,IC__c,nm_Future_Sems_Created__c,late_fee__c,CareerServiceFee__c,RegistrationFee__c,ActualAmountReceived__c,ConsumerType__c,Sem__c,Program_Structure__c,LiveLecturesType__c,CourseList__c,WaivedOffAmount__c,E_S_charge__c,Account.nm_Centers__c,ShareApplicable__c ,AdditionalAmountRecieved__c,Total_Amount_Received__c,Account.nm_Tagged_Pricebook__c,Career_Service__c,Account.Name,Choose_a_Program__c,ChooseProgram__c,ActualPendingAmount__c,Pending_For__c,Actual_Amount__c,
        Account.nm_ChooseaProgram__c,CloseDate,Processed__c,Accountid,nm_StudentProgram__c,nm_Payment_Approved__c,nm_Category__c,Account.nm_IsEmailVerified__c,Specialisation__c,
                             nm_StudentProgram__r.nm_Program__c,Term_Cleared__c,nm_Semester__c,nm_Program__c,nm_Fee_Type__c ,Account.Is_Mobile_Verified__c,Account.nm_Domicile__c,Account.DEBID__c,Account.Program_Type__c,Account.Interview_Status__c,
                             Is_Re_Registration_Payment__c,Student_Number__c,StageName,Coursera__c,Account.is_Video_Call_Verified__c, Account.is_Deb_verified__c,
                             Account.nm_StudentStatus__c,(select id, nm_Amount__c from Opportunities__r 
                             where (nm_PaymentStatus__c='Payment Approved' OR nm_PaymentStatus__c='Waived Off' or nm_PaymentStatus__c = 'Payment Made')) 
                             from Opportunity where id =:OppsId];
        
        // Insert Late Fee Product if Admission Payment is Approved during Late Fee Slab and Admission Payment Transcation Date is with in Late Fee Slab and  if Product is not inserted then Insert Product  
        List<OpportunityLineItem> lstOpportunitylineItem = mapOfOppsIdVsOpportunityLineItem.containskey(objOpp.id) ?  mapOfOppsIdVsOpportunityLineItem.get(objOpp.id) : new List<OpportunityLineItem>();
        
        chooseprogram = objOpp.ChooseProgram__c;
        programtype = objOpp.Account.Program_Type__c;
        interviewstatus = objOpp.Account.Interview_Status__c!=null && objOpp.Account.Interview_Status__c!=''?objOpp.Account.Interview_Status__c:'null';
       AIComponent_opp = objOpp.Account.AI_Component__c!=null && objOpp.Account.AI_Component__c!='' ?objOpp.Account.AI_Component__c.split(';'):null; 
        //  marks = Integer.valueof(objOpp.Account.Total_Score__c);  
        AIComponent_pro =  objOpp.nm_Program__r.AI_Component__c!=null &&  objOpp.nm_Program__r.AI_Component__c!='' ?objOpp.nm_Program__r.AI_Component__c.split(';'):null;
        MBAClosewonCheck = MBAClosewonCheck(chooseprogram,programtype,interviewstatus,AIComponent_opp,AIComponent_pro);
        Boolean isTermCleared = isLastOpportunityCleared(objOpp);
        Boolean isOpportunityCloseWon = isOpportunityOfLiveLectureCloseWon(objOpp, specialEvent, specialPriorValue);
       system.debug('MBAClosewonCheck--->'+MBAClosewonCheck);
       system.debug('isOpportunityCloseWon--->'+isOpportunityCloseWon);
        decimal LateFeeAmount = 0;
        if(!objOpp.Processed__c) {
            if (objOpp.Is_Re_Registration_Payment__c || (!objOpp.Is_Re_Registration_Payment__c && String.isBlank(objOpp.Student_Number__c))) {
                LateFeeAmount = CreateLateFeeProduct(objOpp,eventName);
            }
        }
        if(objOpp.Career_Service__c!='')
        {
            CareerServiceProduct(lstOpportunitylineItem ,objOpp);
        }
        if(objOpp.Coursera__c) {
            CourseraProduct(lstOpportunitylineItem, objOpp, false);
        } else {
            DeleteCourseraProduct(lstOpportunitylineItem, objOpp);
        }
       // pendingAmount = getPendingAmount(OppsId);
        totalAmountReceived = getTotalAmountReceived(OppsId,mapOfOppsIdVsPayments);
        totalAmountApproved = getTotalApprovedAmount(OppsId,mapOfOppsIdVsPayments);
        
        if(LateFeeAmount >0)
        {
            pendingAmount = LateFeeAmount ;
        }
        else
        {
            pendingAmount = objOpp.Actual_Amount__c - totalAmountReceived ;
        }
        
        pendingAmountToApproved = totalAmountReceived - totalAmountApproved ;
        system.debug('StageName-->'+pendingAmount );
        System.debug('pendingAmountToApproved -->'+pendingAmountToApproved);
        Boolean isDebVerified =  ((objOpp.Account.nm_Nationality__c != 'Indian' && objOpp.Account.nm_Nationality__c != 'India')) || (objOpp.Account.is_Deb_verified__c && String.isNotBlank(objOpp.Account.DEBID__c));
        System.debug('isDebMandatory -->'+isDebVerified);
        // pending Amount is '-' in Additional Charger Case in such cases after Additional Charger Payment Approved then Update Opportunity Stage to Closed or Closed Won depending On Account Stage
        if((
            (objOpp.Account.nm_StudentStatus__c=='Admission form & documents Approved'  || objOpp.Account.nm_StudentStatus__c=='Admission Form & Documents Provisional') && pendingAmount<=0  && pendingAmountToApproved ==0 && pendingAdditionalCharge==0 && objOpp.Account.nm_IsEmailVerified__c && objOpp.Account.Is_Mobile_Verified__c && admissionPaymentDone && MBAClosewonCheck && objOpp.Account.is_Video_Call_Verified__c && isDebVerified) 
            || 
            (objOpp.Account.nm_StudentStatus__c=='Confirmed' && pendingAmount <=0 && objOpp.Is_Re_Registration_Payment__c && pendingAdditionalCharge==0 && pendingAmountToApproved ==0 && MBAClosewonCheck)
            ||
            (objOpp.Account.nm_StudentStatus__c=='Confirmed' && pendingAmount <=0  && pendingAmountToApproved ==0 && pendingAdditionalCharge==0 && MBAClosewonCheck))// newly added for update opps stage to closed won if IC/Program chnage /Feetype change after Opps closed won then after approving IC/Program/Feetype payment update Opps to Closed Won
        {
            system.debug('checkRecursive.isCheckRecurssiveforClosedandClosedOwn --> ' + checkRecursive.isCheckRecurssiveforClosedandClosedOwn);
            if(checkRecursive.isCheckRecurssiveforClosedandClosedOwn)
            {
             checkRecursive.isCheckRecurssiveforClosedandClosedOwn=false;
            }
            else
            {
             return objOpp;
            }
            objOpp.nm_Payment_Approved__c = true;
            if ((objOpp.Specialisation__c == 'M.Sc. (AI)' || 
                objOpp.Specialisation__c == 'M.Sc. (AI & ML Ops)') && objOpp.nm_Semester__c == '5' && !isTermCleared) {
                    objOpp.StageName='Closed Won - Re-registration Pending';
            } else {
                if(isOpportunityCloseWon) {
                objOpp.StageName='Closed Won';
            }
                
            }
            objOpp.CloseDate = System.Today();
            system.debug('Closed Won');
            boolean ICProgramChange = ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objOpp);
            if(objOpp.LiveLecturesType__c!='' && objOpp.LiveLecturesType__c!=null  && objOpp.LiveLecturesType__c!='Custom')
            {
                objOpp = SetLiveLecturesValue(objOpp);
            }
            if(!ICProgramChange || objOpp.ActualPendingAmount__c==0){
                lstOpportunityToUpdate.add(objOpp);
            }
            
        }else if(registrationPaymentDone && !DownPaymentDone && !InstallmentPaymentDone  && !admissionPaymentDone && pendingAdditionalCharge==0)
        {
           // update Opportunity Stage to Registrtaion Done if only Registration Payment is Made
            objOpp.StageName = 'Registration Done';
            lstOpportunityToUpdate.add(objOpp);
        }
      
        else if(((pendingAmount !=null && pendingAmount >0) || pendingAdditionalCharge >0) && (!objOpp.StageName.equalsIgnorecase('Re-Registration Pending') && objOpp.StageName!='Closed Won - Re-registration Pending' ))// update Opportunity Stage to Pending Payment when Additional Charge Payment is Inserted Manually
        {
            if(DownPaymentDone)
            {
                 objOpp.StageName = 'Pending Payment - Loan';
            }
            else if(InstallmentPaymentDone)
            {
                 objOpp.StageName = 'Pending Payment - Instalment';
            }else
            {
                objOpp.StageName = 'Pending Payment';
            }
            System.debug('objOpp.nm_Future_Sems_Created__c--->'+objOpp.nm_Future_Sems_Created__c);
            System.debug('objOpp.StageName--->'+objOpp.StageName);
            System.debug('objOpp.nm_Fee_Type__c--->'+ objOpp.nm_Fee_Type__c);
            if(objOpp.nm_Future_Sems_Created__c == true  && objOpp.StageName.contains('Pending Payment') && !objOpp.nm_Fee_Type__c.contains('Considered') )
            {
                list<Opportunity> lstoppsToDelete = new list<Opportunity>();
                Set<String> oppsToDeleteId = new Set<String>();
                List<nm_Payment__c> lstpaymentToDelete = new List<nm_Payment__c>();

                List<Opportunity> lstCloseWonRegPending = [SELECT id FROM Opportunity WHERE AccountID = :objOpp.AccountId AND nm_Semester__c > :objOpp.nm_Semester__c  AND StageName = 'Closed Won - Re-registration Pending' And Total_Amount_Received__c <= 0 ];
                if (lstCloseWonRegPending.size() > 0 ) {
                    lstoppsToDelete.addAll(lstCloseWonRegPending);
                    for(Opportunity oppp : lstoppsToDelete) {
                        oppsToDeleteId.add(oppp.id);
                    }
                    if (oppsToDeleteId.size() > 0) {
                        lstpaymentToDelete = [SELECT Id,nm_Amount__c FROM nm_Payment__c WHERE nm_OpportunityNew__c IN :oppsToDeleteId  and nm_Amount__c=0];         
                    }         
                    if (lstoppsToDelete.size() > 0) {
                        delete lstoppsToDelete;
                    }
                    if (lstpaymentToDelete.size() > 0) {
                        delete lstpaymentToDelete;
                    }
                     objOpp.nm_Future_Sems_Created__c = false;                   
                }
            }
            system.debug('StageName-->'+objOpp.StageName);
           lstOpportunityToUpdate.add(objOpp);
        }else if(pendingAmount <=0 && pendingAmountToApproved ==0 && pendingAdditionalCharge==0) 
        {
            objOpp.StageName='Closed';
          //  objOpp.Pending_For__c = '';
            lstOpportunityToUpdate.add(objOpp);
        } else if(pendingAmountToApproved > 0 && pendingAdditionalCharge==0)
        {
            objOpp.StageName='Payment Made';
            System.debug('objOpp.StageName-->'+objOpp.StageName);
            lstOpportunityToUpdate.add(objOpp);
        }
     
        if(lstOpportunityToUpdate.size()>0)
        {
            system.debug('update opps loop');
            update lstOpportunityToUpdate;
        }
        
        return objOpp;
    }

    public Boolean isLastOpportunityCleared(Opportunity objOpp) {
        String Sem = String.valueOf(Integer.valueOf(objOpp.nm_Semester__c) - 1);
        if ((objOpp.Specialisation__c == 'M.Sc. (AI)' ||objOpp.Specialisation__c == 'M.Sc. (AI & ML Ops)') && sem == '4') {
            List<Opportunity> lastSemOpp = [SELECT Id, Term_Cleared__c FROM Opportunity WHERE AccountId = :objOpp.AccountId AND nm_Semester__c = :sem LIMIT 1];
            if(lastSemOpp.size() > 0 ) {
                if(String.isNotBlank(lastSemOpp[0].Term_Cleared__c) && lastSemOpp[0].Term_Cleared__c == 'No' ) {
                    return false;
                }
            }
        }
        return true;
    }

    public Boolean isOpportunityOfLiveLectureCloseWon(Opportunity objOpp, String specialEvent, String specialPriorValue) {
        if(objOpp.isLiveLecture__c && !objOpp.IsTerm__c && objOpp.Is_Re_Registration_Payment__c && String.isNotBlank(specialEvent) && specialEvent == 'LiveLectureTypeChange'  ) {
            if(String.isNotBlank(objOpp.nm_SelfLearningMaterial__c) && specialPriorValue != 'Closed Won - Re-registration Pending' ) {
                return true;
            } else {
                return false;
            }
        }
        return true;
    }
    
    public Opportunity SetLiveLecturesValue(Opportunity objOpp)
    {
        system.debug('objOpp.LiveLecturesType__c--->'+objOpp.LiveLecturesType__c);
        if(objOpp.LiveLecturesType__c!='' && (objOpp.LiveLecturesType__c=='1SemLecturesFee'
            || objOpp.LiveLecturesType__c.contains('2SemLecturesFee')
            || objOpp.LiveLecturesType__c.contains('3SemLecturesFee')  
            || objOpp.LiveLecturesType__c.contains('4SemLecturesFee')))
        {
            String collegeString = '';
            Set<String> setcourseId = new Set<String>();
            Map<String,Set<String>> mapOfCourseKeyVsProgram = getMapOfProgramNamekeyVsCoursesId();
            String coursekey = objOpp.nm_Program__c+'-'+objOpp.Program_Structure__c+'-'+objOpp.Sem__c+'-'+objOpp.ConsumerType__c;
            System.debug('coursekey---->'+ coursekey);
            system.debug('Mapcoursekey---->'+ mapOfCourseKeyVsProgram.get(coursekey));
            setcourseId = mapOfCourseKeyVsProgram.get(coursekey);
            system.debug('setcourseId--->'+ setcourseId);
            if(setcourseId.size()>0){
                for(String s:setcourseId) {
                    collegeString += (collegeString==''?'':',')+s;
                }
                objOpp.CourseList__c = collegeString;

            }
        }
        return objOpp;
    }
    
    //Creating opportunity line item records
    public OpportunityLineItem CreateLineIteam(String TypeOfProduct,Map<String,PriceBookEntry> mapPricebook,String OppsId)
    { 
        OpportunityLineItem objLineItem = new OpportunityLineItem();
        objLineItem.OpportunityId = OppsId;
        objLineItem.PriceBookEntryId = mapPricebook.get(TypeOfProduct).id;
        objLineItem.Quantity = 1.00;
        objLineItem.UnitPrice = mapPricebook.get(TypeOfProduct).UnitPrice;
        objLineItem.ActualSalePrice__c = mapPricebook.get(TypeOfProduct).UnitPrice;
        return objLineItem;
    }
    public OpportunityLineItem CreateLineIteamObject(String TypeOfProduct,Map<String,PriceBookEntry> mapPricebook,String OppsId)
    { 
        OpportunityLineItem objLineItem = new OpportunityLineItem();
        objLineItem.OpportunityId = OppsId;
        objLineItem.PriceBookEntryId = mapPricebook.get(TypeOfProduct).id;
        objLineItem.Quantity = 1.00;
        return objLineItem;
    }
    public void CreateSemesterLineIteam(Opportunity objOpportunity,Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook,Map<Id,Account> mapOfOppsVsAccount,Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem)
    {
        //get Tag PriceBookId from Account 
        Account objAccount = mapOfOppsVsAccount.get(objOpportunity.AccountId);
        system.debug('objAccount'+objAccount );
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        List<OpportunityLineItem> lstOpportunityLineIteam = mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id) !=null ?  mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id) :new List<OpportunityLineItem>();
        boolean IsRegistartionFeeProductAdded = false;
        boolean servicetaxProductAlreadyInserted  = false;
        //System.debug('Account Tag Price Book---->'+mapPricebookIdVsPriceBook.ContainsKey(objAccount.nm_Tagged_Pricebook__c));
        // Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c);
        String priceBookRef = String.isBlank(objAccount.nm_Tagged_Pricebook__c) ? objOpportunity.nm_Tagged_Pricebook__c : objAccount.nm_Tagged_Pricebook__c;
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(priceBookRef);
        System.debug('mapPricebook -->'+mapPricebook );
        map<id,string>MapOfProgram=new map<id,string>();
        set<String> setOfProgramId = new Set<String>{objOpportunity.nm_Program__c};
        list<nm_Program__c> Lstofprogram = [select id,IsTerm__c,nm_TotalSemesters__c,name,nm_Type__c,Specialisation__c,nm_ProgramName__c from nm_Program__c where id in:setOfProgramId limit 1];
        nm_Program__c objprg = Lstofprogram[0];
        List<OpportunityLineItem> lstOppLineItemsToInsert = new List<OpportunityLineItem>();
        decimal LateFeeAmount = 0.0;
      
        // loop for checking Registrtaion Fee Product Already Added or Not for Fresh admission with Program Change Request  cases
        if(lstOpportunityLineIteam.size()>0 && lstOpportunityLineIteam!=null)
        {
            for(OpportunityLineItem objLine : lstOpportunityLineIteam )
            {
                if(objLine.Product_Name__c == 'Registration Fee')
                {
                    IsRegistartionFeeProductAdded = true;
                }else if(objLine.Product_Name__c == 'Certificate Service Tax' || objLine.Product_Name__c == 'GST' )
                {
                    servicetaxProductAlreadyInserted = true; // checking service tax already Inserted for current sem beacuse In case of Program change same method call from student program it will insert double service tax product
                }
            }
        }
        
        if(mapPricebook !=null)
        { 
            
           /* if(objOpportunity.nm_Semester__c == '1' && mapPricebook.get('Registration Fee') != null && !IsRegistartionFeeProductAdded)
            {
                lstOppLineItemsToInsert.add(CreateLineIteam('Registration Fee',mapPricebook,objOpportunity.id));
            }
            else if(mapPricebook.get('Registration Fee') != null && objOpportunity.nm_Category__c == 'Lateral Admission' && objOpportunity.nm_Semester__c != '1' && !IsRegistartionFeeProductAdded)
            {
                lstOppLineItemsToInsert.add(CreateLineIteam('Registration Fee',mapPricebook,objOpportunity.id));
            }*/
            if(objOpportunity.IC__c == 'Verizon')
            {
                lstOppLineItemsToInsert.add(CreateLineIteam('Exam Fees',mapPricebook,objOpportunity.id));
            }
             if(objOpportunity.Career_Service__c != '' && objOpportunity.Career_Service__c != null)
            {
            system.debug('objOpportunity.Career_Service__c--->'+objOpportunity.Career_Service__c);
                lstOppLineItemsToInsert.add(CreateLineIteam(objOpportunity.Career_Service__c,mapPricebook,objOpportunity.id));
            }
            // create Semester Line Iteam 
                string strKey = objOpportunity.nm_Program__c + '-' + objOpportunity.nm_Semester__c;
                MapOfProgram.put(objOpportunity.nm_Program__c,objOpportunity.nm_Program__r.nm_Type__c);
                System.debug('objOpportunity.nm_Program__c'+objOpportunity.nm_Program__c);
                    
                    
            if(mapPricebook.get('Registration Fee') != null && objprg.Specialisation__c!='CPWL')
                
            {
                    OpportunityLineItem objLineItem1 =  CreateLineIteamObject('Registration Fee',mapPricebook,objOpportunity.id);
               
               if((objOpportunity.nm_Semester__c == '1' || (objOpportunity.nm_Category__c == 'Lateral Admission' && objOpportunity.nm_Semester__c != '1' )) && !IsRegistartionFeeProductAdded  )
                {
                    if(objprg.nm_Type__c == 'Master Programs' && objprg.Specialisation__c=='MBA (WX)' || objprg.Specialisation__c=='MBA - X' || objprg.Specialisation__c=='M.Sc. (AI & ML Ops)'  || objprg.Specialisation__c=='M.Sc. (AI)')
                    {
                        objLineItem1.UnitPrice = Decimal.valueOf(Label.Degree_Programs_Regfee);
                        objLineItem1.ActualSalePrice__c =  Decimal.valueOf(Label.Degree_Programs_Regfee);
                        lstOppLineItemsToInsert.add(objLineItem1);
                    }
                    else
                    {
                         lstOppLineItemsToInsert.add(CreateLineIteam('Registration Fee',mapPricebook,objOpportunity.id));
                    }
                    
                }
               /*   if( objOpportunity.Is_Re_Registration_Payment__c = false && !IsRegistartionFeeProductAdded && objprg.Specialisation__c!='Online MBA' )
                {
                    if(objprg.nm_Type__c == 'Master Programs' && objprg.Specialisation__c!='Online MBA')
                    {
                        objLineItem1.UnitPrice = Decimal.valueOf(Label.Degree_Programs_Regfee);
                        objLineItem1.ActualSalePrice__c =  Decimal.valueOf(Label.Degree_Programs_Regfee);
                        lstOppLineItemsToInsert.add(objLineItem1);
                    }
                
                    else
                    {
                         lstOppLineItemsToInsert.add(CreateLineIteam('Registration Fee',mapPricebook,objOpportunity.id));
                    }
                    
                }*/
                        
            }
            if(mapPricebook.get(strKey) != null)
            {
                OpportunityLineItem objLineItem = CreateLineIteamObject(strKey,mapPricebook,objOpportunity.id);
                if('Emerson'.equalsIgnoreCase(objOpportunity.IC__c))
                    {
                        objLineItem.UnitPrice = 79000;                        
                        objLineItem.ActualSalePrice__c = 79000;               
                    }
                    else{
                    
                objLineItem.UnitPrice = Unitprice(objOpportunity,objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,objprg,mapPricebook,objAccount.OldStudentForExecutive__c);
                system.debug('Program name'+Lstofprogram[0].Name);
                system.debug('Program name'+objOpportunity.nm_Fee_Type__c);
                system.debug('Program name'+objAccount.nm_DefencePersonnel__c);
                
                objLineItem.ActualSalePrice__c = ActualUnitprice(objOpportunity,objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,objprg,mapPricebook,objAccount.OldStudentForExecutive__c);
                system.debug('objLineItem.UnitPrice'+objLineItem.UnitPrice);
            }
                if((objprg.nm_Type__c== 'Certificate Programs' || objprg.nm_Type__c== 'Executive Programs') && !servicetaxProductAlreadyInserted)
                {
                    OpportunityLineItem objLineItems =  CreateLineIteamObject('GST',mapPricebook,objOpportunity.id);
                   
                    
                    Decimal LiveLectureUnitPrice = UnitpriceLiveLecture(objOpportunity,objOpportunity.LiveLecturesType__c,mapPricebook);
                    objLineItems.UnitPrice = (objLineItem.UnitPrice + LiveLectureUnitPrice) *Decimal.valueOf(Label.Service_Tax); 
                    Decimal LiveLectureActualPrice = ActualUnitpriceLiveLecture(objOpportunity,mapPricebook);

                    if (objOpportunity.nm_Fee_Type__c!=null &&  objOpportunity.nm_Fee_Type__c!='' && objOpportunity.nm_Fee_Type__c.contains('Considered') )
                    {
                        objLineItems.ActualSalePrice__c = LiveLectureActualPrice *Decimal.valueOf(Label.Service_Tax) ;
                    }
                    else
                    {
                       objLineItems.ActualSalePrice__c = (LiveLectureActualPrice+ objLineItem.ActualSalePrice__c)*Decimal.valueOf(Label.Service_Tax); 
                    }
                    
                    lstOppLineItemsToInsert.add(objLineItems);
                    System.debug('servicetaxProductAlreadyInserted '+servicetaxProductAlreadyInserted  );
                }
                
                lstOppLineItemsToInsert.add(objLineItem);
            }
        }
        if(lstOppLineItemsToInsert.size() > 0)
        {
        
            system.debug('lstOppLineItemsToInsert'+lstOppLineItemsToInsert.size());
            insert lstOppLineItemsToInsert;
            System.debug('!!!!!!!!!inserted lstOppLineItemsToInsert!!!!!!!!'+lstOppLineItemsToInsert);
        }
        
    }

public decimal ActualUnitpriceLiveLecture(Opportunity objOpportunity,Map<String,PriceBookEntry> mapPricebook)
{
  decimal unitprice =0;
  decimal liveLecturePrice=0;
  decimal numberofsubject=0;
  
     if(mapPricebook != null && !mapPricebook.isEmpty())                                                    
        { 
                liveLecturePrice =mapPricebook.containskey('Live Lectures') ? mapPricebook.get('Live Lectures').UnitPrice : 0;   
               
                   if(!IsNullOrEmpty(objOpportunity.LiveLecturesType__c) && objOpportunity.Program_Structure__c!=null 
                   && objOpportunity.Sem__c!=null && objOpportunity.nm_Program__c!=null)
                   {
                       if(objOpportunity.LiveLecturesType__c.contains('Considered'))
                       {
                            unitprice=0;
                       }else
                       {
                            numberofsubject = TotalNumberOfSubject(Integer.valueof(objOpportunity.Sem__c),objOpportunity.Program_Structure__c,objOpportunity.nm_Program__c,objOpportunity.LiveLecturesType__c,objOpportunity.CourseList__c,objOpportunity.ConsumerType__c);    
                            System.debug('liveLecturePrice--->'+liveLecturePrice);
                            System.debug('numberofsubject--->'+numberofsubject);                   
                            unitprice = liveLecturePrice * (numberofsubject); 
                            System.debug('unitprice--->'+unitprice);     
                       }
                         
                    }
         
                    return unitprice ;                              
        }      
        return 0;
}
public decimal UnitpriceLiveLecture(Opportunity objOpportunity,String lectureType,Map<String,PriceBookEntry> mapPricebook)
    {
        decimal unitprice =0;
        decimal liveLecturePrice=0;
        decimal numberofsubject=0;

        if(mapPricebook != null && !mapPricebook.isEmpty())                                                    
        { 
            liveLecturePrice = mapPricebook.containskey('Live Lectures') ? mapPricebook.get('Live Lectures').UnitPrice : 0;   

            if(!IsNullOrEmpty(lectureType)&& objOpportunity.Program_Structure__c!=null 
            && objOpportunity.Sem__c!=null && objOpportunity.nm_Program__c!=null)
            {

                System.debug('liveLecturePrice--->'+liveLecturePrice);
            
                if(!IsNullOrEmpty(lectureType) && (lectureType.contains('1SemLecturesFee') || lectureType=='Custom' ))
                { 
                    numberofsubject = TotalNumberOfSubject(Integer.valueof(objOpportunity.Sem__c),objOpportunity.Program_Structure__c,objOpportunity.nm_Program__c,objOpportunity.LiveLecturesType__c,objOpportunity.CourseList__c,objOpportunity.ConsumerType__c);
                    unitprice = liveLecturePrice * (numberofsubject); 
                    System.debug('numberofsubject--->'+numberofsubject);
                }
                else if(!IsNullOrEmpty(lectureType) && '2SemLecturesFee-Considered'.equalsIgnoreCase(lectureType) )
                { 
                    numberofsubject = TotalNumberOfSubject(Integer.valueof(objOpportunity.Sem__c-1),objOpportunity.Program_Structure__c,objOpportunity.nm_Program__c,objOpportunity.LiveLecturesType__c,objOpportunity.CourseList__c,objOpportunity.ConsumerType__c);
                    unitprice = liveLecturePrice * (numberofsubject/2); 
                    System.debug('numberofsubject--->'+numberofsubject);
                }
                else if(!IsNullOrEmpty(lectureType) && '2SemLecturesFee'.equalsIgnoreCase(lectureType) )
                { 
                    numberofsubject = TotalNumberOfSubject(Integer.valueof(objOpportunity.Sem__c),objOpportunity.Program_Structure__c,objOpportunity.nm_Program__c,objOpportunity.LiveLecturesType__c,objOpportunity.CourseList__c,objOpportunity.ConsumerType__c);
                    unitprice = liveLecturePrice * (numberofsubject/2); 
                    System.debug('numberofsubject--->'+numberofsubject);
                }               
                else if(!IsNullOrEmpty(lectureType) && lectureType.contains('3SemLecturesFee'))
                { 

                    numberofsubject = TotalNumberOfSubject(Integer.valueof(2),objOpportunity.Program_Structure__c,objOpportunity.nm_Program__c,objOpportunity.LiveLecturesType__c,objOpportunity.CourseList__c,objOpportunity.ConsumerType__c);
                    unitprice = liveLecturePrice * (numberofsubject/3); 
                    System.debug('numberofsubject--->'+numberofsubject);
                }    
                else if(!IsNullOrEmpty(lectureType) && lectureType.contains('4SemLecturesFee') )
                { 
                    numberofsubject = TotalNumberOfSubject(Integer.valueof(1),objOpportunity.Program_Structure__c,objOpportunity.nm_Program__c,objOpportunity.LiveLecturesType__c,objOpportunity.CourseList__c,objOpportunity.ConsumerType__c);
                    unitprice = liveLecturePrice * (numberofsubject/4); 
                    System.debug('numberofsubject--->'+numberofsubject);
                }                

                System.debug('unitprice--->'+unitprice);         
            }

            return unitprice ;               

        }      
    return 0;
}

public decimal Unitprice(Opportunity  objOpportunity,String Feetype, String Isdefence, String Strkey,nm_Program__c objprg,Map<String,PriceBookEntry> mapPricebook,boolean IsexcutiveDiscount)
{
  decimal unitprice;
  
     if(mapPricebook != null && !mapPricebook.isEmpty())                                                    
        {
         System.debug('mapPricebook UnitPrice ----'+mapPricebook.keySet());
        //  if (Isdefence =='Yes' || IsexcutiveDiscount==true)                
        //     {
        //        if(Feetype!=null && Feetype.contains('MBAallTermfee'))
        //         {
        //             unitprice = (mapPricebook.get(objprg.id + '-' +'1').UnitPrice)/objprg.nm_TotalSemesters__c;
        //         }else if(Feetype!=null && Feetype.contains('FullFee') && ('M.Sc. (AI & ML Ops)'.equalsIgnorecase(objprg.Specialisation__c) || 'M.Sc. (AI)'.equalsIgnorecase(objprg.Specialisation__c) ||'MBA'.equalsIgnorecase(objprg.Specialisation__c)))
        //         {   
        //             System.debug('Feetypeprice Price=='+Feetypeprice(objOpportunity,'FullFee',mapPricebook,objprg));
        //             // unitprice =  Feetypeprice(objOpportunity,'FullFee',mapPricebook,objprg)/objprg.nm_TotalSemesters__c; 
        //             unitprice =  Feetypeprice(objOpportunity,'FullFee',mapPricebook,objprg);
        //         }else if(Feetype!=null && Feetype.contains('AnnualFeeLoan') && objprg.Id!=null)
        //         {                       
        //             unitprice = mapPricebook.containsKey(Strkey)?(mapPricebook.get(Strkey).UnitPrice):0 ;
        //         }else if(Feetype!=null && Feetype.contains('AnnualFee') && ('M.Sc. (AI & ML Ops)'.equalsIgnorecase(objprg.Specialisation__c) || 'M.Sc. (AI)'.equalsIgnorecase(objprg.Specialisation__c)) )
        //         {
        //             Decimal totalsem = objprg.IsTerm__c?objprg.nm_TotalSemesters__c/2 : 2; 
        //             //  unitprice =  Feetypeprice(objOpportunity,'Annual',mapPricebook,objprg)/totalsem; 
        //             unitprice =  Feetypeprice(objOpportunity,'Annual',mapPricebook,objprg);
        //         }else if(Feetype!=null && Feetype.contains('FullFeeLoan') && objprg.Id!=null)
        //         {                       
        //             unitprice = mapPricebook.containsKey(Strkey)?(mapPricebook.get(Strkey).UnitPrice):0 ;                
        //         }            
        //         else
        //         {
        //             unitprice = mapPricebook.containsKey(Strkey)?(mapPricebook.get(Strkey).UnitPrice):0 ;
        //         }
        //         System.debug('Before Discount=='+unitprice);
        //              unitprice = unitprice*0.8;  
        //         System.debug('After Discount=='+unitprice);     
                                           
        //         return unitprice;
                
        //     }
        //  else 
          if(Isdefence !='Yes' )
            {
              if(Feetype=='' || Feetype==null)
                {
                   unitprice = (mapPricebook.get(strKey).UnitPrice);
                }
                else if(Feetype.contains('PGAllSemFee') && 'Master Programs'.equalsIgnorecase(objprg.nm_Type__c) && 'M.Sc.'.equalsIgnorecase(objprg.Specialisation__c))
                {
                    unitprice = mapPricebook.get('MSAllSemFee').UnitPrice/4;
                }
                else if(Feetype.contains('PGAllSemFee') && 'Bachelor Programs'.equalsIgnorecase(objprg.nm_Type__c) && 'BCom'.equalsIgnorecase(objprg.Specialisation__c))
                {
                    unitprice = mapPricebook.get('BComAllSemFee').UnitPrice/6;
                }
                else if(Feetype.contains('PGAllSemFee') && 'Bachelor Programs'.equalsIgnorecase(objprg.nm_Type__c) && 'BBA'.equalsIgnorecase(objprg.Specialisation__c))
                {
                    unitprice = mapPricebook.get('BBAAllSemFee').UnitPrice/6;
                }
                else if(Feetype.contains('PGAllSemFee'))
                {
                    unitprice = mapPricebook.get('PG_All_Sem').UnitPrice/4;
                }
                else if(Feetype.contains('AnnualFeeLoan') && objprg.Id!=null && Feetype!=null  )
                {                       
                    Decimal totalsem = objprg.IsTerm__c?objprg.nm_TotalSemesters__c/2 : 2;
                    unitprice = Feetypeprice(objOpportunity,'AnnualFeeLoan',mapPricebook,objprg)/totalsem;                  
                }
                else if(Feetype.contains('AnnualFee') && objprg.Id!=null && Feetype!=null )
                {   
                    Decimal totalsem = objprg.IsTerm__c?objprg.nm_TotalSemesters__c/2 : 2;              
                    unitprice = Feetypeprice(objOpportunity,'Annual',mapPricebook,objprg)/totalsem;            
                }else if(Feetype.contains('2TermFee') && objprg.Id!=null && Feetype!=null )
                {   
                    Decimal totalsem = objprg.IsTerm__c?objprg.nm_TotalSemesters__c/2 : 2;              
                    unitprice = Feetypeprice(objOpportunity,'2TermFee',mapPricebook,objprg)/totalsem;            
                }
                else if(Feetype.contains('3SemFee') && objprg.Id!=null && Feetype!=null )
                {                       
                      unitprice = Feetypeprice(objOpportunity,  '3SemFee',mapPricebook,objprg)/3;                        
                }
                else if(Feetype.contains('3TermFee') && objprg.Id!=null && Feetype!=null )
                {                       
                      unitprice = Feetypeprice(objOpportunity,  '3TermFee',mapPricebook,objprg)/3;                        
                }
                else if(Feetype.contains('4SemFee') && objprg.Id!=null && Feetype!=null )
                {                       
                      unitprice = Feetypeprice(objOpportunity,'4SemFee',mapPricebook,objprg)/4;                        
                }
                else if(Feetype.contains('5SemFee') && objprg.Id!=null && Feetype!=null  )
                {                       
                      unitprice = Feetypeprice(objOpportunity,'5SemFee',mapPricebook,objprg)/5;                        
                }
                else if(Feetype.contains('FullFeeLoan') && objprg.Id!=null && Feetype!=null  )
                {                       
                      unitprice = Feetypeprice(objOpportunity,'FullFeeLoan',mapPricebook,objprg)/objprg.nm_TotalSemesters__c;                      
                }
                else if(Feetype.contains('FullFee') && objprg.Id!=null && Feetype!=null  )
                {                       
                      unitprice = Feetypeprice(objOpportunity,'FullFee',mapPricebook,objprg)/objprg.nm_TotalSemesters__c;                      
                }                
                else if(Feetype.contains('MultipleSemFee'))
                {
                    unitprice = mapPricebook.get('Multiple Semester').UnitPrice/3;
                }
                else if(Feetype.contains('MBAallTermfee'))
                {
                    unitprice = (mapPricebook.get(objprg.id + '-' +'1').UnitPrice)/objprg.nm_TotalSemesters__c;
                }
                else
                {
                    unitprice = mapPricebook.containskey(Strkey)?(mapPricebook.get(Strkey).UnitPrice):0;
                }
                return unitprice ;            
            }           
            else
            {       
                unitprice = (mapPricebook.get(Strkey).UnitPrice);

                 if (Isdefence =='Yes' || IsexcutiveDiscount==true)  {
                    System.debug('Before Discount=='+unitprice);
                    unitprice = unitprice*0.8;
                    System.debug('After Discount=='+unitprice);
                 }

              return unitprice;
            }          
            
        }
        return 0;
}
public decimal ActualUnitprice(Opportunity  objOpportunity ,String Feetype, String Isdefence, String Strkey,nm_Program__c objprg,Map<String,PriceBookEntry> mapPricebook,Boolean IsexcutiveDiscount)
{
  decimal unitprice;
  
  string strkey2;
  
     if(mapPricebook != null && !mapPricebook.isEmpty())                                                    
        {
            System.debug('mapPricebook--->'+mapPricebook);
            System.debug('mapPricebook........>'+mapPricebook.keySet());          
                //  if ((Isdefence!=null && Isdefence =='Yes') || IsexcutiveDiscount==true )                
                // {
                //   System.debug('Feetype'+Feetype);
                //     if(Feetype=='' || Feetype == null)
                //     {
                //        unitprice = (mapPricebook.get(strKey).UnitPrice);
                //     }
                //     mapOfPricebookEntry =getMapOfProductVsPriceBookEntry(objOpportunity.nm_Tagged_Pricebook__c);
                //     System.debug('mapOfPricebookEntry--->'+mapOfPricebookEntry);
                //     System.debug('mapOfPricebookEntry...>'+mapOfPricebookEntry.keySet());
                //     else if(Feetype.contains('Considered') && Feetype!=null)
                //     {
                //         unitprice =0;
                //     }
                //     else if(Feetype.contains('PGAllSemFee')&& Feetype!=null)
                //     {
                //         unitprice = (mapPricebook.get(strKey).UnitPrice)*4;
                //     }
                //     else if(Feetype.contains('FullFee')&& Feetype!=null && ('M.Sc. (AI & ML Ops)'.equalsIgnorecase(objprg.Specialisation__c) || 'M.Sc. (AI)'.equalsIgnorecase(objprg.Specialisation__c)  ))
                //     {
                //         unitprice =  Feetypeprice(objOpportunity,'FullFee',mapPricebook,objprg); 
                //     }
                //     else if((Feetype.contains('FullFee') || Feetype.contains('FullFeeLoan')) && Feetype!=null )
                //     {
                //        // unitprice = (m   apPricebook.get(strKey).UnitPrice)*objprg.nm_TotalSemesters__c;
                //        unitprice = mapPricebook.containsKey(Strkey)?(mapPricebook.get(Strkey).UnitPrice):0 ; 
                //        System.debug(' before multi sem===>'+unitprice);   
                //        unitprice= unitprice*objprg.nm_TotalSemesters__c;
                //        System.debug('unitprice===>'+unitprice);
                //     }                
                //     else if(Feetype.contains('4SemFee')&& Feetype!=null)
                //     {
                //         unitprice = (mapPricebook.get(strKey).UnitPrice)*4;
                //     } 
                //     else if(Feetype.contains('5SemFee')&& Feetype!=null)
                //     {
                //         unitprice = (mapPricebook.get(strKey).UnitPrice)*5;
                //     } else if(Feetype.contains('AnnualFee')&& Feetype!=null && ('M.Sc. (AI & ML Ops)'.equalsIgnorecase(objprg.Specialisation__c) || 'M.Sc. (AI)'.equalsIgnorecase(objprg.Specialisation__c)  ) )
                //     {
                //         unitprice =  Feetypeprice(objOpportunity,'Annual',mapPricebook,objprg); 
                //     }                
                //     else if(Feetype!=null && (Feetype.contains('AnnualFee') || Feetype.contains('AnnualFeeLoan')) )
                //     {
                //         strkey2 = strKey.removeEnd(strKey.substring(strKey.length()-1,strKey.length()));
                        
                //         unitprice = ((mapPricebook.get(strKey).UnitPrice)+(mapPricebook.get(strkey2+'2').UnitPrice)); 
                //     }else if(Feetype.contains('2TermFee')&& Feetype!=null)
                //     {
                //         strkey2 = strKey.removeEnd(strKey.substring(strKey.length()-1,strKey.length()));
                        
                //         unitprice = ((mapPricebook.get(strKey).UnitPrice)+(mapPricebook.get(strkey2+'2').UnitPrice)); 
                //     }
                //    else if((Feetype.contains('MultipleSemFee') || Feetype.contains('3SemFee') || Feetype.contains('3TermFee') )&& Feetype!=null)
                //     {
                //         unitprice = (mapPricebook.get(strKey).UnitPrice)*3;
                //     }
                //      else if(Feetype.contains('MBAallTermfee') && 'MBA (WX)'.equalsIgnorecase(objprg.Specialisation__c))
                //     {
                //         unitprice = (mapPricebook.get('MBAallTermfee').UnitPrice);
                        
                //     }else if(Feetype.contains('MBAallTermfee') && !'MBA (WX)'.equalsIgnorecase(objprg.Specialisation__c))
                //     {
                //          unitprice = (mapPricebook.get(strKey).UnitPrice);
                //     }
                //     else
                //     {
                //        System.debug('Feetype'+Feetype);
                //         unitprice = mapPricebook.containsKey(strKey)?(mapPricebook.get(strKey).UnitPrice):0;
                //     }

                // unitprice = (mapPricebook.get(strKey).UnitPrice);
                //     System.debug('unitprice==>'+unitprice);
                //     System.debug('Before Discount Actualsalesprice...'+unitprice);
                //     unitprice = unitprice*0.8;
                //     System.debug('After Discount Actualsalesprice...'+unitprice);
                //    return unitprice;
                    
                // }
                
                // else 
                // {
                     if(Feetype=='' || Feetype==null)
                    {
                       unitprice = mapPricebook.containskey(strKey)?(mapPricebook.get(strKey).UnitPrice):0;
                    }
                    else if(Feetype.contains('-Considered')&& Feetype!=null)
                    {
                        unitprice =0;
                    }
                    else if(Feetype.contains('PGAllSemFee') && 'Master Programs'.equalsIgnorecase(objprg.nm_Type__c) && 'M.Sc.'.equalsIgnorecase(objprg.Specialisation__c))
                    {
                        unitprice = mapPricebook.get('MSAllSemFee').UnitPrice;
                    }
                    else if(Feetype.contains('PGAllSemFee') && 'Bachelor Programs'.equalsIgnorecase(objprg.nm_Type__c) && 'BCom'.equalsIgnorecase(objprg.Specialisation__c))
                    {
                        unitprice = mapPricebook.get('BComAllSemFee').UnitPrice;
                    }
                    else if(Feetype.contains('PGAllSemFee') && 'Bachelor Programs'.equalsIgnorecase(objprg.nm_Type__c) && 'BBA'.equalsIgnorecase(objprg.Specialisation__c))
                    {
                        unitprice = mapPricebook.get('BBAAllSemFee').UnitPrice;
                    }
                    else if(Feetype.contains('PGAllSemFee')&& Feetype!=null)
                    {
                        unitprice = mapPricebook.get('PG_All_Sem').UnitPrice;
                    }
                    else if(Feetype.contains('AnnualFeeLoan') && objprg.Id!=null && Feetype!=null )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'AnnualFeeLoan',mapPricebook,objprg);                       
                    }
                    else if(Feetype.contains('AnnualFee') && objprg.Id!=null && Feetype!=null )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'Annual',mapPricebook,objprg);                       
                    } else if(Feetype.contains('2TermFee') && objprg.Id!=null && Feetype!=null )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'2TermFee',mapPricebook,objprg);                       
                    }else if(Feetype.contains('3SemFee') && objprg.Id!=null && Feetype!=null )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'3SemFee',mapPricebook,objprg);                      
                    }
                    else if(Feetype.contains('3TermFee') && objprg.Id!=null && Feetype!=null )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'3TermFee',mapPricebook,objprg);                      
                    }
                    else if(Feetype.contains('4SemFee') && objprg.Id!=null && Feetype!=null )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'4SemFee',mapPricebook,objprg);                      
                    }else if(Feetype.contains('5SemFee') && objprg.Id!=null && Feetype!=null  )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'5SemFee',mapPricebook,objprg);                      
                    }
                    else if(Feetype.contains('FullFeeLoan') && objprg.Id!=null && Feetype!=null  )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'FullFeeLoan',mapPricebook,objprg);                      
                    }
                    else if(Feetype.contains('FullFee') && objprg.Id!=null && Feetype!=null  )
                    {                       
                          unitprice = Feetypeprice(objOpportunity,'FullFee',mapPricebook,objprg);                      
                    }                 
                    else if(Feetype.contains('MultipleSemFee')&& Feetype!=null)
                    {
                        unitprice = mapPricebook.get('Multiple Semester').UnitPrice;
                    }
                    else if(Feetype.contains('MBAallTermfee')&& Feetype!=null && 'MBA (WX)'.equalsIgnorecase(objprg.Specialisation__c))
                    {
                        unitprice = mapPricebook.get('MBAallTermfee').UnitPrice;
                    }
                    else if(Feetype.contains('MBAallTermfee') && !'MBA (WX)'.equalsIgnorecase(objprg.Specialisation__c))
                    {
                         unitprice = mapPricebook.containskey(strKey)?(mapPricebook.get(strKey).UnitPrice):0;
                    }
                    else
                    {
                        unitprice = mapPricebook.containskey(strKey)?(mapPricebook.get(strKey).UnitPrice):0;
                        System.debug('Feetype'+Feetype);
                    }

                    if ((Isdefence!=null && Isdefence =='Yes') || IsexcutiveDiscount==true ){
                        System.debug('Before Discount Actualsalesprice==>'+unitprice);
                         unitprice = unitprice * 0.8;
                         System.debug('After Discount Actualsalesprice==>'+unitprice);
                    }
                    return unitprice ;
              
                // }
            //     System.debug('strKey'+strKey);
            //  unitprice = (mapPricebook.get(strKey).UnitPrice);
        }      
        return 0;
}
public decimal Feetypeprice(Opportunity objOpportunity,String Feetype,Map<String,PriceBookEntry> mapPricebook,nm_Program__c objprg)
{
    String programKey = Feetype+'-'+objprg.Id;
    decimal unitprice = 0;
    Integer sem = Integer.valueof(objOpportunity.nm_Semester__c);
    Integer multiplicationFactor = getmultiplicationFactor(objOpportunity.nm_Fee_Type__c);
   
    system.debug('BA objOpportunity.nm_Fee_Type__c--->'+objOpportunity.nm_Fee_Type__c);
    system.debug('Specialisation--->'+objprg.Specialisation__c);
   
     if('BA'.equalsIgnoreCase(objprg.Specialisation__c) && (objOpportunity.nm_Fee_Type__c =='AnnualFee' || objOpportunity.nm_Fee_Type__c =='3SemFee'))
        {
            system.debug('Enter');
            for(Integer i = sem ;i<=(sem + multiplicationFactor - 1);i++)
            {   system.debug('multiplicationFactor---'+i+'-----'+objprg.id);                             
                unitprice += mapPricebook.containskey(objprg.id+'-'+i)?mapPricebook.get(objprg.id+'-'+i).UnitPrice :0 ;               
                system.debug('BA added unitprice-->'+unitprice);
            }
            if(objOpportunity.nm_Fee_Type__c =='AnnualFee')
            {
                unitprice = unitprice * 0.94;

            }else if(objOpportunity.nm_Fee_Type__c =='3SemFee')
            {
                unitprice = unitprice * 0.92;                
            }
            system.debug('BA unitprice-->'+unitprice);
        }
        
       else if(mapPricebook.containsKey(programKey))
        {
            unitprice = mapPricebook.get(programKey).UnitPrice;
        }
        else if(mapPricebook.containsKey(Feetype)){
            unitprice = mapPricebook.get(Feetype).UnitPrice; 
        }                       
        System.debug('enter programName '+programKey);
        return unitprice;
}
                public Integer getmultiplicationFactor(string Feetype)
                {
                    Integer multiFactor=0;
                    if(Feetype =='AnnualFee')
                    {
                        multiFactor =2;
                    }else if(Feetype =='2TermFee')
                    {
                        multiFactor =2;
                    }else if (Feetype =='3SemFee' || Feetype == '3TermFee')
                    {
                        multiFactor =3;
                    }else if (Feetype =='4SemFee')
                    {
                        multiFactor =4;
                    }else if (Feetype =='5SemFee')
                    {
                        multiFactor =5;
                    }
                    return multiFactor;
                }

     /**
     * @description : To check whether feetype updation required or not
     * @author @BK | 10-08-2021 
     * @param TotalSemester 
     * @param Feetype 
     * @param LiveLecturesType 
     * @return boolean 
     **/
    public boolean ValidateFeeType(decimal TotalSemester,String Feetype, String LiveLecturesType, Boolean isTerm) {
        System.debug('Feetype ==>'+Feetype+' TotalSemester==>'+TotalSemester+' LiveLecturesType==>'+LiveLecturesType);
        if((Feetype.contains('PGAllSemFee') || Feetype.contains('FullFee')) && (TotalSemester >= 4 || (isTerm && TotalSemester >= 2 ))) {
            return true;
        }
        else if((Feetype.contains('AnnualFee') || Feetype.contains('2TermFee')) && TotalSemester >= 2) {
            if(String.isBlank(LiveLecturesType) || LiveLecturesType == 'No' || LiveLecturesType == 'Custom' || LiveLecturesType.contains('1SemLecturesFee') || LiveLecturesType.contains('2SemLecturesFee')) {
                return true;
            } else {
               return false;
            }
        }
        else if((Feetype.contains('MultipleSemFee') || Feetype.contains('3SemFee') || Feetype.contains('3TermFee')) && TotalSemester >= 3) {
            if(String.isBlank(LiveLecturesType) || LiveLecturesType == 'No' || LiveLecturesType == 'Custom' || LiveLecturesType.contains('1SemLecturesFee') || LiveLecturesType.contains('2SemLecturesFee') || LiveLecturesType.contains('3SemLecturesFee')) {
                return true;
            } else {
               return false;
            }
        }
        else if(Feetype.contains('MBAallTermfee') && TotalSemester >= 5) {
            return true;
        }
        else if(Feetype.contains('4SemFee') && TotalSemester >= 4) {
            return true;
        }
        else if(Feetype.contains('5SemFee') && TotalSemester >= 5) {
            return true;
        }
        else if(Feetype=='ReRegistrationPayment'|| Feetype=='admission' || Feetype=='Admission' || Feetype =='registration' || Feetype =='InitialAdmissionFee') {
            if(String.isBlank(LiveLecturesType) || LiveLecturesType == 'No' || LiveLecturesType == 'Custom' || LiveLecturesType == '1SemLecturesFee') {
                return true;
            } else {
               return false;
            }
        }
        else {
            return false;
        }
    }
    
    public boolean ValidateFeeType(decimal TotalSemester,String Feetype)
    {
        if(Feetype.contains('PGAllSemFee') && TotalSemester >= 4)
        {
            return true;
        }
        else if(Feetype.contains('FullFee') && TotalSemester >= 4)
        {
            return true;
        }
        else if((Feetype.contains('AnnualFee') || Feetype.contains('2TermFee')) && TotalSemester >= 2)
        {
            return true;
        }
        else if((Feetype.contains('MultipleSemFee') || Feetype.contains('3TermFee') )&& TotalSemester >= 3)
        {
            return true;
        }
        else if(Feetype.contains('MBAallTermfee') && TotalSemester >= 5)
        {
            return true;
        }
        else if(Feetype=='ReRegistrationPayment'|| Feetype=='admission' || Feetype =='registration' || Feetype =='LeadRegistrationAdmission')
        {
            return true;
        }
        else 
        {
            return false;
        }
    }

    //Method Called from nmStudentProgram ,nmopportunity Trigger Handler original
  /*  public void CreateSemesterLineIteam(Opportunity objOpportunity,Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook,Map<String,Account> mapOfOppsVsAccount,Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem)
    {
        //get Tag PriceBookId from Account 
        Account objAccount = mapOfOppsVsAccount.get(objOpportunity.AccountId);
        system.debug('objAccount'+objAccount );
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        List<OpportunityLineItem> lstOpportunityLineIteam = mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id) !=null ?  mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id) :new List<OpportunityLineItem>();
        boolean IsRegistartionFeeProductAdded = false;
        boolean servicetaxProductAlreadyInserted  = false;
        System.debug('Account Tag Price Book---->'+mapPricebookIdVsPriceBook.ContainsKey(objAccount.nm_Tagged_Pricebook__c));
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c);
         map<id,string>MapOfProgram=new map<id,string>();
         set<String> setOfProgramId = new Set<String>{objOpportunity.nm_Program__c};
        list<nm_Program__c> Lstofprogram = [select id,  nm_Type__c from nm_Program__c where id in:setOfProgramId];
        List<OpportunityLineItem> lstOppLineItemsToInsert = new List<OpportunityLineItem>();
         decimal LateFeeAmount = 0.0;
      
        // loop for checking Registrtaion Fee Product Already Added or Not for Fresh admission with Program Change Request  cases
        if(lstOpportunityLineIteam.size()>0 && lstOpportunityLineIteam!=null)
        {
            for(OpportunityLineItem objLine : lstOpportunityLineIteam )
            {
                if(objLine.Product_Name__c == 'Registration Fee')
                {
                    IsRegistartionFeeProductAdded = true;
                }else if(objLine.Product_Name__c == 'Certificate Service Tax')
                {
                    servicetaxProductAlreadyInserted = true; // checking service tax already Inserted for current sem beacuse In case of Program change same method call from student program it will insert double service tax product
                }
            }
        }
        
        if(mapPricebook !=null)
        {
            if(objOpportunity.nm_Semester__c == '1' && mapPricebook.get('Registration Fee') != null && !IsRegistartionFeeProductAdded)
            {
                lstOppLineItemsToInsert.add(CreateLineIteam('Registration Fee',mapPricebook,objOpportunity.id));
            }
            else if(mapPricebook.get('Registration Fee') != null && objOpportunity.nm_Category__c == 'Lateral Admission' && objOpportunity.nm_Semester__c != '1' && !IsRegistartionFeeProductAdded)
            {
                lstOppLineItemsToInsert.add(CreateLineIteam('Registration Fee',mapPricebook,objOpportunity.id));
            }
            
            // create Semester Line Iteam 
            string strKey = objOpportunity.nm_Program__c + '-' + objOpportunity.nm_Semester__c;
            MapOfProgram.put(objOpportunity.nm_Program__c,objOpportunity.nm_Program__r.nm_Type__c);
           System.debug('objOpportunity.nm_Program__c'+objOpportunity.nm_Program__c);
            if(mapPricebook.get(strKey) != null)
            {
                OpportunityLineItem objLineItem = new OpportunityLineItem();
                objLineItem.OpportunityId = objOpportunity.id;
                objLineItem.PriceBookEntryId = mapPricebook.get(strKey).id;
                objLineItem.Quantity = 1.00;
                OpportunityLineItem objLineItems = new OpportunityLineItem();
                         
                if(objOpportunity.nm_Fee_Type__c != null && objOpportunity.nm_Fee_Type__c.contains('PGAllSemFee'))
                {
                    objLineItem.UnitPrice = mapPricebook.get('PG_All_Sem').UnitPrice/4;
                    system.debug('lstOppLineItemsToInsert'+lstOppLineItemsToInsert);
                    system.debug('objLineItem.UnitPrice'+objLineItem.UnitPrice);
                    
                }
                else if(objAccount.nm_DefencePersonnel__c != null && objAccount.nm_DefencePersonnel__c == 'Yes')
                {
                  
                    objLineItem.UnitPrice = ((mapPricebook.get(strKey).UnitPrice)*0.8);
                    
                }
                else if(objOpportunity.nm_Fee_Type__c != null && objOpportunity.nm_Fee_Type__c.contains('AnnualFee')){
                    // checking Student Program as Annaul Fee Option is available for Advance Certificate Program also with different Product Price 
                    if(objOpportunity.Program_Name__c.startswith('AC'))
                    {
                        objLineItem.UnitPrice = mapPricebook.get('Certificate_Annual').UnitPrice/2;
                    }else
                    {
                       objLineItem.UnitPrice = mapPricebook.get('Annual').UnitPrice/2;
                    }   
                    system.debug('objLineItem.UnitPrice'+ objLineItem.UnitPrice);
                }
                else if(objOpportunity.nm_Fee_Type__c != null && objOpportunity.nm_Fee_Type__c.contains('MultipleSemFee'))
                {    
                    objLineItem.UnitPrice = mapPricebook.get('Multiple Semester').UnitPrice/3;
                    
                }
                else
                {
                    
                    objLineItem.UnitPrice = mapPricebook.get(strKey).UnitPrice;
                }
                if(Lstofprogram[0].nm_Type__c=='Certificate Programs' && !servicetaxProductAlreadyInserted)
                {
                    objLineItems.OpportunityId = objOpportunity.id;
                    objLineItems.PriceBookEntryId = mapPricebook.get('Certificate Service Tax').id;
                    objLineItems.Quantity = 1.00;
                    objLineItems.UnitPrice = objLineItem.UnitPrice*Decimal.valueOf(Label.Service_Tax);
                    lstOppLineItemsToInsert.add(objLineItems);
                     System.debug('servicetaxProductAlreadyInserted '+servicetaxProductAlreadyInserted  );
                }
                
                lstOppLineItemsToInsert.add(objLineItem);
            }
        }
            if(lstOppLineItemsToInsert.size() > 0)
            {
            
                system.debug('lstOppLineItemsToInsert'+lstOppLineItemsToInsert.size());
                insert lstOppLineItemsToInsert;
                System.debug('!!!!!!!!!inserted lstOppLineItemsToInsert!!!!!!!!'+lstOppLineItemsToInsert);
            }
        
    }*/
    
    
     public OpportunityLineItem CreateLateFeeLineItem(decimal pendingLateFee,Map<String,PriceBookEntry> mapPricebook,Opportunity objOpps)
    {
        OpportunityLineItem objLineItem = new OpportunityLineItem();
        System.debug('objOpps '+objOpps);
        objLineItem.OpportunityId = objOpps.id;
        System.debug('mapPricebook '+mapPricebook);
        if(mapPricebook != null){
          objLineItem.PriceBookEntryId = mapPricebook.get('Late Fee').id;
        }
        objLineItem.Quantity = 1.00;
        objLineItem.UnitPrice = pendingLateFee ;  
        objLineItem.ActualSalePrice__c = pendingLateFee ;  
        return objLineItem;
    }
    
    //---------- Get late fee details -------------------
    public decimal lateFee ( string strCategory )
    {
        if( strCategory != null )
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and Start_Date__c <= : Date.today()
                                                and End_Date__c >= : Date.today()];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {                   
                    return lstlateFee[0].Late_Fees__c; 
            }
        }    
        return 0;
    }
    public List<Late_Fee__c> getLateFeeRecord(String strCategory,String strtype,String Specialisation,String strSession,String strYear)
    {
        list< Late_Fee__c > lstlateFee = new List<Late_Fee__c>();
        if( strCategory != null && Specialisation!=null)
        { 
            lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                            from Late_Fee__c 
                            where Category__c =: strCategory
                            and nm_Type__c =:strtype
                            and Program_Type__c =:Specialisation 
                            and Session__c =:strSession
                            and Year__c =:strYear
                            and Start_Date__c <= : Date.today()
                            and End_Date__c >= : Date.today()];
                          
                   
        }  
        else
        {
             lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                            from Late_Fee__c 
                            where Category__c =: strCategory 
                            and nm_Type__c =:strtype
                             and Session__c =:strSession
                             and Year__c =:strYear
                            and Start_Date__c <= : Date.today()
                            and End_Date__c >= : Date.today()];
        }  
         
        return lstlateFee;

    }
     public List<Late_Fee__c> getLateFeeRecord(String strCategory,String strtype,String strSession,String strYear)
    {
        list< Late_Fee__c > lstlateFee = new List<Late_Fee__c>();
        if( strCategory != null && strtype!=null)
        {
            lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                            from Late_Fee__c 
                            where Category__c =: strCategory
                            and nm_Type__c =:strtype
                            and Session__c =:strSession
                            and Year__c =:strYear
                            and Start_Date__c <= : Date.today()
                            and End_Date__c >= : Date.today()];
                           
                 if(lstlateFee.isEmpty()){
                            lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                            from Late_Fee__c 
                            where Category__c =: strCategory
                            and nm_Type__c =:strtype 
                            and Start_Date__c <= : Date.today()
                            and End_Date__c >= : Date.today()];
        }  
}

        else
        {
             lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                            from Late_Fee__c 
                            where Category__c =: strCategory
                            and nm_Type__c =:strtype                          
                            and Start_Date__c <= : Date.today()
                            and End_Date__c >= : Date.today()];
        }       
        return lstlateFee;
    }
    
    //Method Called from nmPaymentTriggerHandler,nmAdditionalChargeController
    // Insert Late Fee Product depending on Pending Late Fee
  /*pha  public decimal CreateLateFeeProduct(Opportunity objOpps,String eventName)
    {
        // calculate Late Fee
        decimal LateFeeAmount = 0.0;
        decimal AlreadyPaidLateFeeAmt = 0.0;
        decimal pendingLateFee = 0.0;
        decimal admissionPaidAmount = 0.0;
        boolean isCertificate = false;
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        List<OpportunityLineItem> lstOppLineItemsToInsert = new List<OpportunityLineItem>();
        date admissionPaymentTranscationDate ;
        set<String> setOfOppsId = new set<String>{objOpps.id};
        set<String> setOfAccountId = new set<String>{objOpps.AccountId};
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId);
         List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(objOpps.id) !=null ?  mapOfOppsIdVsPayments.get(objOpps.id) : new List<nm_Payment__c>();
        Map<String,Account> mapOfOppsVsAccount = getOpportunityRelatedAccount(setOfAccountId);
        Account objAccount = mapOfOppsVsAccount.get(objOpps.AccountId);//query Account getting Document Submission Date
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        if(objAccount.nm_ChooseaProgram__c == 'Certificate Programs')
        {
            isCertificate = true;
        }
        
        if(objOpps.Is_Re_Registration_Payment__c)
        {
            lstLateFee = getLateFeeRecord('Re-Registration','');
        }else
        {
            // get Late Fee Records based Upon Late Fee Category
            if(objOpps.nm_Category__c =='Admission')
            {
                lstLateFee = getLateFeeRecord('Admission',objOpps.Account.nm_ChooseaProgram__c);
                
            }else if(objOpps.nm_Category__c == 'Lateral Admission')
            {
                lstLateFee = getLateFeeRecord('Is Lateral','');
            }
        }
        
        if(lstLateFee.size()>0)
        {
            LateFeeAmount = lstLateFee[0].Late_Fees__c;
            if(isCertificate)
            {
                LateFeeAmount  +=(LateFeeAmount * Decimal.valueOf(Label.Service_Tax));
            }
        }
        //check Already paid late in first slab while taking remaninig fee in second slab
        if(lstOppsRelatedPayment.size()>0)
        {
            for(nm_Payment__c objPayment : lstOppsRelatedPayment)
            {
                if((objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c == 'Waived Off' ) && objPayment.nm_PaymentType__c == 'Late Fees' )
                {
                    AlreadyPaidLateFeeAmt  = AlreadyPaidLateFeeAmt + objPayment.nm_Amount__c;
                }
                if(objPayment.nm_PaymentType__c =='Admission' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c == 'Waived Off' ))
                {
                    admissionPaymentTranscationDate = date.valueOf(objPayment.nm_TransactionDate__c);
                    admissionPaidAmount += objPayment.nm_Amount__c;
                }
            }
        }
        // Insert late Fee record with pending Late Fee Amt in Second slab
        if(AlreadyPaidLateFeeAmt !=null && AlreadyPaidLateFeeAmt > 0 )
        {
            pendingLateFee = LateFeeAmount - AlreadyPaidLateFeeAmt;
        }else if(LateFeeAmount !=null && LateFeeAmount > 0) // Insert late Fee record for first slab
        {
            pendingLateFee = LateFeeAmount;
        }
            
        // avoid double Insert of Late Fee Product 
        boolean alreadyInsertedLateFeeProduct = checkAlreadyLateFeeProductInsertedForCurrentSlab(objOpps.id,lstLateFee,lstOppsRelatedPayment,isCertificate);
        
        // Insert Late Fee Line Item if he has paid Registrtaion+Admission+Late Fee at Lead level and after Lead convert if Product is not inserted then allowed to insert product with paid Late fee
        if(AlreadyPaidLateFeeAmt !=null && AlreadyPaidLateFeeAmt > 0 && !alreadyInsertedLateFeeProduct &&  pendingLateFee <=0)
        {
            lstOppLineItemsToInsert.add(CreateLateFeeLineItem(AlreadyPaidLateFeeAmt,mapPricebook,objOpps));
        }
        
        // create Late Fee Prodcut with  Remaining Late Fee on Document Approval,Admission Payment Approval and after Student login 
        if( pendingLateFee !=null && pendingLateFee > 0 && lstLateFee !=null && lstLateFee.size()>0 && !alreadyInsertedLateFeeProduct)
        {
            
            // Insert Late Fee Product even if Mobile or Email is Verified in Late Fee Salb for following cases
            // Student Status not equal to Admission Document Approved or Provisional
            // also not Insert if Payment Already Done Or Closed Opps Stage
            System.debug('event Name-->'+eventName);
            if(
                (
                  (objAccount.nm_IsEmailVerified__c && objAccount.Is_Mobile_Verified__c && !objOpps.Is_Re_Registration_Payment__c) // for Admission Records
                 ||
                  (objOpps.Is_Re_Registration_Payment__c) // for Re-Reg Records
                 ||
                 ( objAccount.nm_StudentStatus__c !='Confirmed'  && !objOpps.Is_Re_Registration_Payment__c)  
                )
                 && lstLateFee.size()>0  && lstLateFee[0].Late_Fees__c != null  
             ) 
            {
               if('Payment Made'.equalsIgnoreCase(eventName) || 'Payment Approved'.equalsIgnoreCase(eventName))
               {
                   if( admissionPaymentTranscationDate !=null )
                    {
                        if(lstLateFee.size()>0 && lstLateFee[0].Late_Fees__c != null && date.valueOf(lstLateFee[0].Start_Date__c) <= admissionPaymentTranscationDate && date.valueOf(lstLateFee[0].End_Date__c) >= admissionPaymentTranscationDate )
                        {
                            lstOppLineItemsToInsert.add(CreateLateFeeLineItem(pendingLateFee,mapPricebook,objOpps));
                        }
                    }    
               }else if('Email Verified'.equalsIgnoreCase(eventName) || 'Mobile Verified'.equalsIgnoreCase(eventName))
               {
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(pendingLateFee,mapPricebook,objOpps));
               }else if('Document Approved'.equalsIgnoreCase(eventName) )
               {
                    if(objAccount.nm_DocumentSubmittedDate__c !=null)
                    {
                        if(date.valueOf(lstLateFee[0].Start_Date__c) <= date.valueOf(objAccount.nm_DocumentSubmittedDate__c) && date.valueOf(lstLateFee[0].End_Date__c) >= date.valueOf(objAccount.nm_DocumentSubmittedDate__c))
                        {
                            lstOppLineItemsToInsert.add(CreateLateFeeLineItem(pendingLateFee,mapPricebook,objOpps));
                        }
                     } 
               }else if('Document Submitted'.equalsIgnoreCase(eventName)){
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(pendingLateFee,mapPricebook,objOpps));
               }else if('service Change'.equalsIgnoreCase(eventName))
               {
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(pendingLateFee,mapPricebook,objOpps));
               }else if('Additional Charge'.equalsIgnoreCase(eventName))
               {
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(pendingLateFee,mapPricebook,objOpps));
               }
            }
        }
        
        if(lstOppLineItemsToInsert.size()>0)
        {
           insert lstOppLineItemsToInsert;  
        }else{
            pendingLateFee = 0;
        }
        
        //check Late Fee Slab is ON only then Update Opportunity Stage To Pending or Payment Made depending on Pending Amount
        if(pendingLateFee !=null && pendingLateFee > 0 && lstLateFee !=null && lstLateFee.size()>0 && lstOppLineItemsToInsert.size()>0)
        {
            //UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpps.id);
        }
        return pendingLateFee;
       
    }*/
   /*pha vs2  public decimal CreateLateFeeProduct(Opportunity objOpps,String eventName)
    {
        // calculate Late Fee
        decimal LateFeeAmount = 0.0;
        decimal AlreadyPaidLateFeeAmt = 0.0;
        decimal pendingLateFee = 0.0;
        decimal admissionPaidAmount = 0.0;
        boolean isCertificate = false;
        boolean initialLatefeeMBAWX = false;
        boolean admissionLatefeeMBAWX = false;
        decimal InitialMBAWXFee = Decimal.valueOf(Label.InitialMBAWXFee).setScale(2);
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        List<OpportunityLineItem> lstOppLineItemsToInsert = new List<OpportunityLineItem>();
        date admissionPaymentTranscationDate ;
        set<String> setOfOppsId = new set<String>{objOpps.id};
        set<String> setOfAccountId = new set<String>{objOpps.AccountId};
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId);
         List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(objOpps.id) !=null ?  mapOfOppsIdVsPayments.get(objOpps.id) : new List<nm_Payment__c>();
        Map<String,Account> mapOfOppsVsAccount = getOpportunityRelatedAccount(setOfAccountId);
        Account objAccount = mapOfOppsVsAccount.get(objOpps.AccountId);//query Account getting Document Submission Date
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        if(objAccount.nm_ChooseaProgram__c == 'Certificate Programs')
        {
            isCertificate = true;
        }
   
        if(objAccount.nm_ChooseaProgram__c == 'Master Programs' && objAccount.Program_Type__c=='MBA (WX)' && objAccount.Days_Since_For_Admission_Payment__c==-1)
        {
            admissionLatefeeMBAWX = true;
            LateFeeAmount += Decimal.valueOf(Label.AdmissionLatefeeMBAWX).setScale(2);
        }
        
       if(objOpps.Is_Re_Registration_Payment__c)
        {
            lstLateFee = getLateFeeRecord('Re-Registration',objAccount.nm_ChooseaProgram__c,objAccount.Program_Type__c);
        }else
        {
            // get Late Fee Records based Upon Late Fee Category
            if(objOpps.nm_Category__c =='Admission')
            {
                lstLateFee = getLateFeeRecord('Admission',objAccount.nm_ChooseaProgram__c,objAccount.Program_Type__c);
                
            }else if(objOpps.nm_Category__c == 'Lateral Admission')
            {
                lstLateFee = getLateFeeRecord('Is Lateral',objAccount.nm_ChooseaProgram__c,objAccount.Program_Type__c);
            }
        }
      
       
        if(lstLateFee.size()>0)
        {
            LateFeeAmount += lstLateFee[0].Late_Fees__c;
            if(isCertificate)
            {
                LateFeeAmount  +=(LateFeeAmount * Decimal.valueOf(Label.Service_Tax));
            }
            system.debug('LateFeeAmount  --->'+LateFeeAmount  );
        }
        //check Already paid late in first slab while taking remaninig fee in second slab
        if(lstOppsRelatedPayment.size()>0)
        {
            for(nm_Payment__c objPayment : lstOppsRelatedPayment)
            {
                if((objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c == 'Waived Off' ) && objPayment.nm_PaymentType__c == 'Late Fees' )
                {
                    AlreadyPaidLateFeeAmt  = AlreadyPaidLateFeeAmt + objPayment.nm_Amount__c;
                }
                if(objPayment.nm_PaymentType__c =='Admission' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c == 'Waived Off' ))
                {
                    admissionPaymentTranscationDate = date.valueOf(objPayment.nm_TransactionDate__c);
                    admissionPaidAmount += objPayment.nm_Amount__c;
                }
            }
        }
        // Insert late Fee record with pending Late Fee Amt in Second slab
        if(AlreadyPaidLateFeeAmt !=null && AlreadyPaidLateFeeAmt > 0 )
        {
            pendingLateFee = LateFeeAmount - AlreadyPaidLateFeeAmt;
        }else if(LateFeeAmount !=null && LateFeeAmount > 0) // Insert late Fee record for first slab
        {
            pendingLateFee = LateFeeAmount;
        }
            
        // avoid double Insert of Late Fee Product 
        boolean alreadyInsertedLateFeeProduct = checkAlreadyLateFeeProductInsertedForCurrentSlab(objOpps.id,LateFeeAmount,lstOppsRelatedPayment,isCertificate);
        
        
        // Insert Late Fee Line Item if he has paid Registrtaion+Admission+Late Fee at Lead level and after Lead convert if Product is not inserted then allowed to insert product with paid Late fee
        if(AlreadyPaidLateFeeAmt !=null && AlreadyPaidLateFeeAmt > 0 && !alreadyInsertedLateFeeProduct &&  pendingLateFee <=0)
        {
            lstOppLineItemsToInsert.add(CreateLateFeeLineItem(AlreadyPaidLateFeeAmt,mapPricebook,objOpps));
        }
        
        // create Late Fee Prodcut with  Remaining Late Fee on Document Approval,Admission Payment Approval and after Student login 
        if( pendingLateFee !=null && pendingLateFee > 0 && lstLateFee !=null && lstLateFee.size()>0 && !alreadyInsertedLateFeeProduct)
        {
            
            // Insert Late Fee Product even if Mobile or Email is Verified in Late Fee Salb for following cases
            // Student Status not equal to Admission Document Approved or Provisional
            // also not Insert if Payment Already Done Or Closed Opps Stage
            System.debug('event Name-->'+eventName);
            if(
                (
                  (objAccount.nm_IsEmailVerified__c && objAccount.Is_Mobile_Verified__c && !objOpps.Is_Re_Registration_Payment__c) // for Admission Records
                 ||
                  (objOpps.Is_Re_Registration_Payment__c) // for Re-Reg Records
                 ||
                 ( objAccount.nm_StudentStatus__c !='Confirmed'  && !objOpps.Is_Re_Registration_Payment__c)  
                )
                 && lstLateFee.size()>0  && lstLateFee[0].Late_Fees__c != null  
             ) 
            {
               if('Payment Made'.equalsIgnoreCase(eventName) || 'Payment Approved'.equalsIgnoreCase(eventName))
               {
                   if( admissionPaymentTranscationDate !=null )
                    {
                        if(lstLateFee.size()>0 && lstLateFee[0].Late_Fees__c != null && date.valueOf(lstLateFee[0].Start_Date__c) <= admissionPaymentTranscationDate && date.valueOf(lstLateFee[0].End_Date__c) >= admissionPaymentTranscationDate )
                        {
                            lstOppLineItemsToInsert.add(CreateLateFeeLineItem(LateFeeAmount,mapPricebook,objOpps));
                        }
                    }    
               }else if('Email Verified'.equalsIgnoreCase(eventName) || 'Mobile Verified'.equalsIgnoreCase(eventName))
               {
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(LateFeeAmount,mapPricebook,objOpps));
               }else if('Document Approved'.equalsIgnoreCase(eventName) )
               {
                    if(objAccount.nm_DocumentSubmittedDate__c !=null)
                    {
                        if(date.valueOf(lstLateFee[0].Start_Date__c) <= date.valueOf(objAccount.nm_DocumentSubmittedDate__c) && date.valueOf(lstLateFee[0].End_Date__c) >= date.valueOf(objAccount.nm_DocumentSubmittedDate__c))
                        {
                            lstOppLineItemsToInsert.add(CreateLateFeeLineItem(LateFeeAmount,mapPricebook,objOpps));
                        }
                     } 
               }else if('Document Submitted'.equalsIgnoreCase(eventName)){
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(LateFeeAmount,mapPricebook,objOpps));
               }else if('service Change'.equalsIgnoreCase(eventName))
               {
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(LateFeeAmount,mapPricebook,objOpps));
               }else if('Additional Charge'.equalsIgnoreCase(eventName))
               {
                   lstOppLineItemsToInsert.add(CreateLateFeeLineItem(LateFeeAmount,mapPricebook,objOpps));
               }
            }
        }
        
        if(lstOppLineItemsToInsert.size()>0)
        {
           insert lstOppLineItemsToInsert;  
        }else{
            pendingLateFee = 0;
        }
        
        //check Late Fee Slab is ON only then Update Opportunity Stage To Pending or Payment Made depending on Pending Amount
        if(pendingLateFee !=null && pendingLateFee > 0 && lstLateFee !=null && lstLateFee.size()>0 && lstOppLineItemsToInsert.size()>0)
        {
            //UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpps.id);
        }
        return pendingLateFee;
       
    }*/
   public decimal CreateLateFeeProduct(Opportunity objOpps,String eventName)
    {
        // calculate Late Fee
        decimal LateFeeAmount = 0.0;
        decimal AlreadyPaidLateFeeAmt = 0.0;
        decimal pendingLateFee = 0.0;
        decimal admissionPaidAmount = 0.0;
        boolean isCertificate = false;   
        boolean isLateFeeApplicable = false;        
        boolean admissionLatefeeMBAWX = false;        
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        List<OpportunityLineItem> lstOppLineItemsToInsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOppLineItemsToupdate = new List<OpportunityLineItem>();
        Date admissionPaymentTranscationDate ;
        set<String> setOfOppsId = new set<String>{objOpps.id};
        set<String> setOfAccountId = new set<String>{objOpps.AccountId};
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId);
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(objOpps.id) !=null ?  mapOfOppsIdVsPayments.get(objOpps.id) : new List<nm_Payment__c>();
        Map<Id,Account> mapOfOppsVsAccount = getOpportunityRelatedAccount(setOfAccountId);
        Account objAccount = mapOfOppsVsAccount.get(objOpps.AccountId);//query Account getting Document Submission Date
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        OpportunityLineItem objLatefee = new OpportunityLineItem();
        Late_Fee__c objLateFeeSlab = new Late_Fee__c();
        String categoryNote = null;
        // String strSession; 
        // decimal strYear;
        if(objAccount.nm_ChooseaProgram__c == 'Certificate Programs')
        {
            isCertificate = true;
        }  
        if(objAccount.nm_ChooseaProgram__c == 'Master Programs' && objAccount.Program_Type__c =='MBA (WX)' && objAccount.Days_Since_For_Admission_Payment__c==-1)
        {
            admissionLatefeeMBAWX = true;
            LateFeeAmount += Decimal.valueOf(Label.AdmissionLatefeeMBAWX).setScale(2);
        }
        
        if(objOpps.Is_Re_Registration_Payment__c) {
            categoryNote = 'Re-Registration';
        } else {
            // get Late Fee Records based Upon Late Fee Category
            if(objOpps.nm_Category__c =='Admission') { 
                categoryNote = 'Admission';
            } else if(objOpps.nm_Category__c == 'Lateral Admission') {
                categoryNote = 'Is Lateral';
            }
        }

        if(String.isNotBlank(categoryNote)) {
            lstLateFee = getLateFeeRecord(categoryNote,objAccount.nm_ChooseaProgram__c,objAccount.Program_Type__c,String.valueOf(objOpps.nm_Session__c),String.valueOf(objOpps.nm_Year__c));
        }

        System.debug('lstLateFee--->'+lstLateFee);
        if(lstLateFee.size() > 0) {
            objLateFeeSlab = lstLateFee[0];
            LateFeeAmount += objLateFeeSlab.Late_Fees__c;
            if(isCertificate) {
                LateFeeAmount += (LateFeeAmount * Decimal.valueOf(Label.Service_Tax));
            }
            System.debug('LateFeeAmount  --->'+LateFeeAmount  );
        }
        //check Already paid late in first slab while taking remaninig fee in second slab
        System.debug('lstOppsRelatedPayment--->'+lstOppsRelatedPayment);
        if(lstOppsRelatedPayment.size()>0)
        {
            for(nm_Payment__c objPayment : lstOppsRelatedPayment)
            {
                if((objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c == 'Waived Off' ) && objPayment.nm_PaymentType__c == 'Late Fees' )
                {
                    AlreadyPaidLateFeeAmt = AlreadyPaidLateFeeAmt + objPayment.nm_Amount__c;
                }
                if(objPayment.nm_PaymentType__c == 'Admission' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c == 'Waived Off' )) {
                    admissionPaymentTranscationDate = Date.valueOf(objPayment.nm_TransactionDate__c);
                    admissionPaidAmount += objPayment.nm_Amount__c;
                }
            }
        }
        System.debug('AlreadyPaidLateFeeAmt-->'+AlreadyPaidLateFeeAmt );
        // Insert late Fee record with pending Late Fee Amt in Second slab
        if(AlreadyPaidLateFeeAmt !=null && AlreadyPaidLateFeeAmt > 0 )
        {
            pendingLateFee = LateFeeAmount - AlreadyPaidLateFeeAmt;
        }else if(LateFeeAmount !=null && LateFeeAmount > 0) // Insert late Fee record for first slab
        {
            pendingLateFee = LateFeeAmount;
        }
        system.debug('setOfOppsId --->'+setOfOppsId  );    
        // avoid double Insert of Late Fee Product 
        system.debug('LateFeeAmount --->'+LateFeeAmount );
       
        list<OpportunityLineItem> lstlateoppitem = [select id,PricebookEntry.Product2Id,OpportunityId ,ActualSalePrice__c,Product_Name__c,
                                                       PriceBookEntryId ,UnitPrice,Quantity,
                                                       TotalPrice,ProgramName2__c,PricebookEntry.Name 
                                                       from OpportunityLineItem where OpportunityId !=null 
                                                       and OpportunityId=:setOfOppsId and Product_Name__c ='Late Fee' limit 1];  
                          
        if(lstlateoppitem.size() > 0) {
            objLatefee = lstlateoppitem[0];
        }
        System.debug('objLatefee--->'+lstlateoppitem.size());
       
        System.debug('objLatefee--->'+objLatefee);
        
        // Insert Late Fee Line Item if he has paid Registrtaion+Admission+Late Fee at Lead level and after Lead convert if Product is not inserted then allowed to insert product with paid Late fee
        if(AlreadyPaidLateFeeAmt !=null && AlreadyPaidLateFeeAmt > 0 && objLatefee.id==null )
        {
            lstOppLineItemsToInsert.add(CreateLateFeeLineItem(AlreadyPaidLateFeeAmt,mapPricebook,objOpps));
            System.debug('lstOppLineItemsToInsert--->'+lstOppLineItemsToInsert);
        }
        
        // create Late Fee Prodcut with  Remaining Late Fee on Document Approval,Admission Payment Approval and after Student login 
        if(pendingLateFee !=null && pendingLateFee > 0 && lstLateFee.size() > 0) {
            objLateFeeSlab = lstLateFee[0];
            // Insert Late Fee Product even if Mobile or Email is Verified in Late Fee Salb for following cases
            // Student Status not equal to Admission Document Approved or Provisional
            // also not Insert if Payment Already Done Or Closed Opps Stage
            System.debug('event Name-->'+eventName);
            if(((objAccount.nm_IsEmailVerified__c && objAccount.Is_Mobile_Verified__c && !objOpps.Is_Re_Registration_Payment__c) // for Admission Records
                ||
                (objOpps.Is_Re_Registration_Payment__c) // for Re-Reg Records
                ||
                (objAccount.nm_StudentStatus__c !='Confirmed'  && !objOpps.Is_Re_Registration_Payment__c)) 
                && objLateFeeSlab.Late_Fees__c != null) 
            {
                if(
                    (
                        ('Payment Made'.equalsIgnoreCase(eventName) || 'Payment Approved'.equalsIgnoreCase(eventName)) 
                        && admissionPaymentTranscationDate!= null && objLateFeeSlab.Late_Fees__c != null 
                        && Date.valueOf(objLateFeeSlab.Start_Date__c) <= admissionPaymentTranscationDate 
                        && Date.valueOf(objLateFeeSlab.End_Date__c) >= admissionPaymentTranscationDate
                    ) 
                    ||
                    (
                        'Document Approved'.equalsIgnoreCase(eventName) && objAccount.nm_DocumentSubmittedDate__c !=null 
                        && Date.valueOf(objLateFeeSlab.Start_Date__c) <= Date.valueOf(objAccount.nm_DocumentSubmittedDate__c) 
                        && Date.valueOf(objLateFeeSlab.End_Date__c) >= Date.valueOf(objAccount.nm_DocumentSubmittedDate__c) 
                    )
                    || 
                    (
                        'Email Verified'.equalsIgnoreCase(eventName) || 'Mobile Verified'.equalsIgnoreCase(eventName) 
                        || 'Document Submitted'.equalsIgnoreCase(eventName) || 'service Change'.equalsIgnoreCase(eventName) 
                        || 'Additional Charge'.equalsIgnoreCase(eventName)
                    )
                ) {
                    if(objLatefee.id != null && LateFeeAmount > objLatefee.ActualSalePrice__c) {
                        isLateFeeApplicable = true;
                        objLatefee.UnitPrice = LateFeeAmount;
                        objLatefee.ActualSalePrice__c = LateFeeAmount;
                    }
                    else if(objLatefee.id==null) {
                        lstOppLineItemsToInsert.add(CreateLateFeeLineItem(LateFeeAmount,mapPricebook,objOpps));
                    }
                }
            }
        }
        System.debug('lstOppLineItemsToInsert--->'+lstOppLineItemsToInsert);
        if(lstOppLineItemsToInsert.size()>0)
        {
            isLateFeeApplicable = true;
            try{
                insert lstOppLineItemsToInsert;  
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }else{
            if(objLatefee!=null && objLatefee.id!=null && isLateFeeApplicable)
            {
                lstOppLineItemsToupdate.add(objLatefee);
                try{
                    update lstOppLineItemsToupdate;
                }catch(DmlException e){
                    System.debug(e.getMessage());
                }
            }
        }

        // To set the lateFeeApplicable option true for additionalCharge Latefee check.
        // Added by Bala 10-10-2019
        System.debug('addLateFeeCheck ==>'+addLateFeeCheck);
        if(!isLateFeeApplicable && pendingLateFee > 0 && addLateFeeCheck) {
            isLateFeeApplicable = true;
        }

        System.debug('isLateFeeApplicable--->'+isLateFeeApplicable);
        if (isLateFeeApplicable) {
            if (objOpps.AdditionalAmountRecieved__c > 0 && objOpps.AdditionalAmountRecieved__c != null && objOpps.AdditionalAmountRecieved__c > pendingLateFee)
            {
                pendingLateFee = 0;
            } else {
                return pendingLateFee;
            }
        } else {
            pendingLateFee = 0;
        }
        
        System.debug('pendingLateFee --->'+pendingLateFee );
        return pendingLateFee;
    }
    /* no more in use
      // Method Called from nmAccounttiggerHandler and OpportunityTriggerHandler
    public void UpdateOpportunityLineItemAfterFeetypeChange(Opportunity objOpportunity)
    {
        Boolean serviceTaxApplicable = false;
        list<OpportunityLineItem> lstOppLineItems = new list<OpportunityLineItem>();
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        // query Account related to Opportunity to get Tag Price Book Id
        set<String> setOfAccountId = new Set<String>{objOpportunity.AccountId};
         Map<String,Account> mapOfOppsVsAccount = getOpportunityRelatedAccount(setOfAccountId);
        Account objAccount = mapOfOppsVsAccount.get(objOpportunity.AccountId);
        set<String> setOfOppsId = new set<String>{objOpportunity.id};
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId );
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(objOpportunity.id) !=null ?  mapOfOppsIdVsPayments.get(objOpportunity.id) : new List<nm_Payment__c>();
        List<nm_Payment__c>lstPaymentToUpdate = new List<nm_Payment__c>();
        OpportunityLineItem objLineItemToUpdate = new OpportunityLineItem();
        OpportunityLineItem objLineItemServiceTaxToUpdate = new OpportunityLineItem();// update Service Tax after Fee Type Change 
        system.debug('objAccount'+objAccount );
        System.debug('Fee Type ------->'+objOpportunity.nm_Fee_Type__c);
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        // calculate Late Fee
       
         
        if(mapPricebook!=null)
        {
            system.debug('Enter in MappriceBook');
            // get all Opportunity Line Item related to Opportunity to update Semester Line Item after Fee Type Changes 
            Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
            List<OpportunityLineItem> lstOpportunitylineItem = mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id);
           
           // create Semester Line Iteam 
            string strKey = objOpportunity.nm_Program__c + '-' + objOpportunity.nm_Semester__c;
            System.debug('objOpportunity.nm_Program__c'+objOpportunity.nm_Program__c);
            boolean admissionpayment = false;
           if(lstOpportunitylineItem.size()>0)
            {
                for(OpportunityLineItem objLineIteam : lstOpportunitylineItem )
                {
                    if(objLineIteam.Product_Name__c.contains('Semester'))
                    {
                        objLineItemToUpdate = objLineIteam;// for Semester Fees 
                       
                    }
                    if(objLineIteam.Product_Name__c.contains('Certificate Service Tax'))
                    {
                        objLineItemServiceTaxToUpdate = objLineIteam;// for Service Tax 
                        serviceTaxApplicable = true;
                        System.debug('objLineItemServiceTaxToUpdate'+objLineItemServiceTaxToUpdate);
                    }
                }
                
                if(lstOppsRelatedPayment.size()>0)
                {
                    lstOppsRelatedPayment.sort();
                    for(nm_Payment__c objPayment : lstOppsRelatedPayment)
                    {
                        if(objPayment.nm_PaymentType__c == 'Admission' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made'))
                        {
                            admissionpayment = true; // for checking Admission Payment received or not .only if admission not received then update Installment ref on Installment Payment 
                        }
                    }
                    
                    for(nm_Payment__c objPayment : lstOppsRelatedPayment)
                    {
                        
                        if(objPayment.nm_PaymentType__c == 'Installment' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made') && !admissionpayment && (objOpportunity.nm_Fee_Type__c == null || objOpportunity.nm_Fee_Type__c == 'registration' || (objAccount.nm_DefencePersonnel__c != null && objAccount.nm_DefencePersonnel__c == 'Yes')))
                        {
                            objPayment.nm_Installment_Payment_Ref__c ='Installment-admission';
                            lstPaymentToUpdate.add(objPayment);
                        }else if(objPayment.nm_PaymentType__c == 'Installment' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made') && !admissionpayment && objOpportunity.nm_Fee_Type__c != null)
                        {
                            objPayment.nm_Installment_Payment_Ref__c ='Installment-'+ objOpportunity.nm_Fee_Type__c;
                            lstPaymentToUpdate.add(objPayment);
                        }
                    }
                    if(lstPaymentToUpdate.size()>0)
                    {
                        update lstPaymentToUpdate;
                    }
                }
            }
            if(objLineItemToUpdate !=null )
            {
                objLineItemToUpdate.UnitPrice = Unitprice(objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,objAccount.nmStudent_Program__c,mapPricebook,objAccount.OldStudentForExecutive__c);
                objLineItemToUpdate.ActualSalePrice__c = ActualUnitprice(objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,objOpportunity.Program_Name__c,mapPricebook,objAccount.OldStudentForExecutive__c);                             
                lstOppLineItems.add(objLineItemToUpdate);
                System.debug('objLineItemToUpdate.ActualSalePrice__c'+objLineItemToUpdate.ActualSalePrice__c);
            }
            
            // for Advanced Certificate Program Service tax
            if(serviceTaxApplicable)
            {
              objLineItemServiceTaxToUpdate.UnitPrice = (objLineItemToUpdate.UnitPrice)*Decimal.valueOf(Label.Service_Tax);
               if(objOpportunity.nm_Fee_Type__c.contains('Considered') && objOpportunity.nm_Fee_Type__c!=null)
                {
                    objLineItemServiceTaxToUpdate.ActualSalePrice__c = 0;
                }
                else
                {
                    objLineItemServiceTaxToUpdate.ActualSalePrice__c = objLineItemToUpdate.ActualSalePrice__c*Decimal.valueOf(Label.Service_Tax);
                }
               
             
                lstOppLineItems.add(objLineItemServiceTaxToUpdate);
            }
        }
        
        if(lstOppLineItems.size()>0 )
        {
            System.debug('lstOppLineItems---'+lstOppLineItems);
            update lstOppLineItems;
            // after Product Price change calculate Pending payment and update Opportunity Stage to Payment made or Pending Payment depending on pending Payment 
            UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpportunity.id,'FeeType Change');
        }
        
              
    }*/
    // Method Called from nmAccounttiggerHandler and OpportunityTriggerHandler     
 /*  public void UpdateOpportunityLineItemAfterFeetypeChange(Opportunity objOpportunity, String Program)
    {
        Boolean serviceTaxApplicable = false;
        Boolean LiveLectureApplicable = false;
        list<OpportunityLineItem> lstOppLineItems = new list<OpportunityLineItem>();
        list<OpportunityLineItem> lstOppLineItemstoDelete = new list<OpportunityLineItem>();
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        // query Account related to Opportunity to get Tag Price Book Id
        set<String> setOfAccountId = new Set<String>{objOpportunity.AccountId};
        Map<Id,Account> mapOfOppsVsAccount = getOpportunityRelatedAccount(setOfAccountId);
        Account objAccount = mapOfOppsVsAccount.get(objOpportunity.AccountId);
        set<String> setOfOppsId = new set<String>{objOpportunity.id};
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId );
        List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(objOpportunity.id) !=null ?  mapOfOppsIdVsPayments.get(objOpportunity.id) : new List<nm_Payment__c>();
        List<nm_Payment__c>lstPaymentToUpdate = new List<nm_Payment__c>();
        OpportunityLineItem objLineItemToUpdate = new OpportunityLineItem();
        OpportunityLineItem objLineItemServiceTaxToUpdate = new OpportunityLineItem();// update Service Tax after Fee Type Change 
        OpportunityLineItem objLineItemLiveLectures = new OpportunityLineItem();
        system.debug('objAccount'+objAccount );
        System.debug('Fee Type ------->'+objOpportunity.nm_Fee_Type__c);
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        // calculate Late Fee
                     
        if(mapPricebook!=null)
        {
            system.debug('Enter in MappriceBook');
            // get all Opportunity Line Item related to Opportunity to update Semester Line Item after Fee Type Changes 
            Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
            List<OpportunityLineItem> lstOpportunitylineItem = mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id);
           
           // create Semester Line Iteam 
            string strKey = objOpportunity.nm_Program__c + '-' + objOpportunity.nm_Semester__c;
            System.debug('objOpportunity.nm_Program__c'+objOpportunity.nm_Program__c);
            boolean admissionpayment = false;
            system.debug('lstOpportunitylineItem.size()'+lstOpportunitylineItem.size());
           if(lstOpportunitylineItem.size()>0)
            {
                for(OpportunityLineItem objLineIteam : lstOpportunitylineItem )
                {
                    if(objLineIteam.Product_Name__c.contains('Semester'))
                    {
                        objLineItemToUpdate = objLineIteam;// for Semester Fees 
                       
                    }
                    if(objLineIteam.Product_Name__c.contains('Certificate Service Tax'))
                    {
                        objLineItemServiceTaxToUpdate = objLineIteam;// for Service Tax 
                        serviceTaxApplicable = true;
                        System.debug('objLineItemServiceTaxToUpdate'+objLineItemServiceTaxToUpdate);
                    }
                    if(objLineIteam.Product_Name__c.contains('Live Lectures'))
                    {
                        if(objOpportunity.LiveLecturesType__c!='')
                        {
                            objLineItemLiveLectures = objLineIteam;
                            LiveLectureApplicable = true;
                            System.debug('objLineItemLiveLectures'+objLineItemLiveLectures);
                            System.debug('LiveLectureApplicable'+LiveLectureApplicable);
                        }else
                        {
                            LiveLectureApplicable = false;
                            lstOppLineItemstoDelete.add(objLineIteam);
                            System.debug('LiveLectureApplicable'+LiveLectureApplicable);
                        }
                        
                    }
                }
                
                if(lstOppsRelatedPayment.size()>0)
                {
                    lstOppsRelatedPayment.sort();
                    for(nm_Payment__c objPayment : lstOppsRelatedPayment)
                    {
                        if(objPayment.nm_PaymentType__c == 'Admission' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made'))
                        {
                            admissionpayment = true; // for checking Admission Payment received or not .only if admission not received then update Installment ref on Installment Payment 
                        }
                    }
                    
                    for(nm_Payment__c objPayment : lstOppsRelatedPayment)
                    {
                        
                        if(objPayment.nm_PaymentType__c == 'Installment' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made') && !admissionpayment && (objOpportunity.nm_Fee_Type__c == null || objOpportunity.nm_Fee_Type__c == 'registration' || (objAccount.nm_DefencePersonnel__c != null && objAccount.nm_DefencePersonnel__c == 'Yes')))
                        {
                            objPayment.nm_Installment_Payment_Ref__c ='Installment-admission';
                            lstPaymentToUpdate.add(objPayment);
                        }else if(objPayment.nm_PaymentType__c == 'Installment' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made') && !admissionpayment && objOpportunity.nm_Fee_Type__c != null)
                        {
                            objPayment.nm_Installment_Payment_Ref__c ='Installment-'+ objOpportunity.nm_Fee_Type__c;
                            lstPaymentToUpdate.add(objPayment);
                        }
                    }
                    if(lstPaymentToUpdate.size()>0)
                    {
                        update lstPaymentToUpdate;
                    }
                }
            }
            
            if(objLineItemToUpdate !=null )
            {
               // objLineItemToUpdate.UnitPrice = Unitprice(objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,Program,mapPricebook,objAccount.OldStudentForExecutive__c);
              //  objLineItemToUpdate.ActualSalePrice__c = ActualUnitprice(objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,Program,mapPricebook,objAccount.OldStudentForExecutive__c);                             
                lstOppLineItems.add(objLineItemToUpdate);
                System.debug('objLineItemToUpdate.ActualSalePrice__c'+objLineItemToUpdate.ActualSalePrice__c);
                System.debug('Program'+Program);
            }
            
            // for Advanced Certificate Program Service tax
            if(serviceTaxApplicable)
            {
              objLineItemServiceTaxToUpdate.UnitPrice = (objLineItemToUpdate.UnitPrice)*Decimal.valueOf(Label.Service_Tax);
               if(objOpportunity.nm_Fee_Type__c.contains('Considered') && objOpportunity.nm_Fee_Type__c!=null)
                {
                    objLineItemServiceTaxToUpdate.ActualSalePrice__c = 0;
                }
                else
                {
                    objLineItemServiceTaxToUpdate.ActualSalePrice__c = objLineItemToUpdate.ActualSalePrice__c*Decimal.valueOf(Label.Service_Tax);
                }
               
             
                lstOppLineItems.add(objLineItemServiceTaxToUpdate);
            }
            if(LiveLectureApplicable && objLineItemLiveLectures!=null)
            {
                Decimal unitpriceLiveLecture = ActualUnitpriceLiveLecture(objOpportunity,mapPricebook);
                objLineItemLiveLectures.UnitPrice = unitpriceLiveLecture ;
                objLineItemLiveLectures.ActualSalePrice__c = unitpriceLiveLecture;
                lstOppLineItems.add(objLineItemLiveLectures);
            }
        }
        if(lstOppLineItemstoDelete.size()>0)
        {
            delete lstOppLineItemstoDelete;
        }
        system.debug('lstOppLineItems--->'+lstOppLineItems);
        if(lstOppLineItems.size()>0 )
        {
            update lstOppLineItems;
            Opportunity objoppt =  UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpportunity.id,'FeeType Change');          
             System.debug('objoppt.StageName---> '+objoppt.StageName);         
             System.debug('objoppt.Processed__c---> '+objoppt.Processed__c);
            
           if(objoppt.StageName=='Closed Won' && objoppt.Processed__c== true &&  !objoppt.nm_Fee_Type__c.contains('-Considered')) 
            {        
                 CheckforDebitCreditEntry ( objoppt,setOfOppsId);
            }
           
        }
        
              
    }*/
    // Method Called from nmAccounttiggerHandler and OpportunityTriggerHandler      
   public void UpdateOpportunityLineItemAfterFeetypeChange(Opportunity objOpportunity, nm_Program__c objProgram, String specialEvent, String specialPriorValue)
   {
       boolean serviceTaxApplicable = false;
       boolean LiveLectureApplicable = false;
       boolean Backlogproductfound = false;
       boolean LiveLectureproductfound = false;
       boolean BacklogproductApplicable = false;
       Opportunity objoppt = new Opportunity();
       list<OpportunityLineItem> lstOppLineItems = new list<OpportunityLineItem>();
       list<OpportunityLineItem> lstOppLineItemstoInsert = new list<OpportunityLineItem>();
       List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
       // query Account related to Opportunity to get Tag Price Book Id
       set<String> setOfAccountId = new Set<String>{objOpportunity.AccountId};
       Map<Id,Account> mapOfOppsVsAccount = getOpportunityRelatedAccount(setOfAccountId);
       Account objAccount = mapOfOppsVsAccount.get(objOpportunity.AccountId);
       set<String> setOfOppsId = new set<String>{objOpportunity.id};
       Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId );
       List<nm_Payment__c> lstOppsRelatedPayment = mapOfOppsIdVsPayments.get(objOpportunity.id) !=null ?  mapOfOppsIdVsPayments.get(objOpportunity.id) : new List<nm_Payment__c>();
       List<nm_Payment__c>lstPaymentToUpdate = new List<nm_Payment__c>();
       OpportunityLineItem objLineItemToUpdate = new OpportunityLineItem();
       OpportunityLineItem objLineItemServiceTaxToUpdate = new OpportunityLineItem();// update Service Tax after Fee Type Change 
       OpportunityLineItem objLineItemLiveLectures = new OpportunityLineItem();
        OpportunityLineItem objLineItemBacklog = new OpportunityLineItem();
        OpportunityLineItem objLineItemBacklogInsert = new OpportunityLineItem();
       OpportunityLineItem objLineItemLiveLecturesInsert = new OpportunityLineItem();
       system.debug('objAccount'+objAccount );
       System.debug('Fee Type ------->'+objOpportunity.nm_Fee_Type__c);
       System.debug('LiveLecturesType__c ------->'+objOpportunity.LiveLecturesType__c);
       Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
       Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
       // calculate Late Fee
                    
       if(mapPricebook!=null)
       {
           system.debug('Enter in MappriceBook');
           // get all Opportunity Line Item related to Opportunity to update Semester Line Item after Fee Type Changes 
           // System.debug('setOfOppsId-->'+setOfOppsId );
           Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
          // system.debug('mapOfOppsIdVsOpportunityLineItem --->'+mapOfOppsIdVsOpportunityLineItem );
           List<OpportunityLineItem> lstOpportunitylineItem = mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id);
          
          // create Semester Line Iteam 
           string strKey = objOpportunity.nm_Program__c + '-' + objOpportunity.nm_Semester__c;
           System.debug('objOpportunity.nm_Program__c'+objOpportunity.nm_Program__c);
           boolean admissionpayment = false;
        //   system.debug('lstOpportunitylineItem--->'+lstOpportunitylineItem);
          if(lstOpportunitylineItem.size()>0)
           {
               for(OpportunityLineItem objLineIteam : lstOpportunitylineItem )
               {
                   if(objLineIteam.Product_Name__c.contains('Semester')|| objLineIteam.Product_Name__c.startswith('Term'))
                   {
                       objLineItemToUpdate = objLineIteam;// for Semester Fees 
                      
                   }
                   if(objLineIteam.Product_Name__c.contains('Certificate Service Tax') || objLineIteam.Product_Name__c.contains('GST'))
                   {
                       objLineItemServiceTaxToUpdate = objLineIteam;// for Service Tax 
                       serviceTaxApplicable = true;
                       System.debug('objLineItemServiceTaxToUpdate'+objLineItemServiceTaxToUpdate);
                   }
                   if(objLineIteam.Product_Name__c.contains('Live Lectures'))
                   {
                       LiveLectureproductfound = true;
                    //    if(objOpportunity.LiveLecturesType__c!='' && objOpportunity.LiveLecturesType__c!='No' )
                    //    {
                           objLineItemLiveLectures = objLineIteam;
                           LiveLectureApplicable = true;
                           
                           System.debug('objLineItemLiveLectures'+objLineItemLiveLectures);
                    //    }
                       
                   }
                   if(objLineIteam.Product_Name__c.contains('Backlog'))
                   {
                       Backlogproductfound = true;
                    //    if(objOpportunity.BacklogList__c!='' )
                    //    {
                           System.debug('objOpportunity.BacklogList__c -----> '+objOpportunity.BacklogList__c);
                           objLineItemBacklog = objLineIteam;
                           BacklogproductApplicable = true;                          
                           System.debug('objLineItemBacklog'+objLineItemBacklog);
                    //    }
                       
                   }
                       
               }
               
               if(lstOppsRelatedPayment.size()>0)
               {
                   lstOppsRelatedPayment.sort();
                   for(nm_Payment__c objPayment : lstOppsRelatedPayment)
                   {
                       if(objPayment.nm_PaymentType__c == 'Admission' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made'))
                       {
                           admissionpayment = true; // for checking Admission Payment received or not .only if admission not received then update Installment ref on Installment Payment 
                       }
                   }
                   
                   for(nm_Payment__c objPayment : lstOppsRelatedPayment)
                   {
                       
                       if(objPayment.nm_PaymentType__c == 'Installment' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made') && !admissionpayment && (objOpportunity.nm_Fee_Type__c == null || objOpportunity.nm_Fee_Type__c == 'registration' || (objAccount.nm_DefencePersonnel__c != null && objAccount.nm_DefencePersonnel__c == 'Yes')))
                       {
                           objPayment.nm_Installment_Payment_Ref__c ='Installment-admission';
                           lstPaymentToUpdate.add(objPayment);
                       }else if(objPayment.nm_PaymentType__c == 'Installment' && (objPayment.nm_PaymentStatus__c =='Payment Approved' || objPayment.nm_PaymentStatus__c == 'Payment Made') && !admissionpayment && objOpportunity.nm_Fee_Type__c != null)
                       {
                           objPayment.nm_Installment_Payment_Ref__c ='Installment-'+ objOpportunity.nm_Fee_Type__c;
                           lstPaymentToUpdate.add(objPayment);
                       }
                   }
                   if(lstPaymentToUpdate.size()>0)
                   {
                       update lstPaymentToUpdate;
                   }
               }
           }
           
           if(objLineItemToUpdate !=null && objLineItemToUpdate.id!=null )
           {
               objLineItemToUpdate.UnitPrice = Unitprice(objOpportunity,objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,objProgram,mapPricebook,objAccount.OldStudentForExecutive__c);
               objLineItemToUpdate.ActualSalePrice__c = ActualUnitprice(objOpportunity ,objOpportunity.nm_Fee_Type__c,objAccount.nm_DefencePersonnel__c,strKey,objProgram,mapPricebook,objAccount.OldStudentForExecutive__c);                             
               lstOppLineItems.add(objLineItemToUpdate);
               System.debug('objLineItemToUpdate.ActualSalePrice__c'+objLineItemToUpdate.ActualSalePrice__c);
              // System.debug('Program'+Program);
           }
           
           // for Advanced Certificate Program Service tax
           if(serviceTaxApplicable)
           {
               Decimal LiveLectureUnitPrice = UnitpriceLiveLecture(objOpportunity,objOpportunity.LiveLecturesType__c,mapPricebook);
               
               objLineItemServiceTaxToUpdate.UnitPrice = (LiveLectureUnitPrice + objLineItemToUpdate.UnitPrice)*Decimal.valueOf(Label.Service_Tax);
               Decimal LiveLectureActualSalesPrice = ActualUnitpriceLiveLecture(objOpportunity,mapPricebook);
               if(objOpportunity.nm_Fee_Type__c.contains('Considered') && objOpportunity.nm_Fee_Type__c!=null)
               {
                   objLineItemServiceTaxToUpdate.ActualSalePrice__c = LiveLectureActualSalesPrice * Decimal.valueOf(Label.Service_Tax);
               }
               else
               {
                   objLineItemServiceTaxToUpdate.ActualSalePrice__c = (LiveLectureActualSalesPrice + objLineItemToUpdate.ActualSalePrice__c)*Decimal.valueOf(Label.Service_Tax);
               }
              
            
               lstOppLineItems.add(objLineItemServiceTaxToUpdate);
           }
           if(LiveLectureApplicable)
           {
             // Decimal unitprice = ActualUnitpriceLiveLecture(objOpportunity,mapPricebook);
               objLineItemLiveLectures.UnitPrice = UnitpriceLiveLecture(objOpportunity,objOpportunity.LiveLecturesType__c,mapPricebook); 
               objLineItemLiveLectures.ActualSalePrice__c = ActualUnitpriceLiveLecture(objOpportunity,mapPricebook);
                lstOppLineItems.add(objLineItemLiveLectures);
           }
            if(BacklogproductApplicable)
           {
              Decimal BacklogPrice = mapPricebook.containskey('Backlog') ? mapPricebook.get('Backlog').UnitPrice : 0;   
              Decimal nosubj=0;
              
              nosubj = BacklogUnitPrice(objOpportunity.BacklogList__c); 

              Decimal unitprice = BacklogPrice * nosubj;
              objLineItemBacklog.UnitPrice = unitprice; 
              objLineItemBacklog.ActualSalePrice__c = unitprice;
              lstOppLineItems.add(objLineItemBacklog);
           }
           system.debug('LiveLectureproductfound--->'+LiveLectureproductfound);
           system.debug('objOpportunity.LiveLecturesType__c--->'+objOpportunity.LiveLecturesType__c);
        if(LiveLectureproductfound==false 
           && ((String.isNotBlank(objOpportunity.LiveLecturesType__c) 
          ) 
           && objOpportunity.LiveLecturesType__c!='No'))            
           
          {
               system.debug('LiveLectureproductfound--->'+LiveLectureproductfound);  
            //   Decimal unitprice = ActualUnitpriceLiveLecture(objOpportunity,mapPricebook) ;              
               objLineItemLiveLecturesInsert.OpportunityId = objOpportunity.id;
               objLineItemLiveLecturesInsert.PriceBookEntryId = mapPricebook.get('Live Lectures').id;
               objLineItemLiveLecturesInsert.Quantity = 1.00;
               objLineItemLiveLecturesInsert.UnitPrice =UnitpriceLiveLecture(objOpportunity,objOpportunity.LiveLecturesType__c,mapPricebook);
               objLineItemLiveLecturesInsert.ActualSalePrice__c = ActualUnitpriceLiveLecture(objOpportunity,mapPricebook);

               lstOppLineItemstoInsert.add(objLineItemLiveLecturesInsert);
           }
            if(Backlogproductfound==false 
           && String.isNotBlank(objOpportunity.BacklogList__c) 
          )            
           {
              system.debug('Backlogproductfound--->'+Backlogproductfound);  
              Decimal BacklogPrice = mapPricebook.containskey('Backlog') ? mapPricebook.get('Backlog').UnitPrice : 0;   
              Decimal nosubj=0;

              nosubj = BacklogUnitPrice(objOpportunity.BacklogList__c); 

              Decimal unitprice = BacklogPrice * nosubj;            
               objLineItemBacklogInsert.OpportunityId = objOpportunity.id;
               objLineItemBacklogInsert.PriceBookEntryId = mapPricebook.get('Backlog').id;
               objLineItemBacklogInsert.Quantity = 1.00;
               objLineItemBacklogInsert.UnitPrice = unitprice;
               objLineItemBacklogInsert.ActualSalePrice__c = unitprice;

               lstOppLineItemstoInsert.add(objLineItemBacklogInsert);
           }
       }
       if(lstOppLineItemstoInsert.size()>0)
       {
           insert lstOppLineItemstoInsert;
       }
      system.debug('lstOppLineItems-->'+lstOppLineItems);
       if(lstOppLineItems.size()>0 )
       {
           update lstOppLineItems;
           if(String.isNotBlank(specialEvent) && specialEvent == 'LiveLectureTypeChange') {
               objoppt =  UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpportunity.id,'FeeType Change', specialEvent, specialPriorValue);          
            } else {
                objoppt =  UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpportunity.id,'FeeType Change', null, null);    
           }
            System.debug('objoppt.StageName---> '+objoppt.StageName);         
            System.debug('objoppt.Processed__c---> '+objoppt.Processed__c);
           
          if(objoppt.StageName=='Closed Won' && objoppt.Processed__c== true &&  !objoppt.nm_Fee_Type__c.contains('-Considered')) 
           {        
                CheckforDebitCreditEntry ( objoppt,setOfOppsId);
           }
          
       }    
   }
     public Decimal BacklogUnitPrice (String BacklogList)
{
    Set<String> setofCourse = new Set<String>();
    List<String> lstCourseList = new List<String>();
    Decimal nosubj=0; 
        if(BacklogList!=null && BacklogList!='')
        {
            lstCourseList =  BacklogList.split(',');
        }                    
        if(lstCourseList.size()>0) 
        {
            setofCourse.addAll(lstCourseList);
        }
        system.debug('SetofCourse'+setofCourse.size());
        nosubj = setofCourse.size()>0?setofCourse.size():0;
        system.debug('nosubj--->'+nosubj);

        return nosubj;
} 
    
public void DeleteOpportunityLineItemAfterProgramChange(Opportunity objOpportunity)
    {
      
            list<OpportunityLineItem> lstOppLineItemstodelete = new list<OpportunityLineItem>();               
            OpportunityLineItem objLineItemServiceTaxToDelete = new OpportunityLineItem();
            set<String> setOfOppsId = new set<String>{objOpportunity.id};
            Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId );
           // List<OpportunityLineItem> lstOpportunitylineItem = mapOfOppsIdVsOpportunityLineItem.get(objOpportunity.id);
            List<OpportunityLineItem> lstOpportunitylineItem =[select id,Product_Name__c from OpportunityLineItem where (Product_Name__c ='Certificate Service Tax' OR Product_Name__c ='GST') and OpportunityID IN:setOfOppsId ];
           boolean readytodelete  = false;
     System.debug('lstOpportunitylineItem.size()'+lstOpportunitylineItem.size());
           if(lstOpportunitylineItem.size()>0)
            {
           System.debug('lstOpportunitylineItem.size()'+lstOpportunitylineItem.size());
                for(OpportunityLineItem objLineIteam : lstOpportunitylineItem )
                {
                System.debug('loop1');
                System.debug('objOpportunity.Program_Name__c'+objOpportunity.Program_Name__c);
                    
                    
                        if(objLineIteam.Product_Name__c.contains('Certificate Service Tax') || objLineIteam.Product_Name__c.contains('GST'))
                        {                        
                                objLineItemServiceTaxToDelete = objLineIteam;
                                System.debug('objOpportunity.Program_Name__c'+objOpportunity.Program_Name__c);
                                System.debug('Delete the Line item'); 
                                 readytodelete  = true;  
                                System.debug('readytodelete'+readytodelete);                           
                        }
                    
                }
                
            }                     
            
        // for Advanced Certificate Program Service tax
       
    if (readytodelete==true)
        {   System.debug('objLineItemServiceTaxToDelete'+objLineItemServiceTaxToDelete);
            lstOppLineItemstodelete.add(objLineItemServiceTaxToDelete);
            System.debug('lstOppLineItemstodelete'+lstOppLineItemstodelete);
            System.debug('readytodelete'+readytodelete);
        }              

    if(lstOppLineItemstodelete.size()>0 && lstOppLineItemstodelete.size()!=null)
        {
            Delete lstOppLineItemstodelete;
        }   
              
    }
  /*Method not in use 
  public boolean checkAlreadyLateFeeProductInsertedForCurrentSlab(String OppsId, decimal LateFeeAmount,List<nm_Payment__c> lstOppsRelatedPayment,boolean isCertificate)
  {
    set<String> setOfOppsId = new set<String>{OppsId};
    Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId);
    List<OpportunityLineItem> lstOpportunityLineItem = mapOfOppsIdVsOpportunityLineItem.get(OppsId) !=null ?mapOfOppsIdVsOpportunityLineItem.get(OppsId) : new  List<OpportunityLineItem>();
    decimal lateFeeProductPrice =0.0;
    decimal lateFee = 0.0;
    List<OpportunityLineItem> lstOpportunityLineItemToDelete = new List<OpportunityLineItem>();
    Map<Decimal,OpportunityLineItem> mapOfAmountAndOpportunityLineItem = new Map<Decimal,OpportunityLineItem>();
    
    if(lstOpportunityLineItem.size()>0)
    {
        for(OpportunityLineItem objLineIteam : lstOpportunitylineItem )
        {
            if(objLineIteam.Product_Name__c.contains('Late Fee'))
            {
                lateFeeProductPrice +=objLineIteam.UnitPrice;
                mapOfAmountAndOpportunityLineItem.put(objLineIteam.UnitPrice,objLineIteam);
            }
        }
    }
    if(lstOppsRelatedPayment.size()>0)
    {
        for(nm_Payment__c objPayment : lstOppsRelatedPayment)
        {
            if(objPayment.nm_PaymentType__c =='Late Fees')
            {
                lateFee +=objPayment.nm_Amount__c;
            }
        }
    }
    
    
        
    // loop for checking if previous Late Fee Slab Payment is not done and he came in Second slab then delete old Late Fee Product and Insert new Late fee Product 
    if(!mapOfAmountAndOpportunityLineItem.IsEmpty())
    {
        if(LateFeeAmount>0 )
        {
            if(LateFeeAmount !=null && LateFeeAmount > 0)
            {
                if(LateFeeAmount > lateFeeProductPrice   )
                {
                    lstOpportunityLineItemToDelete.add(mapOfAmountAndOpportunityLineItem.get(lateFeeProductPrice));
                }
            }
        }
    }
    
    if(lstOpportunityLineItemToDelete.size()>0)
    {
        delete lstOpportunityLineItemToDelete;
    }
    system.debug('lateFeeProductPrice--->'+lateFeeProductPrice);
     system.debug('LateFeeAmount --->'+LateFeeAmount );
    if(LateFeeAmount >0 )
    {
        if(LateFeeAmount !=null && LateFeeAmount > 0 )
        {
        
            if(LateFeeAmount > lateFeeProductPrice)
            {
                return false;
            }
        }
    } 
          
    return true;  
  }*/
    
  /* pha public boolean checkAlreadyLateFeeProductInsertedForCurrentSlab(String OppsId,List<Late_Fee__c> lstLateFee,List<nm_Payment__c> lstOppsRelatedPayment,boolean isCertificate)
  {
    set<String> setOfOppsId = new set<String>{OppsId};
    Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId);
    List<OpportunityLineItem> lstOpportunityLineItem = mapOfOppsIdVsOpportunityLineItem.get(OppsId) !=null ?mapOfOppsIdVsOpportunityLineItem.get(OppsId) : new  List<OpportunityLineItem>();
    decimal lateFeeProductPrice =0.0;
    decimal lateFee = 0.0;
    List<OpportunityLineItem> lstOpportunityLineItemToDelete = new List<OpportunityLineItem>();
    Map<Decimal,OpportunityLineItem> mapOfAmountAndOpportunityLineItem = new Map<Decimal,OpportunityLineItem>();
    
    if(lstOpportunityLineItem.size()>0)
    {
        for(OpportunityLineItem objLineIteam : lstOpportunitylineItem )
        {
            if(objLineIteam.Product_Name__c.contains('Late Fee'))
            {
                lateFeeProductPrice +=objLineIteam.UnitPrice;
                mapOfAmountAndOpportunityLineItem.put(objLineIteam.UnitPrice,objLineIteam);
            }
        }
    }
    if(lstOppsRelatedPayment.size()>0)
    {
        for(nm_Payment__c objPayment : lstOppsRelatedPayment)
        {
            if(objPayment.nm_PaymentType__c =='Late Fees')
            {
                lateFee +=objPayment.nm_Amount__c;
            }
        }
    }
    
    
        
    // loop for checking if previous Late Fee Slab Payment is not done and he came in Second slab then delete old Late Fee Product and Insert new Late fee Product 
    if(!mapOfAmountAndOpportunityLineItem.IsEmpty())
    {
        if(lstLateFee.size()>0 )
        {
            if(lstLateFee[0].Late_Fees__c !=null && lstLateFee[0].Late_Fees__c > 0)
            {
                if(lstLateFee[0].Late_Fees__c > lateFeeProductPrice && !isCertificate && lateFee ==0)
                {
                    lstOpportunityLineItemToDelete.add(mapOfAmountAndOpportunityLineItem.get(lateFeeProductPrice));
                }else if( lateFee ==0 && isCertificate && ((lstLateFee[0].Late_Fees__c * Decimal.valueOf(Label.Service_Tax).setScale(2))+lstLateFee[0].Late_Fees__c) > lateFeeProductPrice)// for Certificate program Late came with Service Tax so actul Late Fee is 500 and Late fee with service Tax is 590 means this is not second salb it is first slab only 
                {
                    lstOpportunityLineItemToDelete.add(mapOfAmountAndOpportunityLineItem.get(lateFeeProductPrice));
                }
            }
        }
    }
    
    if(lstOpportunityLineItemToDelete.size()>0)
    {
        delete lstOpportunityLineItemToDelete;
    }
    
    if(lstLateFee.size()>0 )
    {
        if(lstLateFee[0].Late_Fees__c !=null && lstLateFee[0].Late_Fees__c > 0)
        {
            if(lstLateFee[0].Late_Fees__c > lateFeeProductPrice)
            {
                return false;
            }
        }
    } 
          
    return true;  
  }*/
  
  // method to Update Student Program after Opportunity Stage get Closed Won
  public  Boolean ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(Opportunity objOpp) 
    {
        list<nm_StudentProgram__c> lstUpdateStudentProgram = new list<nm_StudentProgram__c>();
        list<Account> lstUpdateAccount = new list<Account>();
        
        list<IC_Change_Request__c> lstICR=[select id,Student__c,nm_Reson__c,Status__c,nm_TypeofRequest__c,New_Program__c,nm_Reason_for_Change_of_Program__c,New_Information_Center__c from IC_Change_Request__c where Student__c=:objOpp.Accountid and  Opportunity__c=:objOpp.id and Status__c!='Approved'];
        
        if(ObjOpp.nm_StudentProgram__c !=null && ObjOpp.nm_Program__c !=null)
        {
            if(lstICR.size()>0)
            {
                for(IC_Change_Request__c objICChange : lstICR )
                {
                    if(objICChange.nm_TypeofRequest__c=='Program Change' && objICChange.New_Program__c !=null && objICChange.Status__c=='New')  
                    {
                        nm_StudentProgram__c objStudentPro=new nm_StudentProgram__c(id=ObjOpp.nm_StudentProgram__c);
                        objStudentPro.nm_PreviousProgram__c=ObjOpp.nm_StudentProgram__r.nm_Program__c;
                        objStudentPro.nm_Program__c=objICChange.New_Program__c;
                        objStudentPro.nm_Reason_for_change_of_student_Program__c=objICChange.nm_Reason_for_Change_of_Program__c;
                        objStudentPro.nm_FeesPaidofSemester__c=Decimal.ValueOf(ObjOpp.nm_Semester__c);
                        lstUpdateStudentProgram.add(objStudentPro);
                        UpdateICChangeStatusForPaymentApproved(ObjOpp,objICChange);
                    }
                    
                    if(objICChange.nm_TypeofRequest__c=='IC Change' && objICChange.New_Information_Center__c !=null && objICChange.Student__c !=null && objICChange.Status__c=='New')   
                    {
                        Account objAccountUpdate=new Account(id=objICChange.Student__c);
                        // objAccountUpdate.nm_ReasonForICChange__c= objICChange.nm_Reson__c;
                        objAccountUpdate.nm_Centers__c=objICChange.New_Information_Center__c;
                        objAccountUpdate.OwnerId = getCenterUser(objICChange.New_Information_Center__c);
                        lstUpdateAccount.add(objAccountUpdate);
                        UpdateICChangeStatusForPaymentApproved(ObjOpp,objICChange);
                    }
                }
                
                if(lstUpdateAccount.size()>0)
                {
                    update lstUpdateAccount;
                }
                if(lstUpdateStudentProgram.size()>0)
                {
                    update lstUpdateStudentProgram;
                }
               if(ObjOpp !=null && lstUpdateStudentProgram.size()>0)
                {
                    ObjOpp.nm_Program__c=lstUpdateStudentProgram[0].nm_Program__c;
                    //update ObjOpp;
                }
                
                return true;
            }
           /* if('Master Programs'.equalsIgnoreCase(ObjOpp.ChooseProgram__c) && 'MBA (X)'.equalsIgnoreCase(objOpp.Account.Program_Type__c) && objOpp.IC__c !='upGrad' )
            {
                  Account objAccount=new Account(id=ObjOpp.AccountId);
                   objAccount.Prior_information_center__c = objOpp.Account.nm_Centers__c;
                  objAccount.nm_Centers__c =system.label.Upgrad_CenterId;
                   lstUpdateAccount.add(objAccount);
                if(lstUpdateAccount.size()>0)
                {
                    update lstUpdateAccount;
                }
                return true;
            }*/
                    }
        return false;
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
    
    public string getCenterUser(id centerId)
    {
        nm_UserMapping__c objUserMap = [select id,nm_User__c from nm_UserMapping__c where nm_Centers__c=:centerId];
        return objUserMap.nm_User__c;
    }
    
  // Method get Called from nmAdditionalPaymentController
  //return Pending Payment for Admission after Feetype Change or Late Fees or IC Change or Program Change 
  /*  public String getPendingPaymentFor(Opportunity objOpps)
    {
        set<String> setOfOppsId = new set<String>{objOpps.id};
        set<String> setOfAccountId = new set<String>{objOpps.AccountId};
        Map<String,List<OpportunityLineItem>> mapOfOppsIdVsOpportunityLineItem = getOpportunityLineItemEntryRelatedToOpportuntiy(setOfOppsId);
        List<OpportunityLineItem> lstOpportunityLineItem = mapOfOppsIdVsOpportunityLineItem.get(objOpps.id);
        Map<String,List<nm_Payment__c>> mapOfOppsIdVsPayments = getOpportunityRelatedPayment(setOfOppsId);
        List<nm_Payment__c> lstPayment = mapOfOppsIdVsPayments.get(objOpps.id);
        String paymentDescription = '';
        decimal totalAdmissionAmountReceived = 0.0;
        decimal totalAdmissionAmountPending = 0.0;
        decimal pendingPayment = getPendingAmount(objOpps.id);
        decimal LateFeeAmt = 0.0;
        decimal LateFeeProductPrice = 0.0;
        decimal ICChange = 0.0;
        decimal ProgramChange = 0.0;
        decimal studentKit = 0.0;
        decimal serviceTax = 0.0;
        decimal totalAmountToPayForAdmission = 0.0;
        decimal totalAmountToPayForLateFee = 0.0;
        decimal TotalProductAmount  =0.0;
        decimal programChangeWithStudyKit  = 0.0;
        decimal programChangeAndICChangeWithStudyKit  = 0.0;
        decimal programChangeAndICChangeWithoutStudyKit  = 0.0;
        boolean AlreadyPaidLateFee = false;
        decimal SemesterAmount =0.0;
         Map<Id,Account> mapOfOppsVsAccount = getOpportunityRelatedAccount(setOfAccountId);
        Account objAccount = mapOfOppsVsAccount.get(objOpps.AccountId);
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        if(pendingPayment > 0 && pendingPayment !=null)
        {
            for(nm_Payment__c objPayment : lstPayment)
            {
                if((objPayment.nm_PaymentType__c.contains('Admission') || objPayment.nm_PaymentType__c =='Installment') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    totalAdmissionAmountReceived += objPayment.nm_Amount__c;
                    
                }else if(objPayment.nm_PaymentType__c.contains('Late Fees') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Waived Off' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    LateFeeAmt = LateFeeAmt + objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('ProgramChange - StudentKit') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    programChangeWithStudyKit = programChangeWithStudyKit + objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('ProgramChange - ICChange - StudentKit') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    programChangeAndICChangeWithStudyKit = programChangeAndICChangeWithStudyKit + objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('ProgramChange - ICChange') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    programChangeAndICChangeWithoutStudyKit = programChangeAndICChangeWithoutStudyKit + objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('ICChange') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    ICChange = ICChange + objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('ProgramChange') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    ProgramChange = ProgramChange + objPayment.nm_Amount__c;
                }else if(objPayment.nm_PaymentType__c.contains('StudentKit') && (objPayment.nm_PaymentStatus__c =='Payment Made' || objPayment.nm_PaymentStatus__c =='Payment Approved'))
                {
                    studentKit = studentKit + objPayment.nm_Amount__c;
                }
            }
            
            for(OpportunityLineItem objLineItem : lstOpportunityLineItem)
            {
                if(objLineItem.Product_Name__c == 'Late Fee')
                {
                    LateFeeProductPrice = LateFeeProductPrice + objLineItem.UnitPrice;
                    
                }else if(objLineItem.Product_Name__c == 'IC Change Fee')
                {
                    ICChange = objLineItem.UnitPrice - ICChange;
                    
                }else if(objLineItem.Product_Name__c == 'Program Change Fee')
                {
                    ProgramChange = objLineItem.UnitPrice - ProgramChange;
                    
                }else if(objLineItem.Product_Name__c == 'Student Kits')
                {
                    studentKit = objLineItem.UnitPrice - studentKit ;
                }else if(objLineItem.Product_Name__c.contains('Semester') || objLineItem.Product_Name__c.contains('Term') )
                {
                    SemesterAmount +=objLineItem.UnitPrice;
                }else if(objLineItem.Product_Name__c.contains('Certificate Service Tax'))
                {
                    serviceTax +=objLineItem.UnitPrice;
                }
                        
               //calculate Product Price Bases upon Feetype
                if(objOpps.nm_Fee_Type__c !=null && objOpps.nm_Fee_Type__c !='')
                {
                    if(objOpps.nm_Fee_Type__c == 'PGAllSemFee')
                    {
                        TotalProductAmount = mapPricebook.get('PG_All_Sem').UnitPrice;
                        
                    }else if(objOpps.nm_Fee_Type__c == 'AnnualFee')
                    {
                       // checking Student Program as Annaul Fee Option is available for Advance Certificate Program also with different Product Price
                        if(objAccount.nmStudent_Program__c.startswith('Advanced Certificate'))
                        { 
                            TotalProductAmount = mapPricebook.get('Certificate_Annual').UnitPrice + serviceTax*2; // taking Service Tax of both sem and Semester Payment 
                        }
                        else if (objAccount.nm_DefencePersonnel__c =='Yes')
                        {
                            TotalProductAmount =  SemesterAmount*2;
                        }
                       else                     
                        {
                           TotalProductAmount = mapPricebook.get('Annual').UnitPrice;  
                        }  
                    }else if(objOpps.nm_Fee_Type__c == 'MultipleSemFee')
                    {
                        TotalProductAmount = mapPricebook.get('Multiple Semester').UnitPrice;
                        
                    }else if(objOpps.nm_Fee_Type__c.contains('-Considered'))
                    {
                        TotalProductAmount = TotalProductAmount; // for considered fee typr take zero amount 
                    }else
                    {
                        TotalProductAmount = SemesterAmount;
                        if(objAccount.nmStudent_Program__c.contains('Certificate'))
                        { 
                            TotalProductAmount += serviceTax; // adding service Tax to semester product 
                        }
                    }
                }else{// In some cases fee type is Null so take Semester 
                    TotalProductAmount = SemesterAmount;
                    if(objAccount.nmStudent_Program__c.contains('Certificate'))
                    { 
                        TotalProductAmount += serviceTax; // adding service Tax to semester product 
                    }
                }
            }
            
            if(LateFeeProductPrice !=null && LateFeeProductPrice >0)
            {
                totalAmountToPayForLateFee = LateFeeProductPrice - LateFeeAmt;
            }
            
            if(totalAdmissionAmountReceived !=null && totalAdmissionAmountReceived >0)
            {
                totalAdmissionAmountPending = TotalProductAmount - totalAdmissionAmountReceived ;
            }
           
            if(programChangeWithStudyKit !=null && programChangeWithStudyKit >0)
            {
                programChangeWithStudyKit = programChangeWithStudyKit - (ProgramChange + studentKit);
                ProgramChange = 0;
                studentKit = 0;
            }
            
            if(programChangeAndICChangeWithStudyKit !=null && programChangeAndICChangeWithStudyKit >0)
            {
                programChangeAndICChangeWithStudyKit = programChangeAndICChangeWithStudyKit - (ProgramChange + studentKit +ICChange);
                ProgramChange = 0;
                studentKit = 0;
                ICChange = 0;
            }
            
            if(programChangeAndICChangeWithoutStudyKit !=null && programChangeAndICChangeWithoutStudyKit >0)
            {
                programChangeAndICChangeWithoutStudyKit = programChangeAndICChangeWithoutStudyKit - (ProgramChange + ICChange);
                ProgramChange = 0;
                ICChange = 0;
            }
            
            // loop for checking if Student paid IC Change or Program Change Fee At Time of Re-Registration 
            if(totalAdmissionAmountPending !=null && totalAdmissionAmountPending <0)
            {
                totalAmountToPayForAdmission = totalAdmissionAmountPending ;
                totalAmountToPayForAdmission = totalAmountToPayForAdmission.abs(); // convert -ve to +ve number
                // checking Admission Amount less than all Product to avoid old records getting wrong amount 
                if(totalAmountToPayForAdmission <= ( ProgramChange + studentKit + ICChange))
                {
                    if(totalAmountToPayForAdmission >= ( ProgramChange + studentKit ) )// If Student paid Program Change fee + Student kit at time of rereg
                    {
                        totalAmountToPayForAdmission = totalAmountToPayForAdmission - ( ProgramChange + studentKit );
                        ProgramChange = 0;
                        studentKit = 0;
                    }
                    
                    if(totalAmountToPayForAdmission >= ICChange) // If Student Paid only IC Change at Rereg
                    {
                        totalAmountToPayForAdmission = totalAmountToPayForAdmission - ICChange;
                        ICChange = 0;
                    }
                    
                    if(totalAmountToPayForAdmission >= ProgramChange) // If Student Paid only Program Change at Rereg
                    {
                       totalAmountToPayForAdmission = totalAmountToPayForAdmission - ProgramChange;
                       ProgramChange = 0;
                    }
                    
                    if(totalAmountToPayForAdmission >= studentKit) // If Student Paid only StudyKit at Rereg
                    {
                        totalAmountToPayForAdmission = totalAmountToPayForAdmission - studentKit;
                        studentKit = 0;
                    }
                }
                
            }
            System.debug('totalAdmissionAmountPending------>'+totalAdmissionAmountPending);
           if(totalAdmissionAmountPending !=null && totalAdmissionAmountPending >0)
            {
                totalAmountToPayForAdmission = totalAdmissionAmountPending;
                paymentDescription = 'Additional Charge - Admission -'+totalAmountToPayForAdmission;  
            }else if(ProgramChange !=null && ProgramChange >0 && studentKit !=null && studentKit>0 && ICChange !=null && ICChange >0)
            {
                paymentDescription = 'Additional Charge - ProgramChange - ICChange - StudentKit -'+(ProgramChange + studentKit + ICChange );
            }else if(ProgramChange !=null && ProgramChange >0 && studentKit !=null && studentKit>0)
            {
                paymentDescription = 'Additional Charge - ProgramChange - StudentKit -'+(ProgramChange + studentKit);
            }else if(ProgramChange !=null && ProgramChange >0  && ICChange !=null && ICChange >0)
            {
                paymentDescription = 'Additional Charge - ProgramChange - ICChange -'+(ProgramChange + ICChange);
            }else if(ProgramChange !=null && ProgramChange >0)
            {
                paymentDescription = 'Additional Charge - ProgramChange -'+ProgramChange;
            }else if(studentKit !=null && studentKit>0)
            {
                paymentDescription = 'Additional Charge - StudentKit -'+studentKit;
            }else if(ICChange !=null && ICChange >0)
            {
                paymentDescription = 'Additional Charge - ICChange -'+ICChange;
            }else if(totalAmountToPayForLateFee > 0)
            {
                paymentDescription = 'Late Fees -'+totalAmountToPayForLateFee;
            }
        }
        System.debug('paymentDescription ------------->'+paymentDescription );
        return paymentDescription ;
    }*/
    public boolean MBAClosewonCheck(String chooseprogram,String programtype, String InterviewStatus ,  List<String> AIComponent_opp,List<String> AIComponent_pro)
    {
       Decimal requiredmarks;
       requiredmarks= Integer.valueOf(Label.ExecutiveMBARequiredScore);
       Set<String> setAIComponent_opp = new Set<String>();
       Set<String> setAIComponent_pro = new Set<String>();
       
        if(AIComponent_opp!=null && AIComponent_opp.size()>0)
        {
            setAIComponent_opp.addall(AIComponent_opp);
            system.debug('setAIComponent_opp-->'+setAIComponent_opp);
        }
        if(AIComponent_pro!=null && AIComponent_pro.size()>0)
        {
            setAIComponent_pro.addall(AIComponent_pro);
            system.debug('setAIComponent_pro-->'+setAIComponent_pro);
        }
        if(('Master Programs'.equalsIgnoreCase(chooseprogram) && ('MBA (WX)'.equalsIgnoreCase(programtype) || 'MBA - X'.equalsIgnoreCase(programtype) || 'M.Sc. (AI & ML Ops)'.equalsIgnoreCase(programtype) ||  'M.Sc. (AI)'.equalsIgnoreCase(programtype)))         
         ||('Certificate Programs'.equalsIgnoreCase(chooseprogram) && 'PC Term 2'.equalsIgnoreCase(programtype) )
         ||('Professional Programs'.equalsIgnoreCase(chooseprogram) && 'PD Term 4'.equalsIgnoreCase(programtype))           
       )
       {
           
           if(!'M.Sc. (AI)'.equalsIgnoreCase(programtype) && InterviewStatus.equalsIgnorecase('Selected') && InterviewStatus !='' && InterviewStatus!=null)
           {
               return true;
           }
           else if('M.Sc. (AI)'.equalsIgnoreCase(programtype) && InterviewStatus !='' && InterviewStatus!=null && InterviewStatus.equalsIgnorecase('Selected'))
           {
               Boolean compareList =false;
               if(setAIComponent_opp.size()>0)
               {
                   for(String check :setAIComponent_opp)
                   {
                       if(setAIComponent_pro.contains(check))
                       {
                         compareList = true;
                       }
                   }
                  system.debug('compareList--->'+compareList);
                  return compareList;
               }
               else
               {
                   return false;
               }
               
           }else
           {
               return false;
           }
       }
       else
       {
           return true;
       }
    }
    public Late_Fee__c getLateBasedUponTransDateAndCategory(Date transDate,String strCategory,String strtype,String Specialization)
    {
    system.debug('strCategory--->'+strCategory);
    system.debug('strtype--->'+strtype);
     system.debug('transDate--->'+transDate);
    
        Late_Fee__c objLateFee  = new Late_Fee__c();
        if(strCategory =='Lateral Admission')
        {
            strCategory = 'Is Lateral';
        }
           
        if( transDate != null && strCategory =='Admission' && strtype!=null)// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and nm_Type__c=:  strtype 
                                                and Program_Type__c =:Specialization                                        
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    system.debug('lstlateFee --->'+lstlateFee.size());
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else if( transDate != null && strCategory !='Admission'  && strCategory !=null)// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory                                                       
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else{ // for Fresh Student login Cases
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                      
                                                and Start_Date__c <= : Date.today()
                                                and End_Date__c >= : Date.today()];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }    
        return null;
    }
     public Late_Fee__c getLateBasedUponTransDateAndCategory(Date transDate,String strCategory,String strtype)
    {
    system.debug('strCategory--->'+strCategory);
    system.debug('strtype--->'+strtype);
     system.debug('transDate--->'+transDate);
    
        Late_Fee__c objLateFee  = new Late_Fee__c();
        if(strCategory =='Lateral Admission')
        {
            strCategory = 'Is Lateral';
        }
           
        if( transDate != null && strCategory =='Admission' && strtype!=null)// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and nm_Type__c=:  strtype   
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    system.debug('lstlateFee --->'+lstlateFee.size());
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else if( transDate != null && strCategory !='Admission'  && strCategory !=null)// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory                                                       
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else{ // for Fresh Student login Cases
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                      
                                                and Start_Date__c <= : Date.today()
                                                and End_Date__c >= : Date.today()];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }    
        return null;
    }
    public Late_Fee__c getLateBasedUponTransDateAndCategory(Date transDate,String strCategory,String strtype,String Specialization,String strSession,String strYear)
    {
    system.debug('strCategory--->'+strCategory);
    system.debug('strtype--->'+strtype);
    system.debug('transDate--->'+transDate);
  

        Late_Fee__c objLateFee  = new Late_Fee__c();
        if(strCategory =='Lateral Admission')
        {
            strCategory = 'Is Lateral';
        }
           
        if( transDate != null && strCategory =='Admission' && strtype!=null && String.isNotBlank(strSession) && String.isNotBlank(strYear))// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and nm_Type__c=:  strtype 
                                                and Program_Type__c =:Specialization
                                                and Session__c =:strSession
                                                and Year__c =:strYear                             
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    system.debug('lstlateFee --->'+lstlateFee.size());
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else if( transDate != null && strCategory !='Admission'  && strCategory !=null)// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and nm_Type__c=:  strtype                                                       
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else{ // for Fresh Student login Cases
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and nm_Type__c=:  strtype     
                                                and Start_Date__c <= : Date.today()
                                                and End_Date__c >= : Date.today()];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }    
        return null;
    }
     public Late_Fee__c getLateBasedUponTransDateAndCategory(Date transDate,String strCategory,String strtype,String strSession,String strYear)
    {
    system.debug('strCategory--->'+strCategory);
    system.debug('strtype--->'+strtype);
    system.debug('transDate--->'+transDate);
    system.debug('strSession--->'+strSession);
    system.debug('strYear--->'+strYear);
    
        Late_Fee__c objLateFee  = new Late_Fee__c();
        if(strCategory =='Lateral Admission')
        {
            strCategory = 'Is Lateral';
        }
           
        if( transDate != null && strCategory =='Admission' && strtype!=null && String.isNotBlank(strSession) && String.isNotBlank(strYear))// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory
                                                and nm_Type__c=:  strtype 
                                                and Session__c =:strSession
                                                and Year__c =:strYear
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    system.debug('lstlateFee --->'+lstlateFee.size());
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else if( transDate != null && strCategory !='Admission'  && strCategory !=null)// for Payment Initation Cases
        {
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory 
                                                and nm_Type__c=:  strtype                                                      
                                                and Start_Date__c <= : transDate
                                                and End_Date__c >= : transDate ];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }
        else{ // for Fresh Student login Cases
            list< Late_Fee__c > lstlateFee = [ select Start_Date__c, End_Date__c, Late_Fees__c 
                                                from Late_Fee__c 
                                                where Category__c =: strCategory 
                                                and nm_Type__c=:  strtype   
                                                and Start_Date__c <= : Date.today()
                                                and End_Date__c >= : Date.today()];
    
            if( lstlateFee != null && lstlateFee.size() > 0 && lstlateFee[0].Late_Fees__c != null)
            {               
                objLateFee = lstlateFee[0];     
                return objLateFee; 
            }
        }    
        return null;
    }
    
   //Method to check for Debit or Credit entry
   public void CheckforDebitCreditEntry(Opportunity objoppt,Set<String> setOfOppsId )
   {
       //IC share initiatilization 
      //  Date CloseDate = objoppt.CloseDate; 
     // Integer CurrentYear = CloseDate.Year();
       Date today = Date.Today(); 
       Integer CurrentYear = today.Year();
       Integer CurrentMonth = 0;
       double DebitAmount;
       double CreditAmount;
       double Shareforwarded =0 ;
       double RequiredShare =0 ;
       double  ActualAmountReceived =0;
       if(objoppt!=null)
       {
       system.debug('objoppt.ActualAmountReceived__c --->'+objoppt.ActualAmountReceived__c );
        system.debug('objoppt.RegistrationFee__c--->'+objoppt.RegistrationFee__c );
         system.debug('objoppt.late_fee__c --->'+objoppt.late_fee__c );
         system.debug('objoppt.CareerServiceFee__c--->'+objoppt.CareerServiceFee__c );
         
        system.debug('objoppt --->'+objoppt);
        ActualAmountReceived = objoppt.ActualAmountReceived__c + objoppt.E_S_charge__c - objoppt.RegistrationFee__c - objoppt.late_fee__c - objoppt.CareerServiceFee__c;
       
   if(objoppt.ShareApplicable__c == true ){
       Shareforwarded = getCreditSum(setOfOppsId) - getDebitSum(setOfOppsId) ;                   
       system.debug('Shareforwarded'+Shareforwarded);                                    
       RequiredShare = getRequiredShare(setOfOppsId,objoppt.ChooseProgram__c,objoppt);  
    }                   
        if(today.day()  <= 10 ){
           CurrentMonth = today.Month();
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
           // For Insofee check with 2 AEP      
              if((objoppt.ChooseProgram__c =='Master Programs' && objoppt.Specialisation__c ==  'M.Sc. (AI & ML Ops)' )
               || (objoppt.ChooseProgram__c =='Certificate Programs' && objoppt.Specialisation__c ==  'PC Term 2' )
               || (objoppt.ChooseProgram__c =='Professional Programs' && objoppt.Specialisation__c ==  'PD Term 4' )
               ||(objoppt.ChooseProgram__c =='Master Programs' && objoppt.Specialisation__c ==  'M.Sc. (AI)' )
               )
           {
               double DebitAmount1;
               double DebitAmount2;
               double Shareforwarded1;
               double Shareforwarded2;
               double RequiredShareIC;
               double RequiredShareInfo;
               double ActualSaleprice;
              
               ActualSaleprice =(Decimal)[select Sum(ActualSalePrice__c)saleprice 
                                   from OpportunityLineItem
                                   where OpportunityId =:setOfOppsId
                                   and (Product_Name__c Like'Semester%' OR Product_Name__c Like'Certificate Service Tax%' OR Product_Name__c Like'Live%' OR Product_Name__c Like'GST%' )][0].get('saleprice'); 

                if(objoppt.Down_Payment_Made__c &&  objoppt.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objoppt.WaivedOffAmount__c > objoppt.E_S_charge__c )
                {
                    RequiredShareIC = ActualAmountReceived *Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                    RequiredShareInfo = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_MSC); 
                }else if(objoppt.Down_Payment_Made__c &&  objoppt.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objoppt.WaivedOffAmount__c == objoppt.E_S_charge__c){
                    RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                    RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                }
                else{
                    RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                    RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                }                             
               
               Shareforwarded1 = getCreditSum(setOfOppsId,objoppt.IC__c) - getDebitSum(setOfOppsId,objoppt.IC__c) ; 
               Shareforwarded2 = getCreditSum(setOfOppsId,'Insofe') - getDebitSum(setOfOppsId,'Insofe') ; 
               if( Shareforwarded1 > RequiredShareIC)                 
               {
                   DebitAmount1 = Shareforwarded - RequiredShareIC;            
                   handler.createICTransactionDebitEntry(objoppt , CurrentYear, CurrentMonth,DebitAmount1,objoppt.IC__c,'Adjustment Debit');
               }
               if(Shareforwarded2 > RequiredShareInfo)
               {
                   DebitAmount2 = Shareforwarded2 - RequiredShareInfo;
                    handler.createICTransactionDebitEntry(objoppt , CurrentYear, CurrentMonth,DebitAmount2,'Insofe','Adjustment Debit');
               }
           
           }           
           else{
                handler.createICTransactionDebitEntry(objoppt , CurrentYear, CurrentMonth,DebitAmount,objoppt.IC__c,'Adjustment Debit');
           }
                      
       }
        else if(RequiredShare > Shareforwarded )
        {
           System.debug('Shareforwarded '+Shareforwarded); 
           nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
           CreditAmount =  RequiredShare - Shareforwarded;
           system.debug('objoppt.ChooseProgram__c-->'+objoppt.ChooseProgram__c);
           system.debug('objoppt.Specialisation__c-->'+objoppt.Specialisation__c);
                if((objoppt.ChooseProgram__c =='Master Programs' && objoppt.Specialisation__c ==  'M.Sc. (AI & ML Ops)' )
                || (objoppt.ChooseProgram__c =='Master Programs' && objoppt.Specialisation__c ==  'M.Sc. (AI)' )
                || (objoppt.ChooseProgram__c =='Certificate Programs' && objoppt.Specialisation__c ==  'PC Term 2' )
                || (objoppt.ChooseProgram__c =='Professional Programs' && objoppt.Specialisation__c ==  'PD Term 4' )
   )
           {
               double CreditAmount1;
               double CreditAmount2;
               double Shareforwarded1;
               double Shareforwarded2;
               double RequiredShareIC;
               double RequiredShareInfo;
               system.debug('enter in loop1 msc');
               
                
                system.debug('ActualAmountReceived-->'+ActualAmountReceived);
                double ActualSaleprice;
              
                ActualSaleprice =(Decimal)[select Sum(ActualSalePrice__c)saleprice 
                                    from OpportunityLineItem
                                    where OpportunityId =:setOfOppsId
                                    and (Product_Name__c Like'Semester%' OR Product_Name__c Like'Certificate Service Tax%' OR Product_Name__c Like'Live%' OR Product_Name__c Like'GST%' )][0].get('saleprice'); 

                if(objoppt.Down_Payment_Made__c &&  objoppt.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objoppt.WaivedOffAmount__c > objoppt.E_S_charge__c )
                {
                    RequiredShareIC = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                    RequiredShareInfo = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_MSC); 
                }else if(objoppt.Down_Payment_Made__c &&  objoppt.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objoppt.WaivedOffAmount__c == objoppt.E_S_charge__c){
                    RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                    RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                }
                else{
                    RequiredShareIC = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) ;
                    RequiredShareInfo = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
                }   
               
               Shareforwarded1 = getCreditSum(setOfOppsId,objoppt.IC__c) - getDebitSum(setOfOppsId,objoppt.IC__c) ; 
               Shareforwarded2 = getCreditSum(setOfOppsId,'Insofe') - getDebitSum(setOfOppsId,'Insofe') ; 
               system.debug('ActualAmountReceived-->'+ActualAmountReceived);
               system.debug('Shareforwarded1-->'+Shareforwarded1);
               if(RequiredShareIC > Shareforwarded1 )                 
               {
                   CreditAmount1 = RequiredShareIC - Shareforwarded1;            
                   handler.createICTransactionCreditEntry(objoppt , CurrentYear, CurrentMonth,CreditAmount1,objoppt.IC__c,'Pending Commission');
               }
               if(RequiredShareInfo > Shareforwarded2 )
               {
                   CreditAmount2 = RequiredShareInfo - Shareforwarded2;
                    handler.createICTransactionCreditEntry(objoppt , CurrentYear, CurrentMonth,CreditAmount2,'Insofe','Pending Commission');
               }
           
           }else{
               handler.createICTransactionCreditEntry(objoppt , CurrentYear, CurrentMonth,CreditAmount,objoppt.IC__c,'Pending Commission');        
           }
                       
        }   
        }             
             
   }
    //Method to Check for debit entry or credit Entry need to be against opportunity ---Not in use
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
         RequiredShare = getRequiredShare(setOfOppsId,ObjOpp.ChooseProgram__c,ObjOpp);
        
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
                handler.createICTransactionDebitEntry(objOpp, CurrentYear, CurrentMonth,DebitAmount,objOpp.IC__c,'Adjustment Debit');

            }                                      
            
                
    }//Call for check only credit entry ---Not in use
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
         RequiredShare = getRequiredShare(setOfOppsId,ObjOpp.ChooseProgram__c,ObjOpp);
        
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
                handler.createICTransactionCreditEntry(objOpp, CurrentYear, CurrentMonth,CreditAmount,objOpp.IC__c,'');
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
             system.debug('GET CreditSum AMOUNT-->0');
            return 0;
        }   
        
    }
    //Credit Share Based on AEP
     public double getCreditSum(Set<String> setOfOppsId,String ICName)    
     {  
        double  CreditSum;
        
          CreditSum = (Decimal)[Select Sum(Amount__c)total 
                       FROM  IC_Payment_Transaction__c  
                       where Transaction_Type__c='Admission Commision - Credit'
                       and Opportunity__c =:setOfOppsId and NonAdmissionShare__c=false and IC_name__c=:ICName][0].get('total');      
 
        if(CreditSum>0)
         {
             system.debug('GET CreditSum AMOUNT-->'+CreditSum);
             return CreditSum;          
         }
         else 
         {
              system.debug('GET CreditSum AMOUNT-->0');
             return 0;
         }   
         
     }
     public double getDebitSum(Set<String> setOfOppsId,String ICName)    
     {  
        double  DebitSum;
        
       DebitSum = (Decimal) [Select Sum(Amount__c)debitsum 
                             FROM  IC_Payment_Transaction__c 
                             where Transaction_Type__c='Adjustment - Debit' and Opportunity__c =:setOfOppsId 
                             and NonAdmissionShare__c =false and ( NOT Narration__c LIKE '%Book Courier Charges') and IC_name__c=:ICName][0].get('debitsum');     
 
      if(DebitSum>0 && DebitSum!=null)
         {
              system.debug('GET DebitSum AMOUNT-->'+DebitSum);
              return DebitSum;          
         }
         else 
         {
             system.debug('GET DebitSum AMOUNT-->'+DebitSum);
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

     if(DebitSum>0 && DebitSum!=null)
        {
             system.debug('GET DebitSum AMOUNT-->'+DebitSum);
             return DebitSum;          
        }
        else 
        {
            system.debug('GET DebitSum AMOUNT-->'+DebitSum);
            return 0;
        }   
        
    }
     public double getRequiredShare(Set<String> setOfOppsId,String ChooseProgram,Opportunity objopp)    
    {  
        double  ActualSaleprice;
        double  ActualAmountReceived = 0;
        // double  LatefeeAmount = 0;
        double RequiredShare;
       String specialization = objopp.Specialisation__c;
       String sem = objopp.nm_Semester__c;
       nmICPaymentTriggerHandler handler = new nmICPaymentTriggerHandler();
       
       ActualSaleprice =(Decimal)[select Sum(ActualSalePrice__c)saleprice 
       from OpportunityLineItem
       where OpportunityId =:setOfOppsId
       and (Product_Name__c Like'Semester%' OR Product_Name__c Like'Certificate Service Tax%' OR Product_Name__c Like'Live%' OR Product_Name__c Like'GST%' )][0].get('saleprice');
       
       if(ActualSaleprice>0)
        {
            if(ChooseProgram =='Master Programs' && (specialization ==  'M.Sc. (AI & ML Ops)' || specialization ==  'M.Sc. (AI)'))
            {
             if(objopp.Down_Payment_Made__c &&  objopp.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objopp.WaivedOffAmount__c >objopp.E_S_charge__c )
               {
                   ActualAmountReceived = objopp.ActualAmountReceived__c + objopp.E_S_charge__c - objopp.RegistrationFee__c - objopp.late_fee__c - objopp.CareerServiceFee__c;
                   RequiredShare = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) + ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_MSC); 
               }else if(objopp.Down_Payment_Made__c &&  objopp.nm_Fee_Type__c.equalsIgnoreCase('FullFee') && objopp.WaivedOffAmount__c ==objopp.E_S_charge__c )
               {                   
                  RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) + ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
               }else{
                    RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) + ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);
               }
     
            }
           else if(ChooseProgram =='Master Programs' && specialization == 'MBA (X)')
            {
              
                 RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MasterUpGrad);
                                 
            }
             else if(ChooseProgram =='Master Programs'   && specialization != 'MBA (X)')
            {                               
                 RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram);
            }
             else if(ChooseProgram =='Certificate Programs'  && String.isNotBlank(specialization) && specialization == 'CPWL')
            {                               
                 RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_CPWL);
            }else if(ChooseProgram =='Certificate Programs'   &&  String.isNotBlank(specialization) && specialization.contains('Certificate Term'))
            {                               
              //   RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_CPWL);
                                 
                Integer mutiplefactor = handler.getMultipleNumber(objopp.nm_Fee_Type__c);
                RequiredShare = ((ActualSaleprice - (Decimal.valueOf(Label.Stukent) * mutiplefactor)) * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
            } 
            else if(ChooseProgram =='Certificate Programs' && String.isNotBlank(specialization)  && specialization == 'PC Term 2')
            {                         
                RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) + ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);                        
            }
            else if(ChooseProgram =='Professional Programs' && String.isNotBlank(specialization)  && specialization == 'PD Term 4')
            {                         
                RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_DegreeProgram) + ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_MSC);                         
            }
              else if(ChooseProgram =='Professional Programs' && specialization == 'Professional Diploma' &&  sem == '1' )
            {
                 RequiredShare = ((ActualSaleprice -15000) * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
            }
             else if(ChooseProgram =='Professional Programs' && specialization == 'Professional Diploma Term 4' && sem != '4')
            {
                Integer mutiplefactor = handler.getMultipleNumberPP(objopp.nm_Fee_Type__c,Integer.valueof(sem));
                 RequiredShare = ((ActualSaleprice - (Decimal.valueOf(Label.Stukent) * mutiplefactor)) * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
            }
            else if((ChooseProgram =='MBA (Distance) Programs' || ChooseProgram =='MBA (Online) Programs') && objopp.nm_Fee_Type__c.equalsIgnoreCase('FullFeeLoan') )
            {
                 system.debug('enter MBA distance fullfeeloan');
                 
                if(objopp.Down_Payment_Made__c &&  objopp.nm_Fee_Type__c.equalsIgnoreCase('FullFeeLoan') && objopp.WaivedOffAmount__c >objopp.E_S_charge__c )
                {
                    ActualAmountReceived = objopp.ActualAmountReceived__c +objopp.E_S_charge__c - objopp.RegistrationFee__c - objopp.late_fee__c - objopp.CareerServiceFee__c;
                    RequiredShare = ActualAmountReceived*Decimal.valueOf(Label.ICSharePercentage_PGD_D) ;
                }else if(objopp.Down_Payment_Made__c &&  objopp.nm_Fee_Type__c.equalsIgnoreCase('FullFeeLoan') && objopp.WaivedOffAmount__c ==objopp.E_S_charge__c )
                {                   
                    RequiredShare = (ActualSaleprice * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
                }else{
                    RequiredShare = (ActualSaleprice * Decimal.valueOf(Label.ICSharePercentage_PGD_D));
                }
            }
            else
            {
                RequiredShare = ActualSaleprice*Decimal.valueOf(Label.ICSharePercentage_PGD_D);
            }
                                             
            
            system.debug('GET RequiredShare AMOUNT-->'+RequiredShare);
            return RequiredShare;          
        }
        else 
        {
           system.debug('GET RequiredShare AMOUNT-->0');
            return 0;
        }   
        
    }
    
    public void CareerServiceProduct(List<OpportunitylineItem> lstOpportunitylineItem, Opportunity objOpp) { 
        Boolean checkCareerProduct = false;
        List<OpportunitylineItem > lstOppLineItemsToInsert = new List<OpportunitylineItem >();
        if(objOpp.Career_Service__c!=null)
        {
            Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
            Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objOpp.Account.nm_Tagged_Pricebook__c);
            for(OpportunityLineItem objlineitem : lstOpportunitylineItem )
            {
                if(objOpp.Career_Service__c.equalsIgnoreCase(objlineitem.Product_Name__c))
                {   
                  checkCareerProduct = true; 
                   break;                                                 
                }               
    
            }
            system.debug('checkCareerProduct --->'+checkCareerProduct );
            if(!checkCareerProduct)
            {
                lstOppLineItemsToInsert.add(CreateLineIteam(objOpp.Career_Service__c,mapPricebook,objOpp.id));    
            }
            if(lstOppLineItemsToInsert.size()>0)
            {
                insert lstOppLineItemsToInsert;
            }
        }
    }

    public Decimal CourseraProduct(List<OpportunitylineItem> lstOpportunitylineItem, Opportunity objOpp, Boolean getPrice) {
        Boolean checkProductExists = false;
        String productName = 'Coursera';
        List<OpportunitylineItem> lstOppLineItemsToInsert = new List<OpportunitylineItem>();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objOpp.Account.nm_Tagged_Pricebook__c);
        if(getPrice) {
            System.debug('Entered in the if condition..');
            return mapPricebook.get(productName).UnitPrice;
        } else {
            for(OpportunityLineItem objlineitem : lstOpportunitylineItem) {
                if(productName.equalsIgnoreCase(objlineitem.Product_Name__c)) {   
                    checkProductExists = true; 
                    break;                                                 
                }               
            }
            System.debug('checkProductExists --->'+checkProductExists);
            if(!checkProductExists) {
                lstOppLineItemsToInsert.add(CreateLineIteam(productName,mapPricebook,objOpp.id));    
            }
            if(lstOppLineItemsToInsert.size() > 0){
                insert lstOppLineItemsToInsert;
            }
            return lstOppLineItemsToInsert.size() > 0 ? lstOppLineItemsToInsert[0].ActualSalePrice__c : 0;
        }
    }

    public void DeleteCourseraProduct(List<OpportunitylineItem> lstOpportunitylineItem, Opportunity objOpp) {
        if(lstOpportunitylineItem.Size() > 0) {
            Boolean checkProductExists = false;
            String productName = 'Coursera';
            List<OpportunitylineItem> lstOppLineItemsToInsert = new List<OpportunitylineItem>();
            // Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = getMapOfPriceBookIdProductVsPriceBookEntry();
            // Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objOpp.Account.nm_Tagged_Pricebook__c);
            for(OpportunityLineItem objlineitem : lstOpportunitylineItem) {
                if(productName.equalsIgnoreCase(objlineitem.Product_Name__c)) {   
                    // checkProductExists = true; 
                    lstOppLineItemsToInsert.add(objlineitem);  
                    // break;                                                 
                }               
            }
            if(lstOppLineItemsToInsert.size() > 0){
                Delete lstOppLineItemsToInsert;
            }
        }
    }

    public String Validity(Date BatchStart,nm_Program__c objprogram ,Integer sem) {
        
        Date ValidityExpiryDate ;
        Decimal SingleSem;
        Decimal pendingSem;
        Decimal AfterSubstitude;
        Map<Integer,String> MonthIntegervsString = new Map<Integer,String>();
        if(sem>0)
        {
            SingleSem = objprogram.PVM__c / objprogram.nm_TotalSemesters__c ;
            system.debug('SingleSem ---->'+SingleSem );
            pendingSem = (objprogram.nm_TotalSemesters__c - sem) + 1;
            system.debug('pendingSem ----'+pendingSem );
            if(sem==2 && objprogram.nm_TotalSemesters__c==4 )
            {
                AfterSubstitude = (SingleSem*pendingSem)-6;
            }
            else if(sem==2 && objprogram.nm_TotalSemesters__c==2 )
            {
                AfterSubstitude = (SingleSem*pendingSem)+6;
            }
            else
            {    
                AfterSubstitude = SingleSem*pendingSem;
            }
            
           //system.debug('add month'+(()-1));
            ValidityExpiryDate =  BatchStart.addMonths(Integer.valueof(AfterSubstitude - 1));
        }
       /* else
        {
            ValidityExpiryDate =  BatchStart.addMonths(objprogram.PVM__c - 1);
        }*/
        
        
        Integer month = ValidityExpiryDate.month();
        Integer year  = ValidityExpiryDate.year();
        
        if( month!=null && month>0)
        {
            MonthIntegervsString.put(01,'Jan');
            MonthIntegervsString.put(02,'Feb');
            MonthIntegervsString.put(03,'Mar');
            MonthIntegervsString.put(04,'Apr');
            MonthIntegervsString.put(05,'May');
            MonthIntegervsString.put(06,'Jun');
            MonthIntegervsString.put(07,'Jul');
            MonthIntegervsString.put(08,'Aug');
            MonthIntegervsString.put(09,'Sep');
            MonthIntegervsString.put(10,'Oct');
            MonthIntegervsString.put(11,'Nov');
            MonthIntegervsString.put(12,'Dec');
        }
        
        return MonthIntegervsString.get(month)+' '+string.valueof(year);
    }
    
}