@isTest
public class Batch_StatusUpdate_Test {
    testMethod public Static Void Btachtestmethod(){
         Profile p = [select id from profile where name='System Administrator'];
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',
        timezonesidkey='America/Los_Angeles', username='usertest1@noemail.com');
        insert u;
        system.runAs(u){
            String query = 'SELECT Id,Status,IsEscalated,GC_IsEscalated__c FROM Case where IsEscalated = True';
            List<Case>listcase=new List<Case>();
            Country__c toCountry= new Country__c(Name='HQ1', TacticalPlanSetting__c='HQ1', DE_EnableAccountSharing__c=true);
            insert toCountry;
            Account acc=new Account(Name='Test',CountryRef__c=toCountry.ID);
            insert acc;
            Contact con=new Contact(Lastname='Test user');
            insert con;
            Case c1=new Case();
           c1.AccountId=acc.Id;
           c1.ContactId=con.id;
           c1.Reason='Invoice';
           c1.GC_Secondary_Reason_Descr__c='Invoice Copy';
           c1.Origin='Email';
           c1.Status='Open';
           c1.Priority='Medium';
           c1.IsEscalated=False;
            listcase.add(c1);
            insert listcase;
          
             Test.startTest();
            Batch_StatusUpdate Bs=new Batch_StatusUpdate();
            database.executeBatch(Bs);
            Test.stopTest();
            }
    }
        testMethod static void Btachtestmethod2(){
            Profile p = [select id from profile where name='System Administrator'];
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',
        timezonesidkey='America/Los_Angeles', username='usertest1@noemail.com');
        insert u;
            system.runAs(u){
                Country__c toCountry1= new Country__c(Name='HQ2', TacticalPlanSetting__c='HQ2', DE_EnableAccountSharing__c=true);
            insert toCountry1;
            Account acc1=new Account(Name='Test',CountryRef__c=toCountry1.ID);
            insert acc1;
            Contact con1=new Contact(Lastname='Test user');
            insert con1;
                Case c2=new Case();
                c2.AccountId=acc1.Id;
                c2.ContactId=con1.id;
                c2.Reason='Invoice';
           c2.GC_Secondary_Reason_Descr__c='Invoice Copy';
           c2.Origin='Email';
           c2.Status='Open';
           c2.Priority='Medium';
           c2.IsEscalated=True;
             List<Case>listcase1=new List<Case>();
            listcase1.add(c2);
            insert listcase1;
            Test.startTest();
            Batch_StatusUpdate Bs=new Batch_StatusUpdate();
            database.executeBatch(Bs);
            Test.stopTest();
                                      
                
            }
            
        }
        testmethod static Void Scheduler_Batch_StatusUpdatetest(){
             Test.startTest();
        Scheduler_Batch_StatusUpdate schdeduletest=new Scheduler_Batch_StatusUpdate();
        string sch = '0 0 * * 1-12 ? *';
        system.schedule('Process Trans 1', sch, schdeduletest);
      
        Test.stopTest();
        
        
        
        }
    }