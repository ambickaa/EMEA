/*
Trigger name  - Trg_TaskAfterInsertUpdate
Description-  Trigger for updating First Response date /time on case
Created By - Accenture IDC
*/
trigger Trg_TaskAfterInsertUpdate on Task (after insert,after update) {
 if(checkRecursive.runOnce2()){
    if(trigger.isafter && trigger.isinsert){
           
           Hlpr_GlobalFirstResponseDate.processTasks(trigger.new);  
          
    }
  } 
}