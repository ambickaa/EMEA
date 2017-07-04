public without sharing class TriggerLeadUnconfirmedDeletion implements Triggers.Handler 
{   
    public void handle()
    {
        User userAdmin = [SELECT Id, Name, Profile.name FROM user WHERE User.country = 'HQ' AND isActive = TRUE LIMIT 1];
        
        for(Lead l :  (list<Lead>)Trigger.new)
        {
            if((((Map<Id, Lead>)trigger.oldMap).get(l.Id).Status != l.Status) && l.Status == 'Unconfirmed')
            {
                //Reset Lead Fields
                l.FirstName = '---';
                l.LastName = '---';
                l.DAT_Birthday__c = null;
                l.Country = '---';
                l.State = '---';
                l.City = '---';
                l.PostalCode = '---';
                l.Street = '---';
                l.Email = null;
                l.Phone = '---';
                l.Fax = '---';
                l.NUM_Farm_size_per_crop__c = null;
                l.Website = null;
                l.Company = '---';
                l.TXT_Position_in_the_company__c = '---';
                l.TXT_VAT_ID__c = '---';
                l.PICK_User_category__c = null;
                l.PICK_Farm_usage__c = null;
                l.PICK_Gender__c = null;
                l.TXT_Suppliers_of_the_farm__c = '---';
                l.CHK_Consent_Accept_Terms__c = true;
                l.CHK_Consent_Newsletters__c = false;
                l.CHK_Consent_Marketing_material__c = false;
                l.CHK_Consent_Contact_by_phone__c = false;
                l.CHK_Consent_Contact_by_email__c = false;
                l.CHK_Consent_Contact_by_fax__c = false;
                l.CHK_Consent_Contact_by_SMS__c = false;
                l.CHK_Consent_Contact_by_postal__c = false;
                l.LeadSource= null;
                l.TXT_Security_Token__c = '---';
                system.debug('aqui no entra');
                l.OwnerId = userAdmin.Id;               
            }
        }
        
    }
}