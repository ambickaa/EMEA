public without sharing class LeadContactFormController {
    
    public Lead lead {get;set;}
    public Contact contact {get;set;}
    public containerObject test {get;set;}
    public Lead_Country_Fields__c lcountryFields {get; set;}
    public Boolean showButtons {get; set;}
    
    
    list<Task> tasks = new list<Task>();
    
    String idParam;
    String tokenParam;
    String language;
    Boolean emailChanged;
    String oldEmailModified;
    
    public LeadContactFormController()
    {
        test = new containerObject();
        showButtons = true;
        idParam = apexPages.currentPage().getParameters().get('id');
        tokenParam = apexPages.currentPage().getParameters().get('token');
        test.leadLanguage = apexPages.currentPage().getParameters().get('lang');
        test.leadSource = apexPages.currentPage().getParameters().get('origin');
        emailChanged = false;   
        
        getData();
    }
    
    public PageReference save()
    {
        emailChanged = false;
        if(idParam != null && idParam.substring(0,3) == '00Q')
        {   
            lead.FirstName = test.leadFirstName;
            lead.LastName = test.leadLastName;
            lead.DAT_Birthday__c = test.leadBirthday;
            lead.Country = test.leadCountry;
            lead.State = test.leadState;
            lead.City = test.leadCity;
            lead.PostalCode = test.leadPostalCode;
            lead.Street = test.leadStreet;                        
            if(lead.Email != test.leadEmail&& lead.Email != null) 
            {   
                oldEmailModified = lead.TXT_Email_modified__c;
                lead.TXT_Email_modified__c = test.leadEmail;            
                lead.CHK_Confirm_Email_Changed__c = true;               
                emailChanged = true;
            }
            else 
            {
                lead.Email = test.leadEmail;            
            }
            lead.Phone = test.leadPhone;
            lead.Fax = test.leadFax;
            lead.NUM_Farm_size_per_crop__c = test.leadFarmSize;
            lead.Website = test.leadWebsite;
            lead.Company = test.leadCompany;
            lead.TXT_Position_in_the_company__c = test.leadPosition;
            lead.TXT_VAT_ID__c = test.leadVAT;
            lead.PICK_User_category__c = test.leadCategory;
            lead.PICK_Farm_usage__c = test.leadFarm;
            lead.PICK_Gender__c = test.leadGender;
            lead.TXT_Suppliers_of_the_farm__c = test.leadSuppliers;
            //--------------------------------------------------
            // Start: 2016.08.03 New fields added at Dekalb form by Support Team
            //--------------------------------------------------
            lead.NUM_Corn_Total_Acreages__c = test.leadCornAcreages;
            lead.NUM_CornSilage_Total_Acres__c = test.leadCornAcreagesSilage;
            lead.NUM_Total_Acreages_OSR__c = test.leadOSRAcreages;
            lead.TXT_Distributor__c = test.leadDistributor;
            //--------------------------------------------------
            // End: 2016.08.03 New fields added at Dekalb form by Support Team
            //--------------------------------------------------
            lead.CHK_Consent_Accept_Terms__c = test.leadAccept;
            lead.CHK_Consent_Contact_by_email__c = test.leadConsentEmail;
            lead.CHK_Consent_Contact_by_fax__c = test.leadConsentFax;
            lead.CHK_Consent_Contact_by_phone__c =  test.leadConsentPhone;
            lead.CHK_Consent_Contact_by_postal__c = test.leadConsentPostal;
            lead.CHK_Consent_Contact_by_SMS__c = test.leadConsentSMS;
            lead.CHK_Consent_Marketing_material__c =    test.leadConsentMarketing;
            lead.CHK_Consent_Newsletters__c = test.leadConsentNewsletter;
            
            //Check Mandatory Fields
            if(test.leadFirstName.length() == 0 || test.leadFirstName == null || test.leadLastName.length() == 0 || test.leadLastName == null || test.leadEmail.length() == 0 || test.leadEmail.length() == null || test.leadCompany.length() == 0 || test.leadCompany == null)
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get('Lead');
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                
                
                String errorMsg= ((test.leadFirstName.length() == 0 || test.leadFirstName == null) ? fieldMap.get('FirstName').getDescribe().getLabel() : ((test.leadLastName.length() == 0 || test.leadLastName == null)?fieldMap.get('LastName').getDescribe().getLabel() : ((test.leadEmail.length() == 0 || test.leadEmail.length() == null)? fieldMap.get('Email').getDescribe().getLabel() : ((test.leadCompany.length() == 0 || test.leadCompany.length() == null)? fieldMap.get('Company').getDescribe().getLabel() : ''))));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.SLC_mandatory_fields + ': '+errorMsg));
                return null;
            }
            
            Database.SaveResult result = Database.update(lead,false);       
            if (!result.isSuccess()) {
                Database.Error[] errs = result.getErrors();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_modif_KO + '<br>' + errs[0].getMessage()));                               
                if(!Pattern.matches('^[A-Z0-9._%+-/!#$%&\'*=?^_`{|}~]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$', lead.TXT_Email_modified__c))
                {
                    lead.TXT_Email_modified__c = oldEmailModified;
                }                
                return null;             
            }
            
        }
        else if(idParam != null && idParam.substring(0,3) == '003')
        {
            contact.FirstName = test.leadFirstName;
            contact.LastName = test.leadLastName;
            contact.Birthdate = test.leadBirthday;
            contact.MailingCountry = test.leadCountry;
            contact.MailingState = test.leadState;
            
            //--------------------------------------------------
            // Start: 2016.04.15 update by Support Team
            //--------------------------------------------------            
            contact.City__c = test.leadCity;
            contact.Street__c = test.leadStreet;
            contact.ZIPPostalCode__c = test.leadPostalCode;
            contact.StateProvince__c = test.leadState;            
            
            contact.DE_PrivateCity__c = test.leadCity;
            contact.DE_PrivateStreet__c = test.leadStreet;
            contact.DE_PrivateZIP__c = test.leadPostalCode;
            contact.DE_Private_State_Province__c = test.leadState;
            //--------------------------------------------------
            // End: 2016.04.15 update by Support Team
            //--------------------------------------------------
            
            contact.MailingCity = test.leadCity;
            contact.MailingStreet = test.leadStreet;
            contact.MailingPostalCode = test.leadPostalCode;
            if(contact.Email != test.LeadEmail && contact.Email != null)
            {
                oldEmailModified = contact.TXT_Email_modified__c;
                contact.TXT_Email_modified__c = test.leadEmail;
                contact.CHK_Confirm_Email_Changed__c = true;
                emailChanged = true;
            }
            else contact.Email = test.leadEmail;
            contact.Phone = test.leadPhone;
            contact.Fax = test.leadFax;
            contact.NUM_Farm_size_per_crop__c = test.leadFarmSize;
            contact.DE_Website__c = test.leadWebsite;
            contact.TXT_Company__c = test.leadCompany;
            contact.Position__c = test.leadPosition;
            contact.TXT_VAT_ID__c = test.leadVAT;
            contact.PICK_User_category__c = test.leadCategory;
            contact.PICK_Farm_usage__c = test.leadFarm;
            contact.Gender__c = test.leadGender;
            contact.TXT_Suppliers_of_the_farm__c = test.leadSuppliers;
            //--------------------------------------------------
            // Start: 2016.08.03 New fields added at Dekalb form by Support Team
            //--------------------------------------------------
            contact.NUM_Corn_Total_Acreages__c = test.leadCornAcreages;
            contact.NUM_CornSilage_Total_Acres__c = test.leadCornAcreagesSilage;
            contact.NUM_Total_Acreages_OSR__c = test.leadOSRAcreages;
            contact.TXT_Distributor__c = test.leadDistributor;
            //--------------------------------------------------
            // End: 2016.08.03 New fields added at Dekalb form by Support Team
            //--------------------------------------------------            
            contact.Data_Privacy_Agreement__c = test.leadAccept;
            contact.AgreesEmail__c = test.leadConsentEmail;
            contact.CHK_Consent_Contact_by_fax__c = test.leadConsentFax;
            contact.CHK_Consent_Contact_by_phone__c =  test.leadConsentPhone;
            contact.AgreesMail__c = test.leadConsentPostal;
            contact.AgreesSMS__c = test.leadConsentSMS;
            contact.Marketing_Agreement__c = test.leadConsentMarketing;
            contact.CHK_Consent_Newsletters__c = test.leadConsentNewsletter;
            
            Database.SaveResult result = Database.update(contact,false);       
            if (!result.isSuccess()) {
                Database.Error[] errs = result.getErrors();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_modif_KO + '<br>' + errs[0].getMessage()));
                if(!Pattern.matches('^[A-Z0-9._%+-/!#$%&\'*=?^_`{|}~]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$', contact.TXT_Email_modified__c))
                {
                    contact.TXT_Email_modified__c = oldEmailModified;
                }
                return null;             
            }
           
        }
        
        if(!emailChanged) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SLC_site_modif_OK));
        else if (emailChanged) ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SLC_email_changed_modif));
                
        //getData();
        return null;
    }
    
    public PageReference reset()
    {
        emailChanged = false;
        //Lead
        if(idParam != null && idParam.substring(0,3) == '00Q')
        {            
            //Create ghost Lead
            Lead deletedLead= new Lead();
            deletedLead.OwnerId = lead.OwnerId;
            deletedLead.FirstName = '---';
            deletedLead.LastName = '---';
            deletedLead.Status = 'Deleted';
            deletedLead.LeadSource = lead.LeadSource;
            deletedLead.DAT_Birthday__c = null;
            deletedLead.Country = lead.Country;
            deletedLead.State = '---';
            deletedLead.City = '---';
            deletedLead.PostalCode = '---';
            deletedLead.Street = '---';
            deletedLead.Email = '';
            deletedLead.Phone = '---';
            deletedLead.Fax = '---';
            deletedLead.NUM_Farm_size_per_crop__c = null;
            deletedLead.Website = '---';
            deletedLead.Company = '---';
            deletedLead.TXT_Position_in_the_company__c = '---';
            deletedLead.TXT_VAT_ID__c = '---';
            deletedLead.PICK_User_category__c = null;
            deletedLead.PICK_Farm_usage__c = null;
            deletedLead.PICK_Gender__c = null;
            deletedLead.TXT_Suppliers_of_the_farm__c = null;
            //------------------------------------------------------------------
            // Start: 2016.08.03 New fields added at Dekalb form by Support Team
            //------------------------------------------------------------------
            deletedLead.NUM_Corn_Total_Acreages__c = test.leadCornAcreages;
            deletedLead.NUM_CornSilage_Total_Acres__c = test.leadCornAcreagesSilage;
            deletedLead.NUM_Total_Acreages_OSR__c = test.leadOSRAcreages;
            deletedLead.TXT_Distributor__c = test.leadDistributor;
            //-------------------------------------------------------------------
            // End: 2016.08.03 New fields added at Dekalb form by Support Team
            //-------------------------------------------------------------------            
            deletedLead.CHK_Consent_Accept_Terms__c = false;
            deletedLead.CHK_Consent_Contact_by_email__c = false;
            deletedLead.CHK_Consent_Contact_by_fax__c = false;
            deletedLead.CHK_Consent_Contact_by_phone__c =  false;
            deletedLead.CHK_Consent_Contact_by_postal__c = false;
            deletedLead.CHK_Consent_Contact_by_SMS__c = false;
            deletedLead.CHK_Consent_Marketing_material__c = false;
            deletedLead.CHK_Consent_Newsletters__c = false;
            deletedLead.TXT_Security_Token__c = '---';
            
            lead.CHK_Delete_action__c = true;                      
            
            try
            {
                insert deletedLead;
                update lead;
                delete lead;               
            }
            catch(DMLException e)
            {               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_modif_KO));
            }
             //Task
            Task t = new Task();
            t.WhoId = deletedLead.Id;
            t.OwnerId = deletedLead.OwnerId;
            t.Status = 'In Progress';
            t.Subject = 'Lead deleted';
            t.ActivityDate = System.Today();
            tasks.add(t);
            
            try
            {
                 insert tasks;
            }
            catch(DMLException e)
            {               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_modif_KO));
            }
        }
        //Contact
        else if(idParam != null && idParam.substring(0,3) == '003')
        {
            //Create Ghost Contact            
            Contact deletedContact = new Contact();
            deletedContact.FirstName = '---';
            deletedContact.LastName = '---';
            deletedContact.Birthdate = null;
            deletedContact.OwnerId = contact.OwnerId;
            deletedContact.LeadSource = contact.LeadSource;
            deletedContact.CountryRef__c = contact.CountryRef__c;
            deletedContact.MailingState = '---';
            deletedContact.MailingCity = '---';
            
            //--------------------------------------------------
            // Start: 2016.04.15 update by Support Team
            //--------------------------------------------------
            deletedContact.City__c = '---';
            deletedContact.DE_PrivateCity__c = '---';

            deletedContact.Street__c = '---';
            deletedContact.DE_PrivateStreet__c = '---';
            //--------------------------------------------------
            // End: 2016.04.15 update by Support Team
            //--------------------------------------------------
            
            deletedContact.MailingPostalCode = '---';
            deletedContact.MailingStreet = '---';
            deletedContact.Status__c = 'Inactive';
            deletedContact.Email = '';
            deletedContact.Phone = '---';
            deletedContact.Fax = '---';
            deletedContact.NUM_Farm_size_per_crop__c = null;
            deletedContact.DE_Website__c = '---';
            deletedContact.TXT_Company__c = '---';
            deletedContact.Position__c = '---';
            deletedContact.TXT_VAT_ID__c = '---';
            deletedContact.PICK_User_category__c = null;
            deletedContact.PICK_Farm_usage__c = null;
            deletedContact.Gender__c = null;
            deletedContact.TXT_Suppliers_of_the_farm__c = '---';
            //------------------------------------------------------------------
            // Start: 2016.08.03 New fields added at Dekalb form by Support Team
            //------------------------------------------------------------------
            deletedContact.NUM_Corn_Total_Acreages__c = test.leadCornAcreages;
            deletedContact.NUM_CornSilage_Total_Acres__c = test.leadCornAcreagesSilage;
            deletedContact.NUM_Total_Acreages_OSR__c = test.leadOSRAcreages;
            deletedContact.TXT_Distributor__c = test.leadDistributor;
            //------------------------------------------------------------------
            // End: 2016.08.03 New fields added at Dekalb form by Support Team
            //------------------------------------------------------------------            
            deletedContact.Data_Privacy_Agreement__c = false;
            deletedContact.AgreesEmail__c = false;
            deletedContact.CHK_Consent_Contact_by_fax__c = false;
            deletedContact.CHK_Consent_Contact_by_phone__c =  false;
            deletedContact.AgreesMail__c = false;
            deletedContact.AgreesSMS__c = false;
            deletedContact.Marketing_Agreement__c = false;
            deletedContact.CHK_Consent_Newsletters__c = false;
            deletedContact.TXT_Security_token__c = '---';
            
            contact.CHK_Delete_action__c = true;
            
            try
            {
                insert deletedContact;
                update contact;
                delete contact;
            }
            catch(DMLException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_modif_KO));
            }
             //Task
            Task t = new Task();
            t.WhoId = deletedContact.Id;
            t.OwnerId = deletedContact.OwnerId;
            t.Status = 'In Progress';
            t.Subject = 'Lead deleted';
            t.ActivityDate = System.Today();
            tasks.add(t);
            
            try
            {
                insert tasks;
            }
            catch(DMLException e)
            {               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_modif_KO));
            }
            
        }   
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SLC_site_modif_DELOK));
        test.leadStatus = 'Deleted';     
        return null;
    }

    public class containerObject
    {
        public String leadFirstName {get; set;}
        public String leadLastName {get; set;}
        public String leadStatus {get; set;}
        public Date leadBirthday {get; set;}
        public String leadCountry {get; set;}
        public String leadState {get; set;}
        public String leadCity {get; set;}
        public String leadPostalCode {get; set;}
        public String leadStreet {get; set;}
        public String leadEmail {get; set;}
        public String leadEmailModified {get; set;}
        public String leadPhone {get; set;}
        public String leadFax {get; set;}
        public Decimal leadFarmSize {get; set;}
        public String leadWebsite {get; set;}
        public String leadCompany {get; set;}
        public String leadPosition {get; set;}
        public String leadVAT {get; set;}
        public String leadCategory {get; set;}
        public String leadFarm {get; set;}
        public String leadGender {get; set;}
        public String leadSuppliers {get; set;}
        //------------------------------------------------------------------
        // Start: 2016.08.03 New fields added at Dekalb form by Support Team
        //------------------------------------------------------------------
        public Decimal leadCornAcreages {get; set;}
        public Decimal leadCornAcreagesSilage {get; set;}
        public Decimal leadOSRAcreages {get; set;}
        public String leadDistributor {get; set;}
        //------------------------------------------------------------------
        // End: 2016.08.03 New fields added at Dekalb form by Support Team
        //------------------------------------------------------------------              
        public Boolean leadAccept {get; set;}
        public Boolean leadConsentEmail {get; set;}
        public Boolean leadConsentFax {get; set;}
        public Boolean leadConsentPhone {get; set;}
        public Boolean leadConsentPostal {get; set;}
        public Boolean leadConsentSMS {get; set;}
        public Boolean leadConsentMarketing {get; set;}
        public Boolean leadConsentNewsletter {get; set;}
        public String leadSource {get; set;}
        public String leadLanguage {get; set;}        
    }
    
    public List<SelectOption> getGender()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.Lead.fields.PICK_Gender__c.getSObjectField().getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry f: ple)
        {
            options.add(new SelectOption(f.getValue(),f.getLabel()));          
        }
        return options;
    }
    
    public List<SelectOption> getFarmUsage()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.Lead.fields.PICK_Farm_usage__c.getSObjectField().getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry f: ple)
        {
            options.add(new SelectOption(f.getValue(),f.getLabel()));          
        }
        return options;
    }
    
    public List<SelectOption> getCategory()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.Lead.fields.PICK_User_category__c.getSObjectField().getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry f: ple)
        {
            options.add(new SelectOption(f.getValue(),f.getLabel()));          
        }
        return options;
    }
    
    public void getData()
    {
        //Lead
        if(idParam != null && idParam.substring(0,3) == '00Q')
        {
            //Exists Lead?
            try
            {
                lead = [SELECT Id, Name, title, FirstName, LastName, Status, TXT_Language__c, DAT_Birthday__c, City, Country, PostalCode, State, Street, Email, TXT_Email_modified__c, Phone, Fax, NUM_Farm_size_per_crop__c, Website, isConverted, ConvertedContactId,
                            Company, TXT_Position_in_the_company__c, TXT_VAT_ID__c, PICK_User_category__c, PICK_Farm_usage__c, PICK_Gender__c, TXT_Suppliers_of_the_farm__c, CHK_Confirm_Email_Changed__c, CHK_Email_change_confirmed__c, CHK_Consent_Accept_Terms__c, CHK_Consent_Contact_by_email__c, 
                            CHK_Consent_Contact_by_fax__c, CHK_Consent_Contact_by_phone__c, CHK_Consent_Contact_by_postal__c, CHK_Consent_Contact_by_SMS__c, CHK_Consent_Marketing_material__c, CHK_Consent_Newsletters__c, TXT_Security_Token__c, LeadSource, OwnerId, CHK_Delete_action__c,
                            NUM_Corn_Total_Acreages__c, NUM_CornSilage_Total_Acres__c, NUM_Total_Acreages_OSR__c, TXT_Distributor__c
                            FROM Lead WHERE Id =: idParam AND TXT_Security_Token__c =: tokenParam LIMIT 1];
                
                //Looking Lead Country Fields
                if(lead != null && lead.Status != 'Deleted' && !lead.isConverted)
                {
                    try
                    {
                        lcountryFields = [SELECT Id, TXT_Field__c FROM Lead_Country_Fields__c WHERE PICK_Lead_Source__c =: lead.LeadSource AND LKP_Country__r.name=: lead.Country LIMIT 1];
                    }
                    catch(Exception e)
                    {
                        test = null;
                        lcountryFields = null;
                        lcountryFields = null;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_confirm_KO1 + ' ' +Label.SLC_site_confirm_KO2));
                    }
                                        
                    test.leadFirstName = lead.FirstName;
                    test.leadLastName = lead.LastName;
                    test.leadStatus = lead.Status;
                    test.leadBirthday = lead.DAT_Birthday__c;
                    test.leadCountry = lead.Country;
                    test.leadCity = lead.City;
                    test.leadPostalCode = lead.PostalCode;
                    test.leadState = lead.State;
                    test.leadStreet = lead.Street;
                    test.leadEmail = lead.Email;
                    test.leadEmailModified = lead.TXT_Email_modified__c;
                    test.leadPhone = lead.Phone;
                    test.leadFax = lead.Fax;
                    test.leadFarmSize = lead.NUM_Farm_size_per_crop__c;
                    test.leadWebsite = lead.Website;
                    test.leadCompany = lead.Company;
                    test.leadPosition = lead.TXT_Position_in_the_company__c;
                    test.leadVAT = lead.TXT_VAT_ID__c;
                    test.leadCategory = lead.PICK_User_category__c;
                    test.leadFarm = lead.PICK_Farm_usage__c;
                    test.leadGender = lead.PICK_Gender__c;
                    test.leadSuppliers = lead.TXT_Suppliers_of_the_farm__c;
                    //------------------------------------------------------------------
                    // Start: 2016.08.03 New fields added at Dekalb form by Support Team
                    //------------------------------------------------------------------
                    test.leadCornAcreages = lead.NUM_Corn_Total_Acreages__c;
                    test.leadCornAcreagesSilage = lead.NUM_CornSilage_Total_Acres__c;
                    test.leadOSRAcreages = lead.NUM_Total_Acreages_OSR__c;
                    test.leadDistributor = lead.TXT_Distributor__c;
                    //----------------------------------------------------------------
                    // End: 2016.08.03 New fields added at Dekalb form by Support Team
                    //----------------------------------------------------------------                    
                    test.leadAccept = lead.CHK_Consent_Accept_Terms__c;
                    test.leadConsentEmail = lead.CHK_Consent_Contact_by_email__c;
                    test.leadConsentFax = lead.CHK_Consent_Contact_by_fax__c;
                    test.leadConsentPhone = lead.CHK_Consent_Contact_by_phone__c;
                    test.leadConsentPostal = lead.CHK_Consent_Contact_by_postal__c;
                    test.leadConsentSMS = lead.CHK_Consent_Contact_by_SMS__c;
                    test.leadConsentMarketing = lead.CHK_Consent_Marketing_material__c;
                    test.leadConsentNewsletter = lead.CHK_Consent_Newsletters__c;
                    test.leadSource = lead.LeadSource;
                    test.leadLanguage = lead.TXT_Language__c;
                }
                else if(lead != null && lead.Status != 'Deleted' && lead.isConverted)
                {
                    idParam = lead.ConvertedContactId;
                }
            }
            catch(Exception e)
            {    
                showButtons = false;           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_confirm_KO1 + ' ' +Label.SLC_site_confirm_KO2));
            }
            
        }
        //Contact
        if(idParam != null && idParam.substring(0,3) == '003')
        {
            try
            {
                contact = [SELECT Id, FirstName, LastName, TXT_Language__c, Birthdate, CountryRef__c, CountryRef__r.Name, MailingCountry, MailingCity, DE_PrivateCity__c, City__c, MailingPostalCode, MailingState, MailingStreet, DE_PrivateStreet__c, Street__c, Email, Phone, Fax, NUM_Farm_size_per_crop__c, DE_Website__c, TXT_Company__c,
                Position__c, TXT_VAT_ID__c, PICK_User_category__c, PICK_Farm_usage__c, Gender__c, TXT_Suppliers_of_the_farm__c, Data_Privacy_Agreement__c, AgreesEmail__c, CHK_Consent_Contact_by_fax__c, CHK_Email_change_confirmed__c, 
                CHK_Consent_Contact_by_phone__c, AgreesMail__c, AgreesSMS__c, Marketing_Agreement__c, CHK_Consent_Newsletters__c, LeadSource, TXT_Email_modified__c, CHK_Confirm_Email_Changed__c, OwnerId,
                NUM_Corn_Total_Acreages__c, NUM_CornSilage_Total_Acres__c, NUM_Total_Acreages_OSR__c, TXT_Distributor__c
                FROM Contact WHERE Id =: idParam AND TXT_Security_Token__c =: tokenParam LIMIT 1];
                
                //Looking Lead Country Fields
                if(contact != null)
                {
                    try
                    {
                        lcountryFields = [SELECT Id, TXT_Field__c FROM Lead_Country_Fields__c WHERE PICK_Lead_Source__c =: contact.LeadSource AND LKP_Country__r.name=: contact.CountryRef__r.Name LIMIT 1];
                    }
                    catch(Exception e)
                    {
                        showButtons = false;
                        lcountryFields = null;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_confirm_KO1 + ' ' +Label.SLC_site_confirm_KO2));
                        
                    }
                    
                    test.leadFirstName = contact.FirstName;
                    test.leadLastName = contact.LastName;
                    test.leadBirthday = contact.Birthdate;
                    test.leadCountry = contact.MailingCountry;
                    test.leadCity = contact.DE_PrivateCity__c;
                    test.leadPostalCode = contact.MailingPostalCode;
                    test.leadState = contact.MailingState;
                    test.leadStreet = contact.DE_PrivateStreet__c;
                    test.leadEmail = contact.Email;
                    test.leadEmailModified = contact.TXT_Email_modified__c;
                    test.leadPhone = contact.Phone;
                    test.leadFax = contact.Fax;
                    test.leadFarmSize = contact.NUM_Farm_size_per_crop__c;
                    test.leadWebsite = contact.DE_Website__c;
                    test.leadCompany = contact.TXT_Company__c;
                    test.leadPosition = contact.Position__c;
                    test.leadVAT = contact.TXT_VAT_ID__c;
                    test.leadCategory = contact.PICK_User_category__c;
                    test.leadFarm = contact.PICK_Farm_usage__c;
                    test.leadGender = contact.Gender__c;
                    test.leadSuppliers = contact.TXT_Suppliers_of_the_farm__c;
                    //------------------------------------------------------------------
                    // Start: 2016.08.03 New fields added at Dekalb form by Support Team
                    //------------------------------------------------------------------
                    test.leadCornAcreages = contact.NUM_Corn_Total_Acreages__c;
                    test.leadCornAcreagesSilage = contact.NUM_CornSilage_Total_Acres__c;
                    test.leadOSRAcreages = contact.NUM_Total_Acreages_OSR__c;
                    test.leadDistributor = contact.TXT_Distributor__c;
                    //----------------------------------------------------------------
                    // End: 2016.08.03 New fields added at Dekalb form by Support Team
                    //---------------------------------------------------------------                    
                    test.leadAccept = contact.Data_Privacy_Agreement__c;
                    test.leadConsentEmail = contact.AgreesEmail__c;
                    test.leadConsentFax = contact.CHK_Consent_Contact_by_fax__c;
                    test.leadConsentPhone = contact.CHK_Consent_Contact_by_phone__c;
                    test.leadConsentPostal = contact.AgreesMail__c;
                    test.leadConsentSMS = contact.AgreesSMS__c;
                    test.leadConsentMarketing = contact.Marketing_Agreement__c;
                    test.leadConsentNewsletter = contact.CHK_Consent_Newsletters__c;
                    test.leadSource = contact.LeadSource;
                    test.leadLanguage = contact.TXT_Language__c;                    
                }
                
            }
            catch(Exception e)
            {
                showButtons = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SLC_site_confirm_KO1 + ' ' +Label.SLC_site_confirm_KO2));
            }           
        }   
        
    }

}