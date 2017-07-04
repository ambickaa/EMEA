@isTest
private class AccountActionPlan_Controller_Test {

// Test - Initial definition of variables
    public static Division__c Test_Division;
    public static Account Test_Account_Farm;
    public static Account Test_Account_Dist;
    public static Account Test_Account_Comp;
    public static Campaign Test_Previous_Campaign;
    public static Campaign Test_Current_Campaign;
    public static Product2 Test_Product_1;
    public static Product2 Test_Product_2;
    public static ProductCatalogEntry__c Test_PCE;
    public static List<Account> List_Accounts;
    public static List<Country__c> List_Countries;
    public static List<CampaignLineItem__c> List_CampaignLineItems;

    private static void Test_Ini(){
        
    // Test - Setting previous & current years
        TestInit.setYear(1);
        
    // Test - Including some countries
        List_Countries = new List<Country__c>();
        List_Countries.add(TestInit.getCountryByName('France'));
        List_Countries.add(testInit.getCountryByName('United Kingdom'));
        
    // Test - Setting current division (for example, OSR)
        Test_Division = TestInit.getDivision(Util.DIVISION_OSR);

    // Test - Including some accounts
        List_Accounts = new List<Account>();
        // Test - Farm
        Test_Account_Farm = TestInit.createNewFarmer();
        Test_Account_Farm.CountryID__c = List_Countries[0].Id;
        Test_Account_Farm.CountryRef__c = List_Countries[0].Id;
        List_Accounts.add(Test_Account_Farm);
        // Test - Distributor
        Test_Account_Dist = TestInit.createNewDistributor();
        Test_Account_Dist.CountryID__c = List_Countries[0].Id;
        List_Accounts.add(Test_Account_Dist);
        // Test - Competitor
        Test_Account_Comp = TestInit.createNewCompetitor();
        List_Accounts.add(Test_Account_Comp);
        
        insert List_Accounts;

    // Test - Including some products
        Test_Product_1 = TestInit.products[0];
        Test_Product_2 = TestInit.products[1];
        Test_Product_2.ProductVendor__c = List_Accounts[2].Id;
        
        insert new List<Product2>{Test_Product_1, Test_Product_2};
        
    // Test - Including products to the Sales Product Catalog
        ProductCatalog__c Test_Sales_Catalog = TestInit.productCatalogs.get('ProductCatalog__c:SalesProductCatalog');
        Test_Sales_Catalog.YearRef__c = Util.currentYear.Id;
        Test_Sales_Catalog.DivisionRef__c = Test_Division.Id;
        Test_Sales_Catalog.OwnerId = Test_Account_Farm.OwnerId;
        Test_Sales_Catalog.CountryID__c = List_Countries[0].Id;
        Test_Sales_Catalog.CountryRef__c = Test_Account_Farm.CountryRef__c;

        update Test_Sales_Catalog;

    // Test - Setting previous & current campaigns parameters
        Map<String, Object> Test_Previous_Campaign_prm = new Map<String, Object>
        {
            'CountryRef__c' => Test_Account_Farm.CountryRef__c,
            'OwnerId' => Test_Account_Farm.OwnerId,
            'DivisionRef__c' => Test_Division.Id,
            'YearV2__c' => Util.lastYear.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today(),
            'ArchiveDate__c' => Date.today().addDays(30)
        };
        Map<String, Object> Test_Current_Campaign_prm = new Map<String, Object>
        {
            'CountryRef__c' => Test_Account_Farm.CountryRef__c,
            'OwnerId' => Test_Account_Farm.OwnerId,
            'DivisionRef__c' => Test_Division.Id,
            'YearV2__c' => Util.currentYear.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(30),
            'ArchiveDate__c' => Date.today().addDays(60),
            'SalesPCMRef__c' => Test_Sales_Catalog.Id
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
        List_CampaignLineItems = new List<CampaignLineItem__c>();
        
        List_CampaignLineItems.add (new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Previous_Campaign.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Free of charge'
            )
        );
        List_CampaignLineItems.add(new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Previous_Campaign.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Charged',
            POG__c = 1
            )
        );
        List_CampaignLineItems.add (new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Current_Campaign.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.id,
            Type__c = 'Charged'         
            )
        );
        List_CampaignLineItems.add(new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Current_Campaign.Id,
            ProductRef__c = Test_Product_2.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Charged'
            )
        );
        
        insert List_CampaignLineItems;

    // Test - Setting Product Catalog parameters
        Map<String, Object> Test_Sales_Catalog_prm = new Map<String, Object>
        {
            'ProductRef__c' => Test_Product_1.Id,
            'ProductCatalogRef__c' => Test_Sales_Catalog.Id
        };

    // Test - Including a Product Catalog Entry
        Test_PCE = (ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', Test_Sales_Catalog_prm);
        insert Test_PCE;

    }
    static testMethod void Test_Farm() {
        
        Test_Ini();
        
        // Test - Start
        Test.StartTest();
        Test.setCurrentPage(Page.AccountViewFR);
        
        Account Test_Farm = List_Accounts[0];
        Apexpages.currentPage().getParameters().put('id', Test_Farm.Id);
        Apexpages.currentPage().getParameters().put('division', Test_Division.id); 
        Util.currentCampaign = Test_Current_Campaign;
        Util.previewsCampaign = Test_Previous_Campaign;

        AccountActionPlan_Controller Test_Controller = new AccountActionPlan_Controller();
        
        system.debug('+++ isMarketingUser: ' + Test_Controller.isMarketingUser);

        String Rows_Insert = Test_Product_1.Id + '=' + Test_PCE.Id;
        Test_Controller.setRows(Rows_insert);
        Test_Controller.getRows();
        Test_Controller.newAPLines();
        Test_Controller.setAPSectionTmpRendered(true);
        Test_Controller.getAPSectionTmpRendered();
        Test_Controller.setAction('Insert');
        Test_Controller.getAction();
        Test_Controller.doSave();
        Test_Controller.reRenderSection();
        
        String Rows_Update = List_CampaignLineItems[2].Id;
        Test_Controller.setRows(Rows_Update);
        Test_Controller.editAPLines();
        Test_Controller.setAPSectionTmpRendered(true);
        Test_Controller.setAction('Edit');
        Test_Controller.doSave();
        
        String Rows_Delete = List_CampaignLineItems[2].Id;
        Test_Controller.setRows(Rows_Delete);
        Test_Controller.deleteAPLines();
        Test_Controller.setAPSectionTmpRendered(true);
        Test_Controller.setAction('Delete');
        Test_Controller.doSave();
        
        system.debug('+++ Testing Voucher Controller');
        AccountListOfVouchersController VouchersController = new AccountListOfVouchersController();
        List<Voucher__c> VouchersModule = VouchersController.vouchers;
        
        Test.StopTest();
        // Test - End
    }

}