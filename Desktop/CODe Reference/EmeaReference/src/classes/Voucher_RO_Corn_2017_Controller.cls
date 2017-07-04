public with sharing class Voucher_RO_Corn_2017_Controller {

    public ApexPages.StandardController controller;
    
    public Voucher__c voucher {get; set;}
    public String voucherDate {get; set;}
    public String voucherPhone {get; set;}
    public String voucherStatus {get; set;}
    public Boolean voucherSecondStage {get; set;}
    public Boolean oldPrices {get; set;}
    public Map<String, Decimal> q {get; set;}
    
    public List<String> ListGroups {get; set;}
    
    public Map<String, List<VoucherLineItem__c>> MapLines {get; set;}

    public Voucher_RO_Corn_2017_Controller(ApexPages.StandardController controller)
    {
        this.controller = controller;
        q = new Map<String, Decimal>();
        voucher = new Voucher__c();
        Contact c = new Contact();
        
        oldPrices = false;
        ListGroups = new List<String>{'PREMIUM', 'TOP', 'PROGRES', 'CLASIC', 'RETAIL'};
        
        MapLines = new Map<String, List<VoucherLineItem__c>>();
        
        MapLines.put('PREMIUM', new List<VoucherLineItem__c>());
        MapLines.put('TOP', new List<VoucherLineItem__c>());
        MapLines.put('PROGRES', new List<VoucherLineItem__c>());
        MapLines.put('CLASIC', new List<VoucherLineItem__c>());
        MapLines.put('RETAIL', new List<VoucherLineItem__c>());
        
        voucherSecondStage = false;
            
        Id voucherId = controller.getRecord().Id;
        
        for(ProductCatalogEntry__c pce : [SELECT Id, ProductRef__r.TXT_Hybrid__c FROM ProductCatalogEntry__c
        WHERE ProductCatalogRef__r.Name = 'Romania - Corn - Sales - 2017'
        AND Vendor__c LIKE 'Monsanto %' ORDER BY ProductRef__r.TXT_Hybrid__c ASC])
        {
            q.put(pce.ProductRef__r.TXT_Hybrid__c, 0);
        }
        system.debug(q);
        
        if(voucherId != null)
        {
            voucher = [SELECT AddressCopy__c, DistributorNameCopy__c, EmailCopy__c, PhoneCopy__c, FarmNameCopy__c, FiscalCodeCopy__c, AccountRef__c, AccountRef__r.County__c,
                Owner.Name, LastModifiedDate, CreatedDate, Status__c, LKP_CONTACT__c, LKP_CONTACT__r.Name, Name, TotalBags__c, TotalBagsFOC__c, TXT_NOTES__c,
                VoucherCampaignRef__c, VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name, Price_Coupon__c
                FROM Voucher__c WHERE Id =: voucherId];

            voucherDate = voucher.CreatedDate.format('dd/MM/yyyy');
            voucherStatus = voucher.status__c;
            
            Id voucherCampaignId = voucher.VoucherCampaignRef__c;
            
            Discount__c newDiscount = new Discount__c();
            
            for(Discount__c d : [SELECT Id, DATE_Start_Date__c
                FROM Discount__c
                WHERE VoucherCampaignRef__c = :voucherCampaignId
                AND RecordType.Name = 'Smart Discount'
                ORDER BY DATE_Start_Date__c DESC LIMIT 1])
            {
                newDiscount = d;
            }
            
            for(Voucher__c v : [SELECT Id, CreatedDate FROM Voucher__c
                                WHERE AccountRef__c = : voucher.AccountRef__c
                                AND VoucherCampaignRef__c = : voucher.voucherCampaignRef__c
                                AND Status__c = 'Cancelled'])
            {
                if(v.CreatedDate >= newDiscount.DATE_Start_Date__c) oldPrices = false;
                else oldPrices = true;
            }
            
            if(voucher.CreatedDate > newDiscount.DATE_Start_Date__c && !oldPrices)
                voucherSecondStage = true;

            if(voucher.AccountRef__c != null)
            {
                try
                {
                    c = [SELECT Id, Name, MobilePhone, Phone, DE_MonsantoID__c, Decision_Maker__c
                        FROM Contact
                        WHERE AccountId =: voucher.AccountRef__c
                        ORDER BY Decision_Maker__c DESC LIMIT 1];
                } catch( Exception e ) {
                    System.debug(e);
                }
            }

            if(c.MobilePhone != null && voucher.PhoneCopy__c != null)
                voucherPhone = c.MobilePhone + ' / ' + voucher.PhoneCopy__c;

            if(c.MobilePhone != null && voucher.PhoneCopy__c == null)
                voucherPhone = c.MobilePhone;

            if(c.MobilePhone == null && voucher.PhoneCopy__c != null)
                voucherPhone = voucher.PhoneCopy__c;

            if(c.MobilePhone == null && voucher.PhoneCopy__c == null)
                voucherPhone = '';
            
            for(VoucherLineItem__c vli : [SELECT Id, HybridName__c, LKP_ProductCatalogEntry__r.ProductRef__c, LKP_ProductCatalogEntry__r.ProductRef__r.ProductHybridGroup__c,
                LKP_ProductCatalogEntry__r.TXT_FAO__c, LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c, Bags__c, Price__c, NUM_Price_Discount__c,
                LKP_ProductCatalogEntry__r.Price__c, LKP_ProductCatalogEntry__r.PriceOld__c
                FROM VoucherLineItem__c
                WHERE VoucherRef__c = : voucherId
                AND PICK_TYPE__c != 'Free of charge'
                ORDER BY HybridName__c ASC])
            {
                String hGroup_vli = vli.LKP_ProductCatalogEntry__r.ProductRef__r.ProductHybridGroup__c;
                String hGroup = '';
                
                if(hGroup_vli != null && hGroup_vli.contains('PREMIUM')) hGroup = 'PREMIUM';
                if(hGroup_vli != null && hGroup_vli.contains('TOP')) hGroup = 'TOP';
                if(hGroup_vli != null && hGroup_vli.contains('PROGRES')) hGroup = 'PROGRES';
                if(hGroup_vli != null && hGroup_vli.contains('CLASIC')) hGroup = 'CLASIC';
                if(hGroup_vli != null && hGroup_vli.contains('RETAIL')) hGroup = 'RETAIL';
                
                if((hGroup == 'PREMIUM' || hGroup == 'TOP') && oldPrices)
                {
                    vli.Price__c = vli.LKP_ProductCatalogEntry__r.PriceOld__c;
                } else {
                	vli.Price__c = vli.LKP_ProductCatalogEntry__r.Price__c;
                }
                
                MapLines.get(hGroup).add(vli);
            }
        }
    }
}