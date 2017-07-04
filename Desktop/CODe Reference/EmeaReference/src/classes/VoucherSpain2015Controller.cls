public with sharing class VoucherSpain2015Controller {
    
    public Voucher__c voucher  {get;set;}  
    public List<VoucherLineItem__c> voucherLineItems  {get;set;}
    public List<Acreage__c> voucherAcreage {get;set;}
    public String CreatedDate {get;set;}  
    public Account voucherAccount {get;set;}
    public Contact voucherContact {get;set;}
    
    public String PoSAccount {get;set;}
    public String aviso {get;set;}
    public String voucherC1 {get;set;}
    public String voucherC2 {get;set;}
    public String voucherC3 {get;set;}
    public String voucherC4 {get;set;}
    public String voucherC5 {get;set;}
    public String voucherC6 {get;set;}
    public String voucherC7 {get;set;}
    public String voucherC8 {get;set;}

    public Integer CountVLI {get;set;}
    public Integer SUM_Riego {get;set;}
    public Integer SUM_Maiz_Grano {get;set;}
    public Integer SUM_Maiz_Silo {get;set;}

    private ApexPages.StandardController controller;
    
    public VoucherSpain2015Controller(ApexPages.StandardController controller){
        this.controller = controller;
        
        ID VoucherID = controller.getRecord().ID;
        
        voucher= new Voucher__c ();
        voucherAccount = new Account();
        voucherContact = new Contact ();
        voucherLineItems = new List<VoucherLineItem__c>();
        CreatedDate='';
        PoSAccount='';
        voucherC1='';
        voucherC2='';
        voucherC3='';
        voucherC4='';
        voucherC5='';
        voucherC6='';
        voucherC7='';
        voucherC8='';
        
        SUM_Riego=0;
        SUM_Maiz_Grano=0;
        SUM_Maiz_Silo=0;

        if(VoucherID!=null){  
      
         voucher = [SELECT AccountRef__c,AddressCopy__c,CampaignRef__c,CancelReason__c,CreatedById,CreatedDate,DiscountCopy__c,
                  DistributorNameCopy__c,DistributorRef__c,EmailCopy__c,FarmNameCopy__c,FiscalCodeCopy__c,Id,LastModifiedDate,Name,OwnerId,
                  PhoneCopy__c,sentMail__c,Signed__c,Status__c,SystemModstamp,TotalBagsFOC__c,TotalBags__c,
                  VoucherCampaignRef__c, Owner.Name, DiscountRef__c
                  FROM Voucher__c
                  WHERE ID=:VoucherID];
         
         if(voucher.CreatedDate!=null){CreatedDate=(String)(voucher.CreatedDate).format('dd / MM / YYYY');} 
                  
         voucherAccount = [SELECT Name, City__c, StateProvince__c, ZIPPostalCode__c, Phone, GC_Mobile_Phone__c, PrimaryDistributor__r.Name,
                           PrimaryPoS__r.Name, PrimaryPoS__c, CornTotalAcreagesCY__c,GC_VATIN_Number__c
                           FROM Account
                           WHERE ID=:voucher.AccountRef__c];
             
           if(VoucherAccount.PrimaryPoS__c!=null)
           PoSAccount=VoucherAccount.PrimaryPoS__r.Name;
         
         
         if(voucher.Status__C!=null){
                if (voucher.Status__c.equalsignorecase('cancelled')){aviso='CANCELADO';}
                else{aviso=' ';}
         }
         
         voucherC1=voucherAccount.Name;
         voucherC2=voucher.AddressCopy__c;
         voucherC3=voucherAccount.City__c;
         voucherC4=voucherAccount.ZIPPostalCode__c;
         voucherC5=voucherAccount.StateProvince__c;
         voucherC6=voucherAccount.Phone;
         voucherC7=voucherAccount.GC_Mobile_Phone__c;
         voucherC8=voucher.EmailCopy__c;
         
         try{
         voucherContact = [SELECT ID, Name, AccountID, Decision_Maker__c, Adress_line_1__c, City__c,
                           StateProvince__c, ZIPPostalCode__c, Phone, MobilePhone, Email 
                           FROM Contact 
                           WHERE AccountID=:voucher.AccountRef__c 
                           ORDER BY Decision_Maker__c DESC LIMIT 1];
             if(voucherContact.Name!=null){voucherC1=voucherContact.Name;}
             if(voucherContact.Adress_line_1__c!=null){voucherC2=voucherContact.Adress_line_1__c;}
             if(voucherContact.City__c!=null){voucherC3=voucherContact.City__c;}
             if(voucherContact.ZIPPostalCode__c!=null){voucherC4=voucherContact.ZIPPostalCode__c;}
             if(voucherContact.StateProvince__c!=null){voucherC5=voucherContact.StateProvince__c;}
             if(voucherContact.Phone!=null){voucherC6=voucherContact.Phone;}
             if(voucherContact.MobilePhone!=null){voucherC7=voucherContact.MobilePhone;}
             if(voucherContact.Email!=null){voucherC8=voucherContact.Email;}
         }catch( Exception e ){System.debug(e);}
         
         for(Acreage__c voucherAcreage : [SELECT ID, AcrFarmRef__c, Total_Irrigation_Acreages__c, Total_Acreages_Grain_Cron__c, Total_Silage_Corn__c FROM Acreage__c WHERE AcrFarmRef__c=:voucher.AccountRef__c AND AcrYearRef__r.Name='2014']){
             SUM_Riego=SUM_Riego+voucherAcreage.Total_Irrigation_Acreages__c.intValue();
             SUM_Maiz_Grano=SUM_Maiz_Grano+voucherAcreage.Total_Acreages_Grain_Cron__c.intValue();
             SUM_Maiz_Silo=SUM_Maiz_Silo+voucherAcreage.Total_Silage_Corn__c.intValue();
         }

         CountVLI = Integer.ValueOf([SELECT COUNT() FROM VoucherLineItem__c WHERE VoucherRef__c=:VoucherID]);
         
         voucherLineItems = [SELECT Agreed__c,Bags__c,CampaignLineItemRef__c,CreatedDate,
                         FAO__c,HybridGroup__c,HybridName__c,Id,LastModifiedDate,Name,OwnerId,Price__c,ProductName__c,
                         SystemModstamp,VoucherRef__c, VoucherRef__r.CampaignRef__r.DivisionRef__r.Name,
                         campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c, CampaignLineItemRef__r.PlantingDensity__c, CampaignLineItemRef__r.Treatment__c
                         FROM VoucherLineItem__c
                         WHERE VoucherRef__c=:VoucherID
                         ORDER BY Bags__c DESC LIMIT 5];    
         }        
     }
}