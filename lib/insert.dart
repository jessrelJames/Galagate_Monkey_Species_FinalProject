import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:animate_do/animate_do.dart';
import 'data/monkey_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ClassifierScreen extends StatefulWidget {
  const ClassifierScreen({super.key});

  @override
  ClassifierScreenState createState() => ClassifierScreenState();
}

class ClassifierScreenState extends State<ClassifierScreen> {
  final _dbRef = FirebaseDatabase.instance.ref("classifications");
  final ImagePicker _picker = ImagePicker();
  
  File? _image;
  List<dynamic>? _output;
  bool _loading = false;
  String _timestamp = "";
  
  // Debug / Status
  String _saveStatus = "Ready";
  Color _saveStatusColor = Colors.grey;

  // Custom Colors
  final Color primaryColor = const Color(0xFF4ADE80); // Neon Green
  final Color cyanColor = const Color(0xFF22D3EE); // Cyan
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      Tflite.close();
    }
    super.dispose();
  }

  Future<void> _loadModel() async {
    if (kIsWeb) return; 
    try {
      await Tflite.loadModel(
        model: "assets/tflite/model_unquant.tflite",
        labels: "assets/tflite/labels.txt",
      );
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
      _loading = true;
      _output = null;
      _saveStatus = "Analyzing...";
      _saveStatusColor = Colors.blue;
      _timestamp = DateTime.now().toString().split('.')[0]; 
    });

    await _classifyImage(File(image.path));
  }

  Future<void> _classifyImage(File image) async {
    if (kIsWeb) {
       setState(() {
         _loading = false;
         _saveStatus = "Not supported on Web";
       });
      return;
    }

    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 10,
      threshold: 0.0, // Get all
      imageMean: 127.5,
      imageStd: 127.5,
    );
    
    List<dynamic> processedOutput = [];
    
    if (output != null && output.isNotEmpty) {
       // 1. Filter out zeros or extremely small noise
       var nonZeroOutput = output.where((item) => (item['confidence'] as double) > 0.0001).toList();
       
       if (nonZeroOutput.isNotEmpty) {
           // 2. Normalize to sum EXACTLY 1.0
           double totalConfidence = nonZeroOutput.fold(0.0, (sum, item) => sum + (item['confidence'] as double));
           
           processedOutput = nonZeroOutput.map((item) {
             return {
               "label": item['label'],
               "index": item['index'],
               "confidence": (item['confidence'] as double) / totalConfidence
             };
           }).toList();
           
           // Sort again just in case
           processedOutput.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
       }
    }

    setState(() {
      _loading = false;
      _output = processedOutput;
    });

    if (processedOutput.isNotEmpty) {
      await _saveResult();
    } else {
       setState(() {
         _saveStatus = "Failed to classify";
         _saveStatusColor = Colors.red;
       });
    }
  }

  Future<void> _saveResult() async {
    if (_output == null || _output!.isEmpty) return;

    setState(() {
      _saveStatus = "Saving...";
      _saveStatusColor = Colors.orange;
    });

    try {
      final label = _output![0]['label'].toString();
      final confidence = _output![0]['confidence'].toString();

      await _dbRef.push().set({
        "label": label,
        "confidence": confidence,
        "timestamp": DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        setState(() {
          _saveStatus = "Saved";
          _saveStatusColor = primaryColor;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saveStatus = "Error";
          _saveStatusColor = Colors.red;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _output = null;
      _saveStatus = "Ready";
    });
  }

  Monkey? _findMonkeyByLabel(String label) {
    var cleanLabel = label.replaceAll(RegExp(r'^[0-9]+\s*'), '').trim();
    if (cleanLabel.endsWith('...')) {
        cleanLabel = cleanLabel.substring(0, cleanLabel.length - 3).trim();
    }
    try {
      for (var m in monkeyData) {
        if (m.name.toLowerCase() == cleanLabel.toLowerCase()) return m;
      }
      for (var m in monkeyData) {
        if (m.name.toLowerCase().startsWith(cleanLabel.toLowerCase())) return m;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unique Theme for Result Screen
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _image == null ? _buildHomeAppBar() : _buildResultAppBar(),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [backgroundColor, const Color(0xFF0D0D0D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          ),
        ),
        child: _image == null ? _buildSelectionUI() : _buildResultUI(),
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      title: const Text("Identify Species", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.9), backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
        ),
    );
  }

  PreferredSizeWidget _buildResultAppBar() {
    return AppBar(
      title: const Text("Accurate Result", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), // Matched reference
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _reset),
      flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.9), backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
        ),
    );
  }

  Widget _buildSelectionUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: _buildPulseButton(Icons.center_focus_weak),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text("Start Identification", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text("Choose an option below", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInLeft(
                delay: const Duration(milliseconds: 400),
                child: _buildSelectionOption(Icons.camera_alt_outlined, "Camera", () => pickImage(ImageSource.camera)),
              ),
              const SizedBox(width: 24),
              FadeInRight(
                delay: const Duration(milliseconds: 400),
                child: _buildSelectionOption(Icons.photo_library_outlined, "Gallery", () => pickImage(ImageSource.gallery)),
              ),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildPulseButton(IconData icon) {
     return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Icon(icon, size: 60, color: primaryColor),
      );
  }

  Widget _buildSelectionOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          gradient: LinearGradient(
            colors: [cardColor, const Color(0xFF252525)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultUI() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 20),
            const Text("Analyzing...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_output == null || _output!.isEmpty) return const SizedBox.shrink();

    final topResult = _output![0];
    final topLabel = topResult['label'].toString().replaceAll(RegExp(r'[0-9]'), '').trim();
    final topConfidence = topResult['confidence'] * 100;

    double remainingPercent = 0;
    for (int i = 1; i < _output!.length; i++) {
      remainingPercent += (_output![i]['confidence'] * 100);
    }
    final otherClassesCount = _output!.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text("Prediction Details", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 1. Summary Card (Green Box in ref)
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E), // Slightly lighter than bg
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor, width: 2), // Green Border
                boxShadow: [
                   BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 0),
                ]
              ),
              child: Column(
                children: [
                  Text(
                    topLabel, 
                    style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Accuracy: ${topConfidence.toStringAsFixed(2)}%", 
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Recorded: $_timestamp",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 2. Full Prediction Breakdown Title
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: const Text("Full Prediction Breakdown", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 16),

          // 3. Top Prediction Text
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, height: 1.4),
                children: [
                  const TextSpan(text: "Top Prediction: ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: "$topLabel (${topConfidence.toStringAsFixed(2)}%)", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ]
              ),
            ),
          ),
          
          const SizedBox(height: 4),

          // 4. Remaining distribution Text
          FadeInUp(
             delay: const Duration(milliseconds: 350),
             child: Text(
               "Remaining ${remainingPercent.toStringAsFixed(2)}% distributed among $otherClassesCount other classes:",
               style: TextStyle(color: Colors.grey[400], fontSize: 14, fontStyle: FontStyle.italic),
             ),
          ),

          const SizedBox(height: 20),

          // 5. List Items (Match the ref style: Star/Dot, Label, Progress Bar)
          ..._output!.asMap().entries.map((entry) {
             final index = entry.key;
             final item = entry.value;
             final label = item['label'].toString().replaceAll(RegExp(r'[0-9]'), '').trim();
             final confidence = item['confidence'];
             final percent = (confidence * 100).toStringAsFixed(2);
             final isTop = index == 0;
             final monkey = _findMonkeyByLabel(label);

             return FadeInUp(
               delay: Duration(milliseconds: 400 + (index * 100)),
               child: _buildUniqueListItem(label, confidence, percent, isTop, monkey),
             );
          }).toList(),

          const SizedBox(height: 30),
          
          // 6. Footer Total
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Text(
              "Total: 100.00%", 
              style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 40),
          _buildRetakeButton(),
           const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUniqueListItem(String label, double confidence, String percent, bool isTop, Monkey? monkey) {
    // Unique list item style allowing expansion
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 10),
        leading: isTop 
            ? Icon(Icons.star, color: Colors.amber, size: 24) 
            : Icon(Icons.circle, color: Colors.grey[700], size: 12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            Text("$percent%", style: TextStyle(color: isTop ? primaryColor : Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                 isTop ? Colors.orangeAccent : (confidence > 0.1 ? Colors.yellow : Colors.grey)
              ),
            ),
          ),
        ),
        // Keep the description feature as a hidden bonus
        children: [
            if (monkey != null)
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.black26, 
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            if (monkey.imagePath.isNotEmpty)
                                Container(
                                    width: 50, height: 50,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(image: AssetImage(monkey.imagePath), fit: BoxFit.cover)
                                    ),
                                ),
                            Expanded(child: Text(monkey.description, style: TextStyle(color: Colors.grey[400], fontSize: 13)))
                        ],
                    ),
                )
        ],
      ),
    );
  }

  Widget _buildRetakeButton() {
     return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _reset,
        child: const Text("SCAN AGAIN", style: TextStyle(color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }
}
