public with sharing class TriggerLeadCheckDuplicates implements Triggers.Handler {
    
    map<String, Lead> mapLeadEmail = new map<String, Lead>();
    list<Lead>  leadsUpdate = new list<Lead>();
    list<Contact> contactsUpdate = new list<Contact>();
    list<Lead>  newLeadsUpdate = new list<Lead>();
    list<Task> tasks = new list<Task>();
    
    public void handle()
    {
        for(Lead l : (list<Lead>)trigger.new)
        {
            if(l.Status == 'Confirmed') mapLeadEmail.put(l.Email,l); //map New Confirmed Lead
        }
        
        //Leads Same Email Address
        list<Lead> leads = new list<Lead>();
        list<Contact> contacts = new list<Contact>();
        
        //Old Leads
        leads = [SELECT Id, FirstName, LastName, DAT_Birthday__c, Country, City, PostalCode, Street, Email, Phone, NUM_Farm_size_per_crop__c, Website, Company, TXT_Position_in_the_company__c, 
        TXT_VAT_ID__c, PICK_Farm_usage__c, PICK_Gender__c, TXT_Suppliers_of_the_farm__c, CHK_Consent_Accept_Terms__c, CHK_Consent_Newsletters__c, CHK_Consent_Marketing_material__c, CHK_Consent_Contact_by_phone__c,
        CHK_Consent_Contact_by_email__c, CHK_Consent_Contact_by_fax__c, CHK_Consent_Contact_by_SMS__c, CHK_Consent_Contact_by_postal__c, LeadSource, Status, OwnerId, TXT_ClientQuestion__c         
        FROM Lead WHERE isConverted = false AND Status = 'Confirmed' AND Email IN :mapLeadEmail.keySet() AND Id NOT IN :Trigger.newMap.keySet()];
        
        //Old Contacts
        contacts = [SELECT Id, FirstName, LastName, Birthdate, MailingCountry, MailingState, MailingCity, MailingPostalCode, MailingStreet, Email, Phone, Fax, NUM_Farm_size_per_crop__c,
        DE_Website__c, TXT_Company__c, Position__c, TXT_VAT_ID__c, PICK_User_category__c, PICK_Farm_usage__c, Gender__c, TXT_Suppliers_of_the_farm__c, Data_Privacy_Agreement__c, AgreesEmail__c, CHK_Consent_Contact_by_fax__c,
        CHK_Consent_Contact_by_phone__c, AgreesMail__c, Marketing_Agreement__c, CHK_Consent_Newsletters__c, AgreesSMS__c, OwnerId, GC_Comment_Text__c
        FROM Contact WHERE Email IN :mapLeadEmail.keySet()];

        //campaignMembers = [SELECT Id, CampaignId, Lead, Email, Contact FROM CampaignMember WHERE Email IN :mapLeadEmail.keySet()];
        
        //LEADS
        for(Lead l : leads)
        {
                //Lead founded
                if(l.Status == 'Confirmed')
                {
                    //Task
                    Task t = new Task();
                    t.WhoId = l.Id;
                    t.OwnerId = l.OwnerId;
                    t.Status = 'Not started';
                    t.Subject = 'Lead contacted again';                    
                    t.ActivityDate = System.Today();
                    //tasks.add(t);
                    
                    //Copy Information New Lead to Old Lead
                    if(l.Email != null)
                    {
                        Lead newLead = mapLeadEmail.get(l.Email);

                        t.Description = newLead.TXT_ClientQuestion__c;

                        l.FirstName = newLead.FirstName;
                        l.LastName = newLead.LastName;
                        l.DAT_Birthday__c = newLead.DAT_Birthday__c;
                        l.Country = newLead.Country;
                        l.State = newLead.State;
                        l.City = newLead.City;
                        l.PostalCode = newLead.PostalCode;
                        l.Street = newLead.Street;
                        l.Email = newLead.Email;
                        l.Phone = newLead.Phone;
                        l.Fax = newLead.Fax;
                        l.NUM_Farm_size_per_crop__c = newLead.NUM_Farm_size_per_crop__c;
                        l.Website = newLead.Website;
                        l.Company = newLead.Company;
                        l.TXT_Position_in_the_company__c = newLead.TXT_Position_in_the_company__c;
                        l.TXT_VAT_ID__c = newLead.TXT_VAT_ID__c;
                        l.PICK_User_category__c = newLead.PICK_User_category__c;
                        l.PICK_Farm_usage__c = newLead.PICK_Farm_usage__c;
                        l.PICK_Gender__c = newLead.PICK_Gender__c;
                        l.TXT_Suppliers_of_the_farm__c = newLead.TXT_Suppliers_of_the_farm__c;
                        l.CHK_Consent_Accept_Terms__c = newLead.CHK_Consent_Accept_Terms__c;
                        l.CHK_Consent_Newsletters__c = newLead.CHK_Consent_Newsletters__c;
                        l.CHK_Consent_Marketing_material__c = newLead.CHK_Consent_Marketing_material__c;
                        l.CHK_Consent_Contact_by_phone__c = newLead.CHK_Consent_Contact_by_phone__c;
                        l.CHK_Consent_Contact_by_email__c = newLead.CHK_Consent_Contact_by_email__c;
                        l.CHK_Consent_Contact_by_fax__c = newLead.CHK_Consent_Contact_by_fax__c;
                        l.CHK_Consent_Contact_by_SMS__c = newLead.CHK_Consent_Contact_by_SMS__c;
                        l.CHK_Consent_Contact_by_postal__c = newLead.CHK_Consent_Contact_by_postal__c;
                        l.LeadSource= newLead.LeadSource;

                        //Start of Changes Feb 2017
                        //Italy
                        if(newLead.NUM_JACKET_M_L__c != null || newLead.NUM_JACKET_XL_XXL__c != null)
                        {
                            l.NUM_JACKET_M_L__c = newLead.NUM_JACKET_M_L__c;
                            l.NUM_JACKET_XL_XXL__c = newLead.NUM_JACKET_XL_XXL__c;
                        }
                        //Germany
                        if(newLead.NUM_DKC3360__c != null || newLead.NUM_DKC3560__c != null)
                        {
                            l.NUM_DKC3360__c = newLead.NUM_DKC3360__c;
                            l.NUM_DKC3560__c = newLead.NUM_DKC3560__c;
                        }
                        //France
                        if(newLead.NUM_Jacket_size_M__c != null || newLead.NUM_Jacket_size_L__c != null || newLead.NUM_Jacket_size_XL__c != null || newLead.NUM_Jacket_size_XXL__c != null)
                        {
                            l.NUM_Jacket_size_M__c = newLead.NUM_Jacket_size_M__c;
                            l.NUM_Jacket_size_L__c = newLead.NUM_Jacket_size_L__c;
                            l.NUM_Jacket_size_XL__c = newLead.NUM_Jacket_size_XL__c;
                            l.NUM_Jacket_size_XXL__c = newLead.NUM_Jacket_size_XXL__c;
                        }
                        //Romania
                        /*
                        if(newLead.NUM_DKC4964__c != null)
                        {
                            l.NUM_DKC4964__c = newLead.NUM_DKC4964__c;
                        }
                        */
                        //Poland
                        if(newLead.NUM_DKC2931__c != null || newLead.NUM_DKC3050__c != null || newLead.NUM_DKC3441__c != null || newLead.NUM_DKC3623__c != null || newLead.NUM_DKC3939__c != null)
                        {
                            l.NUM_DKC2931__c = newLead.NUM_DKC2931__c;
                            l.NUM_DKC3050__c = newLead.NUM_DKC3050__c;
                            l.NUM_DKC3441__c = newLead.NUM_DKC3441__c;
                            l.NUM_DKC3623__c = newLead.NUM_DKC3623__c;
                            l.NUM_DKC3939__c = newLead.NUM_DKC3939__c;
                        }
                        l.NUM_Corn_Total_Acreages__c = newLead.NUM_Corn_Total_Acreages__c;
                        l.NUM_CornSilage_Total_Acres__c = newlead.NUM_CornSilage_Total_Acres__c;
                        l.NUM_Total_Acreages_OSR__c = newLead.NUM_Total_Acreages_OSR__c;
                        //End of Changes Feb 2017
                                                
                        //Delete New Lead
                        newLead.Status = 'Already a Lead';
                        newLead.LKP_masterLead__c = l.Id;
                        newLead.OwnerId = l.OwnerId;
                        Util.resetLead(newLead);
                        
                        //Send Email
                        l.CHK_sendMailDupRequest__c = true;
                    }
                    leadsUpdate.add(l);   
                    tasks.add(t);                              
                                             
                }                     
                    
        }
        
        list<CampaignMember> listMembers = new list<CampaignMember>();
        
        //CONTACTS
        for(Contact c : contacts)
        {
                //Task
                Task t = new Task();
                t.WhoId = c.Id;
                t.OwnerId = c.OwnerId;
                t.Status = 'Not started';
                t.Subject = 'Lead contacted again';
                t.ActivityDate = System.Today();
                //tasks.add(t);
                
                //Copy Information New Lead to Contact
                if(c.Email != null)
                {
                    Lead newLead = mapLeadEmail.get(c.Email);

                    t.Description = newLead.TXT_ClientQuestion__c;

                    c.FirstName = newLead.FirstName;
                    c.LastName = newLead.LastName;
                    c.Birthdate = newLead.DAT_Birthday__c;
                    c.MailingCountry = newLead.Country;
                    c.MailingState = newLead.State;
                    c.MailingCity = newLead.City;
                    c.MailingPostalCode = newLead.PostalCode;
                    c.MailingStreet = newLead.Street;
                    c.Email = newLead.Email;
                    c.Phone = newLead.Phone;
                    c.Fax = newLead.Fax;
                    c.NUM_Farm_size_per_crop__c = newLead.NUM_Farm_size_per_crop__c;
                    c.DE_Website__c = newLead.Website;
                    c.TXT_Company__c = newLead.Company;
                    c.Position__c = newLead.TXT_Position_in_the_company__c;
                    c.TXT_VAT_ID__c = newLead.TXT_VAT_ID__c;
                    c.PICK_User_category__c = newLead.PICK_User_category__c;
                    c.PICK_Farm_usage__c = newLead.PICK_Farm_usage__c;
                    c.Gender__c = newLead.PICK_Gender__c;
                    c.TXT_Suppliers_of_the_farm__c = newLead.TXT_Suppliers_of_the_farm__c;
                    c.Data_Privacy_Agreement__c = newLead.CHK_Consent_Accept_Terms__c;
                    c.CHK_Consent_Newsletters__c = newLead.CHK_Consent_Newsletters__c;
                    c.Marketing_Agreement__c = newLead.CHK_Consent_Marketing_material__c;
                    c.CHK_Consent_Contact_by_phone__c = newLead.CHK_Consent_Contact_by_phone__c;
                    c.AgreesEmail__c = newLead.CHK_Consent_Contact_by_email__c;
                    c.CHK_Consent_Contact_by_fax__c = newLead.CHK_Consent_Contact_by_fax__c;
                    c.AgreesSMS__c = newLead.CHK_Consent_Contact_by_SMS__c;
                    c.AgreesMail__c = newLead.CHK_Consent_Contact_by_postal__c;
                    c.LeadSource= newLead.LeadSource;

                    //Start of Changes Feb 2017
                    //Italy
                    if(newLead.NUM_JACKET_M_L__c != null || newLead.NUM_JACKET_XL_XXL__c != null)
                    {
                        c.NUM_JACKET_M_L__c = newLead.NUM_JACKET_M_L__c;
                        c.NUM_JACKET_XL_XXL__c = newLead.NUM_JACKET_XL_XXL__c;
                    }
                    //Germany
                    if(newLead.NUM_DKC3360__c != null || newLead.NUM_DKC3560__c != null)
                    {
                        c.NUM_DKC3360__c = newLead.NUM_DKC3360__c;
                        c.NUM_DKC3560__c = newLead.NUM_DKC3560__c;
                    }
                    //France
                    if(newLead.NUM_Jacket_size_M__c != null || newLead.NUM_Jacket_size_L__c != null || newLead.NUM_Jacket_size_XL__c != null || newLead.NUM_Jacket_size_XXL__c != null)
                    {
                        c.NUM_Jacket_size_M__c = newLead.NUM_Jacket_size_M__c;
                        c.NUM_Jacket_size_L__c = newLead.NUM_Jacket_size_L__c;
                        c.NUM_Jacket_size_XL__c = newLead.NUM_Jacket_size_XL__c;
                        c.NUM_Jacket_size_XXL__c = newLead.NUM_Jacket_size_XXL__c;
                    }
                    //Romania
                    /*
                    if(newLead.NUM_DKC4964__c != null)
                    {
                        c.NUM_DKC4964__c = newLead.NUM_DKC4964__c;
                    }
                    */
                    //Poland
                    if(newLead.NUM_DKC2931__c != null || newLead.NUM_DKC3050__c != null || newLead.NUM_DKC3441__c != null || newLead.NUM_DKC3623__c != null || newLead.NUM_DKC3939__c != null)
                    {
                        c.NUM_DKC2931__c = newLead.NUM_DKC2931__c;
                        c.NUM_DKC3050__c = newLead.NUM_DKC3050__c;
                        c.NUM_DKC3441__c = newLead.NUM_DKC3441__c;
                        c.NUM_DKC3623__c = newLead.NUM_DKC3623__c;
                        c.NUM_DKC3939__c = newLead.NUM_DKC3939__c;
                    }
                    c.NUM_Corn_Total_Acreages__c = newLead.NUM_Corn_Total_Acreages__c;
                    c.NUM_CornSilage_Total_Acres__c = newlead.NUM_CornSilage_Total_Acres__c;
                    c.NUM_Total_Acreages_OSR__c = newLead.NUM_Total_Acreages_OSR__c;
                    //End of Changes Feb 2017                    
                    
                    //Delete New Lead
                    newLead.Status = 'Already a Contact';
                    newLead.LKP_masterContact__c = c.Id;
                    newLead.OwnerId= c.OwnerId;
                    Util.resetLead(newLead);
                    
                    //Send Email
                    c.CHK_sendMailDupRequest__c = true;

                    //Create CampaignMember if Lead has another Event
                    //for (CampaignMember cm : campaignMembers){
                        if(newLead.LKP_Campaign__c != null)
                        {
                            listMembers.add(new CampaignMember(CampaignId=newLead.LKP_Campaign__c, ContactId=c.Id));
                            newLead.LKP_Campaign__c = null;
                        }
                    //}

                    try {
                        insert listMembers;
                    } catch(DmlException e) {
                        for(Integer i = 0; i < e.getNumDml(); i++)
                            system.debug('DML Error: ' + e.getDmlMessage(i));
                    }

                }                
                contactsUpdate.add(c);
                tasks.add(t);
        }
                    
        update leadsUpdate;
        update contactsUpdate;
        insert tasks;
        
    }
}