/**
 * @description Controller class to retrieve Case records from the Case object.
 *              Exposes AuraEnabled methods for use in Lightning Web Components.
 * @author      Antigravity
 * @date        2026-03-30
 */
public with sharing class CaseController {

    /**
     * @description Retrieves all Case records with commonly used fields.
     * @return      List of Case records.
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCases() {
        return [
            SELECT
                Id,
                CaseNumber,
                Subject,
                Description,
                Status,
                Priority,
                Origin,
                Type,
                Reason,
                IsEscalated,
                AccountId,
                Account.Name,
                ContactId,
                Contact.Name,
                Contact.Email,
                OwnerId,
                Owner.Name,
                CreatedDate,
                LastModifiedDate,
                ClosedDate,
                SuppliedEmail,
                SuppliedName,
                SuppliedPhone,
                SuppliedCompany,
                Comments
            FROM Case
            WITH SECURITY_ENFORCED
            ORDER BY CaseNumber ASC
            LIMIT 1000
        ];
    }

    /**
     * @description Retrieves a single Case record by its Id.
     * @param       caseId  The Id of the Case to retrieve.
     * @return      The Case record matching the given Id.
     */
    @AuraEnabled(cacheable=true)
    public static Case getCaseById(Id caseId) {
        List<Case> cases = [
            SELECT
                Id,
                CaseNumber,
                Subject,
                Description,
                Status,
                Priority,
                Origin,
                Type,
                Reason,
                IsEscalated,
                AccountId,
                Account.Name,
                ContactId,
                Contact.Name,
                Contact.Email,
                OwnerId,
                Owner.Name,
                CreatedDate,
                LastModifiedDate,
                ClosedDate,
                SuppliedEmail,
                SuppliedName,
                SuppliedPhone,
                SuppliedCompany,
                Comments
            FROM Case
            WHERE Id = :caseId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            throw new AuraHandledException('Case not found for Id: ' + caseId);
        }
        return cases[0];
    }

    /**
     * @description Retrieves Cases filtered by Status.
     * @param       status  The Status value to filter on (e.g. 'Open', 'Closed').
     * @return      List of Case records matching the given Status.
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesByStatus(String status) {
        return [
            SELECT
                Id,
                CaseNumber,
                Subject,
                Status,
                Priority,
                Origin,
                AccountId,
                Account.Name,
                ContactId,
                Contact.Name,
                OwnerId,
                Owner.Name,
                CreatedDate,
                LastModifiedDate
            FROM Case
            WHERE Status = :status
            WITH SECURITY_ENFORCED
            ORDER BY CaseNumber ASC
            LIMIT 1000
        ];
    }
}
