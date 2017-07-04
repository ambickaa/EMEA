@isTest
public with sharing class Test_TriggerCountCases {

	private static testmethod void TriggerCaseNPSResults() 
    {        
        List<Case> listCases = new List<Case>();
        RecordType rtCase = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'Survey Result' LIMIT 1];
        RecordType rtCase2 = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'Standard Cases Record Type' LIMIT 1];
        
        //Create Country
        Country__c co = new Country__c();
        co.Name = 'testCountry';
        insert co;
               
        //Create Account
        Account ac = new Account();
        ac.Name = 'TestAccount';
        ac.CountryRef__c = co.Id;
        insert ac;
        
        //Create case
        Case ca1 = new Case();
        ca1.AccountId = ac.Id;
        ca1.RecordTypeId = rtCase.Id;
        		
		//Create Case2
		Case ca2 = new Case();
		ca2.AccountId = ac.Id;
		ca2.RecordTypeId = rtCase.Id;
		
		//Create Case2
		Case ca3 = new Case();
		ca3.AccountId = ac.Id;
		ca3.RecordTypeId = rtCase2.Id;
		
		listCases.add(ca1);
		listCases.add(ca2);
		listCases.add(ca3);		
		insert listCases;
		
		Account numcases = [SELECT Id, NUM_NPS_Case_Number__c FROM Account WHERE Id =: ac.Id LIMIT 1];
		
		System.assertEquals(numcases.NUM_NPS_Case_Number__c, 2);
		
		delete listCases;
		
		Account numcases2 = [SELECT Id, NUM_NPS_Case_Number__c FROM Account WHERE Id =: ac.Id LIMIT 1];
		
		system.debug(numcases2.NUM_NPS_Case_Number__c);
		
		System.assertEquals(numcases2.NUM_NPS_Case_Number__c, 0);
		}
}