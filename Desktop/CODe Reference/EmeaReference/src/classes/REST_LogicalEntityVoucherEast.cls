@RestResource(urlMapping='/getLogicalEntity/Voucher_2/*')
global with sharing class REST_LogicalEntityVoucherEast {

    @HttpPost
    global static REST_LogicalEntity_Voucher getTrials(REST_Request paramInfo)
    {
        
        REST_Request vRequest = paramInfo;
        
        REST_LogicalEntity_Voucher returned = new REST_LogicalEntity_Voucher ();        
        returned.pagetimestamp=vRequest.pagetimestamp;        
        returned.lastItem=vRequest.lastItem;
        returned.mode=vRequest.mode;       
        returned.lastId='';
    
        returned.vouchers=new List<Voucher__c>();
        returned.voucherLineItems=new List<VoucherLineItem__c>();
        SET<ID> VoucherIds = new SET<ID>();
        
        vRequest.pagetimestamp=UtilREST.resetTimestamp(vRequest.pagetimestamp); 

        
        returned.campaigns = [
                SELECT        
                    IsActive,
                    Name,
                    RecordTypeId,
                    StartDate,
                    EndDate,
                    Status,
                    TotalAllocatedBudget__c,
                    TotalAllocatedCharged__c,
                    TotalAllocatedFOC__c,
                    TotalCampaignBudget__c,
                    TotalCampaignBudgetFOC__c,
                    TotalPendingBudget__c,
                  //TotalPendingCharged__c,
                    TotalForecastCharged__c,
                    TotalForecastFOC__c,
                    TotalAgreedCharged__c,
                    TotalPendingForecastBudget__c,
                    CreatedById,
                    YearV2__c,
                    CountryRef__c,
                    DivisionRef__c,
                    CompetitorPCMRef__c,
                    SalesPCMRef__c,
                    LastModifiedDate,
                    ApprovalStatus_RSA__c,
                    OwnerID,
                    DisableForecastStatus__c,
                    DisableAgreedStatus__c,
                    NUM_TotalFOCAllowed__c
                FROM
                    Campaign
                WHERE
                    lastModifiedDate > :vRequest.pagetimestamp
                    AND StatusCode__c=200
                ];
                

     
        for(Voucher__c v: [
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
                VoucherCampaignRef__c,
                DiscountRef__c,
                isTechnicalAgreement__c,
                Reason__c,
                DiscretionaryDiscount__c,
                EarlyOrderDiscount__c,
                PriceWithDiscount__c,
                Price__c,
                LKP_CONTACT__c,
                CHK_MARKETING_AGREED__c,
                TXT_NOTES__c
            FROM Voucher__c
            WHERE LastModifiedDate > :vRequest.pagetimestamp  AND
                  OwnerId=:Util.currentUser.ID AND
                  CampaignRef__c=:UtilREST.activeCampaigns 
                  AND VoucherCampaignRef__r.isActive__c=true
                  AND AccountRef__r.Name!=null
                  AND DistributorRef__r.Name!=null 
                  AND DiscountRef__r.Name!=null        
        ])
        {
            VoucherIds.add(v.ID);
            returned.vouchers.add(v);
        }
        
        for(voucherLineItem__c vli: [
            SELECT 
                Agreed__c, 
                Bags__c, 
                CampaignLineItemRef__c, 
                FAO__c, 
                HybridGroup__c, 
                HybridName__c,
                LastModifiedDate, 
                OwnerId, 
                Price__c, 
                ProductName__c, 
                Id,
                Name, 
                VoucherRef__c,
                PICK_PRODUCTFIELD1__c,
                TXT_PRODUCTFIELD2__c,
                TXT_PRODUCTFIELD3__c,
                TXT_PRODUCTFIELD4__c,
                TXT_PRODUCTFIELD5__c 
            FROM VoucherLineItem__c 
            WHERE (LastModifiedDate > :vRequest.pagetimestamp  OR
                  VoucherRef__c in : VoucherIds) AND
                  OwnerId=:Util.currentUser.ID AND
                  VoucherRef__r.OwnerID=:Util.currentUser.ID
                  AND VoucherRef__r.Name!=null
                  AND PICK_TYPE__c != 'Free of charge'
             ]) 
        {
            returned.voucherLineItems.add(vli);
        }
                            
        returned.calculateTimestamp(vRequest.maxtimestamp);  
         
        return returned;
    }
    
    global class REST_LogicalEntity_Voucher {
        
        public List<VoucherLineItem__c>  voucherLineItems {get;set;}
        public List<Voucher__c> vouchers  {get;set;} 
        public List<Campaign> campaigns {get;set;} 
        
        public DateTime timestamp {get;set;}
        public DateTime pagetimestamp {get;set;}        
        public DateTime maxtimestamp {get;set;}     
        public Boolean queryMore {get;set;}        
        public Integer mode {get;set;}         
        public Integer lastItem {get;set;}  
        public String lastId {get;set;}
        
        public void calculateTimestamp(Datetime reqMaxTimestamp)
        {   
            maxtimestamp=reqMaxTimestamp;         
            
            for(Voucher__c v : vouchers){
                if(maxtimestamp == null || maxtimestamp < v.LastModifiedDate)maxtimestamp = v.LastModifiedDate;
            }
            for(VoucherLineItem__c vli : voucherLineItems){
                if(maxtimestamp == null || maxtimestamp < vli.LastModifiedDate)maxtimestamp = vli.LastModifiedDate;
            }  
            for(Campaign c : campaigns){
                if(maxtimestamp == null || maxtimestamp < c.LastModifiedDate)maxtimestamp = c.LastModifiedDate;
            }
            
            
            timestamp=maxtimestamp;
            queryMore=false;
            pagetimestamp=maxtimestamp;
            mode=0;
            lastItem=0;
            LastId='';              
        }
    }
  
}