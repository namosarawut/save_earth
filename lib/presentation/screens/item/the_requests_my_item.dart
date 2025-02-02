import 'package:flutter/material.dart';
import 'package:save_earth/route/convert_route.dart';



class TheRequestsMyItemScreen extends StatefulWidget {
  const TheRequestsMyItemScreen({super.key});

  @override
  State<TheRequestsMyItemScreen> createState() => _TheRequestsMyItemScreenState();
}

class _TheRequestsMyItemScreenState extends State<TheRequestsMyItemScreen> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String nameItem = args!["name"] ?? "Unknown";
    List<dynamic> requestList = args["requestList"] ?? [];

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
                 Center(
                  child: Text(
                    nameItem,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Order List
            Expanded(
              child: ListView.builder(
                itemCount: requestList.length,
                itemBuilder: (context, index) {
                  final requestItem = requestList[index];
                  // final requestCount = requestItem["requests"].length;
                  return Card(
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(requestItem["request_by"]["username"],
                          style: const TextStyle(fontSize: 16)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          (Routes.requestsDetail).toStringPath(), // ชื่อ Route ของหน้าถัดไป
                            arguments: {
                              "name" : nameItem,
                              "requestList":requestItem
                            },
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
}
