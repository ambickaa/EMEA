/*
	Check copying ProductGroupRef__c, ProductTypeRef__c, ProductVendor__c from related Product to Acreage.
*/
@isTest
private class Test_TriggerAcreageProductData
{
	private static final String RECORDTYPE_PRODUCT_GROUP = 'Product_Grouping__c:ProductGroup';
	private static final String RECORDTYPE_PRODUCT_TYPE = 'Product_Grouping__c:ProductType';
	
	private static Account anAccount = TestInit.createNewFarmer();
	private static Product_Grouping__c productGroupingGroupRef;
	private static Product_Grouping__c productGroupingTypeRef;
	private static Map<Id, Product2> productMap;
	
	static
	{
		Map<String, Object> aProductGroupParams = new Map<String, Object>
		{
			'RecordTypeId' => Util.recordType.get(RECORDTYPE_PRODUCT_GROUP)
		};
		productGroupingGroupRef = createProductGrouping(aProductGroupParams);
		
		aProductGroupParams.put('RecordtypeId', Util.recordType.get(RECORDTYPE_PRODUCT_TYPE));
		aProductGroupParams.put('ProductGroupRef__c', productGroupingGroupRef.Id);
		productGroupingTypeRef = createProductGrouping(aProductGroupParams);
		Account aProvider = TestInit.createNewCompetitor();
		insert aProvider;
		productMap = createProductMap(productGroupingGroupRef.Id, productGroupingTypeRef.Id, aProvider.Id);
	}
	
	//Test copying fields from Product to related Acreage.
	private static testMethod void testCopyFields()
	{
		Map<String, String> anAssociateField = new Map<String, String>
		{
			'AcrProductGroupRef__c' => 'ProductGroupRef__c',
			'AcrProductTypeRef__c' => 'ProductTypeRef__c',
			'AcrProviderRef__c' => 'ProductVendor__c'
		};
		
		Test.startTest();
		//Insert and check values after copy fields.
		List<Acreage__c> anAcreageList = createAcreageList(productMap.keySet());
		
		Map<Id, Acreage__c> anInsertAcreageMap = selectAcreageById(Util.getIdSet(anAcreageList));
		for (Acreage__c anAcreage : anAcreageList)
		{
			for (String aAcrField : anAssociateField.keySet())
			{
				System.assertEquals(anInsertAcreageMap.get(anAcreage.Id).get(aAcrField),
						productMap.get(anAcreage.AcrProductRef__c).get(anAssociateField.get(aAcrField)),
						'Acreage field ' + aAcrField + ' and Product field ' + 
						anAssociateField.get(aAcrField) + ' should be equals');
			}
		}
		Test.stopTest();
	}
	
	//Create Product_Grouping__c record with map of parameters.
	private static Product_Grouping__c createProductGrouping(Map<String, Object> theProductGroupParams)
	{
		Product_Grouping__c aProductGrouping = (Product_Grouping__c)SmartFactory.createSObject('Product_Grouping__c', theProductGroupParams);
		insert aProductGrouping;
		return aProductGrouping;
	}
	
	//Create list of Product records with parameters.
	private static Map<Id, Product2> createProductMap(Id theProdutGroupingRefId, Id theProdutTypeRefId, Id theAccountId)
	{
		Map<Id, Product2> aProductMap = new Map<Id, Product2>();
		insert TestInit.products;
		for (Product2 aProduct : TestInit.products)
		{
			aProduct.put('ProductGroupRef__c', theProdutGroupingRefId);
			aProduct.put('ProductTypeRef__c', theProdutTypeRefId);
			aProduct.put('ProductVendor__c', theAccountId);
			aProductMap.put(aProduct.Id, aProduct);
		}
		update aProductMap.values();
		return aProductMap;
	}
	
	//Create list of Acreage records with parameters.
	private static List<Acreage__c> createAcreageList(Set<Id> theProductIds)
	{
		Map<String, Object> anAcreageParams = new Map<String, Object>
		{
			'RecordTypeId' => Util.recordType.get('Acreage__c:AcreagesPerProduct'),
			'AcrYearRef__c' => TestInit.years[0].Id
		};
		List<Acreage__c> anAcreageList = new List<Acreage__c>();
		for (ID anProductId : theProductIds)
		{
			anAcreageParams.put('AcrProductRef__c', anProductId);
			anAcreageList.add((Acreage__c)SmartFactory.createSObject('Acreage__c', anAcreageParams));
		}
		insert anAcreageList;
		return anAcreageList;
	}
	
	//Select Acreage records by Ids.
	private static Map<Id, Acreage__c> selectAcreageById(Set<Id> theIds)
	{
		return new Map<Id, Acreage__c>([
				SELECT AcrProductGroupRef__c, AcrProductTypeRef__c, AcrProviderRef__c
				FROM Acreage__c 
				WHERE Id IN :theIds]);
	}
}