// Just added some text for CI Integration test
public class CustomControllerDemo {
    @AuraEnabled
    public static List<PricebookEntry> getProducts(ID priceBookId) {
        // Want to test validation rule for inactive products
        /* return [SELECT Id, Name, ProductCode, UnitPrice 
                FROM PricebookEntry 
                WHERE IsActive = true 
                AND Pricebook2Id = :priceBookId
                ORDER BY ProductCode ASC]; */
        return [SELECT Id, Name, ProductCode, UnitPrice 
                FROM PricebookEntry 
                WHERE Pricebook2Id = :priceBookId
                ORDER BY ProductCode ASC];
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItems(ID OpportunityId) {
        return [SELECT Id, Name, PricebookEntryId, OpportunityId, ListPrice, ProductCode, Quantity, 
                              TotalPrice, UnitPrice, Contract_Type__c
                FROM OpportunityLineItem 
                WHERE OpportunityId = :OpportunityId];
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> saveOpportunityLineItems(List<OpportunityLineItem> lineItems) {
        List<OpportunityLineItem> upsertLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> deleteLineItems = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem li : lineItems) {
            if (li.Quantity == 0) {
                deleteLineItems.add(li);
            } else {
                upsertLineItems.add(li);                
            }
        }
        upsert upsertLineItems;
        delete deleteLineItems;
        
        return getOpportunityLineItems(lineItems[0].OpportunityId);
    }
    
    /* This time, lets handle some exceptions */
    @AuraEnabled
    public static List<OpportunityLineItem> saveOpportunityLineItems2(List<OpportunityLineItem> lineItems) {
        List<OpportunityLineItem> upsertLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> deleteLineItems = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem li : lineItems) {
            if (li.Quantity == 0) {
                deleteLineItems.add(li);
            } else {
                upsertLineItems.add(li);                
            }
        }
        
        try {
            upsert upsertLineItems;
            delete deleteLineItems;
        }
        catch (DMLException dmlex) {
            System.debug('CustomControllerDemo: Exception saving line items '+dmlex.getMessage());
            AuraHandledException ahe = new AuraHandledException('DML Exception: '+dmlex.getMessage());
            // What happens when we don't setMessage? Try it and see!
            ahe.setMessage('Error saving line items, please check the message and try again: '+dmlex.getMessage());
            throw ahe;
        }
        catch (Exception ex) {
            System.debug('CustomControllerDemo: Unexpected Exception saving line items '+ex.getStackTraceString());
            AuraHandledException ahe = new AuraHandledException('Oops, something went wrong: '+ex.getMessage());
            ahe.setMessage('Unexpected error, please report to your Salesforce Admin: '+ex.getMessage());
            throw ahe;
        }        
        return getOpportunityLineItems(lineItems[0].OpportunityId);
    }
    
    
}