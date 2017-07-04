public with sharing class VoucherHungaryCorn2015Controller {

public String HYB_DISPLAY {get;set;}
public String FOC_DISPLAY {get;set;}

public Integer HYB_NUM_BAGS{get;set;}
public Integer FOC_NUM_BAGS{get;set;}

public List<String> HYB_NAME{get;set;}
public List<String> HYB_TREAT{get;set;}
public List<Integer> HYB_BAGS{get;set;}
public List<String> FOC_NAME{get;set;}
public List<String> FOC_TREAT{get;set;}
public List<Integer> FOC_BAGS{get;set;}    

public Voucher__c voucher  {get;set;}  
public Account farm {get;set;}
public Account distrib {get;set;}
public List<VoucherLineItem__c> voucherLineItems  {get;set;}
public String CreatedDate {get;set;}  
public Set<String> hybNames {get;set;}
public String Cancelled {get;set;}
public String tipo {get;set;}
public String fin {get;set;}
public String CreateDate {get;set;}
public Decimal bagSum {get;set;}
public Map<voucherLineItem__c, Map<String,Decimal>> dataMap {get;set;}
public Map<voucherLineItem__c, Map<String,Decimal>> dataMapPoints {get;set;}
public Map<String,Decimal> hybVsBags{get;set;}
public Integer Points{get;set;}



private ApexPages.StandardController controller;
    
    public VoucherHungaryCorn2015Controller (ApexPages.StandardController controller) {
        this.controller = controller;
        
        ID VoucherID = controller.getRecord().ID;
        
        voucher= new Voucher__c ();
        voucherLineItems = new List<VoucherLineItem__c>();
        hybNames = new Set<String>();
        dataMap = new Map<voucherLineItem__c, Map<String,Decimal>>();
        dataMapPoints = new Map<voucherLineItem__c, Map<String,Decimal>>();
        bagSum=0;
        hybVsBags= new Map<String,Decimal>();
        CreatedDate='';
        Cancelled='';
        fin='';
        tipo='';
        CreateDate='';
        List<ProductCatalogEntry__c> pces = new List<ProductCatalogEntry__c>();
        Map<String,Boolean> premiumPces = new Map<String,Boolean>();
        
        if(VoucherID!=null) 
        {
        voucher=[SELECT AccountRef__c, AccountRef__r.client_code__c, AccountRef__r.City__c, AddressCopy__c,CampaignRef__c,CancelReason__c,CreatedById,CreatedDate,DiscountCopy__c,
                  DistributorNameCopy__c,DistributorRef__c, DistributorRef__r.Street__c, DistributorRef__r.city__c, DistributorRef__r.StateProvince__c, DistributorRef__r.county__c, EmailCopy__c,FarmNameCopy__c,FiscalCodeCopy__c,Id,LastModifiedDate,Name,OwnerId,
                  PhoneCopy__c,sentMail__c,Signed__c,Status__c,SystemModstamp,TotalBagsFOC__c,TotalBags__c
                  ,VoucherCampaignRef__c, VoucherCampaignRef__r.Discount_Type__c, Price__c, PriceWithDiscount__c,  Owner.Name, DiscountRef__c, AccountRef__r.DE_ForecastCornCY__c, AccountRef__r.NUM_AGREED_CORN_CHARGED_CY__c,
                  AccountRef__r.Address_line_1__c, AccountRef__r.Address_line_2__c
                  FROM Voucher__c
                  WHERE id=:VoucherID]; 
                  
         voucherlineitems = [SELECT id, HybridName__c, Bags__c, ProductName__c,PICK_TYPE__c,CampaignLineItemRef__r.Treatment__c from voucherlineitem__c where voucherRef__c=:VoucherID];  
         
      HYB_NAME = new List<String>();
      HYB_TREAT = new List<String>();
      HYB_BAGS = new List<Integer>();
      FOC_NAME = new List<String>();
      FOC_TREAT = new List<String>();
      FOC_BAGS = new List<Integer>();
      Integer i = 0;
      Integer j = 0;
      HYB_NUM_BAGS = 0;
      FOC_NUM_BAGS = 0;
       
       if(voucher.status__c=='Cancelled')
            cancelled='CANCELLED';
       
       CreateDate=voucher.CreatedDate.format('yyyy/MM/dd');
       
      
      for(VoucherLineItem__c vli : voucherlineitems){
        if(vli.hybridName__c!=null){
                hybNames.add(vli.hybridName__c);
                dataMap.put(vli,new Map<String,Decimal>{vli.hybridName__c=> vli.Bags__c});
               }
         
        
        if(vli.PICK_TYPE__c == 'Free of charge'){
        //system.debug('treat'+vli.CampaignLineItemRef__r.Treatment__c);
            FOC_NAME.add(vli.hybridName__c);
            if(voucher.status__c=='Cancelled'){
                FOC_TREAT.add('Not Available');
            }else{
                FOC_TREAT.add(vli.CampaignLineItemRef__r.Treatment__c);
            }
            FOC_BAGS.add(vli.Bags__c.intValue());
            FOC_NUM_BAGS = FOC_NUM_BAGS + vli.Bags__c.intValue();
            j++;
        } else {
        //system.debug('treat'+vli.CampaignLineItemRef__r.Treatment__c);
            HYB_NAME.add(vli.HybridName__c);
            if(voucher.status__c=='Cancelled'){
                HYB_TREAT.add('Not Available');
            }else{
                HYB_TREAT.add(vli.CampaignLineItemRef__r.Treatment__c);
            }
            HYB_BAGS.add(vli.Bags__c.intValue());
            HYB_NUM_BAGS = HYB_NUM_BAGS + vli.Bags__c.intValue();
            i++;
        }
        
       }
         
       Points= (Integer)voucher.Price__c;
       for(String hybnam : hybNames){
           for(Map<String,Decimal> map1: dataMap.values()){
               if(map1.get(hybNam)!=null)
               bagSum=bagSum+map1.get(hybNam);
           }
           hybVsBags.put(hybnam,bagSum);
           bagSum=0;    } 
           
        
        if(i==0){HYB_DISPLAY = 'display:none;';} else {HYB_DISPLAY = '';}
        if(j==0){FOC_DISPLAY = 'display:none;';} else {FOC_DISPLAY = '';}
     }
  }
}