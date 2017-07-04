public with sharing class Voucher_SK_OSR_2015_Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}
    
    public List<List<String>> VLI_Final {get;set;}
    public List<List<String>> VLI_FOC_ONLY {get;set;}

    public Integer status{get;set;}
    
    public String VoucherDate {get;set;}
    public String ContactName {get;set;}
    
    public ApexPages.StandardController controller; 
      
    public Voucher_SK_OSR_2015_Controller (ApexPages.StandardController controller) {
        this.controller = controller;
        Id VoucherID = controller.getRecord().Id;
        VoucherDate='';
        ContactName='';
        status=0;   //status 1 for cancelled vouchers
        
        voucher = new Voucher__c();
        AccContact = new Contact();
    
        if(VoucherID!=null){  
            voucher=[SELECT Id,Name,FarmNameCopy__c,AddressCopy__c,PhoneCopy__c,EmailCopy__c,DistributorNameCopy__c,LastModifiedDate,
                     AccountRef__r.Client_Code__c,AccountRef__r.City__c, AccountRef__r.StateProvince__c,AccountRef__r.County__c,Status__c,Owner.Name,
                     LKP_CONTACT__c, LKP_CONTACT__r.Name,VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name,TotalBags__c,TotalBagsFOC__c,
                     AccountRef__r.OSRTotalAcreagesCY__c,AccountRef__r.Collaboratore_IT__c,TXT_NOTES__c,AccountRef__r.FiscalCode__c,FiscalCodeCopy__c,AccountRef__r.GC_VATIN_Number__c,
                     AccountRef__r.OSRTotalSalesPY__c,AccountRef__r.DE_POGOSRFOCPY__c,AccountRef__r.NUM_AGREED_OSR_CY__c,AccountRef__r.NUM_AGREED_OSR_FOC_CY__c,
                     AccountRef__r.TotalAcreagesCY__c, AccountRef__r.Owner.Name FROM Voucher__c WHERE Id=:VoucherID];
                     
            Double POG_PY = voucher.AccountRef__r.OSRTotalSalesPY__c;
            Double POG_FOC_PY = voucher.AccountRef__r.DE_POGOSRFOCPY__c;
            Double AGREED_CY = voucher.AccountRef__r.NUM_AGREED_OSR_CY__c + voucher.AccountRef__r.NUM_AGREED_OSR_FOC_CY__c;
            Double ACREAGE_CY = voucher.AccountRef__r.OSRTotalAcreagesCY__c;
            
            //if a contact related to the account has been selected
            if(voucher.LKP_CONTACT__c!=null){
                 try{
                     AccContact=[SELECT Id,Name,MobilePhone,Phone,Decision_Maker__c,Title,Position_picklist__c
                     FROM Contact
                     WHERE Id=:voucher.LKP_CONTACT__c
                     //ORDER BY Decision_Maker__c DESC LIMIT 1
                     ];} 
                catch( Exception e ) {System.debug(e);}
                               
            }

            //Treatment for voucher details
            VoucherDate=voucher.LastModifiedDate.format('dd/MM/yyyy');
            
            if(voucher.status__c=='Cancelled') status=1;

            if(AccContact.Position_picklist__c == 'CEO' || AccContact.Position_picklist__c == 'General Manager' || AccContact.Position_picklist__c == 'Chairman' || AccContact.Position_picklist__c == 'Owner' || AccContact.Position_picklist__c == 'President')
                ContactName = voucher.LKP_CONTACT__r.Name;            
            else
                ContactName = null;
            

            //Treatment for sales lines introduced
            Map<String, VoucherLineItem__c> VLI_Charged = new Map<String, VoucherLineItem__c>();
            Map<String, VoucherLineItem__c> VLI_FOC = new Map<String, VoucherLineItem__c>();
                       
            for(VoucherLineItem__c vli : [SELECT Id,Name,Agreed__c,Bags__c,CampaignLineItemRef__c,CampaignLineItemRef__r.PlantingDensity__c,CreatedDate,
                                FAO__c,HybridGroup__c,HybridName__c,LastModifiedDate,OwnerId,toLabel(PICK_PRODUCTFIELD1__c),TXT_PRODUCTFIELD2__c,CampaignLineItemRef__r.ProductCatalogEntryRef__c,
                                Price__c,ProductName__c,SystemModstamp,VoucherRef__c,CampaignLineItemRef__r.HybridName__c,PICK_TYPE__c,CampaignLineItemRef__r.ProductRef__r.Id
                                FROM VoucherLineItem__c WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c = 'Charged' ORDER BY HybridName__c ASC]){
                               
                //if the product has already been included it means there is more than one VLI for the same product in this voucher. In this case it's necessary to sum the bags indicated in all VLIs
                if(VLI_Charged.get(vli.ProductName__c) != null)
                  vli.Bags__c = vli.Bags__c + VLI_Charged.get(vli.ProductName__c).Bags__c;
                
                VLI_Charged.put(vli.ProductName__c,vli);
            }
            
            for(VoucherLineItem__c vli : [SELECT Id,Name,Agreed__c,Bags__c,CampaignLineItemRef__c,CampaignLineItemRef__r.PlantingDensity__c,CreatedDate,
                                FAO__c,HybridGroup__c,HybridName__c,LastModifiedDate,OwnerId,toLabel(PICK_PRODUCTFIELD1__c),TXT_PRODUCTFIELD2__c,CampaignLineItemRef__r.ProductCatalogEntryRef__c,
                                Price__c,ProductName__c,SystemModstamp,VoucherRef__c,CampaignLineItemRef__r.HybridName__c,PICK_TYPE__c,CampaignLineItemRef__r.ProductRef__r.Id
                                FROM VoucherLineItem__c WHERE VoucherRef__c=:VoucherID AND PICK_TYPE__c = 'Free of charge' ORDER BY HybridName__c ASC]){
                
                //if the product has already been included it means there is more than one VLI for the same product in this voucher. In this case it's necessary to sum the bags indicated in all VLIs
                if(VLI_FOC.get(vli.ProductName__c) != null)
                  vli.Bags__c = vli.Bags__c + VLI_FOC.get(vli.ProductName__c).Bags__c;
                
                VLI_FOC.put(vli.ProductName__c,vli);
            }
            
            Map<String,String> PCES = new Map<String, String>();
            for(ProductCatalogEntry__c pce : [SELECT Id, Product_Name__c, ProductRef__r.ProductTreatment__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__r.Name='Slovakia - OSR - Sales - 2015'])
            {
               PCES.put(pce.Product_Name__c, pce.ProductRef__r.ProductTreatment__c);
            }
            
            VLI_Final = new List<List<String>>();        
            for(String PN : VLI_Charged.keyset()){                
                if(VLI_FOC.get(PN) != null){
                    //get the VLIs for products that are charged and also FOC
                    List<String> lista1 = new List<String>{VLI_Charged.get(PN).HybridName__c, VLI_Charged.get(PN).Bags__c.toPlainString(), VLI_FOC.get(PN).Bags__c.toPlainString()};                        
                    VLI_Final.add(lista1);
                    //remove from the FOC list the products that are both Charged and FOC
                    VLI_FOC.remove(PN);

                } else {
                    //get the VLIs for products that are only charged
                    List<String> lista1 = new List<String>{VLI_Charged.get(PN).HybridName__c,VLI_Charged.get(PN).Bags__c.toPlainString(),''};
                    VLI_Final.add(lista1);
                }
                
            }
            
            VLI_FOC_ONLY = new List<List<String>>();
            
            for(String PN : VLI_FOC.keyset()){
                //get the VLIs for products that are only FOC
                String str1 = VLI_FOC.get(PN).HybridName__c;
                String str2 = VLI_FOC.get(PN).Bags__c.toPlainString();
                
                List<String> lista2 = new List<String>{VLI_FOC.get(PN).HybridName__c == null?'':VLI_FOC.get(PN).HybridName__c,'',VLI_FOC.get(PN).Bags__c.toPlainString()==null?'':VLI_FOC.get(PN).Bags__c.toPlainString()};
                VLI_FOC_ONLY.add(lista2);
            }
        }
    }
}