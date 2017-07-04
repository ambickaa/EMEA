@isTest
public class Test_BatchArticleUpdateCase {
      testMethod private static void testMethod1(){
          
        
        Profile p = [select id from profile where name='System Administrator'];
        // create a user to run the test as
         Country__c toCountry= new Country__c(Name='HQ', TacticalPlanSetting__c='HQ', DE_EnableAccountSharing__c=true);
        insert toCountry;
        
        User u = new User(alias = 'usertest', email='usertest1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='HQ',
        timezonesidkey='America/Los_Angeles', username='usertest1@noemail.com');
        insert u;
        system.runAs(u){
           Account a =  new Account();
           //a.RecordTypeId = '012L00000004UId';
           a.Name = 'Test';
           a.CountryRef__c= toCountry.id;
           insert a; 
           system.debug('1+++' + a);
           Contact con = new Contact();
           //con.Contact_Type_Descr__c = 'Internal';
           con.LastName = 'Test';
           //con.GC_Type__c = 'Invoice';
           con.AccountId = a.id;
           //con.State_Cd__c = 'Active';
          
           insert con;
           system.debug('2+++' + con);
           
            Case c = new Case();
            c.RecordTypeid = System.Label.ServicecaseRTId;
            c.contactid = con.id;
            c.accountid = a.id;
            c.Priority = 'Medium';
            c.reason = 'Returns';
            c.status = 'Open';
            c.origin ='Email';
            c.GC_CaseArticle_Text__c = '';
            insert c;
            
              String str =   c.GC_CaseArticle_Text__c ;
                        
              //ACS 1.1
              Process_Documentation__kav art1= new Process_Documentation__kav();
               art1.Title='test';
               art1.UrlName = 'testURL';
               art1.GC_Expiration_Date__c=Date.parse('12/02/2015');//ACS 1.1
               art1.GC_Next_Review_Date__c=Date.parse('12/02/2015');//ACS 1.1
              insert art1;
              
              /*Case_Resolution__kav art1 = new Case_Resolution__kav();
              art1.Title='test';
             // art1.PublishStatus = 'Published';
                art1.UrlName = 'testURL';
             insert art1;*/
            
              KnowledgeArticleVersion a1 = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Id = :art1.id];
              //system.debug('+++11' + art1);
                
              CaseArticle caseArt =  new CaseArticle();
              caseArt.CaseId = c.id;
              caseart.KnowledgeArticleId = a1.KnowledgeArticleId;
            
              insert caseArt;
          
              List<Case> caseList = [select id,GC_CaseArticle_Text__c,(select CaseId,Id,KnowledgeArticleId from case.CaseArticles) from Case where id = :c.Id limit 1];   
              if(caseList.size()>0)
              {
               
               //system.assertEquals('False',caseList[0].GC_CaseArticle_Text__c);
              }             
            
            Scheduler_BatchArticleUpdateCase schdl=new Scheduler_BatchArticleUpdateCase();
            BatchArticleUpdateCase batchTest =  new BatchArticleUpdateCase();
              Test.startTest();
              Id batchProcessId = Database.executeBatch(batchTest);
              Test.stopTest();  
              
              List<Case> caseList1 = [select id,GC_CaseArticle_Text__c,(select CaseId,Id,KnowledgeArticleId from case.CaseArticles) from Case where id = :c.Id limit 1];   
              if(caseList1.size()>0)
              {
              System.debug('Check 1 :' + caseList1);
              // system.assertEquals('True',caseList1[0].GC_CaseArticle_Text__c);
              } 
              
            
             AsyncApexJob ap = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchProcessId limit 1];
             
             System.AssertEquals('Completed', ap.status);
            System.AssertEquals(0, ap.NumberOfErrors);
             }
      }
        
       testMethod private static void testMethod2()
          {
        Profile p = [select id from profile where name='System Administrator'];
        
         Country__c toCountry= new Country__c(Name='HQ', TacticalPlanSetting__c='HQ', DE_EnableAccountSharing__c=true);
        insert toCountry;
        
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest2@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='HQ',
        timezonesidkey='America/Los_Angeles', username='usertest2@noemail.com');
        insert u;
        system.runAs(u){
          Account a =  new Account();
          //a.RecordTypeId = '012L00000004UId';
          a.Name = 'Test';
          a.CountryRef__c = toCountry.id;
          insert a; 
          system.debug('1+++' + a);
          Contact con = new Contact();
          //con.Contact_Type_Descr__c = 'Internal';
          con.LastName = 'Test';
         // con.GC_Type__c = 'Invoice';
          con.AccountId = a.id;
        //  con.State_Cd__c = 'Active';
          
            insert con;
            system.debug('2+++' + con);
           
            Case c1 = new Case();
           //c1.RecordTypeid = '01230000001DMS3';
            c1.contactid = con.id;
            c1.accountid = a.id;
            c1.Priority = 'Medium';
            c1.reason = 'Returns';
            c1.status = 'Open';
            c1.origin ='Web';
                       
            insert c1;
            system.debug('+++*Case' + c1);
            
            BatchArticleUpdateCase batchTest =  new BatchArticleUpdateCase();
            Test.startTest();
            database.executeBatch(batchTest);
            Test.stopTest(); 
              List<Case> caseList1 = [select id,GC_CaseArticle_Text__c,(select CaseId,Id,KnowledgeArticleId from case.CaseArticles) from Case where id = :c1.Id limit 1];   
              if(caseList1.size()>0)
              {
               system.debug('+++ case check' + caseList1 + ' caseArticle Check' + caseList1[0].caseArticles ); 
               system.assertEquals('False',caseList1[0].GC_CaseArticle_Text__c);
              } 
            }
          }
    testMethod private static void testMethod3(){
        Test.startTest();
        Scheduler_BatchArticleUpdateCase schdeduletest=new Scheduler_BatchArticleUpdateCase();
        string sch = '0 0 * * 1-12 ? *';
        system.schedule('Process Trans 1', sch, schdeduletest);
        //Scheduler_BatchArticleUpdateCase.SchedulerMethod();
        Test.stopTest();
        
       
        
        
        
        
    }
}