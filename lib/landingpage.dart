import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';

// You can run this main function to see the result
void main() {
  runApp(const MonkeyIdApp());
}

class MonkeyIdApp extends StatelessWidget {
  const MonkeyIdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MonkeyID',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      home: const MonkeyIdScreen(),
    );
  }
}

class MonkeyIdScreen extends StatefulWidget {
  const MonkeyIdScreen({super.key});

  @override
  State<MonkeyIdScreen> createState() => _MonkeyIdScreenState();
}

class _MonkeyIdScreenState extends State<MonkeyIdScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system status bar to clear/light for full screen effect
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (Animated Zoom)
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset(
                  'assets/images/monkey_bg.png',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          // 2. Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(1.0),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   // --- Top Header ---
                  FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Changed to start since version info is removed
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(
                            Icons.forest,
                            color: Color(0xFF4ADE80), // Bright Green
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Monkey Species", // Changed from "Monkey"
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Identifier",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        // Version badge removed as requested
                      ],
                    ),
                  ),

                  const Spacer(),

                  // AI Powered Badge removed as requested

                  const SizedBox(height: 24),

                  // --- Main Title ---
                  FadeInUp(
                    duration: const Duration(milliseconds: 1400),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 48, // Large size
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: "Explore a\nWorld of\n"),
                          TextSpan(
                            text: "Monkey\n",
                            style: TextStyle(
                              color: Color(0xFF4ADE80),
                              shadows: [
                                Shadow(blurRadius: 20, color: Color(0xFF4ADE80), offset: Offset(0, 0))
                              ]
                            ), 
                          ),
                          TextSpan(text: "Species"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Subtitle ---
                  FadeInUp(
                    duration: const Duration(milliseconds: 1500),
                    child: Text(
                      "Snap a photo to instantly identify primates, explore their habitats, and contribute to global conservation efforts.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // --- Start Button ---
                  FadeInUp(
                    duration: const Duration(milliseconds: 1600),
                    child: SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4ADE80).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ADE80), // Neon Green
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.center_focus_weak, size: 28, color: Colors.black),
                              SizedBox(width: 12),
                              Text(
                                "Start",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Footer Text ---
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Text(
                      "By continuing, you agree to our Terms & Privacy Policy",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
