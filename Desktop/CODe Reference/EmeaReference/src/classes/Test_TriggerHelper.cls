/*
	@description Test calculate summary field on Parent record.
	@copyright PARX
*/
@isTest
private class Test_TriggerHelper
{
	private static final String PARENT_FIELD = 'ProductBagSize__c';
	private static final String CHILD_FIELD = 'Price__c';
	
	private static final List<Decimal> FIRST_PRICE_LIST = new List<Decimal> { 1, 3 };
	private static final Decimal FIRST_SUM_PRICE = 4;
	private static final List<Decimal> SECOND_PRICE_LIST = new List<Decimal> { 3, 7 };
	private static final Decimal SECOND_SUM_PRICE = 10;
	
	private static Product2 testProduct = TestInit.products[0];
	private static List<ProductCatalogEntry__c> testPCEList;
	
	/*
		@description Test calculate summary field on Parent record.
	*/
	private static testMethod void testCalculateFieldProduct()
	{
		insert testProduct;
		testPCEList = createPCEList(FIRST_PRICE_LIST);
		
		Test.startTest();
		Set<Id> aProductIds = new Set<Id> { testProduct.Id };
		Map<String, String> aFieldmapping = new Map<String, String> {PARENT_FIELD => CHILD_FIELD};
		TriggerHelper.summarizeFields('Product2', 'ProductCatalogEntries__r', aProductIds , aFieldmapping);
		
		Product2 anFirstUpdatedProduct = [SELECT ProductBagSize__c FROM Product2 WHERE Id = :testProduct.Id];
		System.assertEquals(FIRST_SUM_PRICE, anFirstUpdatedProduct.ProductBagSize__c, 'Summarize this field(' + PARENT_FIELD + ') filled incorrect!');
		
		delete [SELECT Id FROM ProductCatalogEntry__c WHERE ProductRef__c = :testProduct.Id];
		testPCEList = createPCEList(SECOND_PRICE_LIST);
		TriggerHelper.summarizeFields('Product2', 'ProductCatalogEntries__r', aProductIds , aFieldmapping);
		
		Product2 anSecondUpdatedProduct = [SELECT ProductBagSize__c FROM Product2 WHERE Id = :testProduct.Id];
		System.assertEquals(SECOND_SUM_PRICE, anSecondUpdatedProduct.ProductBagSize__c, 'Summarize this field(' + PARENT_FIELD + ') filled incorrect!');
		Test.stopTest();
	}
	
	/*
		@description Create and return list of ProductCatalogEntry records with parameters
	*/
	private static List<ProductCatalogEntry__c> createPCEList(List<Decimal> thePriceList)
	{
		Map<String, Object> aPCEParams = new Map<String, Object>
		{
			'ProductRef__c' => testProduct.Id
		};
		
		List<ProductCatalogEntry__c> aProductCatalogEntryList = new List<ProductCatalogEntry__c>();
		for (Decimal aPrice : thePriceList)
		{
			aPCEParams.put(CHILD_FIELD, aPrice);
			aProductCatalogEntryList.add((ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', aPCEParams));
		}
		
		insert aProductCatalogEntryList;
		return aProductCatalogEntryList;
	}
}