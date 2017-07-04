@isTest
private class AccountPageMarkCampController_Test {

// Test - Initial definition of variables
    public static Division__c Test_Division_OSR;
    public static Division__c Test_Division_CORN;
    public static List<Country__c> List_Test_Countries;
    public static List<Account> List_Test_Accounts;
    public static Account Test_Account_Farm;
    public static Account Test_Account_Dist;

    private static void Ini() {
        
        User CurrentUser = [SELECT Id, Name, Country, ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
        CurrentUser.Country = 'France';
        CurrentUser.CountryISOCode__c='FR';
        update CurrentUser;
    
    // Test - Setting previous & current years
        TestInit.setYear(1);
        
    // Test - Including some countries
        List_Test_Countries = new List<Country__c>();
        List_Test_Countries.add(TestInit.getCountryByName('France'));

    // Test - Setting different divisions
        Test_Division_OSR = TestInit.getDivision(Util.DIVISION_OSR);
        Test_Division_CORN = TestInit.getDivision(Util.DIVISION_CORN);

    // Test - Including some accounts
        List_Test_Accounts = new List<Account>();

        // Test - Farm
        Test_Account_Farm = TestInit.createNewFarmer();
        Test_Account_Farm.CountryID__c = List_Test_Countries[0].Id;
        Test_Account_Farm.CountryRef__c = List_Test_Countries[0].Id;
        Test_Account_Farm.RecordtypeId = Util.recordType.get('Account:GroupFarmSite');
        List_Test_Accounts.add(Test_Account_Farm);

        // Test - Distributor
        Test_Account_Dist = TestInit.createNewDistributor();
        Test_Account_Dist.CountryID__c = List_Test_Countries[0].Id;
        Test_Account_Dist.CountryRef__c = List_Test_Countries[0].Id;
        Test_Account_Dist.RecordtypeId = Util.recordType.get('Account:DistRetPoS');
        List_Test_Accounts.add(Test_Account_Dist);
        
        insert List_Test_Accounts;
        
    //Campaigns
        Campaign Test_Marketing_Campaign_A = new Campaign(Name= 'Test Marketing Campaign A', CountryRef__c=Test_Account_Farm.CountryRef__c, OwnerId=CurrentUser.Id, DivisionRef__c=Test_Division_CORN.Id, YearV2__c=Util.currentYear.Id, StartDate=Date.today(), EndDate= Date.today().addDays(30),ArchiveDate__c=Date.today().addDays(60),RecordtypeId=Util.recordType.get('Campaign:Marketing_campaign') );
        
        Campaign Test_Marketing_Campaign_B = new Campaign(Name= 'Test Marketing Campaign B', CountryRef__c=Test_Account_Farm.CountryRef__c, OwnerId=CurrentUser.Id, DivisionRef__c=Test_Division_CORN.Id, YearV2__c=Util.currentYear.Id, StartDate=Date.today(), EndDate= Date.today().addDays(30),ArchiveDate__c=Date.today().addDays(60),RecordtypeId=Util.recordType.get('Campaign:Marketing_campaign') );
        
        insert new List<Campaign>{Test_Marketing_Campaign_A,Test_Marketing_Campaign_B};         
        
    //Contacts
        contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', Ownerid=CurrentUser.id,AccountId=Test_Account_Farm.Id, Phone=null, MobilePhone='987002765');
        contact contact2 = new Contact(FirstName='TEST', LastName='TEST2', Ownerid=CurrentUser.id,AccountId=Test_Account_Dist.Id, Phone=null, MobilePhone='987002765');
        insert new List<Contact>{contact1,contact2};        
        
        //Campaign member
        CampaignMember CampaignMember1 = new CampaignMember(ContactId=contact1.id, Campaignid=Test_Marketing_Campaign_A.id);
        CampaignMember CampaignMember2 = new CampaignMember(ContactId=contact1.id, Campaignid=Test_Marketing_Campaign_B.id);
        insert new List<CampaignMember>{CampaignMember1,CampaignMember2};
    
    }
    

        
    static testMethod void LoadAccountPage() {

    // Test - Calling Ini() method and starting test
        Ini();
        Test.StartTest();

    // Test - Defining Visualforce page in use
        Util.setCurrentAccount(Test_Account_Farm.Id);
        Test.setCurrentPage(Page.AccountPage);
        Apexpages.currentPage().getParameters().put('division', Test_Division_CORN.Id);
        
        Apexpages.currentPage().getParameters().put('id', Test_Account_Farm.Id);
        AccountPageMarkCampController TestController_Farm = new AccountPageMarkCampController();
         List<Campaign> List_Records_Farm = TestController_Farm.List_Records;
         
         User CurrentUser = [SELECT Id, Name, CountryISOCode__c, ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
         CurrentUser.CountryISOCode__c=null;
         Update CurrentUser;
        
        Util.setCurrentAccount(Test_Account_Dist.Id);
        Apexpages.currentPage().getParameters().put('id', Test_Account_Dist.Id);
        AccountPageMarkCampController TestController_Dist = new AccountPageMarkCampController();
        List<Campaign> List_Records_Dist = TestController_Dist.List_Records;
        
        Test.StopTest();
    }

}