/*
    This class validates retoure values depending on their related Account and CampaignLineItem field values
    Support Team
*/
    public class TriggerValidationRetoure implements Triggers.Handler {
        
        public final Id cornId='a0ED000000E23kmMAB'; //=[SELECT Id FROM Division__c WHERE Name='Corn' LIMIT 1].id;
        public final Id oSRId='a0ED000000E23knMAB'; 
        
         /*Obtaining the Nettosorten products that won't be used in the ZVD*/
        List<String> prodNotInZVD = label.DE_PRODUCTS_NOT_ZVD_2015.split('#',0);
       
        
        public void handle(){
        
       if(util.currentUser.countryISOCode__c=='DE'){
       
       try{
        campaign campCorn;
        campaign campOSR;
        String yearCorn; 
        String yearOSR;     
        
        campCorn =  [SELECT yearV2__r.Name From Campaign Where OwnerId=:util.currentUser.id AND isActive=:true AND DivisionRef__c=:cornId];
        campOSR =  [SELECT yearV2__r.Name From Campaign Where OwnerId=:util.currentUser.id AND isActive=:true AND DivisionRef__c=:oSRId];
        
        if(campCorn!=null)
        yearCorn=campCorn.yearv2__r.Name;
        else if(campCorn==null)
        yearCorn=util.currentyear.Name;
        
        if(campOSR!=null)
        yearOSR=campOSR.yearv2__r.Name;
        else if(campOSR==null)
        yearOSR=util.currentyear.Name;
        
            
            Map<Id, Map<Id,Decimal>> quantity = new Map<Id, Map<Id,Decimal>>();
            Map<Id,Double> accVsExt = new Map<Id,Double>();
            Map<Id,String> accVsSegm = new Map<Id,String>();
            
            for (Retoure__c ret : (List<Retoure__c>)trigger.new){
                if(ret.Division__c == cornId || ret.Division__c == oSRId ){
                    
                    if(ret.Division__c == oSRId && campOSR!=null && ret.Extrarabatt__c>Decimal.valueOf(SystemSettings__c.getValues('DE_RET_OSR_Extrarabatt_'+String.valueof(yearOSR)).Value__c))
                        ret.addError(label.DE_OSRExtrarabatt.replace('[Price]',SystemSettings__c.getValues('DE_RET_OSR_Extrarabatt_'+yearOSR).Value__c));

                    if(ret.Division__c == cornId && campCorn!=null && ret.Account__c != null && ret.Extrarabatt__c != null && ret.Extrarabatt__c>0)
                        accVsExt.put(ret.Account__c, ret.Extrarabatt__c);
                            
                    if (ret.Retoure1__c != null && ret.Retoure1__c >0 && (ret.Vorlieferant1__c == null))
                        ret.addError(label.DE_RETOURE_WITHOUT_VORL); 
                    else if (ret.Retoure2__c != null && ret.Retoure2__c >0 && (ret.Vorlieferant2__c == null))
                        ret.addError(label.DE_RETOURE_WITHOUT_VORL);
                    else if (ret.Retoure3__c != null && ret.Retoure3__c >0 && (ret.Vorlieferant3__c == null))
                        ret.addError(label.DE_RETOURE_WITHOUT_VORL); 
                        
                    if(ret.Account__c != null && ret.Division__c!=null){
                        if(quantity.containskey(ret.Account__c)) 
                            (quantity.get(ret.Account__c)).put(ret.Division__c, 0);
                        else
                            (quantity.put(ret.Account__c, new Map<Id,Double>{ret.Division__c =>0}));    
                    } 
                } 
            }
                                       
            if((accVsExt.keySet()).size()>0){
                for (Account a : [SELECT Id, DE_CustomerCornSeeds__c FROM Account WHERE Id=:accVsExt.keySet()]){
                    if(a.DE_CustomerCornSeeds__c != null && a.DE_CustomerCornSeeds__c!='-')
                        accVsSegm.put(a.id, a.DE_CustomerCornSeeds__c);
                }
                if((accVsSegm.keySet()).size()>0){
                    for (Retoure__c ret : (List<Retoure__c>)trigger.new){
                        if( ret.Account__c != null && campCorn!=null && (accVsSegm.keySet()).contains(ret.Account__c)){
                            if (accVsExt.get(ret.Account__c)>Double.valueOf(SystemSettings__c.getValues('DE_RET_EXTR_'+yearCorn+'_'+accVsSegm.get(ret.Account__c)).Value__c)) 
                            ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]',SystemSettings__c.getValues('DE_RET_EXTR_'+yearCorn+'_'+accVsSegm.get(ret.Account__c)).Value__c).replace('[S]',accVsSegm.get(ret.Account__c))));         
                            //if (accVsSegm.get(ret.Account__c)=='A' && accVsExt.get(ret.Account__c)>2.0) ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','2,00').replace('[S]','A')));         
                            //if (accVsSegm.get(ret.Account__c)=='B' && accVsExt.get(ret.Account__c)>1.5) ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','1,50').replace('[S]','B'))); 
                            //if (accVsSegm.get(ret.Account__c)=='C' && accVsExt.get(ret.Account__c)>0) ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','0,00').replace('[S]','C')));   
                        }
                        
                        else if( ret.Account__c != null && campOSR!=null && (accVsSegm.keySet()).contains(ret.Account__c)){
                            if (accVsExt.get(ret.Account__c)>Double.valueOf(SystemSettings__c.getValues('DE_RET_EXTR_'+yearOSR+'_'+accVsSegm.get(ret.Account__c)).Value__c)) 
                            ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]',SystemSettings__c.getValues('DE_RET_EXTR_'+yearOSR+'_'+accVsSegm.get(ret.Account__c)).Value__c).replace('[S]',accVsSegm.get(ret.Account__c))));          
                            //if (accVsSegm.get(ret.Account__c)=='A' && accVsExt.get(ret.Account__c)>2.0) ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','2,00').replace('[S]','A')));         
                            //if (accVsSegm.get(ret.Account__c)=='B' && accVsExt.get(ret.Account__c)>1.5) ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','1,50').replace('[S]','B'))); 
                            //if (accVsSegm.get(ret.Account__c)=='C' && accVsExt.get(ret.Account__c)>0) ret.addError((label.DE_RETOURE_SEGMENTIERUNG_MAIS.replace('[Price]','0,00').replace('[S]','C')));   
                        } 
                    
                         
                    }    
                }
            }
            if((quantity.keySet()).size()>0){
                for (CampaignLineItem__c cli : [SELECT POG_Agreed__c, FarmRef__c, CampaignRef__r.DivisionRef__c FROM CampaignLineItem__c 
                                            WHERE FarmRef__c IN :quantity.keySet() 
                                            AND ( CampaignRef__r.DivisionRef__c=:cornId OR CampaignRef__r.DivisionRef__c=:oSRId)  
                                            AND CampaignRef__r.StatusCode__c=200
                                            AND ProductRef__r.Name NOT IN :prodNotInZVD]){
                                                
                        if((quantity.keySet()).contains(cli.FarmRef__c)){
                            if((quantity.get(cli.FarmRef__c)).containsKey(cli.CampaignRef__r.DivisionRef__c))
                                (quantity.get(cli.FarmRef__c)).put(cli.CampaignRef__r.DivisionRef__c, cli.PoG_Agreed__c + (quantity.get(cli.FarmRef__c)).get(cli.CampaignRef__r.DivisionRef__c));
                            else
                                (quantity.get(cli.FarmRef__c)).put(cli.CampaignRef__r.DivisionRef__c , cli.PoG_Agreed__c);
                        } else
                             quantity.put(cli.FarmRef__c, new Map<Id,Decimal>{cli.CampaignRef__r.DivisionRef__c => cli.PoG_Agreed__c});
                }
                for (Retoure__c ret : (List<Retoure__c>)trigger.new){
                    if((ret.FruekaufMenge__c != null && ret.FruekaufMenge__c > (quantity.get(ret.Account__c)).get(ret.Division__c)) || (ret.RabattMenge__c !=null && ret.RabattMenge__c > (quantity.get(ret.Account__c)).get(ret.Division__C)))
                        ret.addError(label.DE_RETOURE_POGVSMENGE);
                }
            } 
          }catch( Exception e ) {System.debug(e);}
          }    
        }
    }