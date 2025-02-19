class Database {
  static Database myInstance = Database();

  // Stream สำหรับดึงข้อมูลสินค้า
  Stream<List<Product>> getAllProductStream() {
    var reference = FirebaseFirestore.instance.collection('product');
    Query query = reference.orderBy('id', descending: true);
    var querySnapshot = query.snapshots();

    return querySnapshot.map(
      (snapshots) => snapshots.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  // ฟังก์ชันเพิ่มสินค้า
  Future<void> setProduct({required Product product}) async {
    var reference = FirebaseFirestore.instance.doc('product/${product.id}');
    try {
      await reference.set(product.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // ฟังก์ชันลบสินค้า
  Future<void> deleteProduct({required Product product}) async {
    var reference = FirebaseFirestore.instance.doc('product/${product.id}');
    try {
      await reference.delete();
    } catch (e) {
      rethrow;
    }
  }
}

class Query {
  snapshots() {}
}

class FirebaseFirestore {
  static var instance;
}

//คลาส Model สำหรับสินค้า
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['productName'] ?? '',
      price: (data['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': name,
      'price': price,
    };
  }
}
