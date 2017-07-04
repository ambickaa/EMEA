@isTest
private class Test_REST_LeadRegistration
{
    static testmethod void testLeadRegistration()
    {
        //Lead
        Lead l = new Lead();
        l.FirstName = 'testLead';            
        l.LastName = 'testLead';
        l.DAT_Birthday__c = System.today();
        l.Country = 'country1';
        l.State = 'state1';
        l.City = 'city1';
        l.PostalCode = '0000';
        l.Street = 'street1';
        l.Email = 'test@test.com';
        l.Phone = '666666666';
        l.Fax = '';
        l.NUM_Farm_size_per_crop__c = 100;
        l.Website = '';
        l.Company = 'company';
        l.TXT_Position_in_the_company__c = '';
        l.TXT_VAT_ID__c = '';
        l.PICK_User_category__c = 'farmer';
        l.PICK_Farm_usage__c = '';
        l.PICK_Gender__c = '';
        l.TXT_Suppliers_of_the_farm__c = '';
        l.CHK_Consent_Accept_Terms__c = true;
        l.CHK_Consent_Newsletters__c = false;
        l.CHK_Consent_Marketing_material__c = false;
        l.CHK_Consent_Contact_by_phone__c = false;
        l.CHK_Consent_Contact_by_email__c = false;
        l.CHK_Consent_Contact_by_fax__c = false;
        l.CHK_Consent_Contact_by_SMS__c = false;
        l.CHK_Consent_Contact_by_postal__c = false;
        l.LeadSource = 'DEKALB';
        
        insert l;
        
        REST_LeadRegistration.LeadWrapper request = new  REST_LeadRegistration.LeadWrapper();
        request.status = null;
        request.elementId = null;
        request.token = null;
        request.lead = l;
        
        String JsonMsg = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/leadRegistration';    //Request URL
        req.httpMethod = 'POST';    //HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadRegistration.LeadWrapper response = new  REST_LeadRegistration.LeadWrapper();
        response = REST_LeadRegistration.createLead(request);
        
        System.assert(response.status.contains('Updated Lead'));
        
        Test.stopTest();        
    }
    
    static testmethod void testLeadToCheck2()
    {
        //Contact
        Contact c = new Contact();
        c.FirstName = 'testContact';            
        c.LastName = 'testContact';
        c.Birthdate = System.today();
        c.MailingCountry = 'country';
        c.MailingState = 'state';
        c.MailingCity = 'city';
        c.MailingPostalCode = '0000';
        c.MailingStreet = 'street';
        c.Email = 'test@test.com';
        c.Phone = '666666666';
        c.Fax = '';
        c.NUM_Farm_size_per_crop__c = 100;
        c.DE_Website__c = '';
        c.TXT_Company__c = 'company';
        c.Position__c = '';
        c.TXT_VAT_ID__c = '';
        c.PICK_User_category__c = 'farmer';
        c.PICK_Farm_usage__c = '';
        c.Gender__c = '';
        c.TXT_Suppliers_of_the_farm__c = '';
        c.Data_Privacy_Agreement__c = true;
        c.CHK_Consent_Newsletters__c = false;
        c.Marketing_Agreement__c = false;
        c.CHK_Consent_Contact_by_phone__c = false;
        c.AgreesEmail__c = false;
        c.CHK_Consent_Contact_by_fax__c = false;
        c.AgreesSMS__c = false;
        c.AgreesMail__c = false;
        c.LeadSource = 'DEKALB';
        
        insert c;
        
        Lead l = new Lead();
        l.FirstName = 'testLead';            
        l.LastName = 'testLead';
        l.DAT_Birthday__c = System.today();
        l.Country = 'country1';
        l.State = 'state1';
        l.City = 'city1';
        l.PostalCode = '0000';
        l.Street = 'street1';
        l.Email = 'test@test.com';
        l.Phone = '666666666';
        l.Fax = '';
        l.NUM_Farm_size_per_crop__c = 100;
        l.Website = '';
        l.Company = 'company';
        l.TXT_Position_in_the_company__c = '';
        l.TXT_VAT_ID__c = '';
        l.PICK_User_category__c = 'farmer';
        l.PICK_Farm_usage__c = '';
        l.PICK_Gender__c = '';
        l.TXT_Suppliers_of_the_farm__c = '';
        l.CHK_Consent_Accept_Terms__c = true;
        l.CHK_Consent_Newsletters__c = false;
        l.CHK_Consent_Marketing_material__c = false;
        l.CHK_Consent_Contact_by_phone__c = false;
        l.CHK_Consent_Contact_by_email__c = false;
        l.CHK_Consent_Contact_by_fax__c = false;
        l.CHK_Consent_Contact_by_SMS__c = false;
        l.CHK_Consent_Contact_by_postal__c = false;
        l.LeadSource = 'DEKALB';
        
        REST_LeadRegistration.LeadWrapper request = new  REST_LeadRegistration.LeadWrapper();
        request.status = null;
        request.elementId = null;
        request.token = null;
        request.lead = l;
        
        String JsonMsg = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/leadToCheck';    //Request URL
        req.httpMethod = 'POST';    //HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadRegistration.LeadWrapper response = new  REST_LeadRegistration.LeadWrapper();
        response = REST_LeadRegistration.createLead(request);
        
        System.assert(response.status.contains('Updated Contact'));
        
        Test.stopTest();        
    }
    
    static testmethod void testLeadToCheck3()
    {
        Lead l = new Lead();
        l.FirstName = 'testLead';            
        l.LastName = 'testLead';
        l.DAT_Birthday__c = System.today();
        l.Country = 'country1';
        l.State = 'state1';
        l.City = 'city1';
        l.PostalCode = '0000';
        l.Street = 'street1';
        l.Email = 'test@test.com';
        l.Phone = '666666666';
        l.Fax = '';
        l.NUM_Farm_size_per_crop__c = 100;
        l.Website = '';
        l.Company = 'company';
        l.TXT_Position_in_the_company__c = '';
        l.TXT_VAT_ID__c = '';
        l.PICK_User_category__c = 'farmer';
        l.PICK_Farm_usage__c = '';
        l.PICK_Gender__c = '';
        l.TXT_Suppliers_of_the_farm__c = '';
        l.CHK_Consent_Accept_Terms__c = true;
        l.CHK_Consent_Newsletters__c = false;
        l.CHK_Consent_Marketing_material__c = false;
        l.CHK_Consent_Contact_by_phone__c = false;
        l.CHK_Consent_Contact_by_email__c = false;
        l.CHK_Consent_Contact_by_fax__c = false;
        l.CHK_Consent_Contact_by_SMS__c = false;
        l.CHK_Consent_Contact_by_postal__c = false;
        l.LeadSource = 'DEKALB';
        
        REST_LeadRegistration.LeadWrapper request = new  REST_LeadRegistration.LeadWrapper();
        request.status = null;
        request.elementId = null;
        request.token = null;
        request.lead = l;
        
        String JsonMsg = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/leadToCheck';    //Request URL
        req.httpMethod = 'POST';    //HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadRegistration.LeadWrapper response = new REST_LeadRegistration.LeadWrapper();
        response = REST_LeadRegistration.createLead(request);
        
        System.assert(response.status.contains('Create Lead'));
        
        Test.stopTest();
        
    }
}