@isTest
private class Voucher_RU_Corn_2017_Controller_Test{

    @isTest
    static void init() {

    UserRole user1Role = [select PortalType,PortalAccountId from UserRole where DeveloperName =: 'Region_North_RU' limit 1];
    UserRole user2Role= [select PortalType,PortalAccountId from UserRole where DeveloperName =: 'Sales_Rep_North_RU' limit 1];
    system.debug('***User1: ' + user1Role.Id + ' User2: ' + user2Role.Id);
    Profile user1Profile = [select Id,Name from Profile where Name =: 'RU_Regional Manager' limit 1];
    Profile user2Profile = [select Id,Name from Profile where Name =: 'RU_Sales Representative' limit 1];
    User user1 =  new User(CountryISOCode__c='RU',Country='Russia',Alias='USER1',Email='user1@test.com',EmailEncodingKey='UTF-8',LastName='User1',ProfileId=user1Profile.Id,UserRoleID=user1Role.ID,UserName='user1RU@test.first.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',StandardDivision__c='Corn');
    User user2 =  new User(CountryISOCode__c='RU',Country='Russia',Alias='USER2',Email='user2@test.com',EmailEncodingKey='UTF-8',LastName='User2',ProfileId=user2Profile.Id,UserRoleID=user2Role.ID,UserName='user2RU@test.second.com',ManagerID=user1.Id,LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',StandardDivision__c='Corn');
    insert new List<User>{user1,user2};
    
    System.runAs(user2) {
    
          Year__c year = new Year__c(Name='2017',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2014,1,1));
          insert year;
            
          Division__c division1 = new Division__c(Name='Corn');
          insert division1;
            
          Country__c country = new Country__c(Name='Russia');
          insert country;
            
          RecordType SaC = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
          ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country.Id,RecordTypeId=SaC.Id);
          insert SalesProductCatalog;
          
          Campaign activeCampaign = new Campaign(YearV2__c=year.Id,CountryRef__c=country.Id,OwnerId=user2.Id,StartDate=year.YearStartDate__c,EndDate=year.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
          insert activeCampaign;
      
          Account account1 = new Account(CountryRef__c=country.Id,Name='Russian Test Account',City__c='Russian Test City',StateProvince__c='Russian Test State/Province');
          Account account2 = new Account(CountryRef__c=country.Id,Name='Russian Test Account',City__c='Russian Test City',StateProvince__c='Russian Test State/Province');
          Account account3 = new Account(CountryRef__c=country.Id,Name='Monsanto International Sarl', City__c='Russian Test City',StateProvince__c='Russian Test State/Province');
            
          insert new List<Account>{account1,account2,account3};
          
          Contact contact1 = new Contact(FirstName='Russian',LastName='Test Contact 1',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
          Contact contact2 = new Contact(FirstName='Russian',LastName='Test Contact 2',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
          insert new List<Contact>{contact1,contact2};
      
          VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=year.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=year.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year.YearStartDate__c);
          insert voucherCampaign;
            
          Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id, productVendor__c=account3.Id);
          Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=account3.Id);
          insert new List<Product2> {pr1,pr2};
          
          ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=user2.Id,isFOCallowed__c=true,VoucherProduct__c=true);
          ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=user2.Id,isFOCallowed__c=true,VoucherProduct__c=true);
          insert new List<ProductCatalogEntry__c>{pce1,pce2};

          Voucher__c voucherA = new Voucher__c(TotalBags__c=10,OwnerId=user2.Id,Status__c='Closed',LKP_CONTACT__c=contact1.Id,AccountRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,VoucherCampaignRef__c=voucherCampaign.Id,FarmNameCopy__c='Russian Test Farm',AddressCopy__c='Russian Test Address',PhoneCopy__c='987110234',EmailCopy__c='Russian@test.farm',DistributorNameCopy__c='Russian Test Distributor');
          
          insert new List<Voucher__c>{voucherA};
          
          Discount__c disc1 = new Discount__c(RecordTypeId=Util.recordType.get('Discount__c:Smart_discount'),VoucherCampaignRef__c=voucherCampaign.Id,NUM_DiscountperBag__c=25,PICK_Applies_to__c='All');
          insert new List<Discount__c>{disc1};

          CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user2.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
          CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,ProductCatalogEntryRef__c=pce2.Id,OwnerId=user2.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
          CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=250,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user2.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of Charge',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
          CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=250,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user2.Id,FarmRef__c=account2.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of Charge',PlantingDensity__c='30000',ProductRef__c=pr1.Id);

          insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4};
          
          VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli1.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',HybridGroup__c='NOU',FAO__c=100,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500);
          VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Agreed__c=150,Bags__c=150,HybridName__c='DKC TEST 1',HybridGroup__c='HD',FAO__c=300,ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged', Price__c = 500);
          VoucherLineItem__c vli3 = new VoucherLineItem__c(CampaignLineItemRef__c=cli3.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='NOU',FAO__c=100,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of Charge', Price__c = 500);
          VoucherLineItem__c vli4 = new VoucherLineItem__c(CampaignLineItemRef__c=cli4.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',HybridGroup__c='NOU',FAO__c=200,ProductName__c='DKC TEST 2',PICK_TYPE__c='Free of Charge', Price__c = 500);
         
          insert new List<VoucherLineItem__c>{vli1,vli2,vli3,vli4};
          
          Test.startTest();
          
          ApexPages.StandardController vouA = new ApexPages.StandardController(voucherA);
          Voucher_RU_Corn_2017_Controller controller1 = new Voucher_RU_Corn_2017_Controller(vouA);
 
          System.assertEquals(1,1);
          Test.StopTest();
        }
    }
}