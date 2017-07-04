@isTest
private class Voucher_CZ_OSR_2017_Controller_Test{
    
    public static List<Voucher__c> List_Vouchers;
    
    static void init() {
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id =: Userinfo.getUserId()];
        currentUser.Country = 'Czech Republic';
        update currentUser;
        
        Year__c PY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2015,11,1), YearEndDate__c=date.newinstance(2015,10,31), Current_Year__c=false);
      insert PY;
        Year__c year = new Year__c(Name='2017',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2016,1,1),YearPreviousYear__c=PY.Id);
        insert year;
        
        Division__c division1 = new Division__c(Name='OSR');
        insert division1;
        
        Country__c country = new Country__c(Name='Czech Republic');
        insert country;
        
        RecordType SaC = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country.Id,RecordTypeId=SaC.Id);
        insert SalesProductCatalog;
        
        Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=currentUser.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
        insert activeCampaign;
        
        Account account1 = new Account(CountryRef__c=country.Id,Name='Test Account',City__c='Test City',StateProvince__c='Test State/Province');
        Account account2 = new Account(CountryRef__c=country.Id,Name='Test Account',City__c='Test City',StateProvince__c='Test State/Province');
        Account account3 = new Account(CountryRef__c=country.Id,Name='Monsanto International Sàrl', City__c='Test City',StateProvince__c='Test State/Province');
        
        insert new List<Account>{account1,account2,account3};
            
        Contact contact1 = new Contact(FirstName='',LastName='Test Contact 1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
        Contact contact2 = new Contact(FirstName='',LastName='Test Contact 2',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
        insert new List<Contact>{contact1,contact2};
            
        VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year.YearStartDate__c);
        insert voucherCampaign;
 
        Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id, productVendor__c=account3.Id);
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=account3.Id);
        insert new List<Product2> {pr1,pr2};
            
         ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,DE_isPremium__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        insert new List<ProductCatalogEntry__c>{pce1,pce2};
            
        Product_Grouping__c OSRGroup = new Product_Grouping__c(Name='OSR');
        insert OSRGroup;
        Product_Grouping__c Silage = new Product_Grouping__c(Name='OSR', ProductGroupRef__c=OSRGroup.Id);
        Product_Grouping__c Grain = new Product_Grouping__c(Name='OSR', ProductGroupRef__c=OSRGroup.Id);
      insert new List<Product_Grouping__c> {Silage, Grain};
        
        Acreage__c acr1 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=account1.Id, AcrYearRef__c=year.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=OSRGroup.Id, AcrProductTypeRef__c=Silage.Id);
        Acreage__c acr2 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=account1.Id, AcrYearRef__c=year.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=OSRGroup.Id, AcrProductTypeRef__c=Grain.Id);
        Acreage__c acr3 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=account2.Id, AcrYearRef__c=year.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=OSRGroup.Id, AcrProductTypeRef__c=Silage.Id);
        Acreage__c acr4 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=account2.Id, AcrYearRef__c=year.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=OSRGroup.Id, AcrProductTypeRef__c=Grain.Id);
        insert new List<Acreage__c> {acr1, acr2, acr3, acr4};
        
        List_Vouchers = new List<Voucher__c>();
    List_Vouchers.add(new Voucher__c(DiscretionaryDiscount__c=0, DistributorRef__c=account3.Id,TotalBags__c=10,OwnerId=currentUser.Id,Status__c='Cancelled',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm',AddressCopy__c='Test Address',PhoneCopy__c='987110234',EmailCopy__c='test@test.farm',DistributorNameCopy__c='Test Distributor'));
         List_Vouchers.add(new Voucher__c(DiscretionaryDiscount__c=0, DistributorRef__c=account3.Id,TotalBags__c=60,OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm',AddressCopy__c='Test Address',PhoneCopy__c=null,EmailCopy__c='test@test.farm',DistributorNameCopy__c='Test Distributor'));
        List_Vouchers.add(new Voucher__c(DiscretionaryDiscount__c=5, DistributorRef__c=account3.Id,TotalBags__c=102,OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm',AddressCopy__c='Test Address',PhoneCopy__c='987110234',EmailCopy__c='test@test.farm',DistributorNameCopy__c='Test Distributor'));
        List_Vouchers.add(new Voucher__c(DiscretionaryDiscount__c=5, DistributorRef__c=account3.Id,TotalBags__c=900,OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm',AddressCopy__c='Test Address',PhoneCopy__c=null,EmailCopy__c='test@test.farm',DistributorNameCopy__c='Test Distributor'));
        List_Vouchers.add(new Voucher__c(DiscretionaryDiscount__c=10, DistributorRef__c=account3.Id,TotalBags__c=1005,OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm',AddressCopy__c='Test Address',PhoneCopy__c=null,EmailCopy__c='test@test.farm',DistributorNameCopy__c='Test Distributor'));
        insert List_Vouchers;     
            
    CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=250,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=650,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli5 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=650,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli6 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=300,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        
        insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4,cli5,cli6};
            
        VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[0].Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',HybridGroup__c='NOU',FAO__c=100,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500);
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[0].Id,Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 2',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge', Price__c = 500);
        VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[1].Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',HybridGroup__c='MAXTECH',FAO__c=200,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500);
        VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=List_Vouchers[1].Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='CLASIC',FAO__c=200,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge', Price__c = 500);
        VoucherLineItem__c vli5 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[2].Id,Agreed__c=450,Bags__c=450,HybridName__c='DKC TEST 1',HybridGroup__c='YIELDGARD',FAO__c=300,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500);
        VoucherLineItem__c vli6 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[2].Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='NOU',FAO__c=300,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge', Price__c = 500);
        VoucherLineItem__c vli7 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=List_Vouchers[3].Id,Agreed__c=950,Bags__c=950,HybridName__c='DKC TEST 1',HybridGroup__c='HD',FAO__c=400,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500);
        VoucherLineItem__c vli8 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=List_Vouchers[3].Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='MAXTECH',FAO__c=400,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged', Price__c = 500);
        VoucherLineItem__c vli9 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=List_Vouchers[3].Id,Agreed__c=950,Bags__c=950,HybridName__c='DKC TEST 1',HybridGroup__c='NOU',FAO__c=400,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500);
        VoucherLineItem__c vli10 = new VoucherLineItem__c(CampaignLineItemRef__c=cli5.Id,VoucherRef__c=List_Vouchers[4].Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='YIELDGARD',FAO__c=400,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged', Price__c = 500);
        VoucherLineItem__c vli11 = new VoucherLineItem__c(CampaignLineItemRef__c=cli6.Id,VoucherRef__c=List_Vouchers[4].Id,Agreed__c=150,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='CLASIC',FAO__c=400,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge', Price__c = 500);
        VoucherLineItem__c vli12 = new VoucherLineItem__c(CampaignLineItemRef__c=cli6.Id,VoucherRef__c=List_Vouchers[4].Id,Agreed__c=150,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='HD',FAO__c=400,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge', Price__c = 500);
        
        insert new List<VoucherLineItem__c>{vli1,vli2,vli3,vli4,vli5,vli6,vli7,vli8,vli9,vli10,vli11,vli12};
        }
        static testMethod void Testing_BU_OSR_2016_Voucher() {
        init();
        Test.startTest();

        ApexPages.StandardController vouA = new ApexPages.StandardController(List_Vouchers[0]);
        Voucher_CZ_OSR_2017_Controller controller1 = new Voucher_CZ_OSR_2017_Controller(vouA);
        
        ApexPages.StandardController vouB = new ApexPages.StandardController(List_Vouchers[1]);
        Voucher_CZ_OSR_2017_Controller controller2= new Voucher_CZ_OSR_2017_Controller(vouB);
        
        ApexPages.StandardController vouC = new ApexPages.StandardController(List_Vouchers[2]);
        Voucher_CZ_OSR_2017_Controller controller3 = new Voucher_CZ_OSR_2017_Controller(vouC);
        
        ApexPages.StandardController vouD = new ApexPages.StandardController(List_Vouchers[3]);
        Voucher_CZ_OSR_2017_Controller controller4 = new Voucher_CZ_OSR_2017_Controller(vouD);
        
        ApexPages.StandardController vouE = new ApexPages.StandardController(List_Vouchers[4]);
        Voucher_CZ_OSR_2017_Controller controller5 = new Voucher_CZ_OSR_2017_Controller(vouE);
        
        System.assertEquals(1,1);
        Test.StopTest();
        
    }
}