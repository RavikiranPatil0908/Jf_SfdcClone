public without sharing class AsyncShootJunctionController {
    public AsyncShootJunctionController() {

    }
    public  String jsonAsString { get; set; }
    public  void importCSVFile() {
        
        System.debug( 'jsonAsString :: '+jsonAsString);
        try {
            if (jsonAsString.equalsignorecase('')) {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select excel file.'));
                    return;
        }
        AsyncShootandJunctionHelper asyncwrapper = new AsyncShootandJunctionHelper();
        Map<String, String> tocDataMap = asyncwrapper.getWrapper.getTocDataMap;

        List<AsyncObject> lstJSONObject =  (List<AsyncObject>)System.JSON.deserialize(jsonAsString, List<AsyncObject>.class);

        if (lstJSONObject.size() > 200) {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, 'The excel uploaded file exceeds 200 record limit.'));
                    return;
        }
        String successMsg='';
        String failMsg='';
        List<String> lstColumnId = new List<String>();
        Integer columnId = 2;
        List<Async_Shoot_Post_Production__c> csvDataMap = new List<Async_Shoot_Post_Production__c>();
        for (AsyncObject mapOfExcelData : lstJSONObject) {

            if(!String.isBlank(mapOfExcelData.Block_Name)|| !String.isBlank(mapOfExcelData.Subject) || !String.isBlank(mapOfExcelData.Program)|| 
            !String.isBlank(mapOfExcelData.Unit_Name)|| String.isBlank(mapOfExcelData.Post_Production_Minutes)|| String.isBlank(mapOfExcelData.Final_Video_Link) ||
                String.isBlank(mapOfExcelData.Video_Coverage)|| String.isBlank(mapOfExcelData.Learning_Objectives)||
                 String.isBlank(mapOfExcelData.Learning_Outcomes)){
            
            
             String mapKey = (String)mapOfExcelData.Block_Name.trim(); 
                    mapKey += '-'+ (String)mapOfExcelData.Subject.trim();
                    mapKey += '-'+ (String)mapOfExcelData.Program.trim();
                    mapKey += '-'+ (String)mapOfExcelData.Unit_Name.trim();
                    mapKey += (String)mapOfExcelData.Topic_Name != null ? '-'+ mapOfExcelData.Topic_Name : '-'+ null;
                    mapKey += (String)mapOfExcelData.SubTopic_Name != null ? '-'+ mapOfExcelData.SubTopic_Name : '-'+ null;
                   // System.debug('mapKey123 ::'+mapKey);(Introduction to Operations Research-Operations Research-MBA-Basics of Operations ResearchLearning Objectivenull)
        if(TOCDataMap.containsKey(mapKey)){

           Async_Shoot_Post_Production__c  asyncShootData = new Async_Shoot_Post_Production__c();

            asyncShootData.put('Acads_Team_Remarks__c', mapOfExcelData.Acads_Team_Remarks);
            asyncShootData.put('Chapter_Name__c', mapOfExcelData.Chapter_Name);
            asyncShootData.put('Downloaded_File_Name__c', mapOfExcelData.Downloaded_File_Name);
            asyncShootData.put('Faculty__c', mapOfExcelData.Faculty);
            asyncShootData.put('Faculty_Email__c', mapOfExcelData.Faculty_Email);
            asyncShootData.put('Faculty_ID__c', mapOfExcelData.Faculty_ID);
            asyncShootData.put('Faculty_Name__c', mapOfExcelData.Faculty_Name);
            asyncShootData.put('Faculty_Remarks_for_Edit_Version_1__c', mapOfExcelData.Faculty_Remarks_for_Edit_Version_1);
            asyncShootData.put('Faculty_Remarks_for_Edit_Version_2__c', mapOfExcelData.Faculty_Remarks_for_Edit_Version_2);
            asyncShootData.put('Final_Video_Link__c', mapOfExcelData.Final_Video_Link);
            asyncShootData.put('Formatted_PPT_Path__c', mapOfExcelData.Formatted_PPT_Path);
            asyncShootData.put('Internal_Video_Remarks__c', mapOfExcelData.Internal_Video_Remarks);
            asyncShootData.put('Learning_Objectives__c', mapOfExcelData.Learning_Objectives);

            asyncShootData.put('Learning_Outcomes__c', mapOfExcelData.Learning_Outcomes);
            asyncShootData.put('Mapping_Status__c', mapOfExcelData.Mapping_Status);
            asyncShootData.put('Partner__c', mapOfExcelData.Partner);
            asyncShootData.put('Post_Production_Status__c', mapOfExcelData.Post_Production_Status);
            asyncShootData.put('Production_Team_Remarks__c', mapOfExcelData.Production_Team_Remarks);
            asyncShootData.put('Program__c', mapOfExcelData.Program);

            asyncShootData.put('Recording_Format__c', mapOfExcelData.Recording_Format);
            asyncShootData.put('Recording_Platform__c', mapOfExcelData.Recording_Platform);
            asyncShootData.put('Semester__c', mapOfExcelData.Semester);
            asyncShootData.put('Subject__c', mapOfExcelData.Subject);

            asyncShootData.put('Video_Link_Version_1__c', mapOfExcelData.Video_Link_Version_1);
            asyncShootData.put('Video_Link_Version_2__c', mapOfExcelData.Video_Link_Version_2);
            asyncShootData.put('Video_Link_Version_3__c', mapOfExcelData.Video_Link_Version_3);
            asyncShootData.put('Topics_Covered__c', mapOfExcelData.Video_Title);
            asyncShootData.put('Zoom_Raw_Video_Link__c', mapOfExcelData.Zoom_Raw_Video_Link);
            asyncShootData.put('SubTopics__c', mapOfExcelData.Video_Coverage);
            
            asyncShootData.put('Editor_Email__c', mapOfExcelData.Editor_Email);
            asyncShootData.put('Editor_Name__c', mapOfExcelData.Editor_Name);
            asyncShootData.put('Editor_Email_Id__c',mapOfExcelData.Editor_Email_Id);

            asyncShootData.put('Draft_Acads_Upload__c',  !(mapOfExcelData.Draft_Acads_Upload == null) &&  Boolean.valueOf(Integer.valueOf( mapOfExcelData.Draft_Acads_Upload) == 1 ? 'true' : 'false'));
            asyncShootData.put('Draft_Video_Upload_by_IT__c',!(mapOfExcelData.Draft_Video_Upload == null) &&  Boolean.valueOf(Integer.valueOf(mapOfExcelData.Draft_Video_Upload) == 1 ? 'true' : 'false'));
            asyncShootData.put('Is_Billed__c', !(mapOfExcelData.Is_Billed == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.Is_Billed) == 1 ? 'true' : 'false'));
            asyncShootData.put('isTOC_Mapped__c', !(mapOfExcelData.isTOC_Mapped == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.isTOC_Mapped) == 1 ? 'true' : 'false'));
            asyncShootData.put('Post_Production_Minutes_Approved__c',!(mapOfExcelData.Post_Production_Minutes_Approved == null) && Boolean.valueOf(Integer.valueOf( mapOfExcelData.Post_Production_Minutes_Approved) == 1 ? 'true' : 'false'));
            asyncShootData.put('PPT_Received_from_Faculty__c', !(mapOfExcelData.PPT_Received_from_Faculty == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.PPT_Received_from_Faculty) == 1 ? 'true' : 'false'));
            asyncShootData.put('PPT_Shared_with_Production__c', !(mapOfExcelData.PPT_Shared_with_Production == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.PPT_Shared_with_Production) == 1 ? 'true' : 'false'));

            asyncShootData.put('Recording_Plan__c', !(mapOfExcelData.Recording_Plan == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.Recording_Plan) == 1 ? 'true' : 'false'));
            asyncShootData.put('Request_to_Delete__c', !(mapOfExcelData.Request_to_Delete == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.Request_to_Delete) == 1 ? 'true' : 'false'));
            asyncShootData.put('Topic_Uploaded_on_Portal__c', !(mapOfExcelData.Topic_Uploaded_on_Portal == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.Topic_Uploaded_on_Portal) == 1 ? 'true' : 'false'));
            asyncShootData.put('Video_Uploaded_on_AWS__c', !(mapOfExcelData.Video_Uploaded_on_AWS == null) && Boolean.valueOf(Integer.valueOf(mapOfExcelData.Video_Uploaded_on_AWS) == 1 ? 'true' : 'false'));
           
            asyncShootData.put('Planned_Date_for_Edited_Video__c', !(mapOfExcelData.Planned_Date_for_Edited_Video == null) && !mapOfExcelData.Planned_Date_for_Edited_Video.equalsignorecase('') ? Date.valueOf(mapOfExcelData.Planned_Date_for_Edited_Video.replace('/','-')) : null );
            asyncShootData.put('Shoot_Date__c', !(mapOfExcelData.Shoot_Date == null) && !mapOfExcelData.Shoot_Date.equalsignorecase('') ? Date.valueOf(mapOfExcelData.Shoot_Date.replace('/','-')) : null );

            asyncShootData.put('Recording_Minutes__c', !(mapOfExcelData.Recording_Minutes == null) && !mapOfExcelData.Recording_Minutes.equalsignorecase('') ? Integer.valueOf(mapOfExcelData.Recording_Minutes) : null  );
            asyncShootData.put('Post_Production_Minutes__c', !(mapOfExcelData.Post_Production_Minutes == null) && !mapOfExcelData.Post_Production_Minutes.equalsignorecase('') ? Integer.valueOf(mapOfExcelData.Post_Production_Minutes) : null );
  
            asyncShootData.put('Shoot_End_Time__c', !(mapOfExcelData.Shoot_End_Time == null) && !mapOfExcelData.Shoot_End_Time.equalsignorecase('') ? Datetime.valueOf( mapOfExcelData.Shoot_End_Time.replace('/','-')).time() : null);
            asyncShootData.put('Shoot_Start_Time__c', !(mapOfExcelData.Shoot_Start_Time == null) && !mapOfExcelData.Shoot_Start_Time.equalsignorecase('') ? Datetime.valueOf(mapOfExcelData.Shoot_Start_Time.replace('/','-')).time() : null);

            asyncShootData.put('Video_Link_V1_Date_Time__c',  !(mapOfExcelData.Video_Link_V1_DateTime == null) && !mapOfExcelData.Video_Link_V1_DateTime.equalsignorecase('') ? Datetime.valueOf(mapOfExcelData.Video_Link_V1_DateTime.replace('/','-')) : null );
            asyncShootData.put('Video_Link_V2_Date_Time__c', !(mapOfExcelData.Video_Link_V2_DateTime == null) && !mapOfExcelData.Video_Link_V2_DateTime.equalsignorecase('') ? Datetime.valueOf(mapOfExcelData.Video_Link_V2_DateTime.replace('/','-')) : null );
            asyncShootData.put('MapKey__c',mapKey);

            csvDataMap.add(asyncShootData);
            successMsg += columnId+',';
            columnId++;
        }else{
            lstColumnId.add(columnId+' - ('+mapKey+')');
            failMsg += columnId+',';
            columnId++;
        }   
    } 
        }
        insert csvDataMap;
        List<AsyncTOCLink__c> asyncToLinkList = new List<AsyncTOCLink__c>();
        for(Async_Shoot_Post_Production__c mkey:csvDataMap)
        {
            AsyncTOCLink__c obj = new AsyncTOCLink__c();
            obj.Async_Shoot_Post_Production__c = mkey.Id;
            obj.TOC__c = tocDataMap.get(mkey.MapKey__c);
            asyncToLinkList.add(obj);
        }
        insert asyncToLinkList;
        System.debug('CSVData Size ==>'+csvDataMap.size()+asyncToLinkList.toString());
        String errorMsg = '';
        for (String data : lstColumnId) {
            errorMsg += data+' || ';
        }
        ApexPages.addMessage(
            new ApexPages.Message(ApexPages.Severity.CONFIRM, +csvDataMap.size() +' records('+ successMsg +') uploaded Successfully.')
           );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' records('+ failMsg +') not added. Details ::  '+errorMsg +' make sure that excel data matches with TOC table data(Block_Name-Subject-Program-Unit_Name-Topic_Name-SubTopic_Name)')
            );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ' make sure that excel data matches with TOC table data(Block_Name-Subject-Program-Unit_Name-Topic_Name-SubTopic_Name) and Date format is as Planned_Date_for_Edited_Video and Shoot_Date :-  yyyy-mm-dd hh:mm:ss and Shoot_Start_Time , Shoot_End_Time , Video_Link_V1_DateTime and Video_Link_V2_DateTime :-  yyyy-mm-dd hh:mm:ss AM/PM')
            );
        } catch(Exception e) {
            system.debug('Error 1 is==>'+e.getMessage());
            system.debug('Error 2 is==>'+e.getLineNumber());
            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while importing data into Salesforce. Please make sure input xlsx file is correct');
            ApexPages.addMessage(errorMessage);
        }
    }
        // Define the refreshPage method to refresh the page
        public PageReference refreshPage() {
            // Redirect to the current page to refresh it
            PageReference pageRef = ApexPages.currentPage();
            pageRef.setRedirect(true);
            return pageRef;
        }
        // Define the backSessionYearPage method to back the page
        public PageReference backSessionYearPage() {
            // Redirect to the current page to back it
            PageReference pageRef = ApexPages.currentPage();
            pageRef.setRedirect(true);
            return pageRef;
        }


        public class AsyncObject {


            public AsyncObject() {

                this.Acads_Team_Remarks = '';
                this.Async_Shoot_Post_Production_Name = '';
                this.Block_Name = '';
                this.Chapter_Name = '';
                this.Current_Download_Link = '';
                this.Downloaded_File_Name = '';
                this.Draft_Acads_Upload = '';
                this.Draft_Video_Upload = '';
                this.Edited_Hours = '';
                this.Editor_Email = '';
                this.Editor_Email_Id = '';
                this.Editor_Name = '';
                this.Faculty = '';
                this.Faculty_Email = '';
                this.Faculty_ID = '';
                this.Faculty_Name = '';
                this.Faculty_Remarks_for_Edit_Version_1 = '';
                this.Faculty_Remarks_for_Edit_Version_2 = '';
                this.File_Name = '';
                this.FileName_Revised = '';
                this.Final_Video_Link = '';
                this.Formatted_PPT_Path = '';
                this.Internal_Video_Remarks = '';
                this.Is_Billed = '';
                this.isTOC_Mapped = '';
                this.Learning_Objectives = '';
                this.Learning_Outcomes = '';
                this.Mapping_Status = '';
                this.Partner = '';
                this.Planned_Date_for_Edited_Video = null;
                this.Post_Production_Minutes = '';
                this.Post_Production_Minutes_Approved = '';
                this.Post_Production_Status = '';
                this.PPT_Received_from_Faculty = '';
                this.PPT_Shared_with_Production = '';
                this.Production_Team_Remarks = '';
                this.Program = '';
                this.Recording_Format = '';
                this.Recording_Minutes = '';
                this.Recording_Plan = '';
                this.Recording_Platform = '';
                this.Request_to_Delete = '';
                this.Semester = '';
                this.Shoot_Date = null;
                this.Shoot_End_Time = '';
                this.Shoot_Start_Time = '';
                this.Subject = '';
                this.Topic_Uploaded_on_Portal = '';
                this.Unit_Name = '';
                this.Video_Coverage = '';
                this.Video_Link_V1_DateTime = '';
                this.Video_Link_V2_DateTime = '';
                this.Video_Link_Version_1 = '';
                this.Video_Link_Version_2 = '';
                this.Video_Link_Version_3 = '';
                this.Video_Title = '';
                this.Video_Uploaded_on_AWS = '';
                this.Zoom_Raw_Video_Link = '';
                this.Topic_Name = '';
                this.SubTopic_Name = '';

            }
            public String Async_Shoot_Post_Production_Name {get;set;}

            public String Acads_Team_Remarks {get;set;}
            public String Downloaded_File_Name {get;set;}

            public String Chapter_Name {get;set;}
            public String Current_Download_Link {get;set;}
            public String Draft_Acads_Upload {get;set;}
            public String Draft_Video_Upload {get;set;}
            public String Edited_Hours {get;set;}
            public String Editor_Email {get;set;}
            
            public String Editor_Email_Id {get;set;}
            public String Editor_Name {get;set;}
            public String Faculty {get;set;}
            public String Faculty_Email {get;set;}
            public String Faculty_ID {get;set;}
            public String Faculty_Name {get;set;}
            public String Faculty_Remarks_for_Edit_Version_1 {get;set;}
            public String Faculty_Remarks_for_Edit_Version_2 {get;set;}

            public String File_Name {get;set;}

            public String FileName_Revised {get;set;}

            public String Final_Video_Link {get;set;}

            public String Formatted_PPT_Path {get;set;}
            public String Internal_Video_Remarks {get;set;}


            public String Is_Billed {get;set;}
            public String isTOC_Mapped {get;set;}
            public String Learning_Objectives {get;set;}

            public String Learning_Outcomes {get;set;}

            public String Mapping_Status {get;set;}

            public String Partner {get;set;}
            public String Planned_Date_for_Edited_Video {get;set;}


            public String Post_Production_Minutes {get;set;}
            public String Post_Production_Minutes_Approved {get;set;}

            public String Post_Production_Status {get;set;}
            public String PPT_Received_from_Faculty {get;set;}
            public String PPT_Shared_with_Production {get;set;}

            public String Production_Team_Remarks {get;set;}

            public String Program {get;set;}

            public String Recording_Format {get;set;}

            public String Recording_Minutes {get;set;}


            public String Recording_Plan {get;set;}
            public String Recording_Platform {get;set;}
            public String Request_to_Delete {get;set;}

            public String Semester {get;set;}
            public String Shoot_End_Time {get;set;}
            public String Shoot_Start_Time {get;set;}

            public String Shoot_Date {get;set;}
            public String Subject {get;set;}
            public String Topic_Uploaded_on_Portal {get;set;}
            public String Video_Coverage {get;set;}

            public String Video_Link_V1_DateTime {get;set;}
            public String Video_Link_V2_DateTime {get;set;}

            
            public String Video_Link_Version_1 {get;set;}
            public String Video_Link_Version_2 {get;set;}
            public String Video_Link_Version_3 {get;set;}
            

            public String Video_Title {get;set;}
            public String Video_Uploaded_on_AWS {get;set;}
            public String Zoom_Raw_Video_Link {get;set;}

            public String Block_Name {get;set;}
            public String Unit_Name {get;set;}
            public String Topic_Name {get;set;}
            public String SubTopic_Name {get;set;}
        }
}