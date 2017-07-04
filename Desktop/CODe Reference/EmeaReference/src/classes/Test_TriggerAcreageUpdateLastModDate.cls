/*
	Check and update AcrLastModified__c field of Acreage object
*/
@isTest
private class Test_TriggerAcreageUpdateLastModDate
{
	private static List<Acreage__c> testAcreageList;
	
	//Check changes AcrLastModified__c field
	private static testmethod void testUpdateLastModifiedDate()
	{
		Test.startTest();
		
		//Create Acreage records.
		List<Year__c> anYearList = TestInit.years;
		List<Country__c> aCountryList = TestInit.countries;
		Account anAccount = TestInit.createNewCompetitor();
		insert anAccount;
		testAcreageList = new List<Acreage__c>();
		for (Integer i = 0; i < 2; i++)
		{
			testAcreageList.add(generateAcreage(false, anAccount.Id));
		}
		insert testAcreageList;
		
		//Check Acreage list of records after insert.
		Map<Id, Acreage__c> anInsertAcreageMap = selectAcreagesById(Util.getIdSet(testAcreageList));
		System.assertEquals(DateTime.now().date(), anInsertAcreageMap.get(testAcreageList[0].Id).AcrLastModified__c.date());
		System.assertEquals(DateTime.now().date(), anInsertAcreageMap.get(testAcreageList[1].Id).AcrLastModified__c.date());
		
		//Change AcrLastModified__c field after trigger insert.
		anInsertAcreageMap.get(testAcreageList[0].Id).Dry_Land__c = true;
		anInsertAcreageMap.get(testAcreageList[0].Id).AcrLastModified__c = DateTime.now().addDays(-2);
		anInsertAcreageMap.get(testAcreageList[1].Id).AcrLastModified__c = DateTime.now().addDays(-1);
		update anInsertAcreageMap.values();
		
		//Check AcrLastModified__c field after trigger update.
		Map<Id, Acreage__c> anUpdateAcreageMap = selectAcreagesById(Util.getIdSet(testAcreageList));
		System.assertEquals(DateTime.now().date(), anUpdateAcreageMap.get(testAcreageList[0].Id).AcrLastModified__c.date());
		System.assertEquals(DateTime.now().date().addDays(-1), anUpdateAcreageMap.get(testAcreageList[1].Id).AcrLastModified__c.date());
		Test.stopTest();
	}
	
	//Generate list of Acreage records with parameters.
	private static Acreage__c generateAcreage(Boolean theDryLand, Id theAccountId)
	{
		return (Acreage__c)SmartFactory.createSObject('Acreage__c', new Map<String, Object>
				{
					'Dry_Land__c' => theDryLand, 
					'AcrFarmRef__c' => theAccountId, 
					'AcrProviderRef__c' => theAccountId
				});
	}
	
	//Select Acreage__c records from database by Ids into Map
	private static Map<Id, Acreage__c> selectAcreagesById(Set<Id> theIds)
	{
		return new Map<Id, Acreage__c>([SELECT AcrLastModified__c FROM Acreage__c WHERE Id IN :theIds]);
	}
}