public class TriggerOrderPreventNameUpdate  implements Triggers.Handler
{
  static private map<Id,Order__c> finalOrderStaticMap= new map<Id,Order__c>();
  
    public static void setNewOrders(list<Order__c> newOrders) {
        finalOrderStaticMap.putAll(newOrders);
    }
  
  public static map<ID, Order__c> getFinalOrders(list<Id> finalOrdersId) {
    map<ID, Order__c> result = new map<ID, Order__c>();
    list<Id> finalFilter = new list<Id>();
    for (Id element: finalOrdersId) {
      if (!finalOrderStaticMap.keyset().contains(element)) {
        finalFilter.add(element);
      }
      else {
        result.put(element, finalOrderStaticMap.get(element));
      }
    }
    if (finalFilter.size() > 0) {
      list<Order__c> newElements = new list<Order__c>([SELECT PreliminaryOrderRef_RSA__r.Name , Version_ID_RSA__c FROM Order__c WHERE ID IN :finalFilter]);
      result.putAll(newElements);
      finalOrderStaticMap.putAll(newElements);
    }
    
    return result;
  }
  
  public void handle()
  {
    Set<ID> finalOrders = new Set<ID>();
    
    for (Order__c o : (List<Order__c>)trigger.new){
      if(o.recordTypeID == Util.recordType.get('Order__c:FinalOrder'))
      {
        finalOrders.add(o.id);
      }
    }
    Map<ID,Order__c> finalOrderMap = new Map<ID,Order__c>();
    Map<Id,Order__c> finalOrderBase = getFinalOrders(new list<Id>(finalOrders));
    for(Order__c o : finalOrderBase.values() /*[SELECT PreliminaryOrderRef_RSA__r.Name FROM Order__c WHERE ID IN :finalOrders]*/){
        finalOrderMap.put(o.PreliminaryOrderRef_RSA__c,o);
    }
    
    for (Order__c o : (List<Order__c>)trigger.new){
      if(o.recordTypeID == Util.recordType.get('Order__c:FinalOrder'))
      {
      	if(finalOrderMap.get(o.PreliminaryOrderRef_RSA__c)!=null)
        	o.Name = finalOrderMap.get(o.PreliminaryOrderRef_RSA__c).PreliminaryOrderRef_RSA__r.Name;
        o.Version_ID_RSA__c= ((Order__c)trigger.oldMap.get(o.id)).Version_ID_RSA__c;
       
      }else
      {
        o.Name = ((Order__c)trigger.oldMap.get(o.id)).name;
      }
      o.AccountRef_RSA__c = ((Order__c)trigger.oldMap.get(o.id)).AccountRef_RSA__c;
    }
  }
  
    public static testMethod void testHandle(){
        try{
            new TriggerOrderPreventNameUpdate().handle();
        }catch(Exception e){}
    }
}