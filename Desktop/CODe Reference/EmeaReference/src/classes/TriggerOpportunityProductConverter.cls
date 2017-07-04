public without sharing class TriggerOpportunityProductConverter implements Triggers.Handler 
{            
    public void handle()
    {    
        
        double Factor = 0;
        List<id> listaid = new List<id>();
        List<id> listaidOwner = new List<id>();
        
        for(OpportunityLineItem  oppProductItem : (List<OpportunityLineItem>)Trigger.new)
        {
            listaid.add(oppProductItem.PricebookentryId);
            listaidOwner.add(oppProductItem.opportunityId);            
        }
        Map<Id,OpportunityLineItem> oldOLIs=(Map<Id,OpportunityLineItem>)Trigger.oldMap;
        Map<Id, pricebookentry> ProductsMap = new Map<Id, pricebookentry> ([SELECT Product2Id,Product2.ProductSAPCode__c, Product2.ProductCartonPerPallet__c FROM pricebookentry where id in :listaid]);
        Map<Id, Opportunity> OwnersMap = new Map<Id, Opportunity> ([SELECT id,RecordType.Name, owner.Country FROM Opportunity where id in :listaidOwner]);
        list<opportunityLineItem> upsOLIs=new list<opportunityLineItem> ();
         for(OpportunityLineItem  oppProductItem : (List<OpportunityLineItem>)Trigger.new) 
         {           
             if(trigger.isInsert)
             {
                 oppProductItem.TXT_Line_SAP_status__c=' ';
                 Opportunity master=OwnersMAp.get(oppProductItem.OpportunityId);
                 if(master.RecordType.Name=='Sales Order CP Italy') upsOLIs.addAll(generateFOClines(oppProductItem));
                 
             }
           if(ProductsMap.get(oppProductItem.pricebookentryId).Product2.ProductCartonPerPallet__c == null)
           {
               Factor = 1;
           }
           else
           {
               Factor=ProductsMap.get(oppProductItem.pricebookentryId).Product2.ProductCartonPerPallet__c;

           }
           //Variables to contemplate the lines updates 
             double oldLitres;
             double oldPalets;
             if(trigger.isUpdate)
             {
                 
                 
               oldLitres=oldOlis.get(oppProductItem.Id).NUM_Quantity_litres_CP__c;
               
               oldPalets=oldOlis.get(oppProductItem.Id).NUM_Quantity_palets_CP__c;
                 
             }
             else
             {
                 
                oldLitres=oppProductItem.Quantity;
                
                oldPalets=oppProductItem.Quantity/Factor;                 
               
             }
             
             String prodSapCode=ProductsMap.get(oppProductItem.PricebookEntryId).Product2.ProductSAPCode__c;
             
             
               if (oppProductItem.NUM_Quantity_litres_CP__c != null && (Trigger.isInsert || oppProductItem.NUM_Quantity_palets_CP__c==oldPalets   )  )           
                {        
                    system.debug('la cantidad en litros es:'+ oppProductItem.NUM_Quantity_litres_CP__c );
                    
                    oppProductItem.Quantity = oppProductItem.NUM_Quantity_litres_CP__c;
                    
                    //-----------------
                    // next line for conversion of 0.5 litres product to a bottle. 
                    // ----------------
                    
                    if( prodSapCode.contains('12153646')) oppProductItem.quantity=oppProductItem.quantity*2; 

                   
                    system.debug(oppProductItem.Quantity);
                    oppProductItem.NUM_Quantity_CP__c= oppProductItem.NUM_Quantity_litres_CP__c;
                    oppProductItem.NUM_Quantity_palets_calculated__c = (oppProductItem.Quantity / Factor).setScale(2);
                    if(OwnersMap.get(oppProductItem.opportunityId).RecordType.Name=='Sales Order CP Italy') oppProductItem.NUM_Quantity_palets_CP__c=(oppProductItem.Quantity / Factor).setScale(2);
                    
               
                    
                }else if(oppProductItem.NUM_Quantity_palets_CP__c!= null && (Trigger.isInsert || oppProductItem.NUM_Quantity_litres_CP__c==oldLitres) ) 
                {
                    system.debug('la cantidad en palets es:'+ oppProductItem.NUM_Quantity_palets_CP__c);
                    //system.debug('encuentra: '+OwnersMap.get(oppProductItem.createdbyid));
                    oppProductItem.NUM_Quantity_palets_calculated__c = oppProductItem.NUM_Quantity_palets_CP__c;
                    oppProductItem.Quantity = oppProductItem.NUM_Quantity_palets_calculated__c * Factor;
                    
                    //UPDATED on July 4th: It is not necessary due to the conversion has already been considered within the conversion factor (ProductCartonPerPallet__c)
                    //-----------------
                    // next line for conversion of 0.5 litres product to a bottle. 
                    // ----------------
                    
                    //if( prodSapCode.contains('12153646')) oppProductItem.quantity=oppProductItem.quantity*2; 
                    
                    
                    oppProductItem.NUM_Quantity_CP__c= oppProductItem.NUM_Quantity_palets_calculated__c * Factor;
                    if(OwnersMap.get(oppProductItem.opportunityId).RecordType.Name=='Sales Order CP Italy')
                    { 
                        if(oppProductItem.Type__c=='Charged') oppProductItem.NUM_Quantity_litres_CP__c= (oppProductItem.NUM_Quantity_palets_calculated__c * Factor).round(System.RoundingMode.HALF_DOWN);
                        if(oppProductItem.Type__c=='Free of Charge') oppProductItem.NUM_Quantity_litres_CP__c= (oppProductItem.NUM_Quantity_palets_calculated__c * Factor).round(System.RoundingMode.HALF_UP);
                        }
                    
                    
                    
                      
                }
               
         }
        try{
            upsert upsOlis;
        }catch(DMLException e)
        {                         
            system.debug('ERROR');            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0));
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0));            
            ApexPages.addMessage(myMsg);                                    
        }
         
          
   }
        public list<opportunityLineItem> generateFOClines (opportunityLineItem entryLine)
    {
        list<opportunityLineItem> OLIsToUps=new list<opportunityLineItem>();
        
        if(entryLine.Type__c=='Charged' && entryLine.NUM_Discount__c!=null && (entryLine.Quantity!=null || entryLine.NUM_Quantity_palets_CP__c!=null || entryLine.NUM_Quantity_litres_CP__c!=null ))
        {   
            if(entryLine.NUM_Discount__c == 100)
            {
                entryLine.Type__c='FOC';
                entryLine.NUM_Discount__c = 0;
            }
            else
            {
                opportunityLineItem generatedOLI=new opportunityLineItem();
                
                double discount=entryLine.NUM_Discount__c;
                
                generatedOLI.PricebookEntryId=entryLine.PricebookEntryId;
                generatedOlI.OpportunityId=entryLine.OpportunityId;
                generatedOLI.Type__c='Free of Charge';
                if(entryLine.NUM_Quantity_litres_CP__c!=null)
                {              
                    generatedOLI.NUM_Quantity_litres_CP__c=((discount/100)*entryLine.NUM_Quantity_litres_CP__c).round(System.RoundingMode.HALF_UP);
                    entryLine.NUM_Quantity_litres_CP__c=((1-(discount/100))*entryLine.NUM_Quantity_litres_CP__c).round(System.RoundingMode.HALF_DOWN);
                }else if (entryLine.NUM_Quantity_palets_CP__c !=null)
                {
                    generatedOLI.NUM_Quantity_palets_CP__c=(discount/100)*entryLine.NUM_Quantity_palets_CP__c;
                    entryLine.NUM_Quantity_palets_CP__c=(1-(discount/100))*entryLine.NUM_Quantity_palets_CP__c;
                }else if (entryLine.Quantity!=null )
                {
                    generatedOLI.Quantity=(discount/100)*entryLine.Quantity;
                    entryLine.Quantity=(1-(discount/100))*entryLine.Quantity;                
                }
                OLIsToUps.add(generatedOLI);
            }            
        }
        return OLIsToUps;
    }
}