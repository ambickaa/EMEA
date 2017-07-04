global class CampaignLineItemDistributorBatchable implements Database.Batchable<sObject>,Database.Stateful 
{
    global String countryQuery;
    global String strCountry;
    global List <String> listUoM;
    global List <String> listDoc;
    global String strDiv;
    global String strCode;
    global String strOwner;
    global String startCampaign;
    global String endCampaign;
    global Boolean LastItem;
    public DateTime initialTime = datetime.now();

    global CampaignLineItemDistributorBatchable (String q, String c,  List <String> u, List <String> d, String s, String e, String o, String iniC, String endC, Boolean isLast){
        countryQuery = q;
        strCountry = c;
        listUoM = u;
        listDoc = d;
        strDiv = s;
        strCode = e;
        strOwner = o;
        startCampaign = iniC;
        endCampaign = endC;
        LastItem = isLast;
        }
    
    //global Iterable<Account> start(Database.BatchableContext theContext)
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //Deactivates Triggers on CLI
        SystemSettings__c triggersoff = SystemSettings__c.getInstance('IgnoreTriggers_Cli');
        triggersoff.Value__c = 'true';
        update triggersoff;

        return Database.getQueryLocator(countryQuery);
    }

    global void execute(Database.BatchableContext BC, List<Account> distList)
    {
        //We create two maps with unique key for each CLI with PoS and two more maps to sum up POG and put it as POGPY in another CLI
        Map<String, Decimal> cliSumAgreed = new Map <String, Decimal>();
        Map<String, Decimal> cliSumForecast = new Map <String, Decimal>();
        Map<String, Decimal> cliSumPOG = new Map <String, Decimal>();
        Map<String, Decimal> cliSumPOGPY = new Map <String, Decimal>();
        Map<String,CampaignLineItem__c> cliNewSumPOGPY = new Map <String,CampaignLineItem__c>(); 

        //Maps for CLI Fields
        Map<String,Id> cliCampManager = new Map <String,Id>();
        Map<String,Id> cliCampManagerPY = new Map <String,Id>();
        Map<Id, Id> cliPCE = new Map <Id,Id>();
        
        //Boolean for controlling updates
        Boolean ToUpdate;

        //We recover CLIs with PoS which was in scope distList 
        for(CampaignLineItem__c cliPoS : [SELECT Id, Name, FarmRef__c, Type__c, ProductCatalogEntryRef__c, PoS__c, DistributorRef__c, Agreed__c, Forecast__c, ProductRef__c, ProductRef__r.Name, CampaignRef__r.ParentId, CampaignRef__r.Parent.OwnerId, POG__c, CampaignRef__r.StatusCode__c, FRML_Validation_Dist_PoS__c
            FROM CampaignLineItem__c
            WHERE PoS__c IN :distList
            AND (CampaignRef__r.StatusCode__c = 200 OR CampaignRef__r.StatusCode__c = 300)
            AND ProductRef__r.ProductVendor__c = '001D000000vG1zp'
            AND Division__c =: strDiv
            AND (Agreed__c > 0 OR Forecast__c > 0 OR POG__c > 0)
            AND Status__c != null
            AND Status__c != 'Cancelled'
            AND CampaignRef__r.RecordTypeId = :Util.recordType.get('Campaign:Sales_camp')
            AND RecordTypeId = :Util.recordType.get('CampaignLineItem__c:Sales')]) {
            
            if(cliPoS.PoS__c != null && cliPoS.ProductRef__c != null && cliPoS.Type__c != null && cliPoS.FarmRef__c != null && !cliPoS.FRML_Validation_Dist_PoS__c){

                //Key = accountId + productId + CLI Type
                String mapKey = string.valueof(cliPoS.PoS__c) + string.valueof(cliPoS.ProductRef__c) + string.valueof(cliPoS.Type__c);

                if(cliPoS.CampaignRef__r.StatusCode__c == 200){

                    if(cliPoS.Agreed__c > 0){
                        //if the key (account,product,type) is not in the map, add it
                        if (!cliSumAgreed.containsKey(mapKey)){
                            cliSumAgreed.put(mapKey,cliPoS.Agreed__c);
                            cliCampManager.put(mapKey,cliPoS.CampaignRef__r.Parent.OwnerId);
                            cliPCE.put(cliPoS.ProductRef__c,cliPoS.ProductCatalogEntryRef__c);
                        } else {
                            //if the key (account,product,type) is already on the map, update qty
                            Decimal Agreed_PoS = cliPoS.Agreed__c + cliSumAgreed.get(mapKey);
                            cliSumAgreed.put(mapKey,Agreed_PoS);
                        }
                    }
                    if (cliPoS.Forecast__c > 0){
                        //if the key (account,product,type) is not in the map, add it
                        if (!cliSumForecast.containsKey(mapKey)){
                            cliSumForecast.put(mapKey,cliPoS.Forecast__c);
                            cliCampManager.put(mapKey,cliPoS.CampaignRef__r.Parent.OwnerId);
                            cliPCE.put(cliPoS.ProductRef__c,cliPoS.ProductCatalogEntryRef__c);
                        } else {
                            //if the key (account,product,type) is already on the map, update qty
                            Decimal Forecast_PoS = cliPoS.Forecast__c + cliSumForecast.get(mapKey);
                            cliSumForecast.put(mapKey,Forecast_PoS);
                        }
                    }
                    if (cliPoS.POG__c > 0){
                        //if the key (account,product,type) is not in the map, add it
                        if (!cliSumPOG.containsKey(mapKey)){
                            cliSumPOG.put(mapKey,cliPoS.POG__c);
                            cliCampManager.put(mapKey,cliPoS.CampaignRef__r.Parent.OwnerId);
                            cliPCE.put(cliPoS.ProductRef__c,cliPoS.ProductCatalogEntryRef__c);
                        } else {
                            //if the key (account,product,type) is already on the map, update qty
                            Decimal POG_PoS = cliPoS.POG__c + cliSumPOG.get(mapKey);
                            cliSumPOG.put(mapKey,POG_PoS);
                        }
                    }
                }

                if (cliPoS.CampaignRef__r.StatusCode__c == 300 && cliPoS.POG__c != null && cliPoS.POG__c > 0){

                        //if the key (account,product,type) is not in the map, add it
                        if (!cliSumPOGPY.containsKey(mapKey)){
                            cliSumPOGPY.put(mapKey,cliPoS.POG__c);
                            cliCampManagerPY.put(mapKey,cliPoS.CampaignRef__r.Parent.OwnerId);                                        
                        } else {
                            //if the key (account,product,type) is already on the map, update qty
                            Decimal POGPY_PoS = cliPoS.POG__c + cliSumPOGPY.get(mapKey);
                            cliSumPOGPY.put(mapKey,POGPY_PoS);
                        }
                } 
            }
        }

        //We recover CLIs which have a Distributor and check if Distributor = PoS. If it doesn't, a new register is inserted in the map
        for(CampaignLineItem__c cliDist : [SELECT Id, Name, FarmRef__c, Type__c, ProductCatalogEntryRef__c, PoS__c, DistributorRef__c, Agreed__c, Forecast__c, ProductRef__c, ProductRef__r.Name, CampaignRef__r.Parent.OwnerId, CampaignRef__r.ParentId, POG__c, CampaignRef__r.StatusCode__c
            FROM CampaignLineItem__c
            WHERE DistributorRef__c IN :distList
            AND (CampaignRef__r.StatusCode__c = 200 OR CampaignRef__r.StatusCode__c = 300)
            AND ProductRef__r.ProductVendor__c = '001D000000vG1zp'
            AND Division__c =: strDiv
            AND (Agreed__c > 0 OR Forecast__c > 0 OR POG__c > 0)
            AND Status__c != null
            AND Status__c != 'Cancelled'
            AND CampaignRef__r.RecordTypeId = :Util.recordType.get('Campaign:Sales_camp')
            AND RecordTypeId = :Util.recordType.get('CampaignLineItem__c:Sales')]) {
                
            if(cliDist.DistributorRef__c != null && cliDist.ProductRef__c != null && cliDist.Type__c != null && cliDist.FarmRef__c != null) {
                //Key = accountId + productId + CLI Type
                String cliKey = string.valueof(cliDist.DistributorRef__c) + string.valueof(cliDist.ProductRef__c) + string.valueof(cliDist.Type__c);

                if(cliDist.CampaignRef__r.StatusCode__c == 200) {
                    if(cliDist.Agreed__c > 0) {
                        //if the key (account,product,type) is not in the map, add it
                        if (!cliSumAgreed.containsKey(cliKey)){
                            cliSumAgreed.put(cliKey,cliDist.Agreed__c);
                            cliCampManager.put(cliKey,cliDist.CampaignRef__r.Parent.OwnerId);
                            cliPCE.put(cliDist.ProductRef__c,cliDist.ProductCatalogEntryRef__c);
                        } else {
                            //if the key (account,product,type) is already on the map, update qty
                            Decimal Agreed_Dist = cliDist.Agreed__c + cliSumAgreed.get(cliKey);
                            cliSumAgreed.put(cliKey,Agreed_Dist);
                        }
                    }    

                    if (cliDist.Forecast__c > 0 ){   
                        //if the key (account,product,type) is not in the map, add it                             
                        if (!cliSumForecast.containsKey(cliKey)){
                            cliSumForecast.put(cliKey,cliDist.Forecast__c); 
                            cliCampManager.put(cliKey,cliDist.CampaignRef__r.Parent.OwnerId);
                            cliPCE.put(cliDist.ProductRef__c,cliDist.ProductCatalogEntryRef__c);
                        } else {
                            //if the key (account,product,type) is already on the map, update qty
                            Decimal Forecast_Dist = cliDist.Forecast__c + cliSumForecast.get(cliKey);
                            cliSumForecast.put(cliKey,Forecast_Dist);
                        }
                    }

                    if (cliDist.POG__c > 0){
                        //if the key (account,product,type) is not in the map, add it
                        if (!cliSumPOG.containsKey(cliKey)){
                            cliSumPOG.put(cliKey,cliDist.POG__c);
                            cliCampManager.put(cliKey,cliDist.CampaignRef__r.Parent.OwnerId);
                            cliPCE.put(cliDist.ProductRef__c,cliDist.ProductCatalogEntryRef__c);
                        } else {
                            //if the key (account,product,type) is already on the map, update qty
                            Decimal POG_Dist = cliDist.POG__c + cliSumPOG.get(cliKey);
                            cliSumPOG.put(cliKey,POG_Dist);
                        }
                    }
                }

                if(cliDist.CampaignRef__r.StatusCode__c == 300 && cliDist.POG__c != null && cliDist.POG__c > 0){

                    //if the key (account,product,type) is not in the map, add it                         
                    if (!cliSumPOGPY.containsKey(cliKey)){
                        cliSumPOGPY.put(cliKey,cliDist.POG__c);
                        cliCampManagerPY.put(cliKey,cliDist.CampaignRef__r.Parent.OwnerId);                            
                    } else {
                        //if the key (account,product,type) is already on the map, update qty
                        Decimal POGPY_Dist = cliDist.POG__c + cliSumPOGPY.get(cliKey);
                        cliSumPOGPY.put(cliKey,POGPY_Dist);
                    }
                }
            }
        }
        //We recover current campaigns and sales product catalogs
        Map<Id,Id> cliActualCampaigns = new Map <Id,Id>();
        Set<Id> cliActualSalesPCM = new Set <Id>();
        for(Campaign camp : [SELECT Id, OwnerId, SalesPCMRef__c FROM Campaign WHERE CountryRef__r.Name = :strCountry AND isActive = true AND DivisionRef__r.Name =: strDiv AND RecordTypeId = :Util.recordType.get('Campaign:Sales_camp')]){
            cliActualCampaigns.put(camp.OwnerId,camp.Id);
            cliActualSalesPCM.add(camp.SalesPCMRef__c);
        }

        //We recover CY PCEs
        Map<Id,Id> cliActualPCE = new Map <Id,Id>();
        for(ProductCatalogEntry__c PCE : [SELECT Id, ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c IN :cliActualSalesPCM]){
            cliActualPCE.put(PCE.ProductRef__c,PCE.Id);
        }
        
        //We put Distributor's owners and responsible in maps
        //Map<Id, Id> cliDistOwners = new Map <Id, Id>();  
        Map<Id,Id> responsibleSTperAccs = new map<Id,Id>();
        for (Account a : distList) {
            //cliDistOwners.put(a.Id, a.Owner.IsActive ? a.OwnerId : null);
            if(a.LKP_Responsible_ST__r.IsActive)
                responsibleSTperAccs.put(a.Id, a.LKP_Responsible_ST__c);
        }

        //We create unique key for each CLI 
        Map<String, CampaignLineItem__c> cliDistMap = new Map <String, CampaignLineItem__c>();

        //Lists for updating and inserting CLIs
        List <CampaignLineItem__c> listUpdate = new List <CampaignLineItem__c>();
        List <CampaignLineItem__c> listInsert = new List <CampaignLineItem__c>();
        Map<String, CampaignLineItem__c> mapUpdate = new Map <String, CampaignLineItem__c>();        
        Map<String, CampaignLineItem__c> mapInsert = new Map <String, CampaignLineItem__c>();

        //We get the CLIs from the Distributors and create a map 
        for (CampaignLineItem__c cli : [SELECT FarmRef__c, NUM_FARM_AGREED__c, NUM_FARM_FORECAST__c, NUM_FARM_POG__c, Type__c, ProductCatalogEntryRef__c, OwnerId, CampaignRef__c, POGPY__c, ProductRef__c
            FROM CampaignLineItem__c
            WHERE FarmRef__c IN :distList
            AND CampaignRef__r.isActive = true
            AND ProductRef__r.ProductVendor__c = '001D000000vG1zp'
            AND Division__c =: strDiv
            AND Status__c != 'Cancelled'
            AND CampaignRef__r.RecordTypeId = :Util.recordType.get('Campaign:Sales_camp')
            AND RecordTypeId = :Util.recordType.get('CampaignLineItem__c:Sales')
            ORDER BY CreatedDate DESC]) {
            if(cli.FarmRef__c != null && cli.ProductRef__c != null && cli.Type__c != null)
                cliDistMap.put(string.valueof(cli.FarmRef__c) + string.valueof(cli.ProductRef__c) + string.valueof(cli.Type__c),cli);
        }

        //CLIs with Agreed with existing key are updated, ones without existing key are inserted
        for (String strFarm : cliSumAgreed.keySet()){
            for(String strDist : cliDistMap.keySet()){

                if (cliSumAgreed.containsKey(strDist)){
                    
                    ToUpdate = false;
                    
                    // Updating the NUM_FARM_AGREED__c if necessary
                    if(cliDistMap.get(strDist).NUM_FARM_AGREED__c != cliSumAgreed.get(strDist))
                    {
                        cliDistMap.get(strDist).NUM_FARM_AGREED__c = cliSumAgreed.get(strDist);
                        ToUpdate = true;
                    }
                    // Filling the PCE if empty but existent in the catalog for the related product
                    if(cliDistMap.get(strDist).ProductCatalogEntryRef__c == null && cliActualPCE.containsKey(cliDistMap.get(strDist).ProductRef__c))
                    {
                        cliDistMap.get(strDist).ProductCatalogEntryRef__c = cliActualPCE.get(cliDistMap.get(strDist).ProductRef__c);
                        ToUpdate = true;
                    }
                    if(ToUpdate)
                        mapUpdate.put(strDist,cliDistMap.get(strDist));
                }
            }
            //The key is not in the map coming from Dist CLIs, create a new CLI to be inserted
            if (strFarm != null && !cliDistMap.containsKey(strFarm)){
                String idDist = strFarm.mid(0,18);
                String idProd = strFarm.mid(18,18);
                String type = strFarm.substring(36);
                Id ownerIdAgreed;

                if(responsibleSTperAccs.containsKey(idDist)) ownerIdAgreed = responsibleSTperAccs.get(idDist);
                else ownerIdAgreed = strOwner;

                CampaignLineItem__c cliAgr = new CampaignLineItem__c (FarmRef__c = idDist, ProductCatalogEntryRef__c = cliPCE.get(idProd), Type__c = type, NUM_FARM_AGREED__c = cliSumAgreed.get(strFarm), RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'), OwnerId = ownerIdAgreed, ProductRef__c = idProd, CampaignRef__c = cliActualCampaigns.get(ownerIdAgreed));
                if(cliActualCampaigns.containsKey(ownerIdAgreed)) {
                    mapInsert.put(strFarm,cliAgr);
                }
            }
        }

        //CLIs with Forecast with existing key are updated, ones without existing key are inserted
        for (String strFarm : cliSumForecast.keySet()){
            for(String strDist : cliDistMap.keySet()){
                
                if (cliSumForecast.containsKey(strDist)){
                    
                    ToUpdate = false;
                    
                    // Updating the NUM_FARM_FORECAST__c if necessary
                    if(cliDistMap.get(strDist).NUM_FARM_FORECAST__c != cliSumForecast.get(strDist))
                    {
                        cliDistMap.get(strDist).NUM_FARM_FORECAST__c = cliSumForecast.get(strDist);
                        ToUpdate = true;
                    }
                    // Filling the PCE if empty but existent in the catalog for the related product
                    if(cliDistMap.get(strDist).ProductCatalogEntryRef__c == null && cliActualPCE.containsKey(cliDistMap.get(strDist).ProductRef__c))
                    {
                        cliDistMap.get(strDist).ProductCatalogEntryRef__c = cliActualPCE.get(cliDistMap.get(strDist).ProductRef__c);
                        ToUpdate = true;
                    }
                    if(ToUpdate)
                        mapUpdate.put(strDist,cliDistMap.get(strDist));
                }
            }
            if (strFarm != null && !cliDistMap.containsKey(strFarm)){
                //if the key is already on the map to be inserted update corresponding qty
                if(mapInsert.containsKey(strFarm)){
                    mapInsert.get(strFarm).NUM_FARM_FORECAST__c = cliSumForecast.get(strFarm);
                } else {
                    String idDistFor = strFarm.mid(0,18);
                    String idProdFor = strFarm.mid(18,18);
                    String typeFor = strFarm.substring(36);
                    Id ownerIdFcst;

                    if(responsibleSTperAccs.containsKey(idDistFor)) ownerIdFcst = responsibleSTperAccs.get(idDistFor);
                    else ownerIdFcst = strOwner;

                    CampaignLineItem__c cliFor = new CampaignLineItem__c (FarmRef__c = idDistFor, ProductCatalogEntryRef__c = cliPCE.get(idProdFor), Type__c = typeFor, NUM_FARM_FORECAST__c = cliSumForecast.get(strFarm), RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'), OwnerId = ownerIdFcst, ProductRef__c = idProdFor, CampaignRef__c = cliActualCampaigns.get(ownerIdFcst));
                    if(cliActualCampaigns.containsKey(ownerIdFcst)) {
                        mapInsert.put(strFarm,cliFor);
                    }
                }
            }
        }


        //CLIs with POG with existing key are updated, ones without existing key are inserted
        for (String strFarm : cliSumPOG.keySet()){
            for(String strDist : cliDistMap.keySet()){
                
                if (cliSumPOG.containsKey(strDist)){
                    
                    ToUpdate = false;
                    
                    // Updating the NUM_FARM_POG__c if necessary
                    if(cliDistMap.get(strDist).NUM_FARM_POG__c != cliSumPOG.get(strDist))
                    {
                        cliDistMap.get(strDist).NUM_FARM_POG__c = cliSumPOG.get(strDist);
                        ToUpdate = true;
                    }
                    // Filling the PCE if empty but existent in the catalog for the related product
                    if(cliDistMap.get(strDist).ProductCatalogEntryRef__c == null && cliActualPCE.containsKey(cliDistMap.get(strDist).ProductRef__c))
                    {
                        cliDistMap.get(strDist).ProductCatalogEntryRef__c = cliActualPCE.get(cliDistMap.get(strDist).ProductRef__c);
                        ToUpdate = true;
                    }
                    if(ToUpdate)
                        mapUpdate.put(strDist,cliDistMap.get(strDist));
                }
            }
            if (strFarm != null && !cliDistMap.containsKey(strFarm)){
                //if the key is already on the map to be inserted update corresponding qty
                if(mapInsert.containsKey(strFarm)){
                    mapInsert.get(strFarm).NUM_FARM_POG__c = cliSumPOG.get(strFarm);
                } else {
                    String idDistPOG = strFarm.mid(0,18);
                    String idProdPOG = strFarm.mid(18,18);
                    String typePOG = strFarm.substring(36);
                    Id ownerIdFcst;

                    if(responsibleSTperAccs.containsKey(idDistPOG)) ownerIdFcst = responsibleSTperAccs.get(idDistPOG);
                    else ownerIdFcst = strOwner;

                    CampaignLineItem__c cliFor = new CampaignLineItem__c (FarmRef__c = idDistPOG, ProductCatalogEntryRef__c = cliPCE.get(idProdPOG), Type__c = typePOG, NUM_FARM_POG__c = cliSumPOG.get(strFarm), RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'), OwnerId = ownerIdFcst, ProductRef__c = idProdPOG, CampaignRef__c = cliActualCampaigns.get(ownerIdFcst));
                    if(cliActualCampaigns.containsKey(ownerIdFcst)) {
                        mapInsert.put(strFarm,cliFor);
                    }
                }
            }
        }

        //CLIs with POGPY with same key are updated, ones that dont are inserted
        for (String strFarm : cliSumPOGPY.keySet()){

            String idDistPY = strFarm.mid(0,18);
            String idProdPY = strFarm.mid(18,18);
            String typePY = strFarm.substring(36);
            Id ownerIdPOGPY;

            if(responsibleSTperAccs.containsKey(idDistPY)) ownerIdPOGPY = responsibleSTperAccs.get(idDistPY);
            else ownerIdPOGPY = strOwner;

            CampaignLineItem__c cliPOGPY = new CampaignLineItem__c (FarmRef__c = idDistPY, ProductCatalogEntryRef__c = cliActualPCE.get(idProdPY), Type__c = typePY, POGPY__c = cliSumPOGPY.get(strFarm), RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales'), OwnerId = ownerIdPOGPY, ProductRef__c = idProdPY, CampaignRef__c = cliActualCampaigns.get(ownerIdPOGPY));

            String newKey = idDistPY + string.valueof(cliPOGPY.ProductRef__c) + typePY;
            if(cliActualCampaigns.containsKey(ownerIdPOGPY))
                cliNewSumPOGPY.put(newKey,cliPOGPY);
        }

        for (String strFarm : cliNewSumPOGPY.keySet()){
            for(String strDist : cliDistMap.keySet()){
                
                if (cliNewSumPOGPY.containsKey(strDist)){
                    
                    ToUpdate = false;

                    // Updating the POGPY__c if necessary
                    if(cliDistMap.get(strDist).POGPY__c != cliNewSumPOGPY.get(strDist).POGPY__c)
                    {
                        cliDistMap.get(strDist).POGPY__c = cliNewSumPOGPY.get(strDist).POGPY__c;
                        ToUpdate = true;
                    }                    
                    // Filling the PCE if empty but existent in the catalog for the related product
                    if(cliDistMap.get(strDist).ProductCatalogEntryRef__c == null && cliActualPCE.containsKey(cliDistMap.get(strDist).ProductRef__c))
                    {
                        cliDistMap.get(strDist).ProductCatalogEntryRef__c = cliActualPCE.get(cliDistMap.get(strDist).ProductRef__c);
                        ToUpdate = true;
                    }
                    if(ToUpdate)
                        mapUpdate.put(strDist,cliDistMap.get(strDist));
                }
            }
            if (strFarm != null && !cliDistMap.containsKey(strFarm)){
                if(mapInsert.containsKey(strFarm)){
                    mapInsert.get(strFarm).POGPY__c = cliNewSumPOGPY.get(strFarm).POGPY__c;
                } else {
                    mapInsert.put(strFarm,cliNewSumPOGPY.get(strFarm));
                }
                system.debug('CLI to insert POGPY owners: ' + mapInsert.get(strFarm).OwnerId);
            }
        }

        //We reset values to 0 for CLIs in Distributor which don't have a CLI in Farm with same PCE and Type and put it in update list
        for(String strDist :cliDistMap.keySet()){
          CampaignLineItem__c cliToReset = cliDistMap.get(strDist);
          ToUpdate = false;
            if (!cliSumForecast.containsKey(strDist))
            {                   
                if(cliToReset.NUM_FARM_FORECAST__c != null)
                    ToUpdate = true;

                cliToReset.NUM_FARM_FORECAST__c = null;

            }
            if (!cliSumAgreed.containsKey(strDist))
            {
                if(cliToReset.NUM_FARM_AGREED__c != null)
                    ToUpdate = true;

                cliToReset.NUM_FARM_AGREED__c = null;
                
            }
            if (!cliSumPOG.containsKey(strDist))
            {
                if(cliToReset.NUM_FARM_POG__c != null)
                    ToUpdate = true;

                cliToReset.NUM_FARM_POG__c = null;
                
            }
            if (!cliNewSumPOGPY.containsKey(strDist))
            {
                if(cliToReset.POGPY__c != null)
                    ToUpdate = true;
                
                cliToReset.POGPY__c = null;  
                    
            }
            if(ToUpdate)
              mapUpdate.put(strDist, cliToReset);
        }

        //Update list
        for (String updateKey : mapUpdate.keySet()){
            listUpdate.add(mapUpdate.get(updateKey));
        }   
        
        if(listUpdate.size()>0)
        update listUpdate;

        //Insert list
        for (String insertKey : mapInsert.keySet()){
            listInsert.add(mapInsert.get(insertKey));
        }
        if (listInsert.size()>0)
        insert listInsert;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.

        // Send email to userEmail indicating if the process did not finish correctly
        if (a.Status == 'Failed' || a.NumberOfErrors>0)
        {
            //If the job fails, reactivates Triggers on CLI. Otherwise it will be reactivated within the second batch
            if (LastItem==true){
                SystemSettings__c triggersoff = SystemSettings__c.getInstance('IgnoreTriggers_Cli');
                triggersoff.Value__c = 'false';
                Update triggersoff;
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {string.valueof(Util.currentUser.Email)});
            mail.setSubject('POGPY, Farm Forecast and Farm Agreed Update Process for ' + strCountry + ' has failed.');
            mail.setPlainTextBody ('The batch Apex job for '+ strCountry + ' processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + '\n \r Job Id that failed: ' + a.Id + '\n \r Description: ' + a.ExtendedStatus);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        //Send email to userEmail indicating if the process finished correctly        
        } else {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {string.valueof(Util.currentUser.Email)});
            mail.setSenderDisplayName('POGPY, Farm Forecast and Farm Agreed Update Process for ' + strCountry + ' has been successful');
            mail.setSubject('POGPY, Farm Forecast and Farm Agreed Update Processing');

            mail.setPlainTextBody('CampaignLineItemDistributorBatchable has been executed for Distributors from: ' + strCountry + '\n \r' + 'The process was initiated on: ' + string.valueof(initialTime) + '\n' +'The process was finished on: ' + string.valueof(datetime.now()));       
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            Integer batchSize = Label.Dist_AP_BatchSize != null ? Integer.valueOf(Label.Dist_AP_BatchSize) : 500;
            //Execute ORD and INV batch when this batch has finished correctly
            Id batchORDINVtoCLI = Database.executeBatch (new Batch_ORD_INV_toCampaignLineItem(countryQuery,strCountry,listUoM,listDoc,strDiv,strCode,strOwner,startCampaign,endCampaign, LastItem),batchSize);  
        }
    }   
}