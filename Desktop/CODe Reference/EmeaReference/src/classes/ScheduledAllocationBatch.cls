global class ScheduledAllocationBatch implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        //Num of days to be treated defined at custom label
        Integer numDays = integer.valueof(System.Label.OE2_0_Allocation_Batch_N_days.trim());

        // We now call the batch class to be scheduled
        ProductAllocationBatch b = new ProductAllocationBatch(numDays); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
    
}