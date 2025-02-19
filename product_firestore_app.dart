//งาน ทดสอบปฏิบัติ ครั้งที่ 2 (Take Home)
import 'package:flutter/material.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  void _deleteProduct(String docId) {
    FirebaseFirestore.instance.collection('Goods').doc(docId).delete();
  }

  void _showAddProductDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddProductForm(),
    );
  }

  void _showUpdateProductDialog(
      String docId, String productName, double price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UpdateEditScreen(
        docId: docId,
        productName: productName,
        price: price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffe14e4e),
        title: const Text(
          'รายการสินค้า',
          style: TextStyle(color: Color(0xfff0f0f0)),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xffF7F4F2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header
            Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xff5A4F74),
                  child: Icon(Icons.shopping_bag_sharp,
                      size: 40, color: Color(0xfff4f4f4)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'รายการสินค้า',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0c275a)),
                ),
                const SizedBox(height: 5),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Goods')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      'สินค้าทั้งหมด ${snapshot.data!.docs.length} รายการ',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff30312c)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // แสดงรายการสินค้า
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Goods').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'ยังไม่มีข้อมูลสินค้า',
                        style: TextStyle(
                            color: Color(0xff3B444B),
                            fontSize: 24,
                            fontWeight: FontWeight.normal),
                      ),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Dismissible(
                          key: Key(doc.id),
                          background: Container(
                            color: const Color(0xffD92121),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete,
                                color: Color(0xffF7BFBE)),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteProduct(doc.id);
                          },
                          child: Container(
                            color: Color(0xffFAFBFC),
                            child: ListTile(
                              leading: Icon(Icons.arrow_forward_outlined,
                                  color: Color(0xFF16130C)),
                              title: Text(data['productName'],
                                  style: const TextStyle(fontSize: 23)),
                              subtitle: Text('฿${data['price']}',
                                  style: const TextStyle(
                                      fontSize: 17, color: Color(0xff6B6B6B))),
                              onTap: () => _showUpdateProductDialog(
                                  doc.id,
                                  data['productName'],
                                  (data['price'] as num).toDouble()),
                            ),
                          ));
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ปุ่มเพิ่มสินค้า
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add, color: Color(0xffF9FAFB), size: 30),
        backgroundColor: const Color(0xffA9A6D2),
      ),
    );
  }
}

class UpdateEditScreen extends StatefulWidget {
  final String docId;
  final String productName;
  final double price;

  UpdateEditScreen(
      {required this.docId, required this.productName, required this.price});

  @override
  _UpdateEditScreenState createState() => _UpdateEditScreenState();
}

class _UpdateEditScreenState extends State<UpdateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.productName);
    priceController = TextEditingController(text: widget.price.toString());
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('Goods').doc(widget.docId).update({
        'productName': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        color: Color(0xffF5F3F2),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'แก้ไขสินค้า',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ราคาสินค้า'),
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกราคา' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff3BA54F)),
                  onPressed: _updateProduct,
                  child: Text('อัปเดต',
                      style: TextStyle(
                        color: Color(0xffFCFCFB),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffea1e22)),
                  onPressed: () => Navigator.pop(context),
                  child: Text('ยกเลิก',
                      style: TextStyle(
                        color: Color(0xffFCFCFB),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ฟอร์มเพิ่มสินค้า
class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('Goods').add({
        'productName': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        color: Color(0xfff5f7f9), // กำหนดสีพื้นหลัง
        padding: EdgeInsets.all(20), // เพิ่ม Padding ให้ดูสวยงาม
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'เพิ่มสินค้า',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                    style: const TextStyle(
                        color: Color(0xff032946),
                        fontSize: 18,
                        fontWeight: FontWeight.normal),
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ราคาสินค้า'),
                    style: const TextStyle(
                        color: Color(0xff032946),
                        fontSize: 18,
                        fontWeight: FontWeight.normal),
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกราคา' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff49796B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    minimumSize: const Size(60, 50),
                  ),
                  onPressed: _addProduct,
                  child: const Text(
                    'เพิ่ม',
                    style: TextStyle(
                      color: Color(0xffFEFEFD),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffd9534e),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    minimumSize: const Size(60, 50),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ปิด',
                    style: TextStyle(
                      color: Color(0xffFEFEFD),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
