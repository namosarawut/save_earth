import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/data/local_storage_helper.dart';
import 'package:save_earth/data/model/my_item_list_model.dart';
import 'package:save_earth/logic/Bloc/approve_request/approve_request_bloc.dart';
import 'package:save_earth/logic/Bloc/get_my_requests/get_my_requests_bloc.dart';

class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({super.key});

  void _showConfirmDialog(
      BuildContext context, String itemName, Request requestItem, int itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            height: 300,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "คุณแน่ใจหรือไม่ว่าต้องการให้\n$itemName\nกับ ${requestItem.requestBy.username}?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton(context, "ยกเลิก", Colors.grey, () {
                      Navigator.of(context).pop();
                    }),
                    _buildDialogButton(context, "ใช่", Colors.green.shade900,
                        () {
                      // เพิ่มฟังก์ชันเมื่อกดยืนยัน
                      context.read<ApproveRequestBloc>().add(ApproveRequestById(
                          itemId: itemId, requestId: requestItem.requestId));
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
  void _fetchRequests(BuildContext context) async {
    final user = await LocalStorageHelper.getUser();
    if (user != null) {
      context.read<GetMyRequestsBloc>().add(FetchMyRequests(user.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      final String name = args["name"] ?? "ไม่มีชื่อ";
      final int itemId = args["itemId"] ?? 0;
      final Request requestItem =
          args["requestList"]; // ✅ รับค่า Object `Request`
      return Stack(
        children: [
          Scaffold(
            backgroundColor: Color(0xffF1F4F9),
            bottomNavigationBar: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 23,
                    child: ElevatedButton(
                      onPressed: () {
                        _showConfirmDialog(context, name, requestItem, itemId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "อนุมัติ",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 50),
                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Center(
                        child: Text(
                          "$name โดย ${requestItem.requestBy.username}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                          _buildInfoText("ชื่อ",
                              "${requestItem.requestBy.firstName} ${requestItem.requestBy.lastName}"),
                          _buildInfoText("เบอร์โทรศัพท์",
                              "${requestItem.requestBy.phoneNumber}"),
                          _buildInfoText(
                              "เหตุผลการร้องขอ", "${requestItem.reason}",
                              isReason: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocConsumer<ApproveRequestBloc, ApproveRequestState>(
  listener: (context, approveRequestState) {
    // TODO: implement listener
    if(approveRequestState is ApproveRequestSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("อนุมัตสำเร็จ")),
      );
      _fetchRequests(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }else if(approveRequestState is ApproveRequestError){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("อนุมัตไม่สำเร็จ")),
      );

    }
  },
  builder: (context, approveRequestState) {
    if(approveRequestState is ApproveRequestLoading) {
      return Container(
        color: Colors.black45,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          ),
        ),
      );
    }else{
      return Container();
    }

  },
)
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text("❌ ไม่มีข้อมูล")),
      );
    }
  }

  Widget _buildInfoText(String label, String value, {bool isReason = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isReason ? Colors.grey[300] : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
