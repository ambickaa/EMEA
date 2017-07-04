public with sharing class TriggerVoucherDiscountsCancelled implements Triggers.Handler {

    //------------------------------
    // TriggerVoucherDiscountsCancelled:
    // - Triggered before updating Voucher.
    // - TriggerVoucherDiscounts is responsible to generate FOC VLIs based on FOC CLIs existent in the Action Plan
    //   for Vouchers with the option "FOC Bags from AP" checked in its Voucher Campaign. This class removes the
    //   relation between the VLIs and the CLIs when the Vouchers are cancelled (or rejected, but it does not apply).
    // - eCIP Support Team -> 19.11.2015
    //------------------------------
    
    public List<CampaignLineItem__c> cliToDelete = new List<CampaignLineItem__c>();
    public List<VoucherLineItem__c> vliToUpdate = new List<VoucherLineItem__c>();
    public Map<Id, String> oldStatus = new Map<Id,String>();  
    public Map<Id, String> newStatus = new Map<Id,String>();
    public List<Id> vCancelled = new List<Id>();
    
    public void handle()
    {
        
        for(Voucher__c v : (List<Voucher__c>)Trigger.old)
            oldStatus.put(v.Id, v.Status__c);

        for(Voucher__c v : (List<Voucher__c>)Trigger.new)
            newStatus.put(v.Id, v.Status__c);

        //------------------------------
        // It populates list of cancelled Vouchers.
        //------------------------------
        for(Id v : oldStatus.keyset()) {
            if((oldstatus.get(v)!='Cancelled' && newStatus.get(v)=='Cancelled') || (oldstatus.get(v)!='Rejected' && newStatus.get(v)=='Rejected'))
                vCancelled.add(v);
        }
        
        List<Id> cliToDeleteId = new List<Id>();
        
        for(VoucherLineItem__c vli : [SELECT Id, CampaignLineItemRef__c, PICK_TYPE__c, VoucherRef__r.VoucherCampaignRef__r.Name
                                FROM VoucherLineItem__c
                                WHERE VoucherRef__c != null
                                AND VoucherRef__r.VoucherCampaignRef__c != null
                                AND VoucherRef__c IN : vCancelled]) {

            if(vli.PICK_TYPE__c == 'Free of charge' && vli.VoucherRef__r.VoucherCampaignRef__r.Name == 'Romania - OSR - 2016')
                cliToDeleteId.add(vli.CampaignLineItemRef__c);
                
            //------------------------------
            // Removing relationship between VLI and CLI with vli.CampaignLineItemRef__c = null.
            //------------------------------
            vli.CampaignLineItemRef__c = null;
            vliToUpdate.add(vli);
        }
        update vliToUpdate;
        
        for(CampaignLineItem__c cli : [SELECT Id
                                FROM CampaignLineItem__c
                                WHERE Id IN : cliToDeleteId]) {
                                    cliToDelete.add(cli);
                                }
        delete cliToDelete;
        
    }

}