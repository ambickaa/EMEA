public with sharing  class VouchersGeneratorController{
    
    public Voucher__c voucher  {get;set;}  
    public List<VoucherLineItem__c> voucherLineItems  {get;set;}
    public String CreatedDate {get;set;}  
    public Boolean HDdisplay {get;set;}
    public Boolean CLdisplay {get;set;}
    public Boolean MTdisplay {get;set;}
    public Boolean YGdisplay {get;set;}
    public Account acc {get;set;}

    public Integer Hdrows {get;set;}
    public Integer CLrows {get;set;}
    public Integer MTrows {get;set;}
    public Integer YGrows {get;set;}
    
    public double sumIMM {get;set;}
    public double sumIMID {get; set;}
    public double sumIMP {get;set;}
    public double sumIMIR {get;set;}
    public double sumIMA {get;set;}
    
    public double sumEXS {get;set;}
    public double sumEXC {get;set;}
    public double sumEXP {get;set;}
    public double sumEXT {get;set;}
    
    
    public Integer longit {get;set;}
    public Integer longitname {get;set;}
    public Integer longitdis {get;set;}
    public Integer longitown {get;set;}
    public Integer longimail {get;set;}
    
    public Integer tamletra {get;set;}
    public Integer tamletranom {get;set;}
    public Integer tamletradis {get;set;}
    public Integer tamletraown {get;set;}
    public Integer tamletramail {get;set;}
    
    public Integer totalBagsOSR {get;set;}
    
    public String aviso {get;set;}
    public String centrado {get;set;}
    public String textoprueba {get;set;}
    public String jud {get;set;}
    public String loc {get;set;}
    
    
    public Map<String,Map<String,String>> HDMap{ get; set; }
    public Set<String> getHDMapSet (){ return HDMap.keySet();}

    public Map<String,Map<String,String>> CLMap{ get; set; }
    public Set<String> getCLMapSet (){ return CLMap.keySet();}

    public Map<String,Map<String,String>> MTMap{ get; set; }
    public Set<String> getMTMapSet (){ return MTMap.keySet();}
    
    public Map<String,Map<String,String>> YGMap{ get; set; }
    public Set<String> getYGMapSet (){ return YGMap.keySet();}

    public Map<Integer,Map<String,String>> Discounts { get; set; }
    
    public Map<String,String> OSRMap {get; set;}
    public Set<String> getOSRMapSet (){return OSRMap.keyset();}
    

    private ApexPages.StandardController controller;
    
    public VouchersGeneratorController(ApexPages.StandardController controller) {
        this.controller = controller;
        
        ID VoucherID = controller.getRecord().ID;
        
        voucher= new Voucher__c ();
        voucherLineItems = new List<VoucherLineItem__c>();
        CreatedDate='';
        List<String> groups= new List<String>{'HD','MAXTECH','CLASIC','YIELDGARD'};
        HDMap=new Map<String,Map<String,String>>();   
        MTMap=new Map<String,Map<String,String>>();   
        CLMap=new Map<String,Map<String,String>>();   
        YGMap=new Map<String,Map<String,String>>();   
        Discounts=new Map<Integer,Map<String,String>>();   
        Hdrows=0;
        CLrows=0;
        MTrows=0;
        YGrows=0;
        
        sumIMM=0;
        sumIMID=0;
        sumIMP=0;
        sumIMIR=0;
        sumIMA=0;
        sumEXS=0;
        sumEXC=0;
        sumEXP=0;
        sumEXT=0;
        acc= new Account ();
              
        if(VoucherID!=null) 
        {  
      
         voucher=[SELECT AccountRef__c,AddressCopy__c,CampaignRef__c,CancelReason__c,CreatedById,CreatedDate,DiscountCopy__c,
                  DistributorNameCopy__c,DistributorRef__c,EmailCopy__c,FarmNameCopy__c,FiscalCodeCopy__c,Id,LastModifiedDate,Name,OwnerId,
                  PhoneCopy__c,sentMail__c,Signed__c,Status__c,SystemModstamp,TotalBagsFOC__c,TotalBags__c
                  ,VoucherCampaignRef__c, Owner.Name, DiscountRef__c FROM Voucher__c
                  WHERE id=:VoucherID];
                  
         if(Voucher.AccountRef__c!=null)
             {
                 acc = [SELECT County__c, City__c FROM Account WHERE id=:voucher.AccountRef__c];
                 jud = acc.county__c;
                 loc = acc.city__c;
             }
        
         Integer counter = 1;
                  
         for(Discount__c d: [SELECT Id,PercentIncreaseInBags__c,MaxBags__c,MinBags__c,DiscountInPrice__c from Discount__c where VoucherCampaignRef__c=:voucher.VoucherCampaignRef__c ORDER BY MinBags__c ASC ])         
         {
            if(Discounts.get(counter)==null)
            {
                Discounts.put(counter, new Map<String,String>{'PercentIncreaseInBags'=> String.valueof(d.PercentIncreaseInBags__c) , 'MaxBags' => String.valueof(d.MaxBags__c), 'MinBags' => String.valueOf(d.MinBags__c), 'DiscountInPrice' => String.valueOf(d.DiscountInPrice__c),'isUsed' => (d.ID==voucher.DiscountRef__c?'true':'false')});                                               
                counter++;
            }   
         }      
         
         if(voucher.TotalBags__c!=null && voucher.TotalBagsFOC__c!=null)
         {
          totalBagsOSR=(Integer)voucher.TotalBags__c+(Integer)voucher.TotalBagsFOC__c;  
         }
         
         
         
         if(voucher.Status__C!=null)
         {
                if (voucher.Status__c.equalsignorecase('cancelled'))
                {
                        aviso='CANCELLED';
                }
                else
                {
                        aviso=' ';
                }
         }
         
         if(voucher.AddressCopy__c!=null)
             {
                longit = voucher.AddressCopy__c.length();
                if (longit<90)
                    {
                        tamletra=14;
                    }
                else if (longit<150)
                    {
                        tamletra=12;
                    }  
                else if (longit<245)
                    {
                        tamletra=10;
                    } 
                 else
                     {
                         tamletra=9;
                     }
            
             }

           
          if(voucher.FarmNameCopy__c!=null)
             {
                longitname = voucher.FarmNameCopy__c.length();
                if (longitname<50)
                    {
                        tamletranom=14;
                    }
                else if (longitname<60)
                    {
                        tamletranom=12;
                    }  
                else 
                    {
                        tamletranom=11;
                    } 
             } 
           
          if(voucher.DistributorNameCopy__c!=null)
            {
                longitdis = voucher.DistributorNameCopy__c.length();
                if (longitdis<15)
                    {
                         centrado='display: table-cell; vertical-align: middle;';
                         tamletradis=18;
                    }
                else if (longitdis<33)
                    {
                        centrado=' ';
                        tamletradis=16;
                    }  
                else if (longitdis<63)
                    {
                        centrado=' ';
                        tamletradis=12;
                    } 
                else
                    {
                       centrado=' ';
                       tamletradis=10;
                    } 
             } 

         
         
           if(voucher.Owner.Name!=null)
                {
                    longitown = voucher.Owner.Name.length();
                    if (longitown<15)
                        {
                            tamletraown=18;
                        }
                    else if (longitown<33)
                        {
                            tamletraown=16;
                        }  
                    else if (longitown<63)
                        {
                            tamletraown=12;
                        } 
                    else
                        {
                           tamletraown=10;
                        } 
                 } 
         
         
         if(voucher.EmailCopy__c!=null)
         {
            longimail = voucher.EmailCopy__c.length();
            if (longimail>18 && longimail<22)
                {
                    tamletramail=10;
                }
            else if (longimail>15 && longimail<22)
                {
                    tamletramail=11;
                }  
            else if (longimail>12 && longimail<22 )
                {
                    tamletramail=14;
                } 
            else
                {
                   tamletramail=15;
                } 
         } 
         
         
         
         
         if(voucher.CreatedDate!=null)
         {
            CreatedDate=(String)(voucher.CreatedDate).format('YYYY / MM / dd');
         }         
    
         voucherLineItems = [SELECT Agreed__c,Bags__c,CampaignLineItemRef__c,CreatedDate,
                         FAO__c,HybridGroup__c,HybridName__c,Id,LastModifiedDate,Name,OwnerId,
                         Price__c,ProductName__c,SystemModstamp,VoucherRef__c, VoucherRef__r.CampaignRef__r.DivisionRef__r.Name,
                         campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c FROM VoucherLineItem__c
                         WHERE VoucherRef__c=:VoucherID ];    
         }        
       
         for(VoucherLineItem__c vli : voucherLineItems)
         {
             if(vli.HybridGroup__c!=null)
             {
                 if(vli.HybridGroup__c.equalsIgnoreCase('HD'))
                 {
                    if(HDMap.get(vli.ID)==null)
                    {
                        HDMap.put(vli.ID, new Map<String,String>{'HGroup'=> 'HD', 'HName' => vli.HybridName__c, 'FAO' => String.valueOf(vli.FAO__c), 'Price' => String.valueOf(vli.Price__c), 'Bags' => String.valueOf(vli.Bags__c)});
                                                
                    }                                      
                     HDdisplay =true;                 
                     Hdrows=Hdrows +1;                 
                 }                 
                 else if(vli.HybridGroup__c.equalsIgnoreCase('MAXTECH'))
                 {
                    if(MTMap.get(vli.ID)==null)
                    {
                        MTMap.put(vli.ID, new Map<String,String>{'HGroup'=> 'MAXTECH', 'HName' => vli.HybridName__c, 'FAO' => String.valueOf(vli.FAO__c), 'Price' => String.valueOf(vli.Price__c), 'Bags' => String.valueOf(vli.Bags__c)});
                                                
                    } 
                     MTdisplay=true;
                     MTrows=MTrows+1; 
                 }
                  else if(vli.HybridGroup__c.equalsIgnoreCase('CLASIC'))
                 {
                    if(CLMap.get(vli.ID)==null)
                    {
                        CLMap.put(vli.ID, new Map<String,String>{'HGroup'=> 'CLASIC', 'HName' => vli.HybridName__c, 'FAO' => String.valueOf(vli.FAO__c), 'Price' => String.valueOf(vli.Price__c), 'Bags' => String.valueOf(vli.Bags__c)});
                                                
                    } 
                     CLdisplay=true;
                     CLrows=CLrows+1;
                 }
                 
                  else if(vli.HybridGroup__c.equalsIgnoreCase('YIELDGARD'))
                 {
                    if(YGMap.get(vli.ID)==null)
                    {
                        YGMap.put(vli.ID, new Map<String,String>{'HGroup'=> 'YIELDGARD', 'HName' => vli.HybridName__c, 'FAO' => String.valueOf(vli.FAO__c), 'Price' => String.valueOf(vli.Price__c), 'Bags' => String.valueOf(vli.Bags__c)});
                                                
                    } 
                     YGdisplay=true;
                     YGrows=YGrows+1;
                     

                 }
             }
             
         if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c!=null){
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK IMMINENT CL'))
             sumIMM = sumIMM + vli.Bags__c;
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK IMIDO CL'))
             sumIMID = sumIMID + vli.Bags__c;
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK IMPRESSION CL'))
             sumIMP = sumIMP + vli.Bags__c; 
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK IMIRON CL'))
             sumIMIR = sumIMIR + vli.Bags__c;
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK IMAGINE CL'))
             sumIMA = sumIMA + vli.Bags__c;
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK EXSTORM'))
             sumEXS = sumEXS + vli.Bags__c;
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK EXCELLIUM'))
             sumEXC = sumEXC + vli.Bags__c;
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK EXPOWER'))
             sumEXP = sumEXP + vli.Bags__c;
             if(vli.campaignLineItemRef__r.ProductRef__r.ProductDisplayName__c.equalsIgnoreCase('DK EXTEC'))
             sumEXT = sumEXT + vli.Bags__c;
           }                     
     /*     
     
      if(vli.HybridName__c!=null){
             if(vli.HybridName__c.equalsIgnoreCase('DK IMMINENT CL'))
             sumIMM = sumIMM + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('DK IMIDO CL'))
             sumIMID = sumIMID + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('WRH400'))
             sumIMP = sumIMP + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('DK IMIRON CL'))
             sumIMIR = sumIMIR + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('DK IMAGINE CL'))
             sumIMA = sumIMA + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('DK EXSTORM'))
             sumEXS = sumEXS + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('DK EXCELLIUM'))
             sumEXC = sumEXC + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('DK EXPOWER'))
             sumEXP = sumEXP + vli.Bags__c;
             if(vli.HybridName__c.equalsIgnoreCase('DK EXTEC'))
             sumEXT = sumEXT + vli.Bags__c;
           }                                           
               */          
         
         }

system.debug('tam: '+HDMap);
system.debug('tam: '+MTMap);
system.debug('tam: '+CLMap);
system.debug('tam: '+YGMap);
system.debug('discounts: '+Discounts);
     }

    


}