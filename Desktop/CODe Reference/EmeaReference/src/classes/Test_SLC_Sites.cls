@isTest
public with sharing class Test_SLC_Sites 
{ 
    private static testmethod void LeadConfirmationSite()
    {
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'GroupFarmSite');
        insert lcf;
        
        //BEGIN check lead confirmation site - Access to the site and initialize controller- Lead ok
        Lead test1 = new Lead(email='testemailConfirmOK@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        test1 = [SELECT id, name, TXT_security_token__c, leadSource from lead where id=:test1.id];

        PageReference pageRef = Page.LeadConfirmation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', test1.id);
        ApexPages.currentPage().getParameters().put('token', test1.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test1.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadConfirmationController  controller = new LeadConfirmationController();
        controller.checkLead();
        
        test1 = [SELECT id, name, TXT_security_token__c, leadSource, status from lead where id=:test1.id];
        system.assertEquals(test1.status, 'Confirmed');
        //END check lead confirmation site - Access to the site and initialize controller- Lead ok
        
        //BEGIN check lead confirmation site - Access to the site and initialize controller- Unexisting lead
        Lead test2 = new Lead(email='testemailConfirmKO@asdfasdfasdf.com', leadSource='DEKALB', lastname='test2', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test2;
        test2 = [SELECT id, name, TXT_security_token__c, leadSource from lead where id=:test2.id];

        PageReference pageRef2 = Page.LeadConfirmation;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('id', test2.id);
        ApexPages.currentPage().getParameters().put('token', 'not a token');
        ApexPages.currentPage().getParameters().put('origin', test2.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadConfirmationController  controller2 = new LeadConfirmationController();
        controller2.checkLead();
        
        test2 = [SELECT id, name, TXT_security_token__c, leadSource, status from lead where id=:test2.id];
        system.assertEquals(test2.status, 'Pending confirmation');
        //END check lead confirmation site - Access to the site and initialize controller- Unexisting lead
        
        //BEGIN check contact confirmation site - Access to the site and initialize controller- Exisitng Contact
        Contact test3 = new Contact(email='testemailContactConfirmOK@asdfasdfasdf.com', leadSource='DEKALB', lastname='test3', countryref__c=c.Id, Data_Privacy_Agreement__c = true);
        insert test3;
        test3 = [SELECT id, name, TXT_security_token__c, leadSource, TXT_Email_modified__c , CHK_Confirm_Email_Changed__c from Contact where id=:test3.id];
        
        PageReference pageRef3 = Page.LeadConfirmation;
        Test.setCurrentPage(pageRef3);
        ApexPages.currentPage().getParameters().put('id', test3.id);
        ApexPages.currentPage().getParameters().put('token', test3.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test3.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        ApexPages.currentPage().getParameters().put('email', 'true');
        
        LeadConfirmationController  controller3 = new LeadConfirmationController();
        //END check lead confirmation site - Access to the site and initialize controller- Exisitng Contact
        
        //BEGIN check contact confirmation site - Access to the site and initialize controller- Change email Contact
        test3.TXT_Email_modified__c  = 'testemailContactChanged@asdfasdfasdf.com';
        test3.CHK_Confirm_Email_Changed__c = true;
        update test3;
        LeadConfirmationController  controller4 = new LeadConfirmationController();
        controller4.checkLead();
        test3 = [SELECT id, name, Email from Contact WHERE Id =: test3.Id];
        system.assertEquals(test3.Email, 'testemailcontactchanged@asdfasdfasdf.com');        
    }
    
    private static testmethod void LeadOptOutSite()
    {
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'GroupFarmSite');
        insert lcf;
        
        //BEGIN check lead opt-out site - Lead found
        Lead test1 = new Lead(email='testemailConfirmOK@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        test1.status='Confirmed';
        update test1;
        
        test1 = [SELECT id, name, TXT_security_token__c, leadSource from lead where id=:test1.id];

        PageReference pageRef = Page.LeadWebOptOut;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('origin', test1.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadObtainDatalinkController  controller = new LeadObtainDatalinkController();
        controller.leadEmail='testemailConfirmOK@asdfasdfasdf.com';
        String nextPage = controller.send().getUrl();
        system.debug('devuelve: '+nextPage);
        system.assert(nextPage.contains('Success'));
        //END check lead opt-out site - Lead found
        
        //BEGIN check lead opt-out site - Contact found
        Contact testContact = new Contact(lastName='testContact', email='testemailContact@asdfasdfasdf.com', countryref__c=c.Id);
        insert testContact;
        
        PageReference pageRef2 = Page.LeadWebOptOut;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('origin', 'DEKALB');
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadObtainDatalinkController  controller2 = new LeadObtainDatalinkController();
        controller2.leadEmail=testContact.email;
        nextPage = controller2.send().getUrl();
        system.debug('devuelve: '+nextPage);
        system.assert(nextPage.contains('Success'));
        //END check lead opt-out site - Lead found
        
        //BEGIN check lead opt-out site - Not existing
        PageReference pageRef3 = Page.LeadWebOptOut;
        Test.setCurrentPage(pageRef3);
        ApexPages.currentPage().getParameters().put('origin', 'DEKALB');
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadObtainDatalinkController  controller3 = new LeadObtainDatalinkController();
        controller3.leadEmail='nostExistingAddress@domain.com';
        nextPage = controller3.send().getUrl();
        system.debug('devuelve: '+nextPage);
        system.assert(nextPage.contains('LeadWebOptOutError'));
        //END check lead opt-out site - Lead found
        
        //BEGIN check lead opt-out site - Not existing
        PageReference pageRef4 = Page.LeadWebOptOut;
        Test.setCurrentPage(pageRef4);
        ApexPages.currentPage().getParameters().put('origin', 'DEKALB');
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadObtainDatalinkController  controller4 = new LeadObtainDatalinkController();
        controller4.leadEmail='';
        system.assert(controller4.send() == null);
        //END check lead opt-out site - Lead found
    }
    
    private static testmethod void LeadModificationSite()
    {
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'GroupFarmSite');
        insert lcf;
        
        //BEGIN check lead data site - Lead found
        Lead test1 = new Lead(email='testemailConfirmOK@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        test1.status='Confirmed';
        update test1;
        
        test1 = [SELECT id, name, TXT_security_token__c, leadSource from lead where id=:test1.id];

        PageReference pageRef = Page.LeadContactForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', test1.id);
        ApexPages.currentPage().getParameters().put('token', test1.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test1.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadContactFormController  controller = new LeadContactFormController();
        
        controller.test.leadFirstName='nombre manual';
        controller.save();
        test1 = [SELECT id, firstname, TXT_security_token__c, leadSource from lead where id=:test1.id];
        system.assertEquals('nombre manual', test1.FirstName);
        
        //delete
        controller.reset();
        Lead[] records = Database.query('SELECT id, firstname, TXT_security_token__c, leadSource from lead where isdeleted = false and id =\'' + test1.id + '\'');        
        system.assertEquals(true, records.isEmpty());
        
        //END check lead data site - Lead found & reset
        
        //BEGIN check lead data site - contact found & reset
        Contact testContact = new Contact(lastName='testContact', TXT_security_token__c='testToken', email='testemailContact@asdfasdfasdf.com', countryref__c=c.Id);
        insert testContact;
        

        PageReference pageRef2 = Page.LeadContactForm;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('id', testContact.id);
        ApexPages.currentPage().getParameters().put('token', testContact.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', 'DEKALB');
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadContactFormController  controller2 = new LeadContactFormController();
        
        controller2.test.leadFirstName='nombre manual';
        controller2.save();
        Contact testContactInsert = [SELECT id, firstname, TXT_security_token__c from contact where id=:testContact.id];
        system.assertEquals('nombre manual', testContactInsert.FirstName);
        
        controller2.reset();
        Contact[] records2 = Database.Query('SELECT id, firstname, TXT_security_token__c from contact where id = \'' + testContact.id +'\'');
        //testContactInsert = [SELECT id, firstname, TXT_security_token__c from contact where id=:testContact.id];
        system.assertEquals(true, records2.IsEmpty());
        //END check lead data site - contact found & reset
        
        //BEGIN retrieve picklists
        List<SelectOption> lista = controller.getGender();
        system.assertNotEquals(lista.size(), 0);
        
        lista = controller.getFarmUsage();
        system.assertNotEquals(lista.size(), 0);
        
        lista = controller.getCategory();
        system.assertNotEquals(lista.size(), 0);
        //END retrieve picklists
    }
    
    private static testmethod void LeadEmailModification()
    {
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'GroupFarmSite');
        insert lcf;
        
        //BEGIN insert lead data site - Lead found
        Lead test1 = new Lead(email='testemail1@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        test1.status='Confirmed';
        update test1;
        
        test1 = [SELECT id, name, TXT_security_token__c, leadSource from lead where id=:test1.id];
        
        PageReference pageRef = Page.LeadContactForm;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', test1.id);
        ApexPages.currentPage().getParameters().put('token', test1.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test1.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadContactFormController  controller = new LeadContactFormController();
        
        controller.test.leadFirstName='nombre manual';
        controller.save();
        test1 = [SELECT Id, FirstName, TXT_security_token__c, leadSource FROM Lead WHERE id=:test1.id];
        system.assertEquals('nombre manual', test1.FirstName);
        //END insert lead data site - Lead found
        
        //BEGIN update email aux lead data site - Lead found
        Lead test2 = [SELECT id, name, TXT_security_token__c, leadSource FROM Lead WHERE id =: test1.Id];
        ApexPages.currentPage().getParameters().put('id', test2.id);
        ApexPages.currentPage().getParameters().put('token', test2.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test2.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        controller.test.leadEmail = 'testemail2@asdfasdfasdf.com';
        controller.save();
        test2 = [SELECT id, firstname, Email, TXT_Email_modified__c, TXT_security_token__c, leadSource from lead where id=:test1.id];
        system.assertEquals('testemail2@asdfasdfasdf.com', test2.TXT_Email_modified__c);
        //END update email lead data site - Lead found
        
        //BEGIN update new email lead
        PageReference pageRefConfirm = Page.LeadConfirmation;
        Test.setCurrentPage(pageRefConfirm);
        
        ApexPages.currentPage().getParameters().put('id', test2.Id);
        ApexPages.currentPage().getParameters().put('token', test2.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test2.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        ApexPages.currentPage().getParameters().put('email', 'true');
        
        LeadConfirmationController controller2 = new LeadConfirmationController();
        controller2.checkLead();
        test2 = [SELECT id, firstname, Email, TXT_Email_modified__c, TXT_security_token__c, leadSource from lead where id=:test2.id];
        system.assertEquals('testemail2@asdfasdfasdf.com', test2.Email);
        //END update new email lead
        
    }
    private static testmethod void ContactEmailModification()
    {
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'GroupFarmSite');
        insert lcf;
        
        //BEGIN insert lead data site - Lead found
        Contact test1 = new Contact(email='testemail1@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', countryref__c=c.Id, Data_Privacy_Agreement__c = true);
        insert test1;
        
        test1 = [SELECT id, name, TXT_security_token__c, leadSource from Contact where id=:test1.id];
        
        PageReference pageRef = Page.LeadContactForm;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', test1.id);
        ApexPages.currentPage().getParameters().put('token', test1.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test1.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        LeadContactFormController  controller = new LeadContactFormController();
        
        controller.test.leadFirstName='nombre manual';
        controller.save();
        test1 = [SELECT Id, FirstName, TXT_security_token__c, leadSource FROM Contact WHERE id=:test1.id];
        system.assertEquals('nombre manual', test1.FirstName);
        //END insert lead data site - Contact found
        
        //BEGIN update email aux lead data site - Lead found
        Contact test2 = [SELECT id, name, TXT_security_token__c, leadSource FROM Contact WHERE id =: test1.Id];
        ApexPages.currentPage().getParameters().put('id', test2.id);
        ApexPages.currentPage().getParameters().put('token', test2.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test2.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        
        controller.test.leadEmail = 'testemail2@asdfasdfasdf.com';
        controller.save();
        test2 = [SELECT id, firstname, Email, TXT_Email_modified__c, TXT_security_token__c, leadSource from Contact where id=:test1.id];
        system.assertEquals('testemail2@asdfasdfasdf.com', test2.TXT_Email_modified__c);
        //END update email lead data site - Lead found
        
        
        //BEGIN update new email lead
        PageReference pageRefConfirm = Page.LeadConfirmation;
        Test.setCurrentPage(pageRefConfirm);
        
        ApexPages.currentPage().getParameters().put('id', test2.Id);
        ApexPages.currentPage().getParameters().put('token', test2.TXT_security_token__c);
        ApexPages.currentPage().getParameters().put('origin', test2.leadSource);
        ApexPages.currentPage().getParameters().put('lang', 'en');
        ApexPages.currentPage().getParameters().put('email', 'true');
        
        LeadConfirmationController controller2 = new LeadConfirmationController();
        controller2.checkLead();
        test2 = [SELECT id, firstname, Email, TXT_Email_modified__c, TXT_security_token__c, CHK_Confirm_Email_Changed__c, leadSource from Contact where id=:test2.id];
        system.assertEquals('testemail2@asdfasdfasdf.com', test2.Email);
        //END update new email lead
    }
}