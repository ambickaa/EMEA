Global class Batch_StatusUpdate implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Status,IsEscalated,GC_IsEscalated__c FROM Case where IsEscalated = True';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
        
        if(scope.size()>0)
        {
         for(Case c : scope)
         {
             if(!c.GC_IsEscalated__c )
             {
                 c.GC_IsEscalated__c = True;
                 c.Status= 'Escalated';
                   
                 }                  
         }
                 database.update(scope);
        }
    }   
    global void finish(Database.BatchableContext BC)
    {
     
    }
}