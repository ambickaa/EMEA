/*
	Check filling ProductCatalogEntryRef__c on before insert and before update.
*/
@isTest
private class Test_TriggerCampaignLineItemToPCE
{
	private static List<ProductCatalogEntry__c> productCatalogEntryList;
	private static Product2 product = TestInit.products[0];
	private static List<ProductCatalog__c> productCatalogList;
	private static Campaign campaign;
	
	static
	{
		insert product;
		
		Map<String, Object> aProductCatalogParams = new Map<String, Object>
		{
			'RecordTypeId' => Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog'),
			'CountryRef__c' => TestInit.countries[1].Id
		};
		productCatalogList = createProductCatalogList(4, aProductCatalogParams);
		productCatalogEntryList = createProductCatalogEntryList(Util.getIdSet(productCatalogList));
		Map<String, Object> aCampaignParams = new Map<String, Object>
		{
			'CountryRef__c' => TestInit.countries[1].Id,
			'SalesPCMRef__c' => productCatalogList[0].Id,
			'TrialPCMRef__c' => productCatalogList[1].Id,
			'CompetitorPCMRef__c' => productCatalogList[2].Id,
			'GiveAwayPCMRef__c' => productCatalogList[3].Id,
			'RecordTypeId' => Util.recordType.get('Campaign:Sales_camp')
		};
		campaign = (Campaign)SmartFactory.createSObject('Campaign', aCampaignParams);
		insert campaign;
	}
	
	//Check filling ProductCatalogEntryRef__c.
	private static testMethod void testFillProductCatalogEntryReference()
	{
		Test.startTest();
		Map<String, Object> aCampaignItemParams = new Map<String, Object>
		{
			'CampaignRef__c' => campaign.Id,
			'ProductRef__c' => product.Id
		};
		List<String> aRecordTypeCampaignItemList = new List<String>
		{
			'CampaignLineItem__c:GiveAway', 'CampaignLineItem__c:Sales', 'CampaignLineItem__c:Trial', 'CampaignLineItem__c:Trial'
		};
		List<CampaignLineItem__c> aCampaignItemList = createCampaignItemList(aCampaignItemParams, aRecordTypeCampaignItemList);
		insert aCampaignItemList;
		Map<Id, Id> aCampaignItemIdToProductCatalogIdMap = createCampaignItemToProductCatalogMap(aCampaignItemList);
		
		//Records with filled ProductCatalogEntryRef__c field.
		Map<Id, CampaignLineItem__c> aInsertCampaignItemMap = selectCampaignItemByIds(Util.getIdSet(aCampaignItemList));
		Map<Id, String> aProductCatalogEntryToIds = new Map<Id, String>();
		for (ProductCatalogEntry__c aProductCatalogEntry : productCatalogEntryList)
		{
			aProductCatalogEntryToIds.put(aProductCatalogEntry.Id, aProductCatalogEntry.ProductCatalogRef__c + 
					'-' + aProductCatalogEntry.ProductRef__c);
		}
		Map<Id, String> aCampaignItemLookupToIds = new Map<Id, String>();
		for (Id aCampaignLineItemId : aInsertCampaignItemMap.keySet())
		{
			aCampaignItemLookupToIds.put(aInsertCampaignItemMap.get(aCampaignLineItemId).ProductCatalogEntryRef__c, 
					aCampaignItemIdToProductCatalogIdMap.get(aCampaignLineItemId) + 
					'-' + aInsertCampaignItemMap.get(aCampaignLineItemId).ProductRef__c);
		}
		
		for (Id aCampaignItemLookup : aCampaignItemLookupToIds.keySet())
		{
			System.assertEquals(aCampaignItemLookupToIds.get(aCampaignItemLookup), aProductCatalogEntryToIds.get(aCampaignItemLookup),
					'This ProductCatalogEntry record = ' + aCampaignItemLookup + ' should be has the same lookup to ' + 
					' Product and ProductCatalog as related Campaign record');
		}
		Test.stopTest();
	}
	
	//Get CampaignLineItem__c records by Ids.
	private static Map<Id, CampaignLineItem__c> selectCampaignItemByIds(Set<Id> theIds)
	{
		return new Map<Id, CampaignLineItem__c>([
				SELECT ProductCatalogEntryRef__c, ProductRef__c 
				FROM CampaignLineItem__c 
				WHERE Id IN :theIds]);
	}
	
	//Create list of CampaignLineItem__c records and fill fields by theFieldParametersMap and list of RecordTypes.
	private static List<CampaignLineItem__c> createCampaignItemList(Map<String, Object> theFieldParametersMap, List<String> theRecordTypes)
	{
		List<CampaignLineItem__c> aCampaignItemList = new List<CampaignLineItem__c>();
		for (String aRecordTypeId : theRecordTypes)
		{
			theFieldParametersMap.put('RecordTypeId', Util.recordType.get(aRecordTypeId));
			aCampaignItemList.add((CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', theFieldParametersMap));
		}
		return aCampaignItemList;
	}
	
	//Create list of ProductCatalog records and fill fields by theProductCatalogParams.
	private static List<ProductCatalog__c> createProductCatalogList(Integer theCountProductCatalog, Map<String, Object> theProductCatalogParams)
	{
		List<ProductCatalog__c> aProductCatalogList = new List<ProductCatalog__c>();
		for (Integer i = 0; i < theCountProductCatalog; i++)
		{
			aProductCatalogList.add((ProductCatalog__c)SmartFactory.createSObject('ProductCatalog__c', theProductCatalogParams));
		}
		insert aProductCatalogList;
		return aProductCatalogList;
	}
	
	//Create list of ProductCatalogEntry records and fill ProductRef__c field by theProductCatalogIds.
	private static List<ProductCatalogEntry__c> createProductCatalogEntryList(Set<Id> theProductCatalogIds)
	{
		Map<String, Object> aProductCatalogEntryParams = new Map<String, Object>
		{
			'ProductRef__c' => product.Id
		};
		List<ProductCatalogEntry__c> aProductCatalogEntryList = new List<ProductCatalogEntry__c>();
		for (Id aProductCatalogId : theProductCatalogIds)
		{
			aProductCatalogEntryParams.put('ProductCatalogRef__c', aProductCatalogId);
			aProductCatalogEntryList.add((ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', aProductCatalogEntryParams));
		}
		insert aProductCatalogEntryList;
		return aProductCatalogEntryList;
	}
	
	//Create map with CampaignLineItem Id to related ProductCatalogId by RecordTypeId's CampaignLineUtem.
	private static Map<Id, Id> createCampaignItemToProductCatalogMap(List<CampaignLineItem__c> theCampaignLineItemList)
	{
		Map<Id, Id> aCampaignItemIdToProductCatalogIdMap = new Map<Id, Id>();
		for (CampaignLineItem__c aCampaignLineItem : theCampaignLineItemList)
		{
			if (aCampaignLineItem.RecordTypeId == Util.recordType.get('CampaignLineItem__c:GiveAway'))
			{
				aCampaignItemIdToProductCatalogIdMap.put(aCampaignLineItem.Id, campaign.GiveAwayPCMRef__c);
			} else if (aCampaignLineItem.RecordTypeId == Util.recordType.get('CampaignLineItem__c:Sales'))
			{
				aCampaignItemIdToProductCatalogIdMap.put(aCampaignLineItem.Id, campaign.SalesPCMRef__c);
			} else if (aCampaignLineItem.RecordTypeId == Util.recordType.get('CampaignLineItem__c:Trial'))
			{
				aCampaignItemIdToProductCatalogIdMap.put(aCampaignLineItem.Id, campaign.TrialPCMRef__c);
			}
		}
		
		return aCampaignItemIdToProductCatalogIdMap;
	}
}