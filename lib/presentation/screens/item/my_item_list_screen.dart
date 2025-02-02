import 'package:flutter/material.dart';
import 'package:save_earth/route/convert_route.dart';

class MyItemsListScreen extends StatefulWidget {
  const MyItemsListScreen({super.key});

  @override
  State<MyItemsListScreen> createState() => _MyItemsListScreenState();
}

class _MyItemsListScreenState extends State<MyItemsListScreen> {
  bool isMyRequests = false; // true = คำขอรับของของฉัน, false = ของที่ฉันขอรับ

  final List<Map<String, dynamic>> orders = [
    {
      "item_id": 77,
      "name": "ตู้เย็นเก่า",
      "image_url": "https://example.com/images/fridge.jpg",
      "description": "ตู้เย็นยังใช้งานได้แต่มีรอยขีดข่วนเล็กน้อย",
      "category": "เครื่องใช้ไฟฟ้า",
      "latitude": 13.7563,
      "longitude": 100.5018,
      "status": "available",
      "created_at": "2025-02-01T08:30:00Z",
      "requests": [
        {
          "request_id": 201,
          "request_by": {
            "user_id": 301,
            "username": "john_doe",
            "contact": {
              "first_name": "John",
              "last_name": "Doe",
              "phone_number": "+66812345678"
            }
          },
          "reason": "ต้องการใช้แทนของเก่าที่เสียไป",
          "status": "pending",
          "created_at": "2025-02-01T10:15:00Z"
        },
        {
          "request_id": 202,
          "request_by": {
            "user_id": 302,
            "username": "alice_wonder",
            "contact": {
              "first_name": "Alice",
              "last_name": "Wonderland",
              "phone_number": "+66678901234"
            }
          },
          "reason": "ต้องการบริจาคให้โรงเรียนชนบท",
          "status": "pending",
          "created_at": "2025-02-01T10:30:00Z"
        }
      ]
    },
    {
      "item_id": 88,
      "name": "โต๊ะไม้เก่า",
      "image_url": "https://example.com/images/wooden_table.jpg",
      "description": "โต๊ะไม้เก่าสภาพดี ไม่ได้ใช้แล้ว",
      "category": "เฟอร์นิเจอร์",
      "latitude": 13.7363,
      "longitude": 100.5238,
      "status": "available",
      "created_at": "2025-02-01T09:00:00Z",
      "requests": []
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F4F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // Title
                const Center(
                  child: Text(
                    "รายการ Order",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton("ของที่ฉันขอรับ", !isMyRequests),
                const SizedBox(width: 8),
                _buildToggleButton("คำขอรับของของฉัน", isMyRequests),
              ],
            ),

            const SizedBox(height: 16),
            // Order List
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final requestCount = order["requests"].length;
                  return Card(
                    elevation: 1,
                    color: order["status"] == "available"?Colors.white:Color(0xff0EC872),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading:order["status"] == "available"? GestureDetector(
                        onTap: (){
                          if(order["status"] == "available" && requestCount > 0){
                            Navigator.pushNamed(
                              context,
                              (Routes.requestsMyItem).toStringPath(), // ชื่อ Route ของหน้าถัดไป
                              arguments: {
                                "name" : order["name"],
                                "requestList":order["requests"]
                              }, // ส่ง arguments ไป
                            );
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor:
                          requestCount > 0 ? Colors.red : Colors.grey,
                          child: Text(
                            requestCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ):SizedBox.shrink(),
                      title: Text(order["name"],
                          style: const TextStyle(fontSize: 16)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          (Routes.myItemDetail).toStringPath(), // ชื่อ Route ของหน้าถัดไป
                          arguments: order, // ส่ง arguments ไป
                        );
                            },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isMyRequests = text == "คำขอรับของของฉัน";
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.green.shade900 : Colors.white,
          foregroundColor: isActive ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
