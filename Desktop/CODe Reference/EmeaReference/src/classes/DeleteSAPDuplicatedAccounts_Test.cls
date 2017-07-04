@isTest
private class DeleteSAPDuplicatedAccounts_Test {
	
	public static List<Account> List_Accounts;
	
	private static void myTestIni() {
		
		User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
		currentUser.Country = 'France';
		update currentUser;

		List<User> Test_User = [SELECT Id FROM User WHERE Alias = 'ETLSUPPO' OR Alias = 'LLHEIT' ORDER BY Alias ASC];
		
		Country__c Test_Country = new Country__c(Name='France');
		insert Test_Country;
		
		Product2 Test_Product = new Product2(Name='Product_Test', Description='DKC', ProductSAPCode__c='12123213');
		insert Test_Product;
		
		List_Accounts = new List<Account>();
		List_Accounts.add(new Account(RecordTypeId=Util.recordType.get('Account:DistRetPoS'), CountryRef__c=Test_Country.Id, Name='TEST1', OwnerId = Test_User[0].Id, GC_Integration_Key__c = '0001234567'));
		List_Accounts.add(new Account(RecordTypeId=Util.recordType.get('Account:DistRetPoS'), CountryRef__c=Test_Country.Id, Name='TEST2', OwnerId = Test_User[1].Id, SAP_Number_RSA__c = '1234567'));
		insert List_Accounts;
		
		Partner_Function__c Test_Partner_Function = new Partner_Function__c(Primry_Acct_Integration_Key__c=List_Accounts[0].Id);
		insert Test_Partner_Function;
		
		Invoice__c Test_Invoice = new Invoice__c(GC_Account_Integration_Key__c=List_Accounts[0].Id, GC_Integration_Key__c='0001234567', GC_Order_Number__c='1111111111');
		insert Test_Invoice;
		
		Order Test_Order = new Order(AccountId=List_Accounts[0].Id, GC_Integration_Key__c='0001234567', Status='Draft', EffectiveDate=Date.today());
		insert Test_Order;
		
		Delivery__c Test_Delivery = new Delivery__c(GC_Account_Integration_Key__c=List_Accounts[0].Id, GC_Integration_Key__c='0001234567', GC_Order_Number__c='1111111111');
		insert Test_Delivery;
		
		Contract Test_Contract = new Contract(AccountId=List_Accounts[0].Id, GC_Integration_Key__c='0001234567');
		insert Test_Contract;
		
		Case Test_Case = new Case(AccountId=List_Accounts[0].Id);
		insert Test_Case;
		
		Sales_Area__c Test_Sales_Area = new Sales_Area__c(GC_Account_Integration_Key__c=List_Accounts[0].Id);
		insert Test_Sales_Area;
		
		Contact Test_Contact = new Contact(AccountId=List_Accounts[0].Id, Lastname='Test');
		insert Test_Contact;
		
		EDI__c Test_EDI = new EDI__c(GC_Account_Integration_Key__c=List_Accounts[0].Id);
		insert Test_EDI;
		
		Banking__c Test_Banking = new Banking__c(GC_Account_Integration_Key__c=List_Accounts[0].Id);
		insert Test_Banking;
		
		Action_Plan_Line__c Test_Action_Plan_Line = new Action_Plan_Line__c(LKP_Account__c=List_Accounts[0].Id, LKP_SKU__c=Test_Product.Id, PICK_Period__c='--None--');
		insert Test_Action_Plan_Line;
		
	}

    static testMethod void myUnitTest() {
    	
    	myTestIni();

		Test.StartTest();
		
		DeleteSAPDuplicatedAccounts controller = new DeleteSAPDuplicatedAccounts();
		
		controller.From_Id = '';
		controller.To_Id = '';
		controller.doSearch();
		
		controller.From_Id = List_Accounts[0].Id;
		controller.To_Id = List_Accounts[1].Id;
		controller.doSearch();
		
		controller.doTransferX();
		
		Test.StopTest();

    }
}