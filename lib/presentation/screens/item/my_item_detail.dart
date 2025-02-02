// import 'package:flutter/material.dart';

// class MyItemDetailScreen extends StatelessWidget {
//   const MyItemDetailScreen({super.key});
//
//   void _showConfirmDialog(
//       BuildContext context, String itemName, String requesterName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Container(
//             width: 400,
//             height: 300,
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "คุณแน่ใจหรือไม่ว่าต้องการให้\n$itemName\nกับ $requesterName?",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildDialogButton(context, "ยกเลิก", Colors.grey, () {
//                       Navigator.of(context).pop();
//                     }),
//                     _buildDialogButton(context, "ใช่", Colors.green.shade900,
//                         () {
//                       // เพิ่มฟังก์ชันเมื่อกดยืนยัน
//                       Navigator.of(context).pop();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("การยืนยันเสร็จสมบูรณ์!")),
//                       );
//                     }),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDialogButton(
//       BuildContext context, String text, Color color, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//       ),
//       child:
//           Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Map<String, dynamic>? args =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     return Scaffold(
//       backgroundColor: Color(0xffF1F4F9),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: ListView(
//           // crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // const SizedBox(height: 50),
//             // Back Button
//             Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back, size: 30),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 Center(
//                   child: Text(
//                     "${args!["name"]}",
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 24),
//
//             // Detail Card
//             Card(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildInfoText("ชื่อ : ", "${args["name"]}"),
//                     _buildInfoText("ชื่อ : ", "${args["name"]}"),
//                     _buildInfoText("ชื่อ : ", "${args["name"]}"),
//                     _buildInfoText("ชื่อ : ", "${args["name"]}"),
//                     _buildInfoText("ชื่อ : ", "${args["name"]}"),
//                     _buildInfoText("ชื่อ : ", "${args["name"]}"),
//                     // _buildInfoText("เบอร์โทรศัพท์", "${requestData["request_by"]["contact"]["phone_number"]}"),
//                     // _buildInfoText("เหตุผลการร้องขอ", "${requestData["reason"]}", isReason: true),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoText(String label, String value, {bool isReason = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         // crossAxisAlignment: CrossAxisAlignment.start,
//
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 14),
//           )
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MyItemDetailScreen extends StatelessWidget {

   MyItemDetailScreen({super.key});

  Future<void> _openGoogleMaps(BuildContext context, Map<String, dynamic> args) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double userLat = position.latitude;
    double userLng = position.longitude;
    double destLat = args["latitude"];
    double destLng = args["longitude"];

    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$destLat,$destLng&travelmode=driving");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่สามารถเปิด Google Maps ได้")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      backgroundColor: Color(0xffF1F4F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            // Back Button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // Title
                Center(
                  child: Text(
                    args!["name"],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Detail Card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ข้อมูล", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.green.shade900),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "แก้ไข",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8,),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.red),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "ลบ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("ชื่อ : ${args["name"]}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Text("ประเภท : ${args["category"]}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

                    const SizedBox(height: 16),

                    const Text("คำอธิบาย", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        args["description"],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Map Section
            const Text("ตำแหน่ง", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(args["latitude"], args["longitude"]),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(args["latitude"], args["longitude"]),
                          width: 50,
                          height: 50,
                          child:
                          Icon(Icons.my_location, color: Colors.blue, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Open in Google Maps Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openGoogleMaps(context,args),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "ไปที่ Google Maps",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
