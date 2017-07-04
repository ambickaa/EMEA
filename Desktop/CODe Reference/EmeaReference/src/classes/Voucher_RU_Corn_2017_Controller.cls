public with sharing class Voucher_RU_Corn_2017_Controller   {

        /*********************************************************/ 
        /*                        Variables declaration                         */
        /*********************************************************/ 
  public ApexPages.StandardController controller;
  public Voucher__c voucher {get;set;}
  public Integer status{get;set;}
  public Map<String, VoucherLineItem__c> MAP_VLI_Charged {get;set;}
  public List<String> ListCC {get;set;}
  public Decimal couponInDollars {get;set;}
  public Decimal couponInRubbles {get;set;}

  public Voucher_RU_Corn_2017_Controller (ApexPages.StandardController controller) {
      
        /*********************************************************/ 
        /*                        Variables initialization                        */
        /*********************************************************/   
    this.controller = controller;
    Id voucherId = controller.getRecord().Id;
    voucher = new Voucher__c();
    MAP_VLI_Charged = new Map<String, VoucherLineitem__c>();
    ListCC = new List<String>();
    String convFactorToDollar = System.Label.RU_Voucher_Corn_FY17_currency_conversion;
    status=0;
    Integer BAGS = 0;
    couponInDollars = 0;
    couponInRubbles = 0;
    
    
        if(voucherId!=null) {
            
        /*********************************************************/ 
        /*                       Retrieve voucher data                        */
        /*********************************************************/         
            voucher = [SELECT Name, Owner.Name, CreatedDate, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c, FiscalCodeCopy__c,  AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LKP_CONTACT__r.Name, LastModifiedDate, AccountRef__r.Client_Code__c, AccountRef__r.Street__c, AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.ZIPPostalCode__c, Price_Coupon__c, FRML_DISCOUNT_AMOUNT__c, AccountRef__r.Phone, AccountRef__r.County__c, AccountRef__r.DE_Territory_Key__r.DE_CP__c, AccountRef__r.DE_PLZ__c, VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c, DiscretionaryDiscount__c FROM Voucher__c WHERE Id=:voucherId];
            
        /*********************************************************/ 
        /*                    Retrieve Voucher status                        */
        /*********************************************************/
            status = voucher.status__c == 'Cancelled' ? 1 : 0;
            
        /*********************************************************/ 
        /*                     Split client code letters                         */
        /*********************************************************/
            if (voucher.AccountRef__r.Client_Code__c !=null){
                String CC = voucher.AccountRef__r.Client_Code__c;
                ListCC=CC.split('');
            } else {
                ListCC.add('-');
            }
        /*********************************************************/ 
        /*               Discount in Rubbles                                */
        /*********************************************************/
            if((voucher.TotalBags__c != null) && (voucher.DiscretionaryDiscount__c!= null)){
                couponInRubbles= (voucher.TotalBags__c) *( voucher.DiscretionaryDiscount__c);
            }       
        /*********************************************************/ 
        /*               Conversion discount to Dollars                  */
        /*********************************************************/
            if(convFactorToDollar != null){
                couponInDollars=(couponInRubbles)*(decimal.valueof(convFactorToDollar));
                couponInDollars=couponInDollars.setScale(2, RoundingMode.HALF_UP);
            }       
    
        /*********************************************************/ 
        /*                        Retrieve all products                         */
        /*********************************************************/
            for (voucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, ProductName__c, HybridName__c, HybridGroup__c, FAO__c, PICK_TYPE__c, LKP_ProductCatalogEntry__r.NewProduct__c, LKP_ProductCatalogEntry__r.TXT_FAO__c, CreatedDate, LastModifiedDate, OwnerId, Owner.Name FROM VoucherLineItem__c WHERE VoucherRef__c=:voucherId]){
                
                if(vli.PICK_TYPE__c=='Charged'){
                    if (MAP_VLI_Charged.get(vli.HybridName__c) != null){
                        BAGS = MAP_VLI_Charged.get(vli.HybridName__c).Bags__c.intValue() + vli.Bags__c.intValue();
                        vli.Bags__c = BAGS;
                        MAP_VLI_Charged.remove(vli.HybridName__c);
                    }
                    MAP_VLI_Charged.put(vli.HybridName__c,vli);
                }
            }
        } 
    }
}