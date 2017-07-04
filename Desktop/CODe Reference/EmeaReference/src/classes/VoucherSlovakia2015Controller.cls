public with sharing class VoucherSlovakia2015Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}
    
    public List<List<String>> VLI_Final {get;set;}
    public List<List<String>> VLI_FOC_ONLY {get;set;}
    public Double DKClubFactor {get;set;}
    
    public Integer status{get;set;}
    
    public String Data {get;set;}
    public String Phones {get;set;}
    
    public ApexPages.StandardController controller; 
      
    public VoucherSlovakia2015Controller(ApexPages.StandardController controller) {
        this.controller = controller;
        Id VoucherID = controller.getRecord().Id;
        Data='';
        Phones='';
        
        voucher = new Voucher__c();
        AccContact = new Contact();
        DKClubFactor = 1.0;
    
        if(VoucherID!=null){  
            voucher=[SELECT Id,Name,FarmNameCopy__c,AddressCopy__c,PhoneCopy__c,EmailCopy__c,DistributorNameCopy__c,LastModifiedDate,
                     AccountRef__r.Client_Code__c,AccountRef__r.City__c, AccountRef__r.StateProvince__c,AccountRef__r.County__c,Status__c,Owner.Name,
                     LKP_CONTACT__c, LKP_CONTACT__r.Name,VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name,TotalBags__c,TotalBagsFOC__c,
                     AccountRef__r.CornTotalAcreagesCY__c,AccountRef__r.Collaboratore_IT__c,TXT_NOTES__c,AccountRef__r.FiscalCode__c,AccountRef__r.GC_VATIN_Number__c,
                     AccountRef__r.CornTotalSalesPY__c,AccountRef__r.NUM_AGREED_CORN_CHARGED_CY__c,AccountRef__r.NUM_AGREED_CORN_FOC_CY__c,AccountRef__r.TotalAcreagesCY__c
                     FROM Voucher__c WHERE Id=:VoucherID];
                     
            Double POG_PY = voucher.AccountRef__r.CornTotalSalesPY__c;
            Double AGREED_CY = voucher.AccountRef__r.NUM_AGREED_CORN_CHARGED_CY__c + voucher.AccountRef__r.NUM_AGREED_CORN_FOC_CY__c;
            Double ACREAGE_CY = voucher.AccountRef__r.CornTotalAcreagesCY__c;
                     
            if( (POG_PY!=null && POG_PY > 0 && AGREED_CY!=null && POG_PY <= (1.4*AGREED_CY)) || (POG_PY!=null && POG_PY==0 && AGREED_CY!=null && ACREAGE_CY!=null && ACREAGE_CY > 0 && (AGREED_CY/ACREAGE_CY) >= 0.50) || (POG_PY!=null && POG_PY > 0 && AGREED_CY!=null && ACREAGE_CY!=null && ACREAGE_CY > 0 && (AGREED_CY/ACREAGE_CY) >= 0.90) )
                DKClubFactor = 1.25;
             
            if(voucher.AccountRef__c!=null){
                 try{
                     AccContact=[SELECT Id,Name,MobilePhone,Phone,Decision_Maker__c,Title
                     FROM Contact
                     WHERE AccountId=:voucher.AccountRef__c
                     ORDER BY Decision_Maker__c DESC LIMIT 1];} catch( Exception e ) {System.debug(e);}
                               
            }

            Data=voucher.LastModifiedDate.format('dd/MM/yyyy');
             
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
             
            if(voucher.status__c=='Cancelled'){
                status=1;
            }
            else{
                status=0;
            }
            
            Map<String, VoucherLineItem__c> VLI_Charged = new Map<String, VoucherLineItem__c>();
            Map<String, VoucherLineItem__c> VLI_FOC = new Map<String, VoucherLineItem__c>();
           
            
            for(VoucherLineItem__c vli : [SELECT Id,Name,Agreed__c,Bags__c,CampaignLineItemRef__c,CampaignLineItemRef__r.PlantingDensity__c,CreatedDate,
                                FAO__c,HybridGroup__c,HybridName__c,LastModifiedDate,OwnerId,toLabel(PICK_PRODUCTFIELD1__c),TXT_PRODUCTFIELD2__c,CampaignLineItemRef__r.ProductCatalogEntryRef__c,
                                Price__c,ProductName__c,SystemModstamp,VoucherRef__c,CampaignLineItemRef__r.HybridName__c,CampaignLineItemRef__r.Treatment__c,PICK_TYPE__c
                                FROM VoucherLineItem__c WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c = 'Charged' ORDER BY HybridName__c ASC]){
                VLI_Charged.put(vli.ProductName__c,vli);
            }
            
            for(VoucherLineItem__c vli : [SELECT Id,Name,Agreed__c,Bags__c,CampaignLineItemRef__c,CampaignLineItemRef__r.PlantingDensity__c,CreatedDate,
                                FAO__c,HybridGroup__c,HybridName__c,LastModifiedDate,OwnerId,toLabel(PICK_PRODUCTFIELD1__c),TXT_PRODUCTFIELD2__c,CampaignLineItemRef__r.ProductCatalogEntryRef__c,
                                Price__c,ProductName__c,SystemModstamp,VoucherRef__c,CampaignLineItemRef__r.HybridName__c,CampaignLineItemRef__r.Treatment__c,PICK_TYPE__c
                                FROM VoucherLineItem__c WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c = 'Free of charge' ORDER BY HybridName__c ASC]){
                VLI_FOC.put(vli.ProductName__c,vli);
            }
            
            Map<String,String> PCES = new Map<String, String>();
            for(ProductCatalogEntry__c pce : [SELECT Id, Product_Name__c, ProductRef__r.ProductTreatment__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__r.Name='Slovakia - Corn - Sales - 2015'])
            {
               PCES.put(pce.Product_Name__c, pce.ProductRef__r.ProductTreatment__c);
            }
            
            VLI_Final = new List<List<String>>();        
            for(String PN : VLI_Charged.keyset()){
                if(VLI_FOC.get(PN) != null){

                    List<String> lista1 = new List<String>{VLI_Charged.get(PN).HybridName__c,VLI_Charged.get(PN).FAO__c.toPlainString(),VLI_Charged.get(PN).Bags__c.toPlainString(),PCES.get(VLI_Charged.get(PN).ProductName__c) == null?'':PCES.get(VLI_Charged.get(PN).ProductName__c),VLI_FOC.get(PN).Bags__c.toPlainString(),((DKClubFactor*VLI_Charged.get(PN).Price__c).setscale(1)).toPlainString()};
                    VLI_Final.add(lista1);
                    VLI_FOC.remove(PN);

                } else {

                    List<String> lista1 = new List<String>{VLI_Charged.get(PN).HybridName__c,VLI_Charged.get(PN).FAO__c.toPlainString(),VLI_Charged.get(PN).Bags__c.toPlainString(),PCES.get(VLI_Charged.get(PN).ProductName__c) == null?'':PCES.get(VLI_Charged.get(PN).ProductName__c),'',((DKClubFactor*VLI_Charged.get(PN).Price__c).setscale(1)).toPlainString()};
                    VLI_Final.add(lista1);

                }
            }
            
            VLI_FOC_ONLY = new List<List<String>>();
            for(String PN : VLI_FOC.keyset()){
            
                String str1 = VLI_FOC.get(PN).HybridName__c;
                    system.debug('Id FAO que da null: ' + VLI_FOC.get(PN).id);
                    system.debug('FAO que da null: ' + VLI_FOC.get(PN).FAO__c);
                String str2 = VLI_FOC.get(PN).FAO__c.toPlainString();
                String str3 = PCES.get(VLI_FOC.get(PN).HybridName__c);
                String str4 = VLI_FOC.get(PN).Bags__c.toPlainString();
                String str5 = ((DKClubFactor*VLI_FOC.get(PN).Price__c).setscale(1)).toPlainString();
                
                List<String> lista2 = new List<String>{VLI_FOC.get(PN).HybridName__c == null?'':VLI_FOC.get(PN).HybridName__c ,VLI_FOC.get(PN).FAO__c.toPlainString()==null?'':VLI_FOC.get(PN).FAO__c.toPlainString(),'',PCES.get(VLI_FOC.get(PN).ProductName__c)==null?'':PCES.get(VLI_FOC.get(PN).ProductName__c),VLI_FOC.get(PN).Bags__c.toPlainString()==null?'':VLI_FOC.get(PN).Bags__c.toPlainString(),((DKClubFactor*VLI_FOC.get(PN).Price__c).setscale(1)).toPlainString()==null?'':((DKClubFactor*VLI_FOC.get(PN).Price__c).setscale(1)).toPlainString()};
                VLI_FOC_ONLY.add(lista2);
            }
        }
    }
}