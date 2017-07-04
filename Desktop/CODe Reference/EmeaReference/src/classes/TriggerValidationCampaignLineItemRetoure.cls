/**
    This class validates CampaignLineItem values depending on their related retoure field values.
    Support Team
**/
public class TriggerValidationCampaignLineItemRetoure implements Triggers.Handler{
    
    public final Id cornId='a0ED000000E23kmMAB'; //=[SELECT Id FROM Division__c WHERE Name='Corn' LIMIT 1].id;
    public final Id oSRId='a0ED000000E23knMAB'; 
    
    public void handle(){   
              
        Map<String,Map<String,Decimal>> accInfo = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> accInfoCorn = new Map<String,Map<String,Decimal>>(); 
        Map<String,Map<String,Decimal>> accInfoOSR = new Map<String,Map<String,Decimal>>(); 
        Set<Id> accountIDs = new Set<Id>();
        
        if (Util.currentUser.CountryISOCode__c=='DE'){
        
        try{
            if (!trigger.isDelete){
                for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
                    if(cli.FarmRef__c <> null && cli.CampaignRef__c <> null && cli.Division__c.equalsIgnoreCase('Corn')){
                        accInfoCorn.put(String.valueOf(cli.FarmRef__c), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        accountIDs.add(cli.FarmRef__c);
                    }
                    else if (cli.FarmRef__c <> null && cli.CampaignRef__c <> null && cli.Division__c.equalsIgnoreCase('OSR')){
                        accInfoOSR.put(String.valueOf(cli.FarmRef__c), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        //accInfo.put(String.valueOf(cli.FarmRef__c)+'-'+String.valueOf(cornId), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        //accInfo.put(String.valueOf(cli.FarmRef__c)+'-'+String.valueOf(oSRId), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        accountIDs.add(cli.FarmRef__c);
                    }
                }
             }else{
                for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
                     if(cli.FarmRef__c <> null && cli.CampaignRef__c <> null && cli.CampaignRef__r.DivisionRef__r.Name.equalsIgnoreCase('Corn')){
                        accInfoCorn.put(String.valueOf(cli.FarmRef__c), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        accountIDs.add(cli.FarmRef__c);
                    }
                    else if (cli.FarmRef__c <> null && cli.CampaignRef__c <> null && cli.CampaignRef__r.DivisionRef__r.Name.equalsIgnoreCase('OSR')){
                        accInfoOSR.put(String.valueOf(cli.FarmRef__c), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        //accInfo.put(String.valueOf(cli.FarmRef__c)+'-'+String.valueOf(cornId), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        //accInfo.put(String.valueOf(cli.FarmRef__c)+'-'+String.valueOf(oSRId), new Map<String, Decimal>{'PoG'=>0,'Frue'=>0,'Rab'=>0});
                        accountIDs.add(cli.FarmRef__c);
                    }
                }
            }
            for( CampaignLineItem__c cli : [SELECT FarmRef__c, POG_Agreed__c, CampaignRef__r.DivisionRef__c FROM CampaignLineItem__c 
                    WHERE FarmRef__c IN :accInfoOSR.keyset()
                    AND (CampaignRef__r.DivisionRef__c=:oSRId )//OR CampaignRef__r.DivisionRef__c=:cornId) 
                    AND CampaignRef__r.StatusCode__c=200]){
                        (accInfoOSR.get(String.valueOf(cli.FarmRef__c))).put('PoG', cli.PoG_Agreed__c + accInfoOSR.get(String.valueOf(cli.FarmRef__c)).get('PoG'));
            }
            for( CampaignLineItem__c cli : [SELECT FarmRef__c, POG_Agreed__c, CampaignRef__r.DivisionRef__c FROM CampaignLineItem__c 
                    WHERE FarmRef__c IN :accInfoCorn.keyset()
                    AND (CampaignRef__r.DivisionRef__c=:CornId )//OR CampaignRef__r.DivisionRef__c=:cornId) 
                    AND CampaignRef__r.StatusCode__c=200]){
                        (accInfoCorn.get(String.valueOf(cli.FarmRef__c))).put('PoG', cli.PoG_Agreed__c + accInfoCorn.get(String.valueOf(cli.FarmRef__c)).get('PoG'));
            }
            for(Retoure__c ret : [SELECT Account__c, Division__c, FruekaufMenge__c, RabattMenge__c, TXT_Year__c 
                                  FROM Retoure__c 
                                  WHERE Account__c IN :accountIDs 
                                  AND TXT_Year__c =: Util.CurrentCampaign.yearV2__r.Name
                                  AND (Division__c=:cornId OR Division__c=:oSRId)]){ 
                                    system.debug('TEST1   accInfo :  '+accInfoCorn.size() );
                                    system.debug('TEST2 accountIDs :'+accountIDs);
                 if (ret.FruekaufMenge__c != null && ret.Division__c==cornId && accInfoCorn.size()!=0) (accInfoCorn.get(String.valueOf(ret.Account__c))).put('Frue',ret.FruekaufMenge__c);
                 else if (ret.FruekaufMenge__c != null && ret.Division__c==OSRId && accInfoOSR.size()!=0) (accInfoOSR.get(String.valueOf(ret.Account__c))).put('Frue',ret.FruekaufMenge__c);
                 if (ret.RabattMenge__c != null && ret.Division__c==cornId && accInfoCorn.size()!=0) (accInfoCorn.get(String.valueOf(ret.Account__c))).put('Rab',ret.RabattMenge__c);
                 else if (ret.RabattMenge__c != null && ret.Division__c==OSRId && accInfoOSR.size()!=0) (accInfoOSR.get(String.valueOf(ret.Account__c))).put('Rab',ret.RabattMenge__c);
            }
            if(!trigger.isDelete){
                for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
                    if(cli.FarmRef__c <> null && cli.Division__c.equalsIgnoreCase('Corn')){
                        if(((accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('Frue') > (accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('PoG')) ||
                           ((accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('Rab') > (accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('PoG')))
                            cli.addError(label.DE_RETOURE_POGVSMENGE);
                    } else if (cli.FarmRef__c <> null && cli.Division__c.equalsIgnoreCase('OSR'))
                        {
                        if(((accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('Frue') > (accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('PoG')) ||
                           ((accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('Rab') > (accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('PoG')))
                            cli.addError(label.DE_RETOURE_POGVSMENGE);  
                    }
                }
            }else{ for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
                    if(cli.FarmRef__c <> null && cli.Division__c.equalsIgnoreCase('Corn')){
                        if(((accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('Frue') > (accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('PoG')) ||
                           ((accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('Rab') > (accInfoCorn.get(String.valueOf(cli.FarmRef__c))).get('PoG')))
                            cli.addError(label.DE_RETOURE_POGVSMENGE);
                    } else if (cli.FarmRef__c <> null && cli.Division__c.equalsIgnoreCase('OSR'))
                        {
                        if(((accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('Frue') > (accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('PoG')) ||
                           ((accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('Rab') > (accInfoOSR.get(String.valueOf(cli.FarmRef__c))).get('PoG')))
                            cli.addError(label.DE_RETOURE_POGVSMENGE);  
                    }
                 }
                }
        } catch( Exception e ) {System.debug(e);}
       }
   }
}