import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../data/monkey_data.dart';
import 'detail_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  final String heroTagPrefix;
  
  const HomeScreen({super.key, this.heroTagPrefix = 'home'});

  // Theme Colors
  final Color primaryColor = const Color(0xFF4ADE80); // Neon Green
  final Color secondaryColor = const Color(0xFF22D3EE); // Cyan
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          "Monkey Species",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [backgroundColor, const Color(0xFF0D0D0D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          ),
        ),
        child: monkeyData.isEmpty 
            ? const Center(child: Text("No species data found", style: TextStyle(color: Colors.white)))
            : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65, // Taller cards to prevent overflow
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: monkeyData.length,
                itemBuilder: (context, index) {
                  final monkey = monkeyData[index];
                  final tag = "${heroTagPrefix}_${monkey.name}_$index";
                  
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100), // Staggered Animation
                    duration: const Duration(milliseconds: 600),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(monkey: monkey, heroTag: tag),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [cardColor, const Color(0xFF252525)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Hero(
                                tag: tag,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                    child: monkey.imagePath.contains("assets")
                                      ? Image.asset(
                                          monkey.imagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[850],
                                              child: const Center(
                                                child: Icon(Icons.pets, size: 40, color: Colors.white12),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[850],
                                          child: const Center(
                                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.white12),
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          monkey.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis,
                                            height: 1.1,
                                          ),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 2, 
                                          width: 20, 
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Explore",
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white12),
                                          ),
                                          child: Icon(Icons.arrow_forward_ios, color: secondaryColor, size: 10),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }
}
