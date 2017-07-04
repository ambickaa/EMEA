@isTest
public class Test_VFC_UnreadWarning{
   testMethod public static void testmethod1(){
       Country__c toCountry= new Country__c(Name='HQ', TacticalPlanSetting__c='HQ', DE_EnableAccountSharing__c=true);
        insert toCountry;
            
        //Account Creation
         Account acc1=new Account(Name='Test1',CountryRef__c=toCountry.ID);
         Database.insert (acc1);
         //case creation
        // Case c=new Case();
        
    Case case1=new Case(AccountId=acc1.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',Origin='Email',Status='Open',Priority='Medium');
            insert case1;
            
            
 ApexPages.StandardController con = new ApexPages.standardController(case1);
 
 
        
            case1.GC_IsUnread_Email__c =True;
            update case1;
         VFC_UnreadWarning a=  new VFC_UnreadWarning (con);
        //ApexPages.StandardController con = new ApexPages.standardController(case1);
 
PageReference pg = Page.VFP_UnreadWarning;

    Test.setCurrentPage(pg);


        a.Save();
    }
 }