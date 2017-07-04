@isTest
public class Test_everis_ACS_deploy_4 {

    private static testMethod void testChangeYearOnCountry()
    {
        Year__c y1 = new Year__c (Name = '2013');
        Year__c y2 = new Year__c (Name = '2014');
        Year__c y3 = new Year__c (Name = '2015');
        Year__c y4 = new Year__c (Name = '2016');
        
        //Years are inserted for ID
        insert y1;
        insert y2;
        insert y3;
        insert y4;
        
        //Next Years
        y1.YearNextYear__c = y2.Id;
        y2.YearNextYear__c = y3.Id;
        y3.YearNextYear__c = y4.Id;
        
        //Previous Years
        y4.YearPreviousYear__c = y3.Id;
        y3.YearPreviousYear__c = y2.Id;
        y2.YearPreviousYear__c = y1.Id;
        
        //Years are updated 
        update y1;
        update y2;
        update y3;
        update y4;
        
        Country__c testC1 = new Country__c (Name = 'testCountry1');
        Country__c testC2 = new Country__c (Name = 'testCountry2');
        testC1.LKP_CurrentYear__c = y2.Id;
        testC2.LKP_CurrentYear__c = y3.Id;
        
        insert testC1;
        insert testC2;
        
        testC1.LKP_CurrentYear__c = y3.Id;
        testC2.LKP_CurrentYear__c = y2.Id;
        
        update testC1;
        update testC2;
        
        system.assertEquals(testC1.LKP_CurrentYear__c, y2.YearNextYear__c);
        system.assertEquals(testC2.LKP_CurrentYear__c, y3.YearPreviousYear__c);
      
        //Test.stopTest();
    }
}