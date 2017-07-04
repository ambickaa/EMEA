@RestResource(urlMapping='/sendLogicalEntity/FieldCheckUp/*')
global without sharing class REST_SendLogicalEntityFieldCheckUp{
         
    private static Map<Integer, FieldCheckUp__c> fieldCheckUpToInsert = new Map<Integer, FieldCheckUp__c>();
    private static List<FieldCheckUp__c> fieldCheckUpToUpdate = new List<FieldCheckUp__c>();
    private static List<FieldCheckUp__c> fieldCheckUpToDelete = new List<FieldCheckUp__c>();    
    
    private static Map<Integer, FCU_External_Conditions__c> externalConditionsToInsert = new Map<Integer, FCU_External_Conditions__c>();
    private static List<FCU_External_Conditions__c> externalConditionsToUpdate = new List<FCU_External_Conditions__c>();
    private static List<FCU_External_Conditions__c> externalConditionsToDelete = new List<FCU_External_Conditions__c>();  
    
    private static Map<Integer, FCU_Symptoms_Causes__c> symptomsCausesToInsert = new Map<Integer, FCU_Symptoms_Causes__c>();
    private static List<FCU_Symptoms_Causes__c> symptomsCausesToUpdate = new List<FCU_Symptoms_Causes__c>();
    private static List<FCU_Symptoms_Causes__c> symptomsCausesToDelete = new List<FCU_Symptoms_Causes__c>();
    
    private static Map<Integer, VisualRatingProduct__c> visualRatingsProductToInsert = new Map<Integer, VisualRatingProduct__c>();
    private static List<VisualRatingProduct__c> visualRatingsProductToUpdate = new List<VisualRatingProduct__c>();
    private static List<VisualRatingProduct__c> visualRatingsProductToDelete = new List<VisualRatingProduct__c>();
    
    private static Map<Integer, FCU_Visual_Rating__c> visualRatingsToInsert = new Map<Integer, FCU_Visual_Rating__c>();
    private static List<FCU_Visual_Rating__c> visualRatingsToUpdate = new List<FCU_Visual_Rating__c>();
    private static List<FCU_Visual_Rating__c> visualRatingsToDelete = new List<FCU_Visual_Rating__c>();
    
    private static Map<Integer, FCU_Observations__c> observationsToInsert = new Map<Integer, FCU_Observations__c>();
    private static List<FCU_Observations__c> observationsToUpdate = new List<FCU_Observations__c>();
    private static List<FCU_Observations__c> observationsToDelete = new List<FCU_Observations__c>();

    @HttpPost
    global static REST_FieldCheckUpObject sendFieldCheckUp(REST_FieldCheckUpObject paramInfo)
    {
        String request = System.JSON.serializePretty(paramInfo);
        REST_FieldCheckUpObject returned = paramInfo;
        
        /* BEGIN - Timestamp checking */
         
        Set<Id> fieldCheckUpIdToCheck = new Set<Id>();  
        Set<Id> externalConditionsIdToCheck = new Set<Id>();
        Set<Id> symptomsCausesIdToCheck =  new Set<Id>();
        Set<Id> visualRatingsProductIdToCheck = new Set<Id>();
        Set<Id> visualRatingsIdToCheck = new Set<Id>();
        Set<Id> observationsIdToCheck = new Set<Id>();
        String errorDetailTimestamp = '';
        String errorDetailDeleted = '';
        String fieldId = '';
        String stageId = '';
        //REST_FieldCheckUpObject       
        if(!'Insert'.equalsIgnoreCase(returned.action))
        {
            fieldCheckUpIdToCheck.add(returned.fieldcheckup.Id);
            fieldId = returned.fieldcheckup.LKP_Field__c;
            stageId = returned.fieldcheckup.LKP_SM_Stage__c;            
        }
        /*List<FieldCheckUp__c> fcuInformation = [SELECT
                                LKP_Field__r.name, LKP_Account__r.name, LKP_SM_Stage__r.name, Name
                                FROM
                                FieldCheckUp__c
                                WHERE id IN: fieldCheckUpIdToCheck
                                ];
                                */
        List<Field__c> fieldInformation = [SELECT
                                    name, LKP_Acreage__r.AcrFarmRef__r.name
                                    FROM
                                    Field__c
                                    WHERE id =: fieldId 
                                ];
        List<SM_Stage__c> stageInformation = [SELECT
                                    name
                                    FROM
                                    SM_Stage__c
                                    WHERE id =: stageId 
                                ];
        if(fieldInformation.size()>0 && stageInformation.size()>0 )                                                                         
        {
            errorDetailTimestamp = 'The next Field Check Ups have been overwritten because of online changes:'+'\n\nAccount: '+fieldInformation[0].LKP_Acreage__r.AcrFarmRef__r.name+'  Field: '+fieldInformation[0].name +'  Stage: '+ stageInformation[0].name;
            errorDetailDeleted = 'The next Field Check Ups have been deleted from the online:'+'\n\nAccount: '+fieldInformation[0].LKP_Acreage__r.AcrFarmRef__r.name+'  Field: '+fieldInformation[0].name +'  Stage: '+ stageInformation[0].name;
        }

        //REST_ExternalConditionsObject
        for(REST_ExternalConditionsObject eco: returned.fcuexternalconditions)
        {
            if(!'Insert'.equalsIgnoreCase(eco.action)) externalConditionsIdToCheck.add(eco.fcuexternalcondition.Id);
        }
        //REST_SymptomsCausesObject
        for(REST_SymptomsCausesObject sco: returned.fcusymptomscauses)
        {
            if(!'Insert'.equalsIgnoreCase(sco.action)) symptomsCausesIdToCheck.add(sco.fcusymptomCause.Id);
        }
        //REST_VisualRatingProduct
        for(REST_VisualRatingsProductObject vrp: returned.visualratingsproduct)
        {
            if(!'Insert'.equalsIgnoreCase(vrp.action)) visualRatingsProductIdToCheck.add(vrp.visualratingproduct.Id);
        }        
        //REST_VisualRatingsObject 
        for(REST_VisualRatingsObject vro: returned.fcuvisualratings)
        {
            if(!'Insert'.equalsIgnoreCase(vro.action)) visualRatingsIdToCheck.add(vro.fcuvisualrating.Id);
        }
        //REST_ObservationsObject 
        for(REST_ObservationsObject o: returned.fcuobservations)
        {
            if(!'Insert'.equalsIgnoreCase(o.action)) observationsIdToCheck.add(o.fcuobservation.Id);
        }
        
        //Check REST_FieldCheckUpObject
        Map<Id, FieldCheckUp__c> fieldCheckUpToCheck = new Map<Id, FieldCheckUp__c>([SELECT LastModifiedDate FROM FieldCheckUp__c WHERE ID IN :fieldCheckUpIdToCheck]);
        boolean error = false;  
        if(!'Insert'.equalsIgnoreCase(returned.action))
        { 
            if(fieldCheckUpToCheck.get(returned.fieldcheckup.id) == null)
            {   
                error =  true;         
                returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                returned.statusDescription = errorDetailDeleted;
            } 
            else if(returned.LastModifiedDate != fieldCheckUpToCheck.get(returned.fieldcheckup.Id).LastModifiedDate)
            {
                error =  true;
                returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                returned.statusDescription = errorDetailTimestamp;
            }
            if('Update'.equalsIgnoreCase(returned.action))
            {
                fieldCheckUpToUpdate.add(returned.fieldcheckup);
            } 
            else
            {
                if(FieldCheckUp__c.SObjectType.getDescribe().isDeletable())
                {
                    fieldCheckUpToDelete.add(returned.fieldcheckup);
                }
                else
                {
                    error =  true;
                    returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                    returned.statusDescription = getErrorDescription(returned.statusCode);
                }
            } 
        }
        else fieldCheckUpToInsert.put(Integer.valueOf(returned.fieldcheckup.idDevice__c), returned.fieldcheckup);           
       
        //Check REST_ExternalConditionsObject
        Map<Id, FCU_External_Conditions__c> externalConditionsToCheck = new Map<Id, FCU_External_Conditions__c>([SELECT LastModifiedDate, LKP_ExternalConditions__c FROM FCU_External_Conditions__c WHERE Id IN :externalConditionsIdToCheck]);
        
        for(REST_ExternalConditionsObject eco: returned.fcuexternalconditions)
        {
            if(!'Insert'.equalsIgnoreCase(eco.action))            
            {
                if(externalConditionsToCheck.get(eco.fcuexternalcondition.Id) == null)
                {
                   // returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                   // returned.statusDescription = getErrorDescription(returned.statusCode);
                   error =  true;
                   eco.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                   //returned.statusCode = ERROR_NOT_PROCESSED ;
                   eco.statusDescription = errorDetailDeleted;                    
                }
                else if(eco.LastModifiedDate != externalConditionsToCheck.get(eco.fcuexternalcondition.Id).LastModifiedDate)
                {
                    error =  true;
                    //returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    eco.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    eco.statusDescription = errorDetailTimestamp;
                }
                if('Update'.equalsIgnoreCase(eco.action))
                {
                    externalConditionsToUpdate.add(eco.fcuexternalcondition);
                }
                else
                {
                    if(FCU_External_Conditions__c.SObjectType.getDescribe().isDeletable())
                    {
                        externalConditionsToDelete.add(eco.fcuexternalcondition);
                    }
                    else
                    {
                        error = true;
                        //returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        //returned.statusDescription = getErrorDescription(returned.statusCode);
                        eco.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        eco.statusDescription = getErrorDescription(eco.statusCode);
                    }
                }
            }
            else  externalConditionsToInsert.put(Integer.ValueOf(eco.fcuexternalcondition.IdDevice__c), eco.fcuexternalcondition);           
        }
        
        //Check REST_SymptomsCausesObject
        Map<Id, FCU_Symptoms_Causes__c> symptomsCausesToCheck = new Map<Id, FCU_Symptoms_Causes__c>([SELECT LastModifiedDate, LKP_SymptomsCauses__c FROM FCU_Symptoms_Causes__c WHERE Id IN :symptomsCausesIdToCheck]);
        for(REST_SymptomsCausesObject sco: returned.fcusymptomscauses)
        {
            if(!'Insert'.equalsIgnoreCase(sco.action))            
            {
                if(symptomsCausesToCheck.get(sco.fcusymptomcause.Id) == null)
                {                   
                   error = true;
                   // returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                   sco.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                   sco.statusDescription = errorDetailDeleted;
                   //returned.statusCode = ERROR_NOT_PROCESSED ;
                    
                }
                else if(sco.LastModifiedDate != symptomsCausesToCheck.get(sco.fcusymptomcause.Id).LastModifiedDate)
                {
                    error = true;
                    //returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    sco.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    sco.statusDescription = errorDetailTimestamp;
                }
                if('Update'.equalsIgnoreCase(sco.action))
                {
                    symptomsCausesToUpdate.add(sco.fcusymptomcause);
                }
                else
                {
                    if(FCU_Symptoms_Causes__c.SObjectType.getDescribe().isDeletable())
                    {
                        symptomsCausesToDelete.add(sco.fcusymptomcause);
                    }
                    else
                    {
                        error = true;
                        //returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        //returned.statusDescription = getErrorDescription(returned.statusCode);
                        sco.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        sco.statusDescription = getErrorDescription(sco.statusCode);
                    }
                }
            }
            else symptomsCausesToInsert.put(Integer.ValueOf(sco.fcusymptomCause.IdDevice__c), sco.fcusymptomCause);           
        }
        
        //Check REST_VisualRatingsProductObject
        Map<Id, VisualRatingProduct__c> visualRatingsProductToCheck = new Map<Id, VisualRatingProduct__c >([SELECT LastModifiedDate, LKP_Product__c FROM VisualRatingProduct__c WHERE Id IN :visualRatingsProductIdToCheck]);
        for(REST_VisualRatingsProductObject vrp: returned.visualratingsproduct)
        {
            if(!'Insert'.equalsIgnoreCase(vrp.action))            
            {
                if(visualRatingsProductToCheck.get(vrp.visualratingproduct.Id) == null)
                {
                    error = true;
                    // returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    // returned.statusDescription = getErrorDescription(returned.statusCode);
                    vrp.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    vrp.statusDescription = errorDetailDeleted;
                    //returned.statusCode = ERROR_NOT_PROCESSED ;
                }
                else if(vrp.LastModifiedDate != visualRatingsProductToCheck.get(vrp.visualratingproduct.Id).LastModifiedDate)
                {
                    error = true;
                    //returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    vrp.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    vrp.statusDescription = errorDetailTimestamp;
                }
                if('Update'.equalsIgnoreCase(vrp.action))
                {
                    visualRatingsProductToUpdate.add(vrp.visualratingproduct);
                }
                else
                {
                    if(FCU_Visual_Rating__c.SObjectType.getDescribe().isDeletable())
                    {
                        visualRatingsProductToDelete.add(vrp.visualratingproduct);
                    }
                    else
                    {
                        error = true;
                        //returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        //returned.statusDescription = getErrorDescription(returned.statusCode);
                        vrp.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        vrp.statusDescription = getErrorDescription(vrp.statusCode);
                    }
                }
            }
            else  visualRatingsProductToInsert.put(Integer.ValueOf(vrp.visualratingproduct.IdDevice__c), vrp.visualratingproduct);           
        }        
        
        //Check REST_VisualRatingsObject
        Map<Id, FCU_Visual_Rating__c> visualRatingsToCheck = new Map<Id, FCU_Visual_Rating__c>([SELECT LastModifiedDate, LKP_VisualRating__c FROM FCU_Visual_Rating__c WHERE Id IN :visualRatingsIdToCheck]);
        for(REST_VisualRatingsObject vro: returned.fcuvisualratings)
        {
            if(!'Insert'.equalsIgnoreCase(vro.action))            
            {
                if(visualRatingsToCheck.get(vro.fcuvisualrating.Id) == null)
                {
                    error = true;
                    // returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    // returned.statusDescription = getErrorDescription(returned.statusCode);
                    vro.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    vro.statusDescription = errorDetailDeleted;
                    //returned.statusCode = ERROR_NOT_PROCESSED ;
                }
                else if(vro.LastModifiedDate != visualRatingsToCheck.get(vro.fcuvisualrating.Id).LastModifiedDate)
                {
                    error = true;
                    //returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    vro.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    vro.statusDescription = errorDetailTimestamp;
                }
                if('Update'.equalsIgnoreCase(vro.action))
                {
                    visualRatingsToUpdate.add(vro.fcuvisualrating);
                }
                else
                {
                    if(FCU_Visual_Rating__c.SObjectType.getDescribe().isDeletable())
                    {
                        visualRatingsToDelete.add(vro.fcuvisualrating);
                    }
                    else
                    {
                        error = true;
                        //returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        //returned.statusDescription = getErrorDescription(returned.statusCode);
                        vro.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        vro.statusDescription = getErrorDescription(vro.statusCode);
                    }
                }
            }
            else  visualRatingsToInsert.put(Integer.ValueOf(vro.fcuvisualrating.IdDevice__c), vro.fcuvisualrating);           
        }
        
        //Check REST_ObservationsObject
        Map<Id, FCU_Observations__c> observationsToCheck = new Map<Id, FCU_Observations__c>([SELECT LastModifiedDate, LKP_Observations__c FROM FCU_Observations__c WHERE Id IN :observationsIdToCheck]);
        for(REST_ObservationsObject o: returned.fcuobservations)
        {
            if(!'Insert'.equalsIgnoreCase(o.action))            
            {
                if(observationsToCheck.get(o.fcuobservation.Id) == null)
                {
                    error = true;
                    // returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    // returned.statusDescription = getErrorDescription(returned.statusCode);
                    o.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                    o.statusDescription = errorDetailDeleted;
                    //returned.statusCode = ERROR_NOT_PROCESSED ;
                }
                else if(o.LastModifiedDate != observationsToCheck.get(o.fcuobservation.Id).LastModifiedDate)
                {
                    error = true;
                    //returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    o.statusCode = ERROR_TIMESTAMP_MISMATCH;
                    o.statusDescription = errorDetailTimestamp;
                }
                if('Update'.equalsIgnoreCase(o.action))
                {
                    observationsToUpdate.add(o.fcuobservation);
                }
                else
                {
                    if(FCU_Observations__c.SObjectType.getDescribe().isDeletable())
                    {
                        observationsToDelete.add(o.fcuobservation);
                    }
                    else
                    {
                        error = true;
                        //returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        //returned.statusDescription = getErrorDescription(returned.statusCode);
                        o.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                        o.statusDescription = getErrorDescription(o.statusCode);
                    }
                }
            }
            else  observationsToInsert.put(Integer.ValueOf(o.fcuobservation.IdDevice__c), o.fcuobservation);           
        }  
        
        if(error|| returned.statusCode == ERROR_TIMESTAMP_MISMATCH || returned.statusCode == ERROR_RECORD_PREVIOUSLY_DELETED || returned.statusCode == ERROR_USER_HAS_NO_RIGHTS)
        {
             generateBackupDocument(request,paramInfo,false);
             return returned;
        }   
        /* End - Timestamp checking // Begin - Database commitments*/
        
        FieldCheckUp__c fcu;
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        Savepoint sp = Database.setSavepoint();
        //punto indicates the last DML operation that was completed correctly
        Integer punto = 0;        
        
        try
        {
            /* FIELD CHECK UP */            
            if(fieldCheckUpToUpdate.size() > 0)
            {
                punto = 1;
                update fieldCheckUpToUpdate;
                fcu = fieldCheckUpToUpdate[0];
            }
            if(fieldCheckUpToInsert.size() > 0)
            {
                punto = 2;
                insert fieldCheckUpToInsert.values();
                fcu = fieldCheckUpToInsert.values()[0];                
            } 
            /*EXTERNAL CONDITIONS*/         
            if(externalConditionsToDelete.size() > 0)
            {
                punto = 3;
                delete externalConditionsToDelete;
            }
            if(externalConditionsToInsert.size() > 0)
            {
                for(FCU_External_Conditions__c ec : externalConditionsToInsert.values())
                {
                    ec.LKP_FCU__c = fcu.Id;
                }            
                punto = 4;
                insert externalConditionsToInsert.values();
            }
            if(externalConditionsToUpdate.size() > 0)
            {
                punto = 5;
                update externalConditionsToUpdate;
            }
            /*SYMPTOMS CAUSES*/
            if(symptomsCausesToDelete.size() > 0)
            {
                punto = 6;
                delete symptomsCausesToDelete;
            }
            if(symptomsCausesToInsert.size() > 0)
            {
                for(FCU_Symptoms_Causes__c sc : symptomsCausesToInsert.values())
                {
                    sc.LKP_FCU__c = fcu.Id;
                }
                punto = 7;
                insert symptomsCausesToInsert.values();
            }
            if(symptomsCausesToUpdate.size() > 0)
            {
                punto = 8;
                update symptomsCausesToUpdate;
            }
            /*VISUAL RATINGS PRODUCT*/
            if(visualRatingsProductToInsert.size() > 0)
            {                
                for(VisualRatingProduct__c vrp: visualRatingsProductToInsert.values())
                {
                    vrp.FieldCheckUp__c = fcu.Id;
                }
                punto = 10;
                insert visualRatingsProductToInsert.values();                
            }
            if(visualRatingsProductToUpdate.size() > 0)
            {
                punto = 11;
                update visualRatingsProductToUpdate;
            }            
            /* DELETE VISUAL RATINGS*/
            if(visualRatingsToDelete.size() > 0)
            {
                punto = 12;
                delete visualRatingsToDelete;
            }
            /*VISUAL RATINGS PRODUCT*/
            if(visualRatingsProductToDelete.size() > 0)
            {
                punto = 9;
                delete visualRatingsProductToDelete;
            }
            /*VISUAL RATINGS*/
            if(visualRatingsToInsert.size() > 0)
            {                     
                for(FCU_Visual_Rating__c vr: visualRatingsToInsert.values())
                {                    
                    vr.LKP_FCU__c = fcu.Id;
                    if(vr.LKP_VisualRatingProduct__c == null)
                    {
                        boolean encontrado = false;
                        Integer i = 0;
                        while(i < visualRatingsProductToInsert.size() && !encontrado)
                        {
                            if(visualRatingsProductToInsert.values()[i].idDevice__c == vr.idDeviceParent__c)
                            {
                                vr.LKP_VisualRatingProduct__c = visualRatingsProductToInsert.values()[i].Id;
                                encontrado = true;
                            }
                            i ++;
                        }
                    }  
                }
                punto = 13;
                insert visualRatingsToInsert.values();
            }
            if(visualRatingsToUpdate.size() > 0)
            {
                punto = 14;
                update visualRatingsToUpdate;
            }
            /*OBSERVATIONS*/
            if(observationsToDelete.size() > 0)
            {
                punto = 15;
                delete observationsToDelete;
            }
            if(observationsToInsert.size() > 0)
            {
                for(FCU_Observations__c o: observationsToInsert.values())
                {
                    o.LKP_FCU__c = fcu.Id;
                }
                punto = 16;
                insert observationsToInsert.values();
            }            
            if(observationsToUpdate.size() > 0)
            {
                punto = 17;
                update observationsToUpdate;
            }
            /* DELETE FIELD CHECK UP */
            if(fieldCheckUpToDelete.size() > 0)
            {
                punto = 0;
                delete fieldCheckUpToDelete;
            }
            
            /* BEGIN - SYNC REST OBJECTS */
            Map<Id, FieldCheckUp__c> fieldCheckUpGet = new Map<Id, FieldCheckUp__c>([SELECT LastModifiedDate FROM FieldCheckUp__c WHERE Id IN :fieldCheckUpToInsert.values() OR Id IN :fieldCheckUpToUpdate]);
            
            if(!'Delete'.equalsIgnoreCase(returned.action))
            {
                returned.LastModifiedDate = fieldCheckUpGet.get(returned.fieldcheckup.Id).LastModifiedDate;
            }
  
            Map<Id, FCU_External_Conditions__c> externalConditionsToGet = new Map<Id, FCU_External_Conditions__c>([SELECT LastModifiedDate FROM FCU_External_Conditions__c WHERE Id IN :externalConditionsToInsert.values() OR Id IN :externalConditionsToUpdate]);
            for(REST_ExternalConditionsObject eco: returned.fcuexternalconditions)
            {
                eco.statusCode = returned.statusCode;
                if(!'Delete'.equalsIgnoreCase(eco.action))
                {
                    eco.LastModifiedDate = externalConditionsToGet.get(eco.fcuexternalcondition.Id).LastModifiedDate;
                }
            }
            Map<Id, FCU_Symptoms_Causes__c> symptomCausesToGet = new Map<Id, FCU_Symptoms_Causes__c>([SELECT LastModifiedDate FROM FCU_Symptoms_Causes__c WHERE Id IN :symptomsCausesToInsert.values() OR Id IN :symptomsCausesToUpdate]);
            for(REST_SymptomsCausesObject sco: returned.fcusymptomscauses)
            {
                sco.statusCode = returned.statusCode;
                if(!'Delete'.equalsIgnoreCase(sco.action))
                {
                    sco.LastModifiedDate = symptomCausesToGet.get(sco.fcusymptomcause.Id).LastModifiedDate;
                }
            }
            Map<Id, VisualRatingProduct__c> visualRatingsProductToGet = new Map<Id, VisualRatingProduct__c>([SELECT LastModifiedDate FROM VisualRatingProduct__c WHERE Id IN :visualRatingsProductToInsert.values() OR Id IN :visualRatingsProductToUpdate]);
            for(REST_VisualRatingsProductObject vrp: returned.visualratingsproduct)
            {
                vrp.statusCode = returned.statusCode;
                if(!'Delete'.equalsIgnoreCase(vrp.action))
                {
                    vrp.LastModifiedDate = visualRatingsProductToGet.get(vrp.visualratingproduct.Id).LastModifiedDate;
                }
            }            
            Map<Id, FCU_Visual_Rating__c> visualRatingsToGet = new Map<Id, FCU_Visual_Rating__c>([SELECT LastModifiedDate FROM FCU_Visual_Rating__c WHERE Id IN :visualRatingsToInsert.values() OR Id IN :visualRatingsToUpdate]);
            for(REST_VisualRatingsObject vro: returned.fcuvisualratings)
            {
                vro.statusCode = returned.statusCode;
                if(!'Delete'.equalsIgnoreCase(vro.action))
                {
                    vro.LastModifiedDate = visualRatingsToGet.get(vro.fcuvisualrating.Id).LastModifiedDate;
                }
            }            
            Map<Id, FCU_Observations__c> observationsToGet = new Map<Id, FCU_Observations__c>([SELECT LastModifiedDate FROM FCU_Observations__c WHERE Id IN :observationsToInsert.values() OR Id IN :observationsToUpdate]);
            for(REST_ObservationsObject o: returned.fcuobservations)
            {
                o.statusCode = returned.statusCode;
                if(!'Delete'.equalsIgnoreCase(o.action))
                {
                    o.LastModifiedDate = observationsToGet.get(o.fcuobservation.Id).LastModifiedDate;
                }
            }
                       
            fieldCheckUpToDelete.clear();
            fieldCheckUpToUpdate.clear();
            fieldCheckUpToInsert.clear();            
            
            externalConditionsToDelete.clear();
            externalConditionsToUpdate.clear();
            externalConditionsToInsert.clear();
            
            symptomsCausesToDelete.clear();
            symptomsCausesToUpdate.clear();
            symptomsCausesToInsert.clear();
            
            visualRatingsProductToInsert.clear();
            visualRatingsProductToDelete.clear();
            visualRatingsProductToUpdate.clear();
            
            visualRatingsToInsert.clear();
            visualRatingsToDelete.clear();
            visualRatingsToUpdate.clear();
            
            observationsToInsert.clear();
            observationsToUpdate.clear();
            observationsToDelete.clear();      
            
            /* END - SYNC REST OBJECTS */
            generateBackupDocument(request,paramInfo,true);
        }
        catch(DMLException e)
        {
            String errorMsg ='';
            String fcName, accId, stId, ecId, scId, vrId, oId, pId;
            String errorType;            
            for(Integer i = 0; i < e.getNumDMl(); i++)
            {
                 errorMsg += e.getDmlMessage(i);
                 if(e.getDmlFields(i)!=null &&  e.getDmlFields(i).size()>0)
                    errorMsg += ' : ' + e.getDmlFields(i)[0].getDescribe().getLabel() + ' ';
                 /* FIELD CHECK UP */ 
                 if(punto == 0 && fieldCheckUpToDelete[e.getDmlIndex(i)] != null && fieldCheckUpToDelete[e.getDmlIndex(i)].LKP_Account__c != null && fieldCheckUpToDelete[e.getDmlIndex(i)].LKP_SM_Stage__c != null)
                 {
                     fcName = fieldCheckUpToDelete[e.getDmlIndex(i)].Name;
                     accId = fieldCheckUpToDelete[e.getDmlIndex(i)].LKP_Account__c;
                     stId = fieldCheckUpToDelete[e.getDmlIndex(i)].LKP_SM_Stage__c;
                     errorType = 'FieldCheckUp';
                 }
                 if(punto == 1 && fieldCheckUpToUpdate[e.getDmlIndex(i)] != null && fieldCheckUpToUpdate[e.getDmlIndex(i)].LKP_Account__c != null && fieldCheckUpToUpdate[e.getDmlIndex(i)].LKP_SM_Stage__c != null)
                 {
                     fcName = fieldCheckUpToUpdate[e.getDmlIndex(i)].Name;
                     accId = fieldCheckUpToUpdate[e.getDmlIndex(i)].LKP_Account__c;
                     stId = fieldCheckUpToUpdate[e.getDmlIndex(i)].LKP_SM_Stage__c;
                     errorType = 'FieldCheckUp';
                 }
                 if(punto == 2 && fieldCheckUpToInsert.values()[e.getDmlIndex(i)] != null && fieldCheckUpToInsert.values()[e.getDmlIndex(i)].LKP_Account__c != null && fieldCheckUpToInsert.values()[e.getDmlIndex(i)].LKP_SM_Stage__c != null)
                 {
                     fcName = fieldCheckUpToInsert.values()[e.getDmlIndex(i)].Name;
                     accId = fieldCheckUpToInsert.values()[e.getDmlIndex(i)].LKP_Account__c;
                     stId = fieldCheckUpToInsert.values()[e.getDmlIndex(i)].LKP_SM_Stage__c;
                     errorType = 'FieldCheckUp';
                 }
                 /* CONDITIONS */
                 if(punto == 3 && externalConditionsToDelete[e.getDmlIndex(i)]!= null && externalConditionsToDelete[e.getDmlIndex(i)].LKP_ExternalConditions__c != null)
                 {
                     ecId = externalConditionsToDelete[e.getDmlIndex(i)].LKP_ExternalConditions__c;
                     errorType = 'External Conditions';
                 }
                 if(punto == 4 && externalConditionsToInsert.values()[e.getDmlIndex(i)]!= null && externalConditionsToInsert.values()[e.getDmlIndex(i)].LKP_ExternalConditions__c != null)
                 {
                     ecId = externalConditionsToInsert.values()[e.getDmlIndex(i)].LKP_ExternalConditions__c;
                     errorType = 'External Conditions';
                 }
                 if(punto == 5 && externalConditionsToUpdate[e.getDmlIndex(i)] != null && externalConditionsToUpdate[e.getDmlIndex(i)].LKP_ExternalConditions__c != null)
                 {
                     ecId = externalConditionsToUpdate[e.getDmlIndex(i)].LKP_ExternalConditions__c;
                     errorType = 'External Conditions';
                 }
                 /* SYMPTOMS CAUSES */              
                 if(punto == 6 && symptomsCausesToDelete[e.getDmlIndex(i)]!= null && symptomsCausesToDelete[e.getDmlIndex(i)].LKP_SymptomsCauses__c != null)
                 {
                     scId = symptomsCausesToDelete[e.getDmlIndex(i)].LKP_SymptomsCauses__c;
                     errorType = 'Symptom Causes';
                 }
                 if(punto == 7 && symptomsCausesToInsert.values()[e.getDmlIndex(i)]!= null && symptomsCausesToInsert.values()[e.getDmlIndex(i)].LKP_SymptomsCauses__c != null)
                 {
                     scId = symptomsCausesToInsert.values()[e.getDmlIndex(i)].LKP_SymptomsCauses__c;
                     errorType = 'Symptom Causes';
                 }
                 if(punto == 8 && symptomsCausesToUpdate[e.getDmlIndex(i)] != null && symptomsCausesToUpdate[e.getDmlIndex(i)].LKP_SymptomsCauses__c != null)
                 {
                     scId = symptomsCausesToUpdate[e.getDmlIndex(i)].LKP_SymptomsCauses__c;
                     errorType = 'symptom Causes';
                 }
                 /* VISUAL RATINGS PRODUCT */
                 if(punto == 9 && visualRatingsProductToDelete[e.getDMLIndex(i)]!= null && visualRatingsProductToDelete[e.getDmlIndex(i)].LKP_Product__c != null)
                 {
                     pId = visualRatingsProductToDelete[e.getDMLIndex(i)].LKP_Product__c;
                     errorType = 'Visual Rating Product';                     
                 }                 
                 if(punto == 10 && visualRatingsProductToInsert.values()[e.getDMLIndex(i)]!= null && visualRatingsProductToInsert.values()[e.getDmlIndex(i)].LKP_Product__c != null)
                 {
                     pId = visualRatingsProductToInsert.values()[e.getDMLIndex(i)].LKP_Product__c;
                     errorType = 'Visual Rating Product';                     
                 }
                 if(punto == 11 && visualRatingsProductToUpdate[e.getDMLIndex(i)]!= null && visualRatingsProductToUpdate[e.getDmlIndex(i)].LKP_Product__c != null)
                 {
                     pId = visualRatingsProductToUpdate[e.getDMLIndex(i)].LKP_Product__c;
                     errorType = 'Visual Rating Product';                     
                 }
                 /* VISUAL RATINGS */
                 if(punto == 12 && visualRatingsToDelete[e.getDmlIndex(i)]!= null && visualRatingsToDelete[e.getDmlIndex(i)].LKP_VisualRating__c != null)
                 {
                     vrId = visualRatingsToDelete[e.getDmlIndex(i)].LKP_VisualRating__c;
                     errorType = 'Visual Ratings';
                 }
                 if(punto == 13 && visualRatingsToInsert.values()[e.getDmlIndex(i)]!= null && visualRatingsToInsert.values()[e.getDmlIndex(i)].LKP_VisualRating__c != null)
                 {
                     vrId = visualRatingsToInsert.values()[e.getDmlIndex(i)].LKP_VisualRating__c;
                     errorType = 'Visual Ratings';
                 }
                 if(punto == 14 && visualRatingsToUpdate[e.getDmlIndex(i)] != null && visualRatingsToUpdate[e.getDmlIndex(i)].LKP_VisualRating__c != null)
                 {
                     vrId = visualRatingsToUpdate[e.getDmlIndex(i)].LKP_VisualRating__c;
                     errorType = 'Visual Ratings';
                 }
                 /* OBSERVATIONS */                 
                 if(punto == 15 && observationsToDelete[e.getDmlIndex(i)]!= null && observationsToDelete[e.getDmlIndex(i)].LKP_Observations__c != null)
                 {
                     oId = observationsToDelete[e.getDmlIndex(i)].LKP_Observations__c;
                     errorType = 'Observations';
                 }
                 if(punto == 16 && observationsToInsert.values()[e.getDmlIndex(i)]!= null && observationsToInsert.values()[e.getDmlIndex(i)].LKP_Observations__c != null)
                 {
                     oId = observationsToInsert.values()[e.getDmlIndex(i)].LKP_Observations__c;
                     errorType = 'Observations';
                 }
                 if(punto == 17 && observationsToUpdate[e.getDmlIndex(i)] != null && observationsToUpdate[e.getDmlIndex(i)].LKP_Observations__c != null)
                 {
                     oId = observationsToUpdate[e.getDmlIndex(i)].LKP_Observations__c;
                     errorType = 'Observations';
                 }                                  
                 if(e.getDmlId(i)!=null)
                    errorMsg += e.getDmlId(i);
            }
            system.debug('entra en exception' + e); 
            Database.rollback(sp);
            Id itemFailed;
            String ee ='' + e;
            if((''+e).contains(';'))
                 if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
            System.debug('itemFailed:' + itemFailed);        
            Account acc;
            SM_stage__c st;
            FCU_External_Conditions__c ec;
            FCU_Symptoms_Causes__c sc;
            VisualRatingProduct__c vrp;
            FCU_Visual_Rating__c vr;
            FCU_Observations__c o;
            
            //Account        
            if(accId != null)
            {
                acc = [SELECT Id, Name FROM Account WHERE Id =: accId];
                st = [SELECT Id, Name FROM SM_stage__c WHERE Id =: stId];
                errorMsg = e.getDmlMessage(0) + '\n\n' +  errorType +'account: ' +acc.name + '\n\n' + 'stage: '+ +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):''); 
            }
            //External conditions
            if(ecId != null)
            {
                try
                {
                    ec = [SELECT Id, Name FROM FCU_External_Conditions__c WHERE Id =: ecId];
                    errorMsg = e.getDmlMessage(0) + '\n\n' +  errorType +'master external Condition: ' +ec.Name + 'Field Check Up: '+ fcName + '\n\n' + '-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                }
                catch(Exception exc){}
                
            }
            //Symptoms causes
            if(scId != null)
            {
                try
                {
                    sc = [SELECT Id, Name FROM FCU_Symptoms_Causes__c WHERE Id =: scId];
                    errorMsg = e.getDmlMessage(0) + '\n\n' +  errorType +'master symptom Causes: ' +sc.Name + 'Field Check Up: '+ fcName + '\n\n' + '-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                }
                catch(Exception exc){}
                
            }
            //Visual rating pproduct
            if(pId != null)
            {
                try
                {
                    vrp = [SELECT Id, Name FROM VisualRatingProduct__c WHERE Id =: pId];
                    errorMsg = e.getDmlMessage(0) + '\n\n' + errorType + 'master visual rating product: ' +vrp.Name + 'Field Check Up: '+ fcName + '\n\n' + '-Technical error detail-\n'+ System.now() + '\n' + UserInfo.getUsername() + '\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                }
                catch(Exception exc){}
            }
            //Visual rating
            if(vrId != null)
            {
                try
                {
                    vr = [SELECT Id, Name FROM FCU_Visual_Rating__c WHERE Id =: vrId];
                    errorMsg = e.getDmlMessage(0) + '\n\n' +  errorType +'master visual Ratings: ' +vr.Name + 'Field Check Up: '+ fcName + '\n\n' + '-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                }
                catch(Exception exc){}
                
            }
            //Observations
            if(oId != null)
            {
                try
                {
                    o = [SELECT Id, Name FROM FCU_Observations__c WHERE Id =: oId];
                    errorMsg = e.getDmlMessage(0) + '\n\n' +  errorType +'master Observations: ' +o.Name + 'Field Check Up: '+ fcName + '\n\n' + '-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                }
                catch(Exception exc){}                
            }
                    
            if((''+e).contains('to review the status of this')){
                returned.statusCode = ERROR_STATUS_CHANGE_NOT_ALLOWED;
            }
            else
            {
                returned.statusCode = ERROR_UNKNOWN;
                returned.statusDescription = errorMsg;
            }
            
            returned.statusDescription =  (returned.statusCode==ERROR_UNKNOWN ? '' : (getErrorDescription(returned.statusCode)))+ returned.statusDescription;
             
            if(itemFailed != null)
            {   
                //FIELDCHECKUP              
                if(returned.fieldcheckup.Id != itemFailed)
                {
                    returned.statusCode = ERROR_NOT_PROCESSED;
                    returned.statusDescription = getErrorDescription(returned.statusCode);
                }
                //EXTERNAL CONDITIONS
                for(REST_ExternalConditionsObject eco : returned.fcuexternalconditions)
                {
                    if(eco.fcuexternalcondition.id == itemFailed)
                    {
                        eco.statusCode = returned.statusCode;
                        eco.statusDescription = returned.statusDescription;                     
                    }
                    else
                    {
                        eco.statusCode = ERROR_NOT_PROCESSED;
                        eco.statusDescription = getErrorDescription(eco.statusCode);                                            
                    }
                }
                //SYMPTOMS CAUSES
                for(REST_SymptomsCausesObject sco: returned.fcusymptomscauses)
                {
                    if(sco.fcusymptomcause.id == itemFailed)
                    {
                        sco.statusCode = returned.statusCode;
                        sco.statusDescription = returned.statusDescription;                       
                    }
                    else
                    {
                        sco.statusCode = ERROR_NOT_PROCESSED;
                        sco.statusDescription = getErrorDescription(sco.statusCode);                       
                    }
                }
                //VISUAL RATING PRODUCT
                for(REST_VisualRatingsProductObject vrpo: returned.visualratingsproduct)
                {
                    if(vrpo.visualratingproduct.id == itemFailed)
                    {
                        vrpo.statusCode = returned.statusCode;
                        vrpo.statusDescription = returned.statusDescription;
                    }
                    else
                    {
                        vrpo.statusCode = ERROR_NOT_PROCESSED;
                        vrpo.statusDescription = getErrorDescription(vrpo.statusCode);
                    }
                }
                //VISUAL RATINGS
                for(REST_VisualRatingsObject vro: returned.fcuvisualRatings)
                {
                    if(vro.fcuvisualrating.id == itemFailed)
                    {
                        vro.statusCode = returned.statusCode;
                        vro.statusDescription = returned.statusDescription;                      
                    }
                    else
                    {
                        vro.statusCode = ERROR_NOT_PROCESSED;
                        vro.statusDescription = getErrorDescription(vro.statusCode);                                              
                    }
                }
                //OBSERVATIONS
                for(REST_ObservationsObject oo: returned.fcuobservations)
                {
                    if(oo.fcuobservation.id == itemFailed)
                    {
                        oo.statusCode = returned.statusCode;
                        oo.statusDescription = returned.statusDescription;                      
                    }
                    else
                    {
                        oo.statusCode = ERROR_NOT_PROCESSED;
                        oo.statusDescription = getErrorDescription(oo.statusCode);           
                    }
                }
                               
            }
            generateBackupDocument(request,paramInfo,false);           
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription = (e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') + (e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'') + Userinfo.getUserName() +'-' + System.now() ;
            returned.statusDescription = getErrorDescription(returned.statusCode) + ' ' + returned.statusDescription;
            generateBackupDocument(request,paramInfo,false);
        }
        
        return returned;                
    }
    /**   End - Database commitments   **/      
    
    
    /** INTERNAL OBJECTS  **/
    global class REST_FieldCheckUpObject
    {
        public Datetime LastModifiedDate;
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public FieldCheckUp__c fieldcheckup;
        public List<REST_ExternalConditionsObject> fcuexternalconditions;
        public List<REST_SymptomsCausesObject> fcusymptomscauses;
        public List<REST_VisualRatingsProductObject> visualratingsproduct;
        public List<REST_VisualRatingsObject> fcuvisualratings;
        public List<REST_ObservationsObject> fcuobservations;        
    }
    global class REST_ExternalConditionsObject
    {
        public Datetime LastModifiedDate;
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public FCU_External_Conditions__c fcuexternalcondition;
    }
    global class REST_SymptomsCausesObject
    {
        public Datetime LastModifiedDate;
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public FCU_Symptoms_Causes__c fcusymptomcause;
    }
    global class REST_VisualRatingsProductObject
    {
        public Datetime LastModifiedDate;
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public VisualRatingProduct__c visualratingproduct;
    }
    global class REST_VisualRatingsObject
    {
        public Datetime LastModifiedDate;
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public FCU_Visual_Rating__c fcuvisualrating;
    }
    global class REST_ObservationsObject
    {
        public Datetime LastModifiedDate;
        public String action;
        public Integer statusCode;
        public String statusDescription;
        public FCU_Observations__c fcuobservation;
    }
    
    /** Error messages **/
     private static Integer ERROR_EMPTY = 100;
     private static Integer ERROR_STATUS_CHANGE_NOT_ALLOWED = 105;
     private static Integer ERROR_TIMESTAMP_MISMATCH = 200;
     private static Integer ERROR_RECORD_PREVIOUSLY_DELETED = 201;
     private static Integer ERROR_USER_HAS_NO_RIGHTS = 202;
     private static Integer ERROR_NOT_PROCESSED = 998;
     private static Integer ERROR_UNKNOWN = 999;
     
     private static String getErrorDescription(Integer paramError)
     {
        if(paramError == ERROR_STATUS_CHANGE_NOT_ALLOWED) return 'You are not allowed to change Status field';
        else if(paramError == ERROR_EMPTY) return '';
        else if(paramError == ERROR_TIMESTAMP_MISMATCH) return 'Record was updated on the server before sync';
        else if(paramError == ERROR_RECORD_PREVIOUSLY_DELETED) return 'Record was deleted on the server before sync';
        else if(paramError == ERROR_USER_HAS_NO_RIGHTS) return 'This user does not have enougth rights to perform this operation';
        else if(paramError == ERROR_NOT_PROCESSED) return 'Item Not Processed or no Error Found';
        else if(paramError == ERROR_UNKNOWN) return 'Unknown Error: ';
        else return 'Unknown Error2: ';
     }
     
     /**   Backup documents   **/
     private static void generateBackupDocument(String request, REST_FieldCheckUpObject response, boolean status)
     {
         if((
             systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
             systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all')
             {
                 String documentName='REST_SendLogicalEntityFieldCheckUp' + string.valueOf(system.currentTimeMillis()) + '_' + Util.currentUser.ID;
                 String logFolder=systemSettings__c.getvalues(Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER').Value__c;
                 
                 if (status) documentName = documentName + '_OK';
                 else documentName = documentName+'_ERR';
                 
                 documentName = documentName.remove(':').remove(' ').remove('-');
                 System.debug('Document Name: ' + documentName);
                 String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n'+System.JSON.serializePretty(response);
                 Blob documentBody= Blob.valueOf(body);
                 list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName =:logFolder AND Type = 'Document'];
                 if (destFolder.size() == 1) 
                 {
                     Document doc= new Document(Name = documentName , body=documentBody,developerName=documentName, IsPublic = true, FolderId=destFolder[0].Id, contentType='text/plain',type='json' );
                     insert doc;
                 }
                else 
                {
                    system.debug('SharedDocuments folder not found or returned too many values: ' + destFolder);
                }                 
                 
             }
             else if (systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c!='none'){
                system.debug('Warning: Unexpected value in System Setting \'EAST_REST_SVC_JSON_SAVE\'. Expected values are \'None\', \'Exceptioin\' or \'All\'');
            }
     }
}