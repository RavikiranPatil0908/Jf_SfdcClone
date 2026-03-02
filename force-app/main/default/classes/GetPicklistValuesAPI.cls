/**
 * @description       : REST API to fetch picklist values
 * @author            : @Ravi
 * @last modified on  : 23--09--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-08-2025   @Ravi    Initial Version
**/
@RestResource(urlMapping='/api/FetchPicklistValues/*')
global without sharing class GetPicklistValuesAPI {

    public static ProgramPicklist programResponse { get; set; }

    // ----------------------------
    // HTTP GET - Fetch all picklist values
    // ----------------------------
    @HttpGet
    global static void getPicklistValues() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');

        try {
            String recordId   = RestContext.request.params.get('recordId');
            String objectType = (recordId == null) ? null : 
                                recordId.startsWith('00Q') ? 'Lead' : 
                                recordId.startsWith('001') ? 'Account' : null;

            PicklistResponse responseData = new PicklistResponse();

            if (objectType != null) {
                FormPageController controller = new FormPageController();
                if (objectType == 'Lead') controller.setLeadId(recordId);
                else controller.setAccountId(recordId);

                responseData.getDomicile                   = convertSelectOptions(controller.getDomicile());
                responseData.getProgramsList               = convertSelectOptions(controller.getProgramsList());
                responseData.getWorkExpTimeList            = convertSelectOptions(controller.getWorkExpTimeList());
                responseData.getProgramTypePicklistValues  = convertSelectOptions(controller.getProgramTypePicklistValues());
                responseData.getUniversityOption           = convertUniversityList(GetUniversityList.getUniversityDetails());
                responseData.getGlobalLocalityOptionValues = getPicklistOptions(Lead.Locality__c);
                responseData.globalStateValue              = getPicklistOptions(Lead.State__c);
                responseData.globalCountryValue            = getPicklistOptions(Lead.Country__c);
                responseData.getBachelorsDegree            = getPicklistOptions(Lead.nm_BachelorsDegreeName__c);
                responseData.getMastersDegree              = getPicklistOptions(Lead.Master_s_Degree_Name__c);
                responseData.getIndustryOptions            = getPicklistOptions(nm_WorkExperience__c.Industry__c);
                responseData.getAnnualIncomeOptions         = getPicklistOptions(nm_WorkExperience__c.Annual_Income__c);
                responseData.getDepartmentOptions          = getPicklistOptions(nm_WorkExperience__c.nm_Department__c);
                responseData.getDesignationOptions         = getPicklistOptions(nm_WorkExperience__c.nm_Designation__c);
                responseData.getExperienceLevelOptions     = getPicklistOptions(nm_WorkExperience__c.Experience_Level__c);
                // responseData.getCompanyNames               = convertCompanyList(getCompanyNames());
            }

            res.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse('Success', 'Picklist values fetched successfully', responseData)));
        } catch (Exception e) {
            handleError(e, 'Error retrieving picklist values');
        }
    }

    /**
    * @description : HTTP POST - Fetch program change picklist values
    * @author @Ravi | 19--09--2025 
    **/
    @HttpPost
    global static void getProgramChangePicklistValues() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');

        try {
            String requestBody   = (RestContext.request.requestBody != null) ? RestContext.request.requestBody.toString() : '';
            RequestWrapper input = (RequestWrapper) JSON.deserialize(requestBody, RequestWrapper.class);

            programResponse = new ProgramPicklist();
            programResponse.getSpecializationList      = getSpecializationList(input.chooseProgram, input.IsLateral, input.lateralCourseName); 
            programResponse.getProgramsList            = getProgramsList(input.chooseProgram, input.programType);
            programResponse.getEligibilityCriteriaList = getEligibilityCriteriaList(input.chooseProgram, input.programType);

            res.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse('Success', 'Picklist values fetched successfully', programResponse)));
        } catch (Exception e) {
            handleError(e, 'Error retrieving program picklist values');
        }
    }

    /**
    * @description 
    * @author @Ravi | 19--09--2025 
    * @param String chooseProgram 
    * @param Boolean IsLateral 
    * @param String lateralCourseName 
    * @return List<SelectOption> 
    **/
    public static List<SelectOption> getSpecializationList(String chooseProgram, Boolean IsLateral, String lateralCourseName) {
        Map<String,String> master   = new Map<String,String>{ 'MBA (WX)' => 'Master of Business Administration (Working Executive)'};
        Map<String,String> bachelor = new Map<String,String>{ 'BCom' => 'Bachelor of Commerce', 'BBA' => 'Bachelor of Business Administration' };
        Map<String,String> mbaOnline= new Map<String,String>{ 'MBA'  => 'Master of Business Administration' };

        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', 'Choose Program') };
        String selectedProgram = String.isBlank(chooseProgram) ? '' : chooseProgram.trim();

        if (selectedProgram == 'Master Programs') {
            options.addAll(getOptionsFromMap(master));
        } else if (selectedProgram == 'MBA (Online) Programs') {
            options.addAll(getOptionsFromMap(mbaOnline));
        } else if (selectedProgram == 'Bachelor Programs') {
            for (String key : bachelor.keySet()) {
                if (IsLateral) {
                    if ((lateralCourseName == 'Certificate in Business Administration' && key == 'BBA') ||
                        (lateralCourseName == 'Certificate in General Management' && key == 'BCom')) {
                        options.add(new SelectOption(key, bachelor.get(key)));
                    }
                } else {
                    options.add(new SelectOption(key, bachelor.get(key)));
                }
            }
        }
        return options;
    }

    /**
    * @description 
    * @author @Ravi | 19--09--2025 
    * @param String chooseProgram 
    * @param String programType 
    * @return List<SelectOption> 
    **/
    public static List<SelectOption> getProgramsList(String chooseProgram, String programType) {
        List<SelectOption> options = new List<SelectOption>();
        List<nm_Program__c> programs;

        if (new List<String>{'Master Programs', 'Bachelor Programs', 'MBA (Online) Programs'}.contains(chooseProgram)) {
            programs = [SELECT Id, nm_ProgramName__c, Form_Specialisation__c, Specialisation__c  FROM nm_Program__c  WHERE nm_Type__c = :chooseProgram AND Specialisation__c = :programType 
                          AND nmIsActive__c = true ORDER BY Name ASC];
            options.add(new SelectOption('', 'Choose Specialization'));
        } else {
            chooseProgram = String.isBlank(chooseProgram) ? 'Certificate Programs' : chooseProgram;
            programs = [SELECT Id, nm_ProgramName__c, Specialisation__c, Form_Specialisation__c FROM nm_Program__c WHERE nm_Type__c = :chooseProgram 
                          AND nmIsActive__c = true ORDER BY Name ASC];
            options.add(new SelectOption('', 'Choose Program'));
        }

        for (nm_Program__c prog : programs) {
            String prgName = (prog.Form_Specialisation__c != null) ? prog.Form_Specialisation__c : prog.nm_ProgramName__c;
            options.add(new SelectOption(prog.Id, prgName));
        }
        return options;
    }

    public static List<SelectOptionForCriteria> getEligibilityCriteriaList(String chooseProgram, String type ){  
        List<SelectOptionForCriteria> lstECOptions = new List<SelectOptionForCriteria>{ new SelectOptionForCriteria('', '---None--',0) };

        String programType = (chooseProgram == 'Master Programs') ? type : null;
        List<nm_EligiblityCriteria__c> lstEligibility = [
            SELECT Id,nm_EligiblityCriteria__c,Experience_Required_In_Year__c,HSC_Re__c,Diploma_Required__c, Graduation_Required__c,Post_Graduation_Required__c,Post_Graduation_Percentage__c,Graduation_Percentage__c,nm_Program__c,Is_Active__c,Program_Type__c,HSC_Percentage__c,
                   Diploma_Percentage__c,Enable_Master__c FROM nm_EligiblityCriteria__c WHERE Program_Type__c = :programType  AND nm_Program__c = :chooseProgram AND Is_Active__c = true];

        if (!lstEligibility.isEmpty()) {
            Map<String,String>  mapWorkExp = new Map<String,String>();
            Map<String,Decimal> mapAcademicPerc = new Map<String,Decimal>();
            Map<String,Boolean> mapAcademicReq = new Map<String,Boolean>();
            Map<String,Boolean> mapMaster = new Map<String,Boolean>();

            for (nm_EligiblityCriteria__c obj : lstEligibility) {
                Decimal we = (obj.Experience_Required_In_Year__c == null) ? 0 : obj.Experience_Required_In_Year__c;
                lstECOptions.add(new SelectOptionForCriteria(obj.Id, obj.nm_EligiblityCriteria__c, we));

                mapWorkExp.put(obj.Id, String.valueOf(obj.Experience_Required_In_Year__c));
                mapAcademicReq.put(obj.Id+'-HSC', obj.HSC_Re__c);
                mapAcademicReq.put(obj.Id+'-Diploma', obj.Diploma_Required__c);
                mapAcademicReq.put(obj.Id+'-Graduation', obj.Graduation_Required__c);
                mapAcademicReq.put(obj.Id+'-Professional', obj.Post_Graduation_Required__c);

                mapAcademicPerc.put(obj.Id+'-HSC', obj.HSC_Percentage__c);
                mapAcademicPerc.put(obj.Id+'-Diploma', obj.Diploma_Percentage__c);
                mapAcademicPerc.put(obj.Id+'-Graduation', obj.Graduation_Percentage__c);
                mapAcademicPerc.put(obj.Id+'-Professional', obj.Post_Graduation_Percentage__c);

                mapMaster.put(obj.Id, obj.Enable_Master__c);
            }

            programResponse = (programResponse == null) ? new ProgramPicklist() : programResponse;
            programResponse.jsonMapOfEligibilityVsWorkExp                  = mapWorkExp;
            programResponse.jsonMapOfEligibilityVsRequiredAcademic         = mapAcademicReq;
            programResponse.jsonMapOfEligibilityVsRequiredAcademicPercentage = mapAcademicPerc;
            programResponse.jsonMapOfEligibilityVsMaster                   = mapMaster;
        }
        return lstECOptions;
    }

    // ----------------------------
    // Utility Methods
    // ----------------------------
    /**
    * @description 
    * @author @Ravi | 19--09--2025 
    * @param Map<String String> input 
    * @return List<SelectOption> 
    **/
    private static List<SelectOption> getOptionsFromMap(Map<String,String> input) {
        List<SelectOption> options = new List<SelectOption>();
        for (String key : input.keySet()) options.add(new SelectOption(key, input.get(key)));
        return options;
    }

    // public static List<String> getCompanyNames() {
    //     List<String> companies = new List<String>();

    //     // Load the static resource
    //     StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'CompanyNames' LIMIT 1];
    //     String jsonString = sr.Body.toString();

    //     // Deserialize (assuming format: [ { "name": "TCS" }, { "name": "Infosys" } ])
    //     List<Object> parsedList = (List<Object>) JSON.deserializeUntyped(jsonString);

    //     for (Object obj : parsedList) {
    //         Map<String, Object> record = (Map<String, Object>) obj;
    //         if (record.containsKey('name')) {
    //             companies.add(String.valueOf(record.get('name')));
    //         }
    //     }
    //     return companies;
    // }

    private static List<UniversityOption> convertUniversityList(List<University_List__c> uniList) {
        List<UniversityOption> options = new List<UniversityOption>{ new UniversityOption('', '-- Select --','') };
        for (University_List__c uni : uniList) {
            options.add(new UniversityOption(uni.University_Name__c, uni.University_Name__c, uni.University_Type__c));
        }
        return options;
    }

    // private static List<SelectOption> convertCompanyList(List<String> CompanyList) {
    //     List<SelectOption> options = new List<SelectOption>{ new SelectOption('', '-- Select --') };
    //     for (String name : CompanyList) {
    //         options.add(new SelectOption(name, name));
    //     }
    //     return options;
    // }

    private static List<SelectOption> getPicklistOptions(Schema.SObjectField field) {
        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', '---None---') };
        for (Schema.PicklistEntry pe : field.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(pe.getValue(), pe.getValue()));
        }
        return options;
    }

    private static List<SelectOption> convertSelectOptions(List<System.SelectOption> options) {
        if (options == null) return null;
        List<SelectOption> result = new List<SelectOption>();
        for (System.SelectOption opt : options) result.add(new SelectOption(opt.getValue(), opt.getLabel()));
        return result;
    }

    private static void handleError(Exception e, String customMessage) {
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(
            new BaseResponse('Error', customMessage + ': ' + e.getMessage(), null)
        ));
    }

    // ----------------------------
    // Response Wrapper Classes
    // ----------------------------
    global class PicklistResponse {
        public List<SelectOption> getDomicile;
        public List<SelectOption> getProgramsList;
        public List<SelectOption> globalStateValue;
        public List<SelectOption> globalCountryValue;
        public List<SelectOption> getWorkExpTimeList;
        public List<SelectOption> getProgramTypePicklistValues;
        public List<UniversityOption> getUniversityOption;
        public List<SelectOption> getBachelorsDegree;
        public List<SelectOption> getMastersDegree;
        public List<SelectOption> getGlobalLocalityOptionValues;
        public List<selectOption> getIndustryOptions;
        // public List<SelectOption> getCompanyNames;
        public List<SelectOption> getDepartmentOptions;
        public List<SelectOption> getDesignationOptions;
        public List<SelectOption> getExperienceLevelOptions;
        public List<SelectOption> getAnnualIncomeOptions;

    }

    global class ProgramPicklist {
        public List<SelectOption> getSpecializationList;
        public List<SelectOption> getProgramsList;
        public List<SelectOptionForCriteria> getEligibilityCriteriaList;
        public Map<String,Boolean> jsonMapOfEligibilityVsMaster;
        public Map<String,Decimal> jsonMapOfEligibilityVsRequiredAcademicPercentage;
        public Map<String,Boolean> jsonMapOfEligibilityVsRequiredAcademic;
        public Map<String,String> jsonMapOfEligibilityVsWorkExp;
    }

    global class SelectOption {
        public String value;
        public String label;
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    global class UniversityOption {
        public String value;
        public String label;
        public String Type;
        public UniversityOption(String value, String label, String Type) {
            this.value = value;
            this.label = label;
            this.Type  = Type;
        }
    }

    global class SelectOptionForCriteria {
        public String value;
        public String label;
        public Decimal WExpRequired;
        public SelectOptionForCriteria(String value, String label, Decimal WeRequired) {
            this.value = value;
            this.label = label;
            this.WExpRequired = WeRequired;
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

    global class RequestWrapper {
        public String chooseProgram;
        public Boolean IsLateral;
        public String lateralCourseName;
        public String programType;
    }
}