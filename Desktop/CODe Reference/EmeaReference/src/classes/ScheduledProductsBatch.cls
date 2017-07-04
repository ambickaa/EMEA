global class ScheduledProductsBatch implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        // Implement any logic to be scheduled
        
        // We now call the batch class to be scheduled
        WSPRoductsBatch b = new WSPRoductsBatch(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,1);
    }
    
}