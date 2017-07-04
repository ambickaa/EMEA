@isTest
private class Voucher_RO_Corn_2016_Controller_Test {
	
	public static List<Voucher__c> List_Vouchers;
	
	private static void Test_Ini() {
		
		User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
		currentUser.Country = 'Romania';
		update currentUser;
		
		Year__c PY = new Year__c(Name='2015', YearStartDate__c=date.newinstance(2014,11,1), YearEndDate__c=date.newinstance(2015,10,31), Current_Year__c=false);
		insert PY;
		
		Year__c CY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2015,11,1), YearEndDate__c=date.newinstance(2999,10,31), Current_Year__c=true, YearPreviousYear__c=PY.Id);
		insert CY;
		
		Division__c Corn = new Division__c(Name='Corn');
		insert Corn;
		    
		Country__c Romania = new Country__c(Name='Romania');
		insert Romania;
		
		ProductCatalog__c Romania_Corn_Sales_2016 = new ProductCatalog__c(Name='Romania - Corn - Sales - 2016', CountryRef__c=Romania.Id, DivisionRef__c=Corn.Id, YearRef__c=CY.Id, RecordTypeId=Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'));
		insert Romania_Corn_Sales_2016;
		
		Campaign CampaignPY = new Campaign(YearV2__c=PY.Id, CountryRef__c=Romania.Id, OwnerId=currentUser.Id, StartDate=PY.YearStartDate__c, EndDate=PY.YearEndDate__c, Statuscode__c=300, SalesPCMRef__c=Romania_Corn_Sales_2016.Id, DivisionRef__c=Corn.Id);
		Campaign CampaignCY = new Campaign(YearV2__c=CY.Id, CountryRef__c=Romania.Id, OwnerId=currentUser.Id, StartDate=CY.YearStartDate__c, EndDate=CY.YearEndDate__c, Statuscode__c=200, SalesPCMRef__c=Romania_Corn_Sales_2016.Id, DivisionRef__c=Corn.Id);              
		insert new List<Campaign>{CampaignPY, CampaignCY};
		
		Account Account1 = new Account(CountryRef__c=Romania.Id, Name='TEST1', City__c='TEST', StateProvince__c='TEST', ZIPPostalCode__c = '101010', CornTotalSalesPY__c=10, NUM_AGREED_CORN_CHARGED_CY__c=140, CornTotalAcreagesCY__c=140, AgreedMTOCornSalesCY__c=140);
		Account Account2 = new Account(CountryRef__c=Romania.Id, Name='TEST2', City__c='TEST', StateProvince__c='TEST', CornTotalSalesPY__c=0, NUM_AGREED_CORN_CHARGED_CY__c=25, CornTotalAcreagesCY__c=50, AgreedMTOCornSalesCY__c=25);
		insert new List<Account>{Account1, Account2};
		
		Contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', AccountId=Account1.Id,  Decision_Maker__c=true, Phone=null, MobilePhone='987002765', Position_picklist__c='CEO');
		Contact contact2 = new Contact(FirstName='TEST', LastName='TEST2', AccountId=Account2.Id,  Decision_Maker__c=true, Phone=null, MobilePhone=null, Position_picklist__c='Other');
		insert new List<Contact>{Contact1, Contact2};
		
		VoucherCampaign__c Romania_Corn_2016 = new VoucherCampaign__c(YearRef__c=CY.Id, DivisionRef__c=Corn.Id, BagSize__c=80, CountryRef__c=Romania.Id, StartDate__c=CY.YearStartDate__c, EndDate__c=CY.YearEndDate__c ,MinProducts__c=1, MinTotalBags__c=1);
		insert Romania_Corn_2016;
		
		Discount__c d1 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Romania_Corn_2016.Id, NUM_DiscountperBag__c=5, PICK_Applies_to__c='Premium', NUM_Min_First_Ladder__c=0, TXT_Min_First_Ladder_Field__c='AccountRef__r.AgreedMTOCornSalesCY__c', TXT_Max_First_Ladder_Field__c='AccountRef__r.CornTotalSalesPY__c', NUM_Max_First_Ladder__c=1.05, MinBags__c=0, MaxBags__c=99);
		Discount__c d2 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Romania_Corn_2016.Id, NUM_DiscountperBag__c=5, PICK_Applies_to__c='Premium', NUM_Min_First_Ladder__c=0, TXT_Min_First_Ladder_Field__c='AccountRef__r.AgreedMTOCornSalesCY__c', TXT_Max_First_Ladder_Field__c='AccountRef__r.CornTotalSalesPY__c', NUM_Max_First_Ladder__c=1.05, MinBags__c=100);
		Discount__c d3 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Romania_Corn_2016.Id, NUM_DiscountperBag__c=5, PICK_Applies_to__c='Classic', NUM_Min_First_Ladder__c=0, TXT_Min_First_Ladder_Field__c='AccountRef__r.AgreedMTOCornSalesCY__c', TXT_Max_First_Ladder_Field__c='AccountRef__r.CornTotalSalesPY__c', NUM_Max_First_Ladder__c=1.05, MinBags__c=0, MaxBags__c=99);
		Discount__c d4 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'), VoucherCampaignRef__c=Romania_Corn_2016.Id, NUM_DiscountperBag__c=5, PICK_Applies_to__c='Classic', NUM_Min_First_Ladder__c=0, TXT_Min_First_Ladder_Field__c='AccountRef__r.AgreedMTOCornSalesCY__c', TXT_Max_First_Ladder_Field__c='AccountRef__r.CornTotalSalesPY__c', NUM_Max_First_Ladder__c=1.05, MinBags__c=100);
		insert new List<Discount__c> {d1, d2, d3, d4};
		
		Product2 pr1 = new Product2(Name='TEST1', Description='DKC', ProductSAPCode__c='1212321', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
		Product2 pr2 = new Product2(Name='TEST2', Description='DK', ProductSAPCode__c='12444444', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
		Product2 pr3 = new Product2(Name='TEST3', Description='DK', ProductSAPCode__c='12476767', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200);
		insert new List<Product2> {pr1, pr2, pr3};
		
		ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=Romania_Corn_Sales_2016.Id, OwnerId=currentUser.Id, ProductRef__c=pr1.Id, Price__c=500, VoucherProduct__c=true, TXT_FAO__c='260', NewProduct__c=true);
		ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=Romania_Corn_Sales_2016.Id, OwnerId=currentUser.Id, ProductRef__c=pr2.Id, Price__c=500, VoucherProduct__c=true, TXT_FAO__c='280', DE_isPremium__c=true);
		ProductCatalogEntry__c pce3 = new ProductCatalogEntry__c(ProductCatalogRef__c=Romania_Corn_Sales_2016.Id, OwnerId=currentUser.Id, ProductRef__c=pr3.Id, Price__c=500, VoucherProduct__c=true, TXT_FAO__c='300');
		insert new List<ProductCatalogEntry__c>{pce1, pce2, pce3};
		
		List_Vouchers = new List<Voucher__c>();
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Romania_Corn_2016.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Cancelled', PhoneCopy__c='987110234'));
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=5, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Romania_Corn_2016.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed', PhoneCopy__c=null));
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=2, LKP_CONTACT__c=Contact2.Id, AccountRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Romania_Corn_2016.Id, FarmNameCopy__c='TEST2', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed', PhoneCopy__c='987110234'));
		List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact2.Id, AccountRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Romania_Corn_2016.Id, FarmNameCopy__c='TEST2', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Closed', PhoneCopy__c=null));
		insert List_Vouchers;
		
		CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Charged');
		CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Free of charge');
		CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Charged');
		CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, CampaignRef__c=CampaignPY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Free of charge');
		CampaignLineItem__c cli5 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce3.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr3.Id, Quantity__c=10, Status__c='Confirmed', Type__c='Charged');
		insert new List<CampaignLineItem__c>{cli1, cli2, cli3, cli4, cli5};
		
		VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',HybridGroup__c='HD',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 2',HybridGroup__c='HD',PICK_TYPE__c='Free of charge');
		VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',HybridGroup__c='NOU HD',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',HybridGroup__c='NOU',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli5 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[2].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 2',HybridGroup__c='CLASIC',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli6 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[3].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',HybridGroup__c='CLASIC',PICK_TYPE__c='Free of charge');
		VoucherLineItem__c vli7 = new VoucherLineItem__c(CampaignLineItemRef__c=cli5.Id,VoucherRef__c=List_Vouchers[3].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',HybridGroup__c='CLASIC',PICK_TYPE__c='Charged');
		VoucherLineItem__c vli8 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[3].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',HybridGroup__c='CLASIC',PICK_TYPE__c='Free of charge');
		insert new List<VoucherLineItem__c>{vli1, vli2, vli3, vli4, vli5, vli6, vli7, vli8};

	}

    static testMethod void Testing_RO_Corn_2016_Voucher() {
    	
		Test_Ini();
		Test.StartTest();
		
		ApexPages.StandardController Voucher_0 = new ApexPages.StandardController(List_Vouchers[0]);
		Voucher_RO_Corn_2016_Controller Controller_0 = new Voucher_RO_Corn_2016_Controller(Voucher_0);
		
		ApexPages.StandardController Voucher_1 = new ApexPages.StandardController(List_Vouchers[1]);
		Voucher_RO_Corn_2016_Controller Controller_1 = new Voucher_RO_Corn_2016_Controller(Voucher_1);
		
		ApexPages.StandardController Voucher_2 = new ApexPages.StandardController(List_Vouchers[2]);
		Voucher_RO_Corn_2016_Controller Controller_2 = new Voucher_RO_Corn_2016_Controller(Voucher_2);
		
		ApexPages.StandardController Voucher_3 = new ApexPages.StandardController(List_Vouchers[3]);
		Voucher_RO_Corn_2016_Controller Controller_3 = new Voucher_RO_Corn_2016_Controller(Voucher_3);
		
		Test.StopTest();
    }
}