public with sharing class LeadConfirmationController {
    
    public Lead lead = null;
    public Contact contact = null;
    public String origin {get; set;}
    public boolean error {get; set;}
    public String country {get;set;}
    public String countryISO {get;set;}
    public String resourceName {get;set;}
    public boolean hasBanner {get; set;}
    
    String idParam;
    String tokenParam;
    String originUrl;
    String language;
    String emailChanged;
    
    List<Lead> leads;
       
    public LeadConfirmationController()
    {
        country='';
        countryISO='';
        hasBanner = false;
        error = true;
        idParam = apexPages.currentPage().getParameters().get('id');
        tokenParam = apexPages.currentPage().getParameters().get('token');
        originUrl = apexPages.currentPage().getParameters().get('origin') == null ? 'DEKALB' : apexPages.currentPage().getParameters().get('origin') ;
        language= apexPages.currentPage().getParameters().get('lang') == null ? 'en' : apexPages.currentPage().getParameters().get('lang');
        emailChanged = apexPages.currentPage().getParameters().get('email');
        origin = originUrl;
        
        if(idParam == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_confirm_KO1 + ' ' + Label.SLC_site_confirm_KO2));
        
        //Lead        
        else if(idParam.substring(0,3) == '00Q')       
        {
            leads = [SELECT Id, Email, TXT_Email_modified__c, CHK_Email_change_confirmed__c , TXT_Security_Token__c, Status, LeadSource, TXT_Language__c, LKP_Country__r.Name, LKP_Country__r.TXT_Country_ISO_Code__c FROM Lead WHERE Id =: apexPages.currentPage().getParameters().get('id') AND TXT_Security_Token__c =: apexPages.currentPage().getParameters().get('token')  AND Status != 'Unconfirmed' LIMIT 1];
            
            if(!leads.isEmpty())
            {
                lead = leads[0];
                origin = leads[0].LeadSource;
                language = leads[0].TXT_Language__c;
                country = leads[0].LKP_Country__r.Name;
                countryISO = leads[0].LKP_Country__r.TXT_Country_ISO_Code__c;
            }
        }
        //Contact
        else if(idParam.substring(0,3) == '003')
        {
            List<Contact> contacts = [SELECT Id, Email, TXT_Email_modified__c, CHK_Email_change_confirmed__c , TXT_Security_Token__c, LeadSource, TXT_Language__c, CountryRef__r.Name, CountryRef__r.TXT_Country_ISO_Code__c FROM Contact WHERE Id =: apexPages.currentPage().getParameters().get('id') AND TXT_Security_Token__c =: apexPages.currentPage().getParameters().get('token') LIMIT 1];
            
            if(!contacts.isEmpty())
            {
                contact = contacts[0];
                origin = contacts[0].LeadSource;
                language = contacts[0].TXT_Language__c;
                country = contacts[0].CountryRef__r.Name;
                countryISO = contacts[0].CountryRef__r.TXT_Country_ISO_Code__c;
            }
        }

        resourceName = 'SLC_' + countryISO + '_DEKALB';
        List<StaticResource> ListResource = [SELECT Name FROM StaticResource WHERE Name =: resourceName];
        if(ListResource.size()>0){
            hasBanner = true;
        }
    }  


    
    public PageReference checkLead()
    {
        error = true;
        //Lead Email has been changed
        if(lead != null && emailChanged == 'true')
        {
            lead.Email = lead.TXT_Email_modified__c;
            lead.CHK_Email_change_confirmed__c = true;
            lead.TXT_Email_modified__c = null;
            update lead;
            
            PageReference page = new PageReference('/' + 'LeadSuccesConfirmation' + '?id=' + idParam + '&token=' + tokenParam+ '&lang='+language  + '&origin=' + originUrl);         
            error = false;
            return null;
        }
        else if(contact != null && emailChanged == 'true')
        {
            contact.Email = contact.TXT_Email_modified__c;
            contact.CHK_Email_change_confirmed__c = true;
            contact.TXT_Email_modified__c = null;
            update contact;
            
            PageReference page = new PageReference('/' + 'LeadSuccesConfirmation' + '?id=' + idParam + '&token=' + tokenParam+ '&lang='+language  + '&origin=' + originUrl);         
            error = false;
            return null;
        }
        //Lead has been found
        else if(lead != null) 
        {   
            System.debug(lead.Id);
            lead.Status = 'Confirmed';
            update lead;
            
            leads = [SELECT Id, TXT_Security_Token__c, Status, LeadSource, TXT_Language__c FROM Lead WHERE Id =: lead.Id LIMIT 1];
            System.debug(leads[0].TXT_Security_Token__c);
            
            PageReference page = new PageReference('/' + 'LeadSuccesConfirmation' + '?id=' + leads[0].Id + '&token=' + leads[0].TXT_Security_Token__c + '&lang='+leads[0].TXT_Language__c + '&origin=' + leads[0].LeadSource);         
            page.setRedirect(false);
            error = false;
            return null;
        }
        else
        {           
            PageReference page = new PageReference('/' + 'LeadErrorConfirmation' + '?origin=' + originUrl + '&lang='+language);
            error=true;
            return null;
        }
        
        return null;
    }

}