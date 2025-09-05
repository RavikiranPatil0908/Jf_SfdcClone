/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class UpdateOzontelAgentStatusTracker {

    @isTest
    static void testCallSaveEmailToPortalAPI() {
        // Prepare the input instance of FlowInputs
        UpdateOzontelAgentStatus.FlowInputs input = new UpdateOzontelAgentStatus.FlowInputs();
        input.ozontelId = 'test-agent-id';

        // Put it in a list as required by the Invocable method
        List<UpdateOzontelAgentStatus.FlowInputs> inputs = new List<UpdateOzontelAgentStatus.FlowInputs>{input};

        // Test the invocable method
        Test.startTest();
        UpdateOzontelAgentStatus.callAPIToUpdateStatus(inputs);
        Test.stopTest();
    }

    @isTest
    static void testCallWebService() {
        // Test the future method directly
        Test.startTest();
        UpdateOzontelAgentStatus.callWebService('test-agent-id');
        Test.stopTest();
    }


}