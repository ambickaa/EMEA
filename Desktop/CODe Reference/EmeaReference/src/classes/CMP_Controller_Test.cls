@isTest
private class CMP_Controller_Test {
	
	//----------------------------------------------
	// Test: Initialization of variables.
	//----------------------------------------------
	public static List<Country__c> List_Countries;
	public static List<Account> List_Accounts;
	public static List<Contact> List_Contacts;
	
	public static List<EmailMessage> List_Emails;	
	public static List<Case> List_Cases;
	
	public static User TestUser;
	
	private static void iniUnitTest(){

		//----------------------------------------------
        // Test: Countries.
        //----------------------------------------------
		List_Countries = new List<Country__c>();
		List_Countries.add(new Country__c(Name = 'Slovakia'));
		List_Countries.add(new Country__c(Name = 'France'));
		Database.insert(List_Countries);
		
		//----------------------------------------------
        // Test: Accounts.
        //----------------------------------------------
		List_Accounts = new List<Account>();
		List_Accounts.add(new Account(
			CountryRef__c = List_Countries[0].Id,
			Name = 'Test: Name 0'
		));
		List_Accounts.add(new Account(
			CountryRef__c = List_Countries[1].Id,
			Name = 'Test: Name 1'
		));
		Database.insert(List_Accounts);
		
		//----------------------------------------------
        // Test: Contacts.
        //----------------------------------------------
		List_Contacts = new List<Contact>();
		List_Contacts.add(new Contact(
			FirstName = 'Test: FirstName 0',
			LastName = 'Test: LastName 0',
			MobilePhone = '123456780',
			Phone = null,
			Email = 'cmptestuser@example.com',
			AccountId = List_Accounts[0].Id
		));
		List_Contacts.add(new Contact(
			FirstName = 'Test: FirstName 1',
			LastName = 'Test: LastName 1',
			MobilePhone = '123456781',
			Phone = null,
			Email = 'cmptestuser@example.com',
			AccountId = List_Accounts[1].Id
		));
		List_Contacts.add(new Contact(
			FirstName = 'Test: FirstName 2',
			LastName = 'Test: LastName 2',
			MobilePhone = '123456782',
			Phone = null,
			Email = 'cmptestuser@example.com'
		));
		Database.insert(List_Contacts);
		
		//----------------------------------------------
        // Test: Cases.
        //----------------------------------------------
		List_Cases = new List<Case>();
        List_Cases.add(new Case(
        	RecordTypeId = Util.recordType.get('Case:Standard_Cases_Record_Type'),
        	OwnerId = Util.currentUser.Id,
        	Status = 'In Progress',
        	Description = 'Test: Description. LongDescriptionwithmorethan50characters.LongDescriptionwithmorethan50characters.',
        	NUM_STPriority__c = 1,
        	NUM_USER_SORTING__c = 1,
        	NUM_USER_PRIORITY__c = 1.0,
        	ContactId = List_Contacts[0].Id
        ));
        List_Cases.add(new Case(
        	RecordTypeId = Util.recordType.get('Case:Standard_Cases_Record_Type'),
        	OwnerId = Util.currentUser.Id,
        	Status = 'Closed',
        	Description = 'Test: Description',
        	NUM_STPriority__c = 1,
        	NUM_USER_SORTING__c = 1,
        	NUM_USER_PRIORITY__c = 3.0,
        	ContactId = List_Contacts[1].Id
        ));
        List_Cases.add(new Case(
        	RecordTypeId = Util.recordType.get('Case:Standard_Cases_Record_Type'),
        	OwnerId = '00GD0000002Ju4CMAS',
        	Status = 'New',
        	Description = 'Test: Description',
        	ContactId = List_Contacts[2].Id
        ));
        Database.insert(List_Cases);
        
		//----------------------------------------------
        // Test: EmailMessages.
        //----------------------------------------------
        List_Emails = new List<EmailMessage>();
        List_Emails.add(new EmailMessage(
        	ParentId = List_Cases[0].Id,
        	Subject = 'Test: Subject'
        ));
        List_Emails.add(new EmailMessage(
        	ParentId = List_Cases[1].Id,
        	Subject = 'Test: Subject'
        ));
		Database.insert(List_Emails);

	}

    static testMethod void myUnitTest() {
    	
    	//----------------------------------------------
        // It calls the private static void method.
        //----------------------------------------------
    	iniUnitTest();
        
        //----------------------------------------------
        // Starting test.
        //----------------------------------------------
        Test.StartTest();
        
        //----------------------------------------------
        // Defining current page.
        //----------------------------------------------
        Test.setCurrentPage(Page.CMP);
        
        //----------------------------------------------
        // Defining the variable to call the apex controller.
        //----------------------------------------------
		CMP_Controller CMP = new CMP_Controller();
		
		//----------------------------------------------
        // Calling different existent methods in the apex controller.
        //----------------------------------------------
        CMP.setCaseCurrent(List_Cases[0].Id);
        CMP.renderPanels();
        
        CMP.setEmailCurrent(List_Emails[0].Id);
        CMP.renderPanels();

        system.assertEquals(CMP.getCaseCurrent().Id, List_Cases[0].Id);
        system.assertEquals(CMP.getEmailCurrent().Id, List_Emails[0].Id);
        
        CMP.setCountrySelected('Slovakia');
        CMP.switcher();
        system.assertEquals(CMP.getCountrySelected(), 'Slovakia');
        
        CMP.setListCases(List_Cases[0].Id + ',' + List_Cases[2].Id);
        system.assertEquals(CMP.getListCases(), new List<String>{List_Cases[0].Id, List_Cases[2].Id});
        
		CMP.doSort();
		
		CMP.doClose();
		CMP.doDelete();

        CMP.setRatingValue('Excellent');        
        CMP.setRatingComments('Testing solution for this case.');
        
		system.assertEquals(CMP.getRatingValue(), 'Excellent');
        system.assertEquals(CMP.getRatingComments(), 'Testing solution for this case.');
        
        CMP.doRate();
        
        CMP_Controller.checkMail('cmptestuser@example.com');

		//----------------------------------------------
        // Finishing test.
        //----------------------------------------------
		Test.StopTest();
		
    }
}