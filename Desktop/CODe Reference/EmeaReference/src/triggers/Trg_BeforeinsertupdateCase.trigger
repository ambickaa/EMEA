Trigger Trg_BeforeinsertupdateCase on case(before insert,before update)
{
    if(checkRecursive.runOnce1()){
         HlprlocaltoUSDCurren ch1 = new HlprlocaltoUSDCurren();
         if((trigger.isInsert && trigger.isbefore)||(trigger.isbefore && trigger.isUpdate))
         {
              ch1.currencyUpdate(trigger.new);
              Hlpr_customApproval.beforeinsertupdate(trigger.new);// 
              HLPR_autoPopultaePSA.processInsert(trigger.new);
              HLPR_ArtcleUpdateCase.processRecords(trigger.new);
              if(trigger.isbefore && trigger.isUpdate)//
             {
                     system.debug('--------------Befor Update---');
                     Hlpr_customApproval.beforeupdate(trigger.new,trigger.oldMap);//
                     HLPR_GlobalCaseRollup.storeoldvalues(trigger.oldMap);
             }
         }
        
        //Code added for optimization of roll-up calculation
        if (trigger.isInsert && trigger.isbefore)
        {
            HLPR_GlobalCaseRollup.Resetfields(trigger.new);
            Hlpr_CaseUpdateAccount.updateAccount(trigger.new); //Added by ACS AO PS 9/6/2016:  implemented for eFax request(Request-25271)
        }
     } 
  }