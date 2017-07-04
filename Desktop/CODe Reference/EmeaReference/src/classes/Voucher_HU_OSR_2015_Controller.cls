public with sharing class Voucher_HU_OSR_2015_Controller {

public Voucher__c voucher  {get;set;}  
public List<VoucherLineItem__c> voucherLineItems  {get;set;}
public String CreatedDate {get;set;}  
public Set<String> hybNames {get;set;}
public String Cancelled {get;set;}
public Decimal bagSum {get;set;}
public Map<voucherLineItem__c, Map<String,Decimal>> dataMap {get;set;}
public Map<String,Decimal> hybVsBags{get;set;}
private ApexPages.StandardController controller;
    
    public Voucher_HU_OSR_2015_Controller(ApexPages.StandardController controller) {
        this.controller = controller;
        
        ID VoucherID = controller.getRecord().ID;
        
        voucher= new Voucher__c ();
        voucherLineItems = new List<VoucherLineItem__c>();
        hybNames = new Set<String>();
        dataMap = new Map<voucherLineItem__c, Map<String,Decimal>>();
        bagSum=0;
        hybVsBags= new Map<String,Decimal>();
        CreatedDate='';
        Cancelled='';
        
        if(VoucherID!=null){
          voucher=[SELECT AccountRef__c, AccountRef__r.client_code__c, AddressCopy__c,CampaignRef__c,CancelReason__c,CreatedById,CreatedDate,DiscountCopy__c,
                  DistributorNameCopy__c,DistributorRef__c, DistributorRef__r.Street__c, DistributorRef__r.city__c, DistributorRef__r.StateProvince__c,
                  DistributorRef__r.county__c, EmailCopy__c,FarmNameCopy__c,FiscalCodeCopy__c,Id,LastModifiedDate,Name,OwnerId, Price_Coupon__c,
                  PhoneCopy__c,sentMail__c,Signed__c,Status__c,SystemModstamp,TotalBagsFOC__c,TotalBags__c,VoucherCampaignRef__c,
                  VoucherCampaignRef__r.Discount_Type__c, Price__c, PriceWithDiscount__c,  Owner.Name, DiscountRef__c
                  FROM Voucher__c
                  WHERE id=:VoucherID]; 
                  
                  voucherlineitems = [SELECT Id, HybridName__c, Bags__c FROM VoucherLineItem__c WHERE VoucherRef__c=:VoucherID];  
       
        if(voucher.status__c=='Cancelled')
          cancelled='CANCELLED';

        for(VoucherLineItem__c vli : voucherlineitems){    
          if(vli.hybridName__c!=null){
            hybNames.add(vli.hybridName__c);
            dataMap.put(vli,new Map<String,Decimal>{vli.hybridName__c=> vli.Bags__c});
          }
        } 
        for(String hybnam : hybNames){
          for(Map<String,Decimal> map1: dataMap.values()){
            if(map1.get(hybNam)!=null)
              bagSum=bagSum+map1.get(hybNam);
          }
          hybVsBags.put(hybnam,bagSum);
          bagSum=0;
        } 
      }
    }
}