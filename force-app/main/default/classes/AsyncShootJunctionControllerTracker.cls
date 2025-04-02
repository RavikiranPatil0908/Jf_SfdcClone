@isTest(SeeAllData=false)
public without sharing class AsyncShootJunctionControllerTracker {
    public AsyncShootJunctionControllerTracker() {

    }
        
     @testSetup
    public static void setUpData() {
        TOC__c obj = new TOC__C();
        obj.Block_Name__c = 'Customer Value & Customer Behavior';
        obj.Subject__c = 'Strategic Management';
        obj.Unit_Name__c = 'Analysing the Marketing Environment';
        obj.Topic_Name__c = 'Marketing Management';
        obj.Sub_Topic_Name__c = 'Marketing Management';
        obj.Program__c = 'MBA-WX';
        obj.Block_Number__c = '4';
        obj.Id__c = '1';
        obj.Unit_Number__c = '4';
    
        insert obj;
        
        TOC__c obj1 = new TOC__C();
        obj1.Block_Name__c = 'Customer Value & Customer Behavior';
        obj1.Subject__c = 'Marketing Management';
        obj1.Unit_Name__c = 'Analysing the Marketing Environment';
        obj1.Topic_Name__c = 'Marketing Management';
        obj1.Sub_Topic_Name__c = 'Marketing Management';
        obj1.Program__c = 'MBA';
        obj1.Block_Number__c = '4';
        obj1.Id__c = '2';
        obj1.Unit_Number__c = '4';
    
        insert obj1;
    }
    @isTest
    static void Test1() {
        Test.startTest();
        AsyncShootJunctionController asynconj1 = new AsyncShootJunctionController();
        asynconj1.jsonAsString = '[{"Async_Shoot_Post_Production_Name":"A-02650","Chapter_Name":"Evaluating SHRM","Current_Download_Link":"https://youtu.be/SZ6H_Hx0Ktk","Draft_Acads_Upload":"0","Draft_Video_Upload":"1","Edited_Hours":"0.217","Editor_Email_Id":"wagh.shree.SW@gmail.com","Editor_Name":"Vansh Wagh","Faculty":"Visiting Faculty","Faculty_Email":"ram2000_s@yahoo.com","Faculty_ID":"NMSCEMU215210008","Faculty_Name":"Sriram D. Deshpande","FileName_Revised":"A02650","Is_Billed":"0","isTOC_Mapped":"0","Learning_Objectives":"1. To plan and formulate HR Strategies 2. To execute HR strategies in the organization","Learning_Outcomes":"? Understanding the concept of evaluation and knowing why it is important to evaluate the strategic HR function","Partner":"Vansh Wagh","Post_Production_Minutes":"13","Post_Production_Minutes_Approved":"0","Post_Production_Status":"First Edit Shared by Production","PPT_Received_from_Faculty":"1","PPT_Shared_with_Production":"0","Program":"MBA-WX","Recording_Format":"Zoom","Recording_Plan":"0","Recording_Platform":" Zoom","Request_to_Delete":"0","Shoot_Date":"2024/02/19 00:00:00","Subject":"Strategic HRM : Gaining a Competitive Advantage","Topic_Uploaded_on_Portal":"0","Video_Coverage":"HR Audit","Video_Link_Version_1":"https://youtu.be/SZ6H_Hx0Ktk","Video_Title":"HR Audit","Video_Uploaded_on_AWS":"0","Zoom_Raw_Video_Link":"https://d18mu5y44w00v4.cloudfront.net/45816-84497273708-2023-11-10.mp4"},{"Async_Shoot_Post_Production_Name":"A-02614","Chapter_Name":"Paid Search Analytics","Current_Download_Link":"https://youtu.be/mnB4o36aqes","Draft_Acads_Upload":"1","Draft_Video_Upload":"1","Edited_Hours":"0.367","Editor_Email_Id":"roshanshetty196@gmail.com","Editor_Name":"Roshan Shetty","Faculty":"Visiting Faculty","Faculty_Email":"nidhitak06@gmail.com","Faculty_ID":"NGASCE0459","Faculty_Name":"Nidhi Tak","Faculty_Remarks_for_Edit_Version_1":"Timestamp Error found Correction needed Faculty Remarks Analysing the Google Analytics Report","FileName_Revised":"A02614","Is_Billed":"0","isTOC_Mapped":"0","Learning_Objectives":"Understanding Google Analytics, its benefits, types of data, navigation and report creation","Learning_Outcomes":"Reporting and Optimisation: Understanding Google Analytics Tool","Partner":"Roshan Shetty","Post_Production_Minutes":"22","Post_Production_Minutes_Approved":"0","Post_Production_Status":"Faculty Comments Fixed by Production","PPT_Received_from_Faculty":"1","PPT_Shared_with_Production":"0","Production_Team_Remarks":"Did not understand the remark, please elaborate","Program":"MBA-WX","Recording_Format":"Zoom","Recording_Plan":"0","Recording_Platform":" Zoom","Request_to_Delete":"0","Shoot_Date":"2024/02/08 00:00:00","Subject":"Search Engine Optimisation & Search Engine Marketing","Topic_Uploaded_on_Portal":"0","Video_Coverage":"Paid Search Analytics 3","Video_Link_V1_DateTime":"2024/02/20 12:46:00 PM","Video_Link_Version_1":"https://youtu.be/mnB4o36aqes","Video_Title":"Paid Search Analytics 3","Video_Uploaded_on_AWS":"0","Zoom_Raw_Video_Link":"https://d18mu5y44w00v4.cloudfront.net/45834-85378877750-2023-11-08.mp4"}]';
        asynconj1.importCSVFile();
        Test.stopTest();

    }
    //   @isTest
    // static void Test12() {
    //     Test.startTest();
    //     AsyncShootJunctionController asynconj1 = new AsyncShootJunctionController();
    //     String datastring = '{"Program":"MBA","Subject":"Marketing Management","Block_Name":"Customer Value & Customer Behavior","Unit_Name":"Analysing the Marketing Environment","SubTopic_Name":"Marketing Management"}';
    //     for(Integer  i = 0;i<250;i++)
    //     {
    //         datastring += ','+datastring;
    //     }
    //     datastring = '['+datastring+']';
    //     asynconj1.jsonAsString = datastring;//'[{"Async_Shoot_Post_Production_Name":"A-02650","Chapter_Name":"Evaluating SHRM","Current_Download_Link":"https://youtu.be/SZ6H_Hx0Ktk","Draft_Acads_Upload":"0","Draft_Video_Upload":"1","Edited_Hours":"0.217","Editor_Email_Id":"wagh.shree.SW@gmail.com","Editor_Name":"Vansh Wagh","Faculty":"Visiting Faculty","Faculty_Email":"ram2000_s@yahoo.com","Faculty_ID":"NMSCEMU215210008","Faculty_Name":"Sriram D. Deshpande","FileName_Revised":"A02650","Is_Billed":"0","isTOC_Mapped":"0","Learning_Objectives":"1. To plan and formulate HR Strategies 2. To execute HR strategies in the organization","Learning_Outcomes":"? Understanding the concept of evaluation and knowing why it is important to evaluate the strategic HR function","Partner":"Vansh Wagh","Post_Production_Minutes":"13","Post_Production_Minutes_Approved":"0","Post_Production_Status":"First Edit Shared by Production","PPT_Received_from_Faculty":"1","PPT_Shared_with_Production":"0","Program":"MBA-WX","Recording_Format":"Zoom","Recording_Plan":"0","Recording_Platform":" Zoom","Request_to_Delete":"0","Shoot_Date":"2024/02/19 00:00:00","Subject":"Strategic HRM : Gaining a Competitive Advantage","Topic_Uploaded_on_Portal":"0","Video_Coverage":"HR Audit","Video_Link_Version_1":"https://youtu.be/SZ6H_Hx0Ktk","Video_Title":"HR Audit","Video_Uploaded_on_AWS":"0","Zoom_Raw_Video_Link":"https://d18mu5y44w00v4.cloudfront.net/45816-84497273708-2023-11-10.mp4"},{"Async_Shoot_Post_Production_Name":"A-02614","Chapter_Name":"Paid Search Analytics","Current_Download_Link":"https://youtu.be/mnB4o36aqes","Draft_Acads_Upload":"1","Draft_Video_Upload":"1","Edited_Hours":"0.367","Editor_Email_Id":"roshanshetty196@gmail.com","Editor_Name":"Roshan Shetty","Faculty":"Visiting Faculty","Faculty_Email":"nidhitak06@gmail.com","Faculty_ID":"NGASCE0459","Faculty_Name":"Nidhi Tak","Faculty_Remarks_for_Edit_Version_1":"Timestamp Error found Correction needed Faculty Remarks Analysing the Google Analytics Report","FileName_Revised":"A02614","Is_Billed":"0","isTOC_Mapped":"0","Learning_Objectives":"Understanding Google Analytics, its benefits, types of data, navigation and report creation","Learning_Outcomes":"Reporting and Optimisation: Understanding Google Analytics Tool","Partner":"Roshan Shetty","Post_Production_Minutes":"22","Post_Production_Minutes_Approved":"0","Post_Production_Status":"Faculty Comments Fixed by Production","PPT_Received_from_Faculty":"1","PPT_Shared_with_Production":"0","Production_Team_Remarks":"Did not understand the remark, please elaborate","Program":"MBA-WX","Recording_Format":"Zoom","Recording_Plan":"0","Recording_Platform":" Zoom","Request_to_Delete":"0","Shoot_Date":"2024/02/08 00:00:00","Subject":"Search Engine Optimisation & Search Engine Marketing","Topic_Uploaded_on_Portal":"0","Video_Coverage":"Paid Search Analytics 3","Video_Link_V1_DateTime":"2024/02/20 12:46:00 PM","Video_Link_Version_1":"https://youtu.be/mnB4o36aqes","Video_Title":"Paid Search Analytics 3","Video_Uploaded_on_AWS":"0","Zoom_Raw_Video_Link":"https://d18mu5y44w00v4.cloudfront.net/45834-85378877750-2023-11-08.mp4"}]';
    //     asynconj1.importCSVFile();
    //     Test.stopTest();

    // }
    @isTest
    static void Test2() {
        Test.startTest();
        AsyncShootJunctionController asynconj1 = new AsyncShootJunctionController();
        asynconj1.jsonAsString = '[{"Topic_Name":"Marketing Management","Program":"MBA","Subject":"Marketing Management","Block_Name":"Customer Value & Customer Behavior","Unit_Name":"Analysing the Marketing Environment","SubTopic_Name":"Marketing Management","Post_Production_Minutes":"","Final_Video_Link":"","Video_Coverage":"Learning_Objectives","Learning_Outcomes":""}]';
        asynconj1.importCSVFile();
        Test.stopTest();

     }
    @isTest
    static void Test3() {
        Test.startTest();
        AsyncShootJunctionController.AsyncObject asynconj2 = new AsyncShootJunctionController.AsyncObject();
       
        AsyncShootJunctionController asynconj1 = new AsyncShootJunctionController();
        asynconj1.refreshPage();
        asynconj1.backSessionYearPage();
        Test.stopTest();

    }
}