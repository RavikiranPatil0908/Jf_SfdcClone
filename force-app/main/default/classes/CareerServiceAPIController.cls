/**
 * @File Name          : CareerServiceAPIController.cls
 * @Description        : 
 * @Author             : Bala
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 21/1/2020, 4:40:02 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    9/4/2019, 11:22:22 AM   Bala     Initial Version
**/
public without sharing class CareerServiceAPIController {

    public Map<String,Object> MapOfResponseParameters {get;set;}
    public List<Object> myResult {get;set;}
    public ProductHelper productHelper;
    public String Source {get;set;}
    public Account objAccount {get;set;}
    
    public CareerServiceAPIController() {
        MapOfResponseParameters = new Map<String,Object>();
        myResult = new List<Object>();
        productHelper = new ProductHelper();
        Source = 'Career Services';
        objAccount = new Account();
    }

        
    /**
    * @description - To redirect to specific Request.
    * @author Bala | 9/4/2019
    * @param String KeyUrl
    * @param String jsonString
    * @return Blob
    */
    public Blob RedirectToURI(String KeyUrl,String jsonString) {
        switch on KeyUrl {
            when  'getAccessToken' {
                return getAccessToken(jsonString);
            }
            when 'submitRegistration' {
                return submitRegistration(jsonString);
            }
            when 'getPackages' {
                return getPackages(jsonString);
            }
            when 'createPackage' {
                return createPackage(jsonString);
            }
            when else {
                return InvalidURI();
            }
        }
    } 

    
    /**
    * @description - Request to get the Access Token.
    * @author Bala | 9/4/2019
    * @param String jsonString
    * @return Blob
    */
    public Blob getAccessToken(String jsonString) {

        System.debug('jsonString--'+jsonString);

        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,String> mapOfRequiredValue = new Map<String,String>{'request'=>'auth_token','source'=>'Career Services'};
        Set<String> setRequiredParam = new Set<String>{'email','password','request','source'};
        Map<String,Object> MapOfResponseParameters2 = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
        mapOfAttributes.put('mapOfRequiredValue',mapOfRequiredValue);

        InvalidRequest = InvalidRequest(mapOfAttributes);

        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        }else{

            String Email = String.valueOf(mapOfRequestParameters.get('email'));
            String Password = String.valueOf(mapOfRequestParameters.get('password'));
            String source = String.valueOf(mapOfRequestParameters.get('source'));
            List<RestResource_API_Access__c> lstRRAPIAccess = [SELECT id, isActive__c, API_EncryptionKey__c FROM RestResource_API_Access__c WHERE Email__c=:Email AND Password__c=:Password AND source__c=:source AND isActive__c=true];

            if(lstRRAPIAccess.size() > 0) {
                // To set the Requested Parameters. 
                MapOfResponseParameters2.put('token',generateToken(lstRRAPIAccess[0].API_EncryptionKey__c));
                MapOfResponseParameters2.put('timestamp',DateTime.now());
                MapOfResponseParameters2.put('status','success');
                
                // To set the Requested Parameters.
                MapOfResponseParameters.put('response',MapOfResponseParameters2);
                MapOfResponseParameters.put('message','ok');
                MapOfResponseParameters.put('errorCode','200');
            }else {
                MapOfResponseParameters.put('message','Invalid login credentials.');
                MapOfResponseParameters.put('errorCode','406');
            }
        }
        
        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }

    
    /**
    * @description - submit registration Response
    * @author Bala | 9/4/2019
    * @param String jsonString
    * @return Blob
    */
    public Blob submitRegistration(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'authToken','sapId','request'};
        List<Object> subResult = new List<Object>();
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);

        InvalidRequest = InvalidRequest(mapOfAttributes);

        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        }else {
            String Token = String.valueOf(mapOfRequestParameters.get('authToken'));
            if(!decryptToken(Token)) {
                MapOfResponseParameters.put('message','Invalid Token');
                MapOfResponseParameters.put('errorCode','405'); 
            }else {
                String sapId = String.valueOf(mapOfRequestParameters.get('sapId'));

                List<Account> lstAccount = [SELECT id,nm_NameofBoard__c,nm_10thPercentage__c,nm_YearofCompletion__c,nm_NameofSchool__c,nm_NameofStateBoard10th__c,
                nm_Class12OrDiploma__c,nm_12thPercentage__c,nm_NameofBoard12__c,nm_YearofCompletion12__c,nm_NameofSchool12__c,nm_Stream__c,nm_NameofStateBoard12th__c,
                nm_ResultDiploma__c,nm_DiplomaSchoolCollegeUniversityname__c,nm_DiplomaYearOfCompletion__c,nm_DiplomaName__c,nm_StreamDiploma__c,nm_DurationOfDiploma__c,
                nm_BachelorsDegreeName__c,nm_Specialization__c,nm_NameOfCollege__c,nm_NameofUniversity__c,University_Type__c,Other_University_Name__c,nm_YearofCollegeCompletion__c,
                Percentage_Bachlor__c,nm_GraduationDegreeMode__c,Name_of_Program1__c,Name_of_Program2__c,Name_of_Program3__c,Name_of_College1__c,Name_of_College2__c,
                Name_of_College3__c,Name_of_University1__c,Name_of_University2__c,Name_of_University3__c,Year_of_Passing1__c,Year_of_Passing2__c,Year_of_Passing3__c,
                Percentage1__c,Percentage2__c,Percentage3__c,Duration_of_Program1__c,Duration_of_Program2__c,Duration_of_Program3__c,Graduation_Degree_Mode1__c,
                Graduation_Degree_Mode2__c,Graduation_Degree_Mode3__c,Reason__c,nm_WorkExperience__c,PersonEmail FROM Account WHERE nm_StudentNo__c=:sapId];

                if(lstAccount.size() == 0) { 
                    MapOfResponseParameters.put('message','Invalid Student Number');
                    MapOfResponseParameters.put('errorCode','422');
                }else{
                    Map<String,Object> mapOfRequestParameters2 = (Map<String,Object>) mapOfRequestParameters.get('request');
                    objAccount = lstAccount[0];
                    Map<String,Object> mapOfMethodResponse = submitResponse(mapOfRequestParameters2);
                    if(mapOfMethodResponse.containsKey('InvalidRequest') && mapOfMethodResponse.get('InvalidRequest') == 'true') {
                        MapOfResponseParameters.put('message','Invalid Request');
                        MapOfResponseParameters.put('errorCode','422');
                    }else{
                        MapOfResponseParameters.put('response', mapOfMethodResponse.get('response'));
                        MapOfResponseParameters.put('message','ok');
                        MapOfResponseParameters.put('errorCode','200');
                    }
                }
            }
        }
        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }

    /**
    * @description
    * @author Bala | 9/4/2019
    * @param Map<String, Object> MapOfRequest
    * @return Map<String, Object>
    */
    public Map<String,Object> submitResponse(Map<String,Object> MapOfRequest) {
        String AccountId = objAccount.id;
        Map<String,Object> mapOfResponse = new Map<String,Object>();
        Map<String,Object> MapOfResponseParameters2 = new Map<String,Object>();
        String jsonString = JSON.serialize(MapOfRequest);
        CarrierServiceRequestWrapper requestWrapper = CarrierServiceRequestWrapper.parse(jsonString);

        if( String.isBlank(requestWrapper.packageId) || String.isBlank(requestWrapper.successURL) || String.isBlank(requestWrapper.failureURL)){
            System.debug('Error : PackageID or successURL or failureURL Fields are missing');
            mapOfResponse.put('InvalidRequest','true');
        }else{
            String packageId = requestWrapper.packageId;
            // CarrierServiceRequestWrapper.Qualification qualification = requestWrapper.qualification;
            // CarrierServiceRequestWrapper.Work_Experience work_experience = requestWrapper.work_experience;

            // if(qualification != null && AcademicQualification(qualification)) {
            //     mapOfResponse.put('InvalidRequest','true');
            // }else if(work_experience != null && SaveWorkExp(work_experience)) {
            //     mapOfResponse.put('InvalidRequest','true');
            // }else{
            //     if(requestWrapper.qualification != null || requestWrapper.work_experience != null) {
            //         update objAccount;
            //     }

                Career_Service_Program__c careerPackage = new Career_Service_Program__c();
                List<Career_Service_Program__c> lstCareerPackageProgram = new List<Career_Service_Program__c>();
                lstCareerPackageProgram = [SELECT id, CareerServiceProgram__c ,Stage__c FROM Career_Service_Program__c WHERE Account__c=:AccountId and Stage__c!='Payment Done'] ;
                if(lstCareerPackageProgram.size() > 0) {
                    for(Career_Service_Program__c packages:lstCareerPackageProgram) {
                        if(packages.CareerServiceProgram__c == packageId){
                            careerPackage.id = packages.id;
                        }
                    }
                }
                careerPackage.Account__c = AccountId;
                careerPackage.CareerServiceProgram__c = packageId;
                careerPackage.successURL__c = requestWrapper.successURL;
                careerPackage.failureURL__c = requestWrapper.failureURL;
                careerPackage.Student_E_mail_Address__c = objAccount.PersonEmail;
                
                System.debug('careerPackage -->'+careerPackage);

                upsert careerPackage;

                if(careerPackage != null) {
                    String careerPackageId = careerPackage.id;
                    MapOfResponseParameters2.put('status','success');
                    MapOfResponseParameters2.put('payment_url',System.Label.Site_Url+System.Label.nmAdditonalCharge+'id='+careerPackageId);
                    MapOfResponseParameters2.put('paymentInitializationId',careerPackageId);
                }else {
                    MapOfResponseParameters2.put('status','failed');
                }
                mapOfResponse.put('response',MapOfResponseParameters2);
            // }
        }
        return mapOfResponse;
    }

    /**
    * @description - To process the Academic Qualification json data and to insert the data.
    * @author Bala | 9/4/2019
    * @param CarrierServiceRequestWrapper.Qualification qualification
    * @return Boolean
    */
    // public Boolean AcademicQualification(CarrierServiceRequestWrapper.Qualification qualification) {

    //     if(qualification.ssc == null){
    //         System.debug('SSC Qualification is missing');
    //         // return true;
    //     }else{
    //         CarrierServiceRequestWrapper.Ssc ssc = qualification.ssc;
    //         if( String.isNotBlank(ssc.percentage) && String.isNotBlank(ssc.completion_year) 
    //         && String.isNotBlank(ssc.school_name) && String.isNotBlank(ssc.board) ) {

    //             objAccount.nm_NameofBoard__c = ssc.board;
    //             objAccount.nm_10thPercentage__c = Decimal.valueOf(ssc.percentage);
    //             objAccount.nm_YearofCompletion__c = ssc.completion_year;
    //             objAccount.nm_NameofSchool__c = ssc.school_name;
    //             objAccount.nm_NameofStateBoard10th__c = ssc.other_board;
    //         }else{
    //             System.debug('Error : SSC field values is missing');
    //             return true;
    //         }
    //     }

    //     if(qualification.hsc == null) {
    //         System.debug('Error : HSC Qualification is missing');
    //         // return true;
    //     }else{
    //         CarrierServiceRequestWrapper.Hsc hsc = qualification.hsc;

    //         if( String.isNotBlank(hsc.HSCOrDiploma) && String.isNotBlank(hsc.percentage) 
    //         && String.isNotBlank(hsc.completion_year) && String.isNotBlank(hsc.school_name) 
    //         && String.isNotBlank(hsc.board) && String.isNotBlank(hsc.stream) ) {

    //             objAccount.nm_Class12OrDiploma__c = hsc.HSCOrDiploma;

    //             if(objAccount.nm_Class12OrDiploma__c == 'XII/HSC') {
    //                 objAccount.nm_12thPercentage__c = Decimal.valueOf(hsc.percentage);
    //                 objAccount.nm_NameofBoard12__c = hsc.board;
    //                 objAccount.nm_YearofCompletion12__c = hsc.completion_year;
    //                 objAccount.nm_NameofSchool12__c = hsc.school_name;
    //                 objAccount.nm_Stream__c = hsc.stream;
    //                 objAccount.nm_NameofStateBoard12th__c = hsc.other_board;
    //             }else{
    //                 objAccount.nm_ResultDiploma__c = Decimal.ValueOf(hsc.percentage);
    //                 objAccount.nm_DiplomaSchoolCollegeUniversityname__c = hsc.board;
    //                 objAccount.nm_DiplomaYearOfCompletion__c = Integer.valueOf(hsc.completion_year);
    //                 objAccount.nm_DiplomaName__c = hsc.school_name;
    //                 objAccount.nm_StreamDiploma__c = hsc.stream;
    //                 if(String.isNotBlank(hsc.diploma_duration)) {
    //                     objAccount.nm_DurationOfDiploma__c = Integer.valueOf(hsc.diploma_duration);
    //                 }else{
    //                     System.debug('Error : Diploma Duration is missing');
    //                     return true;
    //                 }
    //             }
    //         }else{
    //             System.debug('Error : HSC field values is missing');
    //             return true;
    //         }
    //     }

    //     if(qualification.graduation == null) {
    //         System.debug('Error : Graduation Qualification is missing');
    //     }else {
    //         CarrierServiceRequestWrapper.Graduation graduation = qualification.graduation;

    //         if( String.isNotBlank(graduation.degree_name) && String.isNotBlank(graduation.specialisation) && String.isNotBlank(graduation.school_name) 
    //         && String.isNotBlank(graduation.university_name) && String.isNotBlank(graduation.university_type) && String.isNotBlank(graduation.degree_mode) 
    //         && String.isNotBlank(graduation.completion_year) && String.isNotBlank(graduation.school_name)) {

    //             objAccount.nm_BachelorsDegreeName__c = graduation.degree_name;
    //             objAccount.nm_Specialization__c = graduation.specialisation;
    //             objAccount.nm_NameOfCollege__c = graduation.school_name;
    //             objAccount.nm_NameofUniversity__c = graduation.university_name;
    //             objAccount.University_Type__c = graduation.university_type;
    //             objAccount.Other_University_Name__c = graduation.other_university;
    //             objAccount.nm_YearofCollegeCompletion__c = graduation.completion_year;
    //             objAccount.Percentage_Bachlor__c = Decimal.valueOf(graduation.percentage);
    //             objAccount.nm_GraduationDegreeMode__c = graduation.degree_mode;
    //         }else{
    //             System.debug('Error : Graduation field values is missing');
    //         }
    //     }

    //     if(qualification.post_graduation == null || qualification.post_graduation.size() <= 0) {
    //         System.debug('Error : Post graduation is missing');
    //     }else {
    //         if(qualification.post_graduation.size() > 0) {
    //             Integer i = 1;
    //             for(CarrierServiceRequestWrapper.Post_graduation pgGrad: qualification.post_graduation) {
                    
    //                 if(String.isNotBlank(pgGrad.degree_name) && String.isNotBlank(pgGrad.school_name) && String.isNotBlank(pgGrad.university_name) 
    //                 && String.isNotBlank(pgGrad.completion_year) && String.isNotBlank(pgGrad.percentage) && String.isNotBlank(pgGrad.program_duration) 
    //                 && String.isNotBlank(pgGrad.degree_mode)) {
    //                     objAccount.put('Name_of_Program'+i+'__c', pgGrad.degree_name);
    //                     objAccount.put('Name_of_College'+i+'__c', pgGrad.school_name);
    //                     objAccount.put('Name_of_University'+i+'__c', pgGrad.university_name);
    //                     objAccount.put('Year_of_Passing'+i+'__c', pgGrad.completion_year);
    //                     objAccount.put('Percentage'+i+'__c', pgGrad.percentage);
    //                     // objAccount.put('Duration_of_Program'+i+'__c', Decimal.valueOf(pgGrad.program_duration));
    //                     objAccount.put('Graduation_Degree_Mode'+i+'__c', pgGrad.degree_mode);
    //                 }else {
    //                     System.debug('Error : '+i+') Post Graduation Field values is missing');
    //                     return true;
    //                 }
    //                 i++;
    //             }
    //         }else{
    //             System.debug('Error : Post graduation is missing');
    //         }
    //     }
    //     return false;
    // }

    /**
    * @description - To process the work expereince json data and to insert the data.
    * @author Bala | 9/4/2019
    * @param CarrierServiceRequestWrapper.Work_Experience workEXP
    * @return Boolean
    */
    // public Boolean SaveWorkExp(CarrierServiceRequestWrapper.Work_Experience workEXP) {
    //     String AccountId = objAccount.id;
    //     if(String.isNotBlank(workEXP.reasonForNotWorking)) {
    //         objAccount.Reason__c = workEXP.reasonForNotWorking;
    //         return false;
    //     }else{
    //         if(String.isBlank(workEXP.total_workExperince) || (workEXP.lstExperience == null || workEXP.lstExperience.size() <= 0) ) {
    //             System.debug('Error : Work Experince is missing');
    //             // return true;
    //         }else{
    //             objAccount.nm_WorkExperience__c = workEXP.total_workExperince;
    //             List<nm_WorkExperience__c> lstWEToUpsert = new List<nm_WorkExperience__c>();

    //             for(CarrierServiceRequestWrapper.LstExperience WERes:workEXP.lstExperience){
    //                 if(WERes.start_date != null && String.isNotBlank(WERes.industry) && String.isNotBlank(WERes.company_name) && String.isNotBlank(WERes.department) 
    //                 && String.isNotBlank(WERes.designation) && String.isNotBlank(WERes.annual_income) && String.isNotBlank(WERes.currentlyWorking) ) {

    //                     nm_WorkExperience__c objWE = new nm_WorkExperience__c();

    //                     objWE.nm_Student__c = AccountId;                        
    //                     if(WERes.currentlyWorking == 'true'){
    //                         objWE.Currently_Working_Here__c = true;
    //                     }else{
    //                         objWE.nm_EndDate__c = WERes.end_date;
    //                     }
    //                     objWE.nm_StartDate__c = WERes.start_date;
    //                     objWE.Industry__c = WERes.industry;
    //                     objWE.nm_CompanyName__c = WERes.company_name;
    //                     objWE.Department__c = WERes.department;
    //                     objWE.nm_Designation__c = WERes.designation;
    //                     objWE.Annual_Income__c = WERes.annual_income;
    //                     lstWEToUpsert.add(objWE);
    //                 }else{
    //                     System.debug('Error : Work Experience list field value is missing');
    //                     return true;
    //                 }
    //             }

    //             if(lstWEToUpsert.size() > 0) {
    //                 delete [select Id from nm_WorkExperience__c where nm_Student__c =:AccountId];
    //                 upsert lstWEToUpsert;
    //             }

    //             return false;
    //         }

    //         return false;
    //     }
    // }

 
    /**
    * @description - Request to get package details.
    * @author Bala | 9/4/2019
    * @param String jsonString
    * @return Blob
    */
    public Blob getPackages(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'authToken','request'};
        Map<String,String> mapOfRequiredValue = new Map<String,String>{'request'=>'packages'};
        List<Object> subResult = new List<Object>();
        Map<String,Object> MapOfResponseParameters2 = new Map<String,Object>();
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);
        mapOfAttributes.put('mapOfRequiredValue',mapOfRequiredValue);

        InvalidRequest = InvalidRequest(mapOfAttributes);

        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        }else {
            String Token = String.valueOf(mapOfRequestParameters.get('authToken'));
            if(!decryptToken(Token)) {
                MapOfResponseParameters.put('message','Invalid Token');
                MapOfResponseParameters.put('errorCode','405'); 
            }else {
                List<wrapCareerPackage> lstWrapCareerPackage = new List<wrapCareerPackage>();
                Map<String,PriceBookEntry> mapOfPriceBookEntry = new Map<String,PriceBookEntry>();
                List<PriceBookEntry> lstPriceBookEntry = [SELECT id,UnitPrice,product2.Name,product2.nm_Program__c,product2.nm_Semester__c FROM PriceBookEntry WHERE product2.isActive = true];
                for(PriceBookEntry pricebook : lstPriceBookEntry) {
                    mapOfPriceBookEntry.put(pricebook.product2.Name,pricebook);
                }

                List<Career_Service_Package__c> lstCareerPackages = [SELECT id,Package_Name__c,Group_Name__c,Package_Code__c,Product__r.Name,Name FROM Career_Service_Package__c WHERE isActive__c=true ];
                MapOfResponseParameters2.put('status','success');
                for(Career_Service_Package__c packages :lstCareerPackages) {
                    String UnitPrice = String.valueOf(mapOfPriceBookEntry.get(packages.Product__r.Name).UnitPrice);
                    lstWrapCareerPackage.add(new wrapCareerPackage(packages, UnitPrice));
                }
                MapOfResponseParameters2.put('packageList', lstWrapCareerPackage);
                MapOfResponseParameters.put('packages', MapOfResponseParameters2);
                MapOfResponseParameters.put('message','ok');
                MapOfResponseParameters.put('errorCode','200');
            }
        }

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }

    public Blob createPackage(String jsonString) {
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfAttributes = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'authToken','request'};
        List<Object> subResult = new List<Object>();
        Map<String,Object> MapOfResponseParameters2 = new Map<String,Object>();
        Boolean InvalidRequest = false;

        // To pass params
        mapOfAttributes.put('setRequiredParam',setRequiredParam);
        mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters);

        InvalidRequest = InvalidRequest(mapOfAttributes);

        if(InvalidRequest) {
            MapOfResponseParameters.put('message','Invalid Request');
            MapOfResponseParameters.put('errorCode','422');
        }else {
            String Token = String.valueOf(mapOfRequestParameters.get('authToken'));
            if(!decryptToken(Token)) {
                MapOfResponseParameters.put('message','Invalid Token');
                MapOfResponseParameters.put('errorCode','405'); 
            }else {
                Map<String,Object> mapOfRequestParameters2 = (Map<String,Object>) mapOfRequestParameters.get('request');
                //To clear all the attributes.
                mapOfAttributes.clear();
                setRequiredParam.clear();
                
                setRequiredParam = new Set<String>{'packageName','type'};
                mapOfAttributes.put('setRequiredParam',setRequiredParam);
                mapOfAttributes.put('mapOfRequestParameters',mapOfRequestParameters2);
                InvalidRequest = InvalidRequest(mapOfAttributes);

                if(InvalidRequest) {
                    MapOfResponseParameters.put('message','Invalid Request');
                    MapOfResponseParameters.put('errorCode','422');
                }else {
                    String type = String.valueOf(mapOfRequestParameters2.get('type'));
                    String name = String.valueOf(mapOfRequestParameters2.get('packageName'));


                    List<Career_Service_Package__c> lstCareerPackages = [SELECT id,Package_Name__c,Group_Name__c FROM Career_Service_Package__c WHERE Package_Name__c=:name AND Group_Name__c=:type];
                    if(lstCareerPackages.size() > 0) {
                        MapOfResponseParameters.put('message','package name already exists');
                        MapOfResponseParameters.put('errorCode','427');
                    }else{
                        try {
                            Career_Service_Package__c objCareerPackage = new Career_Service_Package__c();
                            objCareerPackage.Package_Name__c = name;
                            objCareerPackage.Group_Name__c = type;
                            insert objCareerPackage;

                            Career_Service_Package__c CareerPackages = [SELECT id,Package_Name__c,Group_Name__c,Package_Code__c,Product__r.Name,Name FROM Career_Service_Package__c WHERE id=:objCareerPackage.id Limit 1];

                            wrapCareerPackage careerPackageWrapper = new wrapCareerPackage(CareerPackages, null);

                            MapOfResponseParameters2.put('status','success');
                            MapOfResponseParameters2.put('packages', careerPackageWrapper);
                            MapOfResponseParameters.put('response', MapOfResponseParameters2);
                            MapOfResponseParameters.put('message','ok');
                            MapOfResponseParameters.put('errorCode','200');
                            
                        } catch (Exception e) {
                            MapOfResponseParameters.put('message','Error Record insert Invalid');
                            MapOfResponseParameters.put('errorCode','423');
                        }
                    }
                }
            }
        }

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(MapOfResponseParameters));
        return Result;
    }


    /**
    * @description - To return Error for invalid URL.
    * @author Bala | 9/4/2019
    * @return Blob
    */
    public Blob InvalidURI() {
        // To set the Requested Parameters.
        MapOfResponseParameters.put('message','Could not find a match for URL');
        MapOfResponseParameters.put('errorCode','NOT_FOUND');
        myResult.add(MapOfResponseParameters);

        // Serialize the map to json.
        Blob Result = Blob.valueOf(JSON.serialize(myResult));
        return Result;
    }


    /**
    * @description - To check invalid Requests
    * @author Bala | 9/4/2019
    * @param Map<String, Object> mapOfAttributes
    * @return Boolean
    */
    public Boolean InvalidRequest(Map<String,Object> mapOfAttributes) {
        Boolean InvalidRequest = false;
        Map<String,String> mapOfRequiredValue = new Map<String,String>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)mapOfAttributes.get('mapOfRequestParameters');
        Set<String> setPresentParam = mapOfRequestParameters.keySet();
        Set<String> setRequiredParam = (Set<String>)mapOfAttributes.get('setRequiredParam');
        

        if(mapOfAttributes.containsKey('mapOfRequiredValue')) {
            mapOfRequiredValue = (Map<String,String>)mapOfAttributes.get('mapOfRequiredValue');
        }

        if(setPresentParam.containsAll(setRequiredParam)) {
            for (String fieldName : setRequiredParam) {
                if(mapOfRequestParameters.get(fieldName) == null || mapOfRequestParameters.get(fieldName) == '') {
                    InvalidRequest = true;
                }else if(mapOfRequiredValue.containsKey(fieldName)) {
                    if(mapOfRequiredValue.get(fieldName) != String.valueOf(mapOfRequestParameters.get(fieldName)) ) {
                        InvalidRequest = true;
                    }
                }
            }
        }else{
            InvalidRequest = true;
        }
        return InvalidRequest;
    }

    /**
    * @description
    * @author Bala | 9/4/2019
    * @param String API_EncryptionKey
    * @return String
    */
    public String generateToken(String API_EncryptionKey) {
        Blob cryptoKey = EncodingUtil.base64Decode(API_EncryptionKey);
        DateTime expiryTime = DateTime.now().addHours(1);
        Blob token = Blob.valueOf(DateTime.now().format('dd/MM/yyyy hh:mm a')+'|'+expiryTime.format('dd/MM/yyyy hh:mm a')+'|success|auth_token');
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, token);
        String accessToken = EncodingUtil.base64Encode(encryptedData);
        return accessToken;
    }


    
    /**
    * @description - To decrypt Token.
    * @author Bala | 9/4/2019
    * @param String Token
    * @return Boolean
    */
    public Boolean decryptToken(String Token) {
        try {
            List<RestResource_API_Access__c> lstRRAPIAccess = [SELECT id, isActive__c, API_EncryptionKey__c FROM RestResource_API_Access__c WHERE source__c=:Source and isActive__c=true];
            if(lstRRAPIAccess.size() > 0) {
                Blob cryptoKey = EncodingUtil.base64Decode(lstRRAPIAccess[0].API_EncryptionKey__c);
                Blob encryptedData = EncodingUtil.base64Decode(Token);
                Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
                String decryptedDataString = decryptedData.toString();
                System.debug('decryptedDataString-->'+decryptedDataString);
                List<String> lstResponse = decryptedDataString.split('\\|');
                String role = lstResponse[0];
                DateTime currentDateTime = System.now();
                DateTime expiryDateTime = DateTime.parse(lstResponse[1]);

                if((currentDateTime < expiryDateTime) || role == 'admin') {
                    return true;
                }else {
                    return false;
                }
            }else{
                return false;
            }
            
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
    }


    /**
    * @description - This is the contructor method. When we create a new wrapAccount object 
    *   we pass a Account that is set to the acc property. We also set the selected value to false
    * @author Bala | 9/4/2019
    * @param Career_Service_Package__c a, String price
    */
    public class wrapCareerPackage {
        public String name {get; set;}
        public String type {get; set;}
        public String unitPrice {get; set;}
        public String packageId {get;set;}
        public String packageCode {get;set;}
  
        
        public wrapCareerPackage(Career_Service_Package__c a, String price) {
            name = a.Package_Name__c;
            type = a.Group_Name__c;
            unitPrice = price;
            packageId = a.id;
            packageCode = a.Name;
        }
    }


}