/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 23-04-2024
 * @last modified by  : @BK
**/
public class CreateLeadRestForCampaignWrapper {
  public String Keywords;
  public String AdvertCampaign;
  public String AdvertContent;
  public string AdvertType;
  public String AdvertSize;
  public String ReferringURL;
  public string IPAddress;
  public string TimeStamp;
  public string FullName;
  public string EmailAddress;
  public string ContactNumber;
  public string AgeGroup;
  public string City;
  public string DateOfBirth;
  public string Center;
  public string Program;
  public String ProgramType;
  public String AdvertAgency;
  public String Industry;
  public String SelectProgram;
  public String Title;
  public String Company;
  public String State;
  public String ZipCode;
  public String Google_Link;
  public String Source;
  public String OtherLeadSource;
  public String CountryCode;
  public String GACID;
  public String adgroup;
  public String target;
  public String physicallocation;
  public String interestlocation;
  public String network;
  public String devicemodel;
  public String ad;
  public String placement;
  public String adposition;
  public String PartnerLeadSource;
  public String adgroupId;
  public String campaignId;
  public String experimentId;
  public String FBCLID;
  public String keywordMatchType;
  public String siteLinks;
  public String leadFormID;

public static CreateLeadRestForCampaignWrapper parse(String json){
  System.debug('CreateLeadRestForCampaignWrapper --> ' +System.JSON.deserialize(json, CreateLeadRestForCampaignWrapper.class));
  return (CreateLeadRestForCampaignWrapper) System.JSON.deserialize(json, CreateLeadRestForCampaignWrapper.class);
}
}