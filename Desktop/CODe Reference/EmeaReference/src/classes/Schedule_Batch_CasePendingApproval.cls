Global class Schedule_Batch_CasePendingApproval implements Schedulable {
global void execute(SchedulableContext sc) {
    Batch_CasePendingApproval b = new Batch_CasePendingApproval(); 
    database.executebatch(b,200);
     }
}