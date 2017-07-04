public with sharing class Voucher_PL_OSR_2017_Controller   {

  public ApexPages.StandardController controller;

  public Voucher__c voucher {get;set;}
  public Integer status{get;set;}

  public String voucherDate {get;set;}
  
  public Map<String, VoucherLineItem__c> MAP_VLI {get;set;}
  public Map<String, VoucherLineItem__c> MAP_VLI_Premium {get;set;}
  public Map<String, Boolean> MAP_Products {get;set;}
  public Map<String, Boolean> MAP_Products_Premium {get;set;}
  public List<String> MAP_Products_Keys {get;set;}
  public List<String> MAP_Products_Premium_Keys {get;set;}
  public Map<String, ProductCatalogEntry__c> Map_PCE {get;set;}
  public String pcesInVli {get;set;}
  public String pcesInVliPremium {get;set;}
  public List<VoucherLineItem__c> List_VLI {get;set;}
  public List<VoucherLineItem__c> List_VLI_Premium {get;set;}
  public Decimal BAG_DISCOUNT {get;set;}
  public String Data {get;set;}

  public Boolean Checked {get;set;}

  public Voucher_PL_OSR_2017_Controller (ApexPages.StandardController controller) {
    this.controller = controller;
    Id voucherId = controller.getRecord().Id;
    voucherDate =' ';
    Checked = true;
    List_VLI = new List<VoucherLineItem__c>();
    List_VLI_Premium = new List<VoucherLineItem__c>();
    
    MAP_VLI = new Map<String, VoucherLineitem__c>();
    MAP_VLI_Premium = new Map<String, VoucherLineitem__c>();
    MAP_Products = new Map<String, Boolean>();
    MAP_Products_Premium = new Map<String, Boolean>();
    MAP_Products_Premium_Keys = new List<String>();
    MAP_Products_Keys = new List<String>();    
    Map_PCE = new Map<String, ProductCatalogEntry__c>();
    
    if(voucherId!=null) {
    
      voucher = new Voucher__c();
      voucher = [SELECT Name, Owner.Name, CreatedDate, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c, FiscalCodeCopy__c,
                        AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LKP_CONTACT__r.Name, LastModifiedDate, AccountRef__r.Client_Code__c,
                        AccountRef__r.Street__c, AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.ZIPPostalCode__c,
                        AccountRef__r.Phone, AccountRef__r.County__c,
                        AccountRef__r.DE_Territory_Key__r.DE_CP__c,
                        AccountRef__r.DE_PLZ__c, AccountRef__r.GC_VATIN_Number__c, AccountRef__r.NUM_AGREED_OSR_CY__c,
                        VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c, Price_Coupon__c
                        FROM Voucher__c
                        WHERE Id=:voucherId];
                        BAG_DISCOUNT = voucher.Price_Coupon__c;
      
      
      for(ProductCatalogEntry__c pce : [SELECT Id, DE_isPremium__c, NewProduct__c, prodDesc__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__r.Name = 'Poland - OSR - Sales - 2017' ORDER BY ProductRef__r.TXT_Hybrid__c ]){
          Map_PCE.put(pce.Id, pce);
          if(pce.DE_isPremium__c){
              MAP_Products_Premium.put(pce.Id, false);
              MAP_Products_Premium_Keys.add(pce.Id);
          }else{
              MAP_Products.put((String)pce.Id, false);          
              MAP_Products_Keys.add(pce.Id);
          }

      }
      system.debug('Nr pce: '+Map_PCE.size());
      system.debug('Contains key a0F6E000000BjKZUA0?'+Map_PCE.containsKey('a0F6E000000BjKZUA0'));
      
      Integer BAGS = 0;
      
      pcesInVli = '';
      pcesInVliPremium = '';      
      
      Data = voucher.LastModifiedDate.format('dd/MM/yyyy');   

      status = voucher.status__c == 'Cancelled' ? 1 : 0;

      // All Charged products
      for (voucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, ProductName__c, HybridName__c, HybridGroup__c, FAO__c, PICK_TYPE__c, 
                                    LKP_ProductCatalogEntry__r.Id, LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.TXT_FAO__c, LKP_ProductCatalogEntry__r.DE_isPremium__c,
                                    CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                                    FROM VoucherLineItem__c
                                    WHERE VoucherRef__c=:voucherId
                                    AND PICK_TYPE__c = 'Charged']){
                                        
                                        system.debug('***vli: ' + vli.HybridName__c);
                                        
                                        if (vli.LKP_ProductCatalogEntry__r.DE_isPremium__c==true){
                                            if (MAP_VLI_Premium.get(vli.LKP_ProductCatalogEntry__c) != null){
                                                BAGS = MAP_VLI_Premium.get(vli.LKP_ProductCatalogEntry__c).Bags__c.intValue() + vli.Bags__c.intValue();
                                                vli.Bags__c = BAGS; 
                                                MAP_VLI_Premium.remove(vli.LKP_ProductCatalogEntry__c);
                                            }
                                            pcesInVliPremium += vli.LKP_ProductCatalogEntry__c;
                                            MAP_Products_Premium.put(vli.LKP_ProductCatalogEntry__r.Id, true);
                                            MAP_VLI_Premium.put(vli.LKP_ProductCatalogEntry__c,vli);
                                            List_VLI_Premium.add(vli);
                                        } else {
                                                if (MAP_VLI.get(vli.LKP_ProductCatalogEntry__c) != null){
                                                    BAGS = MAP_VLI.get(vli.LKP_ProductCatalogEntry__c).Bags__c.intValue() + vli.Bags__c.intValue();
                                                    vli.Bags__c = BAGS;
                                                    MAP_VLI.remove(vli.LKP_ProductCatalogEntry__c);
                                                }
                                                pcesInVli += vli.LKP_ProductCatalogEntry__c;
                                                MAP_Products.put(vli.LKP_ProductCatalogEntry__r.Id, true);
                                                MAP_VLI.put(vli.LKP_ProductCatalogEntry__c,vli);
                                                List_VLI.add(vli);
                                        }
                                    }
                                    
                                    system.debug('***map_vli: ' + MAP_VLI);
                                    system.debug('***map_vli_premium: ' + MAP_VLI_Premium);
    }
    system.debug('PCE:'+map_PCE.containskey('a0F5700000r1ZvJEAU'));
        system.debug('MAP_Products_Premium:'+MAP_Products_Premium.keyset());
  }
}