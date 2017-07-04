/*
	Check filling Name of Campaign on before insert.
*/
@isTest
private class Test_TriggerCampaignAutoData
{
	private static List<Country__c> countryList = TestInit.countries;
	private static List<Year__c> yearList = TestInit.years;
	private static Division__c divisionObject = TestInit.getDivision('testDivision');
	
	//Check how filled Name of Campaign inserted record.
	private static testmethod void testCheckFillName()
	{
		List<String> aListOfNamesObjects = new List<String>
		{
			countryList[0].Name, Util.currentYear.Name, divisionObject.Name, UserInfo.getName()
		};
		Test.startTest();
		Map<String, Object> aCampaignParams = new Map<String, Object>
		{
			'RecordTypeId' => Util.recordType.get('Campaign:Sales_camp'), 
			'YearV2__c' => Util.currentYear.Id, 'CountryRef__c' => countryList[0].id, 
			'DivisionRef__c' => divisionObject.Id, 'OwnerId' => UserInfo.getUserId(),
			'StartDate' => Date.today().addDays(1)
		};
		
		Campaign aCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCampaignParams);
		insert aCampaign;
		
		//Check StatusCode__c should be 100
		Campaign anInsertCampaign = selectCamapignById(aCampaign.Id);
		checkCampaignFields(anInsertCampaign, aListOfNamesObjects, false, 100);
		
		//Check StatusCode__c should be 200
		anInsertCampaign.StartDate = Date.today().addDays(-1);
		anInsertCampaign.EndDate = Date.today().addDays(1);
		anInsertCampaign.ArchiveDate__c = Date.today().addDays(30);
		update anInsertCampaign;
		anInsertCampaign = selectCamapignById(aCampaign.Id);
		checkCampaignFields(anInsertCampaign, aListOfNamesObjects, true, 200);
		
		//Check StatusCode__c should be 300
		anInsertCampaign.EndDate = Date.today();
		anInsertCampaign.ArchiveDate__c = Date.today().addDays(1);
		update anInsertCampaign;
		anInsertCampaign = selectCamapignById(aCampaign.Id);
		checkCampaignFields(anInsertCampaign, aListOfNamesObjects, false, 300);
		
		//Check StatusCode__c should be 400
		anInsertCampaign.ArchiveDate__c = Date.today();
		update anInsertCampaign;
		anInsertCampaign = selectCamapignById(aCampaign.Id);
		checkCampaignFields(anInsertCampaign, aListOfNamesObjects, false, 400);
		Test.stopTest();
	}
	
	//Check Campaign name on contains name of related objects from theObjectNames list.
	private static void checkCampaignFields(Campaign theCampaign, List<String> theObjectNames, Boolean theIsActive, Integer theStatusCode)
	{
		System.assertEquals(theIsActive, theCampaign.IsActive, 'IsActive has been filled incorrect!');
		System.assertEquals(theStatusCode, theCampaign.StatusCode__c, 'StatusCode__c has been filled incorrect!');
		
		for (String aName : theObjectNames)
		{
			System.assert(theCampaign.Name.contains(aName), 'Wrong : object with Name=' + aName + ' don\'t has been added.');
		}
	}
	
	//
	private static Campaign selectCamapignById(Id theId)
	{
		return [SELECT Name, IsActive, StatusCode__c FROM Campaign WHERE Id = :theId];
	}
}