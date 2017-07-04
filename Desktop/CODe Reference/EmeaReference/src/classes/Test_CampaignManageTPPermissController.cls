/*
	
*/
@isTest
public class Test_CampaignManageTPPermissController 
{
	// Open page with Campaign
	private static testMethod void testCampaignPermissionPageWithCamapign()
	{
		// create Campaign 
		TestInit.campaign.StartDate = Date.today().addDays(-1);
		TestInit.campaign.EndDate = Date.today().addDays(1);
		
		insert TestInit.campaign;
		
		Test.startTest();
		// Open page
		CampaignManageTPPermissionsController controller = new CampaignManageTPPermissionsController();
		System.assert(controller.campaigns.size() == 1, 'There should be only one campaign');
		
		// Search For Division
		controller.searchCampaign.DivisionRef__c = controller.campaigns.get(0).DivisionRef__c;
		controller.buildQuery();
		System.assert(controller.campaigns.size() == 1, 'There should be only one campaign');
		
		// Activate Checkbox
		controller.campaigns.get(0).DisableForecastStatus__c = true;
		controller.disableSelectedCampaigns();
		System.assert(controller.campaigns.get(0).DisableForecastStatus__c, 'campaign.DisableForecastStatus__c should be true');
		
		
		// go Back to HomePage
		System.assert(controller.backToHome().getUrl()== '/home/home.jsp', 'Back URL is wrong.');
		
		Test.stopTest();
	}
	
	// Open page without Campaign
	private static testMethod void testCampaignPermissionPageWithoutCamapign()
	{
		Test.startTest();
			CampaignManageTPPermissionsController controller = new CampaignManageTPPermissionsController();
			System.assert(controller.campaigns.size() == 0, 'There shouldn\'t be a record');
			
			// go Back to HomePage
			System.assert(controller.backToHome().getUrl()== '/home/home.jsp', 'Back URL is wrong.');
		Test.stopTest();
	}
}