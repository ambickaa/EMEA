public with sharing class Voucher_HU_Corn_2016_Controller {

    public Voucher__c voucher  {get; set;}
    public Contact AccContact {get; set;}
    
    public List<List<String>> VLI_lines_Charged {get; set;}
    public List<List<String>> VLI_lines_FOC {get; set;}

    public Integer status{get; set;}
    
    public String VoucherDate {get; set;}
    public String ContactName {get; set;}
    public String DistAddress {get; set;}
    
    public Map<String, Decimal> Map_Discounts = new Map<String, Integer>();
    
    public ApexPages.StandardController controller; 
      
    public Voucher_HU_Corn_2016_Controller (ApexPages.StandardController controller) {
    
    this.controller = controller;
    Id VoucherID = controller.getRecord().Id;
    VoucherDate = '';
    ContactName = '';
    DistAddress = '';
    status = 0; // Status = 1 for cancelled Vouchers
        
    voucher = new Voucher__c();
    AccContact = new Contact();
        
    VLI_lines_FOC = new List<List<String>>();
    VLI_lines_Charged = new List<List<String>>();
    
    if(VoucherID != null) {
        voucher = [SELECT Id,Name,FarmNameCopy__c,AddressCopy__c,PhoneCopy__c,EmailCopy__c,DistributorNameCopy__c,LastModifiedDate, Price_Coupon__c, VoucherCampaignRef__c,
                 AccountRef__r.Client_Code__c,AccountRef__r.City__c, AccountRef__r.StateProvince__c,AccountRef__r.County__c,Status__c,Owner.Name, DiscretionaryDiscount__c,
                 LKP_CONTACT__c, LKP_CONTACT__r.Name,VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c,TotalBags__c,TotalBagsFOC__c,
                 AccountRef__r.CornTotalAcreagesCY__c, AccountRef__r.OSRTotalAcreagesCY__c, TXT_NOTES__c,AccountRef__r.FiscalCode__c,FiscalCodeCopy__c,AccountRef__r.GC_VATIN_Number__c, DistributorRef__c,
                 AccountRef__r.GC_Bank_Account_Number__c, AccountRef__r.Owner.Name, DistributorRef__r.Street__c, DistributorRef__r.City__c, DistributorRef__r.ZIPPostalCode__c
                 FROM Voucher__c WHERE Id=:VoucherID];
            
        // If some contact has been selected in the Voucher
        if(voucher.LKP_CONTACT__c != null) {
          try {
                 AccContact = [SELECT Id, Name, MobilePhone, Phone, Title, Position_picklist__c
                 FROM Contact
                 WHERE Id =: voucher.LKP_CONTACT__c];
          } catch ( Exception e ) {System.debug(e);}
        }
        
        // Address for Distributor
        if(voucher.DistributorRef__c != null) {
            List<String> List_DistAddress = new List<String>();
            
            List_DistAddress.add(voucher.DistributorRef__r.City__c);
            List_DistAddress.add(voucher.DistributorRef__r.Street__c);
            List_DistAddress.add(voucher.DistributorRef__r.ZIPPostalCode__c);
            for(String s : List_DistAddress) {
                if(s != null && DistAddress == '')
                    DistAddress += s;
                else if (s != null && DistAddress != '')
                    DistAddress += ', ' + s;
            }
        }

        // Treatment for voucher details
        VoucherDate = voucher.LastModifiedDate.format('yyyy/MM/dd');
        status = voucher.status__c == 'Cancelled' ? 1 : 0;         

        // Treatment for sales lines introduced
        Map<String, VoucherLineItem__c> VLI_Charged = new Map<String, VoucherLineItem__c>();
        Map<String, VoucherLineItem__c> VLI_FOC = new Map<String, VoucherLineItem__c>();
                       
        for(VoucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, CampaignLineItemRef__c, LKP_ProductCatalogEntry__c, LKP_ProductCatalogEntry__r.TXT_FAO__c,
                            HybridGroup__c, HybridName__c, PICK_TYPE__c, Price__c, ProductName__c, LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c,
                            LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.DE_isPremium__c
                            FROM VoucherLineItem__c WHERE VoucherRef__c =: VoucherID ORDER BY HybridName__c ASC]) {
            
            if(vli.PICK_TYPE__c == 'Charged') {
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
            
        for(String PN : VLI_Charged.keyset()) {                
            String str0 = VLI_Charged.get(PN).HybridName__c != null ? VLI_Charged.get(PN).HybridName__c : '';
            String str1 = VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c != null ? VLI_Charged.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c : '';
            String str2 = VLI_Charged.get(PN).Bags__c != null ? VLI_Charged.get(PN).Bags__c.toPlainString() : '';
              
            List<String> VLI_list_Charged = new List<String>{str0, str1, str2};
            VLI_lines_Charged.add(VLI_list_Charged);
        }
            
        system.debug('***' + VLI_lines_Charged);
        
        for(String PN : VLI_FOC.keyset()) {
            String str0 = VLI_FOC.get(PN).HybridName__c != null ? VLI_FOC.get(PN).HybridName__c : '';
            String str1 = VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c != null ? VLI_FOC.get(PN).LKP_ProductCatalogEntry__r.ProductRef__r.ProductTreatment__c : '';
            String str2 = VLI_FOC.get(PN).Bags__c!= null ? VLI_FOC.get(PN).Bags__c.toPlainString() : '';
            
            List<String> VLI_list_FOC = new List<String>{str0, str1, str2};
            VLI_lines_FOC.add(VLI_list_FOC);
        }
        
        system.debug('***' + VLI_lines_FOC);
     }
   }
}