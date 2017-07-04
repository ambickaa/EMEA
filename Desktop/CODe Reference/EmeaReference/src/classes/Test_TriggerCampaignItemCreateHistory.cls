/*
	Check correct creating CampaignHistory records on after insert and after update.
*/
@isTest
private class Test_TriggerCampaignItemCreateHistory
{
	//Check correct creating CampaignHistory records.
	private static testMethod void testCorrectCreateCampaignHistory()
	{
		Test.startTest();
		Map<String, Object> aCLIParams = new Map<String, Object>
		{
			'RecordTypeId' => Util.recordType.get('CampaignLineItem__c:Sales'),
			'Forecast__c' => 0
		};
		CampaignLineItem__c aTestCLI = (CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', aCLIParams);
		insert aTestCLI;
		
		//Select CampaignHistory child record and check Changed__c field.
		List<CampaignLineItemHistory__c> aInsertCampaignHistory = getCampaignHistoryByParentId(aTestCLI.Id);
		//System.assert(aInsertCampaignHistory[0].ForecastChanged__c, 'ForecastChanged__c field isn\'t TRUE.');
		
		update aTestCLI;
		
		//Select CampaignHistory child record and check Changed__c field.
		List<CampaignLineItemHistory__c> anUpdateCampaignHistory = getCampaignHistoryByParentId(aTestCLI.Id);
		//System.assertEquals(1, anUpdateCampaignHistory.size(), 
		//		'We didn\'t change fields value. CampaignHistory shouldn\'t have beed created.');
		Test.stopTest();
	}
	
	//Select CampaignHistory by CampaignLineItem__c Id.
	private static List<CampaignLineItemHistory__c> getCampaignHistoryByParentId(Id theCampainItemId)
	{
		return [
			SELECT Forecast__c, ForecastChanged__c 
			FROM CampaignLineItemHistory__c 
			WHERE CampaignLineItem__c = :theCampainItemId];
	}
}