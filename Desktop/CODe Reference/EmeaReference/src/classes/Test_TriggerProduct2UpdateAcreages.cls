/*
	Check updating related Acreage records by update Product records.
*/
@isTest
private class Test_TriggerProduct2UpdateAcreages
{
	private static testMethod void testUpdateRelatedAcreages()
	{
		List<Account> accountList = createAccountList(2);
		Test.startTest();
		//Create requaire objects for test.
		Map<String, Object> aProductParams = new Map<String, Object>
		{
			'ProductVendor__c' => accountList[0].Id
			
		};
		Product2 aProduct = (Product2)SmartFactory.createSObject('Product2', aProductParams);
		insert aProduct;
		Map<String, Object> anAcreageParams = new Map<String, Object>
		{
			'AcrProductRef__c' => aProduct.Id,
			'AcrYearRef__c' => TestInit.years[0].Id,
			'RecordTypeId' => Util.recordType.get('Acreage__c:AcreagesPerProduct')
			
		};
		Acreage__c anAcreage = (Acreage__c)SmartFactory.createSObject('Acreage__c', anAcreageParams);
		insert anAcreage;
		
		//Update product and check that related Acreage record has been updated.
		aProduct.ProductVendor__c = accountList[1].Id;
		update aProduct;
		Acreage__c anUpdateAcreage = selectAcreageById(anAcreage.Id);
		System.assertEquals(accountList[1].Id, anUpdateAcreage.AcrProviderRef__c, 
				'Field AcrProviderRef__c should be equals ProductVendor__c field on related Product record.');
		Test.stopTest();
	}
	
	//
	private static List<Account> createAccountList(Integer theCountAccounts)
	{
		List<Account> anAccountList = new List<Account>();
		for (Integer i = 0; i < theCountAccounts; i++)
		{
			Account anAccount = TestInit.createNewDistributor();
			anAccountList.add(anAccount);
		}
		System.debug('***' + anAccountList);
		insert anAccountList;
		return anAccountList;
	}
	
	//Select Acreage records by Id.
	private static Acreage__c selectAcreageById(Id theId)
	{
		return [SELECT AcrProviderRef__c FROM Acreage__c WHERE Id = :theId];
	}
}