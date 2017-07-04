Global class Batch_AccountSAPUpdate implements Database.Batchable<sObject> {
    Private String query='' ;   
    global Batch_AccountSAPUpdate(){
        query = 'select id,account.name,Account_SAP_Nbr_Text__c,Account.GC_SAP_ID__c from case where accountid!=null and recordtypeid =\''+System.Label.ServicecaseRTId+'\''; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //String query = 'select id,account.name,Account_SAP_Nbr_Text__c,Account.GC_SAP_ID__c from case where accountid!=null and Account.GC_SAP_ID__c!=null and recordtypeid =\''+System.Label.ServicecaseRTId+'\'';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
        List<Case> caseToUpdate = new List<Case>();
        //system.debug('scope.size()'+scope.size());
        if(scope.size()>0)
        {
         for(Case c : scope)
         {
         
             //system.debug('c.accountid'+c.accountid);
            if(c.accountid!=null )
            {
                if( c.account.GC_SAP_ID__c!=null)
                {
                    if(c.Account_SAP_Nbr_Text__c==null){
                        c.Account_SAP_Nbr_Text__c = c.account.GC_SAP_ID__c; 
                        caseToUpdate.add(c);
                       //system.debug('caseToUpdate.size()'+caseToUpdate.size());
                    }
                }                  
            }
            update caseToUpdate;
        }
    }  
    } 
    global void finish(Database.BatchableContext BC)
    {
     
    }
}