@isTest(SeeAllData=true)
public class QuickLeadControllerTracker
{
	public static Lead objLead;

	static testMethod void testMethod1()
	{
		objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
		ApexPages.StandardController sc = new ApexPages.StandardController(objLead);
		QuickLeadController QuickLead = new QuickLeadController(sc);

		QuickLead.getProgramsList();
		QuickLead.getCounselorList();
		
	}
}