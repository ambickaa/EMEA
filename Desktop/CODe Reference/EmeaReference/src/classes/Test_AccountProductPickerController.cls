/*
	@description Check selecting Products and creating CampaignLineItem on AccountproductPicker page.
	@copyright PARX
*/
@isTest
private class Test_AccountProductPickerController
{
	private static Account testAccount = TestInit.createNewFarmer();
	private static Campaign testCampaign = TestInit.campaign;
	private static Map<String, ProductCatalog__c> testProductCatalogMap;
	private static PageReference accountProductPickerPage = Page.AccountProductPicker;
	private static Map<String, Object> baseCampaignParam;
	private static Map<Id, Product2> aProductMap;
	
	/*
		@description Initialize URL parameters and required objects for test.
	*/
	private static void init()
	{
		TestInit.setYear(1);
		insert testAccount;
		accountProductPickerPage.getParameters().put('id', testAccount.Id);
		accountProductPickerPage.getParameters().put('jumperTag', 'tacticalPlanList');
		accountProductPickerPage.getParameters().put('mode', 'tacticalEdit');
		accountProductPickerPage.getParameters().put('division', testCampaign.DivisionRef__c);
		
		//Map which contains key is RecordType ans value ProductCatalog__c
		testProductCatalogMap = TestInit.productCatalogs;
		
		baseCampaignParam = new Map<String, Object>
		{
			'CountryRef__c' => testAccount.CountryRef__c,
			'OwnerId' => testAccount.OwnerId,
			'DivisionRef__c' => accountProductPickerPage.getParameters().get('division'),
			'StartDate' => Date.today(),
			'EndDate' => Date.today().addDays(1),
			'ArchiveDate__c' => Date.today().addDays(10)
		};
		List<String> aProductNameList = new List<string>
		{
			'Test Product1', 'Test Product2', 'Product3'
		};
		aProductMap = createProductMap(aProductNameList);
		Test.setCurrentPage(accountProductPickerPage);
	}
	
	/*
		@description Test ProductPickers wich created as tactical plans.
	*/
	private static testMethod void testProductPickerAsTacticalPlan()
	{
		init();
		Map<String, Object> aCampaignParam = new Map<String, Object>
		{
			'SalesPCMRef__c' => testProductCatalogMap.get('ProductCatalog__c:SalesProductCatalog').Id,
			'CompetitorPCMRef__c' => null,
			'TrialPCMRef__c' => null,
			'GiveAwayPCMRef__c' => null
		};
		createCampaignByParam(aCampaignParam);
		createProductCatalogEntryList(aProductMap, 'ProductCatalog__c:SalesProductCatalog');
		
		Test.startTest();
		Apexpages.StandardController aStdController = new Apexpages.StandardController(testAccount);
		AccountProductPickerController aController = new AccountProductPickerController(aStdController);
		checkSelectedProducts(aProductMap, aController.picker.currentResult);
		
		//Set filter parameters for search
		aController.picker.searchProduct.Name = '*Test*';
		aController.picker.doFilter();
		
		//Fill map of selected Products by filter parameters
		Map<Id, Product2> aSelectedRealProductMap = new Map<Id, Product2>();
		for (Id aProductId : aProductMap.keySet())
		{
			if (aProductMap.get(aProductId).Name.contains('Test'))
			{
				aSelectedRealProductMap.put(aProductId, aProductMap.get(aProductId));
			}
		}
		checkSelectedProducts(aSelectedRealProductMap, aController.picker.currentResult);
		
		//Select Products for additing it to picker and check it.
		aController.picker.currentResult[0].checked = true;
		Id aSelectedProductId = aController.picker.currentResult[0].Id;
		aController.picker.doAddSelected();
		System.assertEquals(1, aController.picker.selectedObjects.size(), 'Size of selected Products should be 1!');
		System.assertEquals(aSelectedProductId, aController.picker.selectedObjects[0].Id, 
				  'Filled wrapper product record should be assigned to Product=' + aSelectedProductId);
		System.assertEquals(aSelectedProductId, aController.picker.selectedProducts[0].Id, 
				  'Filled Product record should be assigned to Product=' + aSelectedProductId);
		
		//Create CampaignLineItems by selected ProductPickers.
		aController.doSave();
		Set<Id> aSelectedProductIdSet = new Set<Id> { aSelectedProductId };
		List<CampaignLineItem__c> aCampaignLineItemList = selectCreatedCLI(aSelectedProductIdSet);
		checkCreatedCampaignLineItems(aSelectedProductIdSet, aCampaignLineItemList);
		Test.stopTest();
	}
	
	/*
		@description Test ProductPickers wich created as Trials.
	*/
	private static testMethod void testProductPickerAsTrials()
	{
		init();
		accountProductPickerPage.getParameters().put('jumperTag', 'AccountTrialList');
		accountProductPickerPage.getParameters().put('mode', 'trailEdit');
		
		Map<String, Object> aCampaignParam = new Map<String, Object>
		{
			'SalesPCMRef__c' => null,
			'CompetitorPCMRef__c' => testProductCatalogMap.get('ProductCatalog__c:CompetitorProductCatalog').Id,
			'TrialPCMRef__c' => testProductCatalogMap.get('ProductCatalog__c:TrialsProductCatalog').Id,
			'GiveAwayPCMRef__c' => null
		};
		createCampaignByParam(aCampaignParam);
		createProductCatalogEntryList(aProductMap, 'ProductCatalog__c:TrialsProductCatalog');
		
		Test.startTest();
		Apexpages.StandardController aStdController = new Apexpages.StandardController(testAccount);
		AccountProductPickerController aController = new AccountProductPickerController(aStdController);
		checkSelectedProducts(aProductMap, aController.picker.currentResult);
		
		//Set filter parameters for search
		aController.picker.searchProduct.Name = 'Product3';
		aController.picker.doFilter();
		
		//Fill map of selected Products by filter parameters
		Map<Id, Product2> aSelectedRealProductMap = new Map<Id, Product2>();
		for (Id aProductId : aProductMap.keySet())
		{
			if (aProductMap.get(aProductId).Name.contains('Product3'))
			{
				aSelectedRealProductMap.put(aProductId, aProductMap.get(aProductId));
			}
		}
		checkSelectedProducts(aSelectedRealProductMap, aController.picker.currentResult);
		
		//Select Products for additing it to picker and check it.
		aController.picker.currentResult[0].checked = true;
		Id aSelectedProductId = aController.picker.currentResult[0].Id;
		aController.picker.doAddSelected();
		System.assertEquals(1, aController.picker.selectedObjects.size(), 'Size of selected Products should be 1!');
		System.assertEquals(aSelectedProductId, aController.picker.selectedObjects[0].Id, 
				  'Filled wrapper product record should be assigned to Product=' + aSelectedProductId);
		System.assertEquals(aSelectedProductId, aController.picker.selectedProducts[0].Id, 
				  'Filled Product record should be assigned to Product=' + aSelectedProductId);
		
		//Create CampaignLineItems by selected ProductPickers.
		aController.doSave();
		Set<Id> aSelectedProductIdSet = new Set<Id> { aSelectedProductId };
		List<CampaignLineItem__c> aCampaignLineItemList = selectCreatedCLI(aSelectedProductIdSet);
		checkCreatedCampaignLineItems(aSelectedProductIdSet, aCampaignLineItemList);
		Test.stopTest();
	}
	
	/*
		@description Test ProductPickers wich created as GiveAways.
	*/
	private static testMethod void testProductPickerAsGiveAway()
	{
		init();
		accountProductPickerPage.getParameters().put('jumperTag', 'AccountGiveAways');
		accountProductPickerPage.getParameters().put('mode', 'merchandiseManagementEdit');
		
		Map<String, Object> aCampaignParam = new Map<String, Object>
		{
			'SalesPCMRef__c' => null,
			'CompetitorPCMRef__c' => null,
			'TrialPCMRef__c' => null,
			'GiveAwayPCMRef__c' => testProductCatalogMap.get('ProductCatalog__c:MarketingProductCatalog').Id
		};
		createCampaignByParam(aCampaignParam);
		createProductCatalogEntryList(aProductMap, 'ProductCatalog__c:MarketingProductCatalog');
		
		Test.startTest();
		Apexpages.StandardController aStdController = new Apexpages.StandardController(testAccount);
		AccountProductPickerController aController = new AccountProductPickerController(aStdController);
		checkSelectedProducts(aProductMap, aController.picker.currentResult);
		
		//Set filter parameters for search
		aController.picker.searchProduct.Name = '*Test*';
		aController.picker.doFilter();
		
		//Fill map of selected Products by filter parameters
		Map<Id, Product2> aSelectedRealProductMap = new Map<Id, Product2>();
		for (Id aProductId : aProductMap.keySet())
		{
			if (aProductMap.get(aProductId).Name.contains('Test'))
			{
				aSelectedRealProductMap.put(aProductId, aProductMap.get(aProductId));
			}
		}
		checkSelectedProducts(aSelectedRealProductMap, aController.picker.currentResult);
		
		//Select Products for additing it to picker and check it.
		aController.picker.currentResult[1].checked = true;
		Id aSelectedProductId = aController.picker.currentResult[1].Id;
		aController.picker.doAddSelected();
		System.assertEquals(1, aController.picker.selectedObjects.size(), 'Size of selected Products should be 1!');
		System.assertEquals(aSelectedProductId, aController.picker.selectedObjects[0].Id, 
				  'Filled wrapper product record should be assigned to Product=' + aSelectedProductId);
		System.assertEquals(aSelectedProductId, aController.picker.selectedProducts[0].Id, 
				  'Filled Product record should be assigned to Product=' + aSelectedProductId);
		
		//Create CampaignLineItems by selected ProductPickers.
		aController.picker.selectedObjects[0].checked = true;
		aController.picker.doDeleteSelected();
		System.assertEquals(0, aController.picker.selectedObjects.size(), 'Count of selected Products should be 0!');
		aController.doCancel();
		Test.stopTest();
	}
	
	/*
		@description Create Camapign record by additional parameters.
	*/
	private static Campaign createCampaignByParam(Map<String, Object> theCampaignParam)
	{
		Campaign aCampaign;
		theCampaignParam.putAll(baseCampaignParam);
		aCampaign = (Campaign)SmartFactory.createSObject('Campaign', theCampaignParam);
		insert aCampaign;
		return aCampaign;
	}
	
	/*
		@description Create map of Products by parameters(field values).
	*/
	private static Map<Id, Product2> createProductMap(List<String> theProductName)
	{
		List<Product2> aProductList = new List<Product2>();
		Account aDist = TestInit.createNewCompetitor();
		insert aDist;
		for (String aName : theProductName)
		{
			Map<String, Object> aProductParam = new Map<String, Object>
			{
				'Name' => aName,
				'ProductVendor__c' => aDist.Id
			};
			Product2 aProduct = (Product2)SmartFactory.createSObject('Product2', aProductParam);
			aProductList.add(aProduct);
		}
		insert aProductList;
		return new Map<Id, Product2>([SELECT Name FROM Product2 WHERE Id IN :Util.getIdSet(aProductList)]);
	}
	
	/*
		@description Create list of ProductCatalogEntry records by Products and RecordType of ProductCatalog__c
	*/
	private static void createProductCatalogEntryList(Map<Id, Product2> theProductMap, 
			  String theRecordTypeProdCatalog)
	{
		List<ProductCatalogEntry__c> aProductCatalogEntryList = new List<ProductCatalogEntry__c>();
		for (Id aProductId : theProductMap.keySet())
		{
			Map<String, Object> aProductCatalogEntryParam = new Map<String, Object>
			{
				'ProductRef__c' => aProductId,
				'ProductCatalogRef__c' => testProductCatalogMap.get(theRecordTypeProdCatalog).Id
			};
			aProductCatalogEntryList.add((ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', aProductCatalogEntryParam));
		}
		insert aProductCatalogEntryList;
	}
	
	/*
		@description Check selected Products by size and contains real Products.
	*/
	private static void checkSelectedProducts(Map<Id, Product2> theRealProducts, List<Product2x> theSelectProducts)
	{
		System.assertEquals(theRealProducts.keySet().size(), theSelectProducts.size(), 'ProductPicker selected more than need Product2 records!');
		for (Product2x aProduct : theSelectProducts)
		{
			System.assert(theRealProducts.containsKey(aProduct.Id), 'Product with Id=' + aProduct.Id + ' shouldn\'t be selected!');
		}
	}
	
	/*
		@description Check created CamapignLineItems by selected Products.
	*/
	private static void checkCreatedCampaignLineItems(Set<Id> theSelectedProducts, List<CampaignLineItem__c> theCLIList)
	{
		for (CampaignLineItem__c aCLI : theCLIList)
		{
			System.assert(theSelectedProducts.contains(aCLI.ProductRef__c), 
					  'CampaignLineItem__c with Id=' + aCLI.Id + ' was created without selected Product!');
		}
	}
	
	/*
		@description Select CamapignLineItem which created by current Account, Campaign and selected Products.
	*/
	private static List<CampaignLineItem__c> selectCreatedCLI(Set<Id> theSelectedProductIds)
	{
		return [
				SELECT ProductRef__c 
				FROM CampaignLineItem__c 
				WHERE RecordTypeId = :Util.recordType.get('CampaignLineItem__c:GiveAway') 
				  AND FarmRef__c = :testAccount.Id
				  AND CampaignRef__c = :Util.currentCampaign.id
				  AND ProductRef__c IN :theSelectedProductIds];
	}
}