@isTest
private class Test_VoucherItaly2015Controller {
	
	public static List<Voucher__c> List_Vouchers;
	
	private static void Test_Ini() {
		
		User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
		currentUser.Country = 'Italy';
		update currentUser;
		
		Year__c PY = new Year__c(Name='2014', YearStartDate__c=date.newinstance(2013,11,1), YearEndDate__c=date.newinstance(2014,10,31), Current_Year__c=false);
		insert PY;
		
		Year__c CY = new Year__c(Name='2015', YearStartDate__c=date.newinstance(2014,11,1), YearEndDate__c=date.newinstance(2999,10,31), Current_Year__c=true, YearPreviousYear__c=PY.Id);
		insert CY;
		
		Division__c Corn = new Division__c(Name='Corn');
		insert Corn;
		    
		Country__c Italy = new Country__c(Name='Italy');
		insert Italy;
		
		ProductCatalog__c Italy_Corn_Sales_2015 = new ProductCatalog__c(Name='Italy - Corn - Sales - 2015', CountryRef__c=Italy.Id, DivisionRef__c=Corn.Id, YearRef__c=CY.Id, RecordTypeId=Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'));
		insert Italy_Corn_Sales_2015;
		
		Campaign CampaignPY = new Campaign(YearV2__c=PY.Id, CountryRef__c=Italy.Id, OwnerId=currentUser.Id, StartDate=PY.YearStartDate__c, EndDate=PY.YearEndDate__c, Statuscode__c=300, SalesPCMRef__c=Italy_Corn_Sales_2015.Id, DivisionRef__c=Corn.Id);
		Campaign CampaignCY = new Campaign(YearV2__c=CY.Id, CountryRef__c=Italy.Id, OwnerId=currentUser.Id, StartDate=CY.YearStartDate__c, EndDate=CY.YearEndDate__c, Statuscode__c=200, SalesPCMRef__c=Italy_Corn_Sales_2015.Id, DivisionRef__c=Corn.Id);              
		insert new List<Campaign>{CampaignPY, CampaignCY};
		
		Account Account1 = new Account(CountryRef__c=Italy.Id, Name='TEST1', City__c='TEST', StateProvince__c='TEST');
		Account Account2 = new Account(CountryRef__c=Italy.Id, Name='TEST1', City__c='TEST', StateProvince__c='TEST', Phone='98877321');
		insert new List<Account> {Account1, Account2};
		
		Contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', AccountId=Account1.Id, Phone=null, MobilePhone='987002765');
		Contact contact2 = new Contact(FirstName='TEST', LastName='TEST1', AccountId=Account2.Id, Phone='98877321', MobilePhone='987002765');
		insert new List<Contact> {Contact1, Contact2};
		
		VoucherCampaign__c Italy_Corn_2015 = new VoucherCampaign__c(YearRef__c=CY.Id, DivisionRef__c=Corn.Id, BagSize__c=80, CountryRef__c=Italy.Id, StartDate__c=CY.YearStartDate__c, EndDate__c=CY.YearEndDate__c ,MinProducts__c=1, MinTotalBags__c=1);
		insert Italy_Corn_2015;
		
		Product2 pr1 = new Product2(Name='TEST1', ProductSAPCode__c='12123213', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
		Product2 pr2 = new Product2(Name='TEST2', ProductSAPCode__c='12444444', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
		insert new List<Product2> {pr1, pr2};
		
		ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=Italy_Corn_Sales_2015.Id, OwnerId=currentUser.Id, ProductRef__c=pr1.Id);
		ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=Italy_Corn_Sales_2015.Id, OwnerId=currentUser.Id, ProductRef__c=pr2.Id);
		insert new List<ProductCatalogEntry__c>{pce1, pce2};
		
		List_Vouchers = new List<Voucher__c>();
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Italy_Corn_2015.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Cancelled', PhoneCopy__c='987110234'));
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Italy_Corn_2015.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed', PhoneCopy__c=null));
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, LKP_CONTACT__c=Contact2.Id, AccountRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Italy_Corn_2015.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed', PhoneCopy__c='987110234'));
		insert List_Vouchers;
		
		CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=10, Agreed__c=5, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, DistributorRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Charged');
		CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=20, Agreed__c=20, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, DistributorRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=20, Status__c='Confirmed', Type__c='Charged');
		CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=20, Agreed__c=20, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, DistributorRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=20, Status__c='Confirmed', Type__c='Charged');
		insert new List<CampaignLineItem__c>{cli1, cli2, cli3};
		
		VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=5,Bags__c=5,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=20,Bags__c=20,HybridName__c='DKC',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=5,Bags__c=5,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=20,Bags__c=20,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli5 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[2].Id,Price__c=1.0,FAO__c=200,Agreed__c=20,Bags__c=20,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
		insert new List<VoucherLineItem__c>{vli1, vli2, vli3, vli4};

	}

    static testMethod void Testing_IT_Corn_2015_Voucher() {
    	
		Test_Ini();
		Test.StartTest();
		
		ApexPages.StandardController Voucher_0 = new ApexPages.StandardController(List_Vouchers[0]);
		VoucherItaly2015Controller Controller_0 = new VoucherItaly2015Controller(Voucher_0);
		
		ApexPages.StandardController Voucher_1 = new ApexPages.StandardController(List_Vouchers[1]);
		VoucherItaly2015Controller Controller_1 = new VoucherItaly2015Controller(Voucher_1);
		
		ApexPages.StandardController Voucher_2 = new ApexPages.StandardController(List_Vouchers[2]);
		VoucherItaly2015Controller Controller_2 = new VoucherItaly2015Controller(Voucher_2);
		
		Test.StopTest();
    }
}