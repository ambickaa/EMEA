/*
	Check Campaign records on duplicates names on before insert.
*/
@isTest
private class Test_TriggerCampaignCheckDuplicates
{
	private static List<Campaign> testCampaignList;
	
	static
	{
		testCampaignList = new List<Campaign>
		{
			new Campaign(Name = 'testCampaign')
		};
	}
	
	//Check Campaign records on duplicates names.
	private static testmethod void testCheckDuplicateName()
	{
		Test.startTest();
		
		//insert first record and check that doesn\'t exist duplicates.
		List<DataBase.SaveResult> anResultInsert = DataBase.insert(testCampaignList, false);
		System.assert(anResultInsert[0].getErrors().isEmpty(), 
				'Campaign record with Name=' + testCampaignList[0].Name + ' shouldn\'t exist in DB.');
		
		//add the same record and insert it. Check that the record with the same name exist.
		testCampaignList.add(new Campaign(Name = 'testCampaign'));
		List<DataBase.UpsertResult> anResultUpsert = DataBase.upsert(testCampaignList, false);
		System.assert(anResultUpsert[0].getErrors().isEmpty(), 
				'Campaign record with Name=' + testCampaignList[0].Name + ' shouldn\'t exist in DB.');
		System.assert(!anResultUpsert[1].getErrors().isEmpty(), 
				'Campaign record with Name=' + testCampaignList[0].Name + ' should exist in DB.');
		Test.stopTest();
	}
}