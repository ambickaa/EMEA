/*
	@description Test Product filter by URL parameter 'mode'
	@copyright PARX
*/
@isTest
private class Test_ProductLookUpController
{
	private static Account testAccount = TestInit.createNewFarmer();
	private static List<ProductCatalogEntry__c> testProductCatalogEntryList;
	private static PageReference testPage = Page.ProductLookUp;
	private static List<Product2> testProductFakeList;
	private static List<Product2> testProductRightList;
	private static Campaign testCampaign;
	
	/*
		@description Initialize test parameters and records
	*/
	private static void init()
	{
		TestInit.setYear(1);
		insert testAccount;
		
		Map<String, Object> aCampaignParam = new Map<String, Object>
		{
			'OwnerId' => testAccount.OwnerId,
			'StartDate' => Date.today(),
			'EndDate' => Date.today().addDays(1),
			'ArchiveDate__c' => Date.today().addDays(30),
			'YearV2__c' => Util.currentYear.Id,
			'SalesPCMRef__c' => TestInit.productCatalogs.get('ProductCatalog__c:SalesProductCatalog').Id,
			'TrialPCMRef__c' => TestInit.productCatalogs.get('ProductCatalog__c:TrialsProductCatalog').Id,
			'GiveAwayPCMRef__c' => TestInit.productCatalogs.get('ProductCatalog__c:SalesProductCatalog').Id,
			'CountryRef__c' => TestInit.countries.get(0).Id,
			'DivisionRef__c' => TestInit.getDivision(Util.DIVISION_CORN).Id
		};
		testCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCampaignParam);
		insert testCampaign;
		
		List<Product2> aProductList = createProductList(3);
		testProductFakeList = new List<Product2> { aProductList[0] };
		testProductRightList = new List<Product2> { aProductList[1], aProductList[2] };
		
		testPage.getParameters().put('accountId', testAccount.Id);
		testPage.getParameters().put('mode', 'Sales');
		Test.setCurrentPageReference(testPage);

		testProductCatalogEntryList = new List<ProductCatalogEntry__c>();
		testProductCatalogEntryList.addAll(createProductCatalogEntryList('ProductCatalog__c:TrialsProductCatalog', testProductFakeList));
		testProductCatalogEntryList.addAll(createProductCatalogEntryList('ProductCatalog__c:SalesProductCatalog', testProductRightList));
	}
	
	/*
		@description Test Product filter by URL parameter 'mode'
	*/
	private static testMethod void testProductFilter()
	{
		init();
		
		Test.startTest();
		
		//'Sales' item
		ProductLookUpController aController = new ProductLookUpController();
		for (Product2x aProduct : aController.results)
		{
			System.assert(Util.getIdSet(testProductRightList).contains(aProduct.Id), 'This product ' + aProduct.Id + ' shouldn\'t selected.');
		}
		
		//'GiveAway' item
		testPage.getParameters().put('mode', 'GiveAway');
		Test.setCurrentPageReference(testPage);
		aController = new ProductLookUpController();
		
		//'Trial' item
		testPage.getParameters().put('mode', 'Trial');
		Test.setCurrentPageReference(testPage);
		aController = new ProductLookUpController();
		
		//'Case' item
		testPage.getParameters().put('mode', 'Case');
		Test.setCurrentPageReference(testPage);
		aController = new ProductLookUpController();
		
		//Without currentCampaign item
		testPage.getParameters().put('mode', '');
		Test.setCurrentPageReference(testPage);
		Util.currentCampaign = null;
		aController = new ProductLookUpController();
		
		aController.getIsMessage();
		Test.stopTest();
	}
	
	/*
		@description Create list of Product records by clone record from TestInit
	*/
	private static List<Product2> createProductList(Integer theCountProducts)
	{
		insert TestInit.products;
		return TestInit.products;
	}
	
	/*
		@description Create list of ProductCatalogEntry records by list of Product reocrds and record type
	*/
	private static List<ProductCatalogEntry__c> createProductCatalogEntryList(String thePCRecordType, List<Product2> theProductList)
	{
		List<ProductCatalogEntry__c> aProductCatalogEntryList = new List<ProductCatalogEntry__c>();
		for (Product2 aProduct : theProductList)
		{
			Map<String, Object> aPCEParams = new Map<String, Object>
			{
				'ProductCatalogRef__c' => TestInit.productCatalogs.get(thePCRecordType).Id,
				'ProductRef__c' => aProduct.Id
			};
			aProductCatalogEntryList.add((ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', aPCEParams));
		}
		
		insert aProductCatalogEntryList;
		return aProductCatalogEntryList;
	}
}