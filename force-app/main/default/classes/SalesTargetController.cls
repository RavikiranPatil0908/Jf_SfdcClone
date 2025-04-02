public with sharing class SalesTargetController 
{
    public Target__c objTarget { get; set; }
    public list<Target__c>lstTarget {get;set;}
    public  map<string,Integer> MapforAchivedCount{get;set;}
    public map<string,integer> MapForSumOfSemAchived{get;set;}
    public map<string,integer >MapforSumOfTarget{get;set;}
    public list<AggregateResult> results {get;set;}
    public integer TotalSem1Target{get;set;}
    public integer TotalSem2Target{get;set;}
    public integer TotalSem3Target{get;set;}
    public integer TotalSem4Target{get;set;}
    public integer TotalSem1Achived{get;set;}
    public integer TotalSem2Achived{get;set;}
    public integer TotalSem3Achived{get;set;}
    public integer TotalSem4Achived{get;set;}
    
    
   
    public SalesTargetController() 
    {
       lstTarget =new list<Target__c>();
        objTarget  = new Target__c();
        MapforSumOfTarget=new map<string,integer>();
        MapForSumOfSemAchived=new map<string,integer>();
        results =new list<AggregateResult>();
      
        
       
    }
         public void getAchievedRecord()
        {
            string Session=objTarget.Session__c;
            Decimal Year=objTarget.Year__c;
            string stage='Closed Won';
            MapforAchivedCount=new map<string,Integer>();
            string key='';
         
            
            if(objTarget.Learning_Center__c!=null && objTarget.InformationCenter__c==null)
            {
              lstTarget=[select id,Admission_Target__c ,nm_Sem2Target__c,nm_Sem3Target__c,nm_Sem4Target__c,Admissions_Achieved__c,
                 Achieved_for_Sem2__c,Achieved_for_Sem3__c,Achieved_for_Sem4__c,Session__c,Year__c,Learning_Center__c,
                                        InformationCenter__c, InformationCenter__r.Name,Learning_Center__r.Name from Target__c where Learning_Center__c=:objTarget.Learning_Center__c  order by Learning_Center__r.Name asc];
              GetSumOfTotalTarget();   
                          
            
            }
            
            else if(objTarget.Learning_Center__c!=null && objTarget.InformationCenter__c!=null)
            {
            
               lstTarget=[select id,Admission_Target__c ,nm_Sem2Target__c,nm_Sem3Target__c,nm_Sem4Target__c,Admissions_Achieved__c,
                 Achieved_for_Sem2__c,Achieved_for_Sem3__c,Achieved_for_Sem4__c,Session__c,Year__c,Learning_Center__c,
                                        InformationCenter__c, InformationCenter__r.Name,Learning_Center__r.Name from Target__c where Learning_Center__c=:objTarget.Learning_Center__c and InformationCenter__c=:objTarget.InformationCenter__c order by Learning_Center__r.Name asc];
              
            
            }
            else if(objTarget.Learning_Center__c==null && objTarget.InformationCenter__c!=null)
            {
                lstTarget=[select id,Admission_Target__c ,nm_Sem2Target__c,nm_Sem3Target__c,nm_Sem4Target__c,Admissions_Achieved__c,
                 Achieved_for_Sem2__c,Achieved_for_Sem3__c,Achieved_for_Sem4__c,Session__c,Year__c,Learning_Center__c,
                                        InformationCenter__c, InformationCenter__r.Name,Learning_Center__r.Name from Target__c where InformationCenter__c=:objTarget.InformationCenter__c order by Learning_Center__r.Name asc];
                                   
            }
            
            else if(objTarget.InformationCenter__c==null && objTarget.Learning_Center__c==null)
            {
               system.debug('enter in loop');
                 lstTarget=[select id,Admission_Target__c ,nm_Sem2Target__c,nm_Sem3Target__c,nm_Sem4Target__c,Admissions_Achieved__c,
                 Achieved_for_Sem2__c,Achieved_for_Sem3__c,Achieved_for_Sem4__c,Session__c,Year__c,Learning_Center__c,
                                        InformationCenter__c, InformationCenter__r.Name,Learning_Center__r.Name from Target__c order by Learning_Center__r.Name asc] ;
                system.debug('lstTarget'+lstTarget.size()); 
                                      
            }

        
            String query =  ' select count(id) countOfRecords,nm_Semester__c,Account.nm_Centers__c icId from Opportunity where nm_Session__c = :Session and nm_Year__c =:Year and StageName =:stage group by nm_Semester__c,Account.nm_Centers__c';
              system.debug('session '+session); 
              system.debug('year '+year ); 
              system.debug('stage '+stage );  
              system.debug('query '+query);  
             list<SObject> result = DataBase.query(query);
             system.debug('result '+result );  
        
            for(SObject  obj: result)
            {
              AggregateResult aggResult = (AggregateResult) obj;
              key=String.valueOf(aggResult.get('icId'))+'-'+String.valueOf(aggResult.get('nm_Semester__c'));
              system.debug('key'+key);  
              MapforAchivedCount.put(key,Integer.valueOf(aggResult.get('countOfRecords')));
              system.debug('MapforAchivedCount'+MapforAchivedCount);  
             
            }  
        
           for(Target__c obj:lstTarget)
            {
              obj.Admissions_Achieved__c=MapforAchivedCount.get(obj.InformationCenter__c+'-1');
              system.debug(' obj.Admissions_Achieved__c'+ obj.Admissions_Achieved__c);
              obj.Achieved_for_Sem2__c=MapforAchivedCount.get(obj.InformationCenter__c+'-2');
              obj.Achieved_for_Sem3__c=Integer.valueOf(MapforAchivedCount.get(obj.InformationCenter__c+'-3'));
              obj.Achieved_for_Sem4__c=Integer.valueOf(MapforAchivedCount.get(obj.InformationCenter__c+'-4'));
        
            }
        }
        
        
        public void GetSumOfTotalTarget()
            {
            
           
                
            list<AggregateResult> lstAr = new list<AggregateResult>();
            lstTarget=[select id,Admission_Target__c ,nm_Sem2Target__c,nm_Sem3Target__c,nm_Sem4Target__c,Admissions_Achieved__c,
                     Achieved_for_Sem2__c,Achieved_for_Sem3__c,Achieved_for_Sem4__c,Session__c,Year__c,Learning_Center__c,
                                            InformationCenter__c, InformationCenter__r.Name,Learning_Center__r.Name from Target__c where Learning_Center__c=:objTarget.Learning_Center__c  order by Learning_Center__r.Name asc];
               
            lstAr = [select Sum(Admission_Target__c) SumTarget1 ,Sum(nm_Sem2Target__c) SumTarget2,Sum(nm_Sem3Target__c) SumTarget3,Sum(nm_Sem4Target__c) SumTarget4,
            Sum(Admissions_Achieved__c) Sem1Achived,Sum(Achieved_for_Sem2__c) Sem2Achived,Sum(Achieved_for_Sem3__c) Sem3Achived,Sum(Achieved_for_Sem4__c) Sem4Achived,Learning_Center__c Lc from Target__c where Learning_Center__c=:objTarget.Learning_Center__c group by Learning_Center__c ];
            system.debug('lstAr'+lstAr.size());
               
            if(lstAr.size()>0)
                {
                for(AggregateResult obj:lstAr)
                {
                AggregateResult  AggResult=(AggregateResult)obj;
                system.debug('AggResult'+AggResult);
                string KeyAllTarget=String.valueOf(AggResult.get('Lc'));
                
                   MapforSumOfTarget.put(KeyAllTarget+'-1',integer.valueOf(AggResult.get('SumTarget1')));
                   system.debug('MapforSumOfTarget'+MapforSumOfTarget);
                   MapforSumOfTarget.put(KeyAllTarget+'-2',integer.valueOf(AggResult.get('SumTarget2')));
                   MapforSumOfTarget.put(KeyAllTarget+'-3',integer.valueOf(AggResult.get('SumTarget3')));
                   MapforSumOfTarget.put(KeyAllTarget+'-4',integer.valueOf(AggResult.get('SumTarget4')));
                   
                   
                   MapForSumOfSemAchived.put(KeyAllTarget+'-1',integer.valueOf(AggResult.get('Sem1Achived')));
                   MapForSumOfSemAchived.put(KeyAllTarget+'-2',integer.valueOf(AggResult.get('Sem2Achived')));
                   MapForSumOfSemAchived.put(KeyAllTarget+'-3',integer.valueOf(AggResult.get('Sem3Achived')));
                   MapForSumOfSemAchived.put(KeyAllTarget+'-4',integer.valueOf(AggResult.get('Sem4Achived')));
                
                }
                }
            
            if(lstTarget.size()>0)
            {
                for(Target__c  obj: lstTarget)
               {
                   TotalSem1Target=MapforSumOfTarget.get(obj.Learning_Center__c+'-1');
                   system.debug('TotalSem1Target'+TotalSem1Target);
                   TotalSem2Target=MapforSumOfTarget.get(obj.Learning_Center__c+'-2');
                   TotalSem3Target=MapforSumOfTarget.get(obj.Learning_Center__c+'-3');
                   TotalSem4Target=MapforSumOfTarget.get(obj.Learning_Center__c+'-4');
                   
                   TotalSem1Achived=MapForSumOfSemAchived.get(obj.Learning_Center__c+'-1');
                   TotalSem2Achived=MapForSumOfSemAchived.get(obj.Learning_Center__c+'-2');
                   TotalSem3Achived=MapForSumOfSemAchived.get(obj.Learning_Center__c+'-3');
                   TotalSem4Achived=MapForSumOfSemAchived.get(obj.Learning_Center__c+'-4');
                   
                   
               }
            
            }
            }
        }