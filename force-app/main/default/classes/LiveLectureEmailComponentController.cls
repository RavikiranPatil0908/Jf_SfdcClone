public with sharing class LiveLectureEmailComponentController {
    public String OpportunityId;
    // public String emailName{get;set;}
    public String CoursesName{get;set;}
    public String RecordedName{get;set;}
    public Integer CourseCount{get;set;}
    public Integer RecordedCount{get;set;}
    public LiveLectureEmailComponentController() {
        //getCourseNameFromCourseId();
        // CoursesName = getCourseNameFromCourseId();
        // CourseCount = getCourseOptCount();
        // RecordedName = getCoursesNameForRecorded();
    }

    // public String getRandomText() {
	// 	return this.RandomText;
	// }

	// public void setRandomText(String RandomText) {
    //     if(OpportunityId != null){
    //         getCourseNameFromCourseId();
    //     }
	// }
    public String getOpportunityId() {
		return this.OpportunityId;
	}

	public void setOpportunityId(String OpportunityId) {
        this.OpportunityId = OpportunityId;
        if(OpportunityId != null){
             getCourseNameFromCourseId();
             getCoursesNameForRecorded();
          
        }
	}

    // public String getCoursesName() {
	// 	return this.CoursesName;
	// }

	// public void setCoursesName(String CoursesName) {
	// 	this.CoursesName = CoursesName;
	// }


    public void getCourseNameFromCourseId() {
       // String courseList;
        System.debug(this.OpportunityId);
       List< Opportunity >opp = [SELECT CourseList__c FROM Opportunity WHERE Id = :this.OpportunityId AND CourseList__c != null AND CourseList__c != ''];
        if(opp.size() > 0 ) {
            List<Integer> courseListId = new List<Integer>();
            System.debug(opp);
            List<String> newLis =opp[0].CourseList__c.split(',');
    
            for(String s: newLis) {
                courseListId.add(Integer.valueOf(s));
            }
            if(courseListId.size() > 0 ) {
                List<nm_Courses__c> courseName = [SELECT Name FROM nm_Courses__c WHERE Student_Zone_Course_Id__c IN :courseListId];
                List < String > strList = new List<String>();
                if(courseName.size() > 0) {
                    for(nm_Courses__c courses : courseName) {
                        strList.add(courses.Name);
                    }
                    this.CourseCount = courseName.size();
                    String CourseListNames = String.join( strList, ', ' );  
                    system.debug( 'Joined with coma is ' +CourseListNames );  
                    this.CoursesName = CourseListNames;
                }
            
        }
    }
    }

    
    public void getCoursesNameForRecorded() {
        List <Opportunity> opp = [SELECT CourseOptCount__c, nm_Program__c, nm_Semester__c, CourseList__c FROM Opportunity WHERE Id = :this.OpportunityId AND CourseList__c != null AND CourseList__c != '' Limit 1];
        if (opp.size() > 0) {
            List<Integer> courseListId = new List<Integer>();
            System.debug(opp);
            List<String> newLis =opp[0].CourseList__c.split(',');
    
            for(String s: newLis) {
                courseListId.add(Integer.valueOf(s));
            }
            List<nm_Courses__c> Courses = [SELECT Name, Student_Zone_Course_Id__c FROM nm_Courses__c WHERE Sem__c = :opp[0].nm_Semester__c AND Program__c = :opp[0].nm_Program__c];
            system.debug(Courses);
            List<Integer> ll = new List<Integer>();
            Set<String> coursesNamee= new Set<String>();

            // for(nm_Courses__c c: Courses) {
            //     ll.add(Integer.valueOf(c.Student_Zone_Course_Id__c));
            // }

            // for(nm_Courses__c c: Courses) {
            //     ll.add(Integer.valueOf(c.Student_Zone_Course_Id__c));
            //     for(Integer i: courseListId) {
            //         system.debug(i);
            //         if(!courseListId.contains(Integer.valueOf(c.Student_Zone_Course_Id__c))) {
            //             system.debug(c.Name);
            //             coursesNamee.add(c.Name);
            //         }
                    
            //     }
            // }
           
                for(Integer i: courseListId) {
                    for(nm_Courses__c c: Courses) {
                        ll.add(Integer.valueOf(c.Student_Zone_Course_Id__c));
                    system.debug(i);
                    if(!courseListId.contains(Integer.valueOf(c.Student_Zone_Course_Id__c))) {
                        system.debug(c.Name);
                        coursesNamee.add(c.Name);
                    }
                    
                }
            }
            system.debug(coursesNamee.toString());
            system.debug(coursesNamee.size());
            this.RecordedCount = coursesNamee.size();
            List<String>coursesNameeList = new List<String>(coursesNamee);
            String CourseListNames = String.join( coursesNameeList, ', ' );  
            system.debug( 'Joined with coma is ' +coursesNameeList ); 
            this.RecordedName= CourseListNames;

        }
    }


    // public String getAllCourseName() {
    //     List <Opportunity> opp = [SELECT Course_opt_Count__c, nm_Program__c, nm_Semester__c, CourseList__c	 FROM Opportunity WHERE Id = :this.OpportunityId Limit 1];
    //     if (opp.size() > 0) {
    //         List<Integer> courseListId = new List<Integer>();
    //         System.debug(opp);
    //         List<String> newLis =opp[0].CourseList__c.split(',');
    
    //         for(String s: newLis) {
    //             courseListId.add(Integer.valueOf(s));
    //         }
    //         List<nm_Courses__c> Courses = [SELECT Name, Student_Zone_Course_Id__c FROM nm_Courses__c WHERE Sem__c = :opp[0].nm_Semester__c AND Program__c = :opp[0].nm_Program__c];
    //         system.debug(Courses);
    //         List<Integer> ll = new List<Integer>();
    //         Set<String> coursesNamee= new Set<String>();          
    //                 for(nm_Courses__c c: Courses) {
    //                     system.debug(c.Name);
    //                     coursesNamee.add(c.Name);
    //             }
            
    //         system.debug(coursesNamee.toString());
    //         system.debug(coursesNamee.size());
    //         List<String>coursesNameeList = new List<String>(coursesNamee);
    //         String CourseListNames = String.join( coursesNameeList, ', ' );  
    //         system.debug( 'Joined with coma is ' +coursesNameeList ); 
    //         return CourseListNames;

    //     }
    //     return null;
    // }

    
}