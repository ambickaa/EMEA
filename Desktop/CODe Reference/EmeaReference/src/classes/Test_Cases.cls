@isTest
private class Test_Cases
{
	
	static void init()
	{
		upsert Testinit.farmers;
		upsert Testinit.cases;
	}
	
	static testMethod void createCaseFromAccountList()
	{
		init();
		Util.urlParameters.put( 'accountId', TestInit.farmers.get( 0 ).id );
		
		PageReference pageNew = Page.CaseNew;
		Test.setCurrentPageReference(pageNew);
		
		ApexPages.StandardController sc = new ApexPages.standardController(new Case());
		CaseNewController controllerNew = new CaseNewController(sc);
		
		// fill form
		controllerNew.currentCase.record.Origin = 'Email';
		controllerNew.currentCase.record.ContactId = TestInit.contacts.get(0).Id;
		controllerNew.currentCase.record.Subject = 'A new Case Subject';
		controllerNew.currentCase.record.Description = 'The Case description goes here..';
		
		// try to save
		controllerNew.save();
		
		// set product
		controllerNew.currentCase.lookupValue.id = TestInit.products.get(0).Id;
		
		// try to save
		controllerNew.save();
		
		// test canecl button
		controllerNew.cancel();
	}

	static testMethod void editCaseFromAccountList()
	{
		init();
		//Util.urlParameters.put( 'accountId', TestInit.farmers.get( 0 ).id );
		
		PageReference pageEdit = Page.CaseEdit;
		Test.setCurrentPageReference(pageEdit);
				
		ApexPages.StandardController sc = new ApexPages.standardController(TestInit.cases.get( 0 ));
		CaseEditController controllerEdit = new CaseEditController(sc);
		
		system.debug('========= case 0 ' + TestInit.cases.get( 0 ));
		system.debug('========= controllerEdit ' + controllerEdit);
		system.debug('========= controllerEdit.currentCase ' + controllerEdit.currentCase);
		
		
		// fill form
		controllerEdit.currentCase.record.Origin = 'Email';
		controllerEdit.currentCase.record.ContactId = TestInit.contacts.get(0).Id;
		controllerEdit.currentCase.record.Subject = 'A new Case Subject';
		controllerEdit.currentCase.record.Description = 'The Case description goes here..';
		controllerEdit.currentCase.lookupValue = new LookupValue(TestInit.products.get(0).Id, TestInit.products.get(0).Name);
		
		// try to save
		controllerEdit.save();
		
		// test canecl button
		controllerEdit.cancel();
	}

	static testMethod void sendToTechDepartment()
	{
		init();
		Util.urlParameters.put( 'Id', TestInit.contacts.get( 0 ).id );
		
		PageReference pageSend = Page.CaseSendToTd;
		Test.setCurrentPageReference(pageSend);
		
		CaseSendToTdController controllerSend = new CaseSendToTdController();
		
		// try to process
		controllerSend.processCase();
		
		controllerSend.emailContactId = TestInit.contacts.get(0).Id;
		controllerSend.processCase();
		
		
		
		// return methods
		controllerSend.returnToCase();
		controllerSend.returnToAccount();
	}


}