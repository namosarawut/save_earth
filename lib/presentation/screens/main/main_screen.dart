import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MarkerData {
  final String userId;
  final String name;
  final String description;
  final String category;
  final String imagePath;
  final LatLng latlong;
  final String status;
  final String createdAt;

  MarkerData({
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.latlong,
    required this.status,
    required this.createdAt,
  });
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainAppScreen> {
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;
  final List<MarkerData> markers = [
    MarkerData(
      userId: "user_01",
      name: "Recycle Bin",
      description: "จุดรับขยะรีไซเคิล",
      category: "Recycling",
      imagePath: "https://c.pxhere.com/photos/03/7e/toys_teddy_bear_plush_bear_plush_old_bear-778203.jpg!d",
      latlong: LatLng(18.7803, 99.0158),
      status: "active",
      createdAt: "2024-02-01",
    ),
    MarkerData(
      userId: "user_02",
      name: "Donation Center",
      description: "บริจาคของใช้ที่ไม่ต้องการ",
      category: "Donation",
      imagePath: "https://c.pxhere.com/photos/03/7e/toys_teddy_bear_plush_bear_plush_old_bear-778203.jpg!d",
      latlong: LatLng(18.8000, 99.0000),
      status: "active",
      createdAt: "2024-02-01",
    ),
    MarkerData(
      userId: "user_03",
      name: "Second-hand Market",
      description: "ตลาดของมือสอง",
      category: "Marketplace",
      imagePath: "https://c.pxhere.com/photos/03/7e/toys_teddy_bear_plush_bear_plush_old_bear-778203.jpg!d",
      latlong: LatLng(18.7700, 99.0200),
      status: "inactive",
      createdAt: "2024-02-01",
    ),
  ];
  List<String> allItems = [
    "Teddy Bear",
    "Stuffed Dog",
    "Stuffed Cat",
    "Stuffed Rabbit",
    "Stuffed Panda",
    "Stuffed Penguin",
    "Stuffed Lion",
    "Stuffed Elephant",
    "Doraemon Plush",
    "Mickey Mouse Plush"
  ];
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(() {
      filterSearchResults();
    });
  }

  void filterSearchResults() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        filteredItems = allItems
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      } else {
        filteredItems.clear(); // ล้างรายการถ้าไม่มีการพิมพ์ข้อความ
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    print("Location : ${position.latitude}, ${position.longitude}");
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // เมื่อได้ตำแหน่งล่าสุดแล้ว ให้เลื่อนแผนที่ไปที่ตำแหน่งนั้น
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, _currentZoom);
    }
  }



  void showRequestDialog(BuildContext context, MarkerData marker) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // มุมโค้ง 20
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "เหตุผลการร้องขอ สิ่งของ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "เหตุผลที่ท่านขอรับสิ่งของชิ้นนี้",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด Dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800], // สีเขียวเข้ม
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "ส่งคำขอ",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMarkerDetails(MarkerData marker) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width-16,
          padding: EdgeInsets.all(16.0),
          child: ListView(
            // mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // กำหนดมุมโค้ง 20
                child: Image.network(
                  marker.imagePath,
                  width: MediaQuery.of(context).size.width-8,
                  height: 200,  // ความสูง 16:9
                  fit: BoxFit.cover, // ครอบคลุมพื้นที่โดยไม่เสียอัตราส่วน
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(marker.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Color(0xffD9D9D9)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(marker.description, style: TextStyle(fontSize: 16),)
                    ],
                  ),
                ),
              ),
              // Text(marker.description),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("หมวดหมู่: ${marker.category}", style: TextStyle(fontSize: 16),)
                ],
              ),
              SizedBox(height: 10),
              Text("ลงประกาศเมื่อ: ${marker.createdAt}"),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, (Routes.mainApp).toStringPath());
                  showRequestDialog(context,marker);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 80,
                  ),
                ),
                child:  Text(
                  "ส่งคำขอ",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? LatLng(13.8588517, 101.99559),
              initialZoom: _currentZoom,
              onPositionChanged: ( pos, bool hasGesture) {
                setState(() {
                  _currentZoom = pos.zoom;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: Icon(Icons.my_location, color: Colors.blue, size: 40),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: markers.map((marker) {
                  return Marker(
                    point: marker.latlong,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showMarkerDetails(marker),
                      child: Icon(
                        Icons.location_on,
                        color: marker.status == "active" ? Colors.green : Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search for what you want",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  // contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
          ),
          Positioned(
            top: 75,
            left: 32,
            right: 32,
            child: filteredItems.isNotEmpty
                ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredItems[index]),
                    onTap: () {
                      _searchController.text = filteredItems[index];
                      setState(() {
                        filteredItems.clear();
                      });
                    },
                  );
                },
              ),
            )
                : Container(),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.8,
            left: MediaQuery.of(context).size.height*0.4,

            child: GestureDetector(
              onTap: (){
                _getCurrentLocation();
              },
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.my_location,color: Colors.green.shade900,),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Account",
          ),
        ],
      ),
    );
  }
}






