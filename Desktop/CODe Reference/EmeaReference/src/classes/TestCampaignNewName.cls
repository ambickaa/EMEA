@isTest 
private class TestCampaignNewName {
    static testMethod void validateCampaignNewName() {
    Country__c country = new Country__c(Name='Poland');
    Year__c year = new Year__c(Name='2016');
    Division__c div = new Division__c(Name='Corn');
   
    insert country;
    insert year;
    insert div;
    
       Campaign b = new Campaign(Name='campaign', DivisionRef__c = div.Id, TXT_Wave__c = '1', CountryRef__c = country.Id, YearV2__c = year.Id, recordtypeid = Util.recordType.get('Campaign:NPS'));
       System.debug('Title before inserting new book: ' + b.Name);

       // Insert campaign
       insert b;
    
       // Retrieve the new campaign
       b = [SELECT Name FROM Campaign WHERE Id =:b.Id];
       System.debug('Title after trigger fired: ' + b.Name);

       // Test that the trigger correctly updated the name
       System.assertEquals('NPS - Poland - Corn - 2016 - 1', b.Name);
    }
}