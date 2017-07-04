/*
    This class validates DE_CustomerCornSeeds__c field value depending on its related retoure values
    Support Team
*/
public class TriggerValidationAccountRetoure implements Triggers.Handler {

    public final Id cornId='a0ED000000E23kmMAB'; //=[SELECT Id FROM Division__c WHERE Name='Corn' LIMIT 1].id;
   

      public void handle(){
      
      if(util.currentUser.countryISOCode__c=='DE'){
        Map<Id,String> accVsSegm = new Map<Id,String>();
        Map<Id,Double> accVsExt = new Map<Id,Double>();
        
        Campaign camp;
        String year;
        
        try{
        camp=  [SELECT yearV2__c, yearV2__r.Name From Campaign Where OwnerId=:util.currentUser.id AND isActive=:true AND divisionRef__c=:cornID LIMIT 1];
        
        if(camp!=null)
        year=camp.yearv2__r.Name;
        else if(camp==null)
        year=util.currentyear.Name;
        
        for(Account a : (List<Account>)trigger.new){
            if (a.DE_CustomerCornSeeds__c != '-' && a.DE_CustomerCornSeeds__c != ((Account)trigger.oldMap.get(a.id)).DE_CustomerCornSeeds__c)
                accVsSegm.put(a.Id, a.DE_CustomerCornSeeds__c);         
        }
        
        if((accVsSegm.keySet()).size()>0){
            for (Retoure__c ret : [SELECT Account__c, Extrarabatt__c FROM Retoure__c  WHERE Division__c =: cornId AND Account__c IN :accVsSegm.keySet() AND TXT_year__c =: camp.yearv2__r.Name]) 
            //Util.CurrentCampaign.YearV2__r.Name])
            {
                accVsExt.put(ret.Account__c, ret.Extrarabatt__c);
            }
            
            for(Account a : (List<Account>)trigger.new){
                if (accVsExt.keySet().contains(a.id))
                    if (accVsExt.get(a.Id)>Double.valueOf(SystemSettings__c.getValues('DE_RET_EXTR_'+camp.YearV2__r.Name+'_'+accVsSegm.get(a.Id)).Value__c)) 
                        a.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]',SystemSettings__c.getValues('DE_RET_EXTR_'+Camp.YearV2__r.Name+'_'+accVsSegm.get(a.Id)).Value__c).replace('[S]',accVsSegm.get(a.Id))));           
                        
                //  if (accVsSegm.get(a.Id)=='B' && accVsExt.get(a.Id)>1.5) a.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','1,50').replace('[S]','B')));         
                //  if (accVsSegm.get(a.Id)=='C' && accVsExt.get(a.Id)>0) a.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','0,00').replace('[S]','C')));           
                                     
            }            
        }
        
      } catch( Exception e ) {System.debug(e);}
      }
    }
}