/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 24-01-2025
 * @last modified by  : @BK
**/
@isTest
public class OzontelResponsePayloadTracker {
    
    @isTest
    static void testParse() {
        // Define mock JSON response as input
        String json = '{'+
        '    "status": "success",'+
        '    "message": "success",'+
        '    "data": ['+
        '        {'+
        '            "AgentState": "ACW",'+
        '            "SkillName": "Academic_related_queries, Anunay, any_other_queries, DailyCallBacks, Examination_related_queries, General, Not_a_Student, ReRegistrationprocess",'+
        '            "Mode": "Blended",'+
        '            "PhoneNumber": "45435",'+ 
        '            "AgentId": "testtest",'+ 
        '            "AgentName": "Test Test"'+ 
        '        }'+
        '    ]'+
        '}';

        // Parse the JSON string into an OzontelResponsePayload object
        OzontelResponsePayload obj = OzontelResponsePayload.parse(json);

        // Assertions to verify the response
        System.assertNotEquals(obj, null, 'The OzontelResponsePayload object should not be null.');
        System.assertEquals(obj.status, 'success', 'The status should be "success".');
        System.assertEquals(obj.message, 'success', 'The message should be "success".');
        System.assertNotEquals(obj.data, null, 'The data field should not be null.');
        System.assertEquals(obj.data.size(), 1, 'There should be exactly one agent in the data.');

        // Check the agent's details in the data list
        OzontelResponsePayload.AgentData agent = obj.data[0];
        System.assertEquals(agent.AgentState, 'ACW', 'The agent state should be "ACW".');
        System.assertEquals(agent.SkillName, 'Academic_related_queries, Anunay, any_other_queries, DailyCallBacks, Examination_related_queries, General, Not_a_Student, ReRegistrationprocess', 'The skill name should match the expected value.');
        System.assertEquals(agent.Mode, 'Blended', 'The mode should be "Blended".');
        System.assertEquals(agent.PhoneNumber, '45435', 'The phone number should match the expected value.');
        System.assertEquals(agent.AgentId, 'testtest', 'The agent ID should match the expected value.');
        System.assertEquals(agent.AgentName, 'Test Test', 'The agent name should be "Test Test".');
    }

}