////// AccountTrialStandardController
@isTest
public with sharing class Test_AccountTrialStandardController_FR 
{
	private static testmethod void testAccountTrialStandardController()
	{
	TestInit.setYear(1);
    Division__c aDivision = TestInit.getDivision(Util.DIVISION_OSR);
    Account anAccount = TestInit.createNewFarmer();
    anAccount.CountryRef__c = TestInit.countries[2].Id;
    insert anAccount;
    Account anCompetitor = TestInit.createNewCompetitor();
    insert anCompetitor;
    
    Map<String, Object> aPreviousCampaignParam = new Map<String, Object>
    {
      'CountryRef__c' => anAccount.CountryRef__c,
      'OwnerId' => anAccount.OwnerId,
      'DivisionRef__c' => aDivision.Id,
      'StartDate' => Date.today(),
      'EndDate' => Date.today(),
      'ArchiveDate__c' => Date.today().addDays(30),
      'YearV2__c' => Util.lastYear.Id
    };
    Campaign aPreviousCampaign = (Campaign)SmartFactory.createSObject('Campaign', aPreviousCampaignParam);
    insert aPreviousCampaign;
    
	Map<String, Object> aCurrentCampaignParam = new Map<String, Object>
    {
      'CountryRef__c' => anAccount.CountryRef__c,
      'OwnerId' => anAccount.OwnerId,
      'DivisionRef__c' => aDivision.Id,
      'StartDate' => Date.today(),
      'EndDate' => Date.today().addDays(1),
      'ArchiveDate__c' => Date.today().addDays(30),
      'YearV2__c' => Util.currentYear.Id,
      'StatusCode__C' => 200
    };
    Campaign aCurrentCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCurrentCampaignParam);
    insert aCurrentCampaign;
	PageReference aPage = Page.AccountViewFR;
	aPage.getParameters().put('Id',anAccount.id);
	aPage.getParameters().put('division', aDivision.Id);
	Test.setCurrentPageReference(aPage);
	Test.startTest();
	System.debug('imprime el Country: '+TestInit.countries[2].DE_EnableAccountSharing__C);
	AccountTrialStandardController atsc= new AccountTrialStandardController();
	
	
			Campaign resultCampaign = atsc.getCurrentCampaign();
			System.debug('result Campaign:'+ resultCampaign);
			System.assertEquals(aCurrentCampaign.Id, resultCampaign.Id);
				
		
		Test.stopTest();
}
}