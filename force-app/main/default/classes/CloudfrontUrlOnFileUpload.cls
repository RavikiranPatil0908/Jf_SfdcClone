/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-09-2024
 * @last modified by  : @BK
**/
public class CloudfrontUrlOnFileUpload {

    // Define properties based on the JSON structure
    public String id { get; set; }
    public List<Link> links { get; set; }
    public String message { get; set; }
    public Boolean error { get; set; }

    // Define the nested Link class
    public class Link {
        public String fileUrl { get; set; }
        public String awsUrl { get; set; }
    }

    // Static method to parse JSON and return an instance of CloudfrontUrlOnFileUpload
    public static CloudfrontUrlOnFileUpload parse(String json) {
        return (CloudfrontUrlOnFileUpload) System.JSON.deserialize(json, CloudfrontUrlOnFileUpload.class);
    }
}