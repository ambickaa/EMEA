public class TriggerOrderSumBagsPreliminary implements Triggers.Handler
{
  public static final ID PreliminaryRecordType = '012D000000037kIIAQ';	

  public void handle()
  {
  
      Set<Id> orderIDs = Trigger.newMap.keyset();
      
      List<AggregateResult> sumBags = 
            [SELECT
                  sum(Agreed__c) sumAgreed, sum(Agree_60kke__c) sumAgreed60kke, Ultrashort_Irrigation_RSA__c irrigation,
                  PreliminaryOrderRef_RSA__c
                
                FROM CampaignLineItem__c
                WHERE PreliminaryOrderRef_RSA__c != null AND PreliminaryOrderRef_RSA__c IN :orderIDs 
                GROUP By PreliminaryOrderRef_RSA__c, Ultrashort_Irrigation_RSA__c
            ];
        
          Map<ID,Double> prelimBags = new Map<ID,Double>();
          Map<ID,Double> prelimBags60kke = new Map<ID,Double>();
          Map<ID,Boolean> prelimIrrigation = new Map<ID,Boolean>();
          
          for (AggregateResult bags : sumBags){
                prelimBags.put((ID)bags.get('PreliminaryOrderRef_RSA__c'),Double.valueOf(bags.get('sumAgreed')));
                prelimBags60kke.put((ID)bags.get('PreliminaryOrderRef_RSA__c'),Double.valueOf(bags.get('sumAgreed60kke')));
                prelimIrrigation.put((ID)bags.get('PreliminaryOrderRef_RSA__c'),(Boolean)bags.get('irrigation'));                
        }
            
      for (Order__c o : (List<Order__c>)Trigger.new){
          if(prelimBags.get(o.id) != null){
            o.BagsQuantity_RSA__c = prelimBags.get(o.id);
          }
          if(prelimBags60kke.get(o.id) != null){
            o.BagsQuantity_RSA_60kke__c = prelimBags60kke.get(o.id);
          } 
          if(prelimIrrigation.get(o.id) != null){
            o.isIrrigated_RSA__c = prelimIrrigation.get(o.id);
          }  
          if(o.RecordTypeId==PreliminaryRecordType && o.BagsQuantity_RSA__c!=(Decimal)Trigger.oldMap.get(o.id).get('BagsQuantity_RSA__c')){         	
          	o.PdfSent_RSA__c=false;
          }    
      }       

  }
  
   public static testMethod void testHandle(){
        try{
            new TriggerOrderSumBagsPreliminary().handle();
        }catch(Exception e){}
    }
}