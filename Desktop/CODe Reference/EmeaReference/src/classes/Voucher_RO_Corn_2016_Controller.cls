public with sharing class Voucher_RO_Corn_2016_Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}

    public Map<String, Decimal> Map_Discounts = new Map<String, Integer>();

    public ApexPages.StandardController controller;

    public Integer status{get;set;}
    
    public List<String> HYB_NAME_NOUHD{get;set;}
    public List<Integer> HYB_PRICE_NOUHD{get;set;}
    public List<String> HYB_FAO1_NOUHD{get;set;}
    public List<Integer> HYB_BAGS_NOUHD{get;set;}
    public Integer HYB_NUM_NOUHD{get;set;}
    public List<Integer> HYB_SIZE_NOUHD{get;set;}
    public List<Integer> HYB_DISC_NOUHD{get;set;}

    public List<String> HYB_NAME_NOU{get;set;}
    public List<Integer> HYB_PRICE_NOU{get;set;}
    public List<String> HYB_FAO1_NOU{get;set;}
    public List<Integer> HYB_BAGS_NOU{get;set;}
    public Integer HYB_NUM_NOU{get;set;}
    public List<Integer> HYB_SIZE_NOU{get;set;}
    public List<Integer> HYB_DISC_NOU{get;set;}
    
    public List<String> HYB_NAME_HD{get;set;}
    public List<Integer> HYB_PRICE_HD{get;set;}
    public List<String> HYB_FAO1_HD{get;set;} 
    public List<Integer> HYB_BAGS_HD{get;set;}
    public Integer HYB_NUM_HD{get;set;}
    public List<Integer> HYB_SIZE_HD{get;set;}
    public List<Integer> HYB_DISC_HD{get;set;}
    
    public List<String> HYB_NAME_OTHERS{get;set;}
    public List<Integer> HYB_PRICE_OTHERS{get;set;}
    public List<String> HYB_FAO1_OTHERS{get;set;}
    public List<Integer> HYB_BAGS_OTHERS{get;set;}
    public Integer HYB_NUM_OTHERS{get;set;}
    public List<Integer> HYB_SIZE_OTHERS{get;set;}
    public List<Integer> HYB_DISC_OTHERS{get;set;}
    
    public List<String> DISPLAY{get;set;}
    public Integer STYLELINES{get;set;}

    public String FOCHybrid {get;set;}
    public String Data {get;set;}
    public String Phones {get;set;}

    public Voucher_RO_Corn_2016_Controller(ApexPages.StandardController controller) {
            this.controller = controller;
            Id VoucherID = controller.getRecord().ID;
            
            voucher = new Voucher__c();
            AccContact = new Contact();
            STYLELINES = 0;
        
            if(VoucherID!=null){  
                voucher=[SELECT AddressCopy__c,DistributorNameCopy__c,EmailCopy__c,PhoneCopy__c,FarmNameCopy__c, AccountRef__r.Province_lckp__r.Name, Name,
                         AccountRef__r.Buyer_RSA__r.Name, AccountRef__r.Buyer_RSA__r.Phone, AccountRef__r.Buyer_RSA__r.Email, AccountRef__r.Client_Code__c,
                         AccountRef__r.TotalAcreagesCY__c, AccountRef__r.City_lckp__r.Name, AccountRef__r.CornTotalAcreagesCY__c,Owner.Name, LastModifiedDate,
                         AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.Street__c, Status__c, AccountRef__r.County__c, LKP_CONTACT__c, LKP_CONTACT__r.Name,
                         AccountRef__r.DE_POGCornPY__c, AccountRef__r.CornTotalSalesPY__c,AccountRef__r.AgreedMTOCornSalesCY__c, FiscalCodeCopy__c, TotalBags__c, TotalBagsFOC__c,
                         AccountRef__r.Region_lckp__r.Name, VoucherCampaignRef__c, VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name, Price_Coupon__c
                         FROM Voucher__c
                         WHERE id=:VoucherID];
                
                if(voucher.AccountRef__c!=null){
                     try{
                         AccContact=[SELECT Id, Name, MobilePhone, Phone, DE_MonsantoID__c, Decision_Maker__c
                         FROM Contact
                         WHERE AccountId=:voucher.AccountRef__c
                         ORDER BY Decision_Maker__c DESC LIMIT 1];} catch( Exception e ) {System.debug(e);}
                }

            HYB_NAME_NOUHD = new List<String>();
            HYB_PRICE_NOUHD = new List<Integer>();
            HYB_FAO1_NOUHD = new List<String>();
            HYB_BAGS_NOUHD = new List<Integer>();
            HYB_NUM_NOUHD = 0;
            HYB_SIZE_NOUHD = new List<Integer>();
            HYB_DISC_NOUHD = new List<Integer>();

            HYB_NAME_NOU = new List<String>();
            HYB_PRICE_NOU = new List<Integer>();
            HYB_FAO1_NOU = new List<String>();
            HYB_BAGS_NOU = new List<Integer>();
            HYB_NUM_NOU = 0;
            HYB_SIZE_NOU = new List<Integer>();
            HYB_DISC_NOU = new List<Integer>();            
            
            HYB_NAME_HD = new List<String>();
            HYB_PRICE_HD = new List<Integer>();
            HYB_FAO1_HD = new List<String>();
            HYB_BAGS_HD = new List<Integer>();
            HYB_NUM_HD = 0;
            HYB_SIZE_HD = new List<Integer>();
            HYB_DISC_HD = new List<Integer>();
            
            HYB_NAME_OTHERS = new List<String>();
            HYB_PRICE_OTHERS = new List<Integer>();
            HYB_FAO1_OTHERS = new List<String>();
            HYB_BAGS_OTHERS = new List<Integer>();
            HYB_NUM_OTHERS = 0;
            HYB_SIZE_OTHERS = new List<Integer>();
            HYB_DISC_OTHERS = new List<Integer>();

            if(AccContact.MobilePhone!=null && voucher.PhoneCopy__c!=null){
                Phones = AccContact.MobilePhone + ' / ' + voucher.PhoneCopy__c;
            }
            if(AccContact.MobilePhone!=null && voucher.PhoneCopy__c==null){
                Phones = AccContact.MobilePhone;
            }
            if(AccContact.MobilePhone==null && voucher.PhoneCopy__c!=null){
                Phones = voucher.PhoneCopy__c;
            }
            if(AccContact.MobilePhone==null && voucher.PhoneCopy__c==null){
                Phones = '';
            }
            FOCHybrid = '';

            // Treatment for voucher details
            Data = voucher.LastModifiedDate.format('dd/MM/yyyy');
            status = voucher.status__c == 'Cancelled' ? 1 : 0;

            // Recover all possible discounts considering total bags and sales increase
            for(Discount__c d : [SELECT Id, PICK_Applies_to__c,
                                NUM_DiscountperBag__c, NUM_Min_First_Ladder__c, NUM_Max_First_Ladder__c,
                                MaxBags__c, MinBags__c
                                FROM Discount__c
                                WHERE VoucherCampaignRef__c = : voucher.VoucherCampaignRef__c
                                AND FRML_Enabled__c = true
                                AND RecordTypeId = : Util.recordType.get('Discount__c:Smart_discount')]) {
              
                Boolean setDiscount = false;
                Decimal MinField_value = (Decimal)voucher.AccountRef__r.AgreedMTOCornSalesCY__c;
                Decimal MaxField_value = (Decimal)voucher.AccountRef__r.CornTotalSalesPY__c;
                
                // Special treatment for new customers also implemented on the class TriggerVoucherDiscounts
                if(voucher.AccountRef__r.CornTotalSalesPY__c == 0) {
                    MinField_value = 0.0;
                    MaxField_value = 1.0;
                }

                if(d.MaxBags__c != null) {
                    if(d.NUM_Max_First_Ladder__c!= null)
                        setDiscount = (voucher.AccountRef__r.AgreedMTOCornSalesCY__c >= d.MinBags__c && voucher.AccountRef__r.AgreedMTOCornSalesCY__c <= d.MaxBags__c && MinField_value >= ((Integer)(d.NUM_Min_First_Ladder__c * MaxField_value).round()) && MinField_value < ((Integer)(d.NUM_Max_First_Ladder__c * MaxField_value).round())) ? true : false;
                    else
                        setDiscount = (voucher.AccountRef__r.AgreedMTOCornSalesCY__c >= d.MinBags__c && voucher.AccountRef__r.AgreedMTOCornSalesCY__c <= d.MaxBags__c && MinField_value >= ((Integer)(d.NUM_Min_First_Ladder__c * MaxField_value).round())) ? true : false;
                }
                else{
                    if(d.NUM_Max_First_Ladder__c!= null)
                        setDiscount = (voucher.AccountRef__r.AgreedMTOCornSalesCY__c >= d.MinBags__c && voucher.AccountRef__r.AgreedMTOCornSalesCY__c >= ((Integer)(d.NUM_Min_First_Ladder__c * MaxField_value).round()) && MinField_value < ((Integer)(d.NUM_Max_First_Ladder__c * MaxField_value).round())) ? true : false;
                    else
                        setDiscount = (voucher.AccountRef__r.AgreedMTOCornSalesCY__c >= d.MinBags__c && MinField_value >= ((Integer)(d.NUM_Min_First_Ladder__c * MaxField_value).round())) ? true : false;
                }

                // Now we have the possible discounts for New and Premium products on the Map
                if(setDiscount)
                    Map_Discounts.put(d.PICK_Applies_to__c, (Integer)d.NUM_DiscountperBag__c.round());
            }
            
            system.debug('***Possible Smart discounts from Visualforce Controller: ' + Map_Discounts);

            List<VoucherLineItem__c> FOCvli = [SELECT Agreed__c,Bags__c,HybridName__c,Id,LastModifiedDate,Name,ProductName__c,PICK_TYPE__c
                            FROM VoucherLineItem__c
                            WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c='Free of charge'
                            LIMIT 1];
                            
            if(FOCvli.size() > 0)
                FOCHybrid = FOCvli[0].HybridName__c;

            DISPLAY = new List<String>{'','','',''};

            for(VoucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, CampaignLineItemRef__c, LKP_ProductCatalogEntry__c, LKP_ProductCatalogEntry__r.TXT_FAO__c,
                                            HybridGroup__c, HybridName__c, PICK_TYPE__c, Price__c, ProductName__c, LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c,
                                            LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.DE_isPremium__c 
                                            FROM VoucherLineItem__c WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c!='Free of charge'
                                            ORDER BY HybridGroup__c DESC,HybridName__c ASC]){
                    String disc = '';  
                    Integer discNumber = 0;                          
                    if(vli.LKP_ProductCatalogEntry__r.DE_isPremium__c){
                        disc = Map_Discounts.get('Premium') != null ? Map_Discounts.get('Premium').toPlainString() : '';
                        if(disc != '') discNumber = (Integer)Map_Discounts.get('Premium').round();
                    } else {
                        if(vli.LKP_ProductCatalogEntry__r.NewProduct__c){
                            disc = Map_Discounts.get('New') != null ? Map_Discounts.get('New').toPlainString() : '';
                            if(disc != '') discNumber = (Integer)Map_Discounts.get('New').round();
                        }else
                            discNumber = 0;
                    }

                    if(vli.HybridGroup__c.equalsIgnoreCase('NOU HD')) {
                        DISPLAY[0] = 'display:table-cell;';
                        HYB_NAME_NOUHD.add(vli.HybridName__c);
                        HYB_PRICE_NOUHD.add(vli.Price__c.intValue());
                        HYB_FAO1_NOUHD.add(vli.LKP_ProductCatalogEntry__r.TXT_FAO__c);
                        HYB_BAGS_NOUHD.add(vli.Bags__c.intValue());
                        HYB_NUM_NOUHD = HYB_NUM_NOUHD + 1;
                        HYB_SIZE_NOUHD.add(vli.LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c.intValue()*1000);
                        HYB_DISC_NOUHD.add(discNumber);
                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('NOU')) {
                        DISPLAY[1] = 'display:table-cell;';
                        HYB_NAME_NOU.add(vli.HybridName__c);
                        HYB_PRICE_NOU.add(vli.Price__c.intValue());
                        HYB_FAO1_NOU.add(vli.LKP_ProductCatalogEntry__r.TXT_FAO__c);
                        HYB_BAGS_NOU.add(vli.Bags__c.intValue());
                        HYB_NUM_NOU = HYB_NUM_NOU + 1;
                        HYB_SIZE_NOU.add(vli.LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c.intValue()*1000);
                        HYB_DISC_NOU.add(discNumber);
                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('HD')) {
                        DISPLAY[2] = 'display:table-cell;';
                        HYB_NAME_HD.add(vli.HybridName__c);
                        HYB_PRICE_HD.add(vli.Price__c.intValue());
                        HYB_FAO1_HD.add(vli.LKP_ProductCatalogEntry__r.TXT_FAO__c);
                        HYB_BAGS_HD.add(vli.Bags__c.intValue());
                        HYB_NUM_HD = HYB_NUM_HD + 1;
                        HYB_SIZE_HD.add(vli.LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c.intValue()*1000);
                        HYB_DISC_HD.add(discNumber);

                    }
                    if(vli.HybridGroup__c.equalsIgnoreCase('MAXTECH') || vli.HybridGroup__c.equalsIgnoreCase('CLASIC') || vli.HybridGroup__c.equalsIgnoreCase('YIELDGARD') || vli.HybridGroup__c.equalsIgnoreCase('DK')) {
                        DISPLAY[3] = 'display:table-cell;';
                        HYB_NAME_OTHERS.add(vli.HybridName__c);
                        HYB_PRICE_OTHERS.add(vli.Price__c.intValue());
                        HYB_FAO1_OTHERS.add(vli.LKP_ProductCatalogEntry__r.TXT_FAO__c);
                        HYB_BAGS_OTHERS.add(vli.Bags__c.intValue());
                        HYB_NUM_OTHERS = HYB_NUM_OTHERS + 1;
                        HYB_SIZE_OTHERS.add(vli.LKP_ProductCatalogEntry__r.ProductRef__r.ProductBagSize__c.intValue()*1000);
                        HYB_DISC_OTHERS.add(discNumber);

                    }                    
                }
                        
            STYLELINES = HYB_NUM_NOUHD + HYB_NUM_NOU + HYB_NUM_HD + HYB_NUM_OTHERS;

    }
}
}