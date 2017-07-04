@isTest
public with sharing class Test_AccountTacticalPlanElController 
{
	//commented by Dmitry Chernik
	/*private static testmethod void Test_AccountTacticalPlanElController()
	{
		TestInit.setYear(0);
		Account farmer = TestInit.createNewFarmer();
		insert farmer;
		
		//Create current Campaign
		Campaign currentCampaign = (Campaign)SmartFactory.createSObject('Campaign', new Map<String, Object>
		{
			'CountryRef__c' => farmer.CountryRef__c,
			'OwnerId' => farmer.OwnerId,
			//'DivisionRef__c' => currentDivision.Id,
			'StartDate' => Date.today(),
			'EndDate' => Date.today().addDays(1),
			'ArchiveDate__c' => Date.today().addDays(30),
			'YearV2__c' => Util.currentYear.Id
		});
		insert currentCampaign;
		
		Campaign previosCampaign = currentCampaign.clone(false, false);
		previosCampaign.YearV2__c = Util.lastYear.Id;
		insert previosCampaign;
	}*/
}