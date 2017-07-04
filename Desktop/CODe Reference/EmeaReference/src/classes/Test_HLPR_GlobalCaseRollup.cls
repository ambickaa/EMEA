@isTest
public class Test_HLPR_GlobalCaseRollup {
 public static List<Case> ListCase = new List<Case>();
     
    @TestSetup static void test1(){
       List<Case> lstCases = new List<Case>(); 
     Account acc1 = new Account(name='Test');
       Id rtype = Schema.SObjectType.case.getRecordTypeInfosByName().get('Service Case').getRecordTypeId();
       insert acc1;
       Case ca1 = new Case(Accountid=acc1.id,origin='Email',Status='Open',Priority='Medium');
       insert ca1;
       Case ca2 = new Case(Accountid=acc1.id,origin='Email',Status='Open',Priority='Medium',Parentid=ca1.id,RecordTypeId=rtype);
       Case ca3 = new Case(Accountid=acc1.id,origin='Email',Status='Open',Priority='Medium',Parentid=ca2.id,RecordTypeId=rtype);
       Case ca4 = new Case(Accountid=acc1.id,origin='Email',Status='Open',Priority='Medium',Parentid=ca3.id,RecordTypeId=rtype);
       lstCases.add(ca2);
       lstCases.add(ca3);
       lstCases.add(ca4);
       insert lstCases;        
    }
   public static testMethod void GlobalCaseRollupTest1() { 
       
       Test.startTest();  
 
   List<Case> lstCases = [select id from case];
   Set<Id> parentid = new Set<Id>();
   Map<Id,Case> mapCases = new Map<Id,Case>();
   
   parentid.add(lstCases[0].id);
   parentid.add(lstCases[1].id);
   parentid.add(lstCases[2].id);
   mapCases.put(lstCases[1].id,lstCases[1]);
   HLPR_GlobalCaseRollup.CountChildCases(parentid,mapCases);
   HLPR_GlobalCaseRollup.storeoldvalues(mapCases);
       
       Test.stopTest();  
}
  
     public static testMethod void GlobalCaseRollupTest2() { 
       Account ac = new Account(name='Test');
       Test.startTest();  
       List<Case> lstCases = [select id from case where parentid!=null];
       delete lstCases;  
       Test.stopTest();  
     }    
    
    public static testMethod void GlobalCaseRollupTest3() { 
        Id rtype = Schema.SObjectType.case.getRecordTypeInfosByName().get('Service Case').getRecordTypeId();
        Account ac = new Account(name='Test');
        Test.startTest();
        List<Case> lstCases = [select id from case];
        Case c1 = new Case(Accountid=ac.id,origin='Email',priority='Medium',status='Open',parentid=lstcases[0].id,RecordTypeId=rtype);
        insert c1;
        Test.stopTest();
     }
}