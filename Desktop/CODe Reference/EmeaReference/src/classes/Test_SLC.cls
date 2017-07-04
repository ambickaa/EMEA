@isTest
public class Test_SLC 
{
    /*
        Class to test all the functionality from SLC project. One method per trigger and controller.
    */
    private static testmethod void TriggerLeadCheckDuplicates()
    {
        //Trigger looks for existing leads or contacts with the same email address.
        
        //BEGIN Insert 2 leads with the same email in pending confirmation status
        Lead test1 = new Lead(email='testemail@asdfasdfasdf.com', lastname='test1', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        
        Lead test1Compare = [SELECT id, name, status from lead where id = :test1.id];
        
        Lead test2 = new Lead(email='testemail@asdfasdfasdf.com', lastname='test2', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test2;
        Lead test2Compare = [SELECT id, name, status, email from lead where id = :test2.id];
        test1Compare = [SELECT id, name, status, LKP_masterLead__c, email from lead where id = :test1.id];
        
        system.assert(test1Compare.status.equals('Pending confirmation'));
        system.assert(test1Compare.LKP_masterLead__c == null);
        system.assert(test1Compare.email == test2Compare.email);
        //END Insert 2 leads with the same email in pending confirmation status
        
        //BEGIN Insert 1 lead and "Confirmed" status with the same email as a confirmed one
        
        test2.status='Confirmed';
        update test2;
        Lead test3 = new Lead(email='testemail@asdfasdfasdf.com', lastname='test3', company = 'companyTest3', CHK_Consent_Accept_Terms__c = true);
        insert test3;
        test3.status = 'Confirmed';
        update test3;
        Lead test3Compare = [SELECT id, name, status, email, LKP_masterLead__c from lead where id = :test3.id];     
        
        system.assert(test3Compare.status.equals('Already a Lead'));
        system.assert(test3Compare.LKP_masterLead__c == test2Compare.Id);
        system.assert(test3Compare.email == null);
        List<Task> tasksDupe = [select id from task where whoID = :test2Compare.id AND subject ='Lead contacted again'];
        system.assert(tasksDupe.size()==1);
        
        //END Insert 2 leads with the same email as a confirmed one
        
        //BEGIN Insert 1 leads with the same email as an existing contact
        
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Contact testContact = new Contact(lastName='testContact', email='testemailContact@asdfasdfasdf.com', countryref__c=c.Id);
        insert testContact;
        
        Lead test4 = new Lead(email='testemailContact@asdfasdfasdf.com', lastname='test4', company = 'companyTest3', CHK_Consent_Accept_Terms__c = true);
        insert test4;
        test4.status = 'Confirmed';
        update test4;
        Lead test4Compare = [SELECT id, name, status, email, LKP_masterContact__c from lead where id = :test4.id];
        
        system.assert(test4Compare.status.equals('Already a Contact'));
        system.assert(test4Compare.LKP_masterContact__c == testContact.Id);
        system.assert(test4Compare.email == null);
        tasksDupe = [select id from task where whoID = :testContact.id AND subject ='Lead contacted again'];
        system.assert(tasksDupe.size()==1);
        
        //END Insert 1 leads with the same email as an existing contact
    }
    
    private static testmethod void TriggerLeadCreateToken()
    {
        //Trigger looks for existing leads or contacts with the same email address.
        
        //BEGIN Insert country, lead country fields and lead to check the initialization of automated configuration data
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'AccountRT');
        insert lcf;
        
        Lead test1 = new Lead(email='testemail@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        
        Lead test1Compare = [SELECT id, name, status, TXT_Security_Token__c, PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c from lead where id = :test1.id];
        system.assert(test1Compare.TXT_Security_Token__c != null);
        system.assert(test1Compare.PICK_Converted_Account_RT__c == lcf.PICK_Converted_Account_RT__c);
        system.assert(test1Compare.PICK_Converted_Account_category__c == lcf.PICK_Converted_Account_category__c);
        //END Insert country, lead country fields and lead to check the initialization of automated configuration data
    }
    
    private static testmethod void TriggerLeadConfirmedCopy()
    {
        //Trigger looks for existing leads or contacts with the same email address.
        
        
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'AccountRT');
        insert lcf;
        
        //BEGIN Check copy of ownerid from original leads to duplicated leads
        User exampleUser = [SELECT id from user where userrole.developername='EMEA' and isactive = true and id<>:Userinfo.getUserId() limit 1];
        Lead test1 = new Lead(email='testemailconfirmed1@asdfasdfasdf.com', lastname='test1', company = 'companyTest', CHK_Consent_Accept_Terms__c = true, ownerid=exampleUser.Id);
        insert test1;
        
        test1.status='Confirmed';
        update test1;
        Lead test1Compare = [SELECT id, name, status, TXT_Security_Token__c, 
                                    PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c, 
                                    ownerid 
                                    from lead 
                                    where id = :test1.id];
                                    
        Lead test2 = new Lead(email='testemailconfirmed1@asdfasdfasdf.com', lastname='test23456', company = 'companyTest2', CHK_Consent_Accept_Terms__c = true);
        insert test2;
        test2.status = 'Confirmed';
        update test2;
        Lead test2Compare = [SELECT id, name, status, TXT_Security_Token__c, 
                                    PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c,
                                    ownerid, lkp_masterLead__c 
                                    from lead 
                                    where id = :test2.id];
        system.assertequals(test1Compare.id, test2Compare.lkp_masterLead__c);
        system.assertequals(test1Compare.ownerid, test2Compare.ownerid);
        //END Check copy of ownerid from original leads to duplicated leads
        
        //BEGIN Check owner set to country defined
        lcf.PICK_Assignment_method__c = 'Country';
        update lcf;
        
        List <User> exampleUsers = [SELECT id from user where userrole.developername='EMEA' and isactive = true and id<>:Userinfo.getUserId()];
        lcf.LKP_Default_Lead_Owner__c = exampleUsers[2].id;
        update lcf;
        Lead test3 = new Lead(email='testownerTerrv1@asdfasdfasdf.com', lastname='test1', 
                                leadSource='DEKALB', country='testCountry', 
                                company = 'companyTest', CHK_Consent_Accept_Terms__c = true, 
                                ownerid=exampleUser.Id);
        insert test3;
        test3.status='Confirmed';
        update test3;
        Lead test3Compare = [SELECT id, name, status, TXT_Security_Token__c, 
                            PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c, 
                            ownerid 
                            from lead 
                            where id = :test3.id];
        
        system.assertEquals(lcf.LKP_Default_Lead_Owner__c, test3Compare.ownerid);
        //END Check owner set to country defined
    }
    
    private static testmethod void TriggerLeadConfirmedCopy2()
    {
    
        //Trigger looks for existing leads or contacts with the same email address.
        
        User exampleUser = [SELECT id from user where userrole.developername='EMEA' and isactive = true and id<>:Userinfo.getUserId() limit 1];
        
        PermissionSet perm = [SELECT Name, PermissionsModifyAllData, (SELECT AssigneeId FROM Assignments) FROM PermissionSet WHERE name like '%SLC%' limit 1];
        List <User> exampleUsers = new List<User>();
        if(perm.Assignments.size() > 0)
        {
            exampleUser.Id = perm.Assignments[0].AssigneeId;
            for(PermissionSetAssignment permAssign : perm.Assignments)
            {
                User u = new User(Id=permAssign.AssigneeId);
                exampleUsers.add(u);
            }            
        }


        Country__c c = new Country__c(name='testCountry2');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'AccountRT', PICK_Assignment_method__c = 'Territory');
        insert lcf;
        Lead_Country_Fields__c lcf2 = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='Roundup', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'AccountRT', PICK_Assignment_method__c = 'Territory');
        
        if(exampleUsers.size()>2)
        {
            lcf.LKP_Default_Lead_Owner__c = exampleUsers[1].id;
            lcf2.LKP_Default_Lead_Owner__c = exampleUsers[2].id;
        }
        update lcf;
        insert lcf2;
        
        Division__c div = new Division__c(name='Corn');
        insert div;
        Division__c div2 = new Division__c(name='OSR');
        insert div2;
        TerritoryManagement__c terr = new TerritoryManagement__c(name='Terr1', DE_CountryRef__c = c.id, DE_CP__c ='08029');
        insert terr;
        TerritoryManagementUser__c tmu = new TerritoryManagementUser__c(DE_TerritoryManagementRef__c = terr.id, DivisionRef__c = div.id);
        if(exampleUsers.size()>2)
            tmu.DE_UserRef__c = exampleUsers[2].id;
        else
            tmu.DE_UserRef__c = exampleUsers[1].id;
        insert tmu;
        
        TerritoryManagement__c terr2 = new TerritoryManagement__c(name='Terr2', DE_CountryRef__c = c.id, DE_CP__c ='08031');
        insert terr2;
        TerritoryManagementUser__c tmu2 = new TerritoryManagementUser__c(DE_TerritoryManagementRef__c = terr2.id, DivisionRef__c = div2.id);
        if(exampleUsers.size()>3)
            tmu2.DE_UserRef__c = exampleUsers[3].id;
        else
            tmu2.DE_UserRef__c = exampleUsers[1].id;
        insert tmu2;                        
        
        Lead test4 = new Lead(email='testownerTerrv2@asdfasdfasdf.com', lastname='test1', 
                                leadSource='DEKALB', country='testCountry2', 
                                company = 'companyTest', CHK_Consent_Accept_Terms__c = true, 
                                ownerid=exampleUser.Id, postalCode='08029');
        insert test4;
        test4.status='Confirmed';
        update test4;
        Lead test4Compare = [SELECT id, name, status, TXT_Security_Token__c, 
                            PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c, 
                            ownerid 
                            from lead 
                            where id = :test4.id];
        
        system.assertEquals(tmu.DE_UserRef__c, test4Compare.ownerid);
        //END Check owner set to territory defined
        //BEGIN Check owner set to territory defined, but no TMUs are found             
        Lead test5 = new Lead(email='testownerTerrNotFoundv25@asdfasdfasdf.com', lastname='test1', 
                                leadSource='Roundup', country='testCountry2', 
                                company = 'companyTest', CHK_Consent_Accept_Terms__c = true, 
                                ownerid=exampleUser.Id, postalCode='08031');
        insert test5;
        test5.status='Confirmed';
        update test5;
        Lead test5Compare = [SELECT id, name, status, TXT_Security_Token__c, 
                            PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c, 
                            ownerid 
                            from lead 
                            where id = :test5.id];
        
        system.assertEquals(lcf2.LKP_Default_Lead_Owner__c, test5Compare.ownerid);
        //END Check owner set to territory defined, but no TMUs are found
        
        //BEGIN Check owner set to territory defined, but no terrs are found                
        Lead test6 = new Lead(email='testownerTerrNotFound3@asdfasdfasdf.com', lastname='test1', 
                                leadSource='DEKALB', country='testCountry2', 
                                company = 'companyTest', CHK_Consent_Accept_Terms__c = true, 
                                ownerid=exampleUser.Id, postalCode='08030');
        insert test6;
        test6.status='Confirmed';
        update test6;
        Lead test6Compare = [SELECT id, name, status, TXT_Security_Token__c, 
                            PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c, 
                            ownerid 
                            from lead 
                            where id = :test6.id];
        
        system.assertEquals(lcf.LKP_Default_Lead_Owner__c, test6Compare.ownerid);
        //END Check owner set to territory defined, but no terrs are found
    }
    
    private static testmethod void TriggerLeadUnconfirmedDeletion()
    {
        Lead test1 = new Lead(email='testemailUnconfirmedLead@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        test1.status='Unconfirmed';
        update test1;
        Lead test1Compare = [SELECT id, name, status, TXT_Security_Token__c, PICK_Converted_Account_RT__c, PICK_Converted_Account_category__c from lead where id = :test1.id];
        system.assert(test1Compare.TXT_Security_Token__c == '---');
    }
    
    private static testmethod void TriggerLeadConversionDeletion()
    {
        Country__c c = new Country__c(name='testCountry');
        insert c;
        Lead_Country_Fields__c lcf = new Lead_Country_Fields__c(name='test', LKP_Country__c =c.Id, PICK_Lead_Source__c='DEKALB', PICK_Converted_Account_category__c='Farm', PICK_Converted_Account_RT__c = 'GroupFarmSite');
        insert lcf;
        
        Lead test1 = new Lead(email='testemailconvertedLead@asdfasdfasdf.com', leadSource='DEKALB', lastname='test1', country='testCountry', company = 'companyTest', CHK_Consent_Accept_Terms__c = true);
        insert test1;
        test1.status='Confirmed';
        update test1;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(test1.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        //Database.LeadConvertResult lcr = Database.convertLead(lc);
        //System.assert(lcr.isSuccess());
    }
}