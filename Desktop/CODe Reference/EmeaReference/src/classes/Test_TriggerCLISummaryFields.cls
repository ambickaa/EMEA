/**
 * @description Test changes on related Account and Campaign records after changed CampaignLineItem record 
 		on after insert and update and delete.
 * @copyright PARX
 */
@isTest
private class Test_TriggerCLISummaryFields
{
	private static Integer VALUE_MULTI_FIELD = 2;
	private static Integer FIELD_CAMPAIGN_STATUS_CODE_200 = 200;
	private static Integer FIELD_CAMPAIGN_STATUS_CODE_300 = 300;
	private static Integer FIELD_PRODUCT_BAG_SIZE = 3;
	private static Integer FIELD_CLI_QUANTITY = 1;
	private static Integer FIELD_CLI_PLANTINGDENSITY = 1;
	private static Integer FIELD_ACCOUNT_TOTAL = (FIELD_PRODUCT_BAG_SIZE * FIELD_CLI_QUANTITY) / FIELD_CLI_PLANTINGDENSITY;
	
	private static Account testFarm = TestInit.createNewFarmer();
	private static Account testMonsantoAcc = TestInit.createNewDistributor();
	private static Account testCompetitorAcc = TestInit.createNewCompetitor();
	private static List<Campaign> campaignList;
	private static List<Division__c> divisionList;
	private static Map<Id, Product2> productMap;
	
	private static Map<String, Object> BaseCLIParamMap;
	
	/*
		@description Initialize required records
	*/
	private static void init()
	{
		insert testFarm;
		insert testMonsantoAcc;
		insert testCompetitorAcc;
		
		BaseCLIParamMap = new Map<String, Object>
		{
			'FarmRef__c' => testFarm.Id, 'POG__c' => FIELD_CLI_QUANTITY, 
			'DistributorRef__c' => testMonsantoAcc.Id, 'PlantingDensity__c' => String.valueOf(FIELD_CLI_PLANTINGDENSITY),
			'RecordTypeId' => Util.recordType.get('CampaignLineItem__c:Sales'), 
			'Forecast__c' => FIELD_CLI_QUANTITY, 'Agreed__c' => FIELD_CLI_QUANTITY
		};
		
		List<String> aDivisionNames = new List<String>
		{
			Util.DIVISION_CORN, Util.DIVISION_CP, Util.DIVISION_OSR
		};
		divisionList = createDivisionList(aDivisionNames);
		productMap = createProductMap();
		
		List<Integer> aCampaignStatusCodeList = new List<Integer>
		{
			FIELD_CAMPAIGN_STATUS_CODE_200, FIELD_CAMPAIGN_STATUS_CODE_300
		};
		campaignList = createCampaignList(aCampaignStatusCodeList);
	}
	
	/*
		@description Check Account summary fields after changes fields on related CamapignlineItem.
	*/
	private static testmethod void testUpdateAccountSummaryFields()
	{
		init();
		
		Test.startTest();
		List<CampaignLineItem__c> aCLIList = createCLIList(testFarm.Id);
		Map<String, Integer> anAccountUpdatedFields = new Map<String, Integer>
		{
			'CornTotalSalesCY__c' => FIELD_CLI_QUANTITY * 2, 
			'CornTotalSalesPY__c' => FIELD_CLI_QUANTITY * 2,
			'OSRTotalSalesCY__c' => FIELD_CLI_QUANTITY * 2, 
			'OSRTotalSalesPY__c' => FIELD_CLI_QUANTITY * 2,
			'CPTotalSalesCY__c' => FIELD_CLI_QUANTITY * 2,
			'CPTotalSalesPY__c' => FIELD_CLI_QUANTITY * 2,
			'TotalCornSalesCompetitorCY__c' => FIELD_CLI_QUANTITY * 2,
			'TotalCornSalesCompetitorPY__c' => FIELD_CLI_QUANTITY * 2,
			'TotalOSRSalesCompetitorCY__c' => FIELD_CLI_QUANTITY * 2, 
			'TotalOSRSalesCompetitorPY__c' => FIELD_CLI_QUANTITY * 2,
			'TotalCornTPMonsantoCY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1, 
			'TotalCornTPMonsantoPY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1,
			'TotalCornTPCompetitorCY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1,
			'TotalCornTPCompetitorPY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1,
			'TotalOSRTPMonsantoCY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1,
			'TotalOSRTPMonsantoPY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1,
			'TotalOSRTPCompetitorCY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1,
			'TotalOSRTPCompetitorPY__c' => FIELD_ACCOUNT_TOTAL * VALUE_MULTI_FIELD * 1,
			'ForecastMTOCornSalesCY__c' => FIELD_CLI_QUANTITY * 6, 
			'AgreedMTOCornSalesCY__c' => FIELD_CLI_QUANTITY * 6
		};
		checkAccountSummary(selectAccountById(testFarm.Id), anAccountUpdatedFields);
		
		//Update Quantity__c, Forecast__c, Agreed__c fields by and check updates on Account fields.
		List<CampaignLineItem__c> aCLIUpdated = selectCLIByAccountId(testFarm.Id);
		for (CampaignLineItem__c aCLI : aCLIUpdated)
		{
			aCLI.POG__c = FIELD_CLI_QUANTITY * VALUE_MULTI_FIELD;
			aCLI.Forecast__c = FIELD_CLI_QUANTITY * VALUE_MULTI_FIELD;
			aCLI.Agreed__c = FIELD_CLI_QUANTITY * VALUE_MULTI_FIELD;
		}
		update aCLIUpdated;
		for (String anField : anAccountUpdatedFields.keySet())
		{
			anAccountUpdatedFields.put(anField, anAccountUpdatedFields.get(anField) * VALUE_MULTI_FIELD);
		}
		checkAccountSummary(selectAccountById(testFarm.Id), anAccountUpdatedFields);
		
		//Delete CampaignLineItem records and check update Account fields
		delete selectCLIByAccountId(testFarm.Id);
		for (String anField : anAccountUpdatedFields.keySet())
		{
			anAccountUpdatedFields.put(anField, 0);
		}
		checkAccountSummary(selectAccountById(testFarm.Id), anAccountUpdatedFields);
		Test.stopTest();
	}
	
	/*
		@description Check Campaign summary fields after changes fields on related CamapignlineItem.
	*/
	private static testmethod void testUpdateCampaignSummaryFields()
	{
		init();
		
		Test.startTest();
		List<CampaignLineItem__c> aCLIList = createCLIList(testFarm.Id);
		Map<Id, Id> aCampaignVendorMap = new Map<Id, Id>();
		for (CampaignLineItem__c aCLI : aCLIList)
		{
			aCampaignVendorMap.put(aCLI.CampaignRef__c, aCLI.ProductRef__r.ProductVendor__c);
		}
		Map<String, Integer> anCampaignUpdatedFields = new Map<String, Integer>
		{
			'CampaignRef__r.TotalAllocatedCharged__c' => FIELD_CLI_QUANTITY * 3,
			'CampaignRef__r.TotalForecastCharged__c' => FIELD_CLI_QUANTITY,
			'CampaignRef__r.TotalAgreedCharged__c' => FIELD_CLI_QUANTITY,
			'CampaignRef__r.TotalSalesCharged__c' => FIELD_CLI_QUANTITY,
			'CampaignRef__r.TotalAllocatedFOC__c' => FIELD_CLI_QUANTITY * 3,
			'CampaignRef__r.TotalForecastFOC__c' => FIELD_CLI_QUANTITY,
			'CampaignRef__r.TotalAgreedFOC__c' => FIELD_CLI_QUANTITY,
			'CampaignRef__r.TotalSalesFOC__c' => FIELD_CLI_QUANTITY
		};
		List<CampaignLineItem__c> aUpdatedCLIList = selectCLIByAccountId(testFarm.Id);
		checkCamapignSummary(aUpdatedCLIList, anCampaignUpdatedFields, aCampaignVendorMap);
		
		//Update Quantity in first CampaignLineItem record and delete second record for test.
		for (CampaignLineItem__c aCLI : aUpdatedCLIList)
		{
			aCLI.POG__c = FIELD_CLI_QUANTITY * VALUE_MULTI_FIELD;
			aCLI.Forecast__c = FIELD_CLI_QUANTITY * VALUE_MULTI_FIELD;
			aCLI.Agreed__c = FIELD_CLI_QUANTITY * VALUE_MULTI_FIELD;
		}
		update aUpdatedCLIList;
		
		for (String anField : anCampaignUpdatedFields.keySet())
		{
			anCampaignUpdatedFields.put(anField, anCampaignUpdatedFields.get(anField) * VALUE_MULTI_FIELD);
		}
		checkCamapignSummary(selectCLIByAccountId(testFarm.Id), anCampaignUpdatedFields, aCampaignVendorMap);
		Test.stopTest();
	}
	
	/*
		@description Create list of Division records with specific names
	*/
	private static List<Division__c> createDivisionList(List<String> theDivisionNames)
	{
		List<Division__c> aDivisionList = new List<Division__c>();
		for (String aDivisionName : theDivisionNames)
		{
			aDivisionList.add(TestInit.getDivision(aDivisionName));
		}
		return aDivisionList;
	}
	
	/*
		@description Create list of Product2 records.
	*/
	private static Map<Id, Product2> createProductMap()
	{
		Map<Id, Product2> anAccountProductMap = new Map<Id, Product2>();
		Product2 aProductMonsanto = TestInit.products[0];
		aProductMonsanto.ProductVendor__c = testMonsantoAcc.Id;
		aProductMonsanto.ProductBagSize__c = FIELD_PRODUCT_BAG_SIZE;
		insert aProductMonsanto;
		
		Product2 aProductCompetitor = TestInit.products[1];
		aProductCompetitor.ProductVendor__c = testCompetitorAcc.Id;
		aProductCompetitor.ProductBagSize__c = FIELD_PRODUCT_BAG_SIZE;
		insert aProductCompetitor;
		
		anAccountProductMap.put(aProductMonsanto.ProductVendor__c, aProductMonsanto);
		anAccountProductMap.put(aProductCompetitor.ProductVendor__c, aProductCompetitor);
		return anAccountProductMap;
	}
	
	/*
		@description Create list of Campaign records with parameters
	*/
	private static List<Campaign> createCampaignList(List<Integer> theCampaignStatusCodeList)
	{
		List<Campaign> aCampaignList = new List<Campaign>();
		Map<String, Object> aCampaignParams = new Map<String, Object>
		{
			'StartDate' => Date.today().addDays(-2), 'EndDate' => Date.today().addDays(1),
			'ArchiveDate__c' => Date.today().addDays(30)
		};
		for (Integer aCampaignStatusCode : theCampaignStatusCodeList)
		{
			if (aCampaignStatusCode == FIELD_CAMPAIGN_STATUS_CODE_200)
			{
				aCampaignParams.put('StartDate', Date.today().addDays(-2));
				aCampaignParams.put('EndDate', Date.today().addDays(1));
				aCampaignParams.put('ArchiveDate__c', Date.today().addDays(30));
			}
			else if (aCampaignStatusCode == FIELD_CAMPAIGN_STATUS_CODE_300)
			{
				aCampaignParams.put('StartDate', Date.today().addDays(-2));
				aCampaignParams.put('EndDate', Date.today());
			}
			
			for (Division__c aDivision : divisionList)
			{
				aCampaignParams.put('DivisionRef__c', aDivision.Id);
				aCampaignList.add((Campaign)SmartFactory.createSObject('Campaign', aCampaignParams));
			}
		}
		insert aCampaignList;
		return aCampaignList;
	}
	
	/*
		@description Create list of CampaignLineItem records with parameters.
	*/
	private static List<CampaignLineItem__c> createCLIList(Id theAccountId)
	{
		Map<String, Object> aCLIParam = new Map<String, Object>();
		aCLIParam.putAll(BaseCLIParamMap);
		List<String> aCLIStatusList = new List<String> {'Confirmed', 'Ordered / Discussed', 'Forecast'};
		List<String> aCLITypeList = new List<String> {'Charged', 'Free of charge'};
		List<CampaignLineItem__c> aCLIList = new List<CampaignLineItem__c>();
		for (Id aCampaignId : Util.getIdSet(campaignList))
		{
			aCLIParam.put('CampaignRef__c', aCampaignId);
			for (Product2 aProduct : productMap.values())
			{
				aCLIParam.put('ProductRef__c', aProduct.Id);
				for (String aStatus : aCLIStatusList)
				{
					aCLIParam.put('Status__c', aStatus);
					for (String aType : aCLITypeList)
					{
						aCLIParam.put('Type__c', aType);
						aCLIList.add((CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', aCLIParam));
					}
				}
			}
		}
		
		insert aCLIList;
		return aCLIList;
	}
	
	/*
		@description Select Account record by Id
	*/
	private static Account selectAccountById(Id theId)
	{
		Account anAccount = [
			SELECT CornTotalSalesCY__c, CornTotalSalesPY__c, OSRTotalSalesCY__c, OSRTotalSalesPY__c,
					CPTotalSalesCY__c, CPTotalSalesPY__c, TotalCornSalesCompetitorCY__c, TotalCornSalesCompetitorPY__c,
					TotalOSRSalesCompetitorCY__c, TotalOSRSalesCompetitorPY__c, TotalCornTPMonsantoCY__c,
					TotalCornTPCompetitorCY__c, TotalOSRTPMonsantoCY__c, TotalOSRTPCompetitorCY__c,
					TotalCornTPMonsantoPY__c, TotalCornTPCompetitorPY__c, TotalOSRTPMonsantoPY__c,
					TotalOSRTPCompetitorPY__c, ForecastMTOCornSalesCY__c, AgreedMTOCornSalesCY__c
			FROM Account
			WHERE Id = :theId];
		return anAccount;
	}
	
	/*
		@description Select CampaignLineItem record by Account Id.
	*/
	private static List<CampaignLineItem__c> selectCLIByAccountId(Id theAccountId)
	{
		return [
			SELECT Id
			FROM CampaignLineItem__c 
			WHERE FarmRef__c = :theAccountId];
	}
	
	/*
		@description Check Account summary fields after changes fields on related CampaignLineItem.
	*/
	private static void checkAccountSummary(Account theAccount, Map<String, Integer> theAccountUpdatedFields)
	{
		for (String aField : theAccountUpdatedFields.keySet())
		{
			System.assertEquals(theAccountUpdatedFields.get(aField), theAccount.get(aField), 
					'Account field '+ aField + ' has been filled incorrect!');
		}
	}
	
	/*
		@description Check Campaign summary fields after changes fields on related CampaignLineItem.
	*/
	private static void checkCamapignSummary(List<CampaignLineItem__c> theCampaignLineItemList, 
			  Map<String, Integer> theCampaignUpdatedFields, Map<Id, Id> theCamapignCompetitorMap)
	{
		for (CampaignLineItem__c aCLI : theCampaignLineItemList)
		{
			if (theCamapignCompetitorMap.get(aCLI.Id) == testCompetitorAcc.Id)
			{
				for (String aField : theCampaignUpdatedFields.keySet())
				{
					System.assertEquals(theCampaignUpdatedFields.get(aField), aCLI.get(aField), 
						  'CampaignLineItem__c field ' + aField + ' has been filled incorrect!');
				}
			}
		}
	}
}