public interface AccountListObjectWrapper
{
    // get selected records to delete these records later
    List<sObject> getSelectedRecords();
    // get filled records to save these records
    List<sObject> getFilledRecords();
}