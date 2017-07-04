public with sharing class LeadObtainDatalinkController {

    public String leadEmail { get; set; }
    public String origin {get; set;}
    private List<Lead> leads;
    private List<Contact> contacts;
    
    String language;
    
    public LeadObtainDatalinkController() {
    	
    	origin = apexPages.currentPage().getParameters().get('origin');
    	language = apexPages.currentPage().getParameters().get('lang');
    }
    
    public PageReference send()
    {
        if(!String.isEmpty(leadEmail))
        { 
            leads = [SELECT Id, CHK_Send_Email_Opt_Out__c, LeadSource, TXT_Language__c FROM Lead WHERE Email =: leadEmail AND Status = 'Confirmed'];
            contacts = [SELECT Id, CHK_Send_Email_Opt_Out__c, LeadSource, TXT_Language__c FROM Contact WHERE Email =: leadEmail];
            
            //Lead and Contact not found 
            if(leads.isEmpty() && contacts.isEmpty())
            {            	
            	return new PageReference('/' + 'LeadWebOptOutError' + '?origin=' + origin + '&lang=' + language);
            } 
            else if(!leads.isEmpty())
            {
                leads[0].CHK_Send_Email_Opt_Out__c= true;
                origin = leads[0].LeadSource;
                language = leads[0].TXT_Language__c;
                update leads[0];
                return new PageReference('/' + 'LeadWebOptOutSuccess' + '?origin=' + origin + '&lang=' + language);
            }
            else if(!contacts.isEmpty())
            {
                contacts[0].CHK_Send_Email_Opt_Out__c = true;
                origin = contacts[0].LeadSource;
                language = contacts[0].TXT_Language__c;
                update contacts[0]; 
                return new PageReference('/' + 'LeadWebOptOutSuccess' + '?origin=' + origin + '&lang=' + language);
            }
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.SLC_site_modif_mandatory));
        return null;
    }

}