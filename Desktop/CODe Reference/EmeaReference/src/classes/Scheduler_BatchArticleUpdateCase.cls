Global class Scheduler_BatchArticleUpdateCase implements Schedulable {
global void execute(SchedulableContext sc) {
    BatchArticleUpdateCase b = new BatchArticleUpdateCase(); 
    database.executebatch(b,200);
     }
}