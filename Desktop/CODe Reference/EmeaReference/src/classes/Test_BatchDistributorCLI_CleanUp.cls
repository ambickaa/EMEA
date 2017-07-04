@isTest
public class Test_BatchDistributorCLI_CleanUp {
    static testMethod void testCLIBatch()
    {
        //Inserting data for batch test execution
        //Inserting Country data from Custom Label
        String strCountries = System.Label.Dist_AP_Countries;
        List<String> countryList = new List <String>();
        countryList = strCountries.split('\r\n');
        //We split the first value into 3 different values: country, country code and owner Id
        String firstLabel = countryList.get(0);
        List <String> splitLabel = new List <String>();
        splitLabel = countryList.get(0).split('-');
        Country__c country = new Country__c(Name = splitLabel.get(0));
        //Gets country Italy
        insert country;
        String code = splitLabel.get(1);
        //String owner = splitLabel.get(2);        

        //Inserting Division data from Custom Label
        String strDiv = System.Label.Dist_AP_Division;
        List<String> divList = new List <String>();
        divList = strDiv.split('\r\n');
        Division__c division = new Division__c(Name = divList.get(0));
        //Gets division Corn
        insert division;
        
        Year__c year = new Year__c(Name = '2017');
        insert year;

        //Recovering Document Type
        String strDoc = System.Label.Dist_AP_OrderDocType;
        List<String> docList = strDoc.split('\n');

        //Recovering UoM
        String strUoM = System.Label.Dist_AP_UoM;
        List<String> uomList = strUoM.split('\n');

        //Recovering current year and creating dates for campaigns
        List<String> datesList = (System.Label.Dist_AP_Dates).split(',');
        String iniCampaign = datesList.get(0);
        String endCampaign = datesList.get(1);
        Boolean IsLast = false;
        SystemSettings__c TriggerOff = new SystemSettings__c(name='IgnoreTriggers_Cli',value__c='false');
        insert TriggerOff;

        //Querying Campaign Owners
        Profile user1Profile = [select Id,Name from Profile where Name =: 'IT_Regional Manager' limit 1];
        Profile user2Profile = [select Id,Name from Profile where Name =: 'IT_Sales Representative' limit 1];
        Profile supportUserProfile = [select Id,Name from Profile where Name =: 'System Administrator' limit 1];
        User user1 =  new User(CountryISOCode__c='IT', Alias='USER1',Email='user1@test.com',EmailEncodingKey='UTF-8',LastName='User1',ProfileId=user1Profile.Id,UserName='user1PL@test.first.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',StandardDivision__c=division.Name);
        User user2 =  new User(CountryISOCode__c='IT', Alias='USER2',Email='user2@test.com',EmailEncodingKey='UTF-8',LastName='User2',ProfileId=user2Profile.Id,UserName='user2PL@test.second.com',ManagerID=user1.Id,LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',StandardDivision__c=division.Name);
        User user3 =  new User(CountryISOCode__c='IT', Alias='USER3',Email='user3@test.com',EmailEncodingKey='UTF-8',LastName='User3',ProfileId=user1Profile.Id,UserName='user3PL@test.first.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',StandardDivision__c=division.Name);
        User user4 =  new User(CountryISOCode__c='IT', Alias='USER4',Email='user4@test.com',EmailEncodingKey='UTF-8',LastName='User4',ProfileId=user2Profile.Id,UserName='user4PL@test.second.com',ManagerID=user1.Id,LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',StandardDivision__c=division.Name);
        User user5 =  new User(CountryISOCode__c='HQ', Alias='Support',Email='user5@test.com',EmailEncodingKey='UTF-8',FirstName = 'Support',LastName='Team',ProfileId=supportUserProfile.Id,UserName='supportteam@test.first.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',StandardDivision__c=division.Name);
        insert new List<User>{user1,user2,user3,user4,user5};
        String owner=string.valueof(user1.id);

        //Insert query data
        String query = 'SELECT Id, OwnerId, Owner.IsActive, LKP_Responsible_ST__c, LKP_Responsible_ST__r.IsActive FROM Account WHERE RecordType.Name = ' + '\'' + 'Dist./Ret./PoS' + '\'' + ' AND CountryRef__r.Name = ' + '\'' + splitLabel.get(0) + '\'';
       
        //Inserting Distributors' data
        Account account1 = new Account(OwnerId = user2.Id, Name = 'D1', CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:DistRetPoS'));
        Account account2 = new Account(OwnerId = user2.Id, Name = 'D2', CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:DistRetPoS'));
        Account account3 = new Account(OwnerId = user2.Id, Name =  'F1', CountryRef__c = country.Id, RecordTypeId = '012D00000002zq3');
        Account account4 = new Account(OwnerId = user2.Id, Name =  'F2', CountryRef__c = country.Id, RecordTypeId = '012D00000002zq3');
        
        insert new List<Account>{account1,account2,account3,account4};

        //Inserting Sales Product Catalog
        ProductCatalog__c testPCM = new ProductCatalog__c(Name = 'Corn');
        insert testPCM;

        //Recovering current year and creating dates for campaigns
        Date thisDay = Date.today();
        Date start = Date.newInstance(thisDay.year(), 1, 1);
        Date finish = Date.newInstance(thisDay.year(), 12, 31);
        Date startPast = Date.newInstance(thisDay.year() - 1, 1, 1);
        Date finishPast = Date.newInstance(thisDay.year() - 1, 12, 31);

        //Inserting Parent Campaign for Corn
        Campaign activeParCamp = new Campaign(OwnerId = user1.Id, StartDate = start, EndDate = finish, StatusCode__c = 200, isActive = true, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'), CountryRef__c = country.Id, DivisionRef__c = division.Id, SalesPCMRef__c = testPCM.Id,YearV2__c = year.Id);
        //Inserting Active Campaign for Corn
        Campaign activeCamp = new Campaign(OwnerId = user2.Id, StartDate = start, EndDate = finish, isActive = true, StatusCode__c= 200, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'), CountryRef__c = country.Id, DivisionRef__c = division.Id, SalesPCMRef__c = testPCM.Id,YearV2__c = year.Id);
        //Inserting Past Parent Campaign for Corn with different users
        Campaign pastParCamp = new Campaign(OwnerId = user3.Id, StartDate = startPast, EndDate = finishPast, isActive = false, StatusCode__c = 300, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'), CountryRef__c = country.Id, DivisionRef__c = division.Id, SalesPCMRef__c = testPCM.Id,YearV2__c = year.Id);
        //Inserting Past Campaign for Corn with different users
        Campaign pastCamp = new Campaign(OwnerId = user4.Id, StartDate = startPast, EndDate = finishPast, isActive = false, StatusCode__c = 300, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'), CountryRef__c = country.Id, DivisionRef__c = division.Id, SalesPCMRef__c = testPCM.Id,YearV2__c = year.Id);
        insert new List<Campaign>{activeParCamp,activeCamp,pastParCamp,pastCamp};

        activeCamp.ParentId = activeParCamp.Id;
        pastCamp.ParentId = pastParCamp.Id;
        update new List<Campaign>{activeCamp,pastCamp}; 


        //Inserting Products for PCEs
        Product2 prod1 = new Product2(ProductVendor__c = '001D000000vG1zp', ProductSAPCode__c = '111111111', Name = 'testProduct1');
        Product2 prod2 = new Product2(ProductVendor__c = '001D000000vG1zp', ProductSAPCode__c = '222222222', Name = 'testProduct2'); 
        Product2 prod3 = new Product2(ProductVendor__c = '001D000000vG1zp', ProductSAPCode__c = '333333333', Name = 'testProduct3'); 
        insert new List<Product2>{prod1,prod2,prod3}; 

        //Inserting PCEs
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductRef__c = prod1.Id, ProductCatalogRef__c = testPCM.Id, Allocation__c=300);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductRef__c = prod2.Id, ProductCatalogRef__c = testPCM.Id,Allocation__c=300);
        ProductCatalogEntry__c pce3 = new ProductCatalogEntry__c(ProductRef__c = prod3.Id, ProductCatalogRef__c = testPCM.Id, Allocation__c=300);
        insert new List<ProductCatalogEntry__c>{pce1,pce2,pce3};

        //Inserting Farm CLIs
        //CLI with different PoS, Distributor null and active campaign
        CampaignLineItem__c cli1 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account3.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', Agreed__c = 5, Forecast__c = 8, POG__c = 7 ,PoS__c = account1.Id, DistributorRef__c = account2.Id, Status__c = 'Ordered / Discussed');
        //Same cli as cli1 but with different Farm
        CampaignLineItem__c cli2 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account4.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', Agreed__c = 5, Forecast__c = 8, POG__c = 7 ,PoS__c = account1.Id, DistributorRef__c = account2.Id, Status__c = 'Ordered / Discussed');
        //CLI with same campaign,PoS, Distributor but different Product as cli1  (Insert)
        CampaignLineItem__c cli3 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account3.Id, ProductRef__c = prod2.Id, ProductCatalogEntryRef__c = pce2.Id, Type__c = 'Charged', Agreed__c = 5, Forecast__c = 6, POG__c = 7 ,PoS__c = account1.Id, DistributorRef__c = account2.Id, Status__c = 'Ordered / Discussed');
        //Same cli as cli1 but different Type
        CampaignLineItem__c cli4 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account3.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Free of charge', Agreed__c = 0, Forecast__c = 8, POG__c = 7 ,PoS__c = account1.Id, DistributorRef__c = account2.Id, Status__c = 'Ordered / Discussed');
        //Past campaign CLI with POG
        CampaignLineItem__c cli5 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user4.Id, CampaignRef__c = pastCamp.Id, FarmRef__c = account3.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', POG__c = 9, PoS__c = account1.Id, DistributorRef__c = account2.Id, Status__c = 'Confirmed');
        //Update for cli5 (PoS)
        CampaignLineItem__c cli6 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user4.Id, CampaignRef__c = pastCamp.Id, FarmRef__c = account3.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', POG__c = 10, PoS__c = account1.Id, DistributorRef__c = null, Status__c = 'Confirmed');
        //Update for cli5 (Distributor)
        CampaignLineItem__c cli7 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user4.Id, CampaignRef__c = pastCamp.Id, FarmRef__c = account3.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', POG__c = 11, PoS__c = null, DistributorRef__c = account2.Id, Status__c = 'Confirmed');
        //Past campaign CLI with no Distributor CLI (Insert)
        CampaignLineItem__c cli8 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user4.Id, CampaignRef__c = pastCamp.Id, FarmRef__c = account3.Id, ProductRef__c = prod3.Id, ProductCatalogEntryRef__c = pce3.Id, Type__c = 'Free of charge', POG__c = 3, PoS__c = null, DistributorRef__c = account1.Id, Status__c = 'Confirmed');
        //Inserting Distributor CLIs
        //CLI from PoS to be updated by cli1 and 2
        CampaignLineItem__c cliDist1 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account1.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', NUM_FARM_AGREED__c = null, NUM_FARM_FORECAST__c = null, POGPY__c = null, Status__c = 'Ordered / Discussed',DistributorRef__c = NULL,PoS__c = NULL);
        //CLI from Dist to be updated by cli1 and 2
        CampaignLineItem__c cliDist2 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account2.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', NUM_FARM_AGREED__c = null, NUM_FARM_FORECAST__c = null, POGPY__c = null, Status__c = 'Ordered / Discussed',DistributorRef__c = NULL,PoS__c = NULL);
        //CLI from Dist/Pos which is not updated
        CampaignLineItem__c cliDist3 = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account1.Id, ProductRef__c = prod3.Id, ProductCatalogEntryRef__c = pce3.Id, Type__c = 'Free of charge', NUM_FARM_AGREED__c = null, NUM_FARM_FORECAST__c = null, POGPY__c = null, Status__c = 'Ordered / Discussed',DistributorRef__c = NULL,PoS__c = NULL);
        insert new List<CampaignLineItem__c>{cli1,cli2,cli3,cli4,cli5,cli6,cli7,cli8,cliDist1,cliDist2,cliDist3};
        
        system.runAs(user5)
        {
            CampaignLineItem__c cliDist1Dup = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account1.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', NUM_FARM_AGREED__c = null, NUM_FARM_FORECAST__c = null, POGPY__c = null, Status__c = 'Ordered / Discussed',DistributorRef__c = NULL,PoS__c = NULL);
        //CLI from Dist to be updated by cli1 and 2
        CampaignLineItem__c cliDist2Dup = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account2.Id, ProductRef__c = prod1.Id, ProductCatalogEntryRef__c = pce1.Id, Type__c = 'Charged', NUM_FARM_AGREED__c = null, NUM_FARM_FORECAST__c = null, POGPY__c = null, Status__c = 'Ordered / Discussed',DistributorRef__c = NULL,PoS__c = NULL);
        //CLI from Dist/Pos which is not updated
        CampaignLineItem__c cliDist3Dup = new CampaignLineItem__c(RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'),OwnerId = user2.Id, CampaignRef__c = activeCamp.Id, FarmRef__c = account1.Id, ProductRef__c = prod3.Id, ProductCatalogEntryRef__c = pce3.Id, Type__c = 'Free of charge', NUM_FARM_AGREED__c = null, NUM_FARM_FORECAST__c = null, POGPY__c = null, Status__c = 'Ordered / Discussed',DistributorRef__c = NULL,PoS__c = NULL);
            insert new List<CampaignLineItem__c>{cliDist1Dup,cliDist2Dup,cliDist3Dup};
        }
        
        //Querying all the CampaignLineItems for a particular country
        List<CampaignLineItem__c> listOfCLIs = [Select Id, Name, OwnerId,Owner.Alias,Owner.Name, CampaignRef__c, CampaignRef__r.Name,ProductCatalogEntryRef__c,
                                                ProductRef__c,ProductRef__r.ProductSAPCode__c,FarmRef__c, FarmRef__r.Client_Code__c,Type__c,LKP_PY_CLI__c,
                                                RecordTypeId,Year__c,Division__c,country__c,Agreed__c,Forecast__c,POG__c,CreatedById,CreatedDate,
                                                CreatedBy.Name,ForecastLow__c,FarmRef__r.Recordtype.Name,recordtype.Name from CampaignLineItem__c ];
        System.debug('Total Number of CLIs Queried '+listOfCLIs);
        //Run batch test
        Test.startTest();
        //BatchDistributorCLI_CleanUp cliCleanUp = new BatchDistributorCLI_CleanUp();
        //cliCleanUp.CLICleanUP('2017','Italy');
        Id batchTest = Database.executeBatch (new BatchDistributorCLI_CleanUp('2017','Italy'));
        Test.stopTest();
    }
}