@isTest
private class Test_REST_LeadToUpdate
{
    static testmethod void testLeadUpdate()
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
        
        l.FirstName = 'testLead';
        
        REST_LeadToUpdate.LeadWrapper request = new  REST_LeadToUpdate.LeadWrapper();
        request.status = null;
        request.elementId = l.Id;
        request.token = null;
        request.lead = l;
        
        String JsonMsg = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/leadToUpdate';    //Request URL
        req.httpMethod = 'POST';    //HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadToUpdate.LeadWrapper response = new  REST_LeadToUpdate.LeadWrapper();
        response = REST_LeadToUpdate.createLead(request);
        
        System.assert(response.status.contains('Updated Lead'));
        
        Test.stopTest();        
    }
    
    static testmethod void testContactToUpdate()
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
        
        REST_LeadToUpdate.LeadWrapper request = new  REST_LeadToUpdate.LeadWrapper();
        request.status = null;
        request.elementId = c.Id;
        request.token = null;
        request.lead = l;
        
        String JsonMsg = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/leadToUpdate';    //Request URL
        req.httpMethod = 'POST';    //HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadToUpdate.LeadWrapper response = new  REST_LeadToUpdate.LeadWrapper();
        response = REST_LeadToUpdate.createLead(request);
        
        System.assert(response.status.contains('Updated Contact'));
        
        Test.stopTest();        
    }
    
    static testmethod void testLeadConverted()
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
        l.Status = 'Open';
        insert l;
        
        l.Status = 'Confirmed';
        update l;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        lc.setOwnerId(UserInfo.getUserId());
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        REST_LeadToUpdate.LeadWrapper request = new  REST_LeadToUpdate.LeadWrapper();
        request.status = null;
        request.elementId = l.Id;
        request.token = null;
        request.lead = l;
        
        String JsonMsg = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/leadToUpdate';    //Request URL
        req.httpMethod = 'POST';    //HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_LeadToUpdate.LeadWrapper response = new REST_LeadToUpdate.LeadWrapper();
        response = REST_LeadToUpdate.createLead(request);
        
        System.assert(response.status.contains('Updated Contact'));
        
        Test.stopTest();
        
    }
}