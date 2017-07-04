Global class Scheduler_Batch_StatusUpdate implements Schedulable {
    global void execute(SchedulableContext sc)
     {    
     Batch_StatusUpdate b = new Batch_StatusUpdate(); 
     database.executebatch(b,200);
     }
     }