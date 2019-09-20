/**
 * @description Tests for AccountTriggerHandler Apex Controller
 * @author Jason Snyder
 * @created 09/20/2019
 */

@isTest
public with sharing class AccountTriggerHandler_Test {

    @testSetup
    static void setup(){
        // Create Accounts
        Account acc1 = new Account(
            Name='Jason Snyder',
            Primary_Experience_Reference__c='LinkedIn',
            LinkedIn_URL__c='https=//www.linkedin.com/in/jason-snyder2/',
            Trailhead_URL__c='https=//trailhead.salesforce.com/en/me/jsnyder4',
            Phone='5747802700',
            Industry='Technology',
            ShippingStreet='10708 Snowdrop Way',
            ShippingCity='Indianapolis',
            ShippingState='Indiana',
            ShippingPostalCode='46235',
            ShippingCountry='United States');
        insert acc1;

        Account acc2 = new Account(
            Name='Jason Snyder2',
            Primary_Experience_Reference__c='Trailhead',
            LinkedIn_URL__c='https=//www.linkedin.com/in/jason-snyder2/',
            Trailhead_URL__c='https=//trailhead.salesforce.com/en/me/jsnyder4',
            Phone='5747802700',
            Industry='Technology',
            ShippingStreet='10708 Snowdrop Way',
            ShippingCity='Indianapolis',
            ShippingState='Indiana',
            ShippingPostalCode='46235',
            ShippingCountry='United States');
        insert acc2;

        // Create Opportunities
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 6; i++) {
            Opportunity opp = new Opportunity(
                Name=('Acc1 Opp ' + String.valueOf(i)),
                StageName='Negotiation/Review',
                CloseDate=Date.today().addDays(7));
            if(i < 3) {
                opp.AccountId=acc1.Id;
                opp.Interest_Description__c='We should hire this guy, look at this LinkedIn!';
                opp.Experience_URL__c='https://www.linkedin.com/in/jason-snyder2/';
            }
            else {
                opp.AccountId=acc2.Id;
                opp.Interest_Description__c='We should hire this guy, look at this LinkedIn!';
                opp.Experience_URL__c='https://trailhead.salesforce.com/me/jsnyder4';
            }
            oppList.add(opp);
        }
        insert oppList;
    }

    @isTest
    static void testHandleAfterUpdate() {
        List<Account> accList = new List<Account>{[SELECT Id FROM Account WHERE Name='Jason Snyder'],[SELECT Id FROM Account WHERE Name='Jason Snyder2']};

        Test.startTest();
        accList.get(0).Primary_Experience_Reference__c='Trailhead';
        accList.get(1).Primary_Experience_Reference__c='LinkedIn';
        update accList;
        Test.stopTest();

        List<Opportunity> acc1Opps = [SELECT Id, Interest_Description__c FROM Opportunity WHERE AccountId=:accList.get(0).Id];
        List<Opportunity> acc2Opps = [SELECT Id, Interest_Description__c FROM Opportunity WHERE AccountId=:accList.get(1).Id];

        // Test that Account 1 opps changed
        for(Opportunity opp : acc1Opps) {
            system.assertEquals('We should add this guy to the team, look at these badges!', opp.Interest_Description__c);
        }
         // Test that Account 2 opps did not change
        for(Opportunity opp : acc2Opps) {
            system.assertEquals('We should hire this guy, look at this LinkedIn!', opp.Interest_Description__c);
        }
    }

}
