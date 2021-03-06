public with sharing class Voucher_CZ_OSR_2017_Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}
    
    public List<List<String>> VLI_lines_Charged {get;set;}
    public List<List<String>> VLI_lines_FOC {get;set;}

    public Integer status{get;set;}
    
    public String VoucherDate {get;set;}
    
    public Integer acreage {get;set;}
    public Decimal TotalDiscount {get;set;}

    
    private Decimal TotalBags_Silage = 0;
    private Decimal TotalBags_Grain = 0;
    
    public Map<String, Decimal> Map_Discounts = new Map<String, Integer>();
    
    public ApexPages.StandardController controller; 
      
    public Voucher_CZ_OSR_2017_Controller (ApexPages.StandardController controller) {
        this.controller = controller;
        Id VoucherID = controller.getRecord().Id;
        VoucherDate = '';
        status = 0; // Status = 1 for cancelled Vouchers
        
        acreage = 0;
        TotalDiscount = 0;
        voucher = new Voucher__c();
        AccContact = new Contact();
        
        VLI_lines_FOC = new List<List<String>>();
        VLI_lines_Charged = new List<List<String>>();
    
        if(VoucherID != null) { 
            voucher = [SELECT Id,Name,FarmNameCopy__c,AddressCopy__c,PhoneCopy__c,EmailCopy__c,DistributorNameCopy__c,LastModifiedDate, Price_Coupon__c, VoucherCampaignRef__c,
                     AccountRef__r.Client_Code__c,AccountRef__r.City__c, Price__c, PriceWithDiscount__c, AccountRef__r.StateProvince__c,AccountRef__r.County__c,Status__c,Owner.Name, DiscretionaryDiscount__c,
                     LKP_CONTACT__c, LKP_CONTACT__r.Name,VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c,FRML_DISCOUNT_AMOUNT__c,TotalBags__c,TotalBagsFOC__c,
                     AccountRef__r.CornTotalAcreagesCY__c,TXT_NOTES__c,AccountRef__r.FiscalCode__c,FiscalCodeCopy__c,AccountRef__r.GC_VATIN_Number__c,
                     AccountRef__r.CornTotalSalesPY__c, AccountRef__r.GC_Bank_Account_Number__c, AccountRef__r.DE_POGOSRPY__c, AccountRef__r.DE_POGOSRFOCPY__c,                     
                     AccountRef__r.TotalAcreagesCY__c, AccountRef__r.Owner.Name FROM Voucher__c WHERE Id=:VoucherID];
            
            // If some contact has been selected in the Voucher
            if(voucher.LKP_CONTACT__c != null) {
              try {
                     AccContact = [SELECT Id, Name, MobilePhone, Phone, Title, Position_picklist__c
                     FROM Contact
                     WHERE Id =: voucher.LKP_CONTACT__c];
              } catch ( Exception e ) {System.debug(e);}
            }
            
            // Calculate OSR Total Acreages for the Farm
            if(voucher.AccountRef__c != null) {
              if(voucher.AccountRef__r.TotalAcreagesCY__c > 0) {
                 AggregateResult[] acr = [SELECT SUM(FRML_TOTAL_OSR_ACREAGES__c)acreage
                                     FROM Acreage__c
                                     WHERE AcrFarmRef__c = : voucher.AccountRef__c
                                     AND AcrYearRef__c =: voucher.VoucherCampaignRef__r.YearRef__c];
                 
                   acreage = acr[0].get('acreage') != null ? Integer.valueOf((Decimal)acr[0].get('acreage')) : acreage;
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
                // CHARGED VLI //
                if(vli.PICK_TYPE__c == 'Charged') {
                
                    if(vli.LKP_ProductCatalogEntry__r.DE_isPremium__c) TotalBags_Silage = TotalBags_Silage + vli.Bags__c;
                    else TotalBags_Grain = TotalBags_Grain + vli.Bags__c;
                
                    // If the product has already been included it means there is more than one VLI for the same product in this voucher. In this case it's necessary to sum the bags indicated in all VLIs
                    if(VLI_Charged.get(vli.ProductName__c) != null)
                      vli.Bags__c = vli.Bags__c + VLI_Charged.get(vli.ProductName__c).Bags__c;
                    
                    VLI_Charged.put(vli.ProductName__c,vli);

                }
                // FOC VLI //
                if(vli.PICK_TYPE__c == 'Free of charge') {
                    // If the product has already been included it means there is more than one VLI for the same product in this voucher. In this case it's necessary to sum the bags indicated in all VLIs
                    if(VLI_FOC.get(vli.ProductName__c) != null)
                      vli.Bags__c = vli.Bags__c + VLI_FOC.get(vli.ProductName__c).Bags__c;
                    
                    VLI_FOC.put(vli.ProductName__c,vli);
                }
            } // end for //
            
            
            // CHARGED //
            // PN = productName //
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
                TotalDiscount += int7;
                String str7 = int7.toPlainString();
                
               // if(VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.NewProduct__c)
               //   str0 += '<span class="new-pce">Novinka</span>';
                  
                List<String> VLI_list_Charged = new List<String>{str0, str1, str2, str3, str4, str5, str6, str7};
                VLI_lines_Charged.add(VLI_list_Charged);
            }
            
            system.debug('***' + VLI_lines_Charged);
            
            // FOC //
            for(String PN : VLI_FOC.keyset()) {
                String str0 = VLI_FOC.get(PN).HybridName__c != null ? VLI_FOC.get(PN).HybridName__c : '';
                String str1 = VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c != null ? VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c : '';
                String str2 = VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.TXT_FAO__c != null ? VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.TXT_FAO__c : '';
                String str3 = VLI_FOC.get(PN).Bags__c!= null ? VLI_FOC.get(PN).Bags__c.toPlainString() : '';
                
            //    if(VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.NewProduct__c == true)
             //     str0 += '<span class="new-pce">Novinka</span>';
                
                // add condition standard treatment?
                List<String> VLI_list_FOC = new List<String>{str0, str1, str2, str3};
                VLI_lines_FOC.add(VLI_list_FOC);
            }
            
            system.debug('***' + VLI_lines_FOC);
        }
    }
}