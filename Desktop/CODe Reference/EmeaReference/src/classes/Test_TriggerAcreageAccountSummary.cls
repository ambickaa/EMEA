/**
 * Check Account summary fields after changes fields on related Acreages 
 * on after insert, after update and after delete.
 */
@isTest
private class Test_TriggerAcreageAccountSummary
{
	private static Account testMonsantoAccount = TestInit.createNewDistributor();
	private static Account testCompetitorAccount = TestInit.createNewCompetitor();
	private static Account testAccount = TestInit.createNewFarmer();
	private static Map<String, Object> baseAcreageParam;

	static void init()
	{
		insert testCompetitorAccount;
		insert testMonsantoAccount;
		insert testAccount;
		TestInit.setYear(0);
		
		baseAcreageParam = new Map<String, Object>
		{
			'AcrProviderRef__c' => testMonsantoAccount.Id, 'AcrFarmRef__c' => testAccount.Id,
			'AcrTotalAcreages__c' => 1, 'RecordTypeId' => Util.recordType.get('Acreage__c:AcreagesPerProductGroup')
		};
	}
	
	//Check Account summary fields after changes fields on related Acreages.
	private static testmethod void testUpdateAccountSummary()
	{
		init();
		//CREATE METHOD FOR FILLING LIST
		List<Map<String, Object>> anAcreageParams = new List<Map<String, Object>>
		{
			new Map<String, Object>
			{
				'AcrProductGroupRef__c' => Util.getProductGroup(Util.PRODUCT_GROUP_CORN), 
				'AcrYearRef__c' => Util.currentYear.Id
			},
			new Map<String, Object>
			{
				'AcrProductGroupRef__c' => Util.getProductGroup(Util.PRODUCT_GROUP_OSR), 
				'AcrYearRef__c' => Util.currentYear.Id
			},
			new Map<String, Object>
			{
				'AcrProductGroupRef__c' =>  Util.getProductGroup(Util.PRODUCT_GROUP_CORN), 
				'AcrYearRef__c' => Util.lastYear.Id
			},
			new Map<String, Object>
			{
				'AcrProductGroupRef__c' => Util.getProductGroup(Util.PRODUCT_GROUP_OSR), 
				'AcrYearRef__c' => Util.lastYear.Id
			}
		};
		Test.startTest();
		List<Acreage__c> anAcreageList = createAcreageList(anAcreageParams);
		
		//Prepare and check summary fields on Account after insert related Acreages
		Map<String, Integer> anAccountUpdatedFields = new Map<String, Integer>
		{
			'CornTotalAcreagesCY__c' => 1, 'CornTotalAcreagesPY__c' => 1, 
			'OSRTotalAcreagesCY__c' => 1, 'OSRTotalAcreagesPY__c' => 1, 
			'CompetitorTotalAcreagesCY__c' => 0, 'CompetitorTotalAcreagesPY__c' => 0, 
			'CornDekalbMarketshareCY__c' => 1, 'CornDekalbMarketsharePY__c' => 1, 
			'OSRDekalbMarketshareCY__c' => 1, 'OSRDekalbMarketsharePY__c' => 1
		};
		checkAccountSummary(selectAccountById(testAccount.Id), anAccountUpdatedFields);
		
		//Prepare and check summary fields on Account after update one related Acreage
		for (Acreage__c anAcreage : anAcreageList)
		{
			anAcreage.AcrProviderRef__c = testCompetitorAccount.Id;
		}

		update anAcreageList;
		anAccountUpdatedFields.put('CornDekalbMarketshareCY__c', 0);
		anAccountUpdatedFields.put('OSRDekalbMarketshareCY__c', 0);
		anAccountUpdatedFields.put('CompetitorTotalAcreagesCY__c', 2);
		anAccountUpdatedFields.put('CornDekalbMarketsharePY__c', 0);
		anAccountUpdatedFields.put('OSRDekalbMarketsharePY__c', 0);
		anAccountUpdatedFields.put('CompetitorTotalAcreagesPY__c', 2);
		checkAccountSummary(selectAccountById(testAccount.Id), anAccountUpdatedFields);
		
		//Prepare and check summary fields on Account after delete one related Acreage
		delete [SELECT Id FROM Acreage__c WHERE Id = :anAcreageList[0].Id];
		anAccountUpdatedFields.put('CornTotalAcreagesCY__c', 0);
		anAccountUpdatedFields.put('CompetitorTotalAcreagesCY__c', 1);
		anAccountUpdatedFields.put('CompetitorTotalAcreagesPY__c', 2);
		checkAccountSummary(selectAccountById(testAccount.Id), anAccountUpdatedFields);
		Test.stopTest();
	}
	
	//Create list of Acreage records with parameters
	private static List<Acreage__c> createAcreageList(List<Map<String, Object>> theAcreageParams)
	{
		List<Acreage__c> anAcreageList = new List<Acreage__c>();
		for (Map<String, Object> anAcreageParams : theAcreageParams)
		{
			anAcreageParams.putAll(baseAcreageParam);
			anAcreageList.add((Acreage__c)SmartFactory.createSObject('Acreage__c', anAcreageParams));
		}
		insert anAcreageList;
		return anAcreageList;
	}
	
	//Select Account record by Id
	private static Account selectAccountById(Id theId)
	{
		return (Account)[
			SELECT CornTotalAcreagesCY__c, CornTotalAcreagesPY__c, OSRTotalAcreagesCY__c, 
				OSRTotalAcreagesPY__c, CompetitorTotalAcreagesCY__c, CompetitorTotalAcreagesPY__c, 
				CornDekalbMarketshareCY__c, CornDekalbMarketsharePY__c, OSRDekalbMarketshareCY__c, 
				OSRDekalbMarketsharePY__c
			FROM Account
			WHERE Id = :theId];
	}
	
	//Check Account summary fields after changes fields on related Acreages.
	private static void checkAccountSummary(Account theAccount, Map<String, Integer> theAccountInsertedFields)
	{
		for (String aField : theAccountInsertedFields.keySet())
		{
			System.assertEquals(theAccountInsertedFields.get(aField), theAccount.get(aField), 'Account field '+ aField + ' has been filled incorrect!');
		}
	}
}