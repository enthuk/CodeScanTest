public class DummyController {

    @AuraEnabled
    public static void generateUnhandledException(String type) {
        // If we had Summer 18 I'd be using a Switch/Case statement already, just saying...
        if (type == 'DMLException') {
            Account a = new Account();
            insert a; // ooops!
        }
        else
        {
            Account a;
            a.name = 'Ooopsy';
        }
    }
    
    @AuraEnabled
    public static void generateHandledException(String type) {
        try {
            if (type == 'DMLException') {
                Account a = new Account();
                insert a; // ooops!
            }
            else
            {
                Account a;
                a.name = 'Ooopsy';
            }
        }
        catch (DMLException dmlex) {
            System.debug(dmlex.getMessage());
            AuraHandledException ahe = new AuraHandledException('Unable to save the record, please review the reasons: '+dmlex.getMessage());
            //This is what appears in the debug log
            ahe.setMessage(dmlex.getMessage());
            throw ahe;
            //throw dmlex;
        }   
        catch (Exception ex) {
            System.debug(ex.getMessage());
            AuraHandledException ahe = new AuraHandledException('Unexpected error: '+ex.getMessage() + 
                                                                '. Your Salesforce Admin has been notified.');
            ahe.setMessage('System Exception in generateHandledException: type='+type + 
                           ' : '+ex.getMessage()+' : '+ex.getCause());
            throw ahe;
        }
    }
    
    @AuraEnabled
    public static void generateDuplicate() {
        Lead l = new Lead(FirstName = 'John', LastName = 'Doe', email='JohnDoe@gmail.com', company='Provar');
        insert l;
        l.id = null;
        insert l;
    }
    
    
}