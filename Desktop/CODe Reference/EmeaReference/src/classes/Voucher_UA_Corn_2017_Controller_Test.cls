@isTest
private class Voucher_UA_Corn_2017_Controller_Test {
  
  public static List<Voucher__c> List_Vouchers;
  
  private static void Test_Ini() {
    
    User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
    currentUser.Country = 'Ukraine';
    update currentUser;
    
    Year__c PY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2015,09,1), YearEndDate__c=date.newinstance(2016,08,31), Current_Year__c=false);
    insert PY;
    
    Year__c CY = new Year__c(Name='2017', YearStartDate__c=date.newinstance(2016,09,1), YearEndDate__c=date.newinstance(2999,08,31), Current_Year__c=true, YearPreviousYear__c=PY.Id);
    insert CY;
    
    Division__c Corn = new Division__c(Name='Corn');
    insert Corn;
        
    Country__c Ukraine = new Country__c(Name='Ukraine');
    insert Ukraine;
    
    ProductCatalog__c Ukraine_Corn_Sales_2017 = new ProductCatalog__c(Name='Ukraine - Corn - Sales - 2017', CountryRef__c=Ukraine.Id, DivisionRef__c=Corn.Id, YearRef__c=CY.Id, RecordTypeId=Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'));
    insert Ukraine_Corn_Sales_2017;
    
    Campaign CampaignPY = new Campaign(YearV2__c=PY.Id, CountryRef__c=Ukraine.Id, OwnerId=currentUser.Id, StartDate=PY.YearStartDate__c, EndDate=PY.YearEndDate__c, Statuscode__c=300, SalesPCMRef__c=Ukraine_Corn_Sales_2017.Id, DivisionRef__c=Corn.Id);
    Campaign CampaignCY = new Campaign(YearV2__c=CY.Id, CountryRef__c=Ukraine.Id, OwnerId=currentUser.Id, StartDate=CY.YearStartDate__c, EndDate=CY.YearEndDate__c, Statuscode__c=200, SalesPCMRef__c=Ukraine_Corn_Sales_2017.Id, DivisionRef__c=Corn.Id);              
    insert new List<Campaign>{CampaignPY, CampaignCY};
    
    Account Account1 = new Account(CountryRef__c=Ukraine.Id, Name='TEST1', City__c='TEST', StateProvince__c='TEST');
    Account Account2 = new Account(CountryRef__c=Ukraine.Id, Name='TEST2', City__c='TEST', StateProvince__c='TEST');
    insert new List<Account>{Account1, Account2};
    
    Contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', AccountId=Account1.Id,  Decision_Maker__c=true, Phone=null, MobilePhone='987002765');
    Contact contact2 = new Contact(FirstName='TEST', LastName='TEST2', AccountId=Account2.Id,  Decision_Maker__c=true, Phone=null, MobilePhone=null);
    insert new List<Contact>{Contact1, Contact2};
    
    VoucherCampaign__c Ukraine_Corn_2017= new VoucherCampaign__c(YearRef__c=CY.Id, DivisionRef__c=Corn.Id, BagSize__c=80, CountryRef__c=Ukraine.Id, StartDate__c=CY.YearStartDate__c, EndDate__c=CY.YearEndDate__c ,MinProducts__c=1, MinTotalBags__c=1);
    insert Ukraine_Corn_2017;
    
    Discount__c d1 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Volume'), VoucherCampaignRef__c=Ukraine_Corn_2017.Id, NUM_DiscountperBag__c=0, MinBags__c=0, MaxBags__c=10000000);
    insert d1;
    
    Product2 pr1 = new Product2(Name='TEST1', ProductSAPCode__c='12123213', DivisionRef__c=Corn.Id, productBagSize__c=80);
    Product2 pr2 = new Product2(Name='TEST2', ProductSAPCode__c='12444444', DivisionRef__c=Corn.Id, productBagSize__c=80);
    insert new List<Product2> {pr1, pr2};
    
    ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=Ukraine_Corn_Sales_2017.Id, OwnerId=currentUser.Id, ProductRef__c=pr1.Id, Price__c=500);
    ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=Ukraine_Corn_Sales_2017.Id, OwnerId=currentUser.Id, ProductRef__c=pr2.Id, Price__c=300);
    insert new List<ProductCatalogEntry__c>{pce1, pce2};
    
    List_Vouchers = new List<Voucher__c>();
    List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Ukraine_Corn_2017.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Cancelled'));
    List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact1.Id, AccountRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Ukraine_Corn_2017.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=10, Status__c='Closed'));
    List_Vouchers.add(new Voucher__c(OwnerId=currentUser.Id, DiscretionaryDiscount__c=0, LKP_CONTACT__c=Contact2.Id, AccountRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, VoucherCampaignRef__c=Ukraine_Corn_2017.Id, FarmNameCopy__c='TEST2', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBags__c=50, Status__c='Closed'));
    insert List_Vouchers;
    
    CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=50, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=50, Status__c='Ordered / Discussed', Type__c='Charged');
    CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=10, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Quantity__c=10, Status__c='Ordered / Discussed', Type__c='Free of charge');
    CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=20, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=20, Status__c='Ordered / Discussed', Type__c='Charged');
    CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), Agreed__c=40, ProductCatalogEntryRef__c=pce2.Id, OwnerId=currentUser.Id, FarmRef__c=Account2.Id, CampaignRef__c=CampaignPY.Id, PlantingDensity__c='30000', ProductRef__c=pr2.Id, Quantity__c=40, Status__c='Ordered / Discussed', Type__c='Free of charge');
    insert new List<CampaignLineItem__c>{cli1, cli2, cli3, cli4};
    
    VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
    VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[0].Id,Price__c=1.0,FAO__c=200,Agreed__c=10,Bags__c=10,HybridName__c='DKC',ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge');
    VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
    VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Price__c=1.0,FAO__c=200,Agreed__c=50,Bags__c=50,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
    VoucherLineItem__c vli5 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[2].Id,Price__c=1.0,FAO__c=200,Agreed__c=40,Bags__c=40,HybridName__c='DKC',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
    VoucherLineItem__c vli6 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[2].Id,Price__c=1.0,FAO__c=200,Agreed__c=20,Bags__c=20,HybridName__c='DKC',ProductName__c='DKC TEST 1',PICK_TYPE__c='Free of charge');
    insert new List<VoucherLineItem__c>{vli1, vli2, vli3, vli4, vli5, vli6};

  }

    static testMethod void Testing_UA_Corn_2017_Voucher() {
      
    Test_Ini();
    Test.StartTest();
    
    ApexPages.StandardController Voucher_0 = new ApexPages.StandardController(List_Vouchers[0]);
    Voucher_UA_Corn_2017_controller Controller_0 = new Voucher_UA_Corn_2017_controller(Voucher_0);
    
    ApexPages.StandardController Voucher_1 = new ApexPages.StandardController(List_Vouchers[1]);
    Voucher_UA_Corn_2017_controller Controller_1 = new Voucher_UA_Corn_2017_controller(Voucher_1);
    
    ApexPages.StandardController Voucher_2 = new ApexPages.StandardController(List_Vouchers[2]);
    Voucher_UA_Corn_2017_controller Controller_2 = new Voucher_UA_Corn_2017_controller(Voucher_2);
    
    Test.StopTest();
    }
}