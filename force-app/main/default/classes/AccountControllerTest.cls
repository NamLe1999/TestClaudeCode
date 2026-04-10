/**
 * @description Test class for AccountController.
 * @author      Antigravity
 * @date        2026-04-09
 */
@IsTest
private class AccountControllerTest {

    /**
     * @description Creates test data shared across all test methods.
     */
    @TestSetup
    static void setupTestData() {
        // Create a parent Account
        Account parentAccount = new Account(
            Name        = 'Parent Account',
            Industry    = 'Technology',
            Type        = 'Partner',
            Phone       = '0123456789',
            Website     = 'https://parent.example.com',
            Rating      = 'Hot',
            BillingCity = 'Ho Chi Minh City',
            BillingCountry = 'Vietnam'
        );
        insert parentAccount;

        // Create child Accounts
        List<Account> testAccounts = new List<Account>{
            new Account(
                Name             = 'Alpha Corp',
                Industry         = 'Finance',
                Type             = 'Customer',
                Phone            = '0111111111',
                Website          = 'https://alpha.example.com',
                Rating           = 'Cold',
                ParentId         = parentAccount.Id,
                BillingCity      = 'Hanoi',
                BillingCountry   = 'Vietnam',
                NumberOfEmployees = 50,
                AnnualRevenue    = 1000000
            ),
            new Account(
                Name             = 'Beta Solutions',
                Industry         = 'Consulting',
                Type             = 'Prospect',
                Phone            = '0222222222',
                Website          = 'https://beta.example.com',
                Rating           = 'Warm',
                ParentId         = parentAccount.Id,
                BillingCity      = 'Da Nang',
                BillingCountry   = 'Vietnam',
                NumberOfEmployees = 120,
                AnnualRevenue    = 5000000
            ),
            new Account(
                Name             = 'Gamma Enterprises',
                Industry         = 'Manufacturing',
                Type             = 'Customer',
                Phone            = '0333333333',
                Website          = 'https://gamma.example.com',
                Rating           = 'Hot',
                ParentId         = parentAccount.Id,
                BillingCity      = 'Can Tho',
                BillingCountry   = 'Vietnam',
                NumberOfEmployees = 300,
                AnnualRevenue    = 20000000
            )
        };
        insert testAccounts;
    }

    // ─────────────────────────────────────────────
    // getAllAccounts
    // ─────────────────────────────────────────────

    @IsTest
    static void testGetAllAccounts_returnsAccounts() {
        Test.startTest();
        List<Account> result = AccountController.getAllAccounts();
        Test.stopTest();

        // Expect at least 4 records (1 parent + 3 children)
        Assert.isTrue(result.size() >= 4, 'Expected at least 4 Account records to be returned.');
    }

    @IsTest
    static void testGetAllAccounts_resultsSortedByName() {
        Test.startTest();
        List<Account> result = AccountController.getAllAccounts();
        Test.stopTest();

        // Verify records are sorted ascending by Name
        for (Integer i = 0; i < result.size() - 1; i++) {
            Assert.isTrue(
                result[i].Name <= result[i + 1].Name,
                'Accounts should be sorted by Name ASC. Found: ' + result[i].Name + ' before ' + result[i + 1].Name
            );
        }
    }

    @IsTest
    static void testGetAllAccounts_containsExpectedFields() {
        Test.startTest();
        List<Account> result = AccountController.getAllAccounts();
        Test.stopTest();

        // Spot-check required fields are populated on at least one record
        Account sample = result[0];
        Assert.isNotNull(sample.Id,   'Id should not be null.');
        Assert.isNotNull(sample.Name, 'Name should not be null.');
    }

    // ─────────────────────────────────────────────
    // getAccountById
    // ─────────────────────────────────────────────

    @IsTest
    static void testGetAccountById_validId_returnsAccount() {
        Account existing = [SELECT Id, Name FROM Account WHERE Name = 'Alpha Corp' LIMIT 1];

        Test.startTest();
        Account result = AccountController.getAccountById(existing.Id);
        Test.stopTest();

        Assert.areEqual(existing.Id,   result.Id,   'Returned Account Id should match queried Id.');
        Assert.areEqual('Alpha Corp',  result.Name, 'Returned Name should match.');
    }

    @IsTest
    static void testGetAccountById_invalidId_throwsException() {
        Id fakeId = '001000000000000AAA'; // Syntactically valid but non-existent
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            AccountController.getAccountById(fakeId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'AuraHandledException should be thrown for a non-existent Account Id.');
    }

    // ─────────────────────────────────────────────
    // searchAccountsByName
    // ─────────────────────────────────────────────

    @IsTest
    static void testSearchAccountsByName_matchingTerm_returnsResults() {
        Test.startTest();
        List<Account> result = AccountController.searchAccountsByName('Alpha');
        Test.stopTest();

        Assert.isFalse(result.isEmpty(), 'Expected at least one result matching "Alpha".');
        Assert.areEqual('Alpha Corp', result[0].Name, 'First result should be "Alpha Corp".');
    }

    @IsTest
    static void testSearchAccountsByName_partialMatch_returnsResults() {
        Test.startTest();
        List<Account> result = AccountController.searchAccountsByName('eta'); // matches "Beta"
        Test.stopTest();

        Assert.isFalse(result.isEmpty(), 'Expected partial match results for "eta".');
    }

    @IsTest
    static void testSearchAccountsByName_noMatch_returnsEmptyList() {
        Test.startTest();
        List<Account> result = AccountController.searchAccountsByName('XYZ_NO_MATCH_12345');
        Test.stopTest();

        Assert.isTrue(result.isEmpty(), 'Expected empty list when no Account name matches.');
    }

    @IsTest
    static void testSearchAccountsByName_caseInsensitive_returnsResults() {
        Test.startTest();
        List<Account> result = AccountController.searchAccountsByName('GAMMA');
        Test.stopTest();

        Assert.isFalse(result.isEmpty(), 'Search should be case-insensitive. Expected match for "GAMMA".');
    }
}
