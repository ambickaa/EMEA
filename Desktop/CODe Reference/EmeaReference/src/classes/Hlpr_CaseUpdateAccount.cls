/*
    Created By   : Accenture IDC
    Created Date : 9/6/2016
    This class is invoked by Case Before Insert trigger 
*/

public class Hlpr_CaseUpdateAccount{     
        static final String origin = 'Fax';
        static boolean isRunningFirst = true;
        //static string cs = WebEmail__c.getInstance('webmailvalue').EmailValue__c;
        
        static List<WebEmail__c> cs = WebEmail__c.getAll().Values();
        
        //This Method will update the new Cases Account by referring to fax number.
    public static void updateAccount(List<Case> lstCases){
        if(isRunningFirst){
        Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Case').getRecordTypeId();
        Set<Id> caseID = new Set<Id>();
        Set<String> faxString =  new Set<String>();
        Map<String,Account> mapAcc = new Map<String,Account>();
        Map<String,Contact> mapCon = new Map<String,Contact>();
        Set<String> webEmailValues = new Set<String>();
       // mapCS.putall(cs);
       System.debug('cs++'+cs);
        String faxno = '';
        webEmailValues = WebEmail__c.getAll().keyset();
        System.debug('webEmailValues++'+webEmailValues);
        if(!lstCases.isEmpty())
        {
        for(case c: lstCases){
            if(c.subject!=null && c.RecordTypeId == RId){
             faxno = c.subject.substringBetween('"');
             // this set will contains the faxnumber of new cases.
             if(faxno != null && faxno != '') // Support Team fix bug 2016.12.16
             	faxString.add(faxno);
             }  
        }
        system.debug('faxno++'+faxString);
        if(faxString!=null && !faxString.isEmpty()){  // Support Team fix bug 2016.12.16
            for(Account ac : [select id,fax from Account where fax!=null and fax in :faxString])
            {
                mapAcc.put(ac.fax,ac);
            }
             System.debug('mapAcc++'+mapAcc); 
            for(Contact cn : [select id,fax,Accountid from Contact where fax in :faxString limit :limits.getLimitQueryRows()])
            {
                mapCon.put(cn.fax,cn);
            }
            System.debug('mapCon++'+mapCon);
            for(Case c: lstCases)
            {            
           //    for(WebEmail__c we : cs){
            //   System.debug('we++'+we.EmailValue__c);
            System.debug('matching++'+webEmailValues.contains(c.SuppliedEmail));
            system.debug('c.SuppliedEmail++'+c.SuppliedEmail);
            System.debug('c.origin++'+c.origin);
            System.debug('origin++'+origin);
                if(c.origin!=null && (c.origin == origin || (c.SuppliedEmail!=null && webEmailValues.contains(c.SuppliedEmail) )))
                {
                system.debug('chk33++');
                    if(mapAcc.containsKey(faxno) && mapAcc!=null){
                        c.AccountId = mapAcc.get(faxno).Id; //The account will be assigned to the case
                        system.debug('chk1'+mapAcc.get(faxno).Id);
                    }
                    //System.debug('c.AccountId++'+mapAcc.get(faxno).Id);
                    if(mapCon.containsKey(faxno) && mapCon!=null){
                        c.ContactId = mapCon.get(faxno).Id;
                        c.AccountId = mapCon.get(faxno).Accountid;
                        System.debug('chk2'+mapCon.get(faxno).Id+''+mapCon.get(faxno).Accountid);
                    }                           
                    isRunningFirst = false;
              }        
            //   }
               System.debug('AccountId++'+c.AccountId);
               System.debug('ContactId++'+c.ContactId); 
            } 
            
        }
        }
        } 
    }
}