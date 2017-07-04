public with sharing class Voucher_PL_Corn_2017_Controller {

    public ApexPages.StandardController controller;
    public Voucher__c voucher {get; set;}
    public Boolean isVATPayer {get; set;}
    public String voucherStatus {get; set;}
    public String voucherDate {get; set;}
    public String farmAddress {get; set;}

    public Map<String, VoucherLineItem__c> MAP_VLI {get;set;}
    public Map<String, VoucherLineItem__c> MAP_VLI_PREMIUM {get;set;}

    public List<VoucherLineitem__c> List_Premium_1{get;set;}
    public List<VoucherLineitem__c> List_Premium_2{get;set;}
    public List<VoucherLineitem__c> List_NOTPremium_1{get;set;}
    public List<VoucherLineitem__c> List_NOTPremium_2{get;set;}
    public List<VoucherLineitem__c> List_NOTPremium_3{get;set;}

    public Voucher_PL_Corn_2017_Controller (ApexPages.StandardController controller) {
        this.controller = controller;
        Id voucherId = controller.getRecord().Id;
        voucherStatus = '';
        voucherDate = '';
        farmAddress = '';
        if(voucherId!=null)
        {
            voucher = new Voucher__c();
            voucher = [SELECT Name, Owner.Name, CreatedDate, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c,
            			FiscalCodeCopy__c, AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LKP_CONTACT__r.Name, LastModifiedDate,
                        AccountRef__r.Client_Code__c,
                        AccountRef__r.DE_Territory_Key__r.DE_CP__c,
                        AccountRef__r.DE_Territory_Key__r.DE_Ort__c,
                        AccountRef__r.DE_Territory_Key__r.DE_Landkreis2__c,
                        AccountRef__r.Street__c,
                        AccountRef__r.DE_PLZ__c,
                        AccountRef__r.City__c,
                        AccountRef__r.StateProvince__c,
                        AccountRef__r.ZIPPostalCode__c,
                        AccountRef__r.Phone,
                        AccountRef__r.Name,
                        AccountRef__r.County__c,
                        AccountRef__r.FiscalCode__c,
                        AccountRef__r.TXT_BANK_ADDRESS__c,
                        AccountRef__r.TXT_TAX_OFFICE_NAME__c,
                        AccountRef__r.FCPArelevant__c,
                        AccountRef__r.CHK_VAT_Payer__c,
                        AccountRef__r.GC_Bank_Account_Number__c,
                        AccountRef__r.GC_Bank_Name__c,
                        AccountRef__r.GC_VATIN_Number__c, // AccountRef__r.DE_TEMP_BANK_SWIFT__c,
                        VoucherCampaignRef__r.DivisionRef__c,
                        VoucherCampaignRef__r.YearRef__c,
                        Price_Coupon__c
                        FROM Voucher__c
                        WHERE Id=:voucherId];

            voucherStatus = voucher.status__c;
            voucherDate = voucher.LastModifiedDate.format('dd/MM/yyyy');
            isVATPayer = voucher.AccountRef__r.CHK_VAT_Payer__c;

            MAP_VLI_PREMIUM = new Map<String, VoucherLineitem__c>();
            MAP_VLI = new Map<String, VoucherLineitem__c>();
            Integer BAGS = 0;
            
            farmAddress += voucher.AccountRef__r.Street__c;
            
            if(voucher.AccountRef__r.DE_Territory_Key__c != null)
            {
            	if(voucher.AccountRef__r.DE_Territory_Key__r.DE_Ort__c != '')
            		farmAddress += farmAddress != '' ? ', ' + voucher.AccountRef__r.DE_Territory_Key__r.DE_Ort__c : voucher.AccountRef__r.DE_Territory_Key__r.DE_Ort__c;
            	if(voucher.AccountRef__r.DE_Territory_Key__r.DE_Landkreis2__c != '')
            		farmAddress += farmAddress != '' ? ', ' + voucher.AccountRef__r.DE_Territory_Key__r.DE_Landkreis2__c : voucher.AccountRef__r.DE_Territory_Key__r.DE_Landkreis2__c;
            } else {
            	if(voucher.AccountRef__r.City__c != '')
            		farmAddress += farmAddress != '' ? ', ' + voucher.AccountRef__r.City__c : voucher.AccountRef__r.City__c;
            	if(voucher.AccountRef__r.County__c != '')
            		farmAddress += farmAddress != '' ? ', ' + voucher.AccountRef__r.County__c : voucher.AccountRef__r.County__c;
            }

            for(VoucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, ProductName__c, HybridName__c, HybridGroup__c, FAO__c, PICK_TYPE__c, 
                                          LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.TXT_FAO__c,
                                          CreatedDate, LastModifiedDate, OwnerId, Owner.Name, LKP_ProductCatalogEntry__r.DE_isPremium__c
                                          FROM VoucherLineItem__c
                                          WHERE VoucherRef__c=:voucherId
                                          AND PICK_TYPE__c = 'Charged' ORDER BY HybridName__c ASC])
            {
                // Premium products //
                if(MAP_VLI_PREMIUM.containsKey(vli.HybridName__c) && (vli.LKP_ProductCatalogEntry__r.DE_isPremium__c == true))
                {
                    BAGS = MAP_VLI_PREMIUM.get(vli.HybridName__c).Bags__c.intValue() + vli.Bags__c.intValue();
                    vli.Bags__c = BAGS;
                    MAP_VLI_PREMIUM.remove(vli.HybridName__c);
                }
                // Not Premium products //
                if(MAP_VLI.containsKey(vli.HybridName__c) && (vli.LKP_ProductCatalogEntry__r.DE_isPremium__c == false))
                {
                    BAGS = MAP_VLI.get(vli.HybridName__c).Bags__c.intValue() + vli.Bags__c.intValue();
                    vli.Bags__c = BAGS;
                    MAP_VLI.remove(vli.HybridName__c);
                }

                if(vli.LKP_ProductCatalogEntry__r.DE_isPremium__c == true) {
                    MAP_VLI_PREMIUM.put(vli.HybridName__c,vli);
                } else {
                    MAP_VLI.put(vli.HybridName__c,vli);
                }
            }

            Integer i = 0;
            List_Premium_1 = new List<VoucherLineitem__c>();
            List_Premium_2 = new List<VoucherLineitem__c>();

            for(VoucherLineItem__c vli : Map_VLI_PREMIUM.values())
            {
              i++;
              
              if(i <= 2) List_Premium_1.add(vli);
              else List_Premium_2.add(vli);
            }

            Integer j = 0;
            List_NOTPremium_1 = new List<VoucherLineitem__c>();
            List_NOTPremium_2 = new List<VoucherLineitem__c>();
            List_NOTPremium_3 = new List<VoucherLineitem__c>();

            for(VoucherLineItem__c vli : Map_VLI.values())
            {
              j++;
              if(j <= 4) List_NOTPremium_1.add(vli);
              else if(j > 4 && j <= 10) List_NOTPremium_2.add(vli);
              else List_NOTPremium_3.add(vli);
            }

        }
    }
}