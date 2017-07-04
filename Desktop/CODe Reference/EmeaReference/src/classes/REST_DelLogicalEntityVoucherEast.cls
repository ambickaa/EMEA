@RestResource(urlMapping='/getDeletedLogicalEntity/Voucher/*')
global with sharing class REST_DelLogicalEntityVoucherEast {

    @HttpPost
    global static REST_DelLogicalEntity_Voucher getDeletedVouchers(REST_DelLogicalEntity_Voucher paramInfo)
    {
        REST_DelLogicalEntity_Voucher returned = new REST_DelLogicalEntity_Voucher();
        
        returned.vouchers = new List<Voucher__c>();
        returned.voucherLineItems = new List<VoucherLineItem__c>();      
		
        Map<ID,VoucherLineItem__c> paramInfoVoucherLineItems = new Map<ID,VoucherLineItem__c>(paramInfo.voucherLineItems);
        Set<ID> paramInfoVoucherLineItemsIDs = paramInfoVoucherLineItems.keySet();
        
        List<VoucherLineItem__c> currentVoucherLineItems = new List<VoucherLineItem__c>();
        
        Set<Id> currentVoucherLineItemsIDs = new Set<Id>();
        Set<ID> currentVouchersIDs = new Set<Id>();
        
        Map<ID,Voucher__c> paramInfoVouchers = new Map<ID,Voucher__c>(paramInfo.vouchers);
        
        Set<ID> paramInfoVouchersIDs = paramInfoVouchers.keySet();
        
        for(VoucherLineItem__c vli: [
         SELECT ID, VoucherRef__c FROM VoucherLineItem__c 
         WHERE /*ID IN :paramInfoVoucherLineItemsIDs AND*/VoucherRef__r.VoucherCampaignRef__r.isActive__c=true AND
          VoucherRef__r.CampaignRef__c in:UtilREST.activeCampaigns AND VoucherRef__r.Name!=null
           AND VoucherRef__r.AccountRef__r.Name!=null
           AND VoucherRef__r.DistributorRef__r.Name!=null 
           AND VoucherRef__r.DiscountRef__r.Name!=null      
           AND OwnerId=:Util.currentUser.ID AND VoucherRef__r.OwnerId=:Util.currentUser.ID] 
        )
        {
        	currentVouchersIDs.add(vli.VoucherRef__c);
        	currentVoucherLineItemsIDs.add(vli.id);
        }
        
        //
        paramInfoVoucherLineItemsIDs.removeAll(currentVoucherLineItemsIDs);
        for(ID i : paramInfoVoucherLineItemsIDs){
            returned.voucherLineItems.add(paramInfoVoucherLineItems.get(i));
        }
        
        paramInfoVouchersIDs.removeAll(currentVouchersIDs);
        for(ID i : paramInfoVouchersIDs){
            returned.vouchers.add(paramInfoVouchers.get(i));
        }        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Voucher getExample()
    {
        REST_DelLogicalEntity_Voucher returned = new REST_DelLogicalEntity_Voucher();
        
        returned.vouchers = [SELECT ID FROM Voucher__c WHERE OwnerID=:Util.currentUser.ID LIMIT 2];
        returned.voucherLineItems = [SELECT ID FROM VoucherLineItem__c WHERE OwnerID=:Util.currentUser.ID LIMIT 2];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Voucher
    {
        public List<Voucher__C> vouchers;
        public List<VoucherLineItem__c> voucherLineItems;
    }
    
    
}