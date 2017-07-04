/*
	Check Account summary fields after update related Campaign record.
	trigger on after update.
*/
@isTest
private class Test_TriggerCampaignUpdateAccounts
{
	private static Integer FIELD_CAMPAIGN_STATUS_CODE_200 = 200;
	private static Integer FIELD_CAMPAIGN_STATUS_CODE_300 = 300;
	private static Integer FIELD_CLI_POG = 3;
	
	private static Campaign testCampaign;
	private static Account testAccount = TestInit.createNewFarmer();
	private static CampaignLineItem__c testCampaignLineItem;
	private static Account testMonsanto = TestInit.createNewDistributor();
	
	private static void init()
	{
		TestInit.setYear(0);
		insert testMonsanto;
		Division__c aDivision = TestInit.getDivision(Util.DIVISION_CORN);
		Map<String, Object> aCampaignFieldsMap = new Map<String, Object>
		{
			'DivisionRef__c' => aDivision.Id,
			'StartDate' => Date.today().addDays(-2), 'EndDate' => Date.today().addDays(1),
			'ArchiveDate__c' => Date.today().addDays(30)
		};
		testCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCampaignFieldsMap);
		insert testCampaign;
		insert testAccount;
		Product2 aProduct = TestInit.products.get(0);
		aProduct.ProductVendor__c = testMonsanto.Id;
		insert aProduct;
		Map<String, Object> aCampaignLineItemFieldsMap = new Map<String, Object>
		{
			'FarmRef__c' => testAccount.Id,
			'CampaignRef__c' => testCampaign.Id,
			'POG__c' => FIELD_CLI_POG,
			'Status__c' => 'Confirmed',
			'ProductRef__c' => aProduct.Id,
			'RecordTypeId' => Util.recordType.get('CampaignLineItem__c:Sales')
		};
		testCampaignLineItem = 
				(CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', aCampaignLineItemFieldsMap);
		insert testCampaignLineItem;
	}
	
	//Check Account summary fields after update related Campaign record
	private static testMethod void testAccountSummaryFields()
	{
		init();
		Map<String, Object> anAccountUpdatedFields = new Map<String, Object>
		{
			'CornTotalSalesCY__c' => testCampaignLineItem.POG__c, 'OSRTotalSalesCY__c' => 0,
			'CPTotalSalesCY__c' => 0, 'CornTotalSalesPY__c' => 0,
			'OSRTotalSalesPY__c' => 0, 'CPTotalSalesPY__c' => 0
		};
		Test.startTest();
		
		//Check StatusCode__c should be 200.
		checkAccountSummary(selectAccountById(testAccount.Id), anAccountUpdatedFields);
		
		//Check StatusCode__c should be 300.
		testCampaign.StartDate = Date.today().addDays(-1);
		testCampaign.EndDate = Date.today();
		anAccountUpdatedFields.put('CornTotalSalesCY__c', 0);
		anAccountUpdatedFields.put('CornTotalSalesPY__c', testCampaignLineItem.POG__c);
		update testCampaign;
		Test.stopTest();
		checkAccountSummary(selectAccountById(testAccount.Id), anAccountUpdatedFields);
	}
	
	//Select Account rcord by Id
	private static Account selectAccountById(Id theId)
	{
		return (Account)[
			SELECT CornTotalSalesCY__c, OSRTotalSalesCY__c, CPTotalSalesCY__c, CornTotalSalesPY__c,
				OSRTotalSalesPY__c, CPTotalSalesPY__c
			FROM Account
			WHERE Id = :theId];
	}
	
	//Check Account summary fields after changes fields on related Campaign.
	private static void checkAccountSummary(Account theAccount, Map<String, Object> theAccountUpdatedFields)
	{
		for (String aField : theAccountUpdatedFields.keySet())
		{
			System.assertEquals(theAccountUpdatedFields.get(aField), theAccount.get(aField), 
					'Account field '+ aField + ' has been filled incorrect!');
		}
	}
}