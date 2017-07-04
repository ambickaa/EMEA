public class CaseItem {
    
    public Change_Request__c record {get;set;}
   // public String accountName {get;set;}
    
    public CaseItem(Change_Request__c cas){  
        record=cas;
    //    if(cas.AccountID != null )
    //        accountName=[SELECT Name FROM Account WHERE Id=:cas.AccountID LIMIT 1].Name;
    } 
    public Change_Request__c getCase(){return record;}
   // public String getaccountName(){return accountName;}   
}