public with sharing class TriggerVoucherCalculatePoints  implements Triggers.Handler {
    
    public void handle()
    {
        List<Voucher__c> vouchersToUpdate = new List<Voucher__c>();
        Map<String,Boolean> premiumPces = new Map<String,Boolean>();
        Map<Id, List<VoucherLineItem__c>> vWithVli = new Map<Id,List<VoucherLineItem__c>>();
        
        for (VoucherLineItem__c v : (List<VoucherLineItem__c>)Trigger.new){
            
            if(vWithVli.get(v.voucherRef__c)!=null)
            vWithVli.get(v.VoucherRef__c).add(v);
            else
            vWithVli.put(v.voucherRef__c, new List<VoucherLineItem__c>{v});
        }
        
        for ( ProductCatalogEntry__c pce : [SELECT id, productRef__c,  productRef__r.Name, ProductRef__r.ProductDisplayName__c, DE_isPremium__c from ProductCatalogEntry__c where productCatalogRef__r.Name='Hungary - Corn - Sales - 2015' ]){
             premiumPces.put(pce.ProductRef__r.ProductDisplayName__c, pce.DE_isPremium__c);
        }
        
        for (Voucher__c voucher : [SELECT id, AccountRef__r.NUM_AGREED_CORN_CHARGED_CY__c, AccountRef__r.DE_ForecastCornCY__c, TotalBags__c, CreatedDate, Price__c
                            FROM Voucher__c WHERE VoucherCampaignRef__r.Name='Hungary - Corn - 2015' AND id in :vWithVli.keyset()]){  
                Integer TotalPoints = 0;
                for(VoucherLineItem__c vli : vWithVli.get(voucher.Id)){         
                  if(vli.hybridName__c!=null){
                         Integer pointspce;
                         if(premiumPces.get(vli.HybridName__c)==true)
                         pointspce=500;
                         else pointspce=0;
                         
                         TotalPoints=TotalPoints+(pointsPce*(Integer)vli.Bags__c);
                        }
                  }
               if(voucher.CreatedDate.date() < Date.newInstance(2015, 2, 7)){
                   TotalPoints=TotalPoints+(1500* (Integer)voucher.TotalBags__c);
               } 
               else if ( voucher.CreatedDate.date() < Date.newInstance(2015, 3, 3) && voucher.CreatedDate.date() >= Date.newInstance(2015, 2, 7) ){
                   TotalPoints=TotalPoints+(1000 * (Integer)voucher.TotalBags__c);
               } 
               if(voucher.TotalBags__c >= 501){
                   TotalPoints=TotalPoints+(1500 * (Integer)voucher.TotalBags__c);
               } 
               else if(voucher.TotalBags__c >= 301 && voucher.TotalBags__c <= 500  ){
                   TotalPoints=TotalPoints+(1000* (Integer)voucher.TotalBags__c);
               }
               else if(voucher.TotalBags__c>= 151 && voucher.TotalBags__c <= 300){
                   TotalPoints=TotalPoints+(500* (Integer)voucher.TotalBags__c);  }
               else{ TotalPoints=TotalPoints+(200* (Integer)voucher.TotalBags__c);  }
               
              Decimal Agreed = voucher.AccountRef__r.NUM_AGREED_CORN_CHARGED_CY__c;
               Decimal Forecast = voucher.AccountRef__r.DE_ForecastCornCY__c;
               
             if(Forecast!=null && Forecast>0){ 
               Decimal percent = (((Agreed-Forecast)*100)/Forecast).setScale(2);
               
              if(percent>-5 && percent<10)
               TotalPoints=TotalPoints+(1500 * (Integer)voucher.TotalBags__c);
             }  
             if(voucher.CreatedDate.date() < Date.newInstance(2015, 3, 3)){
              voucher.Price__c=(Integer)TotalPoints; 
             }else{
              voucher.Price__c=0;
             }
             
              vouchersToUpdate.add(voucher);            
        }
        try{
            update vouchersToUpdate;}catch(Exception e){ System.debug(e); }
    }
}