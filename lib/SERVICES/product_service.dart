import 'package:cloud_firestore/cloud_firestore.dart';
import '../MODELS/product_models.dart';

class ProductService {
  final _productsRef = FirebaseFirestore.instance.collection('product');

  Stream<List<ProductModel>> getProducts() {
    return _productsRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Stream<ProductModel?> getProductById(String id) {
    return _productsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProductModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _productsRef.add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _productsRef.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }
}