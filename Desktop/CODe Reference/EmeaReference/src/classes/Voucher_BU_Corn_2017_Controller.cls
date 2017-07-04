public with sharing class Voucher_BU_Corn_2017_Controller {

    public ApexPages.StandardController controller;

    public Voucher__c voucher {get;set;}
    public Contact vouContact {get;set;}
    public Integer status {get;set;}
    public String voucherDate {get;set;}
    public String PostalCode {get;set;}
    public String vouContactName {get;set;}
    public Integer bags {get;set;}
    public Decimal discount {get;set;}
    public Integer intDisc {get;set;}
    public boolean newCust {get;set;}
    public Integer totalDisc {get;set;}

    public List<Integer> Acr {get;set;}
    public List<List<String>> List_PCE {get;set;}
    public List<List<String>> List_PCE_Premium {get;set;}
    public List<List<String>> List_PCE_Progress {get;set;}
    public List<List<String>> List_PCE_Classic {get;set;}
    public List<Discount__c> List_Disc_Bag {get;set;}

    public Voucher_BU_Corn_2017_Controller(ApexPages.StandardController controller) {
    
    this.controller = controller;
    Id voucherId = controller.getRecord().Id;
    
    voucher = new Voucher__c();
    vouContact = new Contact();
    newCust = false;

    if(voucherId != null) {
    
      voucher = [SELECT Name, Owner.Name, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c, FiscalCodeCopy__c,
                        AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LastModifiedDate,AccountRef__r.Client_Code__c,
                        AccountRef__r.Street__c, AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.ZIPPostalCode__c,
                        AccountRef__r.TotalAcreagesCY__c, AccountRef__r.CornTotalAcreagesCY__c, AccountRef__r.OSRTotalAcreagesCY__c,
                        VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c, NUM_EXTRA_VOLUME__c, AccountRef__r.CornTotalSalesPY__c
                 FROM Voucher__c
                 WHERE Id = : voucherId];
                
      if(voucher.AccountRef__c != null) {

        if(voucher.AccountRef__r.CornTotalSalesPY__c == 0 || voucher.AccountRef__r.CornTotalSalesPY__c == null) newCust = true;  
        system.debug('New Customer: ' + newCust);
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

            system.debug('***ACREAGE ' + acreage.AcrProductGroupRef__r.Name + ' ' + acreage.AcrTotalAcreages__c);
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
      status = voucher.status__c == 'Cancelled' ? 1 : 0;
      
      Integer Bags_Charged = 0;
      Integer Bags_FOC = 0;
      Map<String, Map<String, Integer>> Map_VLI = new Map<String, Map<String, Integer>>();
      Map<String, Decimal> Map_VLI_Discount = new Map<String, Decimal>();
      for(VoucherLineItem__c vli : [SELECT Id, Bags__c, HybridName__c, PICK_TYPE__c, NUM_Price_Discount__c 
                                    FROM VoucherLineItem__c
                                    WHERE VoucherRef__c=:voucherId]) {
        
        if(vli.PICK_TYPE__c == 'Charged') {

          Bags_Charged = vli.Bags__c.intValue();
          Bags_FOC = 0;
          
          if(Map_VLI.get(vli.HybridName__c) != null) {
            Bags_Charged = vli.Bags__c.intValue() + Map_VLI.get(vli.HybridName__c).get('Bags_Charged');
            Bags_FOC = Map_VLI.get(vli.HybridName__c).get('Bags_FOC');
          }
          Map_VLI.put(vli.HybridName__c, new Map<String, Integer>{'Bags_Charged'=>Bags_Charged,'Bags_FOC'=>Bags_FOC});
          Map_VLI_Discount.put(vli.HybridName__c,vli.NUM_Price_Discount__c);
        }

        if(vli.PICK_TYPE__c == 'Free of charge') {

          Bags_Charged = 0;
          Bags_FOC = vli.Bags__c.intValue();
          
          if(Map_VLI.get(vli.HybridName__c) != null) {
            Bags_Charged = Map_VLI.get(vli.HybridName__c).get('Bags_Charged');
            Bags_FOC = vli.Bags__c.intValue() + Map_VLI.get(vli.HybridName__c).get('Bags_FOC');
          }
          Map_VLI.put(vli.HybridName__c, new Map<String, Integer>{'Bags_Charged'=>Bags_Charged,'Bags_FOC'=>Bags_FOC});
        }

      }
      
      Map<String, ProductCatalogEntry__c> Map_PCE = new Map<String, ProductCatalogEntry__c>();

      //List_Disc_Bag = new List<Discount__c>();
      //List_Disc_Bag = [SELECT NUM_DiscountperBag__c FROM Discount__c WHERE VoucherCampaignRef__r.Name = 'Bulgaria - Corn - 2017' AND RecordType.Name = 'Smart Discount'];

      for(ProductCatalogEntry__c pce : [SELECT Id, Name, ProductRef__r.Description, ProductRef__r.ProductHybridGroup__c, NewProduct__c, DE_isPremium__c, TXT_FAO__c
                                          FROM ProductCatalogEntry__c
                                          WHERE VoucherProduct__c = true
                                          AND ProductRef__r.Description != null
                                          AND ProductCatalogRef__r.Name = 'Bulgaria - Corn - Sales - 2017'
                                          ORDER BY TXT_FAO__c ASC NULLS LAST, ProductRef__r.Description ASC, ProductRef__r.ProductBagSize__c ASC NULLS FIRST])
      Map_PCE.put(pce.ProductRef__r.Description, pce);

      List_PCE_Premium = new List<List<String>>();
      List_PCE_Progress = new List<List<String>>();
      List_PCE_Classic = new List<List<String>>();
      totalDisc = 0;
      

      for(ProductCatalogEntry__c pce : Map_PCE.values()) {

        List<String> List_info = new List<String>();
        //String TXT_NEW = pce.NewProduct__c ? 'NEW' : '';
        String TXT_HD = '';
        String TXT_FAO = (pce.TXT_FAO__c != '0' && pce.TXT_FAO__c != null) ? pce.TXT_FAO__c : '';      
        
        if((pce.DE_isPremium__c || pce.NewProduct__c || pce.ProductRef__r.Description == 'DKC4014') && pce.ProductRef__r.Description != 'DKC5141' && pce.ProductRef__r.Description != 'DKC4490'){

          TXT_HD = 'HD';

        } else{

          TXT_HD = '';

        } 

        List_info.add(pce.ProductRef__r.Description);
        List_info.add(TXT_HD);
        List_info.add(TXT_FAO);
        //List_info.add(TXT_NEW);
        
        if(pce.ProductRef__r.Description != null) {

          discount = 0;
          intDisc = 0;
          system.debug('***PCE description' + pce.ProductRef__r.Description);
          bags = 0;

          if (Map_VLI.containsKey(pce.ProductRef__r.Description) && Map_VLI_Discount.containsKey(pce.ProductRef__r.Description)){
            discount = Map_VLI_Discount.get(pce.ProductRef__r.Description);
            intDisc = discount.intValue();
            bags = Map_VLI.get(pce.ProductRef__r.Description).get('Bags_Charged');
          } 
          system.debug('+++aqui');
          List_info.add(String.valueof(intDisc));
          List_info.add(String.valueof(bags));
          //List_info.add(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_Charged') != 0 ? String.valueOf(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_Charged')) : '');
          //List_info.add(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_FOC') != 0 ? String.valueOf(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_FOC')) : '');
          List_info.add(String.valueof(intDisc * bags));
          //List_info.add(String.valueOf(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_FOC') + Map_VLI.get(pce.ProductRef__r.Description).get('Bags_Charged')));

          if(pce.DE_isPremium__c){
            List_PCE_Premium.add(List_info);
          }
          else if(pce.NewProduct__c){
            List_PCE_Progress.add(List_info);
          }
          else{
            List_PCE_Classic.add(List_info);
          }

        } else {
          List_info.add('');
          List_info.add('');

          List_info.add('');
        }
        totalDisc = totalDisc + (intDisc * bags);
        system.debug('***List_info: ' + List_info);
      }

    }
  }
}