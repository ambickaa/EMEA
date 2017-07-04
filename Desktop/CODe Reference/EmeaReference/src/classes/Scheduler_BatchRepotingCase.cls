Global class Scheduler_BatchRepotingCase implements Schedulable {
global void execute(SchedulableContext sc) {
    BatchRepotingCase b = new BatchRepotingCase(); 
    database.executebatch(b,200);
    }
}