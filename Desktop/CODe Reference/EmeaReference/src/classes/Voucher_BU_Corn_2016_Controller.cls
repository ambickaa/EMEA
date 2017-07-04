public with sharing class Voucher_BU_Corn_2016_Controller {

    public ApexPages.StandardController controller;

    public Voucher__c voucher {get;set;}
    public Contact vouContact {get;set;}
    public Integer status {get;set;}
    public String voucherDate {get;set;}
    public String PostalCode {get;set;}
    public String vouContactName {get;set;}

    public List<Integer> Acr {get;set;}
    public List<List<String>> List_PCE {get;set;}

    public Voucher_BU_Corn_2016_Controller(ApexPages.StandardController controller) {
    
    this.controller = controller;
    Id voucherId = controller.getRecord().Id;
    
    voucher = new Voucher__c();
    vouContact = new Contact();

    if(voucherId != null) {
    
      voucher = [SELECT Name, Owner.Name, Status__c, TotalBags__c, TotalBagsFOC__c, FarmNameCopy__c, DistributorNameCopy__c, FiscalCodeCopy__c,
                        AddressCopy__c, EmailCopy__c, PhoneCopy__c, LKP_CONTACT__c, LastModifiedDate,AccountRef__r.Client_Code__c,
                        AccountRef__r.Street__c, AccountRef__r.City__c, AccountRef__r.StateProvince__c, AccountRef__r.ZIPPostalCode__c,
                        AccountRef__r.TotalAcreagesCY__c, AccountRef__r.CornTotalAcreagesCY__c, AccountRef__r.OSRTotalAcreagesCY__c,
                        VoucherCampaignRef__r.DivisionRef__c, VoucherCampaignRef__r.YearRef__c, NUM_EXTRA_VOLUME__c
                 FROM Voucher__c
                 WHERE Id = : voucherId];
                
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
      for(VoucherLineItem__c vli : [SELECT Id, Bags__c, HybridName__c, PICK_TYPE__c
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
      for(ProductCatalogEntry__c pce : [SELECT Id, Name, ProductRef__r.Description, ProductRef__r.ProductHybridGroup__c, NewProduct__c, DE_isPremium__c, TXT_FAO__c
                                          FROM ProductCatalogEntry__c
                                          WHERE VoucherProduct__c = true
                                          AND ProductRef__r.Description != null
                                          AND ProductCatalogRef__r.Name = 'Bulgaria - Corn - Sales - 2016'
                                          ORDER BY TXT_FAO__c ASC NULLS LAST, ProductRef__r.Description ASC, ProductRef__r.ProductBagSize__c ASC NULLS FIRST])
        Map_PCE.put(pce.ProductRef__r.Description, pce);

      List_PCE = new List<List<String>>();
      for(ProductCatalogEntry__c pce : Map_PCE.values()) {

        List<String> List_info = new List<String>();

        String TXT_NEW = pce.NewProduct__c ? 'NEW' : '';
        String TXT_HD = pce.DE_isPremium__c ? 'HD' : '';
        String TXT_FAO = (pce.TXT_FAO__c != '0' && pce.TXT_FAO__c != null) ? pce.TXT_FAO__c : '';
        
        List_info.add(TXT_NEW);
        List_info.add(pce.ProductRef__r.Description);
        List_info.add(TXT_HD);
        List_info.add(TXT_FAO);
        
        if(Map_VLI.get(pce.ProductRef__r.Description) != null) {
          List_info.add(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_Charged') != 0 ? String.valueOf(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_Charged')) : '');
          List_info.add(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_FOC') != 0 ? String.valueOf(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_FOC')) : '');

          List_info.add(String.valueOf(Map_VLI.get(pce.ProductRef__r.Description).get('Bags_FOC') + Map_VLI.get(pce.ProductRef__r.Description).get('Bags_Charged')));

        } else {
          List_info.add('');
          List_info.add('');

          List_info.add('');
        }
        
        if(!(Map_VLI.get(pce.ProductRef__r.Description) == null && TXT_FAO == ''))
          List_PCE.add(List_info);

      }
      system.debug('***'+List_PCE);
  }
    }
  }