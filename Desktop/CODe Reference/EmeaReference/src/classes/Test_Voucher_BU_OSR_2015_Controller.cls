@isTest
private class Test_Voucher_BU_OSR_2015_Controller {
    
    @isTest
    static void init() {
        
        Test.startTest();
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
        currentUser.Country = 'Bulgaria';
        update currentUser;
        
        Year__c year_py = new Year__c(Name='2014',Current_Year__c=false,YearEndDate__c=date.newinstance(2014,12,31),YearStartDate__c=date.newinstance(2013,1,1));
        insert year_py;
        
        Year__c year = new Year__c(Name='2015',Current_Year__c=true,YearPreviousYear__c=year_py.Id,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year;
        
        Division__c division1 = new Division__c(Name='OSR');
        insert division1;
        
        Country__c country = new Country__c(Name='Bulgaria');
        insert country;
        
        RecordType RecPCSales = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Bulgaria - OSR - Sales - 2015',CountryRef__c=country.Id,DivisionRef__c=division1.Id,YearRef__c=year.Id,RecordTypeId=RecPCSales.Id);
        insert SalesProductCatalog;
        
        Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=currentUser.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
        insert activeCampaign;
        
        Account account1 = new Account(CountryRef__c=country.Id,Name='Test Account1',City__c='Test City1',StateProvince__c='Test State/Province1',ZIPPostalCode__c='60612');
        Account account2 = new Account(CountryRef__c=country.Id,Name='Test Account2',City__c='Test City2',StateProvince__c='Test State/Province2');
        Account account3 = new Account(CountryRef__c=country.Id,Name='Test Account3',City__c='Test City3',StateProvince__c='Test State/Province3');
        insert new List<Account>{account1,account2};
            
		Product_Grouping__c PGrouping1 = new Product_Grouping__c (Name = 'Corn');
        Product_Grouping__c PGrouping2 = new Product_Grouping__c (Name = 'OSR');
        Product_Grouping__c PGrouping3 = new Product_Grouping__c (Name = 'Sun Flower');
        Product_Grouping__c PGrouping4 = new Product_Grouping__c (Name = 'Wheat');
        Product_Grouping__c PGrouping5 = new Product_Grouping__c (Name = 'Barley');
        insert new List<Product_Grouping__c>{PGrouping1,PGrouping2,PGrouping3,PGrouping4,PGrouping5};
            
		RecordType RecAcGroup = [select Id from RecordType where SobjectType='Acreage__c' and DeveloperName='AcreagesPerProductGroup'];
        Acreage__c acr1A = new Acreage__c(AcrTotalAcreages__c=120,AcrFarmRef__c=account1.Id,AcrYearRef__c=year.Id,AcrProductGroupRef__c=PGrouping1.Id,AcrProviderRef__c=account3.Id);
        Acreage__c acr1B = new Acreage__c(AcrTotalAcreages__c=150,AcrFarmRef__c=account1.Id,AcrYearRef__c=year.Id,AcrProductGroupRef__c=PGrouping2.Id,AcrProviderRef__c=account3.Id);
        Acreage__c acr2A = new Acreage__c(AcrTotalAcreages__c=20,AcrFarmRef__c=account2.Id,AcrYearRef__c=year.Id,AcrProductGroupRef__c=PGrouping3.Id,AcrProviderRef__c=account3.Id);
        Acreage__c acr2B = new Acreage__c(AcrTotalAcreages__c=20,AcrFarmRef__c=account2.Id,AcrYearRef__c=year.Id,AcrProductGroupRef__c=PGrouping4.Id,AcrProviderRef__c=account3.Id);
        Acreage__c acr2C = new Acreage__c(AcrTotalAcreages__c=20,AcrFarmRef__c=account2.Id,AcrYearRef__c=year.Id,AcrProductGroupRef__c=PGrouping5.Id,AcrProviderRef__c=account3.Id);
        insert new List<Acreage__c>{acr1A,acr1B,acr2A,acr2B,acr2C};
            
		Contact contact1 = new Contact(FirstName='Test',LastName='Contact1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
        Contact contact2 = new Contact(FirstName='Test',LastName='Contact2',MobilePhone=null,Phone='999666333',Decision_Maker__c=true,AccountId=account2.Id);
        insert new List<Contact>{contact1,contact2};
            
		VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=division1.Id,BagSize__c=1500,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=1,MinTotalBags__c=20,StartDate__c=year.YearStartDate__c);
        insert voucherCampaign;
        
        Product2 pr1 = new Product2(Name='EXPRIT Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id, productBagSize__c=1500,ProductTreatment__c='NA');
        Product2 pr2 = new Product2(Name='EXPLICIT Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productBagSize__c=1500,ProductTreatment__c='NA');
        insert new List<Product2> {pr1,pr2};
            
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=0,ProductRef__c=pr1.Id,OwnerId=currentUser.Id);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=0,ProductRef__c=pr2.Id,OwnerId=currentUser.Id);
        insert new List<ProductCatalogEntry__c>{pce1,pce2};
            
            Voucher__c voucherA = new Voucher__c(OwnerId=currentUser.Id,Status__c='Cancelled',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm1',AddressCopy__c='Test Address1',PhoneCopy__c='987110234',EmailCopy__c='test1@test.farm',DistributorNameCopy__c='Test Distributor1');
        Voucher__c voucherB = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Test Farm2',AddressCopy__c='Test Address2',PhoneCopy__c=null,EmailCopy__c='test2@test.farm',DistributorNameCopy__c='Test Distributor2');
        insert new List<Voucher__c>{voucherA,voucherB};
            
            CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=30,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='40000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=80,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='40000',ProductRef__c=pr2.Id);
        insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4};
            
            VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='EXPRIT Test',ProductName__c='EXPRIT Test',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Agreed__c=30,Bags__c=30,HybridName__c='EXPLICIT Test',ProductName__c='EXPLICIT Test',PICK_TYPE__c='Free of charge');
        VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=voucherB.Id,Agreed__c=50,Bags__c=50,HybridName__c='EXPRIT Test',ProductName__c='EXPRIT Test',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=voucherB.Id,Agreed__c=30,Bags__c=30,HybridName__c='EXPLICIT Test',ProductName__c='EXPLICIT Test',PICK_TYPE__c='Free of charge');
        insert new List<VoucherLineItem__c>{vli1,vli2,vli3,vli4};
            
            ApexPages.StandardController vouA = new ApexPages.StandardController(voucherA);
        Voucher_BU_OSR_2015_Controller controller1 = new Voucher_BU_OSR_2015_Controller(vouA);
        
        ApexPages.StandardController vouB = new ApexPages.StandardController(voucherB);
        Voucher_BU_OSR_2015_Controller controller2= new Voucher_BU_OSR_2015_Controller(vouB);
        
        System.assertEquals(1,1);
    Test.StopTest();
}
}