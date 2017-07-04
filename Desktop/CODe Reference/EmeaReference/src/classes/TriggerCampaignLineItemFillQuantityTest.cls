@isTest
private class TriggerCampaignLineItemFillQuantityTest {
	
	private static final Decimal FORECAST_VALUE = 30;
	private static final Decimal AGREED_VALUE = 30;
	private static final Decimal CONFIRMED_VALUE = 30;
	
	/**
	* Tests that quantity value is set correctly.
	*/
	static testMethod void mainTest()
	{
		Test.startTest();
		//Create new CLI with forecast status.
		Map<String, Object> aCLIParams = new Map<String, Object>{'RecordTypeId' => Util.recordType.get('CampaignLineItem__c:Sales'),
				  'POG__c' => CONFIRMED_VALUE, 'Forecast__c' => FORECAST_VALUE, 'Agreed__c' => AGREED_VALUE, 'Status__c' => 'Forecast'};
		CampaignLineItem__c aTestCLI = (CampaignLineItem__c) SmartFactory.createSObject('CampaignLineItem__c', aCLIParams);
		insert aTestCLI;
		System.assertEquals(FORECAST_VALUE, getCLIQuantity(aTestCLI.Id));
		
		//Check quantity on agreed status.
		aTestCLI.Status__c = 'Ordered / Discussed';
		update aTestCLI;
		System.assertEquals(AGREED_VALUE, getCLIQuantity(aTestCLI.Id));
		
		//Check quantity on confirmed status.
		aTestCLI.Status__c = 'Confirmed';
		update aTestCLI;
		System.assertEquals(CONFIRMED_VALUE, getCLIQuantity(aTestCLI.Id));
		Test.stopTest();
	}
	
	/**
	* Gets current value of quantity field for the selected CLI.
	*/
	static Decimal getCLIQuantity(Id theCLIId)
	{
		String aSOQL = new al.SoqlBuilder().selectx(new List<String>{'Id', 'Quantity__c'})
				  .fromx('CampaignLineItem__c')
				  .wherex(new al.FieldCondition('Id', theCLIId)).toSOQL();
		List<sObject> aResult = Database.query(aSOQL);
		return (aResult == null || aResult.size() == 0) ? null : (Decimal)aResult[0].get('Quantity__c');
	}
}