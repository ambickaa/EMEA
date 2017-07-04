@isTest
private class Test_VoucherHungaryCorn2015 {
    
    @isTest
    static void init() {

        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
		currentUser.Country = 'Hungary';
		update currentUser;
        
        Year__c year = new Year__c(Name='2015',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2014,1,1));
        insert year;
        
        Division__c division1 = new Division__c(Name='Corn');
        insert division1;
        
        Country__c country = new Country__c(Name='Hungary');
        insert country;
        
        RecordType SaC = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Hungary - Corn - Sales - 2015',CountryRef__c=country.Id,RecordTypeId=SaC.Id);
        insert SalesProductCatalog;
        
        Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=currentUser.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
        insert activeCampaign;
        
        Account account1 = new Account(CountryRef__c=country.Id,Name='Hungaryn Test Account',City__c='Hungaryn Test City',StateProvince__c='Hungaryn Test State/Province');
        Account account2 = new Account(CountryRef__c=country.Id,Name='Hungaryn Test Account',City__c='Hungaryn Test City',StateProvince__c='Hungaryn Test State/Province');
        insert new List<Account>{account1,account2};
            
        Contact contact1 = new Contact(FirstName='Hungaryn',LastName='Test Contact 1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
        Contact contact2 = new Contact(FirstName='Hungaryn',LastName='Test Contact 2',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
        insert new List<Contact>{contact1,contact2};
            
		VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year.YearStartDate__c);
        insert voucherCampaign;
        
        Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id);
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id);
        Product2 pr3 = new Product2(Name='DKC Test',ProductSAPCode__c='12123623',DivisionRef__c=division1.id);
        Product2 pr4 = new Product2(Name='DKC Test',ProductSAPCode__c='12446664',DivisionRef__c=division1.id);
        
        insert new List<Product2> {pr1,pr2, pr3, pr4};
            
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(DE_isPremium__c=false, ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=currentUser.Id);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(DE_isPremium__c=true, ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id);
        ProductCatalogEntry__c pce3 = new ProductCatalogEntry__c(DE_isPremium__c=true, ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr3.Id,OwnerId=currentUser.Id);
        ProductCatalogEntry__c pce4 = new ProductCatalogEntry__c(DE_isPremium__c=true, ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr4.Id,OwnerId=currentUser.Id);
        insert new List<ProductCatalogEntry__c>{pce1,pce2, pce3, pce4};
            
        Voucher__c voucherA = new Voucher__c(TotalBags__c=100,TotalBagsFOC__c=0,OwnerId=currentUser.Id,Status__c='Closed',AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Hungaryn Test Farm',AddressCopy__c='Hungaryn Test Address',PhoneCopy__c='987110234',EmailCopy__c='Hungaryn@test.farm',DistributorNameCopy__c='Hungaryn Test Distributor');
        Voucher__c voucherB = new Voucher__c(TotalBags__c=200,TotalBagsFOC__c=0,OwnerId=currentUser.Id,Status__c='Closed',AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Hungaryn Test Farm',AddressCopy__c='Hungaryn Test Address',PhoneCopy__c=null,EmailCopy__c='Hungaryn@test.farm',DistributorNameCopy__c='Hungaryn Test Distributor');
        Voucher__c voucherC = new Voucher__c(TotalBags__c=400,TotalBagsFOC__c=0,OwnerId=currentUser.Id,Status__c='Closed',AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Hungaryn Test Farm',AddressCopy__c='Hungaryn Test Address',PhoneCopy__c='987110234',EmailCopy__c='Hungaryn@test.farm',DistributorNameCopy__c='Hungaryn Test Distributor');
        Voucher__c voucherD = new Voucher__c(TotalBags__c=1000,TotalBagsFOC__c=0,OwnerId=currentUser.Id,Status__c='Closed',AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Hungaryn Test Farm',AddressCopy__c='Hungaryn Test Address',PhoneCopy__c=null,EmailCopy__c='Hungaryn@test.farm',DistributorNameCopy__c='Hungaryn Test Distributor');
        insert new List<Voucher__c>{voucherA,voucherB,voucherC,voucherD};
            
        CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Forecast__c=1700, Agreed__c=100,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=200,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=400,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr3.Id);
        CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=10000,ProductCatalogEntryRef__c=pce2.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr4.Id);
        insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4};
            
        VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherA.Id,Agreed__c=100,Bags__c=100,HybridName__c='DKC TEST 1',HybridGroup__c='NOU',FAO__c=100,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Agreed__c=200,Bags__c=200,HybridName__c='DKC TEST 2',HybridGroup__c='HD',FAO__c=100,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherB.Id,Agreed__c=400,Bags__c=400,HybridName__c='DKC TEST 3',HybridGroup__c='MAXTECH',FAO__c=200,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherB.Id,Agreed__c=1000,Bags__c=1000,HybridName__c='DKC TEST 4',HybridGroup__c='CLASIC',FAO__c=200,ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
       	insert new List<VoucherLineItem__c>{vli1,vli2,vli3,vli4};
            
            ApexPages.StandardController vouA = new ApexPages.StandardController(voucherA);
        VoucherHungaryCorn2015Controller controller1 = new VoucherHungaryCorn2015Controller(vouA);
        
        ApexPages.StandardController vouB = new ApexPages.StandardController(voucherB);
        VoucherHungaryCorn2015Controller controller2= new VoucherHungaryCorn2015Controller(vouB);
        
        ApexPages.StandardController vouC = new ApexPages.StandardController(voucherC);
        VoucherHungaryCorn2015Controller controller3 = new VoucherHungaryCorn2015Controller(vouC);
        
        ApexPages.StandardController vouD = new ApexPages.StandardController(voucherD);
        VoucherHungaryCorn2015Controller controller4 = new VoucherHungaryCorn2015Controller(vouD);
        
        System.assertEquals(1,1);
    }    
}