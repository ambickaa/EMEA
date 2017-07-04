public with sharing class VoucherHungaryController {

public Voucher__c voucher  {get;set;}  
public Account farm {get;set;}
public Account distrib {get;set;}
public List<VoucherLineItem__c> voucherLineItems  {get;set;}
public String CreatedDate {get;set;}  
public Set<String> hybNames {get;set;}
public String Cancelled {get;set;}
public String tipo {get;set;}
public String fin {get;set;}
public Decimal bagSum {get;set;}
public Map<voucherLineItem__c, Map<String,Decimal>> dataMap {get;set;}
public Map<String,Decimal> hybVsBags{get;set;}
public String PriceToDisplay {get;set;}
public Integer TestPrice {get;set;}
public Integer resto{get;set;}
private ApexPages.StandardController controller;
    
    public VoucherHungaryController(ApexPages.StandardController controller) {
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
        fin='';
        tipo='';
        
         if(VoucherID!=null) 
        {
        voucher=[SELECT AccountRef__c, AccountRef__r.client_code__c, AddressCopy__c,CampaignRef__c,CancelReason__c,CreatedById,CreatedDate,DiscountCopy__c,
                  DistributorNameCopy__c,DistributorRef__c, DistributorRef__r.Street__c, DistributorRef__r.city__c, DistributorRef__r.StateProvince__c, DistributorRef__r.county__c, EmailCopy__c,FarmNameCopy__c,FiscalCodeCopy__c,Id,LastModifiedDate,Name,OwnerId,
                  PhoneCopy__c,sentMail__c,Signed__c,Status__c,SystemModstamp,TotalBagsFOC__c,TotalBags__c
                  ,VoucherCampaignRef__c, VoucherCampaignRef__r.Discount_Type__c, Price__c, PriceWithDiscount__c,  Owner.Name, DiscountRef__c FROM Voucher__c
                  WHERE id=:VoucherID]; 
                  
         voucherlineitems = [SELECT id, HybridName__c, Bags__c from voucherlineitem__c where voucherRef__c=:VoucherID];  
       
       if(voucher.status__c=='Cancelled')
       {
           cancelled='CANCELLED';
       }
      
       if(voucher.VoucherCampaignRef__r.Discount_Type__c=='In Bags')
       {
           tipo='In Bags';
           fin=' zsálc';
       }
       else
       {
           tipo='In Price';
           fin='HUF';
       }  
       
       if(voucher.priceWithDiscount__c != null )
       {
           testPrice=1234556789;  //Sustituir por priceWithDiscount cuando venga sin decimales
           String PriceString=string.valueOf((Integer)voucher.priceWithDiscount__c);
            Integer tam = PriceString.length();
            PriceToDisplay='';
            Integer incr = 0;
          for(integer i=tam; i>0; i--)
              {
                  PriceToDisplay=PriceString.substring(i-1,i)+PriceToDisplay;
                  incr=incr+1;
                  resto = math.mod(incr,3);
                  if( resto == 0)
                      {
                          PriceToDisplay=','+PriceToDisplay;
                      }
              
              }  
            
 /*for(i=0, i<tam, i++){
                        if (tam - 3 >= 0)
                          PriceToDisplay= entero.substr(i - 3, 3) + "," + numero;
                        else
                          numero = entero.substr(0, i) + "," + numero;
                        i = i - 3;
                        if (i <= 0) break; 
                      } */
                   }
        
         
       for(VoucherLineItem__c vli : voucherlineitems)
         {    
          if(vli.hybridName__c!=null)
              {
                 hybNames.add(vli.hybridName__c);
                 dataMap.put(vli,new Map<String,Decimal>{vli.hybridName__c=> vli.Bags__c});
              }
              
         } 
       
       for(String hybnam : hybNames)
       {
           for(Map<String,Decimal> map1: dataMap.values())
           {
               if(map1.get(hybNam)!=null)
               {
                bagSum=bagSum+map1.get(hybNam);
               }
           }
           hybVsBags.put(hybnam,bagSum);
           bagSum=0;
       } 
         
        }

        }
}