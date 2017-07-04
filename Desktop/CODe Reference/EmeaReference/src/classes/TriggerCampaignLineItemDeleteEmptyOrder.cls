public without sharing class TriggerCampaignLineItemDeleteEmptyOrder implements Triggers.Handler
{
	private static map<Id, Order__c> ordersStaticMap = new map<Id, Order__c>();
	
	public static void setNewOrders(list<Order__c> newElements) {
		ordersStaticMap.putAll(newElements);
	}
	
	public static map<Id, Order__c> getOrders(list<Id> ordersList) {
		map<Id, Order__c> result = new map<Id, Order__c>();
		list<Id> finalFilter = new list<Id>();
		for (Id element: ordersList) {
			if (!ordersStaticMap.keyset().contains(element)) {
				finalFilter.add(element);
			}
			else {
				result.put(element, ordersStaticMap.get(element));
			}
		}
		if (finalFilter.size() > 0) {
			list<Order__c> newElements = new list<Order__c>([SELECT Id,(SELECT ID FROM PreliminaryItems__r),(SELECT ID FROM FinalItems__r) FROM Order__c WHERE Id in :finalFilter]);
			result.putAll(newElements);
			ordersStaticMap.putAll(newElements);
		}
		return result;
	}
	
  public void handle()
  {
      Set<ID> preliminaryOrdersID = new Set<ID>();
      Set<ID> finalOrdersID = new Set<ID>();
      for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old)
      {
        if(cli.PreliminaryOrderRef_RSA__c != null)
            preliminaryOrdersID.add(cli.PreliminaryOrderRef_RSA__c);
        else if(cli.FinalOrderRef_RSA__c != null)
            finalOrdersID.add(cli.FinalOrderRef_RSA__c);
      }
      /*map<Id,Order__c> ordersInvolved = new map<Id,Order__c>([SELECT Id,(SELECT ID FROM PreliminaryItems__r),(SELECT ID FROM FinalItems__r) FROM Order__c WHERE Id in :preliminaryOrdersID OR Id in :finalOrdersID ]);*/
      list<Id> totalList = new list<Id>(preliminaryOrdersID);
      totalList.addAll(finalOrdersID);
      map<Id,Order__c> ordersInvolved = getOrders(totalList);
      
      List<Order__c> preliminaryOrders = new list<Order__c>();
      List<Order__c> finalOrders = new list<Order__c>();
      
      for (Id i:preliminaryOrdersID){
      	if(ordersInvolved.get(i) != null){
      		preliminaryOrders.add(ordersInvolved.get(i));
      	}
      }
      for (Id i:FinalOrdersID){
      	if(ordersInvolved.get(i) != null){
      		finalOrders.add(ordersInvolved.get(i));
      	}
      }
      
      List<Order__c> ordersToDelete = new List<Order__c>();
      for(Order__c o : preliminaryOrders){
          if(o.PreliminaryItems__r.size() == 0){
              ordersToDelete.add(o);
          }
      }
      
      for(Order__c o : finalOrders){
          if(o.FinalItems__r.size() == 0){
              ordersToDelete.add(o);
          }
      }
      
      delete ordersToDelete;
  }
}