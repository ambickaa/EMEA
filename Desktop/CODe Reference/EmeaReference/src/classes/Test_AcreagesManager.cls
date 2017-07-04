/*
 * Check created Acreages by CampaignLineItem's fields
 */
@isTest
private class Test_AcreagesManager
{
	private static String VALUE_PLAINTING_DESTINY = '0.5';
	private static Integer VALUE_QUANTITY = 10;
	
	private static Account testAccount = TestInit.createNewFarmer();
	private static List<Product2> testProductList;
	private static Campaign previousCampaign;
	private static Campaign currentCampaign;
	private static List<CampaignLineItem__c> campaignLineItemList;
	private static Map<Id, Acreage__c> acreageMap;
	
	private static Map<String, Object> aBaseCLIParams;
	private static Map<String, Object> aBaseAcreageParams;
	
	static
	{
		TestInit.setYear(0);
		insert testAccount;
		ApexPages.currentPage().getParameters().put('id', testAccount.Id);
		Division__c aDivision = TestInit.divisions.values()[0];
		ApexPages.currentPage().getParameters().put('division', aDivision.Id);
		testProductList = createProductList(5);
		Date todayDate = Date.today();
		
		aBaseCLIParams = new Map<String, Object>
		{
			'POG__c' => VALUE_QUANTITY, 
			'Status__c' => 'Confirmed',
			'PlantingDensity__c' => VALUE_PLAINTING_DESTINY, 
			'Quantity__c' => VALUE_QUANTITY, 
			'FarmRef__c' => testAccount.Id, 
			'RecordTypeId' => Util.recordType.get('CampaignLineItem__c:Sales')
		};
		aBaseAcreageParams = new Map<String, Object>
		{
			'RecordTypeId' => Util.recordType.get('Acreage__c:' + AcreageFactory.ACREAGE_RT_PRODUCT),
			'AcrFarmRef__c' => testAccount.Id,
			'AcrTotalAcreages__c' => Decimal.valueOf(VALUE_PLAINTING_DESTINY) * VALUE_QUANTITY
		};
		
		//Create previous Campaign
		previousCampaign = (Campaign)SmartFactory.createSObject('Campaign', 
			new Map<String, Object>
			{
				'CountryRef__c' => testAccount.CountryRef__c,
				'OwnerId' => testAccount.OwnerId,
				'DivisionRef__c' => aDivision.Id,
				'StartDate' => Date.newInstance(todayDate.year() - 1, 1, 1),
				'EndDate' => Date.newInstance(todayDate.year() - 1, 1, 2),
				'ArchiveDate__c' => Date.newInstance(todayDate.year() - 1, 1, 30),
				'YearV2__c' => Util.lastYear.Id
			}
		);
		
		//Create current Campaign
		currentCampaign = (Campaign)SmartFactory.createSObject('Campaign', 
			new Map<String, Object>
			{
				'CountryRef__c' => testAccount.CountryRef__c,
				'OwnerId' => testAccount.OwnerId,
				'DivisionRef__c' => aDivision.Id,
				'StartDate' => todayDate,
				'EndDate' => todayDate.addDays(1),
				'ArchiveDate__c' => todayDate.addDays(30),
				'YearV2__c' => Util.currentYear.Id
			});
		insert new List<Campaign> {previousCampaign, currentCampaign};
		
		//Create CampaignLineItems
		List<Map<String, Object>> campaignLineItemParams = new List<Map<String, Object>>
		{
			new Map<String, Object> {'ProductRef__c'=> testProductList[0].Id, 'CampaignRef__c' => currentCampaign.Id, 'POG__c' => VALUE_QUANTITY * 3},
			new Map<String, Object> {'ProductRef__c'=> testProductList[1].Id, 'CampaignRef__c' => currentCampaign.Id},
			new Map<String, Object> {'ProductRef__c'=> testProductList[2].Id, 'CampaignRef__c' => currentCampaign.Id},
			new Map<String, Object> {'ProductRef__c'=> testProductList[4].Id, 'CampaignRef__c' => currentCampaign.Id, 'POG__c' => VALUE_QUANTITY * 3},
			new Map<String, Object> {'ProductRef__c'=> testProductList[3].Id, 'CampaignRef__c' => previousCampaign.Id},
			new Map<String, Object> {'ProductRef__c'=> testProductList[2].Id, 'CampaignRef__c' => previousCampaign.Id}
		};
		campaignLineItemList = createCLIList(campaignLineItemParams);
		//Create Acreages
		List<Map<String, Object>> anAcreageParamsList = new List<Map<String, Object>>
		{
			new Map<String, Object> {'AcrYearRef__c' => Util.lastYear.Id, 'AcrProductRef__c' => testProductList[0].Id},
			new Map<String, Object> {'AcrYearRef__c' => Util.lastYear.Id, 'AcrProductRef__c' => testProductList[1].Id},
			new Map<String, Object> {'AcrYearRef__c' => Util.currentYear.Id, 'AcrProductRef__c' => testProductList[1].Id},
			new Map<String, Object> {'AcrYearRef__c' => Util.currentYear.Id, 'AcrProductRef__c' => testProductList[2].Id}
		};
		acreageMap = createAcreageMap(anAcreageParamsList);
	}
	
	//Check created Acreages by CamapignLineItem information.
	private static testmethod void testGenerateAcreages()
	{
		//
		Map<Id, Id> aProductPrevAcreagesMap = new Map<Id, Id>();
		for (Id anAcreageId : acreageMap.keySet())
		{
			Acreage__c anAcreage = acreageMap.get(anAcreageId);
			if (anAcreage.AcrYearRef__c == Util.lastYear.Id)
			{
				aProductPrevAcreagesMap.put(anAcreage.AcrProductRef__c, anAcreage.Id);
			}
		}
		//Map of ProductId to Acreage__c. This map for check result. And the two FOR operators below fill this map.
		Map<Id, Acreage__c> checkAcreageMap = new Map<Id, Acreage__c>
		{
			testProductList[0].Id => new Acreage__c(AcrProductRef__c = testProductList[0].Id, 
					PreviousAcreageRef__c = aProductPrevAcreagesMap.get(testProductList[0].Id), 
					AcrYearRef__c = Util.currentYear.Id, 
					AcrTotalAcreages__c = Decimal.valueOf(VALUE_PLAINTING_DESTINY) * VALUE_QUANTITY * 3),
			testProductList[4].Id => new Acreage__c(AcrProductRef__c = testProductList[4].Id, 
					PreviousAcreageRef__c = null, 
					AcrYearRef__c = Util.currentYear.Id, 
					AcrTotalAcreages__c = Decimal.valueOf(VALUE_PLAINTING_DESTINY) * VALUE_QUANTITY * 3)
		};
		Test.startTest();
		List<Acreage__c> aCreatedAcreages = AcreagesManager.createAcreagesByTacticalPlans(testAccount.Id);
		if (!aCreatedAcreages.isEmpty())
		{
			//Select and check created and store early Acreages
			List<Acreage__c> anAcreageList = [SELECT AcrTotalAcreages__c, AcrProductRef__c, AcrYearRef__c, PreviousAcreageRef__c 
					FROM Acreage__c];
			for (Acreage__c anAcreageDB : anAcreageList)
			{
				Acreage__c aCheckAcreage = acreageMap.containsKey(anAcreageDB.Id) 
											? acreageMap.get(anAcreageDB.Id)
											: checkAcreageMap.containsKey(anAcreageDB.AcrProductRef__c)
													? checkAcreageMap.get(anAcreageDB.AcrProductRef__c)
													: null;
				if (aCheckAcreage != null)
				{
					System.assertEquals(aCheckAcreage.AcrProductRef__c, anAcreageDB.AcrProductRef__c, 
							'Incorrect filled Product reference!');
					System.assertEquals(aCheckAcreage.AcrYearRef__c, anAcreageDB.AcrYearRef__c, 
							'Incorrect filled Year reference!');
					System.assertEquals(aCheckAcreage.PreviousAcreageRef__c, anAcreageDB.PreviousAcreageRef__c, 
							'Incorrect filled previous Acreage reference!');
					if (checkAcreageMap.containsKey(aCheckAcreage.AcrProductRef__c) 
							&& aCheckAcreage.AcrYearRef__c == Util.currentYear.Id)
					{
						System.assertEquals(aCheckAcreage.AcrTotalAcreages__c, anAcreageDB.AcrTotalAcreages__c, 
								'Incorrect filled AcrTotalAcreages__c field!');
					}
					if (anAcreageDB.AcrYearRef__c == Util.currentYear.Id)
					{
						checkAcreageMap.remove(anAcreageDB.AcrProductRef__c);
					}
				}
				else
				{
					System.assert(false, 'Has been created Acreage with Id=' + anAcreageDB.Id);
				}
			}
			
			System.assert(checkAcreageMap.keySet().isEmpty(), 'These Acreages ' + checkAcreageMap.keySet() + 
					' should be created');
		}
		else
		{
			System.assert(false, 'Acreages won\'t created!');
		}
		Test.stopTest();
	}
	
	//Create list of Product records by clone record from TestInit
	private static List<Product2> createProductList(Integer theCountProducts)
	{
		List<Product2> aProductList = new List<Product2>();
		for (Integer i = 0; i < theCountProducts; i++)
		{
			Product2 aProduct = TestInit.products[0].clone(false, false);
			aProduct.Name = String.valueOf(i);
			aProductList.add(aProduct);
		}
		insert aProductList;
		return aProductList;
	}
	
	//Create list of CampaignLineItem records with parameters
	private static List<CampaignLineItem__c> createCLIList(List<Map<String, Object>> theCLIParamList)
	{
		List<CampaignLineItem__c> aCamapignLineItemList = new List<CampaignLineItem__c>();
		for (Integer i = 0; i < theCLIParamList.size(); i++)
		{
			aBaseCLIParams.putAll(theCLIParamList[i]);
			aCamapignLineItemList.add((CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', aBaseCLIParams));
		}
		insert aCamapignLineItemList;
		return aCamapignLineItemList;
	}
	
	//Create list of Acreage records with parameters
	private static Map<Id, Acreage__c> createAcreageMap(List<Map<String, Object>> theAcreageParamList)
	{
		Map<Id, Acreage__c> aResultAcreages = new Map<Id, Acreage__c>();
		List<Acreage__c> anAcreageList = new List<Acreage__c>();
		for (Integer i = 0; i < theAcreageParamList.size(); i++)
		{
			theAcreageParamList[i].putAll(aBaseAcreageParams);
			anAcreageList.add((Acreage__c)SmartFactory.createSObject('Acreage__c', theAcreageParamList[i]));
		}
		insert anAcreageList;
		
		for (Acreage__c anAcreage : anAcreageList)
		{
			aResultAcreages.put(anAcreage.Id, anAcreage);
		}
		return aResultAcreages;
	}
}