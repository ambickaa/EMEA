@isTest
private class AccountPageVouchersController_Test {

// Test - Initial definition of variables
    public static Division__c Test_Division_OSR;
    public static Division__c Test_Division_CORN;
    public static List<Country__c> List_Test_Countries;
    public static List<Account> List_Test_Accounts;
    public static Account Test_Account_Farm;
    public static Account Test_Account_Dist;
    public static Campaign Test_Previous_Campaign;
    public static Campaign Test_Current_Campaign;

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
        
        insert List_Test_Accounts;

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
            'ArchiveDate__c' => Date.today().addDays(60)
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
    }
    
    static testMethod void LoadAccountPage() {

    // Test - Calling Ini() method and starting test
        Ini();
        Test.StartTest();

    // Test - Defining Visualforce page in use
        Test.setCurrentPage(Page.AccountPage);

        Util.currentCampaign = Test_Current_Campaign;
        Util.previewsCampaign = Test_Previous_Campaign;
        
        Apexpages.currentPage().getParameters().put('division', Test_Division_CORN.Id);
        
        Apexpages.currentPage().getParameters().put('id', Test_Account_Farm.Id);
        AccountPageVouchersController TestController_Farm = new AccountPageVouchersController();
        
        List<Report> List_Reports = TestController_Farm.availableReports;
        List<Voucher__c> List_Records_Farm = TestController_Farm.List_Records;
        
        Util.setCurrentAccount(Test_Account_Dist.Id);
        Apexpages.currentPage().getParameters().put('id', Test_Account_Dist.Id);
        AccountPageVouchersController TestController_Dist = new AccountPageVouchersController();
        
        List<Voucher__c> List_Records_Dist = TestController_Dist.List_Records;
        
        Test.StopTest();
    }

}