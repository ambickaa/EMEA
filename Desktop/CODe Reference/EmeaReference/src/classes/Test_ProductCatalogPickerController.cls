/*
	@description Check selecting Products and creating ProductCatalogEntry on ProductCatalogPicker page.
	@copyright PARX
*/
@isTest
private class Test_ProductCatalogPickerController
{
	private static ProductCatalog__c testProductCatalog;
	private static Map<Id, Product2> aProductMap;
	
	/*
		@description Initialize required objects for test.
	*/
	private static void init()
	{
		TestInit.setYear(1);
		testProductCatalog = TestInit.productCatalogs.get('ProductCatalog__c:CompetitorProductCatalog');
		
		List<String> aProductNameList = new List<String> { 'Test Product1', 'Test Product2' };
		aProductMap = createProductMap(aProductNameList);
	}
	
	/*
		@description Test ProductPickers wich created as ProductCatalog.
	*/
	private static testMethod void testProductPickerAsProductcatalog()
	{
		init();
		
		Test.startTest();
		Apexpages.StandardController aStdController = new Apexpages.StandardController(testProductCatalog);
		ProductCatalogPickerController aController = new ProductCatalogPickerController(aStdController);
		checkSelectedProducts(aProductMap, aController.resultProducts);
		
		//Set filter parameters for search
		aController.searchProduct.Name = '*Product2';
		aController.doFilter();
		
		//Fill map of selected Products by filter parameters
		Map<Id, Product2> aSelectedRealProductMap = new Map<Id, Product2>();
		for (Id aProductId : aProductMap.keySet())
		{
			if (aProductMap.get(aProductId).Name.contains('Product2'))
			{
				aSelectedRealProductMap.put(aProductId, aProductMap.get(aProductId));
			}
		}
		checkSelectedProducts(aSelectedRealProductMap, aController.resultProducts);
		
		//Select Products for additing it to picker and check it.
		aController.resultProducts[0].checked = true;
		Id aSelectedProductId = aController.resultProducts[0].Id;
		aController.doAddProducts();
		List<ProductCatalogEntry__c> aInsertedPCEList = selectProductCatalogEntryByProductCatalog(testProductCatalog.Id);
		System.assertEquals(1, aInsertedPCEList.size(), 'Size of selected Products should be 1!');
		System.assertEquals(aSelectedProductId, aController.currentProducts[0].record.ProductRef__c, 
				  'Filled currentProductCatalogEntry record should be assigned to Product=' + aSelectedProductId);
		System.assertEquals(aSelectedProductId, aInsertedPCEList[0].ProductRef__c, 
				  'Created ProductCatalogEntry record should be assigned to Product=' + aSelectedProductId);
		
		//Delete ProductCatalogEntry records which has benn created by selected Products and redirect to ProductCatalog record.
		aController.currentProducts[0].checked = true;
		aController.doDeleteProducts();
		List<ProductCatalogEntry__c> aDeletedPCEList = selectProductCatalogEntryByProductCatalog(testProductCatalog.Id);
		System.assertEquals(0, aController.currentProducts.size(), 'Size of selected Products should be 0!');
		System.assertEquals(0, aDeletedPCEList.size(), 
				  'Created ProductCatalogEntry record should be assigned to Product=' + aSelectedProductId);
		
		aController.doCancel();
		Test.stopTest();
	}
	
	/*
		@description Create map of Products by parameters(field values).
	*/
	private static Map<Id, Product2> createProductMap(List<String> theProductName)
	{
		List<Product2> aProductList = new List<Product2>();
		Account aProvider = TestInit.createNewCompetitor();
		insert aProvider;
		for (String aName : theProductName)
		{
			Map<String, Object> aProductParam = new Map<String, Object>
			{
				'Name' => aName,
				'DivisionRef__c' => TestInit.divisions.get(Util.DIVISION_CORN).Id,
				'RecordTypeId' => Util.recordType.get('Product2:CompetitorProduct'),
				'ProductVendor__c' => aProvider.Id
			};
			Product2 aProduct = (Product2)SmartFactory.createSObject('Product2', aProductParam);
			aProductList.add(aProduct);
		}
		insert aProductList;
		return new Map<Id, Product2>([SELECT Name FROM Product2 WHERE Id IN :Util.getIdSet(aProductList)]);
	}
	
	/*
		@description Check selected Products by size and contains real Products.
	*/
	private static void checkSelectedProducts(Map<Id, Product2> theRealProducts, 
			  List<Product2x> theSelectProducts)
	{
		System.assertEquals(theRealProducts.keySet().size(), theSelectProducts.size(), 'ProductPicker selected more than need Product2 records!');
		for (Product2x aProduct : theSelectProducts)
		{
			System.assert(theRealProducts.containsKey(aProduct.Id), 'Product with Id=' + aProduct.Id + ' shouldn\'t be selected!');
		}
	}
	
	/*
		@description Select PRoductCatalogEntry records by related Product ids.
	*/
	private static List<ProductCatalogEntry__c> selectProductCatalogEntryByProductCatalog(Id theProductCatalogId)
	{
		return Database.query(new al.SoqlBuilder().selectx(new List<String>{'ProductRef__c'}).fromx('ProductCatalogEntry__c')
				  .wherex(new al.FieldCondition('ProductCatalogRef__c', theProductCatalogId)).toSoql());
	}
}