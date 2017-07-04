@RestResource(urlMapping='/leadRegistration/*') 
global without sharing class REST_LeadRegistration
{
    @HttpPost
    global static LeadWrapper createLead(LeadWrapper param)
    {
        
        list<Lead> leadCheck = [SELECT Id, FirstName, LastName, DAT_Birthday__c, Country, State, City, PostalCode, Street, Email, Phone, Fax, NUM_Farm_size_per_crop__c, Website, Company, TXT_Position_in_the_company__c, TXT_VAT_ID__c, 
                                PICK_User_category__c, PICK_Farm_usage__c, PICK_Gender__c, TXT_Suppliers_of_the_farm__c, CHK_Consent_Accept_Terms__c, CHK_Consent_Newsletters__c, CHK_Consent_Marketing_material__c, 
                                CHK_Consent_Contact_by_phone__c, CHK_Consent_Contact_by_email__c, CHK_Consent_Contact_by_fax__c, CHK_Consent_Contact_by_SMS__c, CHK_Consent_Contact_by_postal__c, TXT_Security_Token__c, TXT_Distributor__c,
                                NUM_Total_Acreages_OSR__c, NUM_CornSilage_Total_Acres__c, NUM_Corn_Total_Acreages__c                              
                                FROM Lead WHERE Email =: param.lead.Email AND isConverted = false LIMIT 1];
                        
        list<Contact> contactCheck = [SELECT Id, FirstName, LastName, Birthdate, MailingCountry, MailingState, MailingCity, MailingPostalCode, MailingStreet, Email, Phone, Fax, NUM_Farm_size_per_crop__c, DE_Website__c,
                                      TXT_Company__c, Position__c, TXT_VAT_ID__c, PICK_User_category__c, PICK_Farm_usage__c, Gender__c, TXT_Suppliers_of_the_farm__c, Data_Privacy_Agreement__c, CHK_Consent_Newsletters__c,
                                      Marketing_Agreement__c, CHK_Consent_Contact_by_phone__c, AgreesEmail__c, CHK_Consent_Contact_by_fax__c, AgreesSMS__c, AgreesMail__c, LeadSource, TXT_Security_Token__c, TXT_Distributor__c,
                                      NUM_Total_Acreages_OSR__c, NUM_CornSilage_Total_Acres__c, NUM_Corn_Total_Acreages__c
                                      FROM Contact WHERE Email =: param.lead.Email LIMIT 1];

        LeadWrapper leadResponse = new LeadWrapper();
        
        //LEAD
        if(leadCheck.size() > 0)
        {        
            leadCheck[0].FirstName = param.lead.FirstName;            
            leadCheck[0].LastName = param.lead.LastName;
            leadCheck[0].DAT_Birthday__c = param.lead.DAT_Birthday__c;
            leadCheck[0].Country = param.lead.Country;
            leadCheck[0].State = param.lead.State;
            leadCheck[0].City = param.lead.City;
            leadCheck[0].PostalCode = param.lead.PostalCode;
            leadCheck[0].Street = param.lead.Street;
            leadCheck[0].Email = param.lead.Email;
            leadCheck[0].Phone = param.lead.Phone;
            leadCheck[0].Fax = param.lead.Fax;
            leadCheck[0].NUM_Farm_size_per_crop__c = param.lead.NUM_Farm_size_per_crop__c;
            leadCheck[0].Website = param.lead.Website;
            leadCheck[0].Company = param.lead.Company;
            leadCheck[0].TXT_Position_in_the_company__c = param.lead.TXT_Position_in_the_company__c;
            leadCheck[0].TXT_VAT_ID__c = param.lead.TXT_VAT_ID__c;
            leadCheck[0].PICK_User_category__c = param.lead.PICK_User_category__c;
            leadCheck[0].PICK_Farm_usage__c = param.lead.PICK_Farm_usage__c;
            leadCheck[0].PICK_Gender__c = param.lead.PICK_Gender__c;
            leadCheck[0].TXT_Suppliers_of_the_farm__c = param.lead.TXT_Suppliers_of_the_farm__c;
            leadCheck[0].CHK_Consent_Accept_Terms__c = param.lead.CHK_Consent_Accept_Terms__c;
            leadCheck[0].CHK_Consent_Newsletters__c = param.lead.CHK_Consent_Newsletters__c;
            leadCheck[0].CHK_Consent_Marketing_material__c = param.lead.CHK_Consent_Marketing_material__c;
            leadCheck[0].CHK_Consent_Contact_by_phone__c = param.lead.CHK_Consent_Contact_by_phone__c;
            leadCheck[0].CHK_Consent_Contact_by_email__c = param.lead.CHK_Consent_Contact_by_email__c;
            leadCheck[0].CHK_Consent_Contact_by_fax__c = param.lead.CHK_Consent_Contact_by_fax__c;
            leadCheck[0].CHK_Consent_Contact_by_SMS__c = param.lead.CHK_Consent_Contact_by_SMS__c;
            leadCheck[0].CHK_Consent_Contact_by_postal__c = param.lead.CHK_Consent_Contact_by_postal__c;
            leadCheck[0].TXT_Distributor__c = param.lead.TXT_Distributor__c;
            leadCheck[0].NUM_Total_Acreages_OSR__c = param.lead.NUM_Total_Acreages_OSR__c;
            leadCheck[0].NUM_CornSilage_Total_Acres__c = param.lead.NUM_CornSilage_Total_Acres__c;
            leadCheck[0].NUM_Corn_Total_Acreages__c = param.lead.NUM_Corn_Total_Acreages__c;           
            leadCheck[0].LeadSource = param.lead.LeadSource;
            leadCheck[0].status= 'Confirmed';   
            update leadCheck;
                        
            leadResponse.status = 'Updated Lead';
            leadResponse.elementId = leadCheck[0].Id;
            leadResponse.token = leadCheck[0].TXT_Security_Token__c;
        }
        //CONTACT
        else if(contactCheck.size() > 0)
        {
            contactCheck[0].FirstName = param.lead.FirstName;            
            contactCheck[0].LastName = param.lead.LastName;
            contactCheck[0].Birthdate = param.lead.DAT_Birthday__c;
            contactCheck[0].MailingCountry = param.lead.Country;
            contactCheck[0].MailingState = param.lead.State;
            contactCheck[0].MailingCity = param.lead.City;
            contactCheck[0].MailingPostalCode = param.lead.PostalCode;
            contactCheck[0].MailingStreet = param.lead.Street;
            contactCheck[0].Email = param.lead.Email;
            contactCheck[0].Phone = param.lead.Phone;
            contactCheck[0].Fax = param.lead.Fax;
            contactCheck[0].NUM_Farm_size_per_crop__c = param.lead.NUM_Farm_size_per_crop__c;
            contactCheck[0].DE_Website__c = param.lead.Website;
            contactCheck[0].TXT_Company__c = param.lead.Company;
            contactCheck[0].Position__c = param.lead.TXT_Position_in_the_company__c;
            contactCheck[0].TXT_VAT_ID__c = param.lead.TXT_VAT_ID__c;
            contactCheck[0].PICK_User_category__c = param.lead.PICK_User_category__c;
            contactCheck[0].PICK_Farm_usage__c = param.lead.PICK_Farm_usage__c;
            contactCheck[0].Gender__c = param.lead.PICK_Gender__c;
            contactCheck[0].TXT_Suppliers_of_the_farm__c = param.lead.TXT_Suppliers_of_the_farm__c;
            contactCheck[0].Data_Privacy_Agreement__c = param.lead.CHK_Consent_Accept_Terms__c;
            contactCheck[0].CHK_Consent_Newsletters__c = param.lead.CHK_Consent_Newsletters__c;
            contactCheck[0].Marketing_Agreement__c = param.lead.CHK_Consent_Marketing_material__c;
            contactCheck[0].CHK_Consent_Contact_by_phone__c = param.lead.CHK_Consent_Contact_by_phone__c;
            contactCheck[0].AgreesEmail__c = param.lead.CHK_Consent_Contact_by_email__c;
            contactCheck[0].CHK_Consent_Contact_by_fax__c = param.lead.CHK_Consent_Contact_by_fax__c;
            contactCheck[0].AgreesSMS__c = param.lead.CHK_Consent_Contact_by_SMS__c;
            contactCheck[0].AgreesMail__c = param.lead.CHK_Consent_Contact_by_postal__c;
            contactCheck[0].TXT_Distributor__c = param.lead.TXT_Distributor__c;
            contactCheck[0].NUM_Total_Acreages_OSR__c = param.lead.NUM_Total_Acreages_OSR__c;
            contactCheck[0].NUM_CornSilage_Total_Acres__c = param.lead.NUM_CornSilage_Total_Acres__c;
            contactCheck[0].NUM_Corn_Total_Acreages__c = param.lead.NUM_Corn_Total_Acreages__c;          
            contactCheck[0].LeadSource = param.lead.LeadSource;
            
            if(contactCheck[0].TXT_Security_Token__c  == null || contactCheck[0].TXT_Security_Token__c  == '')
                contactCheck[0].TXT_Security_Token__c = TriggerLeadCreateToken.GenerateGUID();
            
            update contactCheck;
            
            leadResponse.status = 'Updated Contact';
            leadResponse.elementId = contactCheck[0].Id;
            leadResponse.token = contactCheck[0].TXT_Security_Token__c;         
        }        
        //Not exists       
        else
        {
            Lead leadInsert = new Lead();
            leadInsert = param.lead.clone();
            leadInsert.status = 'Pending DEKALB';
            insert leadInsert;
            Lead statusUpdate = new Lead(id=leadInsert.id, status = 'Confirmed');
            update statusUpdate ;         
            leadResponse.status = 'Create Lead';
            Lead leadAux = [SELECT Id, TXT_Security_Token__c FROM Lead WHERE Id =: leadInsert.Id];
                      
            leadResponse.elementId = leadAux .Id;            
            leadResponse.token = leadAux.TXT_Security_Token__c;
            //leadResponse.lead  = leadInsert;
        }

        return leadResponse;
    }
    
    global class LeadWrapper
    {
        public String status;
        public Id elementId;
        public String token;
        public Lead lead;
    }
}