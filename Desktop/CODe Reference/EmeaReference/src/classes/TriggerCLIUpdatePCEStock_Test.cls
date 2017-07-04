@isTest
private class TriggerCLIUpdatePCEStock_Test {
    
    private static void Test_Ini() {
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id = : UserInfo.getUserId()];
        currentUser.Country = 'Spain';
        update currentUser;
        
        Year__c PY = new Year__c(Name='2015', YearStartDate__c=date.newinstance(2014,11,1), YearEndDate__c=date.newinstance(2015,10,31), Current_Year__c=false);
        insert PY;
        
        Year__c CY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2015,11,1), YearEndDate__c=date.newinstance(2999,10,31), Current_Year__c=true, YearPreviousYear__c=PY.Id);
        insert CY;
        
        Division__c Corn = new Division__c(Name='Corn');
        insert Corn;
            
        Country__c Test_Country = new Country__c(Name='Spain');
        insert Test_Country;
        
        ProductCatalog__c Test_Country_Corn_Sales_2016 = new ProductCatalog__c(Name='Spain - Corn - Sales - 2016', CountryRef__c=Test_Country.Id, DivisionRef__c=Corn.Id, YearRef__c=CY.Id, RecordTypeId=Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'));
        insert Test_Country_Corn_Sales_2016;
        
        Campaign CampaignPY = new Campaign(YearV2__c=PY.Id, CountryRef__c=Test_Country.Id, OwnerId=currentUser.Id, StartDate=PY.YearStartDate__c, EndDate=PY.YearEndDate__c, Statuscode__c=300, SalesPCMRef__c=Test_Country_Corn_Sales_2016.Id, DivisionRef__c=Corn.Id);
        Campaign CampaignCY = new Campaign(YearV2__c=CY.Id, CountryRef__c=Test_Country.Id, OwnerId=currentUser.Id, StartDate=CY.YearStartDate__c, EndDate=CY.YearEndDate__c, Statuscode__c=200, SalesPCMRef__c=Test_Country_Corn_Sales_2016.Id, DivisionRef__c=Corn.Id);              
        insert new List<Campaign>{CampaignPY, CampaignCY};
        
        Account Account1 = new Account(CountryRef__c=Test_Country.Id, Name='Monsanto');
        insert Account1;
        
        Product2 pr1 = new Product2(Name='TEST', Description='DKC', ProductSAPCode__c='12123213', DivisionRef__c=Corn.Id, productBagSize__c=80, ProductMaturity__c=200, ProductVendor__c=Account1.Id);
        insert pr1;
        
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=Test_Country_Corn_Sales_2016.Id, OwnerId=currentUser.Id, ProductRef__c=pr1.Id, Allocation__c=200);
        insert pce1;
        
        CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Type__c='Charged');
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), PoG__c=100, Agreed__c=50, ProductCatalogEntryRef__c=pce1.Id, OwnerId=currentUser.Id, FarmRef__c=Account1.Id, CampaignRef__c=CampaignCY.Id, PlantingDensity__c='30000', ProductRef__c=pr1.Id, Type__c='Free of charge');
        insert new List<CampaignLineItem__c>{cli1, cli2};
        
        cli1.POG__c=150;
        update cli1;
        
        delete cli2;

    }

    static testMethod void DML_actions() {
        
        Test.StartTest();
        
        Test_Ini();
        
        Test.StopTest();
    }
}