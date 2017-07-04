public with sharing class TriggerVoucherGiveStockBack implements Triggers.Handler{

  public Map<Id,String> oldStatus = new  Map<Id,String>();  
  public Map<Id,String> newStatus = new  Map<Id,String>();
  public List<Id> vouchersToRejectStock = new List<Id>();
  public Map<Id, Decimal> PCEToReject = new Map<Id,Decimal>();
  public List<ProductCatalogEntry__c> PceToUp = new List<ProductCatalogEntry__c>();
  public List<VoucherLineItem__c> vliToUpdate  =new List<VoucherLineItem__c>();  
  public void handle()
  {
     for (Voucher__c v : (List<Voucher__c>)Trigger.old)
     {
     	oldStatus.put(v.Id,v.Status__c);
     }
     for (Voucher__c v : (List<Voucher__c>)Trigger.new)
     {
     	newStatus.put(v.Id, v.Status__c);
     }
     
     for (ID vou : oldStatus.keyset() )
     {
     	if(oldstatus.get(vou)=='Waiting for approval' && newStatus.get(vou)=='Rejected')
     	{
     		vouchersToRejectStock.add(vou);
     		
     	}
     
     }
     
   for (VoucherLineItem__c vli : [SELECT id, 
										 VoucherRef__c,
										 Agreed__c,
										 CampaignLineItemRef__c,
										 campaignLineItemRef__r.ProductCatalogEntryRef__c
								FROM VoucherLineItem__c
								WHERE voucherRef__c IN :vouchersToRejectStock])
		{
			vli.CampaignLineItemRef__c=null;
			vliToUpdate.add(vli);
			//PCEToReject.put(vli.campaignLineItemRef__r.ProductCatalogEntryRef__c, vli.Agreed__c);
		}
	/*
	for (ProductCatalogEntry__c pce : 
			[ SELECT id, in_use__c FROM ProductCatalogEntry__c WHERE id IN :PCEToReject.keyset()])
		{
			pce.in_use__c=pce.in_use__c - PCEToReject.get(pce.id);
			pceToUp.add(pce);
		}	
	for (VoucherLineItem__c vli : vliToUpdate ){
		vli.CampaignLineItemRef__c=null;
	}			
	*/
	Savepoint sp = Database.setSavepoint();	
	 try{		
    	//update pceToUp;
    	update vliToUpdate;
    	}
    catch(DMLException e)
        {
        system.debug('DML Exception was found :  ' + e);
   		Database.rollback(sp);
   		}						
  }
  
}