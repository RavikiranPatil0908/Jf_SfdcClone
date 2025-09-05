/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 25-07-2025
 * @last modified by  : @Shailesh
**/
public without sharing class AEPEfficiencyReportController {

    @AuraEnabled(cacheable=true)
    public static String getAEPefficency(String drivename,String search){
        List<DataWrapper> datawrapperlst = new List<DataWrapper>();
        List<String> drivelst = drivename.split(',');

        List<nm_Centers__c> Lclst = [select Id, name ,Nm_Active__c,RecordType.name from nm_Centers__c where Nm_Active__c = true and RecordType.name = 'Learning Center' order by name ];

        List<nm_Centers__c> Iclst = [select Id, name ,Nm_Active__c,RecordType.name,nm_LearningCenter__r.Id ,nm_LearningCenter__r.name from nm_Centers__c where nm_LearningCenter__c != null and nm_LearningCenter__r.Nm_Active__c = true and Nm_Active__c = true and RecordType.name = 'Information Center' order by name ];

        List<Counsellor_Profile__c> cplst = [select Id ,Name,Full_Name__c,AEP_Name__r.name,AEP_Name__r.Id from Counsellor_Profile__c where IsActive__c = false];

        List<opportunity> opportlst = [select Id, name,Account.Id,Account.Name,Account.LC_Name__c, Account.IC_Name__c, Account.IC_company__c ,Counselor_Profile__r.Name,Counselor_Profile__r.Full_Name__c ,Counselor_Profile__r.Id,Counselor_Profile__r.IsActive__c, nm_Semester__c, nm_Drive_Name__c from opportunity where Counselor_Profile__r.IsActive__c = false and Counselor_Profile__c != null and  StageName = 'Closed Won' and nm_Semester__c = '1' and nm_Drive_Name__c In : drivelst ];



        Map<Id, List<Counsellor_Profile__c>> aepIdToCounsellorsMap = new Map<Id, List<Counsellor_Profile__c>>();
        for (Counsellor_Profile__c cp : cplst) {
            if (cp.AEP_Name__r != null) {
                if (!aepIdToCounsellorsMap.containsKey(cp.AEP_Name__r.Id)) {
                    aepIdToCounsellorsMap.put(cp.AEP_Name__r.Id, new List<Counsellor_Profile__c>());
                }
                aepIdToCounsellorsMap.get(cp.AEP_Name__r.Id).add(cp);
            }
        }

        Map<Id, List<Opportunity>> counsellorIdToOpportunities = new Map<Id, List<Opportunity>>();
        for (Opportunity opp : opportlst) {
            if (opp.Counselor_Profile__r != null) {
                if (!counsellorIdToOpportunities.containsKey(opp.Counselor_Profile__r.Id)) {
                    counsellorIdToOpportunities.put(opp.Counselor_Profile__r.Id, new List<Opportunity>());
                }
                counsellorIdToOpportunities.get(opp.Counselor_Profile__r.Id).add(opp);
            }
        }


        for (nm_Centers__c lcobj : Lclst) {

           
            

            for (nm_Centers__c icobj : Iclst) {
                if(lcobj.Id == icobj.nm_LearningCenter__r.Id){
                List<Counsellor_Profile__c> cps = aepIdToCounsellorsMap.get(icobj.Id);
                Integer cpCount = 0;
                Integer oppCount = 0;
                Integer oppCount1 = 0;
                DataWrapper obj = new DataWrapper();
                obj.lcName = lcobj.name;
                obj.aepName = icobj.name;
                if (cps != null) {
                    for (Counsellor_Profile__c cp : cps) {
                        
                        List<Opportunity> opps = counsellorIdToOpportunities.get(cp.Id);
                        // Count relevant opps

                            cpCount++;
                            if (opps != null) {
                            for (Opportunity oppobj : opps) {

                                if(oppobj.nm_Drive_Name__c == drivelst[0]){
                                    oppCount++;
                                } 
                                else if(oppobj.nm_Drive_Name__c == drivelst[1]){
                                    oppCount1++;
                                }
                            }
                            }
                    }
                }
                obj.activeCounsellorCount = cpCount+'';
                obj.semCountValue = oppCount+'';
                obj.semCountValue1 = oppCount1+'';
                if(cpCount > 0){
                obj.peformanceValue = (oppCount/cpCount)+'';
                obj.peformanceValue1 = (oppCount1/cpCount)+'';
                }
                obj.driveName = drivelst[0];
                obj.driveName1 = drivelst[1];
                datawrapperlst.add(obj);
            }
            }
        }

        
    System.debug('Search ::::'+search);

/*----------------------------------------------------------------------

        for (nm_Centers__c lcobj : Lclst) {

            DataWrapper obj = new DataWrapper();
            obj.lcName = lcobj.name;
            

            for (nm_Centers__c icobj : Iclst) {
                if(lcobj.Id == icobj.nm_LearningCenter__r.Id){
                      obj.aepName = icobj.name;
               
              
                    Integer cpCount = 0;
                    Integer oppCount = 0;
                    Integer oppCount1 = 0;
                    for (Counsellor_Profile__c cpobj : cplst) {

                        if(icobj.Id == cpobj.AEP_Name__r.Id){

                            cpCount++;

                            for (Opportunity oppobj : opportlst) {

                            if(oppobj.Counselor_Profile__r.Id == cpobj.AEP_Name__r.Id){

                                if(oppobj.nm_Drive_Name__c == drivelst[0]){
                                    oppCount++;
                                } 
                                else if(oppobj.nm_Drive_Name__c == drivelst[1]){
                                    oppCount1++;
                                }
                                
                            }

                            }

                        }  
                    }

                    obj.activeCounsellorCount = cpCount+'';
                    obj.semCountValue = oppCount+'';
                    obj.semCountValue1 = oppCount1+'';
                    if(cpCount > 0){
                    obj.peformanceValue = (oppCount/cpCount)+'';
                    obj.peformanceValue1 = (oppCount1/cpCount)+'';
                    }
                    obj.driveName = drivelst[0];
                    obj.driveName1 = drivelst[1];
                    datawrapperlst.add(obj);
                 }
                 
            }

            
   
        }
**/

        /**
         * 
         * drive1

            lc aep

            aep counsellor

            counsellor opportunity 

     


        
        List<Opportunity> opplst = [select Id, name,Account.Id,Account.Name,Account.LC_Name__c, Account.IC_Name__c, Account.IC_company__c ,Counselor_Profile__r.Name,Counselor_Profile__r.Full_Name__c ,
                                    Counselor_Profile__r.IsActive__c, nm_Semester__c, nm_Drive_Name__c from opportunity where StageName = 'Closed Won'
                                    and nm_Semester__c = '1' and nm_Drive_Name__c In : drivelst  ]; //('Jan2025','Jul2025')

       
        
        Map<String,Map<String,Set<String>>> driveVslckeyAepMap = new Map<String,Map<String,Set<String>>>();
        Map<String,Map<String,Set<String>>> driveVsaepkeycounsellorMap = new Map<String,Map<String,Set<String>>>();
        Map<String,Map<String,Set<String>>> driveVsaepkeycounsellorMapactive = new Map<String,Map<String,Set<String>>>();
        Map<String,Map<String,List<String>>> driveVsaepkeyOppMap = new Map<String,Map<String,List<String>>>();//drive--aep--sem--lst
        Map<String,Map<String,String>> driveVsperformanceAepkeyAvg = new Map<String,Map<String,String>>();
        List<DataWrapper> datawrapperlst = new List<DataWrapper>();

        if(opplst.size()>0){
            System.debug('Opportunity list size '+opplst.size());
            
            if(drivelst.size() > 0){

                for(Opportunity opp : opplst){
                       System.debug('opp list size '+opp);
                    for(String drivevalue : drivelst){
                           System.debug('drivevalue list size '+drivevalue);
                    if(opp.nm_Drive_Name__c == drivevalue &&  driveVslckeyAepMap != null && driveVslckeyAepMap.get(drivevalue) != null && driveVslckeyAepMap.get(drivevalue).containsKey(opp.Account.LC_Name__c)){

                        driveVslckeyAepMap.get(drivevalue).get(opp.Account.LC_Name__c).add(opp.Account.IC_Name__c);

                    }else if(opp.nm_Drive_Name__c == drivevalue){
                        Map<String,Set<String>> tempMap = new Map<String,Set<String>>();
                        Set<String> templst = new Set<String>();
                        templst.add( opp.Account.IC_Name__c);
                        tempMap.put(opp.Account.LC_Name__c, templst);

                        //driveVslckeyAepMap.get(drivevalue) != null ? driveVslckeyAepMap.get(drivevalue).put(opp.Account.LC_Name__c, templst) : driveVslckeyAepMap.put(drivevalue,tempMap);

                        if(driveVslckeyAepMap.get(drivevalue) != null){
                            driveVslckeyAepMap.get(drivevalue).put(opp.Account.LC_Name__c, templst);
                        }else{
                            driveVslckeyAepMap.put(drivevalue,tempMap);
                        }
                        
                    }


                    if(opp.Counselor_Profile__r.Name != null && opp.Counselor_Profile__r.Full_Name__c != null && opp.nm_Drive_Name__c == drivevalue && driveVsaepkeycounsellorMap != null && driveVsaepkeycounsellorMap.get(drivevalue) != null && driveVsaepkeycounsellorMap.get(drivevalue).containsKey(opp.Account.IC_Name__c)){

                        driveVsaepkeycounsellorMap.get(drivevalue).get(opp.Account.IC_Name__c).add(opp.Counselor_Profile__r.Name+'-'+ opp.Counselor_Profile__r.Full_Name__c);

                    }else if(opp.Counselor_Profile__r.Name != null && opp.Counselor_Profile__r.Full_Name__c != null && opp.nm_Drive_Name__c == drivevalue){
                        Map<String,Set<String>> tempMap = new Map<String,Set<String>>();
                        Set<String> templst = new Set<String>();
                        templst.add( opp.Counselor_Profile__r.Name+'-'+ opp.Counselor_Profile__r.Full_Name__c);
                        tempMap.put(opp.Account.IC_Name__c, templst);
                        // driveVsaepkeycounsellorMap.get(drivevalue) != null ? driveVsaepkeycounsellorMap.get(drivevalue).put(opp.Account.IC_Name__c, templst) :  driveVsaepkeycounsellorMap.put(drivevalue,tempMap);
                        if( driveVsaepkeycounsellorMap.get(drivevalue) != null){
                            driveVsaepkeycounsellorMap.get(drivevalue).put(opp.Account.IC_Name__c, templst);
                        }
                        else{
                            driveVsaepkeycounsellorMap.put(drivevalue,tempMap);
                        }
                    }
                
                    if(opp.Counselor_Profile__r.Name != null && opp.Counselor_Profile__r.Full_Name__c != null && opp.nm_Drive_Name__c == drivevalue && driveVsaepkeycounsellorMapactive != null && driveVsaepkeycounsellorMapactive.get(drivevalue) != null && driveVsaepkeycounsellorMapactive.get(drivevalue).containsKey(opp.Account.IC_Name__c) && opp.Counselor_Profile__r.IsActive__c == false){
                        
                        driveVsaepkeycounsellorMapactive.get(drivevalue).get(opp.Account.IC_Name__c).add(opp.Counselor_Profile__r.Name+'-'+ opp.Counselor_Profile__r.Full_Name__c);

                    }else if( opp.Counselor_Profile__r.Name != null && opp.Counselor_Profile__r.Full_Name__c != null && opp.nm_Drive_Name__c == drivevalue && opp.Counselor_Profile__r.IsActive__c == false){
                        Map<String,Set<String>> tempMap = new Map<String,Set<String>>();
                        Set<String> templst = new Set<String>();
                        templst.add( opp.Counselor_Profile__r.Name+'-'+ opp.Counselor_Profile__r.Full_Name__c);
                        tempMap.put(opp.Account.IC_Name__c, templst);

                      //  driveVsaepkeycounsellorMapactive.get(drivevalue) != null ? driveVsaepkeycounsellorMapactive.get(drivevalue).put(opp.Account.IC_Name__c, templst) : driveVsaepkeycounsellorMapactive.put(drivevalue,tempMap);
                        if( driveVsaepkeycounsellorMapactive.get(drivevalue) != null){
                            driveVsaepkeycounsellorMapactive.get(drivevalue).put(opp.Account.IC_Name__c, templst);
                        }
                        else{
                            driveVsaepkeycounsellorMapactive.put(drivevalue,tempMap);
                        }
                        
                    }
                    
                 


                    if(opp.nm_Drive_Name__c == drivevalue && driveVsaepkeyOppMap != null && driveVsaepkeyOppMap.get(drivevalue) != null && driveVsaepkeyOppMap.get(drivevalue).containsKey(opp.Account.IC_Name__c)){

                        driveVsaepkeyOppMap.get(drivevalue).get(opp.Account.IC_Name__c).add(opp.Account.Id);

                    }else if(opp.nm_Drive_Name__c == drivevalue){
                        Map<String,List<String>> tempMap = new Map<String,List<String>>();
                        List<String> templst = new List<String>();
                        templst.add(opp.Account.Id);
                        tempMap.put(opp.Account.IC_Name__c, templst);
                        //driveVsaepkeyOppMap.get(drivevalue) != null ? driveVsaepkeyOppMap.get(drivevalue).put(opp.Account.IC_Name__c, templst) : driveVsaepkeyOppMap.put(drivevalue,tempMap);
                        if( driveVsaepkeyOppMap.get(drivevalue) != null){
                            driveVsaepkeyOppMap.get(drivevalue).put(opp.Account.IC_Name__c, templst);
                        }
                        else{
                             driveVsaepkeyOppMap.put(drivevalue,tempMap);
                        }
                      
                    } 
                   
                    }

                       System.debug('driveVslckeyAepMap:: '+driveVslckeyAepMap.size());
                         System.debug('driveVsaepkeycounsellorMap:: '+driveVsaepkeycounsellorMap.size());
                           System.debug('driveVsaepkeyOppMap:: '+driveVsaepkeyOppMap.size());
                             System.debug('driveVsperformanceAepkeyAvg:: '+driveVsperformanceAepkeyAvg.size());
                            

                                 System.debug('driveVslckeyAepMap:: '+driveVslckeyAepMap);
                                   System.debug('driveVsaepkeycounsellorMap:: '+driveVsaepkeycounsellorMap);
                                     System.debug('driveVsaepkeyOppMap:: '+driveVsaepkeyOppMap);
                                       System.debug('driveVsperformanceAepkeyAvg:: '+driveVsperformanceAepkeyAvg);
                                       

                    }

                    
                    for(String drivevalue : drivelst){
                        if(driveVslckeyAepMap.get(drivevalue) != null){
                        for(String lc : driveVslckeyAepMap.get(drivevalue).keySet()){

                        for(String aepValue : driveVslckeyAepMap.get(drivevalue).get(lc)){
                        if(driveVsaepkeycounsellorMap.get(drivevalue) != null){

                            // for(String aepValue : driveVsaepkeycounsellorMap.get(drivevalue).keySet()){
                            Map<String,String> templst = new Map<String,String>();
                            //if(driveVsaepkeycounsellorMap.get(drivevalue).get(aepValue) != null && driveVsaepkeycounsellorMap.get(drivevalue).get(aepValue).size() > 0){
                                templst.put(aepValue, driveVsaepkeyOppMap.get(drivevalue) != null && driveVsaepkeyOppMap.get(drivevalue).get(aepValue) != null && driveVsaepkeycounsellorMap.get(drivevalue) != null && driveVsaepkeycounsellorMap.get(drivevalue).get(aepValue) != null && driveVsaepkeyOppMap.get(drivevalue).get(aepValue).size() > 0 && driveVsaepkeycounsellorMap.get(drivevalue).get(aepValue).size() > 0? (driveVsaepkeyOppMap.get(drivevalue).get(aepValue).size()/driveVsaepkeycounsellorMap.get(drivevalue).get(aepValue).size())+'':'');
                                driveVsperformanceAepkeyAvg.put(drivevalue,templst);
                            //}
                          //  }

                        }
                         
                    }}}}

                    System.debug('driveVslckeyAepMap:: '+driveVslckeyAepMap.size());
                    System.debug('drivelst:: '+drivelst);
                   
                    

                   // for(String drivevalue : drivelst){
                    String drivevalue = drivelst[0];
                    System.debug('driveVslckeyAepMap.get(drivevalue).keySet():: '+driveVslckeyAepMap.get(drivevalue).keySet());
                        for(String lc : driveVslckeyAepMap.get(drivevalue).keySet()){
                             
                    System.debug('driveVslckeyAepMap.get(drivevalue).get(lc):: '+driveVslckeyAepMap.get(drivevalue).get(lc));
                    System.debug('driveVslckeyAepMap.get(drivevalue).get(lc):: '+driveVslckeyAepMap.get(drivevalue).get(lc).size());
                            for(String aep : driveVslckeyAepMap.get(drivevalue).get(lc)){

                                DataWrapper obj = new DataWrapper();
                              //  if(driveVsaepkeycounsellorMap.get(drivevalue) != null && driveVsaepkeyOppMap.get(drivevalue) != null && driveVsperformanceAepkeyAvg.get(drivevalue) != null && driveVsaepkeycounsellorMapactive.get(drivevalue) != null){
                                obj.driveName = drivevalue;
                                obj.driveName1 = drivelst[1];
                                obj.lcName =lc;
                                obj.aepName =aep;
                                obj.totalCounsellorCount = driveVsaepkeycounsellorMap.get(drivevalue) != null && driveVsaepkeycounsellorMap.get(drivevalue).get(aep) != null && driveVsaepkeycounsellorMap.get(drivevalue).get(aep).size() > 0 ? driveVsaepkeycounsellorMap.get(drivevalue).get(aep).size()+'' : '';
                                obj.semCountValue = driveVsaepkeyOppMap.get(drivevalue) != null && driveVsaepkeyOppMap.get(drivevalue).get(aep) != null ? driveVsaepkeyOppMap.get(drivevalue).get(aep).size()+'' : '';
                                obj.peformanceValue = driveVsperformanceAepkeyAvg.get(drivevalue) != null && driveVsperformanceAepkeyAvg.get(drivevalue).get(aep) != null ? driveVsperformanceAepkeyAvg.get(drivevalue).get(aep)+'' : '';
                                obj.activeCounsellorCount = driveVsaepkeycounsellorMapactive.get(drivevalue) != null && driveVsaepkeycounsellorMapactive.get(drivevalue).get(aep) != null ? driveVsaepkeycounsellorMapactive.get(drivevalue).get(aep).size()+'':'';
                                obj.semCountValue1 = driveVsaepkeyOppMap.get(drivelst[1]) != null && driveVsaepkeyOppMap.get(drivelst[1]).get(aep) != null ? driveVsaepkeyOppMap.get(drivelst[1]).get(aep).size()+'' : '';
                                obj.peformanceValue1 = driveVsperformanceAepkeyAvg.get(drivelst[1]) != null && driveVsperformanceAepkeyAvg.get(drivelst[1]).get(aep) !=null ? driveVsperformanceAepkeyAvg.get(drivelst[1]).get(aep)+'' : '';
                                datawrapperlst.add(obj);
                                    System.debug('datawrapperlst  obj :: '+obj);
                               // } 
                               
                            

                                if(driveVslckeyAepMap.get(drivelst[1]) != null && driveVslckeyAepMap.get(drivelst[1]).get(lc) != null && !driveVslckeyAepMap.get(drivelst[1]).get(lc).contains(aep)){

                                DataWrapper objInner = new DataWrapper();
                                objInner.driveName = drivevalue;
                                objInner.driveName1 = drivelst[1];
                                objInner.lcName =lc;
                                objInner.aepName =aep;
                                objInner.totalCounsellorCount = driveVsaepkeycounsellorMap.get(drivevalue) != null && driveVsaepkeycounsellorMap.get(drivevalue).get(aep) != null && driveVsaepkeycounsellorMap.get(drivevalue).get(aep).size() > 0 ? driveVsaepkeycounsellorMap.get(drivevalue).get(aep).size()+'' : '';
                                objInner.semCountValue = driveVsaepkeyOppMap.get(drivevalue) != null && driveVsaepkeyOppMap.get(drivevalue).get(aep) != null ? driveVsaepkeyOppMap.get(drivevalue).get(aep).size()+'' : '';
                                objInner.peformanceValue = driveVsperformanceAepkeyAvg.get(drivevalue) != null && driveVsperformanceAepkeyAvg.get(drivevalue).get(aep) != null ? driveVsperformanceAepkeyAvg.get(drivevalue).get(aep)+'' : '';
                                objInner.activeCounsellorCount = driveVsaepkeycounsellorMapactive.get(drivevalue) != null && driveVsaepkeycounsellorMapactive.get(drivevalue).get(aep) != null ? driveVsaepkeycounsellorMapactive.get(drivevalue).get(aep).size()+'':'';
                                objInner.semCountValue1 = driveVsaepkeyOppMap.get(drivelst[1]) != null && driveVsaepkeyOppMap.get(drivelst[1]).get(aep) != null ? driveVsaepkeyOppMap.get(drivelst[1]).get(aep).size()+'' : '';
                                objInner.peformanceValue1 = driveVsperformanceAepkeyAvg.get(drivelst[1]) != null && driveVsperformanceAepkeyAvg.get(drivelst[1]).get(aep) !=null ? driveVsperformanceAepkeyAvg.get(drivelst[1]).get(aep)+'' : '';
                                datawrapperlst.add(objInner);
                                System.debug('datawrapperlst  objInner :: '+objInner);
                                }
                                
                             
                                
                            }
                             System.debug('datawrapperlst:: '+datawrapperlst);
                        }
                       
                   // }


                }
        }
                   */
        datawrapperlst.sort(new DataWrapper());

        if(!String.isBlank(search)){
            List<DataWrapper> localdatawrapperlst = new List<DataWrapper>();
            for (DataWrapper wrapobj : datawrapperlst) {
                if(wrapobj.aepName.containsIgnoreCase(search) || wrapobj.lcName.containsIgnoreCase(search)){
                    localdatawrapperlst.add(wrapobj);
                }
            }
            datawrapperlst = localdatawrapperlst;
        }
        System.debug('datawrapperlst:: '+datawrapperlst);
        System.debug('datawrapperlst:: '+JSON.serialize(datawrapperlst));
            return JSON.serialize(datawrapperlst) ;
        
    }


    public class DataWrapper implements Comparator<DataWrapper>{
        public String driveName { get; set; }
        public String driveName1 { get; set; }
        public String lcName { get; set; }
        public String aepName { get; set; }
        public String activeCounsellorCount { get; set; }
        public String totalCounsellorCount {get; set;}
        public String semCountValue { get; set; } //semkeyvalue
        public String peformanceValue { get; set; } //semkeyvalue
        public String semCountValue1 { get; set; } //semkeyvalue
        public String peformanceValue1 { get; set; } //semkeyvalue
        
        public DataWrapper(){
            this.driveName = '';
            this.driveName1 = '';
            this.lcName = '';
            this.aepName = '';
            this.activeCounsellorCount = '';
            this.totalCounsellorCount = '';
            this.semCountValue = ''; 
            this.peformanceValue = '';

            this.semCountValue1 = ''; 
            this.peformanceValue1 = '';
        }
         public Integer compare(DataWrapper o1, DataWrapper o2) {

            if(o1.activeCounsellorCount != null && o1.activeCounsellorCount != null && Integer.valueOf(o1.activeCounsellorCount) > Integer.valueOf(o2.activeCounsellorCount)) {
                return -1;
            }
            else if(o1.activeCounsellorCount != null && o1.activeCounsellorCount != null && Integer.valueOf(o1.activeCounsellorCount) < Integer.valueOf(o2.activeCounsellorCount))
            {return 1;} 
            else{return  0;}

         }

    }


}