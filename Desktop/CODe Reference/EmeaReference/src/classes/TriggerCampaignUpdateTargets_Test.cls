@isTest
private class TriggerCampaignUpdateTargets_Test {
     // This class is triggered after updating Total Campaign Budget or Total Campaign Budget Acreages //

    @isTest
    static void init(){
        // Campaign object: We have to check if the fields had been updated //
        Test.startTest();
        // The campaigns belongs to a user //
        
        // we create two user test with a role and profile //
        UserRole user1Role = [select PortalType,PortalAccountId from UserRole where DeveloperName =: 'Regional_Manager_IT_Zone_CARNAROGLIO_FABIO' limit 1];
        UserRole user2Role= [select PortalType,PortalAccountId from UserRole where DeveloperName =: 'Sales_Representative_IT_Zone_CARNAROGLIO_FABIO' limit 1];
               
        Profile user1Profile = [select Id,Name from Profile where Name =: 'IT_Regional Manager' limit 1];
        Profile user2Profile = [select Id,Name from Profile where Name =: 'IT_Sales Representative' limit 1];  
        
        User user1 =  new User( CountryISOCode__c='UA',Alias='USER1',Is_Country_Manager__c = TRUE,Country='Italy',Email='user1@test.com',EmailEncodingKey='UTF-8',LastName='User1',ProfileId=user1Profile.Id,UserRoleID=user1Role.ID,UserName='user1UA@test.first.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', NUM_CURRENT_CAMPAIGN_HA_TARGET__c = 0, NUM_Current_CornCampaign_Target__c = 0, NUM_CURRENT_OSRCAMPAIGN_HA_TARGET__c = 0, NUM_Current_OSRCampaign_Target__c = 0);
        User user2 =  new User(CountryISOCode__c='UA',Alias='USER2',Is_Country_Manager__c = FALSE, ManagerID =user1.id,Country='Italy', Email='user2@test.com',EmailEncodingKey='UTF-8',LastName='User2',ProfileId=user2Profile.Id,UserRoleID=user2Role.ID,UserName='user2UA@test.second.com',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', NUM_CURRENT_CAMPAIGN_HA_TARGET__c = 0, NUM_Current_CornCampaign_Target__c = 0, NUM_CURRENT_OSRCAMPAIGN_HA_TARGET__c = 0, NUM_Current_OSRCampaign_Target__c = 0);

        // we insert this users into a list //
        insert new List<User>{user1,user2};
 
        System.runAs (user1){
         // test user with role and profile
         //YEAR//
         Year__c year = new Year__c(Name='2015',Current_Year__c=true,YearEndDate__c=date.newinstance(2099,12,31),YearStartDate__c=date.newinstance(2014,1,1));
         insert year;   
         
         Division__c division1 = new Division__c(Name='Corn');
         Division__c division2 = new Division__c(Name='OSR');
         
         insert new List<Division__c>{division1, division2};

         Country__c country = new Country__c(Name='Italy');
         insert country;
         
         Campaign aOSR = new Campaign(Name='campaign2',OwnerId=user2.Id, CountryRef__c = country.Id, YearV2__c = year.Id,DivisionRef__c=division2.id,RecordTypeId=Util.recordType.get('Campaign:Sales_camp'), StartDate=year.YearStartDate__c, EndDate=year.YearEndDate__c,Statuscode__c=200, TotalCampaignBudget__c = 1111,Total_Campaign_Budget_Acreages__c = 2222, NUM_POTENTIAL_HA__c = 3333);
         Campaign aCorn = new Campaign(Name='campaign1',OwnerId=user2.Id, CountryRef__c = country.Id, YearV2__c = year.Id,DivisionRef__c=division1.id,RecordTypeId=Util.recordType.get('Campaign:Sales_camp'), StartDate=year.YearStartDate__c, EndDate=year.YearEndDate__c,Statuscode__c=200, TotalCampaignBudget__c = 1111,Total_Campaign_Budget_Acreages__c = 2222, NUM_POTENTIAL_HA__c = 3333);
         
         List<Campaign> listCampaigns = new List<Campaign>{aCorn,aOSR};
         insert listCampaigns;
         
         // aCorn campaign test changing values //
         aCorn.TotalCampaignBudget__c =1234;
         aCorn.Total_Campaign_Budget_Acreages__c = 4321;
         aCorn.NUM_POTENTIAL_HA__c = 584167;
         aOSR.TotalCampaignBudget__c =146562;
         aOSR.Total_Campaign_Budget_Acreages__c = 5677894;
         aOSR.NUM_POTENTIAL_HA__c = 590198;
         
         update listCampaigns;
 
         user2 = [SELECT Id, NUM_Current_CornCampaign_Target__c, NUM_CURRENT_CAMPAIGN_HA_TARGET__c, NUM_POTENTIAL_HA_CORN__c FROM User WHERE Id =: user2.id]; 
        
         // the campaign aCorn has been assigned to user1 //
         System.assertEquals(aCorn.TotalCampaignBudget__c,user2.NUM_Current_CornCampaign_Target__c);
         System.assertEquals(aCorn.Total_Campaign_Budget_Acreages__c,user2.NUM_CURRENT_CAMPAIGN_HA_TARGET__c);
         System.assertEquals(aCorn.NUM_POTENTIAL_HA__c,user2.NUM_POTENTIAL_HA_CORN__c);
 
         user2 = [SELECT Id, NUM_Current_OSRCampaign_Target__c, NUM_CURRENT_OSRCAMPAIGN_HA_TARGET__c, NUM_POTENTIAL_HA_OSR__c FROM User WHERE Id =: user2.id]; 
        
         // the campaign aCorn has been assigned to user1 //
         System.assertEquals(aOSR.TotalCampaignBudget__c,user2.NUM_Current_OSRCampaign_Target__c);
         System.assertEquals(aOSR.Total_Campaign_Budget_Acreages__c,user2.NUM_CURRENT_OSRCAMPAIGN_HA_TARGET__c);
         System.assertEquals(aOSR.NUM_POTENTIAL_HA__c,user2.NUM_POTENTIAL_HA_OSR__c);
        }
               
    }

}