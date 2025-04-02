/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-09-2024
 * @last modified by  : @BK
**/
@isTest
public class CloudfrontUrlOnFileUploadTracker {

    @isTest
    static void testParse() {
        // Setup: Create a sample JSON string that matches the CloudfrontUrlOnFileUpload structure
        String jsonResponse = '{' +
            '"id": "TestUser", ' +
            '"links": [{' +
                '"fileUrl": "https://example.com/file1", ' +
                '"awsUrl": "https://aws.example.com/file1"' +
            '}, {' +
                '"fileUrl": "https://example.com/file2", ' +
                '"awsUrl": "https://aws.example.com/file2"' +
            '}], ' +
            '"message": "Operation successful", ' +
            '"error": false' +
        '}';

        // Act: Call the parse method
        CloudfrontUrlOnFileUpload result = CloudfrontUrlOnFileUpload.parse(jsonResponse);

        // Assert: Verify that the result matches the expected values
        System.assertNotEquals(null, result, 'The result should not be null');

        // Assert the top-level properties
        System.assertEquals('TestUser', result.id, 'The id should match the expected value');
        System.assertEquals('Operation successful', result.message, 'The message should match the expected value');
        System.assertEquals(false, result.error, 'The error flag should match the expected value');

        // Assert the links list
        System.assertNotEquals(null, result.links, 'The links list should not be null');
        System.assertEquals(2, result.links.size(), 'The links list should contain two items');

        // Assert the properties of each link
        CloudfrontUrlOnFileUpload.Link link1 = result.links[0];
        System.assertEquals('https://example.com/file1', link1.fileUrl, 'The fileUrl for the first link should match');
        System.assertEquals('https://aws.example.com/file1', link1.awsUrl, 'The awsUrl for the first link should match');

        CloudfrontUrlOnFileUpload.Link link2 = result.links[1];
        System.assertEquals('https://example.com/file2', link2.fileUrl, 'The fileUrl for the second link should match');
        System.assertEquals('https://aws.example.com/file2', link2.awsUrl, 'The awsUrl for the second link should match');
    }
}