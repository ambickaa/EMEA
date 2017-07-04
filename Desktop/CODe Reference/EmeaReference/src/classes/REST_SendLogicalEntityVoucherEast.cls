@RestResource(urlMapping='/sendLogicalEntity/Voucher/*')
global with sharing class REST_SendLogicalEntityVoucherEast {

    private static Map<Integer,Voucher__c> vouchersToInsert = new Map<Integer,Voucher__c>();
    private static Map<Integer,Voucher__c> vouchersToUpdate = new Map<Integer,Voucher__c>();
    private static List<Voucher__c> vouchersToDelete = new List<Voucher__c>();
    private static Map<Id,Voucher__c> vouchersToReassign = new Map<Id,Voucher__c>();
     
    private static Map<Integer,VoucherLineItem__c> voucherLineItemsToInsert = new Map<Integer,VoucherLineItem__c>();
    private static List<VoucherLineItem__c> voucherLineItemsToUpdate = new List<VoucherLineItem__c>();
    private static List<VoucherLineItem__c> voucherLineItemsToDelete = new List<VoucherLineItem__c>();
    private static Map<Id,Id> mapVLIsUpdate= new Map<ID,ID>();
    
    
    private static Map<Integer,Integer> vliToInserVoucherIdDevice = new Map<Integer,Integer>();
    private static Map<Id,Integer> vliToUpVoucherIdDevice = new Map<Id,Integer>();
    private static Map<Id, Decimal> vliToUpdate = new Map<Id, Decimal>();
    private static Map<Id, Decimal> vliToUpdate2 = new Map<Id, Decimal>();
    
    private static List<Integer> voRejOrApproval = new List<Integer>();
    
    private static Integer stockErrors=0;
        
    @HttpPost
   
    global static REST_SendLogicalEntityVoucher sendVouchers(REST_SendLogicalEntityVoucher paramInfo)
    {
      //tengo que inicializar las variables fuera del try
        String request = System.JSON.serializePretty(paramInfo);
        REST_SendLogicalEntityVoucher returned = paramInfo;
        Map<Integer, List<Integer>> voWithVli = new Map<Integer, List<Integer>>();
        List<Integer> vlisWithoutCli = new List<Integer>();
        List<Integer> voWithoutCli = new List<Integer>();
        Map<Integer, List<Integer>> voWithVliNoCli = new Map<Integer, List<Integer>>();    
       Map<Integer, List<Id>> voWithVliC = new Map<Integer, List<Id>>();
       CampaignLineItem__c CliToAdd = new CampaignLineItem__c();      
       
       //START OF STOCK CHECK
        Map<ID,Decimal> pcetocheck = new Map<ID, Decimal>();
        Map<ID,Decimal> PCEvsStockLeft = new Map<ID,Decimal>();
        List<VoucherLineItem__c> vlistocheck = new List<VoucherLineItem__c>();
        Map<ID,Decimal> CLIvsBags = new Map<ID,Decimal>();
        
        Map<Integer, VoucherLineItem__c> voucherlineitemstoReject = new Map<Integer, VoucherLineItem__c>();
        Map<Integer, String> vliToRejectName = new Map<Integer, String>();
        Map<Integer, Voucher__c> vouchersToReject = new Map<Integer,Voucher__c>();
        
        Map<Integer, Id> vCampaigns = new Map<Integer, Id>();
        Map<Id,Boolean> vcVsVHungary = new Map<Id,Boolean>();
        
  
        Map<Integer, Id> vCLI = new Map<Integer, Id>();
        Map<Id, Integer> vCLI2 = new Map<Id, Integer>();
        Map<Integer, Decimal> vBAGS = new Map<Integer, Decimal>();
        Map<Id, Decimal> vBAGSup = new Map<Id, Decimal>();
        Map<Id, Id> vCLIup = new Map<Id, Id>();
        Map<Id, Id> vCLIup2 = new Map<Id, Id>();
        Map<Integer, Id> vPCE = new Map<Integer, Id>();
        Map<Id, Id> vPCEup = new Map<Id, Id>();
          
      Map<Id,ProductCatalogEntry__c> vPCEob = new Map<Id,ProductCatalogEntry__c>();
      Integer punto = 0;     
    try{
          // Init_Of    TimeStamp check
          Set<ID> voucherLineItemsIdToCheck = new Set<ID>();
          for(REST_VoucherLineItemObject rvli : returned.voucherLineItems){
              rvli.voucherLineItem.OwnerId=Util.currentUser.Id;       
              if(!'Insert'.equalsIgnoreCase(rvli.action)){
                  voucherLineItemsIdToCheck.add(rvli.voucherLineItem.ID);
              }
          }
          Set<ID> vouchersIdToCheck = new Set<ID>();
          for(REST_VoucherObject rvo : returned.vouchers){
              rvo.voucher.OwnerId=Util.currentUser.Id;  
              if(!'Insert'.equalsIgnoreCase(rvo.action)){
                  vouchersIdToCheck.add(rvo.voucher.ID);
              }
          }
          Map<ID,VoucherLineItem__c> voucherLineItemsToCheck = new Map<ID,VoucherLineItem__c>([SELECT CampaignLineItemRef__c, LastModifiedDate FROM VoucherLineItem__c WHERE ID IN :voucherLineItemsIdToCheck AND PICK_TYPE__c != 'Free of charge']);
          Map<ID,Voucher__c> vouchersToCheck = new Map<ID,Voucher__c>([SELECT LastModifiedDate FROM Voucher__c WHERE ID IN :vouchersIdToCheck]);
         
            List<Id> accountVLIsTimestampList = new List<Id>();
            List<Id> accountVLIsDeleteList= new List<Id>();
            returned.statusDescription = '';
          for(REST_VoucherLineItemObject rvli : returned.voucherLineItems){
              if(!'Insert'.equalsIgnoreCase(rvli.action)){
                  if(voucherLineItemsToCheck.get(rvli.voucherLineItem.id) == null){
                      returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                      accountVLIsDeleteList.add(rvli.voucherLineItem.CampaignLineItemRef__r.FarmRef__c);
                      rvli.statusCode = returned.statusCode;
                      rvli.statusDescription = returned.statusDescription;
                  }else if(rvli.voucherLineItem.LastModifiedDate != voucherLineItemsToCheck.get(rvli.voucherLineItem.id).LastModifiedDate && voucherLineItemsToCheck.get(rvli.voucherLineItem.id).CampaignLineItemRef__c != null){
                      returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                      accountVLIsTimestampList.add(rvli.voucherLineItem.CampaignLineItemRef__r.FarmRef__c);
                      rvli.statusCode = returned.statusCode;
                      rvli.statusDescription = returned.statusDescription;
                  }
                  if('Update'.equalsIgnoreCase(rvli.action)){
                      //We Only receive updates when cancelling a voucher
                      
                      vliToUpdate2.put(rvli.voucherLineItem.id, rvli.voucherLineItem.Agreed__c);
                      rvli.voucherLineItem.CampaignLineItemRef__c=null;
                      vliToUpVoucherIdDevice.put(rvli.voucherlineitem.id,rvli.VoucherIdDevice); 
                      voucherLineItemsToUpdate.add(rvli.voucherLineItem);
                      mapVLIsUpdate.put(rvli.voucherlineitem.id,rvli.voucherlineitem.id);
                      
                      if(voWithVliC.get(rvli.VoucherIdDevice)==null) 
                    {
                        voWithVliC.put(rvli.VoucherIdDevice, new List<Id>{rvli.voucherlineitem.id});
                    }
                  else
                    {
                      voWithVliC.get(rvli.VoucherIdDevice).add(rvli.voucherlineitem.id);
                    }
                      
                  }else
                  {
                      if(VoucherLineItem__c.sObjectType.getDescribe().isDeletable())
                      {
                          vliToUpdate.put(rvli.voucherLineItem.CampaignLineItemRef__c, rvli.voucherLineItem.Agreed__c);
                          voucherLineItemsToDelete.add(rvli.voucherLineItem);
                          
                      }else
                      {
                          returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                          returned.statusDescription = getErrorDescription(returned.statusCode);
                          rvli.statusCode = returned.statusCode;
                          rvli.statusDescription = returned.statusDescription;
                      }
                  }
              }else{
                  voucherLineItemsToInsert.put(Integer.valueof(rvli.voucherLineItem.idDevice__c),rvli.voucherLineItem);
                  vliToInserVoucherIdDevice.put((Integer)rvli.voucherLineItem.idDevice__c,rvli.VoucherIdDevice);
                  if(voWithVli.get(rvli.VoucherIdDevice)==null && rvli.voucherLineItem.campaignLineItemRef__c!=null)
                    {
                        voWithVli.put(rvli.VoucherIdDevice, new List<Integer>{Integer.valueof(rvli.VoucherLineItem.idDevice__c)});
                    }
                else if(rvli.voucherLineItem.campaignLineItemRef__c!=null)
                    {
                      voWithVli.get(rvli.VoucherIdDevice).add(Integer.valueOf(rvli.VoucherLineItem.idDevice__c));
                    }
                  else
                  {
                    if(voWithVliNoCli.get(rvli.VoucherIdDevice)==null)
                    {
                        voWithVliNoCli.put(rvli.VoucherIdDevice, new List<Integer>{Integer.valueof(rvli.VoucherLineItem.idDevice__c)});                    
                    }
                    else
                    {
                      voWithVliNoCli.get(rvli.VoucherIdDevice).add(Integer.valueOf(rvli.VoucherLineItem.idDevice__c));                    
                    }
                  }
              }
          }
          
        List<Account> accountNameVLIsDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountVLIsDeleteList
                                                        ];
        List<Account> accountNameVLIsTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountVLIsTimestampList 
                                                        ];
        String accountVLIsDelete = '';
        String accountVLIsTimestamp = '';
        
        for(account acc : accountNameVLIsDeleteList )
        {
            accountVLIsDelete += acc.Name +'\n';
        }
        for(account acct : accountNameVLIsTimestampList )
        {
            accountVLIsTimestamp += acct.Name +'\n';
        }
          
          
            if(accountVLIsTimestamp != '')
            {
                returned.statusDescription += 'Voucher Line Items for the next accounts have been overwritten because of online changes: \n'+accountVLIsTimestamp;
            }
            if(accountVLIsDelete != '')
            {
                returned.statusDescription += '\n\nVoucher Line Items for the next accounts have been deleted from the online: \n'+accountVLIsDelete;          
            }
            
            List<Id> accountVouchersTimestampList = new List<Id>();
            List<Id> accountVouchersDeleteList = new List<Id>();
          for(REST_VoucherObject rvo : returned.vouchers){
              if(!'Insert'.equalsIgnoreCase(rvo.action)){
                  if(vouchersToCheck.get(rvo.voucher.id) == null){
                      returned.statusCode = ERROR_RECORD_PREVIOUSLY_DELETED;
                      accountVouchersDeleteList.add(rvo.voucher.AccountRef__c);
                      rvo.statusCode = returned.statusCode;
                      rvo.statusDescription = returned.statusDescription;
                  }else if(rvo.voucher.LastModifiedDate != vouchersToCheck.get(rvo.voucher.id).LastModifiedDate){
                      returned.statusCode = ERROR_TIMESTAMP_MISMATCH;
                      accountVouchersTimestampList.add(rvo.voucher.AccountRef__c);
                      rvo.statusCode = returned.statusCode;
                      rvo.statusDescription = returned.statusDescription;
                  }
                  if('Update'.equalsIgnoreCase(rvo.action)){
                    
                    if(rvo.voucher.status__c == 'Rejected' || rvo.voucher.status__c=='Waiting for approval')
                       {
                         voRejOrApproval.add(Integer.valueOf(rvo.voucher.idDevice__c));  
                       }
                      vouchersToUpdate.put(Integer.valueOf(rvo.voucher.idDevice__c),rvo.voucher);
                  }else if('Delete'.equalsIgnoreCase(rvo.action)){
                      if(Voucher__c.sObjectType.getDescribe().isDeletable()){
                          vouchersToDelete.add(rvo.voucher);
                      }else{
                          returned.statusCode = ERROR_USER_HAS_NO_RIGHTS;
                          returned.statusDescription = getErrorDescription(returned.statusCode);
                          rvo.statusCode = returned.statusCode;
                          rvo.statusDescription = returned.statusDescription;
                      }
                  }
              }else{
                  //XXX
                  vouchersToInsert.put(Integer.valueOf(rvo.voucher.idDevice__c),rvo.voucher);
                  vouchersToUpdate.put(Integer.valueOf(rvo.voucher.idDevice__c),rvo.voucher);
              }
          }
          
          List<Account> accountNameVoucherssDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountVouchersDeleteList
                                                        ];
        List<Account> accountNameVouchersTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountVouchersTimestampList
                                                        ];
        String accountVouchersDelete = '';
        String accountVouchersTimestamp = '';
        
        for(account acc : accountNameVoucherssDeleteList)
        {
            accountVouchersDelete += acc.Name +'\n';
        }
        for(account acct : accountNameVouchersTimestampList)
        {
            accountVouchersTimestamp += acct.Name +'\n';
        }
          if(accountVouchersTimestamp != '')
            {
                returned.statusDescription += 'Vouchers for the next accounts have been overwritten because of online changes: \n'+accountVouchersTimestamp;
            }
            if(accountVouchersDelete != '')
            {
                returned.statusDescription += '\n\nVouchers for the next accounts have been deleted from the online: \n'+accountVouchersDelete;            
            }
          if(returned.statusCode == ERROR_TIMESTAMP_MISMATCH || returned.statusCode == ERROR_RECORD_PREVIOUSLY_DELETED || returned.statusCode == ERROR_USER_HAS_NO_RIGHTS){
               generateBackupDocument(request,paramInfo,false);
               return returned;
          }
          // End_Of    TimeStamp Check  
          
          for(Integer vo : vouchersToInsert.keyset())
          {
            vCampaigns.put(vo, vouchersToInsert.get(vo).voucherCampaignRef__c);
          }
          
          for(Integer vo : vouchersToUpdate.keyset())
          {
            vCampaigns.put(vo, vouchersToUpdate.get(vo).voucherCampaignRef__c);
          }
          
          for( VoucherCampaign__c vc : [SELECT ID, VoucherHungary__c FROM VoucherCampaign__c WHERE id IN :vCampaigns.values() ])
          {
            vcVsVHungary.put(vc.id, vc.VoucherHungary__c);
          }
          
          
          //recorro vli sin cli
          Set<Integer> vouchersToRemove = new Set<Integer>();
          Set<Integer> vlisToRemove = new Set<Integer>();
          for (Integer vo : voWithVliNoCli.keyset())
          {
            List<Integer> vliList = voWithVliNoCli.get(vo);
            for(Integer vliNoCli : vliList)
            {
              if(vouchersToInsert.get(vo).Status__c!='Cancelled')
              {
                List<CampaignLineItem__c> clisToAdd = [SELECT id FROM CampaignLineItem__c WHERE
                            Agreed__c=:voucherLineItemsToInsert.get(vliNoCli).Agreed__c AND
                            ownerId =: Util.CurrentUser.Id AND
                            DistributorRef__c =: vouchersToInsert.get(vo).DistributorRef__c AND
                            FarmRef__c =: vouchersToInsert.get(vo).AccountRef__c AND
                            ProductRef__r.Name =: voucherLineItemsToInsert.get(vliNoCli).ProductName__c AND
                            CampaignRef__c =: vouchersToInsert.get(vo).CampaignRef__c AND
                            ID NOT IN (SELECT CampaignLineItemRef__c 
                                  FROM VoucherLineItem__c 
                                  WHERE VoucherRef__r.AccountRef__c =: vouchersToInsert.get(vo).AccountRef__c AND 
                                      VoucherRef__r.Status__c!='Cancelled')
                            LIMIT 1];
                if(clisToAdd.size()>0) voucherLineItemsToInsert.get(vliNoCli).campaignLineItemRef__c=clisToAdd[0].id;
                else{
                  System.debug('ENRIC ENTRA');
                  vouchersToRemove.add(vo);
                  vlisToRemove.add(vliNoCli);
                }
              }            
            }
          }
          if (vouchersToRemove.size() > 0){
            for(Integer vTR : vouchersToRemove){
          voWithoutCli.add(vTR);
          voWithVli.remove(vTR);
          vouchersToInsert.remove(vTR);
                vouchersToUpdate.remove(vTR);
            }
        }  
          if (vlisToRemove.size() > 0){
            for (Integer vlTR : vlisToRemove){
          vlisWithoutCli.add(vlTR);
                voucherLineItemsToInsert.remove(vlTR);
            }
        }
        System.Debug('TEST ENRIC voWithoutCli' + voWithoutCli + 'voWithVli' + voWithVli +'vouchersToInsert' + vouchersToInsert +'vouchersToUpdate' + vouchersToUpdate +'vlisWithoutCli' + vlisWithoutCli+ 'voucherLineItemsToInsert' + voucherLineItemsToInsert);          
          for(integer vliTi : voucherLineItemsToInsert.keyset())
              {
                  if( voucherlineitemstoinsert.get(vliTi).CampaignLineItemRef__c!=null &&
                      voucherlineitemstoinsert.get(vliTi).Agreed__c != null &&
                      vcVsVHungary.get(vCampaigns.get(vliToInserVoucherIdDevice.get(vliTi))) == true)
                      
                      {
                        vCLI.put(vliTi, voucherlineitemstoinsert.get(vliTi).campaignLineItemRef__c );
                        vCLI2.put(voucherlineitemstoinsert.get(vliTi).campaignLineItemRef__c, vliTi);
                        vBAGS.put(vliTi, voucherlineitemstoinsert.get(vliTi).Agreed__c);
                       }
               }
               
            system.debug('TEST voWithVliC: ' +voWithVliC);  
            system.debug('TEST vliToUpdate2: '+vliToUpdate2);  
            system.debug('TEST vliToUpVoucherIdDevice: '+vliToUpVoucherIdDevice);  
            
            //Query for update VLI (cancelled vouchers) 
            for(VoucherLineItem__c vli : [SELECT id, campaignLineItemRef__c, Bags__c, Agreed__c, idDevice__c from voucherlineitem__c where ID IN :vliToUpdate2.keyset() AND PICK_TYPE__c != 'Free of charge'])
            {
              system.debug('IF1 VLI VLI VLI :' +vli);
              system.debug('IF2 TEST vliToUpVoucherIdDevice: '+vliToUpVoucherIdDevice);  
              system.debug('IF3 vCampaigns : ' +vCampaigns);
              system.debug('IF4 vcVsVHungary : ' +vcVsVHungary);
              system.debug('TEST IF CAMP: ' +vcVsVHungary.get(vCampaigns.get(vliToUpVoucherIdDevice.get(vli.id))));
              
              if(vcVsVHungary.get(vCampaigns.get(vliToUpVoucherIdDevice.get(vli.id))) == true)
              {
                vlitoupdate.put(vli.campaignLineItemRef__c, vli.Agreed__c );
                vCLIup.put(vli.id, vli.campaignLineItemRef__c);
                vCLIup2.put(vli.campaignLineItemRef__c, vli.id );
                vBAGSup.put(vli.id, vli.Agreed__c);
              }
              
            }
            system.debug('vCLIup2  : '+vCLIup2);
            system.debug('vCLI2 :' +vCli2 );
              
              for (CampaignLineItem__c cli : [SELECT ID, 
                                    ProductCatalogEntryRef__c
                                                 FROM campaignLineItem__c 
                                                 WHERE ID IN :vCLI2.keyset()])
                  {
                      if(vCLI2.keyset().contains(cli.id))
                      { 
                        vPCE.put(vCLI2.get(cli.id), cli.ProductCatalogEntryRef__c );
                      }
                  }
                  
             for (CampaignLineItem__c cli : [SELECT ID, 
                                    ProductCatalogEntryRef__c
                                                 FROM campaignLineItem__c 
                                                 WHERE ID IN :vCLIup2.keyset()])      
                  {    
                       if (vCLIup2.keyset().contains(cli.id))
                      {
                    system.debug('ESTA LISTA:  '+vCLIup2);
                      system.debug('CONTIENE: ' +cli.id);
                      system.debug('HAY VLI TO UPDATE?? ' +vliToUpdate);
                      vPCEup.put(vCLIup2.get(cli.id), cli.ProductCatalogEntryRef__c);
                      }
                      
                  }
                  
             for( ProductCatalogEntry__c pce : [SELECT ID, Left__c, in_use__c, Product_Name__c, Allocation__c 
                                                 FROM ProductCatalogEntry__c
                                                 WHERE ID IN :vPCE.values() OR ID IN :vPCEup.values() FOR UPDATE])
                  {
                    vPCEob.put(pce.id,pce);
                  }  
                    
              
              ////COMIENZO A ITERAR SOBRE VOUCHERS
              
              ///PRIMERO LOS CANCELADOS:
              system.debug('LISTA DE VOUCHERS NUEVOS CON VLIS: ' +voWithVli);
              system.debug('LISTA DE PCE OBJECTS:  ' +vPCEob);
              system.debug('LISTA DE PCE NUEVOS ' +vPCE);
              system.debug('LISTA DE BAGS NUEVAS:  ' +vBAGS);
               
                
              system.debug('LISTA DE VOUCHERS CANCELADOS CON VLIS: ' +voWithVlic);
              system.debug('LISTA DE PCE OBJECTS:  ' +vPCEob);
              system.debug('LISTA DE PCE CANCELADOS  ' +vPCEup);
              system.debug('LISTA DE BAGS CANCELADAS:  ' +vBAGSup);
               
              
                  ///Primero quito los Rejected o Waiting for approval
              system.debug('LISTA DE VOUCHER REJECTED O WFA' +voRejOrApproval); 
              for(Integer voToTake : voRejOrApproval)
              {
                voWithVliC.remove(voToTake);
              }
               
               
              for(Integer vo : voWithVliC.keyset())
                {
                  List<Id> vliListC = voWithVliC.get(vo);
                  //Check if stock control is enabled for individual vouchers
                  if(vcVsVHungary.get(vCampaigns.get(vo)))
                  {
                    for(Id vli : vliListC)
                    {
                      //if(vPCEob.get(vPCEup.get(vli))!=null)
                      //  vPCEob.get(vPCEup.get(vli)).in_use__c-=vBAGSup.get(vli);
                      
                    }
                  }
                
                }        
      }catch(Exception e){
            system.debug('EXCEPTION FOUND!!! ' + e);
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription=getErrorDescription(returned.statusCode)+e.getMessage()+'. Line Number: '+e.getLineNumber();
            generateBackupDocument(request,paramInfo,false); 
            return returned;     
        } 
        Savepoint sp1 = Database.setSavepoint();
        try{  
          punto = 0;
          update vPCEob.values();         
        }catch(DMLException dmle){
          system.debug('DML EXCEPTION FOUND!!! ' + dmle);
            generateBackupDocument(request,paramInfo,false);      
           Database.rollback(sp1);
         }catch(Exception e){
          system.debug('EXCEPTION FOUND!!! ' + e);
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription=getErrorDescription(returned.statusCode)+e.getMessage()+'. Line Number: '+e.getLineNumber();          
            generateBackupDocument(request,paramInfo,false);    
            return returned;     
         }
            //// AHORA LOS NUEVOS
        try{
            for(Integer vo: voWithVli.keyset())
              {
                if(vcVsVHungary.get(vCampaigns.get(vo))==true)  
                {  
                    List<Integer> vliList = voWithVli.get(vo);
                    Map<Integer,Decimal> vBAGtemp = new Map<Integer,Decimal>();
                    Integer hasStock=0;
                    
                    for(Integer vli : vliList)
                    {
                      if((vPCEob.get(vPCE.get(vli)).Allocation__c - vPCEob.get(vPCE.get(vli)).in_use__c) >= vBAGS.get(vli))
                      {
                        hasStock=hasStock+1;
                        //vBAGtemp=put(vli,vBAGS.get(vli));
                      }
                      
                    }
                    
                    if(vliList.size() == hasStock)   // SI TODOS LOS VLI TIENEN STOCK
                    {
                      for (Integer vli : vliList)
                      {
                        //vPCEob.get(vPCE.get(vli)).in_use__c+=vBAGS.get(vli);
                      }
                    }
                    else  // SI NO LO TIENEN
                    {  
                      for (Integer vli : vliList)
                      {
                        voucherLineItemsToInsert.remove(vli); 
                        voucherLineItemsToReject.put(vli,voucherLineItemsToInsert.get(vli));
                      }
                      
                      vouchersToReject.put(vo,vouchersToInsert.get(vo));
                      vouchersToInsert.remove(vo);
                      vouchersToUpdate.remove(vo);
                      
                    }
                }      
              }          
        }catch(Exception e){
          system.debug('EXCEPTION FOUND!!! ' + e);
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription=getErrorDescription(returned.statusCode)+e.getMessage()+'. Line Number: '+e.getLineNumber();          
            generateBackupDocument(request,paramInfo,false); 
            return returned;     
    }          
    try{    
      update vPCEob.values();              
    }catch(DMLException dmle){
        system.debug('DML EXCEPTION FOUND!!! ' + dmle);
        generateBackupDocument(request,paramInfo,false);   
       Database.rollback(sp1);
     }catch(Exception e){
      system.debug('EXCEPTION FOUND!!! ' + e);
        returned.statusCode = ERROR_UNKNOWN;
        returned.statusDescription=getErrorDescription(returned.statusCode)+e.getMessage()+'. Line Number: '+e.getLineNumber();
        generateBackupDocument(request,paramInfo,false);
        return returned;     
    }
    try{        
       for (Integer vliTR : VoucherLineItemsToReject.keyset())
          {
              for(REST_VoucherLineItemObject rvli : returned.voucherLineItems)
              {
                  if(rvli.voucherlineitem.idDevice__c == vliTR)
                  {
                        rvli.statusCode = ERROR_NOT_ENOUGH_STOCK;
                       rvli.statusDescription='There is not enough stock for product '+vliToRejectName.get(vliTR)+'. REQUESTED: '+vBAGS.get(vliTR)+' AVALIABLE: '+(vPCEob.get(vPCE.get(vliTR)).Allocation__c - vPCEob.get(vPCE.get(vliTR)).in_use__c);
                       stockErrors=stockErrors+1;
                  }
                  
              }
          }
         
        for (Integer vTR : VouchersToReject.keyset())
          {
              for(REST_VoucherObject rvo : returned.vouchers)
              {
                  if(rvo.Voucher.IdDevice__c == vTR)
                  {
                       rvo.statusCode = ERROR_NOT_ENOUGH_STOCK;
                       rvo.statusDescription=getErrorDescription(rvo.statusCode);
                       stockErrors=stockErrors+1;
                  }
                  
              }
          } 
          
          for (Integer vNotToCancel : voRejOrApproval )
          {
            for(REST_VoucherObject rvo : returned.vouchers)
              {
                  if(rvo.Voucher.IdDevice__c == vNotToCancel)
                  {
                       rvo.statusCode = ERROR_TIMESTAMP_MISMATCH;
                       rvo.statusDescription=getErrorDescription(rvo.statusCode);
                       
                  }
                  
              }
          }
          
          //Add Error of VLI without CLI
          
          for (Integer vErr : voWithoutCLI)
          {
            for (REST_VoucherObject rvo : returned.vouchers)
            {
              if(rvo.Voucher.IdDevice__c == vErr)
              {
                rvo.StatusCode=ERROR_UNKNOWN;
                rvo.statusDescription=getErrorDescription(rvo.statusCode);
              }
            }
          }
          
          for (Integer vliErr : vlisWithoutCli)
          {
              for(REST_VoucherLineItemObject rvli : returned.voucherLineItems)
              {
                  if(rvli.voucherlineitem.idDevice__c == vliErr)
                  {
                       rvli.StatusCode=ERROR_UNKNOWN;
                rvli.statusDescription=getErrorDescription(rvli.statusCode);
                  }
                  
              }
          }
          
          
          if(vouchersToReject.size()==0)
          {
              returned.statusCode = 100;
              returned.statusDescription = 'Processed';
          }
          else if (vouchersToInsert.size()==0)
          {
              returned.statusCode=103;
              returned.statusDescription= 'Stock errors';
          }
          else
          {
              returned.statusCode=102;
              returned.statusDescription= 'Processed with some errors.';
          }
    }catch(Exception e){  
          system.debug('EXCEPTION FOUND!!! ' + e);
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription=getErrorDescription(returned.statusCode)+e.getMessage()+'. Line Number: '+e.getLineNumber();
            generateBackupDocument(request,paramInfo,false);
            return returned;     
    }  
  Savepoint sp = Database.setSavepoint();
  System.Debug('TEST ENRIC 2 voWithoutCli' + voWithoutCli + 'voWithVli' + voWithVli +'vouchersToInsert' + vouchersToInsert +'vouchersToUpdate' + vouchersToUpdate +'vlisWithoutCli' + vlisWithoutCli+ 'voucherLineItemsToInsert' + voucherLineItemsToInsert);          
  
  try{
        punto = 1;
        
            delete vouchersToDelete;
           
            punto = 2;
           
            insert vouchersToInsert.values();
            
            punto = 3;
            
            update vouchersToUpdate.values();
            
            punto = 4;
            
            delete voucherLineItemsToDelete;
            
            for(REST_VoucherLineItemObject rvli : returned.voucherLineItems){
                if(rvli.voucherLineItem.id != null && mapVLIsUpdate.containsKey(rvli.voucherLineItem.id)){
                    rvli.statusCode=100;
                }
            }            
            
            for(REST_VoucherLineItemObject rvli : returned.voucherLineItems){
                if(rvli.VoucherIdDevice != 0 && rvli.voucherLineItem.VoucherRef__c == null && vouchersToInsert.size()>0 && vouchersToInsert.keyset().contains(rvli.VoucherIdDevice)){
                    rvli.voucherLineItem.VoucherRef__c = vouchersToInsert.get(rvli.VoucherIdDevice).id;    
                }
            }
      
      punto = 5;
        
            insert voucherLineItemsToInsert.values();
            
            punto = 6;
            
            update voucherLineItemsToUpdate;
            
            punto = 7;
            
            update vouchersToReassign.values();
            
            
            List<Attachment> signaturesToInsert = new List<Attachment>();

            for(REST_VoucherObject rvo : returned.vouchers){
                if ('Insert'.equalsIgnoreCase(rvo.action) &&  rvo.voucher.Status__c == 'Closed' && rvo.voucher.Signed__c == true && vouchersToInsert.keyset().contains(Integer.valueOf(rvo.voucher.idDevice__c))) 
                {
                    if (rvo.signature != null)
                        signaturesToInsert.add(new Attachment(parentID = rvo.voucher.id, name='Signature.png', body = EncodingUtil.base64Decode(rvo.signature)));
                    else{
                        throw new REST_ERROR_CODES.REST_Exception(REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND,rvo.voucher.id);
                    }
                }
            }
            if(vouchersToInsert.size()>0)  ////CHANGE
            
            punto = 8;
             
            insert signaturesToInsert; 

            Map<ID,Voucher__c> vouchersToGet = new Map<ID,Voucher__c>([SELECT Name, LastModifiedDate FROM Voucher__c WHERE ID IN :vouchersToUpdate.values()]);
             //Set all the error codes to 100 and fill LastModifiedDate if possible
           if(vouchersToGet.size()>0 )
           {
           
                for(REST_VoucherObject rvo : returned.vouchers){
                  if(vouchersToUpdate.keyset().contains(Integer.valueOf(rvo.voucher.idDevice__c)))
                  {
                    rvo.statusCode = 100;
                rvo.statusDescription = 'Processed';
                  }
                      
                    if(!'Delete'.equalsIgnoreCase(rvo.action) && vouchersToUpdate.keyset().contains(Integer.valueOf(rvo.voucher.idDevice__c)) ){
                        rvo.LastModifiedDate = vouchersToGet.get(rvo.voucher.id).LastModifiedDate;
                        rvo.voucher.Name=vouchersToGet.get(rvo.voucher.id).Name;
                        
                    }
                }
           }  
           
            Map<ID,VoucherLineItem__c> voucherLineItemsToGet = new Map<ID,VoucherLineItem__c>([SELECT  LastModifiedDate, CampaignLineItemRef__c FROM VoucherLineItem__c WHERE (ID IN :voucherLineItemsToInsert.values() OR ID IN :voucherLineItemsToUpdate) AND PICK_TYPE__c != 'Free of charge']);
           if(voucherLineItemsToGet.size()>0 )
           {
                for(REST_VoucherLineItemObject rvli : returned.voucherLineItems)
                {
                  if(voucherLineItemsToInsert.keyset().contains(Integer.valueOf(rvli.voucherlineitem.idDevice__c)) && voucherLineItemsToGet.keyset().contains(rvli.voucherLineItem.id))
                    {  
                        rvli.statusCode = 100;
                        rvli.statusDescription = 'Processed';
                        if(!'Delete'.equalsIgnoreCase(rvli.action))
                          {
                            rvli.LastModifiedDate = voucherLineItemsToGet.get(rvli.voucherLineItem.id).LastModifiedDate;
                            rvli.voucherLineItem.CampaignLineItemRef__c=voucherLineItemsToGet.get(rvli.voucherLineItem.id).CampaignLineItemRef__c;
                          }
                     }
                  }
           }    
       
       if(vouchersToInsert.size()>0)
       {
          Approval.ProcessSubmitRequest[] app = new List<Approval.ProcessSubmitRequest>();
            for(Voucher__c vTi : vouchersToInsert.values())
            {
              Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitRequest();
              app1.setObjectId(vTi.id);
              app.add(app1);
            }
        
          List<Approval.ProcessResult> result = Approval.process(app, false);
         
         /*for(Approval.ProcessResult res: result )
         {
          system.debug('APPROVAL PROCESS RESULTS' +res.getErrors()); 
         }*/
       }  
          generateBackupDocument(request,paramInfo,true);
            
        }catch(DMLException e){
          String errorMsg = '';
          String accId;
          String voucherId;
          String voucherIdInsert;
          for(Integer i = 0; i<e.getNumDMl(); i++){
              errorMsg += e.getDmlMessage(i);
            if(e.getDmlFields(i)!=null &&  e.getDmlFields(i).size()>0)
                errorMsg += ' : ' + e.getDmlFields(i)[0].getDescribe().getLabel() + ' ';
            if(punto == 1 && vouchersToDelete[e.getDmlIndex(i)]!= null && vouchersToDelete[e.getDmlIndex(i)].AccountRef__c != null)
                {
                  accId = vouchersToDelete[e.getDmlIndex(i)].AccountRef__c;
                  
                }
            if(punto == 2 && vouchersToInsert.values()[e.getDmlIndex(i)]!= null && vouchersToInsert.values()[e.getDmlIndex(i)].AccountRef__c != null)
                {
                  accId = vouchersToInsert.values()[e.getDmlIndex(i)].AccountRef__c;
                  
                }  
            if(punto == 3 && vouchersToUpdate.values()[e.getDmlIndex(i)]!= null && vouchersToUpdate.values()[e.getDmlIndex(i)].AccountRef__c != null)
                {
                  accId = vouchersToUpdate.values()[e.getDmlIndex(i)].AccountRef__c;
                  
                }
            if(punto == 4 && voucherLineItemsToDelete[e.getDmlIndex(i)]!= null && voucherLineItemsToDelete[e.getDmlIndex(i)].VoucherRef__c != null)
                {
                  voucherId = voucherLineItemsToDelete[e.getDmlIndex(i)].VoucherRef__c;
                }
            if(punto == 5 && voucherLineItemsToInsert.values()[e.getDmlIndex(i)]!= null && voucherLineItemsToInsert.values()[e.getDmlIndex(i)].VoucherRef__c != null)
                {                  
                  voucherIdInsert = vouchersToInsert.get(Integer.valueOf(voucherLineItemsToInsert.values()[e.getDmlIndex(i)].IdDevice__c)).AccountRef__c;
                }  
            if(punto == 6 && voucherLineItemsToUpdate[e.getDmlIndex(i)]!= null && voucherLineItemsToUpdate[e.getDmlIndex(i)].VoucherRef__c != null)
                {
                  voucherId = voucherLineItemsToUpdate[e.getDmlIndex(i)].VoucherRef__c;
                  
                }  
            if(punto == 7 && vouchersToReassign.values()[e.getDmlIndex(i)]!= null && vouchersToReassign.values()[e.getDmlIndex(i)].AccountRef__c != null)
                {
                  accId = vouchersToReassign.values()[e.getDmlIndex(i)].AccountRef__c;
                  
                }  
     /*     if(punto == 8 && signaturesToInsert[e.getDmlIndex(i)]!= null && signaturesToInsert[e.getDmlIndex(i)]. != null)
                {
                  accId = signaturesToInsert[e.getDmlIndex(i)].;
                  
                }  
                */
          }      
          
            system.debug('DML EXCEPTION FOUND!!! ' + e);
            Database.rollback(sp);
            ID itemFailed;
            String ee ='' + e;
            if((''+e).contains(';'))
                if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
            
            Account acc;
            Voucher__c vouc;
            
            if(accId!=null){
                       acc = [SELECT name FROM Account WHERE id=:accId];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' +acc.name + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
            if(voucherId!=null){
                       vouc = [SELECT name, AccountRef__r.name  FROM Voucher__c WHERE id=:voucherId];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'voucher: ' +vouc.name + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
            if(voucherIdInsert!=null){
                       acc = [SELECT name FROM Account WHERE id=:voucherIdInsert];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' +acc.name + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
                      
            returned.statusDescription = '';
            if((''+e).contains('to review the status of this')){
                returned.statusCode = ERROR_STATUS_CHANGE_NOT_ALLOWED;
            }else{
                returned.statusCode = ERROR_UNKNOWN;
                returned.statusDescription = errorMsg;
            }
            
            returned.statusDescription =  (returned.statusCode==ERROR_UNKNOWN ? '' : (getErrorDescription(returned.statusCode)))+ returned.statusDescription;
            
            if(itemFailed!=null){
                for(REST_VoucherObject rvo : returned.vouchers){
                    if(rvo.voucher.id == itemFailed){
                        rvo.statusCode = returned.statusCode;
                        rvo.statusDescription = returned.statusDescription;
                    }else{
                        rvo.statusCode = ERROR_NOT_PROCESSED;
                        rvo.statusDescription = getErrorDescription(rvo.statusCode);
                    }
                }
                for(REST_VoucherLineItemObject rvli : returned.voucherLineItems){
                    if(rvli.voucherLineItem.id == itemFailed){
                        rvli.statusCode = returned.statusCode;
                        rvli.statusDescription = returned.statusDescription;
                    }else{
                        rvli.statusCode = ERROR_NOT_PROCESSED;
                        rvli.statusDescription = getErrorDescription(rvli.statusCode);
                    }
                }
            }
            generateBackupDocument(request,paramInfo,false);
            
            
//        to review the status of this 
        }catch(Exception e){
            system.debug('EXCEPTION FOUND!!! ' + e);
            Database.rollback(sp);
            
            returned.statusCode = ERROR_UNKNOWN;
            returned.statusDescription = '' + e;
            returned.statusDescription = getErrorDescription(returned.statusCode) + returned.statusDescription + '. Line Number: ' + e.getLineNumber();
            generateBackupDocument(request,paramInfo,false);
        }
        
        return returned;
    }
    
    global class REST_SendLogicalEntityVoucher{
        public Integer statusCode;
        public String statusDescription;
        
        public List<REST_VoucherObject> vouchers;
        public List<REST_VoucherLineItemObject> voucherLineItems;
    }
    
    global class REST_VoucherObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;       
        public DateTime LastModifiedDate;           
        public Voucher__c voucher;
        public String signature;       
    }
    
    global class REST_VoucherLineItemObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;       
        public DateTime LastModifiedDate;      
        public Integer VoucherIdDevice;        
        public VoucherLineItem__c voucherLineItem;
    }
    
    
    // Errors Description
    private static Integer ERROR_STATUS_CHANGE_NOT_ALLOWED = 105;
    
    private static Integer ERROR_TIMESTAMP_MISMATCH = 200;
    private static Integer ERROR_RECORD_PREVIOUSLY_DELETED = 201;
    private static Integer ERROR_USER_HAS_NO_RIGHTS = 202;
    
    private static Integer ERROR_NOT_PROCESSED = 998;
    private static Integer ERROR_UNKNOWN = 999;
    
    private static Integer ERROR_NOT_ENOUGH_STOCK = 997; ///?
    
    private static String getErrorDescription(Integer paramError){
        if(paramError == ERROR_STATUS_CHANGE_NOT_ALLOWED) return 'You are not allowed to change Status field';
        
        if(paramError == ERROR_TIMESTAMP_MISMATCH) return 'Record was updated on the server before sync';
        if(paramError == ERROR_RECORD_PREVIOUSLY_DELETED) return 'Record was deleted on the server before sync';
        if(paramError == ERROR_USER_HAS_NO_RIGHTS) return 'This user does not have enougth rights to perform this operation';
        
        if(paramError == ERROR_NOT_PROCESSED) return 'Item Not Processed or no Error Found';
        if(paramError == ERROR_UNKNOWN) return 'Unknown Error: ';
        if(paramError == ERROR_NOT_ENOUGH_STOCK) return 'There is not enough stock for some products';
        
        return 'Unknown Error2: ';
    }
    
   /* @HttpGet
    global static REST_SendLogicalEntityVoucher getExample()
    {
        REST_SendLogicalEntityVoucher returned = new REST_SendLogicalEntityVoucher();
        returned.statusCode=100;
        returned.statusDescription=null;
        returned.vouchers = new List<REST_VoucherObject>();
        returned.voucherLineItems= new List<REST_VoucherLineItemObject>();
     
        returned.vouchers.
        voucher = [SELECT ID FROM Voucher__c WHERE OwnerID=:Util.currentUser.ID LIMIT 1];
        returned.voucherLineItems.voucherLineItem = [SELECT ID FROM VoucherLineItem__c WHERE OwnerID=:Util.currentUser.ID LIMIT 1];
        
        return returned;
    }*/
    
    /**Generate Backup Document according to the system settings logging value
    *
    * @param status: false when an error happens. True if everything is ok
    * 
    *
    * None: No documents are generated.
    * Exception: Documents are generated only when an exception is thrown
    * All: A document is generated always.
    * 
    */
    private static void generateBackupDocument(String request, REST_SendLogicalEntityVoucher response, boolean status){
        if((
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all'
        ) {
            String documentName='REST_SendLogicalEntityVoucher'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
            String logFolder=systemSettings__c.getvalues(Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER').Value__c;
            
            if (status){
                documentName = documentName+'_OK';
            }
            else{
                documentName = documentName+'_ERR';
            }
            
             
            documentName=documentName.remove(':').remove(' ').remove('-');
            
            System.debug('Document Name: ' + documentName);
            String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n'+System.JSON.serializePretty(response);
            Blob documentBody= Blob.valueOf(body);
            list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName =:logFolder  AND Type = 'Document'];
            if (destFolder.size() == 1) { 
                Document doc= new Document(Name = documentName , body=documentBody,developerName=documentName, IsPublic = true, FolderId=destFolder[0].Id, contentType='text/plain',type='json' );
                insert doc;
            }
            else {
                system.debug('SharedDocuments folder not found or returned too many values: ' + destFolder);
            }
        }
        else if (systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c!='none'){
            system.debug('Warning: Unexpected value in System Setting \'EAST_REST_SVC_JSON_SAVE\'. Expected values are \'None\', \'Exceptioin\' or \'All\'');
        }
    }
    
    
 
    
}