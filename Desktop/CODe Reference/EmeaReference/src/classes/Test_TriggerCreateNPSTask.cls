@isTest
public class Test_TriggerCreateNPSTask{
    static testMethod void testInsertNPSCase() {
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
       
     //Get the RecordTypeID for "Survey Result" on Case Object
     string recordtype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Survey Result').getRecordTypeId();
        
     //Create new Country
    Country__c country = new Country__c(Name='Hungary');
    insert country;
    
    Year__c y = new Year__c(Name='TestYear');
    insert y;
     
     //Create new Account
    Account a = new Account(Name='Test Account',CountryRef__c=country.id);
    insert a;
    
    Contact c = new Contact(FirstName='Test',LastName='Contact',AccountId=a.id,CountryRef__c=country.id);
    insert c;
    
    Division__c d = new Division__c(Name='Corn');
    insert d;
    
    //Create Campaign
    Campaign ca = new Campaign();
    ca.Name = 'testCampaign';
    ca.CountryRef__c = country.Id;
    ca.YearV2__c = y.Id;
    ca.DivisionRef__c = d.Id;
    insert ca;
    
    
    c = [SELECT Firstname,Lastname, AccountId FROM Contact WHERE Id = :c.Id];
    System.assertEquals(a.id, c.AccountId);

    //Create new Case
    Case cs = new Case(Subject='Test Case',RecordTypeId=recordtype,ContactId=c.Id,AccountId=a.Id,NPS_RESULT_Q4__c='Yes', NPS_CAMPAIGN__c = ca.Id);
    insert cs;
       
     }
}