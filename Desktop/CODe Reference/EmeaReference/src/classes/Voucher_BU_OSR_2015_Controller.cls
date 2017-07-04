public with sharing class Voucher_BU_OSR_2015_Controller {

  public ApexPages.StandardController controller;

  public Voucher__c voucher {get;set;}
  public Contact vouContact {get;set;}
  public Integer status{get;set;}

  public String voucherDate {get;set;}
  public String PostalCode {get;set;}
  public String vouContactName {get;set;}
  
  public List<Integer> Acr {get;set;}
  public Map<String, Integer> MapCharged {get;set;}
  public Map<String, Integer> MapFOC {get;set;}

  public Voucher_BU_OSR_2015_Controller(ApexPages.StandardController controller) {
    this.controller = controller;
    Id voucherId = controller.getRecord().Id;
    
    voucher = new Voucher__c();
    vouContact = new Contact();

    if(voucherId!=null) {
    
      voucher = [SELECT Name, Owner.Name, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c, FiscalCodeCopy__c,
                        AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LastModifiedDate,AccountRef__r.Client_Code__c,
                        AccountRef__r.Street__c, AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.ZIPPostalCode__c,
                        AccountRef__r.TotalAcreagesCY__c, AccountRef__r.CornTotalAcreagesCY__c, AccountRef__r.OSRTotalAcreagesCY__c,
                        VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c
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
      Map<String, VoucherLineItem__c> MapVli = new Map<String, VoucherLineItem__c>();
      for(VoucherLineItem__c vli : [SELECT Id, Name, Agreed__c, Bags__c, ProductName__c, HybridName__c, HybridGroup__c, FAO__c, PICK_TYPE__c,
                                           CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                                    FROM VoucherLineItem__c
                                    WHERE VoucherRef__c=:voucherId
                                    AND PICK_TYPE__c = 'Charged']) {
        
        MapVli.put(vli.HybridName__c,vli);
      }
      
      // Free of charge
      Map<String, VoucherLineItem__c> MapVliFOC = new Map<String, VoucherLineItem__c>();
      for(VoucherLineItem__c vliFOC : [SELECT Id, Name, Agreed__c, Bags__c, ProductName__c, HybridName__c, HybridGroup__c, FAO__c, PICK_TYPE__c,
                                           CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                                    FROM VoucherLineItem__c
                                    WHERE VoucherRef__c=:voucherId
                                    AND PICK_TYPE__c = 'Free of charge']) {
        
        // Free of charge lines can be duplicated
        if(MapVliFOC.get(vliFOC.HybridName__c)!=null)
          vliFOC.Bags__c = vliFOC.Bags__c + MapVliFOC.get(vliFOC.HybridName__c).Bags__c;
          
        MapVliFOC.put(vliFOC.HybridName__c,vliFOC);
      }
      
      MapCharged = new Map<String, Integer>();
      MapFOC = new Map<String, Integer>();
      for(ProductCatalogEntry__c pce : [SELECT Id, Name, prodDesc__c, ProductRef__c, ProductRef__r.ProductHybridGroup__c
                                          FROM ProductCatalogEntry__c
                                          WHERE ProductCatalogRef__r.Name = 'Bulgaria - OSR - Sales - 2015']) {
        // Charged
        if(MapVli.get(pce.prodDesc__c)!=null)
            MapCharged.put(pce.prodDesc__c,MapVli.get(pce.prodDesc__c).Bags__c.intValue());
        else
          MapCharged.put(pce.prodDesc__c,0);
        
        // FOC
        if(MapVliFOC.get(pce.prodDesc__c)!=null)
            MapFOC.put(pce.prodDesc__c,MapVliFOC.get(pce.prodDesc__c).Bags__c.intValue());
        else
          MapFOC.put(pce.prodDesc__c,0);

      }
      
    }
  }
}