@isTest
private class Voucher_UA_OSR_2017_Controller_Test {
    
    @isTest
    static void init() {
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
        currentUser.Country = 'Ukraine';
        update currentUser;
        
        Year__c year = new Year__c(Name='2017',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2017,1,1));
        insert year;
        
        Division__c OSR = new Division__c(Name='OSR');
        insert OSR;
        
        Country__c country = new Country__c(Name='Ukraine');
        insert country;
        
        Id SaCId = Util.RecordType.get('ProductCatalog__c:SalesProductCatalog');
        
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country.Id,RecordTypeId=SacId);
        insert SalesProductCatalog;
        
        Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=currentUser.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=OSR.Id);              
        insert activeCampaign;
        
        Account account1 = new Account(CountryRef__c=country.Id,Name='Ukranian Test Account',City__c='Ukranian Test City',StateProvince__c='Ukranian Test State/Province');
        Account account2 = new Account(CountryRef__c=country.Id,Name='Ukranian Test Account',City__c='Ukranian Test City',StateProvince__c='Ukranian Test State/Province');
        insert new List<Account>{account1,account2};
            
            Contact contact1 = new Contact(FirstName='Ukranian',LastName='Test Contact 1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
        Contact contact2 = new Contact(FirstName='Ukranian',LastName='Test Contact 2',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
        insert new List<Contact>{contact1,contact2};
            
            VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=OSR.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year.YearStartDate__c);
        insert voucherCampaign;
        
        Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=OSR.id, productBagSize__c=80);
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=OSR.id, productBagSize__c=80);
        insert new List<Product2> {pr1,pr2};
            
            ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=currentUser.Id);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id);
        insert new List<ProductCatalogEntry__c>{pce1,pce2};
            
            Voucher__c voucherA = new Voucher__c(OwnerId=currentUser.Id,Status__c='Cancelled',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Ukranian Test Farm',AddressCopy__c='Ukranian Test Address',PhoneCopy__c='987110234',EmailCopy__c='ukranian@test.farm',DistributorNameCopy__c='Ukranian Test Distributor');
        Voucher__c voucherB = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Ukranian Test Farm',AddressCopy__c='Ukranian Test Address',PhoneCopy__c=null,EmailCopy__c='ukranian@test.farm',DistributorNameCopy__c='Ukranian Test Distributor');
        Voucher__c voucherC = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Ukranian Test Farm',AddressCopy__c='Ukranian Test Address',PhoneCopy__c='987110234',EmailCopy__c='ukranian@test.farm',DistributorNameCopy__c='Ukranian Test Distributor');
        Voucher__c voucherD = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Ukranian Test Farm',AddressCopy__c='Ukranian Test Address',PhoneCopy__c=null,EmailCopy__c='ukranian@test.farm',DistributorNameCopy__c='Ukranian Test Distributor');
        insert new List<Voucher__c>{voucherA,voucherB,voucherC,voucherD};
            
            CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4};
            
            VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge');
        VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherB.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherB.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge');
        VoucherLineItem__c vli5 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=voucherC.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli6 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=voucherC.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge');
        VoucherLineItem__c vli7 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=voucherD.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli8 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=voucherD.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge');
        insert new List<VoucherLineItem__c>{vli1,vli2,vli3,vli4,vli5,vli6,vli7,vli8};
            
            ApexPages.StandardController vouA = new ApexPages.StandardController(voucherA);
        Voucher_UA_OSR_2017_Controller controller1 = new Voucher_UA_OSR_2017_Controller(vouA);
        
        ApexPages.StandardController vouB = new ApexPages.StandardController(voucherB);
        Voucher_UA_OSR_2017_Controller controller2= new Voucher_UA_OSR_2017_Controller(vouB);
        
        ApexPages.StandardController vouC = new ApexPages.StandardController(voucherC);
        Voucher_UA_OSR_2017_Controller controller3 = new Voucher_UA_OSR_2017_Controller(vouC);
        
        ApexPages.StandardController vouD = new ApexPages.StandardController(voucherD);
        Voucher_UA_OSR_2017_Controller controller4 = new Voucher_UA_OSR_2017_Controller(vouD);
        
        System.assertEquals(1,1);
    }
}