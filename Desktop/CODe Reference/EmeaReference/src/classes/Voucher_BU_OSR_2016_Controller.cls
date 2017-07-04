public with sharing class Voucher_BU_OSR_2016_Controller {

  public ApexPages.StandardController controller;

  public Voucher__c voucher {get;set;}
  public Contact vouContact {get;set;}
  public Integer status{get;set;}

  public String voucherDate {get;set;}
  public String PostalCode {get;set;}
  public String vouContactName {get;set;}
  public Integer TotalBags {get;set;}
  
  public List<Integer> Acr {get;set;}
  public Map<String, Integer> MapCharged {get;set;}
  public Map<String, Integer> MapFOC {get;set;}
  public Map<String, VoucherLineItem__c> MapVli{get;set;}
  public Map<String,Integer> MapVliBags{get;set;}
  public List<String> ListVli{get;set;}

  public Voucher_BU_OSR_2016_Controller(ApexPages.StandardController controller) {
    this.controller = controller;
    Id voucherId = controller.getRecord().Id;
    
    voucher = new Voucher__c();
    vouContact = new Contact();

    if(voucherId!=null) {
    
      voucher = [SELECT Name, Owner.Name, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c, FiscalCodeCopy__c,
                        AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LastModifiedDate,AccountRef__r.Client_Code__c,
                        AccountRef__r.Street__c, AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.ZIPPostalCode__c,
                        AccountRef__r.TotalAcreagesCY__c, AccountRef__r.CornTotalAcreagesCY__c, AccountRef__r.OSRTotalAcreagesCY__c,
                        VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c, TXT_NOTES__c
                 FROM Voucher__c
                 WHERE Id=:voucherId];
                
      if(voucher.AccountRef__c != null) {
      
        vouContactName = '';
        if(voucher.LKP_CONTACT__c != null) {
          try{
            vouContact = [SELECT Name FROM Contact WHERE Id =:voucher.LKP_CONTACT__c];
            vouContactName = vouContact.Name;
          } catch( Exception e ) { system.debug(e); }
        }
      
        PostalCode = '';
        if(voucher.AccountRef__r.ZIPPostalCode__c != null) {
          PostalCode = voucher.AccountRef__r.ZIPPostalCode__c;
          if(PostalCode.length() < 5) PostalCode = '0' + PostalCode;
        }
        
        try{
          Acr = new List<Integer>{0,0,0,0,0};
          for(Acreage__c acreage : [SELECT Id, Name, AcrTotalAcreages__c, AcrProductGroupRef__c, AcrProductGroupRef__r.Name FROM Acreage__c
                                         WHERE AcrFarmRef__c =:voucher.AccountRef__c
                                         AND AcrYearRef__c =:voucher.VoucherCampaignRef__r.YearRef__c]) {
            Boolean other = true;
            if(acreage.AcrProductGroupRef__r.Name == 'Corn') {
              Acr[0] = Acr[0] + acreage.AcrTotalAcreages__c.intValue();
              other = false;
            }
            if(acreage.AcrProductGroupRef__r.Name == 'OSR') {
              Acr[1] = Acr[1] + acreage.AcrTotalAcreages__c.intValue();
              other = false;
            }
            if(acreage.AcrProductGroupRef__r.Name == 'Sun Flower') {
              Acr[2] = Acr[2] + acreage.AcrTotalAcreages__c.intValue();
              other = false;
            }
            if(acreage.AcrProductGroupRef__r.Name.contains('Wheat')) {
              Acr[3] = Acr[3] + acreage.AcrTotalAcreages__c.intValue();
              other = false;
            }
            if(other) Acr[4] = Acr[4] + acreage.AcrTotalAcreages__c.intValue();

          }
        } catch( Exception e ) { system.debug(e); }
      }

      voucherDate = voucher.LastModifiedDate.format('yyyy.MM.dd');

      if(voucher.status__c=='Cancelled')
        status=1;
      else
        status=0;

      // Charged
      TotalBags = 0;
      MapVliBags = new Map<String,Integer> ();
      MapVli = new Map<String, VoucherLineItem__c>();
      ListVli = new List<String>();
      for(VoucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, ProductName__c, HybridName__c, HybridGroup__c, FAO__c, PICK_TYPE__c,
                                           CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                                    FROM VoucherLineItem__c
                                    WHERE VoucherRef__c=:voucherId
                                    AND PICK_TYPE__c = 'Charged']) {
        TotalBags += vli.Bags__c.intValue();
        ListVli.add(vli.HybridName__c);
        MapVliBags.put(vli.HybridName__c,vli.Bags__c.intValue());
        MapVli.put(vli.HybridName__c,vli);
      }
    }
  }
}