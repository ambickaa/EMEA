@isTest
private class REST_LeadEmailConfirmation_Test
{
    static testmethod void TestEmailConfirmation()
    {
        //--------------------
        // Inserting new contact
        //--------------------
        
        Country__c country = new Country__c (Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert country;
        Account a = new Account(CountryRef__c=country.ID, Name='Test Account',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), Category__c='Farm',GC_VATIN_Number__c='5');
        insert a;
        Contact c = new Contact(LastName='Test Contact', email='email.example@email.com', CountryRef__c=country.id, AccountId=a.id);
        insert c;
        
        REST_LeadEmailConfirmation.EmailConfirmationWrapper request = new REST_LeadEmailConfirmation.EmailConfirmationWrapper();
        request.email = c.email;
        
        String JSON_request = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/LeadEmailConfirmation';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON_request);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadEmailConfirmation.EmailConfirmationWrapper response = new REST_LeadEmailConfirmation.EmailConfirmationWrapper();
        response = REST_LeadEmailConfirmation.LeadEmailConfirmation(request);
        
        Test.stopTest();
    }
}