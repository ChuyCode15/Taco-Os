# Use Case Unit Tests Summary

This directory contains comprehensive unit tests for all use cases with mocked repositories.

## Test Coverage

### Authentication Use Cases (`auth/`)

#### SignInUseCase
- ✅ Successful authentication returns User
- ✅ Failed authentication returns AuthFailure
- ✅ Network issues return NetworkFailure
- ✅ Repository called exactly once

#### SignOutUseCase
- ✅ Successful sign out
- ✅ Failed sign out returns Failure
- ✅ Repository called exactly once

### Cajero Use Cases (`cajero/`)

#### OpenSessionUseCase
**Boundary Value Testing (Requirements 3.6, 9.2):**
- ✅ `initialCash = 0.00` (minimum valid) ✓
- ✅ `initialCash = 0.01` (just above minimum) ✓
- ✅ `initialCash = 999,999.99` (maximum valid) ✓
- ✅ `initialCash = 1,000,000` (exceeds maximum) ✗
- ✅ `initialCash < 0` (negative) ✗
- ✅ Mid-range values (e.g., 500.00) ✓

**Error Handling:**
- ✅ LocalDatabaseFailure when repository fails

#### RegisterExpenseUseCase
**Amount Boundary Testing (Requirements 7.3, 5.8):**
- ✅ `amount = 0.00` (minimum invalid) ✗
- ✅ `amount = 0.01` (minimum valid) ✓
- ✅ `amount = 999,999.99` (maximum valid) ✓
- ✅ `amount = 1,000,000` (exceeds maximum) ✗
- ✅ `amount < 0` (negative) ✗

**Description Validation (Requirements 7.3, 7.4, 7.5):**
- ✅ Empty description ✗
- ✅ 1 character description ✓
- ✅ 100 character description (maximum valid) ✓
- ✅ 101+ character description (exceeds maximum) ✗

**Error Handling:**
- ✅ LocalDatabaseFailure when repository fails

#### RegisterSaleUseCase
**Product Quantity Boundary Testing (Requirements 5.8, 9.2):**
- ✅ `quantity = 0` (minimum invalid) ✗
- ✅ `quantity = 1` (minimum valid) ✓
- ✅ `quantity = 999,999,999` (maximum valid) ✓
- ✅ `quantity < 0` (negative) ✗

**Sale Item Validation:**
- ✅ Sale with no items ✗
- ✅ Unit price = 0 ✗
- ✅ Unit price < 0 (negative) ✗
- ✅ Subtotal mismatch (quantity × unitPrice ≠ subtotal) ✗
- ✅ Multiple items sale ✓

**Total Validation:**
- ✅ Total = 0 ✗
- ✅ Total < 0 (negative) ✗
- ✅ Total ≠ sum of subtotals ✗

**Error Handling:**
- ✅ LocalDatabaseFailure when repository fails

#### CancelSaleUseCase
**Anti-Fraud Window Validation (Requirements 6.5, 9.2):**
- ✅ 0 minutes elapsed (within window) ✓
- ✅ 4 minutes 59 seconds elapsed (within window) ✓
- ✅ Exactly 5 minutes elapsed (boundary - outside window) ✗
- ✅ 6 minutes elapsed (outside window) ✗
- ✅ 10 minutes elapsed (well outside window) ✗

**Photo Validation (Requirements 6.2, 6.3, 6.4):**
- ✅ Empty photo path ✗
- ✅ Photo path provided and within window ✓

**Combined Validations:**
- ✅ Outside window with photo ✗ (window validation takes precedence)
- ✅ Within window without photo ✗

**Error Handling:**
- ✅ LocalDatabaseFailure when repository fails
- ✅ CameraFailure when camera unavailable

### Catalog Use Cases (`catalog/`)

#### GetProductsByCategoryUseCase
**Category Testing:**
- ✅ Retrieve products for `comida` category
- ✅ Retrieve products for `bebidas` category
- ✅ Retrieve products for `postres` category
- ✅ Empty list when category has no products

**Multi-Tenant Isolation (Requirement 15.2):**
- ✅ Products filtered by `businessId`
- ✅ Different businesses return different products

**Error Handling:**
- ✅ LocalDatabaseFailure when repository fails
- ✅ NetworkFailure when offline with empty catalog

## Test Summary

**Total Tests:** 70 tests
**Status:** ✅ All passing

## Requirements Validated

The tests validate the following requirements:
- **3.6**: Fondo_de_Cambio validation (0.00–999,999.99)
- **5.8**: Product quantity validation (1–999,999,999)
- **6.5**: Anti-fraud window enforcement (< 5 minutes)
- **7.3**: Expense amount and description validation
- **9.2**: Counted cash validation (0.00–999,999.99)
- **15.2**: Multi-tenant isolation by businessId

## Key Testing Patterns

1. **Boundary Value Testing**: All numeric validations test minimum, maximum, and invalid boundary values
2. **Anti-Fraud Window**: Comprehensive testing of the 5-minute cancellation window with boundary cases
3. **Mocked Repositories**: All repository dependencies are mocked using Mocktail
4. **Error Handling**: All failure scenarios return appropriate Failure types
5. **Multi-Tenant Isolation**: Products are correctly filtered by businessId

## Running Tests

```bash
# Run all use case tests
flutter test test/domain/usecases/

# Run specific use case test
flutter test test/domain/usecases/cajero/cancel_sale_use_case_test.dart

# Run with coverage
flutter test --coverage test/domain/usecases/
```
