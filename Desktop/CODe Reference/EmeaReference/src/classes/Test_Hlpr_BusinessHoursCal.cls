@isTest
private class Test_Hlpr_BusinessHoursCal {
     private static testmethod void testcasebusiness(){
        Profile p = [select id from profile where name='System Administrator'];
            // create a user to run the test as
             Country__c toCountry= new Country__c(Name='HQ', TacticalPlanSetting__c='HQ', DE_EnableAccountSharing__c=true);
        insert toCountry;
        
            User u = new User(alias = 'usertest', email='usertest11@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='HQ',
                timezonesidkey='America/Los_Angeles', username='usertest11@noemail.com');
                
               BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
            system.runAs(u)
            {
            system.debug('+++defaultHours' + defaultHours);
            Account acc=new Account(Name='Test',CountryRef__c=toCountry.ID);
            insert acc;
            Contact con=new Contact(accountid=acc.id,Lastname='Test user');
            insert con;

      List<case>lstcase=new List<Case>();
            Map<id,case> oldmap = new Map<id,case>();
             RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            Case c1=new Case(AccountId=acc.Id,ContactId=con.id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',
                              Origin='Email',Status='Open',Priority='Medium',description = 'Test',subject='Test',GC_First_Resp_To_Cust_Date__c=Date.today(),
                              BusinessHoursId=defaultHours.id,Is_ByPass__c=true,recordtypeId= System.Label.ServicecaseRTId);
            
            lstcase.add(c1);
            insert lstcase;
           Test.StartTest();
           Hlpr_BusinessHoursCal.processcases(lstcase,oldMap);
            //c1.GC_Case_Age_in_Business_Hours_nbr__c = 
           //update c1;
            Test.StopTest();  
           
            }      
      }
      
       /*private static testmethod void test_Hlpr_GlobalFirstResponseDate(){
             
          Case cNew = [select id from case limit 1] ;
          cNew.Status = 'New';
          update cnew;
          cNew.Status = 'Closed';
          update cnew;
          task tNew = [select id from task limit 1 ];
          tNew.Type='Email';
          update tNew;
          cNew.Status = 'Closed';
          update cnew;
          system.debug('+++ GC_First_Resp_To_Cust_Date__c' + cNew.GC_First_Resp_To_Cust_Date__c);   
      }*/
    
      private static testmethod void test_Hlpr_GlobalFirstResponseDate1(){
      Profile p = [select id from profile where name='System Administrator'];
            // create a user to run the test as
            
        
            User u = new User(alias = 'ust82', email='usrtst821@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='HQ',
                timezonesidkey='America/Los_Angeles', username='usertest811@noemail.com');
                
               BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
            system.runAs(u){
          Datetime timestamp=System.now();
          Country__c country = new Country__c(Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
          insert country;
          Account account = new Account (CountryRef__c=country.Id,Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), 
                                       Category__c='Farm');
          insert account;
          Contact contact= new Contact(CountryRef__c=country.Id,FirstName='Pablo', LastName='Mora',  AccountId=account.id);
          insert contact;
          
          Case casex = new Case (AccountId=account.Id,Is_ByPass__c=true,recordtypeId= System.Label.ServicecaseRTId, ContactId=contact.Id, Subject='testSubject', Description='description',
                               GC_Resolution_Text__c='Valid Support',GC_Functional_Area_Descr__c='Cases', Type='Bug',Status='New' );
          insert casex;
          Task task =new Task(WhatId = casex.id, WhoId=contact.Id, Subject='Call', Status='New', Priority='Normal',  
                            ActivityDate=Date.today(),type='Call');
          insert task;
          update casex;
          
      }

}
}