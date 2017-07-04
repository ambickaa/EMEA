public with sharing class AccountListOfVouchersController {
    
    public List<Voucher__c> vouchers {get;set;}

    public AccountListOfVouchersController()
    { 
        init();
    }

    private void init()
    {
        /*Query to find the orders to show*/
        vouchers = 
          [
            SELECT 
                AddressCopy__c,             
                CampaignRef__c,
                CancelReason__c, 
                DiscountCopy__c, 
                DistributorRef__c, 
                DistributorNameCopy__c, 
                EmailCopy__c, 
                AccountRef__c, 
                FarmNameCopy__c, 
                FiscalCodeCopy__c, 
                LastModifiedDate, 
                OwnerId, 
                PhoneCopy__c, 
                Id, 
                Signed__c, 
                Status__c, 
                TotalBags__c, 
                TotalBagsFOC__c, 
                Name, 
                idDevice__c, 
                sentMail__c,
                createdDate,
                CreatedBy.Name,
                CampaignRef__r.DivisionRef__r.Name,
               (select ID, name FROM Attachments order by bodylength DESC)  
          FROM Voucher__c 
          WHERE AccountRef__c = :Util.currentAccount.ID  ORDER BY CreatedDate DESC
        ];    
    }                
}