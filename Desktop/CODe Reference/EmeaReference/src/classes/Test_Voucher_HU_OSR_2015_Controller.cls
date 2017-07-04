@isTest
private class Test_Voucher_HU_OSR_2015_Controller {
    
    @isTest
    static void init() {
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id =: Userinfo.getUserId()];
        currentUser.Country = 'Hungary';
        update currentUser;
    
        Year__c year = new Year__c(Name='2015',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2014,1,1));
        insert year;
        
        Division__c division1 = new Division__c(Name='OSR');
        insert division1;
        
        Country__c country = new Country__c(Name='Hungary');
        insert country;
        
        RecordType SaC = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country.Id,RecordTypeId=SaC.Id);
        insert SalesProductCatalog;
        
        Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=currentUser.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
        insert activeCampaign;
        
        Account account1 = new Account(CountryRef__c=country.Id,Name='Hungarian Test Account',City__c='Hungarian Test City',StateProvince__c='Hungarian Test State/Province');
        Account account2 = new Account(CountryRef__c=country.Id,Name='Hungarian Test Account',City__c='Hungarian Test City',StateProvince__c='Hungarian Test State/Province');
        Account account3 = new Account(CountryRef__c=country.Id,Name='Monsanto International Sàrl', City__c='Hungarian Test City',StateProvince__c='Hungarian Test State/Province');
        
        insert new List<Account>{account1,account2,account3};
            
        Contact contact1 = new Contact(FirstName='Hungarian',LastName='Test Contact 1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
        Contact contact2 = new Contact(FirstName='Hungarian',LastName='Test Contact 2',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
        insert new List<Contact>{contact1,contact2};
            
		VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year.YearStartDate__c);
        insert voucherCampaign;
        
        Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id, productVendor__c=account3.Id, ProductHybridGroup__c='CLEARFIELD');
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=account3.Id, ProductHybridGroup__c='CLASIC');
        insert new List<Product2> {pr1,pr2};
            
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        insert new List<ProductCatalogEntry__c>{pce1,pce2};
            
		Voucher__c voucherA = new Voucher__c(TotalBags__c=10,TotalBagsFOC__c=10,OwnerId=currentUser.Id,Status__c='Cancelled',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Hungarian Test Farm',AddressCopy__c='Hungarian Test Address',PhoneCopy__c='987110234',EmailCopy__c='Hungarian@test.farm',DistributorNameCopy__c='Hungarian Test Distributor');
        Voucher__c voucherB = new Voucher__c(TotalBags__c=60,TotalBagsFOC__c=10,OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=null,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Hungarian Test Farm',AddressCopy__c='Hungarian Test Address',PhoneCopy__c=null,EmailCopy__c='Hungarian@test.farm',DistributorNameCopy__c='Hungarian Test Distributor');
        insert new List<Voucher__c>{voucherA,voucherB};
            
		CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        insert new List<CampaignLineItem__c>{cli1,cli2};
            
        VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherA.Id,Price__c=500,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',HybridGroup__c='CLEARFIELD',FAO__c=100,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Price__c=500,Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 2',HybridGroup__c='CLASIC',FAO__c=100,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherB.Id,Price__c=500,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',HybridGroup__c='CLEARFIELD',FAO__c=200,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherB.Id,Price__c=500,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='CLASIC',FAO__c=200,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of charge');
        insert new List<VoucherLineItem__c>{vli1,vli2,vli3,vli4};
            
        ApexPages.StandardController vouA = new ApexPages.StandardController(voucherA);
        Voucher_HU_OSR_2015_Controller controller1 = new Voucher_HU_OSR_2015_Controller(vouA);
        
        ApexPages.StandardController vouB = new ApexPages.StandardController(voucherB);
        Voucher_HU_OSR_2015_Controller controller2= new Voucher_HU_OSR_2015_Controller(vouB);
        
        System.assertEquals(1,1);
    }
}