global class Scheduled_Batch_CP_ordered_Delivered implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {                           
        List<String> listAccounts = Label.Batch_CP_Acc_NoStd.split('\r\n');
        List<String> listDTstd = Label.Batch_CP_DocType_Std.split('\r\n');
        List<String> listDT = Label.Batch_CP_DocType_NoStd.split('\r\n');
        
        String query = 'SELECT id FROM account WHERE ';
        query+='Id IN (SELECT AccountId FROM Order WHERE Divison_Code__c =\'15\'';
        query+=' AND (GC_Document_Type_Descr__c IN :listDTstd';
        query+=' OR (GC_Document_Type_Descr__c IN :listDT';     
        query+=' AND Account.GC_Integration_Key__c IN :listAccounts';       
        query+=')))';
        
        id jobid= Database.executeBatch (new Batch_CP_ordered_Delivered(query, 24), 10);        
    }    
}