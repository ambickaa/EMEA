global class DailySchedulable implements Schedulable {
   global void execute(SchedulableContext sc) { 
      MassUpdaterBatchable b1 = new MassUpdaterBatchable(); 
      b1.BudgetMode=true;
      database.executebatch(b1);
            
   }
}