public with sharing class TriggerVoucherPreventNameUpdate implements Triggers.Handler{

  public Map<Id,String> oldNames = new  Map<Id,String>();  
    
  public void handle()
  {
     for (Voucher__c v : (List<Voucher__c>)Trigger.old)
     {
     	oldNames.put(v.Id,v.Name);
     }
     for (Voucher__c v : (List<Voucher__c>)Trigger.new)
     {
     	v.Name=oldNames.get(v.ID);
     }     
  }
  
  
}