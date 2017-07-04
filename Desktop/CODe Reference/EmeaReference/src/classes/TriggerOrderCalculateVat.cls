public with sharing class TriggerOrderCalculateVat implements Triggers.Handler
{
 static private map<Id, Account> OrderStaticMap= new map<Id,Account>();
    
   public static map<ID, Account> getOrders(list<Id> AccountsId) {
        map<ID, Account> result = new map<ID, Account>();
        list<Id> finalFilter = new list<Id>();
        for (Id element: AccountsId) {
            if (!OrderStaticMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, OrderStaticMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<Account> newElements = new list<Account>([Select GC_VATIN_Number__c from Account where id in :finalFilter]);
            result.putAll(newElements);
            OrderStaticMap.putAll(newElements);
        }
        
        return result;
    }   
    
  public void handle()
  {
    list<Id> accountsList = new list<Id>();
    for (Order__c element :(list<Order__c>)trigger.new) {
        accountsList.add(element.AccountRef_RSA__c);
    }
   Map<Id, Account> accounts=getOrders(accountsList);
   for(Order__c o: (list<Order__c>)trigger.new ){
     Account item = accounts.get(o.AccountRef_RSA__c);
     if(item != null && item.GC_VATIN_Number__c!='' && item.GC_VATIN_Number__c!= null ){
        o.VAT_RSA__c=double.valueOf(SystemSettings__c.getValues('VAT_value0_RSA').Value__c);
     }else{
        o.VAT_RSA__c=double.valueOf(SystemSettings__c.getValues('VAT_RSA').Value__c);
     }
   }
  
  }
}