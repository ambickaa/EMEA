@isTest
public class CampaignSalesBudgetControllerTest
{
    private static testmethod void testCampaignSalesBudgetController()
    {
        Campaign campaign = (Campaign) SmartFactory.createSObject('Campaign');
        campaign.TotalCampaignBudget__c = 15000;
        campaign.Name = 'Test Campaign';
        insert campaign;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
        CampaignSalesBudgetController controller =new CampaignSalesBudgetController(sc);
        
        controller.doCancel();
        controller.doSave();
        controller.doSendNotifications();
        Test.stopTest();
    }
}