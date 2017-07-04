global class BatchDistributorCLI_CleanUp implements Database.Batchable<CampaignLineItem__c>{

   global final String Query;

   global BatchDistributorCLI_CleanUp(String year,String country){
	  Id cLIRecordType = Util.recordType.get('CampaignLineItem__c:Sales');
      Id accRecordType = Util.recordType.get('Account:DistRetPoS');
      Query='Select Id, Name, OwnerId,Owner.Alias,Owner.Name, CampaignRef__c, CampaignRef__r.Name,ProductCatalogEntryRef__c,ProductRef__c,ProductRef__r.ProductSAPCode__c,FarmRef__c, FarmRef__r.Client_Code__c,Type__c,LKP_PY_CLI__c,RecordTypeId,Year__c,Division__c,country__c,Agreed__c,Forecast__c,POG__c,CreatedById,CreatedDate,CreatedBy.Name,ForecastLow__c from CampaignLineItem__c where Country__c =\'' +country+ '\' and Year__c =\'' +year+ '\' and recordtypeid =\'' +cLIRecordType+ '\' and DistributorRef__c = NULL and PoS__c = NULL and FarmRef__r.recordtypeid =\'' +accRecordType+'\'';
   }

   global List<CampaignLineItem__c> start(Database.BatchableContext BC){
      return Database.Query(Query);
   }

   global void execute(Database.BatchableContext BC, List<CampaignLineItem__c> listOfCLIs){
     	List<Id> duplicateCLIsCreatedByBatch = new List<Id>();
        Set<Id> duplicatedCLIs = new Set<Id>();
        Map<String,List<CampaignLineItem__c>> cLIsNotCreatedBySupportTeams = new Map<String,List<CampaignLineItem__c>>();
        Map<String,List<CampaignLineItem__c>> cLIsCreatedBySupportTeams = new Map<String,List<CampaignLineItem__c>>();
        Map<Id,CampaignLineItem__c> mergedCLIsToBeUpdatedMap = new Map<Id,CampaignLineItem__c>();
        Set<String> uniqueKeySet = new Set<String>();
        String uniqueKey = '';
       	
        System.debug('Total Number of CLIs Queried '+listOfCLIs.size());

        if(!listOfCLIs.isEmpty())
        {
            //Iterating through the CLIs retrieved and preparing the maps based on the createdby value.
            for(CampaignLineItem__c cli : listOfCLIs) 
            {
        
                //Farming unique key by combining OwnerId, CampaignId, Product Id, Farm Id and Type
                uniqueKey = String.valueOf(cli.OwnerId) + String.valueOf(cli.CampaignRef__c) + String.valueOf(cli.ProductRef__c) + String.valueOf(cli.FarmRef__c) + String.valueOf(cli.Type__c) + String.valueOf(cli.ProductCatalogEntryRef__c);
                System.debug('UniqueKey Framed '+ uniqueKey + ' '+cli.Id);
                uniqueKeySet.add(uniqueKey);
                
                if(cli.CreatedBy.Name.equals('Support Team') )      //Created By Support Team
                {
                    if(!cLIsCreatedBySupportTeams.ContainsKey(uniqueKey))
                    {
                        cLIsCreatedBySupportTeams.put(uniqueKey,new List<CampaignLineItem__c>{cli});
                    }
                    else
                    {
                        List<CampaignLineItem__c> tempList = cLIsCreatedBySupportTeams.get(uniquekey);
                        tempList.add(cli);
                        cLIsCreatedBySupportTeams.put(uniqueKey,tempList);
                    }
                }
                
                if(!(cli.CreatedBy.Name.equals('Support Team')))        //Created By Users
                {
                    if(!cLIsNotCreatedBySupportTeams.ContainsKey(uniqueKey))
                    {
                        cLIsNotCreatedBySupportTeams.put(uniqueKey,new List<CampaignLineItem__c>{cli});
                    }
                    else
                    {
                        List<CampaignLineItem__c> tempList = cLIsNotCreatedBySupportTeams.get(uniquekey);
                        tempList.add(cli);
                        cLIsNotCreatedBySupportTeams.put(uniqueKey,tempList);
                    }
                }
            } 
        
            for(String key: uniqueKeySet)
            {   
                //Farming unique key by combining OwnerId, CampaignId, Product Id, Farm Id and Type
                //String mapuniqueKey = String.valueOf(cli.OwnerId) + String.valueOf(cli.CampaignRef__c) + String.valueOf(cli.ProductRef__c) + String.valueOf(cli.FarmRef__c) + String.valueOf(cli.Type__c) + String.valueOf(cli.ProductCatalogEntryRef__c);
                String mapuniqueKey = key;
                Integer j=0;
                Integer mergedForecast=0;
                Integer mergedAgreed = 0;
                Integer mergedPOG = 0;
                Integer mergedForecastLow = 0;
                
                if(!cLIsCreatedBySupportTeams.isEmpty() && cLIsCreatedBySupportTeams.get(mapuniqueKey) != NULL)
                {
                    Boolean oneLoopCheck = false;
                    //Check if the unique key present in both maps.
                    for(CampaignLineItem__c cliSupport: cLIsCreatedBySupportTeams.get(mapuniqueKey))
                    {
                        if(cliSupport != NULL)
                        {
                        //If the unique key is present in both maps, check the values of Forecast, Agreed, POG, Forecast Low and LKY_PY_CLI__c should equals to zero. This condition
                        // will elimate the CLIs that are created by batch
                        if((cliSupport.Forecast__c == NULL || cliSupport.Forecast__c == 0) && (cliSupport.Agreed__c == NULL || cliSupport.Agreed__c == 0) 
                        && (cliSupport.POG__c == NULL || cliSupport.POG__c == 0) && (cliSupport.ForecastLow__c == NULL || cliSupport.ForecastLow__c == 0) && cliSupport.LKP_PY_CLI__c == NULL)
                        {
                            // adding the CLIs to deleteList that are created by batch and user hasn't introduced any Forecast,Agreed and POG values.
                            duplicatedCLIs.add(cliSupport.Id);  
                        }
                        
                        if(((cliSupport.Forecast__c != NULL || cliSupport.Forecast__c != 0) || (cliSupport.Agreed__c != NULL || cliSupport.Agreed__c != 0) 
                        || (cliSupport.POG__c != NULL || cliSupport.POG__c != 0) || (cliSupport.ForecastLow__c == NULL || cliSupport.ForecastLow__c == 0)) && cliSupport.LKP_PY_CLI__c == NULL)
                        {
                            // Merging the Forecast,Agreed and POG values.
                            mergedForecast = mergedForecast + Integer.valueOf(cliSupport.Forecast__c == NULL ? 0 : cliSupport.Forecast__c);
                            mergedAgreed = mergedAgreed + Integer.valueOf(cliSupport.Agreed__c == NULL ? 0 : cliSupport.Agreed__c);
                            mergedPOG = mergedPOG + Integer.valueOf(cliSupport.POG__c == NULL ? 0 : cliSupport.POG__c);
                            mergedForecastLow = mergedForecastLow + Integer.valueOf(cliSupport.ForecastLow__c == NULL ? 0 : cliSupport.ForecastLow__c);
                            System.debug('Support MergedValues '+(j+1)+'mergedForecast -'+mergedForecast+' mergedAgreed -'+mergedAgreed+' mergedPOG -'+mergedPOG+' mergedForecastLow -'+mergedForecastLow);
                         
                            if(!cLIsNotCreatedBySupportTeams.isEmpty() && cLIsNotCreatedBySupportTeams.get(mapuniqueKey) != NULL)
                            {
                                Integer userCreatedCLIListSize = cLIsNotCreatedBySupportTeams.get(mapuniqueKey).size();
                                Integer counter =0;
                                for(CampaignLineItem__c cliUser: cLIsNotCreatedBySupportTeams.get(mapuniqueKey))
                                {
                                    //Taking anyone of the CLI created by the user and inserting the merged values of Forecast, Agreed and POG values introduced in the CLIs created by Support Team
                                    if(cliUser != NULL && userCreatedCLIListSize > counter && counter <= 0)
                                    {
                                        if(oneLoopCheck)
                                        {
                                            cliUser.Forecast__c = Decimal.valueOf(mergedForecast);
                                            cliUser.Agreed__c = Decimal.valueOf(mergedAgreed);
                                            cliUser.POG__c = Decimal.valueOf(mergedPOG);
                                            cliUser.ForecastLow__c = Decimal.valueOf(mergedForecastLow);
                                            mergedCLIsToBeUpdatedMap.put(cliUser.Id,cliUser);
                                            break;
                                        }
                                        cliUser.Forecast__c = Decimal.valueOf(mergedForecast + Integer.valueOf(cliUser.Forecast__c == NULL ? 0 : cliUser.Forecast__c));
                                        cliUser.Agreed__c = Decimal.valueOf(mergedAgreed + Integer.valueOf(cliUser.Agreed__c == NULL ? 0 : cliUser.Agreed__c));
                                        cliUser.POG__c = Decimal.valueOf(mergedPOG + Integer.valueOf(cliUser.POG__c == NULL ? 0 : cliUser.POG__c));
                                        cliUser.ForecastLow__c = Decimal.valueOf(mergedForecastLow + Integer.valueOf(cliUser.ForecastLow__c == NULL ? 0 : cliUser.ForecastLow__c));
                                        System.debug('User MergedValues '+(j+1)+'mergedForecast -'+cliUser.Forecast__c+' mergedAgreed -'+cliUser.Agreed__c+' mergedPOG -'+cliUser.POG__c+' mergedForecastLow -'+cliUser.ForecastLow__c);
                                        //Setting updated merge values into the map
                                        mergedCLIsToBeUpdatedMap.put(cliUser.Id,cliUser);
                                        oneLoopCheck = true;
                                    }
                                    counter++;
                                }
                            }
                            // After merging we need to delete the CLI that was created by Support Team. So adding them to the delete list.
                            duplicatedCLIs.add(cliSupport.Id);
                        }
                    }
                    }
                }
            }
        }
    
        if(!mergedCLIsToBeUpdatedMap.isEmpty())
        {
            List<Database.SaveResult> SR = Database.update(mergedCLIsToBeUpdatedMap.values(),false);
            System.debug('#Save Result of Update# '+SR);
            System.debug('#MergedCLIsToBeUpdatedMap Values# '+mergedCLIsToBeUpdatedMap.values());
        }
        if(!duplicatedCLIs.isEmpty())
        {
            duplicateCLIsCreatedByBatch.addAll(duplicatedCLIs);
            Database.delete(duplicateCLIsCreatedByBatch,false);
            //System.debug('#Save Result of Delete# '+SR1);
            System.debug('#DuplicateCLIsCreatedByBatch Values# '+duplicateCLIsCreatedByBatch.size());
        }
    }

   global void finish(Database.BatchableContext BC){
       System.debug('##Finished##');
   }
}