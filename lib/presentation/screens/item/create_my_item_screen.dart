import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:save_earth/data/local_storage_helper.dart';
import 'package:save_earth/logic/Bloc/create_item/create_item_event_bloc.dart';
import 'package:save_earth/route/convert_route.dart';

class CreateMyItemScreen extends StatefulWidget {
  const CreateMyItemScreen({super.key});

  @override
  State<CreateMyItemScreen> createState() => _CreateMyItemScreenState();
}

class _CreateMyItemScreenState extends State<CreateMyItemScreen> {
  File? _image;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherCategoryController = TextEditingController();
  String? _selectedCategory;
  bool isOtherCategorySelected = false;

  final List<String> categories = [
    "เฟอร์นิเจอร์",
    "เครื่องใช้ไฟฟ้า",
    "เสื้อผ้า",
    "หนังสือ",
    "ของใช้ในบ้าน",
    "ของเล่น",
    "อื่นๆ"
  ];

  MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(13.7563, 100.5018);

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _createItem() async {
    if (_formKey.currentState!.validate()) {
      final user = await LocalStorageHelper.getUser();
      if (user != null) {
        context.read<CreateItemBloc>().add(CreateItem(
          name: _nameController.text,
          category: isOtherCategorySelected ? _otherCategoryController.text : _selectedCategory.toString(),
          description: _descriptionController.text,
          latitude: _currentLocation.latitude,
          longitude: _currentLocation.longitude,
          posterUserId: user.userId,
          image: _image,
        ));
        Navigator.pushReplacementNamed(context, Routes.myItemList.toStringPath());
      }
    }
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation, 15.0);
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      isOtherCategorySelected = category == "อื่นๆ";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("สร้างสิ่งของของฉัน", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _image == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/image/imagePiker.png", height: 80),
                        const SizedBox(height: 8),
                        const Text("เพิ่มรูปภาพสิ่งของ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                ),
              ),
              if (_image == null) const Text("กรุณาเลือกรูปภาพ", style: TextStyle(color: Colors.red)),

              const SizedBox(height: 16),

              _buildTextField("คุณเรียกของสิ่งนี้ว่าอะไร", _nameController),

              const SizedBox(height: 12),

              _buildTextField("คำอธิบายเพิ่มเติม...", _descriptionController, height: 120),

              const SizedBox(height: 16),

              const Text("ประเภท", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: categories.map((category) {
                  bool isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00DC00) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_selectedCategory == null) const Text("กรุณาเลือกประเภท", style: TextStyle(color: Colors.red)),

              if (isOtherCategorySelected) ...[
                const SizedBox(height: 12),
                _buildTextField("กรอกประเภทอื่นๆ", _otherCategoryController),
              ],

              const SizedBox(height: 16),

              const Text("ตำแหน่ง", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 15.0,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          setState(() => _currentLocation = position.center);
                        }
                      },
                    ),
                    children: [
                      TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
                      MarkerLayer(markers: [Marker(width: 40.0, height: 40.0, point: _currentLocation, child: const Icon(Icons.location_on, color: Colors.green, size: 40))]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _getUserLocation,
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  label: const Text("ตำแหน่งปัจจุบัน"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade900),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _createItem,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade900, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text("สร้างเลย", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildTextField(String placeholder, TextEditingController controller, {double height = 50}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: placeholder, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      validator: (value) => value!.isEmpty ? "กรุณากรอก $placeholder" : null,
      maxLines: height > 50 ? null : 1,
      minLines: height > 50 ? 3 : 1,
    );
  }
}
