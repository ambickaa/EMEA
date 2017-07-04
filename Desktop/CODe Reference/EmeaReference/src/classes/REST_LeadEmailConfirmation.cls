@RestResource(urlMapping='/LeadEmailConfirmation/*') 
global without sharing class REST_LeadEmailConfirmation
{
    @HttpPost
    global static EmailConfirmationWrapper LeadEmailConfirmation(EmailConfirmationWrapper emailApproved)
    {
        EmailConfirmationWrapper EmailConfirmationResponse = new EmailConfirmationWrapper();       
        List<Lead> ConfirmedLead = [SELECT id FROM Lead WHERE email =: emailApproved.email AND status= 'Confirmed' Limit 1];

        if (ConfirmedLead.size()>0) EmailConfirmationResponse.email = emailApproved.email;
        else {
            List<Contact> ConfirmedContact = [SELECT id FROM Contact WHERE email =: emailApproved.email AND Status__c= 'Active' Limit 1];
            if (ConfirmedContact.size()>0)  EmailConfirmationResponse.email = emailApproved.email;
            else EmailConfirmationResponse.email = '';
        }       
        return EmailConfirmationResponse;
    }
    
    global class EmailConfirmationWrapper
    {
        public String email;
    }
}