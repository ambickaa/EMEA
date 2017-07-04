@isTest
private class TriggerEventAccountVisited_Test {
    
    static testMethod void Test_Events(){
        
        Test.StartTest();
        
        User currentUser = [SELECT Id, Country, CountryISOCode__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        currentUser.CountryISOCode__c = 'FR';
        currentUser.Country = 'France';
        currentUser.Division = 'S&T';
        update currentUser;

        Year__c PPFY = new Year__c(Name = '2015', Current_Year__c = false, YearEndDate__c = date.newinstance(2015, 12, 31), YearStartDate__c = date.newinstance(2015, 1, 1)); 
        insert PPFY;  

        Year__c PFY = new Year__c(Name = '2016', Current_Year__c = false, YearEndDate__c = date.newinstance(2016, 12, 31), YearStartDate__c = date.newinstance(2016, 1, 1), YearPreviousYear__c = PPFY.Id); 
        insert PFY;    
        
        Year__c FY = new Year__c(Name = '2017', Current_Year__c = true, YearEndDate__c = date.newinstance(2017, 12, 31), YearStartDate__c = date.newinstance(2017, 1, 1), YearPreviousYear__c = PFY.Id); 
        insert FY;
        
        Country__c country = new Country__c(Name = 'France', TacticalPlanSetting__c = 'Standard', LKP_CurrentYear__c = FY.Id, LKP_OSRYear__c = PFY.Id);
        insert country;
        
        List<Division__c> List_d = new List<Division__c>();
        List_d.add(new Division__c(Name = 'Corn', Standard__c = true));
        List_d.add(new Division__c(Name = 'OSR', Standard__c = true));
        insert List_d;
        
        List<SystemSettings__c> List_ss = new List<SystemSettings__c>();
        List_ss.add(new SystemSettings__c(Name = currentUser.CountryISOCode__c + '_TPP_TRIGGER', Value__c = '1#1#1'));
        List_ss.add(new SystemSettings__c(Name = 'NUM_MONTHS_EVENTS_IPAD', Value__c = '6'));
        insert List_ss;
        
        AccountVisited__c av = new AccountVisited__c(Name = currentUser.Country, Corn__c = '01-09/31-03', OSR__c = '01-04/31-08');
        insert av;
        
        List<Account> List_acc = new List<Account>();
        List_acc.add(new Account(Name = 'TEST 0', CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:GroupFarmSite')));
        List_acc.add(new Account(Name = 'TEST 1', CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:DistRetPoS')));
        List_acc.add(new Account(Name = 'TEST 2', CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:DistRetPoS')));
        List_acc.add(new Account(Name = 'TEST 3', CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:GroupFarmSite')));
        List_acc.add(new Account(Name = 'TEST 4', CountryRef__c = country.Id, RecordTypeId = Util.recordType.get('Account:GroupFarmSite')));
        insert List_acc;

        List<Touchpoint_Program__c> List_tpp = new List<Touchpoint_Program__c>();
        List_tpp.add(new Touchpoint_Program__c(LKP_ACCOUNT__c = List_acc[0].Id, LKP_YEAR__c = FY.Id, LKP_CROP__c = List_d[0].Id));
        List_tpp.add(new Touchpoint_Program__c(LKP_ACCOUNT__c = List_acc[1].Id, LKP_YEAR__c = FY.Id, LKP_CROP__c = List_d[0].Id));
        List_tpp.add(new Touchpoint_Program__c(LKP_ACCOUNT__c = List_acc[1].Id, LKP_YEAR__c = PFY.Id, LKP_CROP__c = List_d[1].Id));
        List_tpp.add(new Touchpoint_Program__c(LKP_ACCOUNT__c = List_acc[2].Id, LKP_YEAR__c = PFY.Id, LKP_CROP__c = List_d[0].Id));
        insert List_tpp;

        List<Event> List_Events = new List<Event>();

        List_Events.add(new Event(WhatId = List_acc[0].Id, LKP_TOUCHPOINT_PROG__c = List_tpp[0].Id, Subject = 'Dealer visit', DurationInMinutes = 5, StartDateTime = Datetime.newinstance(2017, 01, 15, 12, 30, 0)));
        List_Events.add(new Event(WhatId = List_acc[1].Id, LKP_TOUCHPOINT_PROG__c = List_tpp[1].Id, Subject = 'Dealer visit', DurationInMinutes = 5, StartDateTime = Datetime.newinstance(2017, 01, 15, 12, 30, 0)));
        List_Events.add(new Event(WhatId = List_acc[1].Id, LKP_TOUCHPOINT_PROG__c = List_tpp[2].Id, Subject = 'Dealer visit', DurationInMinutes = 5, StartDateTime = Datetime.newinstance(2017, 01, 15, 12, 30, 0)));
        List_Events.add(new Event(WhatId = List_acc[2].Id, LKP_TOUCHPOINT_PROG__c = List_tpp[3].Id, Subject = 'Dealer visit', DurationInMinutes = 5, StartDateTime = Datetime.newinstance(2017, 01, 15, 12, 30, 0)));

        List_Events.add(new Event(WhatId = List_acc[3].Id, Subject = 'Dealer visit', DurationInMinutes = 5, StartDateTime = Datetime.newinstance(2017, 01, 15, 12, 30, 0)));
        List_Events.add(new Event(WhatId = List_acc[4].Id, Subject = 'Dealer visit', DurationInMinutes = 5, StartDateTime = Datetime.newinstance(2017, 05, 15, 12, 30, 0)));
        List_Events.add(new Event(WhatId = List_acc[4].Id, Subject = 'Dealer visit', DurationInMinutes = 5, StartDateTime = Datetime.newinstance(2016, 07, 15, 12, 30, 0)));
        insert List_Events;
        
        Set<Id> Set_AccountId = new Set<Id>();
        
        for(Account a : List_acc)
            Set_AccountId.add(a.Id);

        List<Account> List_accounts = [SELECT Id, Name, GC_is_Visited__c, CHK_Visited_OSR_CY__c FROM Account WHERE Id IN :Set_AccountId ORDER BY Name ASC];
        
        system.assertEquals(true, List_accounts[0].GC_is_Visited__c);
        system.assertEquals(false, List_accounts[0].CHK_Visited_OSR_CY__c);
        
        system.assertEquals(true, List_accounts[1].GC_is_Visited__c);
        system.assertEquals(true, List_accounts[1].CHK_Visited_OSR_CY__c);
        
        system.assertEquals(false, List_accounts[2].GC_is_Visited__c);
        system.assertEquals(false, List_accounts[2].CHK_Visited_OSR_CY__c);
        
        system.assertEquals(true, List_accounts[3].GC_is_Visited__c);
        system.assertEquals(false, List_accounts[3].CHK_Visited_OSR_CY__c);
        
        system.assertEquals(false, List_accounts[4].GC_is_Visited__c);
        system.assertEquals(true, List_accounts[4].CHK_Visited_OSR_CY__c);

        Test.StopTest();
    }
           
}