/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 29-11-2024
 * @last modified by  : @BK
**/
global class EscalationLevelController {

    global class WrapperUserClass {
        public String Level1User { get; set; }
        public String Level2User { get; set; }
        public String Level3User { get; set; }
        public String Level4User { get; set; }

        // Constructor
        public WrapperUserClass(String firstOwner, String secondOwner, String thirdOwner, String fourthOwner) {
            this.Level1User = firstOwner;
            this.Level2User = secondOwner;
            this.Level3User = thirdOwner;
            this.Level4User = fourthOwner;
        }
    }

    /**
     * @description 
     * @author Ravi | 08-01-2024 
     * @param caseId 
     * @param EscalationLevel 
     * @param ECDDate 
     * @param CategoryEsclevel 
     * @return String 
     **/
    @AuraEnabled
    webService static String EscalateCase(String caseId, Integer EscalationLevel, Date ECDDate, Integer CategoryEsclevel) { 
        try {
            System.debug('caseId::' + caseId);
            System.debug('EscalationLevel::' + EscalationLevel);
            System.debug('ECDDate::' + ECDDate);
            System.debug('CategoryEsclevel::' + CategoryEsclevel);

            List<Case> lstCase = [
                SELECT id, Expected_Close_Date__c, Escalation_Level__c, Count_of_ECD_changed_By_System__c, FirstCaseAssigned__c, 
                       InternalCategory__c, OwnerId, Status, Owner.Name, CreatedBy.Name, CreatedBy.Id  
                FROM Case 
                WHERE id = :caseId  
                LIMIT 1
            ];

            Map<String, WrapperUserClass> mapCategoryWrapperUserClass = new Map<String, WrapperUserClass>{
                'Finance' => new WrapperUserClass('Finance Department', 'Dhyey', 'Rajiv Shah', ''),
                'Marketing' => new WrapperUserClass('Mihhiir Lakhani', 'Amit Deshmukh', 'Rajiv Shah', ''),
                'Admissions' => new WrapperUserClass('Admission Dept.', 'Admission Dept.', 'Rajiv Shah', ''),
                'Internal Exam' => new WrapperUserClass('Ngasce Exams', 'Priya Mathew', 'Rajiv Shah', ''),
                'TEE' => new WrapperUserClass('NCDOE Exams - University', 'Priya Mathew', 'Rajiv Shah', ''),
                'Academics' => new WrapperUserClass('Ngasce Academics', 'Priya Mathew', 'Rajiv Shah', ''),
                'Career Services' => new WrapperUserClass('Varun Mathur', 'Amit Deshmukh', 'Rajiv Shah', ''),
                'Product' => new WrapperUserClass('Likesh Bhambhwani', 'Rajiv Shah', '', ''),
                'Logistics' => new WrapperUserClass('Deepali Shetty', 'Deepali Shetty', 'Rajiv Shah', ''),
                'Student Support' => new WrapperUserClass('Sangeeta Shetty', 'Sangeeta Shetty', 'Rajiv Shah', ''),
                'AEP Request' =>  new WrapperUserClass('Admission Dept.', 'Admission Dept.', 'Rajiv Shah', ''),
                'LC' => new WrapperUserClass('', 'Binoy Nair', 'Amit Deshmukh', 'Rajiv Shah')
                
            };

            if (lstCase.size() > 0) {
                Case caseRecord = lstCase[0];
                EscalationLevel = (EscalationLevel != 0) ? EscalationLevel + 1 : 1;
                
                String owner = '';
                String category = caseRecord.InternalCategory__c;

                if (EscalationLevel == 1) {
                    owner = category.startsWith('LC') ? category : mapCategoryWrapperUserClass.get(category).Level1User;
                } else if (EscalationLevel == 2) {
                    if (category.startsWith('LC')) category = 'LC';
                    owner = mapCategoryWrapperUserClass.get(category).Level2User;
                } else if (EscalationLevel == 3) {
                    if (category.startsWith('LC')) category = 'LC';
                    owner = mapCategoryWrapperUserClass.get(category).Level3User;
                } else if (EscalationLevel == 4) {
                    if (category.startsWith('LC')) category = 'LC';
                    owner = mapCategoryWrapperUserClass.get(category).Level4User;
                }

                if (owner != '') {
                    ChangeOwner(caseRecord, owner);
                }

                caseRecord.Expected_Close_Date__c = ECDDate;
                caseRecord.Escalation_Level__c = EscalationLevel;  
                caseRecord.Count_of_ECD_changed_By_System__c += 1;  
                caseRecord.Escalated_Date__c = System.today();   
                update caseRecord;

                return 'Case Escalated with Level ' + EscalationLevel + ' and Expected CloseDate is ' + ECDDate;
            } else {
                return 'Case not found';
            }
        } catch (Exception e) {
            System.debug('Failed to Escalate: ' + e.getMessage());
            return e.getMessage();
        } 
    }

    /**
     * @description 
     * @author Ravi | 08-01-2024 
     * @param caseRecord 
     * @param owner 
     * @return Boolean 
     **/
    @AuraEnabled
    public static Boolean ChangeOwner(Case caseRecord, String owner) {
        List<User> lstUser = [SELECT Id, Name FROM User WHERE Name = :owner];
        if (!lstUser.isEmpty()) {
            caseRecord.OwnerId = lstUser[0].Id;
            return true;
        } else {
            return false;
        }
    }
}