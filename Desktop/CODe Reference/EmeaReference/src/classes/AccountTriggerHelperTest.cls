@isTest
/**
* Performs tests pn AccountTriggerHelper 
*/
private class AccountTriggerHelperTest
{
    /**
    * Tests summarizing fields on Account from CLI.
    *
    * CornTotalSalesCY__c - sum of all POG__c from CLI Corn current Campaign.
    * OSRTotalSalesCY__c - sum of all POG__c from CLI OSR current Campaign.
    * CPTotalSalesCY__c - sum of all POG__c from CLI CP current Campaign.
    * CornTotalSalesPY__c - sum of all POG__c from CLI Corn previous Campaign.
    * OSRTotalSalesPY__c - sum of all POG__c from CLI OSR previous Campaign.
    * CPTotalSalesPY__c - sum of all POG__c from CLI CP previous Campaign. 
    *
    */
    static void testCLISummary()
    {
        //Create CY and PY
        Year__c PY = new Year__c(Name='2016', YearStartDate__c=date.newinstance(2016,11,1), YearEndDate__c=date.newinstance(2016,10,31), Current_Year__c=false);
        insert PY;
        Year__c year = new Year__c(Name='2017',Current_Year__c=true,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2017,1,1),YearPreviousYear__c=PY.Id);
        insert year;

        //Search for Record Types
        List<Id> recordTypeIDs = new List<Id>();
        recordTypeIDs.add(Util.recordType.get('ProductCatalog__c:SalesProductCatalog'));
        recordTypeIDs.add(Util.recordType.get('Product2:CornSalesProduct'));
        recordTypeIDs.add(Util.recordType.get('CampaignLineItem__c:Sales'));
        recordTypeIDs.add(Util.recordType.get('Acreage__c:AcreagesPerProductGroup'));


        //Create 3 divisions
        List<Division__c> CampaignDivision = new List<Division__c>();
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_CORN));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_OSR));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_LATITUDE));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_MONITOR));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_ROUNDUP));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_MONFAST));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_ACTIMUM));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_GUARDIAN));
        CampaignDivision.add(testInit.getDivision(Util.DIVISION_HARNESS));

        List<Country__c> countryList = testInit.countries;
        Country__c testCountry = [SELECT Id FROM Country__c WHERE Name = 'Germany'];
        testCountry.LKP_CurrentYear__c = year.Id;
        update testCountry;
        
        //Create Farm account.
        Account anAccount = TestInit.createNewFarmer();
        anAccount.CountryRef__c = testCountry.Id;

        //Create German Account
        Account aDEAccount = new Account (Name = 'German Account');
        aDEAccount.CountryRef__c = testCountry.Id;

        //Create Distributor Accounts
        Account aDistAccount = TestInit.createNewDistributor();
        aDistAccount.CountryRef__c = testCountry.Id;
        Account aDistAccountDE = TestInit.createNewDistributor();
        aDistAccount.CountryRef__c = testCountry.Id;

        //Create Distributor Account
        Account aCompAccount = TestInit.createNewCompetitor();
        aCompAccount.CountryRef__c = testCountry.Id;
        insert new List <Account> {anAccount, aDEAccount, aDistAccount, aDistAccountDE, aCompAccount};

        //Create Product Catalogues
        List<ProductCatalog__c> CatalogToInsert = new List<ProductCatalog__c>();
        CatalogToInsert.add(new ProductCatalog__c(Name='Product Catalog',CountryRef__c=testCountry.Id, RecordTypeId=recordTypeIDs.get(0), YearRef__c = year.Id));
        CatalogToInsert.add(new ProductCatalog__c(Name='Product Catalog',CountryRef__c=testCountry.Id, RecordTypeId=recordTypeIDs.get(0), YearRef__c = PY.Id));
        insert CatalogToInsert;

        //Create 2 products
        List<Product2> ProdToInsert = new List<Product2>();
        ProdToInsert.add(new Product2 (Name = 'Product1', ProductSAPCode__c='12123213', RecordTypeId = recordTypeIDs.get(1), ProductVendor__c = aDistAccount.Id, ProductBagSize__c = 80));
        ProdToInsert.add(new Product2 (Name = 'Product2', ProductSAPCode__c='12444444', RecordTypeId = recordTypeIDs.get(1), ProductVendor__c = aCompAccount.Id, ProductBagSize__c = 80));
        ProdToInsert.add(new Product2 (Name = 'Product3', ProductSAPCode__c='13333333',RecordTypeId = recordTypeIDs.get(1), ProductVendor__c = aDistAccountDE.Id, ProductBagSize__c = 80, DE_RelFactor__c = 1, NUM_UnitsPerSKU__c = 2));
        ProdToInsert.add(new Product2 (Name = 'Product3', ProductSAPCode__c='14444444',RecordTypeId = recordTypeIDs.get(1), ProductVendor__c = aCompAccount.Id, ProductBagSize__c = 80));
        insert ProdToInsert;

        //Create PCEs
        List<ProductCatalogEntry__c> PCEToInsert = new List<ProductCatalogEntry__c>();
        PCEToInsert.add(new ProductCatalogEntry__c (ProductRef__c = ProdToInsert.get(0).Id, ProductCatalogRef__c = CatalogToInsert.get(0).Id, isFOCallowed__c=true));
        PCEToInsert.add(new ProductCatalogEntry__c (ProductRef__c = ProdToInsert.get(0).Id, ProductCatalogRef__c = CatalogToInsert.get(1).Id, isFOCallowed__c=true));
        PCEToInsert.add(new ProductCatalogEntry__c (ProductRef__c = ProdToInsert.get(1).Id, ProductCatalogRef__c = CatalogToInsert.get(0).Id, isFOCallowed__c=true));
        PCEToInsert.add(new ProductCatalogEntry__c (ProductRef__c = ProdToInsert.get(1).Id, ProductCatalogRef__c = CatalogToInsert.get(1).Id, isFOCallowed__c=true));
        PCEToInsert.add(new ProductCatalogEntry__c (ProductRef__c = ProdToInsert.get(3).Id, ProductCatalogRef__c = CatalogToInsert.get(0).Id, isFOCallowed__c=true));
        PCEToInsert.add(new ProductCatalogEntry__c (ProductRef__c = ProdToInsert.get(3).Id, ProductCatalogRef__c = CatalogToInsert.get(1).Id, isFOCallowed__c=true));
        insert PCEToInsert;

        //Create Product Groupings
        Product_Grouping__c CornGroup = new Product_Grouping__c(Name='Corn');
        insert CornGroup;
        Product_Grouping__c Silage = new Product_Grouping__c(Name='Greenland', ProductGroupRef__c=CornGroup.Id);
        Product_Grouping__c Grain = new Product_Grouping__c(Name='Corn', ProductGroupRef__c=CornGroup.Id);
        insert new List<Product_Grouping__c> {Silage, Grain};

        //Create 4 Campaigns
        List<Campaign> CampToInsert = new List<Campaign>();
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Corn Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(0).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Corn Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(0).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'OSR Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(1).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'OSR Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(1).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));

        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Lat Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(2).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Lat Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(2).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));

        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Mon Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(3).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Mon Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(3).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));

        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(4).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(4).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));

        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(5).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(5).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));

        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(6).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(6).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));

        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(7).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(7).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));

        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Camp', StatusCode__c = 200, DivisionRef__c = CampaignDivision.get(8).Id, YearV2__c = year.Id,
            StartDate = System.today(), EndDate = System.today().addYears(1), SalesPCMRef__c = CatalogToInsert.get(0).Id, CountryRef__c=testCountry.Id));
        CampToInsert.add(new Campaign (OwnerId = Util.currentUser.Id, Name = 'Rou Prev Camp', StatusCode__c = 300, DivisionRef__c = CampaignDivision.get(8).Id, YearV2__c = PY.Id,
            StartDate = System.today().addYears(-1), EndDate = System.today(), SalesPCMRef__c = CatalogToInsert.get(1).Id, CountryRef__c=testCountry.Id));
        insert CampToInsert;
                  
        //Create Campaign Line Items and test them.
        
        List<CampaignLineItem__c> CLItoInsert = new List<CampaignLineItem__c>();
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(0).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2),
            FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(0).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Free of Charge', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2),
            FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(1).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2),
            FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(1).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Free of Charge', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2),
            FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(0).Id, ProductRef__c = ProdToInsert.get(3).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Free of Charge', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(4).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2),
            FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(1).Id, ProductRef__c = ProdToInsert.get(3).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(5).Id, Status__c = 'Confirmed'));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(2).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id, Status__c = 'Confirmed'));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'), FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(2).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Free of Charge', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(3).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2),
            FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(2).Id, ProductRef__c = ProdToInsert.get(3).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(5).Id, Status__c = 'Confirmed'));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(3).Id, ProductRef__c = ProdToInsert.get(3).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(4).Id, Status__c = 'Confirmed'));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = anAccount.Id, CampaignRef__c = CampToInsert.get(3).Id, ProductRef__c = ProdToInsert.get(0).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Free of Charge', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(4).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(5).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(6).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(7).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(8).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(9).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(10).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(11).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(12).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(13).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(14).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(15).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));

        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(16).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(0).Id));
        CLItoInsert.add(new CampaignLineItem__c (OwnerId = Util.currentUser.Id, RecordTypeId = recordTypeIDs.get(2), FarmRef__c = aDEAccount.Id, CampaignRef__c = CampToInsert.get(17).Id, ProductRef__c = ProdToInsert.get(2).Id, Forecast__c = 10, Agreed__c = 12, POG__c = 15, Type__c = 'Charged', PlantingDensity__c = '70000', ProductCatalogEntryRef__c = PCEToInsert.get(1).Id));
        insert CLItoInsert;

        Test.startTest();

        //Create Acreages and test them.
        List<Acreage__c> AcrToInsert = new List<Acreage__c>();
        AcrToInsert.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=year.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aDistAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_CORN), AcrProductTypeRef__c=Silage.Id));
        AcrToInsert.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=year.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aDistAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_OSR), AcrProductTypeRef__c=Silage.Id));
        AcrToInsert.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=year.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aCompAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_WINTER_WHEAT), AcrProductTypeRef__c=Silage.Id));
        AcrToInsert.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=year.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aCompAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS), AcrProductTypeRef__c=Silage.Id));
        insert AcrToInsert;

        //Insert PY Acreages and test them
        List<Acreage__c> AcrToInsertPY = new List<Acreage__c>();
        AcrToInsertPY.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=PY.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aDistAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_CORN), AcrProductTypeRef__c=Silage.Id));
        AcrToInsertPY.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=PY.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aDistAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_OSR), AcrProductTypeRef__c=Silage.Id));
        AcrToInsertPY.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=PY.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aCompAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_WINTER_WHEAT), AcrProductTypeRef__c=Silage.Id));
        AcrToInsertPY.add(new Acreage__c (RecordTypeId=recordTypeIDs.get(3), AcrYearRef__c=PY.Id,AcrTotalAcreages__c = 20, AcrFarmRef__c = anAccount.Id, AcrProviderRef__c = aCompAccount.Id, AcrProductGroupRef__c=Util.getProductGroup(Util.PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS), AcrProductTypeRef__c=Silage.Id));
        insert AcrToInsertPY;

        
        Account aTestAccount = getAccount(anAccount.Id);
        aTestAccount = getAccount(anAccount.Id);
        Test.stopTest();
    }
    
    private static Account getAccount(Id theAccID)
    {
        return (Account)Database.query(new al.SoqlBuilder().selectx(new List<String>{'Id', 'CornTotalSalesCY__c', 'OSRTotalSalesCY__c',
                      'CPTotalSalesCY__c', 'CornTotalSalesPY__c', 'OSRTotalSalesPY__c', 'CPTotalSalesPY__c'})
                      .fromx('Account').wherex(new al.FieldCondition('Id', theAccID)).toSOQL()).get(0);
    }
    
  static testMethod void testingHelper() {
      
    testCLISummary();

    }
}