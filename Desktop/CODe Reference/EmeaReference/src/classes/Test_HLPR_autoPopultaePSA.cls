@isTest
public class Test_HLPR_autoPopultaePSA {
    testMethod public Static Void TestautoPopultaePSA(){
        Profile p = [select id from profile where name='System Administrator'];
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',
        timezonesidkey='America/Los_Angeles', username='usertest1@noemail.com',SAP_Partner_Code__c='abcd');
        insert u;
        System.runAs(u){
        RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            Country__c toCountry= new Country__c(Name='HQ1', TacticalPlanSetting__c='HQ1', DE_EnableAccountSharing__c=true);
            insert toCountry;
            //Account Creation
            Account acc=new Account(Name='Test1',CountryRef__c=toCountry.ID);
            insert acc;
            /*Contact con=new Contact(Lastname='Test user');
            insert con;*/
          
            List<Case> lstcase=new List<Case>();
            //case Creation
            Case c1=new Case();
            c1.AccountId=acc.Id;
            c1.Reason='Invoice';
            c1.GC_Secondary_Reason_Descr__c='Invoice Copy';
            c1.Origin='Email';
            c1.Status='Open';
            c1.Priority='Medium';
            c1.RecordTypeId=recType.id;
            lstcase.add(c1);
            Insert lstcase;
            //partner function creation
            Partner_Function__c pf=new Partner_Function__c();
            pf.Name='TCS Test';
            pf.Partner_SAP_ID__c='abcd';
            pf.Partner_Function_Code__c='YW';
            pf.Primry_Acct_Integration_Key__c=acc.Id;
            Insert pf;
            Test.startTest();
            HLPR_autoPopultaePSA.processInsert(lstcase);
            Test.stopTest();
            
  }
        
}
    testMethod public Static Void TestautoPopultaePSA2(){
        
        Profile p = [select id from profile where name='System Administrator'];
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',
        timezonesidkey='America/Los_Angeles', username='usertest1@noemail.com',SAP_Partner_Code__c='abcd');
        insert u;
        System.runAs(u){
        RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            Country__c toCountry= new Country__c(Name='HQ1', TacticalPlanSetting__c='HQ1', DE_EnableAccountSharing__c=true);
            insert toCountry;
            //Account Creation
            Account acc1=new Account(Name='Test1',CountryRef__c=toCountry.ID);
            insert acc1;
            List<Case> lstcase1=new List<Case>();
            Case c2=new Case();
            c2.AccountId=acc1.Id;
            c2.Reason='Invoice';
            c2.GC_Secondary_Reason_Descr__c='Invoice Copy';
            c2.Origin='Email';
            c2.Status='Open';
            c2.Priority='Medium';
            c2.RecordTypeId=recType.id;
            lstcase1.add(c2);
            Insert lstcase1;
             //partner function creation
            Partner_Function__c pf=new Partner_Function__c();
            pf.Name='TCS Test';
            //pf.Partner_SAP_ID__c='abcd';
           // pf.Partner_Function_Code__c='YW';
            pf.Primry_Acct_Integration_Key__c=acc1.Id;
            Insert pf;
            Test.startTest();
            HLPR_autoPopultaePSA.processInsert(lstcase1);
            Test.stopTest();
            
        
        
        
        
        
        }
        
        
        
        
        
        
        
        
    }  

}