@isTest
private class TriggerChangeYearOnCountry_Test {
    
    static testMethod void Test_1(){
        
        system.test.startTest();
        
        Year__c PrevYear = new Year__c (Name='2015', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), YearStartDate__c=date.newinstance(1913, 1, 1)); 
        insert PrevYear;    
        
        Year__c NextYear = new Year__c (Name='2017', Current_Year__c=false, YearEndDate__c=date.newinstance(3914, 12, 31), YearStartDate__c=date.newinstance(2916, 1, 1)); 
        insert NextYear;    
        
        Year__c year= new Year__c (Name='2016', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), YearStartDate__c=date.newinstance(1915, 1, 1),YearPreviousYear__c=PrevYear.id, YearNextYear__c=NextYear.id); 
        insert year;
        
        Country__c country = new Country__c(Name ='Ukraine', TacticalPlanSetting__c = 'Standard', LKP_CurrentYear__c=year.id, LKP_OSRYear__c=year.id);
        insert country;
        
        Country__c country2 = new Country__c(Name ='Germany', TacticalPlanSetting__c = 'Standard', LKP_CurrentYear__c=year.id, LKP_OSRYear__c=year.id);
        insert country2;
        
        Country__c country3 = new Country__c(Name ='France', TacticalPlanSetting__c = 'Standard', LKP_CurrentYear__c=year.id, LKP_OSRYear__c=year.id);
        insert country3;
        
        Account account1 = new Account (CountryRef__c=country.Id, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), Category__c='Farm');
        insert account1;
        
        Contact contact= new Contact(FirstName='TestName', LastName='TestLastName', CountryRef__c=country.Id, AccountId=account1.id);
        insert contact;
        
        Account account2 = new Account (CountryRef__c=country2.Id, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:DistRetPoS'), Category__c='Distributor');
        insert account2;
        
        Account account3 = new Account (CountryRef__c=country3.Id, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:DistRetPoS'), Category__c='Distributor');
        insert account3;

        country.LKP_CurrentYear__c=NextYear.id;
        update country;
        
        country.LKP_OSRYear__c=NextYear.id;
        update country;
        
        country2.LKP_CurrentYear__c=PrevYear.id;
        update country2;
        
        country2.LKP_OSRYear__c=PrevYear.id;
        update country2;
        
        country3.LKP_CurrentYear__c=PrevYear.id;
        update country3;
        
        system.Test.stopTest();
    }
}