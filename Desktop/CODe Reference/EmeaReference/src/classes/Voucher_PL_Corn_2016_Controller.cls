public with sharing class Voucher_PL_Corn_2016_Controller   {

  public ApexPages.StandardController controller;

  public Voucher__c voucher {get;set;}
  public Integer status{get;set;}

  public String voucherDate {get;set;}
  
  public Map<String, VoucherLineItem__c> MAP_VLI {get;set;}
  public Decimal BAG_DISCOUNT {get;set;}
  public String Data {get;set;}

  public Boolean Checked {get;set;}

  public Voucher_PL_Corn_2016_Controller (ApexPages.StandardController controller) {
    this.controller = controller;
    Id voucherId = controller.getRecord().Id;
    voucherDate =' ';
    Checked = true;
    if(voucherId!=null) {
    
      voucher = new Voucher__c();
      voucher = [SELECT Name, Owner.Name, CreatedDate, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c, FiscalCodeCopy__c,
                        AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LKP_CONTACT__r.Name, LastModifiedDate, AccountRef__r.Client_Code__c,
                        AccountRef__r.Street__c, AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.ZIPPostalCode__c,
                        AccountRef__r.Phone, AccountRef__r.County__c,
                        AccountRef__r.DE_Territory_Key__r.DE_CP__c,
                        AccountRef__r.DE_PLZ__c,
                        VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c
                        FROM Voucher__c
                        WHERE Id=:voucherId];
                        
       
      // Recover the smart discount
      Discount__c d = [SELECT Id, PICK_Applies_to__c,
                           NUM_DiscountperBag__c, NUM_Min_First_Ladder__c, NUM_Max_First_Ladder__c,
                           MaxBags__c, MinBags__c
                           FROM Discount__c
                           WHERE VoucherCampaignRef__c = : voucher.VoucherCampaignRef__c
                           AND RecordTypeId = : Util.recordType.get('Discount__c:Smart_discount')];
                           
                           BAG_DISCOUNT = d.NUM_DiscountperBag__c;
        
     
      MAP_VLI = new Map<String, VoucherLineitem__c>();
      Integer BAGS = 0;
      
      Data = voucher.LastModifiedDate.format('dd/MM/yyyy');   

      status = voucher.status__c == 'Cancelled' ? 1 : 0;

      // All Charged products
      for (voucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, ProductName__c, HybridName__c, HybridGroup__c, FAO__c, PICK_TYPE__c, 
                                           LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.TXT_FAO__c,
                                           CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                                    FROM VoucherLineItem__c
                                    WHERE VoucherRef__c=:voucherId
                                    AND PICK_TYPE__c = 'Charged']){
                                    
                                    
                                    if (MAP_VLI.get(vli.HybridName__c) != null){
                                        BAGS = MAP_VLI.get(vli.HybridName__c).Bags__c.intValue() + vli.Bags__c.intValue();
                                        vli.Bags__c = BAGS; 
                                        MAP_VLI.remove(vli.HybridName__c);
                                    }
                                    
                                    MAP_VLI.put(vli.HybridName__c,vli);

        }
        }
                                    
      
  }
}