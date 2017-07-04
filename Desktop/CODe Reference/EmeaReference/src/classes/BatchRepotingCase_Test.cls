@isTest
private class BatchRepotingCase_Test

{  

     static testMethod void BatchRepotingCaseTest()
     {
        /*Country__c countries=new Country__c();
            countries.Name='TestCountry';
            Insert countries;
            */
            Account acc=new Account();
            acc.Name='Test Account';
            Insert acc;
            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
            
            system.debug('****hrs*****'+defaultHours.Id);
            Datetime targetTime = Datetime.newInstance(2013, 5, 28, 1, 6, 8);
            Datetime targetTime1 = Datetime.newInstance(2013, 5, 27, 1, 6, 4);
            Datetime targetTime2 = Datetime.newInstance(2013, 5, 26, 1, 6, 3);
              Datetime targetTime5 = Datetime.newInstance(2013, 5, 20, 1, 6, 3);
           
            Contact con=new Contact(Lastname='Test user');
            insert con;
            
             Case c1=new Case(AccountId=acc.Id,ContactId=con.id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',
                              Origin='Email',Status='Open',Priority='Medium',description = 'Test',recordtypeid='012570000003HCV');
            insert c1;
            

            Case c=new Case();
            c.RecordTypeId='012570000003HCV';
            c.AccountId=acc.id;
            c.status='Closed';
            c.GC_Secondary_Reason_Descr__c='Account Balance';
            c.GC_First_Resp_To_Cust_Date__c=targetTime1 ;
            //c.closeddate=targetTime;
            //c.CreatedDate =targetTime5;
            //c.LastModifiedDate=targetTime2; 
            c.BusinessHoursId=defaultHours.Id;
            insert c;
            
           // LIst<Case> CaseList=new List<Case>();
         //   CaseList.add(c);
             
       
       
       
       Test.startTest();
      List<Case> records=[select id,BusinessHoursId, status,LastModifiedDate,GC_First_Resp_To_Cust_Date__c, closeddate,CreatedDate from case where RecordTypeId='012570000003HCV'];
       BatchRepotingCase RptCase= new BatchRepotingCase();
       Database.executeBatch(RptCase,100);    
      RptCase.execute(null,records);
      Scheduler_BatchRepotingCase p=new Scheduler_BatchRepotingCase();
        string x = '0 0 * * * ? ';
        system.schedule('Scheduler_BatchRepotingCase Job', x, p);
       Test.stopTest();       
   
    }
    
}