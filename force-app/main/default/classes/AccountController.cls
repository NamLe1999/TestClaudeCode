public with sharing class AccountController {

    /**
     * @description Retrieves all Account records with commonly used fields.
     * @return List of Account records
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAllAccounts() {
        List<Account> accounts = [
            SELECT
                Id,
                Name,
                AccountNumber,
                Type,
                Industry,
                AnnualRevenue,
                NumberOfEmployees,
                Rating,
                Phone,
                Fax,
                Website,
                Description,
                OwnerId,
                Owner.Name,
                ParentId,
                Parent.Name,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                ShippingStreet,
                ShippingCity,
                ShippingState,
                ShippingPostalCode,
                ShippingCountry,
                CreatedById,
                CreatedDate,
                LastModifiedById,
                LastModifiedDate,
                IsDeleted
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC LIMIT 200
        ];
        return accounts;
    }

    /**
     * @description Retrieves a single Account record by Id.
     * @param accountId The Id of the Account to retrieve
     * @return Account record
     */
    @AuraEnabled(cacheable=true)
    public static Account getAccountById(Id accountId) {
        Account acc = [
            SELECT
                Id,
                Name,
                AccountNumber,
                Type,
                Industry,
                AnnualRevenue,
                NumberOfEmployees,
                Rating,
                Phone,
                Fax,
                Website,
                Description,
                OwnerId,
                Owner.Name,
                ParentId,
                Parent.Name,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                ShippingStreet,
                ShippingCity,
                ShippingState,
                ShippingPostalCode,
                ShippingCountry,
                CreatedById,
                CreatedDate,
                LastModifiedById,
                LastModifiedDate
            FROM Account
            WHERE Id = :accountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return acc;
    }

    /**
     * @description Searches Accounts by name (case-insensitive partial match).
     * @param searchTerm The search keyword
     * @return List of matching Account records
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountsByName(String searchTerm) {
        String keyword = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        List<Account> results = [
            SELECT
                Id,
                Name,
                AccountNumber,
                Type,
                Industry,
                Phone,
                Website,
                BillingCity,
                BillingCountry,
                Owner.Name,
                CreatedDate
            FROM Account
            WHERE Name LIKE :keyword
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC LIMIT 200
        ];
        return results;
    }
}
