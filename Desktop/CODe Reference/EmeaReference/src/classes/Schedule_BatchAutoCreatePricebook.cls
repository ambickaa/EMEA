global class Schedule_BatchAutoCreatePricebook implements Schedulable {

    global void execute(SchedulableContext sc) {

        BatchAutoCreatePricebook b = new BatchAutoCreatePricebook();
        database.executebatch(b,5000);
    }
}