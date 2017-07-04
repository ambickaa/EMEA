global class ScheduledWhiteLabelsLines implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        // Implement any logic to be scheduled
        
        // We now call the batch class to be scheduled
        BatchWhiteLabelLines b = new BatchWhiteLabelLines(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,15);
    }
    
}