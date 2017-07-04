@isTest
private class AccountPageController_Test {

// Test - Initial definition of variables
    public static Division__c Test_Division;
    public static List<Country__c> List_Test_Countries;
    public static List<Account> List_Test_Accounts;
    public static Account Test_Account_Farm;
    public static Account Test_Account_Dist;
    public static Account Test_Account_Comp;
    public static Account Test_Account_Glob;

    private static void Ini() {
    
    // Test - Setting previous & current years
        TestInit.setYear(1);
        
    // Test - Including some countries
        List_Test_Countries = new List<Country__c>();
        List_Test_Countries.add(TestInit.getCountryByName('Italy'));
        //List_Test_Countries.add(testInit.getCountryByName('Ukraine'));
        //List_Test_Countries.add(testInit.getCountryByName('Romania'));

    // Test - Setting current division (for example, OSR)
        Test_Division = TestInit.getDivision(Util.DIVISION_OSR);

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
        
        // Test - Global
        Test_Account_Glob = new Account(Name = 'New Global', RecordTypeId = Util.recordType.get('Account:Account_Global'));
        List_Test_Accounts.add(Test_Account_Glob);
        
        insert List_Test_Accounts;
    }
    
    static testMethod void LoadAccountPage() {

    // Test - Calling Ini() method and starting test
        Ini();
        Test.StartTest();

    // Test - Defining Visualforce page in use
        Test.setCurrentPage(Page.AccountPage);
        
        Apexpages.currentPage().getParameters().put('division', Test_Division.Id);
        Apexpages.currentPage().getParameters().put('core.apexpages.devmode.url', '1');
        
        Apexpages.currentPage().getParameters().put('id', Test_Account_Farm.Id);
        Apexpages.StandardController stdController_Farm = new Apexpages.StandardController(Test_Account_Farm);
        AccountPageController TestController_Farm = new AccountPageController(stdController_Farm);
        
        Util.setCurrentAccount(Test_Account_Dist.Id);
        Apexpages.currentPage().getParameters().put('id', Test_Account_Dist.Id);
        Apexpages.StandardController stdController_Dist = new Apexpages.StandardController(Test_Account_Dist);
        AccountPageController TestController_Dist = new AccountPageController(stdController_Dist);
        
        TestController_Dist.redirectPage();
        
        Util.setCurrentAccount(Test_Account_Glob.Id);
        Apexpages.currentPage().getParameters().put('id', Test_Account_Glob.Id);
        Apexpages.StandardController stdController_Glob = new Apexpages.StandardController(Test_Account_Glob);
        AccountPageController TestController_Glob = new AccountPageController(stdController_Glob);
        
        TestController_Glob.redirectPage();
        
        Test.StopTest();
    }

    static testMethod void LoadRecordDeleted() {

    // Test - Calling Ini() method and starting test
        Ini();
        Test.StartTest();

    // Test - Defining Visualforce page in use
        Test.setCurrentPage(Page.AccountPage);

    // Test - Deleting record and trying to access it
        delete Test_Account_Farm;
        
        Apexpages.StandardController stdController_Farm = new Apexpages.StandardController(Test_Account_Farm);
        AccountPageController TestController_Farm = new AccountPageController(stdController_Farm);

    // Test - Unsharing record and trying to access it
        AccountShare[] AccountShare_Dist = [SELECT Id FROM AccountShare WHERE AccountId = :Test_Account_Dist.Id AND UserOrGroupId = :UserInfo.getUserId() AND RowCause = 'Manual'];
        
        if(AccountShare_Dist.size() > 0)
            delete AccountShare_Dist;

        Apexpages.StandardController stdController_Dist = new Apexpages.StandardController(Test_Account_Dist);
        AccountPageController TestController_Dist = new AccountPageController(stdController_Dist);
        
        Test.StopTest();
    }

}