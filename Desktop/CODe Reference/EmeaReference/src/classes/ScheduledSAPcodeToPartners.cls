global class ScheduledSAPcodeToPartners implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        // Implement any logic to be scheduled
        
        // We now call the batch class to be scheduled
        orderAuxDatagenerator b = new orderAuxDatagenerator(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,1000);
    }
    
}