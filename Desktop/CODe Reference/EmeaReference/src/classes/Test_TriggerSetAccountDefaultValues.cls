@IsTest
public class Test_TriggerSetAccountDefaultValues{

    public static testmethod void test(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User();
        u.Alias = 'standt'; 
        u.Email='standarduser@testorg.com';
        u.EmailEncodingKey='UTF-8'; 
        u.LastName=Label.IntegrationUserCheck; 
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US'; 
        u.ProfileId = p.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        u.UserName='standarduser123@testorgforce123456.com';
        insert u;
        System.Debug('@@@ '+u.Name);
                        
      //Inserting Country data
        Country__c country=new Country__c();
        country.Name='Spain';
        insert country;
        
        //Inserting account data
        Account account=new Account();
            account.Name='Test Acc';
            account.CountryRef__c=country.Id;
            account.GC_Cust_Account_Grp_Descr__c='Ship-to Party';
        
        Account account1=new Account();
            account1.Name='Testing Acc';
            account1.CountryRef__c=country.Id;
        
        System.runAs(u) {
            insert account;
            insert account1;
        }
        
    }
 }