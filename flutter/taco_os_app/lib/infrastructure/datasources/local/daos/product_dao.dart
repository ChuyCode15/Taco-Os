import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  /// Get all active products for a specific business and category
  /// MULTI-TENANT: Filters by business_id
  Future<List<ProductData>> getProductsByBusinessAndCategory(
    String businessId,
    String category,
  ) {
    return (select(products)
          ..where((p) => p.businessId.equals(businessId))
          ..where((p) => p.category.equals(category))
          ..where((p) => p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Get all active products for a specific business (all categories)
  /// MULTI-TENANT: Filters by business_id
  Future<List<ProductData>> getAllProductsByBusiness(String businessId) {
    return (select(products)
          ..where((p) => p.businessId.equals(businessId))
          ..where((p) => p.isActive.equals(true))
          ..orderBy([
            (p) => OrderingTerm.asc(p.category),
            (p) => OrderingTerm.asc(p.name),
          ]))
        .get();
  }

  /// Get a single product by ID and business
  /// MULTI-TENANT: Filters by business_id
  Future<ProductData?> getProductById(String businessId, String productId) {
    return (select(products)
          ..where((p) => p.businessId.equals(businessId))
          ..where((p) => p.id.equals(productId)))
        .getSingleOrNull();
  }

  /// Insert a new product
  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product, mode: InsertMode.insertOrReplace);
  }

  /// Insert or update multiple products (for sync from backend)
  Future<void> upsertProducts(List<ProductsCompanion> productList) {
    return batch((batch) {
      batch.insertAll(products, productList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Update a product
  Future<bool> updateProduct(String productId, ProductsCompanion updates) {
    return (update(products)..where((p) => p.id.equals(productId)))
        .write(updates)
        .then((count) => count > 0);
  }

  /// Soft delete a product (mark as inactive)
  /// MULTI-TENANT: Filters by business_id
  Future<bool> deactivateProduct(String businessId, String productId) {
    return (update(products)
          ..where((p) => p.businessId.equals(businessId))
          ..where((p) => p.id.equals(productId)))
        .write(
          ProductsCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .then((count) => count > 0);
  }

  /// Reactivate a product
  /// MULTI-TENANT: Filters by business_id
  Future<bool> activateProduct(String businessId, String productId) {
    return (update(products)
          ..where((p) => p.businessId.equals(businessId))
          ..where((p) => p.id.equals(productId)))
        .write(
          ProductsCompanion(
            isActive: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .then((count) => count > 0);
  }

  /// Delete all products for a business (used during full catalog sync)
  /// MULTI-TENANT: Filters by business_id
  Future<int> deleteAllProductsByBusiness(String businessId) {
    return (delete(
      products,
    )..where((p) => p.businessId.equals(businessId))).go();
  }

  /// Get count of products by category for a business
  /// MULTI-TENANT: Filters by business_id
  Future<int> countProductsByCategory(String businessId, String category) {
    final query = selectOnly(products)
      ..addColumns([products.id.count()])
      ..where(products.businessId.equals(businessId))
      ..where(products.category.equals(category))
      ..where(products.isActive.equals(true));

    return query.map((row) => row.read(products.id.count()) ?? 0).getSingle();
  }
}
