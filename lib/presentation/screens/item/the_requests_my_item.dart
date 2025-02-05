import 'package:flutter/material.dart';
import 'package:save_earth/data/model/my_item_list_model.dart';
import 'package:save_earth/route/convert_route.dart';



class TheRequestsMyItemScreen extends StatefulWidget {
  const TheRequestsMyItemScreen({super.key});

  @override
  State<TheRequestsMyItemScreen> createState() => _TheRequestsMyItemScreenState();
}

class _TheRequestsMyItemScreenState extends State<TheRequestsMyItemScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is ItemListModel) {
      final requestData = args;
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
                      requestData.name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Order List
              Expanded(
                child: ListView.builder(
                  itemCount: requestData.requests.length,
                  itemBuilder: (context, index) {
                    final requestItem = requestData.requests[index];
                    // final requestCount = requestItem["requests"].length;
                    return Card(
                      elevation: 1,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(

                        title: Text(requestItem.requestBy.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            (Routes.requestsDetail).toStringPath(), // ชื่อ Route ของหน้าถัดไป
                            arguments: {
                              "name" : requestData.name,
                              "itemId": requestData.itemId,
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
    } else {
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color(0xff598E0A),
          child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
SizedBox(height: 200,),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(height: 30,),
                        Text("ไม่มีข้อมูล สิ่งของ ของฉัน",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.w700),),
                      ],
                    ),
                  )
                ],
              )),
        ),
      );
    }



  }
}
