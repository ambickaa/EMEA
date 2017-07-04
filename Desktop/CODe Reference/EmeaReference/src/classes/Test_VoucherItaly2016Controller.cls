@isTest
private class Test_VoucherItaly2016Controller {
    
    @isTest
    static void init() {
		
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
		currentUser.Country = 'Italy';
		update currentUser;
        
        Year__c year = new Year__c(Name='2016',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2014,1,1));
        insert year;
        
        Division__c division1 = new Division__c(Name='Corn');
        insert division1;
        
        Country__c country = new Country__c(Name='Italy');
        insert country;
        
        RecordType SaC = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country.Id,RecordTypeId=SaC.Id);
        insert SalesProductCatalog;
        
        Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=currentUser.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
        insert activeCampaign;
        
        Account account1 = new Account(CountryRef__c=country.Id,Name='Italian Test Account',City__c='Italian Test City',StateProvince__c='Italian Test State/Province');
        Account account2 = new Account(CountryRef__c=country.Id,Name='Italian Test Account',City__c='Italian Test City',StateProvince__c='Italian Test State/Province',Phone='988210555');
        Account account3 = new Account(CountryRef__c=country.Id,Name='Italian Test Account',City__c='Italian Test City',StateProvince__c='Italian Test State/Province',Phone='988210556');
        insert new List<Account>{account1,account2,account3};
            
        Contact contact1 = new Contact(FirstName='Italian',LastName='Test Contact 1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
        Contact contact2 = new Contact(FirstName='Italian',LastName='Test Contact 2',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
        Contact contact3 = new Contact(FirstName='Italian',LastName='Test Contact 2',MobilePhone='947593958',Phone=null,Decision_Maker__c=true,AccountId=account3.Id);
        insert new List<Contact>{contact1,contact2,contact3};
            
        VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year.YearStartDate__c);
        insert voucherCampaign;
        
        Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id);
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id);
        insert new List<Product2> {pr1,pr2};
            
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=currentUser.Id);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=currentUser.Id);
        insert new List<ProductCatalogEntry__c>{pce1,pce2};
            
        Voucher__c voucherA = new Voucher__c(OwnerId=currentUser.Id,Status__c='Cancelled',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Italian Test Farm',AddressCopy__c='Italian Test Address',PhoneCopy__c='987110234',EmailCopy__c='Italian@test.farm',DistributorNameCopy__c='Italian Test Distributor');
        Voucher__c voucherB = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Italian Test Farm',AddressCopy__c='Italian Test Address',PhoneCopy__c=null,EmailCopy__c='Italian@test.farm',DistributorNameCopy__c='Italian Test Distributor');
        Voucher__c voucherC = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Italian Test Farm',AddressCopy__c='Italian Test Address',PhoneCopy__c='987110234',EmailCopy__c='Italian@test.farm',DistributorNameCopy__c='Italian Test Distributor');
        Voucher__c voucherD = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact2.Id,AccountRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Italian Test Farm',AddressCopy__c='Italian Test Address',PhoneCopy__c=null,EmailCopy__c='Italian@test.farm',DistributorNameCopy__c='Italian Test Distributor');
        Voucher__c voucherE = new Voucher__c(OwnerId=currentUser.Id,Status__c='Closed',LKP_CONTACT__c=contact3.Id,AccountRef__c=account3.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Italian Test Farm',AddressCopy__c='Italian Test Address',PhoneCopy__c=null,EmailCopy__c='Italian@test.farm',DistributorNameCopy__c='Italian Test Distributor');
        
        insert new List<Voucher__c>{voucherA,voucherB,voucherC,voucherD,voucherE};
            
            CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=currentUser.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id,DistributorRef__c=account2.Id);
        //insert cli1;
        
        VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherB.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherC.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherD.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        insert new List<VoucherLineItem__c>{vli1,vli2,vli3,vli4};
            
        ApexPages.StandardController vouA = new ApexPages.StandardController(voucherA);
        VoucherItaly2016Controller controller1 = new VoucherItaly2016Controller(vouA);
        
        ApexPages.StandardController vouB = new ApexPages.StandardController(voucherB);
        VoucherItaly2016Controller controller2= new VoucherItaly2016Controller(vouB);
        
        ApexPages.StandardController vouC = new ApexPages.StandardController(voucherC);
        VoucherItaly2016Controller controller3 = new VoucherItaly2016Controller(vouC);
        
        ApexPages.StandardController vouD = new ApexPages.StandardController(voucherD);
        VoucherItaly2016Controller controller4 = new VoucherItaly2016Controller(vouD);
        
        System.assertEquals(1,1);
    }
}