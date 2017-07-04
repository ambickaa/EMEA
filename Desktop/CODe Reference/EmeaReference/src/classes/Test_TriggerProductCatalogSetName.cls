/*
	Check filling Name of ProductCatalog__c on before insert.
*/
@isTest
private class Test_TriggerProductCatalogSetName
{
	private static List<Country__c> countryList = TestInit.countries;
	private static List<Year__c> yearList = TestInit.years;
	private static Division__c divisionObject = TestInit.getDivision('testDivision');
	
	//Check how filled Name of ProductCatalog__c inserted record.
	private static testmethod void testCheckFillName()
	{
		Test.startTest();
		List<String> aListOfNamesObjects = new List<String>
		{
			countryList[0].Name, yearList[0].Name, divisionObject.Name, 'Competitor'
		};
		Map<String, Object> aProductCatalogParams = new Map<String, Object>
		{
			'RecordTypeId' => Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog'), 
			'YearRef__c' => yearList[0].Id, 'CountryRef__c' => countryList[0].id, 
			'DivisionRef__c' => divisionObject.Id
		};
		ProductCatalog__c aProductCatalog = (ProductCatalog__c)SmartFactory.createSObject('ProductCatalog__c', aProductCatalogParams);
		insert aProductCatalog;
		
		ProductCatalog__c aInsertProductCatalog = [SELECT Name FROM ProductCatalog__c WHERE Id = :aProductCatalog.Id];
		checkPartsOfName(aInsertProductCatalog.Name, aListOfNamesObjects);
		Test.stopTest();
	}
	
	//Check ProductCatalog__c name on contains name from related objects from theObjectNames list.
	private static void checkPartsOfName(String theProductCatalogName, List<String> theObjectNames)
	{
		for (String aName : theObjectNames)
		{
			System.assert(theProductCatalogName.contains(aName), 
					'Wrong : object with Name=' + aName + ' don\'t has been added.');
		}
	}
}