@isTest
private class TestCustomController {

    // Yes it's bad, but it's just a placeholder
    static testMethod void testCoverage() {
       // Create some unit test data
        Account a = new Account(Name='Test 1');
        insert a;
        Opportunity o = new Opportunity(Name='Test Opp', AccountId=a.id, CloseDate=System.today(), Amount=100, StageName='Prospecting');
        insert o;
        Product2 p = new Product2(Name='Test Product', Family='Unit Test');
        insert p;
        
        // Get Standard Pricebook
        Id pricebookid = Test.getStandardPricebookId();
        PriceBookEntry pbe = new PriceBookEntry(PriceBook2Id = pricebookid,
                                                Product2Id = p.Id,
                                                UnitPrice = 100,
                                                IsActive = true
                                               );
        insert pbe;
        
        // Create one initial line item
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = o.id;
        oli1.TotalPrice = 100;
        oli1.PricebookEntryId = pbe.Id;
        oli1.Quantity = 1;
        insert oli1;
        
        Test.startTest();        
        
		CustomControllerDemo.getProducts(null);
        CustomControllerDemo.getOpportunityLineItems(null);
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        oli1.Quantity = 2;
        lineItems.add(oli1);
        OpportunityLineItem oli2 = oli1.clone();
		insert oli2;
        oli2.Quantity = 0;
        lineItems.add(oli2);
        
        try {
            CustomControllerDemo.saveOpportunityLineItems(lineItems);
            CustomControllerDemo.saveOpportunityLineItems2(lineItems);
        }
        catch (AuraHandledException ahe) {
        	// Don't worry it's on purpose   
        	System.debug('ahe handled: '+ahe.getMessage());     
        }        
        OpportunityLineItem oli = [SELECT Quantity FROM OpportunityLineItem WHERE id = :oli1.id];
        System.assertEquals(2, oli.Quantity);
        Test.stopTest();
    }
}