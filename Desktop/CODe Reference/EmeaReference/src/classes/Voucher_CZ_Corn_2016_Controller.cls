public with sharing class Voucher_CZ_Corn_2016_Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}
    
    public List<List<String>> VLI_lines_Charged {get;set;}
    public List<List<String>> VLI_lines_FOC {get;set;}

    public Integer status{get;set;}
    
    public String VoucherDate {get;set;}
    
    public Integer AcrGrain {get;set;}
    public Integer AcrSilage {get;set;}
    
    private Decimal TotalBags_Silage = 0;
    private Decimal TotalBags_Grain = 0;
    
    public Map<String, Decimal> Map_Discounts = new Map<String, Integer>();
    
    public ApexPages.StandardController controller; 
      
    public Voucher_CZ_Corn_2016_Controller (ApexPages.StandardController controller) {
        this.controller = controller;
        Id VoucherID = controller.getRecord().Id;
        VoucherDate = '';
        status = 0; // Status = 1 for cancelled Vouchers
        
        AcrGrain = 0;
        AcrSilage = 0;
        
        voucher = new Voucher__c();
        AccContact = new Contact();
        
        VLI_lines_FOC = new List<List<String>>();
        VLI_lines_Charged = new List<List<String>>();
    
        if(VoucherID != null) {
            voucher = [SELECT Id,Name,FarmNameCopy__c,AddressCopy__c,PhoneCopy__c,EmailCopy__c,DistributorNameCopy__c,LastModifiedDate, Price_Coupon__c, VoucherCampaignRef__c,
                     AccountRef__r.Client_Code__c,AccountRef__r.City__c, AccountRef__r.StateProvince__c,AccountRef__r.County__c,Status__c,Owner.Name, DiscretionaryDiscount__c,
                     LKP_CONTACT__c, LKP_CONTACT__r.Name,VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c,TotalBags__c,TotalBagsFOC__c,
                     AccountRef__r.CornTotalAcreagesCY__c,TXT_NOTES__c,AccountRef__r.FiscalCode__c,FiscalCodeCopy__c,AccountRef__r.GC_VATIN_Number__c,
                     AccountRef__r.CornTotalSalesPY__c, AccountRef__r.GC_Bank_Account_Number__c, AccountRef__r.DE_POGCornPY__c, AccountRef__r.DE_POGCornFOCPY__c,                     
                     AccountRef__r.TotalAcreagesCY__c, AccountRef__r.Owner.Name FROM Voucher__c WHERE Id=:VoucherID];
            
            // If some contact has been selected in the Voucher
            if(voucher.LKP_CONTACT__c != null) {
              try {
                     AccContact = [SELECT Id, Name, MobilePhone, Phone, Title, Position_picklist__c
                     FROM Contact
                     WHERE Id =: voucher.LKP_CONTACT__c];
              } catch ( Exception e ) {System.debug(e);}
            }
            
            // Splitting acreages in Grain and Silage
            if(voucher.AccountRef__c != null) {
              if(voucher.AccountRef__r.TotalAcreagesCY__c > 0) {
                 AggregateResult[] acr = [SELECT SUM(Total_Acreages_Grain_Cron__c)grain, SUM(Total_Silage_Corn__c)silage
                                     FROM Acreage__c
                                     WHERE AcrFarmRef__c = : voucher.AccountRef__c
                                     AND AcrYearRef__c =: voucher.VoucherCampaignRef__r.YearRef__c];
                 
                   AcrGrain = acr[0].get('grain') != null ? Integer.valueOf((Decimal)acr[0].get('grain')) : AcrGrain;
                   AcrSilage = acr[0].get('silage') != null ? Integer.valueOf((Decimal)acr[0].get('silage')) : AcrSilage;
              }
            }

            // Treatment for voucher details
            VoucherDate = voucher.LastModifiedDate.format('dd/MM/yyyy');
            status = voucher.status__c == 'Cancelled' ? 1 : 0;

            // Treatment for sales lines introduced
            Map<String, VoucherLineItem__c> VLI_Charged = new Map<String, VoucherLineItem__c>();
            Map<String, VoucherLineItem__c> VLI_FOC = new Map<String, VoucherLineItem__c>();
                       
            for(VoucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, CampaignLineItemRef__c, LKP_ProductCatalogEntry__c, LKP_ProductCatalogEntry__r.TXT_FAO__c,
                                HybridGroup__c, HybridName__c, PICK_TYPE__c, Price__c, ProductName__c, LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c,
                                LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.DE_isPremium__c
                                FROM VoucherLineItem__c WHERE VoucherRef__c =: VoucherID ORDER BY HybridName__c ASC]) {
                
                if(vli.PICK_TYPE__c == 'Charged') {
                
                    if(vli.LKP_ProductCatalogEntry__r.DE_isPremium__c) TotalBags_Silage = TotalBags_Silage + vli.Bags__c;
                    else TotalBags_Grain = TotalBags_Grain + vli.Bags__c;
                
                    // If the product has already been included it means there is more than one VLI for the same product in this voucher. In this case it's necessary to sum the bags indicated in all VLIs
                    if(VLI_Charged.get(vli.ProductName__c) != null)
                      vli.Bags__c = vli.Bags__c + VLI_Charged.get(vli.ProductName__c).Bags__c;
                    
                    VLI_Charged.put(vli.ProductName__c,vli);

                }
                
                if(vli.PICK_TYPE__c == 'Free of charge') {
                    // If the product has already been included it means there is more than one VLI for the same product in this voucher. In this case it's necessary to sum the bags indicated in all VLIs
                    if(VLI_FOC.get(vli.ProductName__c) != null)
                      vli.Bags__c = vli.Bags__c + VLI_FOC.get(vli.ProductName__c).Bags__c;
                    
                    VLI_FOC.put(vli.ProductName__c,vli);
                }
            }
            
            for(Discount__c d : [SELECT Id, PICK_Applies_to__c,
                                PercentIncreaseInPrice__c,
                                MaxBags__c, MinBags__c
                                FROM Discount__c
                                WHERE VoucherCampaignRef__c = : voucher.VoucherCampaignRef__c
                                AND RecordTypeId = : Util.recordType.get('Discount__c:Smart_discount')]) {
              
              Boolean setDiscount = false;
                
              if(d.PICK_Applies_to__c == 'Premium') {
                if(d.MaxBags__c != null)
                    setDiscount = (TotalBags_Silage >= d.MinBags__c && TotalBags_Silage <= d.MaxBags__c) ? true : false;
                else
                    setDiscount = (TotalBags_Silage >= d.MinBags__c) ? true : false;
              }
              if(d.PICK_Applies_to__c == 'Classic') {
                if(d.MaxBags__c != null)
                    setDiscount = (TotalBags_Grain >= d.MinBags__c && TotalBags_Grain <= d.MaxBags__c) ? true : false;
                else
                    setDiscount = (TotalBags_Grain >= d.MinBags__c) ? true : false;
              }
              
              if(setDiscount)
                  Map_Discounts.put(d.PICK_Applies_to__c, (Integer)d.PercentIncreaseInPrice__c.round());
            }
            
            for(String PN : VLI_Charged.keyset()) {                
                String str0 = VLI_Charged.get(PN).HybridName__c != null ? VLI_Charged.get(PN).HybridName__c : '';
                String str1 = VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c != null ? VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c : '';
                String str2 = VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.TXT_FAO__c != null ? VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.TXT_FAO__c : '';
                String str3 = VLI_Charged.get(PN).Bags__c != null ? VLI_Charged.get(PN).Bags__c.toPlainString() : '';
                String str4 = VLI_Charged.get(PN).Price__c != null ? String.valueOf((Integer)VLI_Charged.get(PN).Price__c) : '';
                
                String str5 = '';
                Integer int5 = 0;
                if(VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.DE_isPremium__c) {
                    str5 = Map_Discounts.get('Premium') != null ? Map_Discounts.get('Premium').toPlainString() : '';
                    if(str5 != '') int5 = (Integer)Map_Discounts.get('Premium').round();
                } else {
                    str5 = Map_Discounts.get('Classic') != null ? Map_Discounts.get('Classic').toPlainString() : '';
                    if(str5 != '') int5 = (Integer)Map_Discounts.get('Classic').round();
                }
                String str6 = voucher.DiscretionaryDiscount__c != null ? voucher.DiscretionaryDiscount__c.toPlainString() : '';
                
                Decimal int7 = (((int5 + voucher.DiscretionaryDiscount__c)/100.0) * VLI_Charged.get(PN).Bags__c * VLI_Charged.get(PN).Price__c).setScale(2);
                String str7 = int7.toPlainString();
                
                if(VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.NewProduct__c)
                  str0 += '<span class="new-pce">Novinka</span>';
                  
                List<String> VLI_list_Charged = new List<String>{str0, str1, str2, str3, str4, str5, str6, str7};
                VLI_lines_Charged.add(VLI_list_Charged);
            }
            
            system.debug('***' + VLI_lines_Charged);
            
            for(String PN : VLI_FOC.keyset()) {
                String str0 = VLI_FOC.get(PN).HybridName__c != null ? VLI_FOC.get(PN).HybridName__c : '';
                String str1 = VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c != null ? VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c : '';
                String str2 = VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.TXT_FAO__c != null ? VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.TXT_FAO__c : '';
                String str3 = VLI_FOC.get(PN).Bags__c!= null ? VLI_FOC.get(PN).Bags__c.toPlainString() : '';
                
                if(VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.NewProduct__c == true)
                  str0 += '<span class="new-pce">Novinka</span>';
                
                List<String> VLI_list_FOC = new List<String>{str0, str1, str2, str3};
                VLI_lines_FOC.add(VLI_list_FOC);
            }
            
            system.debug('***' + VLI_lines_FOC);
        }
    }
}