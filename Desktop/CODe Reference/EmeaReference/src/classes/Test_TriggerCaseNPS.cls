@isTest
public class Test_TriggerCaseNPS {

    private static testmethod void TriggerCaseNPSResults() 
    {        
        RecordType rtCampaign = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'NPS' LIMIT 1];
        RecordType rtCase = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'Survey Result' LIMIT 1];
        List<Case> listCases = new List<Case>();
        
        //Create Country
        Country__c co = new Country__c();
        co.Name = 'testCountry';
        insert co;
        
        //Create Account
        Account ac = new Account();
        ac.Name = 'TestAccount';
        ac.Category__c = 'Farm';
        ac.GC_Status_Descr__c = 'Active';
        ac.CountryRef__c = co.Id;
        insert ac;
        
        //Create Year
        Year__c y = new Year__c();
        y.Name = 'testYear';
        insert y;
        
        //Create Campaign
        Campaign ca = new Campaign();
        ca.RecordTypeId = rtCampaign.Id;
        ca.Name = 'testCampaign';
        ca.CountryRef__c = co.Id;
        ca.YearV2__c = y.Id;
        ca.StartDate = System.Today() - 30;
        ca.EndDate = System.Today() + 30;
        insert ca;
        
        //Create case
        Case c1 = new Case();
        c1.RecordTypeId = rtCase.Id;
        c1.AccountId = ac.Id;
        c1.Status = 'New';
        c1.NPS_CAMPAIGN__c = ca.Id;
        c1.NPS_RESULT_Q1__c = 3;
        
        //Create Case2
        Case c2 = new Case();
        c2.RecordTypeId = rtCase.Id;
        c2.AccountId = ac.Id;
        c2.Status = 'New';
        c2.NPS_CAMPAIGN__c = ca.Id;
        c2.NPS_RESULT_Q1__c = 3;
        
        listCases.add(c1);
        listCases.add(c2);      
        insert listCases;
        
        //Compare result Campaigns
        Campaign resultCampaign = [SELECT Id, GC_Total_Promoter_Qty__c, GC_Total_Passive_Qty__c, GC_Total_Detractor_Qty__c FROM Campaign WHERE Id =: ca.Id LIMIT 1];
        System.assertEquals(resultCampaign.GC_Total_Detractor_Qty__c, 2);       
        listCases.clear();      
        
        //Update case
        listCases = [SELECT Id FROM Case];
        listCases[0].NPS_RESULT_Q1__c = 7;
        listCases[1].NPS_RESULT_Q1__c = 7;              
        update listCases;
        
        //Compare result Campaigns
        resultCampaign = [SELECT Id, GC_Total_Promoter_Qty__c, GC_Total_Passive_Qty__c, GC_Total_Detractor_Qty__c FROM Campaign WHERE Id =: ca.Id LIMIT 1];
        System.assertEquals(resultCampaign.GC_Total_Passive_Qty__c, 2);
        
        listCases[0].NPS_RESULT_Q1__c = 10;
        listCases[1].NPS_RESULT_Q1__c = 10;
        update listCases;
        
        //Compare result Campaigns
        resultCampaign = [SELECT Id, GC_Total_Promoter_Qty__c, GC_Total_Passive_Qty__c, GC_Total_Detractor_Qty__c FROM Campaign WHERE Id =: ca.Id LIMIT 1];
        System.assertEquals(resultCampaign.GC_Total_Promoter_Qty__c, 2);
        
        delete listCases[1];
        resultCampaign = [SELECT Id, GC_Total_Promoter_Qty__c, GC_Total_Passive_Qty__c, GC_Total_Detractor_Qty__c FROM Campaign WHERE Id =: ca.Id LIMIT 1];
        System.assertEquals(resultCampaign.GC_Total_Promoter_Qty__c, 1);
    }
    
    private static testMethod void TriggerChangeVisibility()
    {
        RecordType rtCase = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'Survey Result' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='ES_Sales Representative' LIMIT 1];
        User u = [SELECT Id, Name FROM User WHERE ProfileId =: p.Id AND IsActive = true LIMIT 1];
        
        //Create Country
        Country__c co = new Country__c();
        co.Name = 'testCountry';
        insert co;
        
        //Create Account        
        Account ac = new Account();
        ac.Name = 'TestAccount';
        ac.Category__c = 'Farm';
        ac.GC_Status_Descr__c = 'Active';
        ac.CountryRef__c = co.Id;
        ac.OwnerId = u.Id;
        insert ac;      
            
        Case c = new Case();
        c.RecordTypeId = rtCase.Id;
        c.AccountId = ac.Id;
        c.Status = 'New';           
        insert c;
        
        System.runAs(u)
        {
            Case cAux = [SELECT Id FROM Case WHERE AccountId =: ac.Id LIMIT 1];
            System.assertEquals(c.Id, cAux.Id);
        }           
        
    }
    private static testMethod void TriggerCaseAccountManager()
    {
        RecordType rtCase = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'Survey Result' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='FR_Sales Representative' LIMIT 1];
        User u = [SELECT Id, Name, ManagerId FROM User WHERE ProfileId =: p.Id AND IsActive = true AND ManagerId != null LIMIT 1];
        
        //Create Country
        Country__c co = new Country__c();
        co.Name = 'testCountry';
        insert co;
        
        //Create Account        
        Account ac = new Account();
        ac.Name = 'TestAccount';
        ac.Category__c = 'Farm';
        ac.GC_Status_Descr__c = 'Active';
        ac.CountryRef__c = co.Id;
        ac.OwnerId = u.Id;
        insert ac;
        
        Case c = new Case();
        c.RecordTypeId = rtCase.Id;
        c.AccountId = ac.Id;
        c.Status = 'New';
        c.NPS_RESULT_Q1__c = 8;         
        insert c;
        
        Case caseAux = [SELECT Id, LKP_Account_Owner_Manager__c  FROM Case WHERE Id =:c.Id LIMIT 1];
        System.assertNotEquals(caseAux.LKP_Account_Owner_Manager__c , null);
    
    }
}