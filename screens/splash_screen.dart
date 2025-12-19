// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../landingpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize Animation Controller for 3 seconds duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _loadingPercentage = (_animation.value * 100).toInt();
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Navigate to Landing Page after animation completes
             Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MonkeyIdScreen()),
          );
        }
      });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B12), // Dark Green/Black Background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Loading Bar and Percentage (Positioned at bottom)
          Positioned(
            bottom: 100, // Moved up slightly to ensure visibility
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Percentage Text
                 Text(
                  "LOADING SYSTEM $_loadingPercentage%",
                  style: TextStyle(
                    color: const Color(0xFF4ADE80), // Neon Green
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                
                // Progress Bar and Monkey Animation
                SizedBox(
                  width: 240,
                  height: 50, // Increased height to accommodate monkey
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    clipBehavior: Clip.none,
                    children: [
                      // The Loading Bar
                      Container(
                        width: 240,
                        height: 8,
                        decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(10),
                           color: const Color(0xFF1E3A2F).withOpacity(0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _animation.value, // Bind to animation value
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                          ),
                        ),
                      ),
                      
                      // The Monkey Animation
                      Positioned(
                        left: (240 * _animation.value).clamp(0, 200).toDouble(), // Move along bar, clamp to prevent overflow (240 - width of monkey approx 40)
                        bottom: 8, // Sit slightly above the bar
                        child: Image.asset(
                          _loadingPercentage >= 100 
                              ? 'assets/images/monkey_eat.png' 
                              : 'assets/images/monkey_run.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),




        ],
      ),
    );
  }
}
