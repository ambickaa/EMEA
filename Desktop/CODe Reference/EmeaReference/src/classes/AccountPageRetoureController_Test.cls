@isTest
private class AccountPageRetoureController_Test {

    // Test - Initial definition of variables
    public static Division__c Test_Division_OSR;
    public static Division__c Test_Division_CORN;
    public static List<Country__c> List_Test_Countries;
    public static List<Account> List_Test_Accounts;
    public static Account Test_Account_Farm;
    public static Account Test_Account_Dist;
    public static Account Test_Account_Comp;
    public static Campaign Test_Current_Campaign;
    public static Campaign Test_Current_Campaign_OSR;
    public static Product2 Test_Product_1;
    public static Product2 Test_Product_2;
    public static ProductCatalogEntry__c Test_PCE_1;
    public static List<Retoure__c> List_Retoure;
    public static List<CampaignLineItem__c> List_Test_CLIs;


    private static void Ini() {
    
    // Test - Setting previous & current years
        TestInit.setYear(1);
        
    // Test - Including some countries
        List_Test_Countries = new List<Country__c>();
        List_Test_Countries.add(TestInit.getCountryByName('Germany'));

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
        ProductCatalog__c Test_Sales_Catalog = TestInit.productCatalogs.get('ProductCatalog__c:SalesProductCatalog');
        Test_Sales_Catalog.YearRef__c = Util.currentYear.Id;
        Test_Sales_Catalog.DivisionRef__c = Test_Division_CORN.Id;
        Test_Sales_Catalog.OwnerId = Test_Account_Farm.OwnerId;
        Test_Sales_Catalog.CountryID__c = List_Test_Countries[0].Id;
        Test_Sales_Catalog.CountryRef__c = Test_Account_Farm.CountryRef__c;
        
        update Test_Sales_Catalog;
        
    // Test - Setting Product Catalog parameters
        Map<String, Object> Test_Sales_Catalog_prm = new Map<String, Object>
        {
            'ProductRef__c' => Test_Product_1.Id,
            'ProductCatalogRef__c' => Test_Sales_Catalog.Id
        };

    // Test - Including a Product Catalog Entry
        Test_PCE_1 = (ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', Test_Sales_Catalog_prm);
        Test_PCE_1.CHK_ZVD__c = TRUE;
        insert Test_PCE_1;

    // Test - Setting current campaign parameters
        Map<String, Object> Test_Current_Campaign_prm = new Map<String, Object>
        {
            'CountryRef__c' => Test_Account_Farm.CountryRef__c,
            'OwnerId' => Test_Account_Farm.OwnerId,
            'DivisionRef__c' => Test_Division_CORN.Id,
            'YearV2__c' => Util.currentYear.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(30),
            'ArchiveDate__c' => Date.today().addDays(60),
            'SalesPCMRef__c' => Test_Sales_Catalog.Id
        };

        Map<String, Object> Test_Current_Campaign_prm_OSR = new Map<String, Object>
        {
            'CountryRef__c' => Test_Account_Farm.CountryRef__c,
            'OwnerId' => Test_Account_Farm.OwnerId,
            'DivisionRef__c' => Test_Division_OSR.Id,
            'YearV2__c' => Util.currentYear.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(30),
            'ArchiveDate__c' => Date.today().addDays(60),
            'SalesPCMRef__c' => Test_Sales_Catalog.Id
        };
            
            Map<String, Object> Test_Current_Campaign_name_OSR = new Map<String, Object>
        {
            'name' => 'OSR',
            'CountryRef__c' => Test_Account_Farm.CountryRef__c,
            'OwnerId' => Test_Account_Farm.OwnerId,
            'DivisionRef__c' => Test_Division_OSR.Id,
            'YearV2__c' => Util.currentYear.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(30),
            'ArchiveDate__c' => Date.today().addDays(60),
            'SalesPCMRef__c' => Test_Sales_Catalog.Id
        };

    // Test - Including retoure
        List_Retoure = new List<Retoure__c>();
        Retoure__c testRetoure = new Retoure__c();
        testRetoure.Account__c = Test_Account_Farm.Id;
        testRetoure.Division__c = Test_Division_CORN.Id;
        testRetoure.TXT_year__c = Util.currentYear.Id;
        List_Retoure.add(testRetoure);
        
        Retoure__c testRetoureOSR = new Retoure__c();
        testRetoureOSR.Account__c = Test_Account_Farm.Id;
        testRetoureOSR.Division__c = Test_Division_OSR.Id;
        testRetoureOSR.TXT_year__c = Util.currentYear.Id;
        List_Retoure.add(testRetoureOSR);

        insert List_Retoure;

        // Test - Including current campaign
        List<Campaign> List_Campaigns = new List<Campaign>();

        // Test - Current Campaigns for Corn & OSR
        Test_Current_Campaign = (Campaign)SmartFactory.createSObject('Campaign', Test_Current_Campaign_prm);
        //Test_Current_Campaign.DivisionRef__c = Test_Division_CORN.Id;
        List_Campaigns.add(Test_Current_Campaign);

        Test_Current_Campaign_OSR = (Campaign)SmartFactory.createSObject('Campaign', Test_Current_Campaign_prm_OSR);
        //Test_Current_Campaign_OSR.DivisionRef__c = Test_Division_OSR.Id;
        List_Campaigns.add(Test_Current_Campaign_OSR);

        insert List_Campaigns;

    // Test - Including sales lines in Action Plan
        List_Test_CLIs = new List<CampaignLineItem__c>();

        List_Test_CLIs.add (new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Current_Campaign.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.id,
            Type__c = 'Charged', 
            POG__c = 3
            )
        );
        List_Test_CLIs.add(new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Current_Campaign.Id,
            ProductRef__c = Test_Product_2.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Charged',
            POG__c = 5
            )
        );
        List_Test_CLIs.add (new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Current_Campaign_OSR.Id,
            ProductRef__c = Test_Product_1.Id,
            FarmRef__c = Test_Account_Farm.id,
            Type__c = 'Charged', 
            POG__c = 3        
            )
        );
        List_Test_CLIs.add(new CampaignLineItem__c (
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),
            CampaignRef__c = Test_Current_Campaign_OSR.Id,
            ProductRef__c = Test_Product_2.Id,
            FarmRef__c = Test_Account_Farm.Id,
            Type__c = 'Charged',
            POG__c = 5
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
        AccountPageRetoureController TestController_Farm = new AccountPageRetoureController();
        
        Campaign PageCampaign = TestController_Farm.currentCampaign;

        //Create Field Set
        List<Schema.FieldSetMember> fields =
        Schema.SObjectType.Retoure__c.fieldSets.getMap().get('AccountPageDE').getFields();
        fields = TestController_Farm.FieldSet_Component;
        List<Retoure__c> List_Records = TestController_Farm.List_Records;
        
    // Test - Methods with no records selected (no actions)
        TestController_Farm.doSave();
        
        TestController_Farm.modeEdit();
        TestController_Farm.doSave();
        
        TestController_Farm.cancelModes();
        
    // Test - Methods with records selected (actions triggered)
        
        String newId = Test_Product_1.Id + '/' + Test_PCE_1.Id;
        
        List<Retoure__c> List_Insert = TestController_Farm.List_Records;
        for(Retoure__c r : List_Insert)
        {
            r.TXT_Bemerkung__C = 'test';
            r.Extrarabatt__c = 2;
            r.Retoure1__c = 5;
        }

        TestController_Farm.doSave();

        String recordsId = '';

        for(Retoure__c c : List_Retoure)
        {
            if(recordsId == '')
                recordsId += c.Id;
            else
                recordsId += ',' + c.Id;
        }
        
        Util.setCurrentAccount(Test_Account_Dist.Id);
        Apexpages.currentPage().getParameters().put('id', Test_Account_Dist.Id);
        AccountPageActionPlanController TestController_Dist = new AccountPageActionPlanController();
        
        Test.StopTest();
    }
    
    static testMethod void Test() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(
            Alias = 'userTest',
            Email = 'userTest@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName='userTest',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles',
            UserName='userTest@testinguser.com',
            StandardDivision__c = 'OSR'
        );
        
        System.runAs(u){            
            List_Test_Countries = new List<Country__c>();
            
            Country__c country = new Country__c(
            	name = 'Italy',
                TXT_Country_ISO_Code__c = 'IT'
            );
            
            List_Test_Countries.add(country);
            insert List_Test_Countries;
            
            Test_Division_OSR = TestInit.getDivision(Util.DIVISION_OSR);
            
            // Test - Including some accounts
            List_Test_Accounts = new List<Account>();
            
            // Test - Distributor
            Test_Account_Dist = TestInit.createNewDistributor();
            Test_Account_Dist.CountryID__c = List_Test_Countries[0].Id;
            Test_Account_Dist.CountryRef__c = List_Test_Countries[0].Id;
            List_Test_Accounts.add(Test_Account_Dist);
            
            // Test - Farm
            Test_Account_Farm = TestInit.createNewFarmer();
            Test_Account_Farm.CountryID__c = List_Test_Countries[0].Id;
            Test_Account_Farm.CountryRef__c = List_Test_Countries[0].Id;
            List_Test_Accounts.add(Test_Account_Farm);
            
            insert List_Test_Accounts;

            // Test - Setting different divisions
            Test_Division_OSR = TestInit.getDivision(Util.DIVISION_OSR);
                     
            List_Retoure = new List<Retoure__c>();
            Retoure__c testRetoureOSR = new Retoure__c();
            testRetoureOSR.Account__c = Test_Account_Farm.Id;
            testRetoureOSR.Division__c = Test_Division_OSR.Id;
            testRetoureOSR.TXT_year__c = Util.currentYear.Id;
            List_Retoure.add(testRetoureOSR);
            
            insert List_Retoure;
            
            Util.setCurrentAccount(Test_Account_Dist.Id);
            Apexpages.currentPage().getParameters().put('id', Test_Account_Dist.Id);
            AccountPageRetoureController TestController = new AccountPageRetoureController();
            
            List<Retoure__c> List_Insert = TestController.List_Records;
            for(Retoure__c r : List_Insert)
            {
                r.TXT_Bemerkung__C = 'test';
                r.Extrarabatt__c = 2;
                r.Retoure1__c = 5;
            }
            
            TestController.modeEdit();
            TestController.doSave();
        }
        
    }
    
}