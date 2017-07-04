/*
	Check copying address from related Account records to Contact records.
*/
@isTest
private class Test_TriggerContact
{
	private static Account testAccount;
	private static final Map<String, String> contactToAccountFieldMap = new Map<String, String>
	{
		'ZIPPostalCode__c' => 'ZIPPostalCode__c',
		'Street__c' => 'Street__c',
		'StateProvince__c' => 'StateProvince__c',
		'Micro_Region__c' => 'Micro_Region__c',
		'County__c' => 'County__c',
		'CountryRef__c' => 'CountryRef__c',
		'City__c' => 'City__c'
	};
	
	static
	{
		testAccount = createAccount();
		insert testAccount;
	}
	
	//Check copy related Account address.
	private static testmethod void testCopyRelatedAccountAddress()
	{
		Contact aContact = new Contact(LastName = 'testContact', AccountId = testAccount.Id);
		Test.startTest();
		
		insert aContact;
		
		Contact aInsertContact = selectContactById(aContact.Id);
		checkAddresses(aInsertContact, testAccount);
		Test.stopTest();
	}
	
	//Create account record.
	private static Account createAccount()
	{
		Map<String, Object> aFieldToValue = new Map<String, Object>();
		for (String aField : contactToAccountFieldMap.keySet())
		{
			aFieldToValue.put(aField, aField != 'CountryRef__c' ? 'test' : TestInit.countries[0].Id);
		}
		return (Account)SmartFactory.createSObject('Account', aFieldToValue);
	}
	
	//Check up Contact and Account address.
	private static void checkAddresses(Contact theContact, Account theAccount)
	{
		for (String aContactField : contactToAccountFieldMap.KeySet())
		{
			System.assertEquals(theContact.get(aContactField), 
								theAccount.get(contactToAccountFieldMap.get(aContactField)), 
								'Warning : values doesn\'t equals in Contact field = ' + aContactField);
		}
	}
	
	//Select Contact records from database by Ids.
	private static Contact selectContactById(Id theId)
	{
		return [
				SELECT AccountId, ZIPPostalCode__c, Street__c, StateProvince__c,
					Micro_Region__c, County__c, CountryRef__c, City__c
				FROM Contact
				WHERE Id = :theId];
	}
}