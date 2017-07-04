@isTest
private class AccountPageGiveAwaysController_Test {

// Test - Initial definition of variables
    public static Division__c Test_Division_OSR;
    public static Division__c Test_Division_CORN;
    public static List<Country__c> List_Test_Countries;
    public static List<Account> List_Test_Accounts;
    public static Account Test_Account_Farm;
    public static Account Test_Account_Dist;
    public static Account Test_Account_Comp;
    public static Campaign Test_Previous_Campaign;
    public static Campaign Test_Current_Campaign;
    public static Product2 Test_Product_1;
    public static Product2 Test_Product_2;
    public static ProductCatalogEntry__c Test_PCE_1;
    public static List<CampaignLineItem__c> List_Test_CLIs;
    
    private static void Ini() {
    
    // Test - Setting previous & current years
        TestInit.setYear(1);
        
    // Test - Including some countries
        List_Test_Countries = new List<Country__c>();
        List_Test_Countries.add(TestInit.getCountryByName('Italy'));

    // Test - Setting different divisions
        Test_Division_OSR = TestInit.getDivision(Util.DIVISION_OSR);
        Test_Division_CORN = TestInit.getDivision(Util.DIVISION_CORN);

    // Test - Including some accounts
        List_Test_Accounts = new List<Account>();

        // Test - Farm
        Test_Account_Farm = TestInit.createNewFarmer();
        Test_Account_Farm.CountryID__c = List_Test_Countries[0].Id;
        Test_Account_Farm.CountryRef__c = List_Test_Countries[0].Id;
        List_Test_Accounts.add(Test_Account_Farm);

        // Test - Distributor
        Test_Account_Dist = TestInit.createNewDistributor();
        Test_Account_Dist.CountryID__c = List_Test_Countries[0].Id;
        Test_Account_Dist.CountryRef__c = List_Test_Countries[0].Id;
        List_Test_Accounts.add(Test_Account_Dist);
        
        // Test - Competitor
        Test_Account_Comp = TestInit.createNewCompetitor();
        List_Test_Accounts.add(Test_Account_Comp);
        
        insert List_Test_Accounts;

    // Test - Including some products
        Test_Product_1 = TestInit.products[0];
        Test_Product_2 = TestInit.products[1];
        Test_Product_2.ProductVendor__c = List_Test_Accounts[2].Id;
        
        insert new List<Product2>{Test_Product_1, Test_Product_2};
        
    // Test - Including products to the Sales Product Catalog
        ProductCatalog__c Test_Marketing_Catalog = TestInit.productCatalogs.get('ProductCatalog__c:MarketingProductCatalog');
        Test_Marketing_Catalog.YearRef__c = Util.currentYear.Id;
        Test_Marketing_Catalog.DivisionRef__c = Test_Division_CORN.Id;
        Test_Marketing_Catalog.OwnerId = Test_Account_Farm.OwnerId;
        Test_Marketing_Catalog.CountryID__c = List_Test_Countries[0].Id;
        Test_Marketing_Catalog.CountryRef__c = Test_Account_Farm.CountryRef__c;

        update Test_Marketing_Catalog;
        
    // Test - Setting Product Catalog parameters
        Map<String, Object> Test_Marketing_Catalog_prm = new Map<String, Object>
        {
            'ProductRef__c' => Test_Product_1.Id,
            'ProductCatalogRef__c' => Test_Marketing_Catalog.Id
        };

    // Test - Including a Product Catalog Entry
        Test_PCE_1 = (ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', Test_Marketing_Catalog_prm);
        insert Test_PCE_1;

    // Test - Setting previous & current campaigns parameters
        Map<String, Object> Test_Previous_Campaign_prm = new Map<String, Object>
        {
            'CountryRef__c' => Test_Account_Farm.CountryRef__c,
            'OwnerId' => Test_Account_Farm.OwnerId,
            'DivisionRef__c' => Test_Division_CORN.Id,
            'YearV2__c' => Util.lastYear.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today(),
            'ArchiveDate__c' => Date.today().addDays(30)
        };
        Map<String, Object> Test_Current_Campaign_prm = new Map<String, Object>
        {
            'CountryRef__c' => Test_Account_Farm.CountryRef__c,
            'OwnerId' => Test_Account_Farm.OwnerId,
            'DivisionRef__c' => Test_Division_CORN.Id,
            'YearV2__c' => Util.currentYear.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(30),
            'ArchiveDate__c' => Date.today().addDays(60),
            'SalesPCMRef__c' => Test_Marketing_Catalog.Id
        };

    // Test - Including previous & current campaigns
        List<Campaign> List_Campaigns = new List<Campaign>();
        // Test - Previous Campaign
        Test_Previous_Campaign = (Campaign)SmartFactory.createSObject('Campaign', Test_Previous_Campaign_prm);
        List_Campaigns.add(Test_Previous_Campaign);
        // Test - Current Campaign
        Test_Current_Campaign = (Campaign)SmartFactory.createSObject('Campaign', Test_Current_Campaign_prm);
        List_Campaigns.add(Test_Current_Campaign);
        
        insert List_Campaigns;

    // Test - Including sales lines in Action Plan
        List_Test_CLIs = new List<CampaignLineItem__c>();
        
        List_Test_CLIs.add (new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:GiveAway'),
            CampaignRef__c = Test_Previous_Campaign.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Free of charge'
            )
        );
        List_Test_CLIs.add(new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:GiveAway'),
            CampaignRef__c = Test_Previous_Campaign.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Charged',
            POG__c = 1
            )
        );
        List_Test_CLIs.add (new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:GiveAway'),
            CampaignRef__c = Test_Current_Campaign.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.id,
            Type__c = 'Charged'         
            )
        );
        List_Test_CLIs.add(new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:GiveAway'),
            CampaignRef__c = Test_Current_Campaign.Id,
            ProductRef__c = Test_Product_2.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Charged'
            )
        );
        
        insert List_Test_CLIs;
    }
    
    static testMethod void LoadAccountPage() {

    // Test - Calling Ini() method and starting test
        Ini();
        Test.StartTest();

    // Test - Defining Visualforce page in use
        Test.setCurrentPage(Page.AccountPage);
        
        Apexpages.currentPage().getParameters().put('division', Test_Division_CORN.Id);
        
        Apexpages.currentPage().getParameters().put('id', Test_Account_Farm.Id);
        AccountPageGiveAwaysController TestController_Farm = new AccountPageGiveAwaysController();
        
        List<Report> List_Reports = TestController_Farm.availableReports;
        List<CampaignLineItem__c> List_Records = TestController_Farm.List_Records;
        
    // Test - Methods with no records selected (no actions)
        TestController_Farm.modeAdd();
        TestController_Farm.modeNew();
        TestController_Farm.doSave();
        
        TestController_Farm.modeEdit();
        TestController_Farm.doSave();
        
        TestController_Farm.doDelete();
        
        TestController_Farm.getRows();

    // Test - Methods with records selected (actions triggered)
        TestController_Farm.modeAdd();
        
        String newId = Test_Product_1.Id + '/' + Test_PCE_1.Id;
        TestController_Farm.setRows(newId);
        
        TestController_Farm.modeNew();
        List<CampaignLineItem__c> List_Insert = TestController_Farm.List_Records;
        for(CampaignLineItem__c r : List_Insert)
        {
        
        }
        TestController_Farm.doSave();

        String recordsId = '';
        for(CampaignLineItem__c c : List_Test_CLIs)
        {
            if(recordsId == '')
                recordsId += c.Id;
            else
                recordsId += ',' + c.Id;
        }

        TestController_Farm.modeEdit();
        TestController_Farm.setRows(recordsId);
        TestController_Farm.doSave();
        
        TestController_Farm.setRows(recordsId);
        TestController_Farm.doDelete();
        
        //Util.setCurrentAccount(Test_Account_Dist.Id);
        //Apexpages.currentPage().getParameters().put('id', Test_Account_Dist.Id);
        //AccountPageGiveAwaysController TestController_Dist = new AccountPageGiveAwaysController();
        
        Test.StopTest();
    }

}