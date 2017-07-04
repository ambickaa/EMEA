public with sharing class VoucherItaly2016Controller {

    public Voucher__c voucher  {get;set;}
    public Contact AccContact {get;set;}
    
    public String CC0 {get;set;}
    public String CC1 {get;set;}
    public String CC2 {get;set;}
    public String CC3 {get;set;}
    public String CC4 {get;set;}
    public String CC5 {get;set;}
    
    public List<VoucherLineItem__c> voucherLineItems  {get;set;}
    
    public Integer status{get;set;}
    
    public String Data {get;set;}
    
    public ApexPages.StandardController controller; 
      
    public VoucherItaly2016Controller(ApexPages.StandardController controller) {
        this.controller = controller;
        Id VoucherID = controller.getRecord().Id;
        
        voucher = new Voucher__c ();
        AccContact = new Contact();
    
        if(VoucherID!=null){  
            voucher=[SELECT Id,Name,FarmNameCopy__c,AddressCopy__c,PhoneCopy__c,EmailCopy__c,DistributorNameCopy__c,LastModifiedDate,
                     AccountRef__r.Client_Code__c,AccountRef__r.City__c, AccountRef__r.StateProvince__c,Status__c, AccountRef__r.Street__c,Owner.Name,
                     AccountRef__r.ZIPPostalCode__c,
                     LKP_CONTACT__c, LKP_CONTACT__r.Name,VoucherCampaignRef__r.DivisionRef__r.Name, VoucherCampaignRef__r.YearRef__r.Name,
                     AccountRef__r.Phone,AccountRef__r.TotalAcreagesCY__c,AccountRef__r.CornTotalAcreagesCY__c,AccountRef__r.Collaboratore_IT__c,TXT_NOTES__c
                     FROM Voucher__c WHERE id=:VoucherID];
             
            if(voucher.AccountRef__c!=null){
                 try{
                     AccContact=[SELECT Id,Name,MobilePhone,Phone,Decision_Maker__c
                     FROM Contact
                     WHERE AccountId=:voucher.AccountRef__c
                     ORDER BY Decision_Maker__c DESC LIMIT 1];} catch( Exception e ) {System.debug(e);}
             
            }
             
            CC0 = '';
            CC1 = '';
            CC2 = '';
            CC3 = '';
            CC4 = '';
            CC5 = '';
            
            List<String> clientCode= new List<String>();         
            if(voucher.AccountRef__r.Client_Code__c !=null){
                clientCode = String.valueof(voucher.AccountRef__r.Client_Code__c).split(''); 
              
                try { CC0 = clientCode.get(4); }catch( Exception e ){}
                try { CC1 = clientCode.get(5); }catch( Exception e ){}
                try { CC2 = clientCode.get(6); }catch( Exception e ){}
                try { CC3 = clientCode.get(7); }catch( Exception e ){}
                try { CC4 = clientCode.get(8); }catch( Exception e ){}
                try { CC5 = clientCode.get(9); }catch( Exception e ){}
            }
            Data=voucher.LastModifiedDate.format('dd/MM/yyyy');
                        
            if(voucher.status__c=='Cancelled'){
                status=1;
            }
            else{
                status=0;
            }
            voucherLineItems = new List<VoucherLineItem__c>();
            voucherLineItems = [SELECT Id,Name,Agreed__c,Bags__c,CampaignLineItemRef__c,campaignLineItemRef__r.PlantingDensity__c,CreatedDate,
                                FAO__c,HybridGroup__c,HybridName__c,LastModifiedDate,OwnerId,toLabel(PICK_PRODUCTFIELD1__c),TXT_PRODUCTFIELD2__c,
                                Price__c,ProductName__c,SystemModstamp,VoucherRef__c,campaignLineItemRef__r.Treatment__c,
                                LKP_ProductCatalogEntry__r.TXT_FAO__c
                                FROM VoucherLineItem__c  WHERE VoucherRef__c=:VoucherID];
        }
    }
}