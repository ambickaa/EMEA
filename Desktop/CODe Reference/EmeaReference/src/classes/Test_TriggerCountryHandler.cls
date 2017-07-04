/*
	@description Test copy CountryId__c from Id on after insert
	@copyright PARX
*/
@isTest
private class Test_TriggerCountryHandler
{
	private static testMethod void testUpdateCoutryByInsert()
	{
		Test.startTest();
		List<Country__c> aCountryList = TestInit.countries;
		for (Country__c aCountry : [SELECT CountryId__c FROM Country__c WHERE ID IN :Util.getIdSet(aCountryList)])
		{
			System.assertEquals(aCountry.Id, aCountry.CountryId__c, 'Id and CountryId__c should be equals!');
		}
		Test.stopTest();
	}
}