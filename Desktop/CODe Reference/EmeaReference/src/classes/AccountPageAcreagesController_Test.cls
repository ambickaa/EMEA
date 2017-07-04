@isTest
private class AccountPageAcreagesController_Test {

// Test - Initial definition of variables
    public static Division__c Test_Division_OSR;
    public static Division__c Test_Division_CORN;
    public static List<Country__c> List_Test_Countries;
    public static List<Account> List_Test_Accounts;
    public static List<Acreage__c> List_Test_Acreages;
    public static Account Test_Account_Farm;
    public static Account Test_Account_Dist;
    public static Account Test_Account_Comp;
    public static Product_Grouping__c Test_Group_OSR;
    public static Product_Grouping__c Test_Group_CORN;

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

        // Test - Inserting acreages data (Product Groups and Product Types)
        Test_Group_OSR = new Product_Grouping__c(Name = Util.DIVISION_OSR, RecordTypeId = Util.recordType.get('Product_Grouping__c:ProductGroup'));
        Test_Group_CORN = new Product_Grouping__c(Name = Util.DIVISION_CORN, RecordTypeId = Util.recordType.get('Product_Grouping__c:ProductGroup'));
        insert new List<Product_Grouping__c> {Test_Group_OSR, Test_Group_CORN};
        
        Product_Grouping__c Test_Group_CORN_GRAIN = new Product_Grouping__c(Name = 'Grain', ProductGroupRef__c = Test_Group_CORN.Id, RecordTypeId = Util.recordType.get('Product_Grouping__c:ProductType'));
        insert Test_Group_CORN_GRAIN;
        
        // Test - Including some acreages
        Acreage__c Test_Acreage_PY = new Acreage__c(RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrProviderRef__c = Test_Account_Comp.Id, AcrFarmRef__c = Test_Account_Farm.Id, AcrYearRef__c = Util.lastYear.Id, AcrTotalAcreages__c = 95, AcrProductGroupRef__c = Test_Group_CORN.Id, AcrProductTypeRef__c = Test_Group_CORN_GRAIN.Id);
        
        insert Test_Acreage_PY;

        List_Test_Acreages = new List<Acreage__c>();
        
        List_Test_Acreages.add(new Acreage__c(RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrProviderRef__c = Test_Account_Comp.Id, AcrFarmRef__c = Test_Account_Farm.Id, AcrYearRef__c = Util.currentYear.Id, AcrTotalAcreages__c = 100, AcrProductGroupRef__c = Test_Group_CORN.Id, AcrProductTypeRef__c = Test_Group_CORN_GRAIN.Id, PreviousAcreageRef__c = Test_Acreage_PY.Id));
        List_Test_Acreages.add(new Acreage__c(RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrProviderRef__c = Test_Account_Comp.Id, AcrFarmRef__c = Test_Account_Farm.Id, AcrYearRef__c = Util.currentYear.Id, AcrTotalAcreages__c = 100, AcrProductGroupRef__c = Test_Group_OSR.Id));
        
        insert List_Test_Acreages;
        
        List_Test_Acreages.add(Test_Acreage_PY);
    }
    
    static testMethod void LoadAccountPage() {

    // Test - Calling Ini() method and starting test
        Ini();
        Test.StartTest();

    // Test - Defining Visualforce page in use
        Test.setCurrentPage(Page.AccountPage);
        
        Apexpages.currentPage().getParameters().put('division', Test_Division_CORN.Id);
        
        Apexpages.currentPage().getParameters().put('id', Test_Account_Farm.Id);
        AccountPageAcreagesController TestController_Farm = new AccountPageAcreagesController();
        
        List<Report> List_Reports = TestController_Farm.availableReports;
        List<Acreage__c> List_Records = TestController_Farm.List_Records;
        TestController_Farm.getMap_ProductTranslations();
        
    // Test - Methods with no records selected (no actions)
        TestController_Farm.modeNew();
        TestController_Farm.doSave();
        
        TestController_Farm.modeEdit();
        TestController_Farm.doSave();
        
        TestController_Farm.doDelete();
        
        TestController_Farm.getRows();

    // Test - Methods with records selected (actions triggered)
        TestController_Farm.modeNew();
        List<Acreage__c> List_Insert = TestController_Farm.List_Records;
        for(Acreage__c r : List_Insert)
        {
            r.AcrTotalAcreages__c = 5;
            r.AcrProviderRef__c = Test_Account_Comp.Id;
            r.AcrProductGroupRef__c = Test_Group_OSR.Id;
        }
        TestController_Farm.doSave();

        String recordsId = '';
        for(Acreage__c a : List_Test_Acreages)
        {
            if(recordsId == '')
                recordsId += a.Id;
            else
                recordsId += ',' + a.Id;
        }
        
        TestController_Farm.setRows(List_Test_Acreages[0].Id);
        TestController_Farm.doDelete();
        
        TestController_Farm.modeEdit();
        TestController_Farm.setRows(recordsId);
        TestController_Farm.doSave();
        
        TestController_Farm.setRows(recordsId);
        TestController_Farm.doDelete();
        
        Util.setCurrentAccount(Test_Account_Dist.Id);
        Apexpages.currentPage().getParameters().put('id', Test_Account_Dist.Id);
        AccountPageAcreagesController TestController_Dist = new AccountPageAcreagesController();
        
        Test.StopTest();
    }

}