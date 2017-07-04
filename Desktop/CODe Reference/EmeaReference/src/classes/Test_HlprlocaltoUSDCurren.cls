@isTest(seeAlldata=true)
public class Test_HlprlocaltoUSDCurren {
    testMethod public Static Void testlocaltousdcurncy(){
        Profile p = [select id from profile where name='System Administrator'];
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',
        timezonesidkey='America/Los_Angeles', username='usertest1@noemail.com');
        insert u;
        System.runAs(u){
            Country__c toCountry= new Country__c(Name='HQ1', TacticalPlanSetting__c='HQ1', DE_EnableAccountSharing__c=true);
            insert toCountry;
            //Account Creation
            Account acc=new Account(Name='Test1',CountryRef__c=toCountry.ID);
            insert acc;
            List<Case> cn=new List<Case>();
            Case c1=new case(AccountId=acc.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',Origin='Email',Status='Open',Priority='Medium',GC_Amount_in_LC_Currncy__c=12.0,GC_CA_Cst_LC_Currncy__c=23.0,GC_Currency_Descr__c='CYP');
            Case c2=new Case(AccountId=acc.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',Origin='Email',Status='Open',Priority='Medium',GC_Currency_Descr__c='CYP',GC_Amount_in_LC_Currncy__c=null,GC_CA_Cst_LC_Currncy__c=0);
            cn.add(c1);
            cn.add(c2);
            Test.startTest();
            insert cn;
            HlprlocaltoUSDCurren cas=new HlprlocaltoUSDCurren();
            cas.currencyUpdate(cn);
            Test.stopTest();
        }
    }
    
    testMethod public Static Void testlocaltousdcurncy2(){
        Profile p = [select id from profile where name='System Administrator'];
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',
        timezonesidkey='America/Los_Angeles', username='usertest1@noemail.com');
        insert u;
        System.runAs(u){
        
        Country__c toCountry= new Country__c(Name='HQ1', TacticalPlanSetting__c='HQ1', DE_EnableAccountSharing__c=true);
            insert toCountry;
            //Account Creation
            Account acc=new Account(Name='Test1',CountryRef__c=toCountry.ID);
            insert acc;
            List<Case> cn=new List<Case>();
            Case c1=new case(AccountId=acc.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',Origin='Email',Status='Open',Priority='Medium');
            Case c2=new Case(AccountId=acc.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',Origin='Email',Status='Open',Priority='Medium',GC_Currency_Descr__c='CYP',GC_Amount_in_LC_Currncy__c=0,GC_CA_Cst_LC_Currncy__c=null);
            cn.add(c1);
            cn.add(c2);
            Test.startTest();
            insert cn;
            HlprlocaltoUSDCurren cas=new HlprlocaltoUSDCurren();
            cas.currencyUpdate(cn);
            Test.stopTest();
            
            
        }
        
    } 
 }