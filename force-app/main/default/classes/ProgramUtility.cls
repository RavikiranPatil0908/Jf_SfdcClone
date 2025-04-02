/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  : @BK
**/
public without sharing class ProgramUtility {
    private static ProgramUtility utils { get; private set; }
    public UtlityProgramWrapper objWrapper {get; private set;}

    public ProgramUtility() {
        this.objWrapper = getPrograms();
    }

    public static ProgramUtility getInstance() {
        if(utils == null) {
            utils = new ProgramUtility();
        }
        return utils;
    }

    /**
    * @description 
    * @author @BK | 30-12-2023 
    * @return UtlityProgramWrapper 
    **/
    public UtlityProgramWrapper getPrograms() {
        UtlityProgramWrapper objWrapperV2 = new UtlityProgramWrapper();
        objWrapperV2.mapOfNameVsProgram = new Map<String,nm_Program__c>();
        // query Program as Map
        objWrapperV2.mapOfIdVsProgram = new Map<Id,nm_Program__c>([SELECT Id,Name,AI_Component__c,Anytime_Lateral__c,applicableforDeregister__c,Bachelor_Specialization__c,nm_Type__c,
        BookCChargeapplicable__c,Drive_change_applicable__c,Dual_Specialization__c,Fee_program__c,Form_Specialisation__c,Gap_Month__c,nmIsActive__c,
        isLiveLecture__c,IsTerm__c,Loan_API_Code__c,nm_ProgramCode__c,nm_ProgramDuration__c,Program_Id__c,nm_ProgramName__c,prgst__c,PVM__c,nm_TotalSemesters__c,
        nm_ProgramValidity__c,PVPerSM__c,PVPerSM2__c,Propelld_API_Code__c,ReRegonly__c,SAP_Program_Code__c,Specialisation__c,StudentZoneProgramCode__c
        FROM nm_Program__c WHERE nm_Type__c!=null]);

        objWrapperV2.lstPrograms = objWrapperV2.mapOfIdVsProgram.values();
        for (nm_Program__c objProgram : objWrapperV2.mapOfIdVsProgram.values()) {
            objWrapperV2.mapOfNameVsProgram.put(objProgram.nm_ProgramName__c,objProgram);
        }
        System.debug('On Program Util ==>'+objWrapperV2.lstPrograms.size());
        return objWrapperV2;
    }

    public class UtlityProgramWrapper {
        public Map<Id,nm_Program__c> mapOfIdVsProgram { get; private set; }
        public Map<String,nm_Program__c> mapOfNameVsProgram { get; private set; }
        public List<nm_Program__c> lstPrograms {get; private set;}
    }
}