public interface AccountListInterface
{
    // save for lines
    PageReference save();
    // returns pagereference without changing anything
    PageReference cancel();
    // checks if the list is filled with records
    boolean getIsList();
    // edit mode
    PageReference edit();
    // delete records with this function
    PageReference deletex();
    // creation of a new line
    PageReference newRecord();
}