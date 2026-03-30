/**
 * @description Test class for CaseController.
 * @author      Antigravity
 * @date        2026-03-30
 */
@IsTest
private class CaseControllerTest {

    /**
     * @description Creates test data shared across all test methods.
     */
    @TestSetup
    static void setupTestData() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create test Cases
        List<Case> testCases = new List<Case>{
            new Case(
                Subject = 'Test Case Open 1',
                Description = 'Description for open case 1',
                Status = 'New',
                Priority = 'High',
                Origin = 'Web',
                AccountId = testAccount.Id,
                ContactId = testContact.Id
            ),
            new Case(
                Subject = 'Test Case Open 2',
                Description = 'Description for open case 2',
                Status = 'Working',
                Priority = 'Medium',
                Origin = 'Phone',
                AccountId = testAccount.Id,
                ContactId = testContact.Id
            ),
            new Case(
                Subject = 'Test Case Closed',
                Description = 'Description for closed case',
                Status = 'Closed',
                Priority = 'Low',
                Origin = 'Email',
                AccountId = testAccount.Id,
                ContactId = testContact.Id
            )
        };
        insert testCases;
    }

    // ─────────────────────────────────────────────
    // getAllCases
    // ─────────────────────────────────────────────
    @IsTest
    static void testGetAllCases_returnsCases() {
        Test.startTest();
        List<Case> result = CaseController.getAllCases();
        Test.stopTest();

        Assert.isTrue(result.size() >= 3, 'Expected at least 3 Case records to be returned.');
    }

    // ─────────────────────────────────────────────
    // getCaseById
    // ─────────────────────────────────────────────
    @IsTest
    static void testGetCaseById_validId_returnsCase() {
        Case existingCase = [SELECT Id, Subject FROM Case WHERE Subject = 'Test Case Open 1' LIMIT 1];

        Test.startTest();
        Case result = CaseController.getCaseById(existingCase.Id);
        Test.stopTest();

        Assert.areEqual(existingCase.Id, result.Id, 'Returned Case Id should match the queried Id.');
        Assert.areEqual('Test Case Open 1', result.Subject, 'Returned Subject should match.');
    }

    @IsTest
    static void testGetCaseById_invalidId_throwsException() {
        // Use a fake but syntactically valid Case Id
        Id fakeId = '500000000000000AAA';
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            CaseController.getCaseById(fakeId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'AuraHandledException should have been thrown for an invalid Id.');
    }

    // ─────────────────────────────────────────────
    // getCasesByStatus
    // ─────────────────────────────────────────────
    @IsTest
    static void testGetCasesByStatus_new_returnsCases() {
        Test.startTest();
        List<Case> result = CaseController.getCasesByStatus('New');
        Test.stopTest();

        for (Case c : result) {
            Assert.areEqual('New', c.Status, 'All returned Cases should have Status = New.');
        }
        Assert.isFalse(result.isEmpty(), 'Expected at least one Case with Status = New.');
    }

    @IsTest
    static void testGetCasesByStatus_closed_returnsCases() {
        Test.startTest();
        List<Case> result = CaseController.getCasesByStatus('Closed');
        Test.stopTest();

        for (Case c : result) {
            Assert.areEqual('Closed', c.Status, 'All returned Cases should have Status = Closed.');
        }
        Assert.isFalse(result.isEmpty(), 'Expected at least one Case with Status = Closed.');
    }
}
