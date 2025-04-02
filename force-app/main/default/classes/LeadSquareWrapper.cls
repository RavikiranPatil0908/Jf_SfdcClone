public class LeadSquareWrapper {

    public class Before {
        public String ProspectID;
        public String ProspectAutoId;
        public String FirstName;
        public String LastName;
        public String EmailAddress;
        public Object Phone;
        public String Mobile;
        public Object Source;
        public Object SourceMedium;
        public Object SourceCampaign;
        public String ProspectStage;
        public String Score;
        public String EngagementScore;
        public String ProspectActivityName_Max;
        public String ProspectActivityDate_Max;
        public String OwnerId;
        public String ModifiedBy;
        public String ModifiedOn;
        public String LastModifiedOn;
        public String NotableEvent;
        public String NotableEventdate;
        public String QualityScore01;
        public Object ConversionReferrerURL;
        public Object SourceReferrerURL;
        public Object SourceIPAddress;
        public String LeadLastModifiedOn;
        public String OwnerIdEmailAddress;
        public String ModifiedByName;
        public String mx_Lead_Status;
        public String mx_Lead_Description;


    }

    public Before Before;
    public After After;

    public class After {
        public String ProspectID;
        public String ProspectAutoId;
        public String FirstName;
        public String LastName;
        public String EmailAddress;
        public Object Phone;
        public Object Mobile;
        public Object Source;
        public Object SourceMedium;
        public Object SourceCampaign;
        public String ProspectStage;
        public String Score;
        public String EngagementScore;
        public String ProspectActivityName_Max;
        public String ProspectActivityDate_Max;
        public String OwnerId;
        public String ModifiedBy;
        public String ModifiedOn;
        public String LastModifiedOn;
        public String NotableEvent ;
        public String NotableEventdate;
        public String QualityScore01;
        public Object ConversionReferrerURL;
        public Object SourceReferrerURL;
        public Object SourceIPAddress;
        public String LeadLastModifiedOn;
        public String OwnerIdEmailAddress;
        public String ModifiedByName;
        public String mx_Lead_Status;
        public String mx_Lead_Description;

    }

    
    public static LeadSquareWrapper parse(String json) {
        return (LeadSquareWrapper) System.JSON.deserialize(json, LeadSquareWrapper.class);
    }
}