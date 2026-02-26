import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: LogoApp())));

class AnimatedLogo extends AnimatedWidget {
  const AnimatedLogo({super.key, required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: animation.value,
        width: animation.value,
        child: const Text("Show Up", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class LogoApp extends StatefulWidget {
  const LogoApp({super.key});

  @override
  State<LogoApp> createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2), 
      vsync: this,
    );
    
    // We removed the ..addListener(() => setState(() {})) 
    // because AnimatedWidget handles the rebuilding for us.
    animation = Tween<double>(begin: 0, end: 300).animate(controller);
    
    controller.forward();
  }

  @override
  Widget build(BuildContext context) => AnimatedLogo(animation: animation);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class BackgroundColor extends AnimatedWidget {
  // Pass the animation controller or tween here
  const BackgroundColor({super.key, required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    // Access the animation value to make the gradient dynamic
    final animation = listenable as Animation<double>;
    
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          // You can use animation.value to change the radius or center!
          center: const Alignment(0, 0), 
          radius: animation.value / 150, // Example: scales with the logo
          colors: [
            const Color.fromARGB(255, 173, 56, 56),
            const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.5),
          ],
        ),
      ),
    );
  }
}