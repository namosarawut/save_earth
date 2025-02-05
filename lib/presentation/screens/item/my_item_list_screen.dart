import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/data/local_storage_helper.dart';
import 'package:save_earth/logic/Bloc/get_my_item_list/get_my_item_list_bloc.dart';
import 'package:save_earth/route/convert_route.dart';

class MyItemsListScreen extends StatefulWidget {
  const MyItemsListScreen({super.key});

  @override
  State<MyItemsListScreen> createState() => _MyItemsListScreenState();
}

class _MyItemsListScreenState extends State<MyItemsListScreen> {
  bool isMyRequests = false; // true = คำขอรับของของฉัน, false = ของที่ฉันขอรับ
  final List<Map<String, dynamic>> myRequestList = [
    {
      "request_id": 201,
      "item": {
        "item_id": 77,
        "name": "ตู้เย็นเก่า",
        "image_url": "https://example.com/images/fridge.jpg",
        "category": "เครื่องใช้ไฟฟ้า",
        "latitude": 13.7563,
        "longitude": 100.5018,
        "posted_by": {
          "user_id": 501,
          "username": "jane_doe",
          "contact": {
            "first_name": "Jane",
            "last_name": "Doe",
            "phone_number": "+66987654321"
          }
        }
      },
      "reason": "ต้องการใช้แทนของเก่าที่เสียไป",
      "status": "pending",
      "created_at": "2025-02-01T10:15:00Z"
    },
    {
      "request_id": 202,
      "item": {
        "item_id": 88,
        "name": "โต๊ะไม้เก่า",
        "image_url": "https://example.com/images/wooden_table.jpg",
        "category": "เฟอร์นิเจอร์",
        "latitude": 13.7363,
        "longitude": 100.5238,
        "posted_by": {
          "user_id": 502,
          "username": "alice_wonder",
          "contact": {
            "first_name": "Alice",
            "last_name": "Wonderland",
            "phone_number": "+66678901234"
          }
        }
      },
      "reason": "ต้องการนำไปใช้ในหอพัก",
      "status": "approved",
      "created_at": "2025-02-01T11:20:00Z"
    },
    {
      "request_id": 203,
      "item": {
        "item_id": 99,
        "name": "ตุ๊กตาหมี",
        "image_url": "https://example.com/images/teddy.jpg",
        "category": "ของใช้ส่วนตัว",
        "latitude": 13.7451,
        "longitude": 100.5392,
        "posted_by": {
          "user_id": 503,
          "username": "bob_marley",
          "contact": {
            "first_name": "Bob",
            "last_name": "Marley",
            "phone_number": "+66543210987"
          }
        }
      },
      "reason": "ต้องการให้ลูกสาววัย 3 ขวบ",
      "status": "taken",
      "created_at": "2025-02-01T12:00:00Z"
    }
  ];
  @override
  void initState() {
    super.initState();
    _fetchUserItems();
  }

  void _fetchUserItems() async {
    final user = await LocalStorageHelper.getUser();
    if (user != null) {
      context.read<GetMyItemListBloc>().add(FetchMyItems(user.userId));
    }
  }

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
                    "รายการ สิ่งของ",
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
            isMyRequests? BlocConsumer<GetMyItemListBloc, GetMyItemListState>(
  listener: (context, getMyItemListState) {
    // TODO: implement listener
  },
  builder: (context, getMyItemListState) {
    if (getMyItemListState is GetMyItemListLoading) {
      return Center(
        child: Container(
          width: 40,
          height: 40,
          color: Color(0xffF1F4F9),
          child: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              )),
        ),
      );
    } else if (getMyItemListState is GetMyItemListLoaded){
      if(getMyItemListState.items.isEmpty){
        return Container(
          width: MediaQuery.of(context).size.width,
          color: Color(0xffF1F4F9),
          child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.green,
                    size: 40,
                  ),
                  Text("ไม่มีข้อมูล สิ่งของ ของฉัน",style: TextStyle(fontSize: 20,color: Colors.green,fontWeight: FontWeight.w700),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _fetchUserItems();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Icon(Icons.refresh,color: Colors.white,),
                      ),
                    ],
                  ),
                ],
              )),
        );
      }else{
        return Expanded(
          child: Column(
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _fetchUserItems();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Icon(Icons.refresh,color: Colors.white,),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: getMyItemListState.items.length,
                  itemBuilder: (context, index) {
                    final order = getMyItemListState.items[index];
                    final requestCount = order.requests.length;
                    return Card(
                      elevation: 1,
                      color: order.status == "available"?Colors.white:Color(0xff0EC872),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading:order.status == "available"? GestureDetector(
                          onTap: (){
                            if(order.status == "available" && requestCount > 0){
                              Navigator.pushNamed(
                                context,
                                (Routes.requestsMyItem).toStringPath(), // ชื่อ Route ของหน้าถัดไป
                                arguments: {
                                  "name" : order.name,
                                  "requestList":order.requests
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
                        title: Text(order.name,
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
        );
      }

    } else if (getMyItemListState is GetMyItemListError) {
      return  Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xff598E0A),
        child: Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 40,
            )),
      );
    }else{
      return Center(
        child: Container(
          width: 40,
          height: 40,
          color: Color(0xffF1F4F9),
          child: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              )),
        ),
      );
    }

  },
) : Expanded(
              child: ListView.builder(
                itemCount: myRequestList.length,
                itemBuilder: (context, index) {
                  final requestListItem = myRequestList[index];
                  // final requestCount = order["requests"].length;
                  return Card(
                    elevation: 1,
                    color: requestListItem["status"] == "pending"?Colors.white:requestListItem["status"] == "approved"?Color(0xff0EC872):requestListItem["status"] == "taken"?Colors.red:Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(requestListItem["item"]["name"],
                          style: const TextStyle(fontSize: 16)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          (Routes.myRequestsDetail).toStringPath(), // ชื่อ Route ของหน้าถัดไป
                          arguments: requestListItem, // ส่ง arguments ไป
                        );
                      },
                    ),
                  );
                },
              ),
            ) ,
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
