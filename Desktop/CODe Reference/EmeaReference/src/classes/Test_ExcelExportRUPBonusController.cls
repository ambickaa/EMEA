@isTest
private class Test_ExcelExportRUPBonusController {

    @isTest
    static void Test_ExcelExportRUPBonus() {
        
        UserRole user1Role = [select PortalType,PortalAccountId from UserRole where DeveloperName =: 'Germany' limit 1];
        UserRole user2Role= [select PortalType,PortalAccountId from UserRole where DeveloperName =: 'CP_Sales_Representative_DE' limit 1];
        Profile user1Profile = [select Id,Name from Profile where Name =: 'DE_CRM Responsible CP' limit 1];
        Profile user2Profile = [select Id,Name from Profile where Name =: 'DE_Sales Representative CP' limit 1];
        User user1 =  new User(StandardDivision__c='CP',CountryISOCode__c='DE',Country='Germany',Alias='USER1',Email='user1@test.com',EmailEncodingKey='UTF-8',LastName='User1',ProfileId=user1Profile.Id,UserRoleID=user1Role.ID,UserName='user1@test.first.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles');
        User user2 =  new User(StandardDivision__c='CP',CountryISOCode__c='DE',Country='Germany',Alias='USER2',Email='user2@test.com',EmailEncodingKey='UTF-8',LastName='User2',ProfileId=user2Profile.Id,UserRoleID=user2Role.ID,UserName='user2@test.second.com',ManagerID=user1.Id,LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles');
        insert new List<User>{user1,user2};
        
        System.runAs(user2) {
            
            Test.startTest();
            
            PageReference pageRef = Page.ExcelExportRUPBonus;
            Test.setCurrentPage(pageRef);
        
            Year__c PY = new Year__c(Name='2016',Current_Year__c=false,YearEndDate__c=date.newinstance(2016,12,31),YearStartDate__c=date.newinstance(2016,1,1));
            Year__c CY = new Year__c(Name='2017',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2017,1,1));
            insert new List<Year__c>{PY,CY};
                
            Division__c division1 = new Division__c(Name='Roundup');
            insert division1;
                
            Country__c country = new Country__c(Name='Germany');
            insert country;
                
            RecordType SaC = [select Id from RecordType where SobjectType='ProductCatalog__c' and DeveloperName='SalesProductCatalog'];
            ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country.Id,RecordTypeId=SaC.Id);
            insert SalesProductCatalog;
            
            Campaign previoCampaign = new Campaign(YearV2__c=PY.Id,CountryRef__c=country.Id,OwnerId=user2.Id,StartDate=PY.YearStartDate__c,EndDate=PY.YearEndDate__c,Statuscode__c=300,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);
            Campaign activeCampaign = new Campaign(YearV2__c=CY.Id,CountryRef__c=country.Id,OwnerId=user2.Id,StartDate=CY.YearStartDate__c,EndDate=CY.YearEndDate__c,Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,DivisionRef__c=division1.Id);              
            insert new List<Campaign>{previoCampaign,activeCampaign};
            
            Account account1 = new Account(CountryRef__c=country.Id,Name='Test Account 1',City__c='Test City',StateProvince__c='Test State/Province',DE_ID_Status__c = 'Wiederverkäufer Ost',CornTotalSalesPY__c=10,NUM_AGREED_CORN_CHARGED_CY__c=140,CornTotalAcreagesCY__c=140,DE_CP_AGREED_RUP_CY__c=50);
            Account account2 = new Account(CountryRef__c=country.Id,Name='Test Account 2',City__c='Test City',StateProvince__c='Test State/Province',DE_ID_Status__c = 'Großhandels-Niederlassung',CornTotalSalesPY__c=10,NUM_AGREED_CORN_CHARGED_CY__c=25,CornTotalAcreagesCY__c=50,DE_CP_AGREED_RUP_CY__c=null);
            insert new List<Account>{account1,account2};
            
            Contact contact1 = new Contact(FirstName='Contact',LastName='forTest',Salutation='Mr.',MobilePhone='987002765',Phone=null,Decision_Maker__c=true,AccountId=account1.Id);
            Contact contact2 = new Contact(FirstName='Contact',LastName='forTest',Salutation='Dr.',MobilePhone=null,Phone=null,Decision_Maker__c=true,AccountId=account2.Id);
            insert new List<Contact>{contact1,contact2};
            
            VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(YearRef__c=CY.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country.Id,EndDate__c=CY.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=CY.YearStartDate__c);
            insert voucherCampaign;
            
            Discount__c discount1 = new Discount__c(MinBags__c=0,MaxBags__c=100,DiscountInPrice__c=5,VoucherCampaignRef__c=voucherCampaign.Id);
            Discount__c discount2 = new Discount__c(MinBags__c=101,MaxBags__c=999,DiscountInPrice__c=6,VoucherCampaignRef__c=voucherCampaign.Id);
            insert new List<Discount__c>{discount1,discount2};
                
            Product2 pr1 = new Product2(Name='RUP Test',ProductSAPCode__c='11953395',NUM_UnitsPerSKU__c=15,DE_BasicUnits__c=15,DivisionRef__c=division1.id, productBagSize__c=80,ProductMaturity__c=200);
            Product2 pr2 = new Product2(Name='RUP Test',ProductSAPCode__c='11864374',NUM_UnitsPerSKU__c=5,DE_BasicUnits__c=5,DivisionRef__c=division1.id, productBagSize__c=80,ProductMaturity__c=200);
            insert new List<Product2> {pr1,pr2};
            
            ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr1.Id,OwnerId=user2.Id);
            ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=user2.Id);
            insert new List<ProductCatalogEntry__c>{pce1,pce2};
            
            CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,Forecast__c=null,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user2.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
            CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=0,Agreed__c=50,Forecast__c=50,ProductCatalogEntryRef__c=pce2.Id,OwnerId=user2.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
            CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=null,Agreed__c=null,Forecast__c=100,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user2.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
            CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=50,Forecast__c=0,ProductCatalogEntryRef__c=pce2.Id,OwnerId=user2.Id,FarmRef__c=account1.Id,CampaignRef__c=activeCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
            insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4};
            
            Util.setCurrentAccount(account1.Id);
            ApexPages.currentPage().getParameters().put('Id', account1.Id);
            ApexPages.currentPage().getParameters().put('division', division1.Id);
            ExcelExportRUPBonusController controller1 = new ExcelExportRUPBonusController();
            //controller = new ExcelExportRUPBonusController();
            
            Util.setCurrentAccount(account2.Id);
            ApexPages.currentPage().getParameters().put('Id', account2.Id);
            ApexPages.currentPage().getParameters().put('division', division1.Id);
            ExcelExportRUPBonusController controller2 = new ExcelExportRUPBonusController();
            
            Test.StopTest();

        }
        
    }
}