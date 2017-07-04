@isTest
private class TriggerCampaignBlockFields_Test {

    private static testmethod void Test_Ini()
    {
        Country__c Test_country_A = new Country__c(Name = 'Italy');
        Country__c Test_country_B = new Country__c(Name = 'Spain');
        insert new List<Country__c>{Test_country_A, Test_country_B};
        
        
        Division__c Test_d_1 = new Division__c(Name = 'Corn');
        Division__c Test_d_2 = new Division__c(Name = 'OSR');
        insert new List<Division__c>{Test_d_1, Test_d_2};
        
        Year__c PY = new Year__c(Name = '2015', YearStartDate__c = date.newinstance(2014,11,1), YearEndDate__c = date.newinstance(2015,10,31), Current_Year__c = false);
        insert PY;
        
        Year__c CY = new Year__c(Name = '2016', YearStartDate__c = date.newinstance(2015,11,1), YearEndDate__c = date.today().addDays(1), Current_Year__c = true, YearPreviousYear__c = PY.Id);
        insert CY;
        
        Campaign Test_c_A1CP = new Campaign(DisableAgreedStatus__c = false, CountryRef__c = Test_country_A.Id, DivisionRef__c = Test_d_1.Id, YearV2__c = CY.Id, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'));
        Campaign Test_c_A1C = new Campaign(DisableAgreedStatus__c = false, CountryRef__c = Test_country_A.Id, DivisionRef__c = Test_d_1.Id, YearV2__c = CY.Id, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'));
        Campaign Test_c_A1P = new Campaign(DisableAgreedStatus__c = false, CountryRef__c = Test_country_A.Id, DivisionRef__c = Test_d_1.Id, YearV2__c = PY.Id, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'));
        Campaign Test_c_A2C = new Campaign(DisableAgreedStatus__c = false, CountryRef__c = Test_country_A.Id, DivisionRef__c = Test_d_2.Id, YearV2__c = CY.Id, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'));
        Campaign Test_c_A2P = new Campaign(DisableAgreedStatus__c = false, CountryRef__c = Test_country_A.Id, DivisionRef__c = Test_d_2.Id, YearV2__c = PY.Id, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'));

        Campaign Test_c_B1C = new Campaign(DisableAgreedStatus__c = false, CountryRef__c = Test_country_B.Id, DivisionRef__c = Test_d_1.Id, YearV2__c = CY.Id, RecordTypeId = Util.recordType.get('Campaign:Sales_camp'));
        insert new List<Campaign>{Test_c_A1CP, Test_c_A1C, Test_c_A1P, Test_c_A2C, Test_c_A2P, Test_c_B1C};
        
        Test_c_A1C.ParentId = Test_c_A1CP.Id;
        update Test_c_A1C;
        
        Test.startTest();
        
        Test_c_A1CP.DisableAgreedStatus__c = true;
        update Test_c_A1CP;
        
        for(Campaign c : [SELECT Id, DisableAgreedStatus__c FROM Campaign
                          WHERE Id = :Test_c_A1C.Id OR Id = :Test_c_A1P.Id OR Id = :Test_c_A2C.Id OR Id = :Test_c_A2P.Id OR Id = :Test_c_B1C.Id]) {
        
            if(c.Id == Test_c_A1C.Id)
                system.assertEquals(c.DisableAgreedStatus__c, true);
            else
                system.assertEquals(c.DisableAgreedStatus__c, false);
        }
        
        Test.stopTest();
        
    }
}