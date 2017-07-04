/*
	
*/
@isTest
private class Test_AccountListContactController
{
	private static final Integer CLI_QUANTITY = 19;
	private static final Integer PCE_PRICE = 7;
	
	private static Contact testContact = TestInit.contacts[0];
	
	/*
		@description Initialize URL parameters and required records for test.
	*/
	private static void init()
	{
		TestInit.createAccountListController();
		
		testContact.AccountId = TestInit.accountWrapper.accountRecord.Id;
		update testContact;
		
		PageReference aPage = Page.AccountViewDefault;
		aPage.getParameters().put('Id', TestInit.accountWrapper.accountRecord.Id);
		aPage.getParameters().put('division', TestInit.accountWrapper.campaignRecord.DivisionRef__c);
		Test.setCurrentPageReference(aPage);
	}
	
	/*
		@description Test create, edit and delete Contact records
	*/
	private static testMethod void testAccountContactListController()
	{
		init();
		
		Test.startTest();
		AccountListContactController aController = new AccountListContactController();
		System.AssertEquals(testContact.Id, aController.getContacts()[0].record.Id, 'Selected Campaign record is incorrect.');
		System.assert(aController.getIsHasElements(), 'Controller hasn\'t any elements.');
		
		//Create new record
		Test.setCurrentPage(TestInit.customRedirectModifier(aController.newRecord()));
		Util.urlParameters = null;
		AccountListContactController aNewRecordController = new AccountListContactController();
		
		Integer aListSize = aNewRecordController.getContacts().size();
		System.AssertEquals(2, aListSize, 'Size of list should be 2.');
		
		Contact aCreatedRecord = aNewRecordController.getContacts()[aListSize - 1].record;
		aCreatedRecord.LastName = TestInit.accountWrapper.accountRecord.Name;
		
		//Save new record with filled fields
		Test.setCurrentPage(TestInit.customRedirectModifier(aNewRecordController.save()));
		Util.urlParameters = null;
		AccountListContactController aSaveRecordController = new AccountListContactController();
		
		//Select last record for delete
		aListSize = aSaveRecordController.getContacts().size();
		System.AssertEquals(2, aListSize, 'Size of list should be 2.');
		aSaveRecordController.getContacts()[aListSize - 1].checked = true;
		
		//Delete selected record
		Test.setCurrentPage(TestInit.customRedirectModifier(aSaveRecordController.deletex()));
		Util.urlParameters = null;
		AccountListContactController aDeleteRecordController = new AccountListContactController();
		System.assertEquals(1, aDeleteRecordController.getContacts().size(), 'Size of list should be 1.');
		aDeleteRecordController.edit();
		aDeleteRecordController.cancel();
		Test.stopTest();
	}
}