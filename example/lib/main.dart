import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to/scroll_to.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScrollTo Package Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ScrollToDemo(),
    );
  }
}

class ScrollToDemo extends StatefulWidget {
  const ScrollToDemo({super.key});

  @override
  State<ScrollToDemo> createState() => _ScrollToDemoState();
}

class _ScrollToDemoState extends State<ScrollToDemo> {
  late final ScrollToController _scrollController;
  final UnmodifiableListView<Color> _colors = UnmodifiableListView([
    Colors.red.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
    Colors.teal.shade300,
    Colors.indigo.shade300,
    Colors.pink.shade300,
    Colors.amber.shade300,
    Colors.cyan.shade300,
  ]);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollToController(
      defaultConfig: const ScrollToConfig(debugMode: kDebugMode),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.scrollToKey(
        index,
        config: ScrollToConfig(
          duration: const Duration(milliseconds: 800),
          animationType: ScrollAnimationType.easeInOut,
          alignment: 0.1,
          paddingTop: 16,
          debugMode: true,
          onScrollStart: () => debugPrint('Scroll started to section $index'),
          onScrollComplete:
              () => debugPrint('Scroll completed to section $index'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrollTo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              spacing: 8,
              children: [
                const Text(
                  'Tap buttons to scroll to sections',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < _colors.length; i++) ...[
                      ElevatedButton(
                        onPressed: () => _scrollToSection(i),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colors[i],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Section ${i + 1}'),
                      ),
                    ],
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          () async => _scrollController.scrollToTop(
                            config: ScrollToConfig.fast,
                          ),
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text('Top'),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          () async => _scrollController.scrollToBottom(
                            config: ScrollToConfig.bouncy,
                          ),
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text('Bottom'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController.scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (int index = 0; index < _colors.length; index++) ...[
                    ScrollToWidget(
                      id: index,
                      controller: _scrollController,
                      child: Section(
                        index: index,
                        colors: _colors,
                        scrollToSection:
                            () =>
                                _scrollToSection((index + 1) % _colors.length),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _scrollController,
        builder: (context, child) {
          return FloatingActionButton(
            onPressed:
                _scrollController.isScrolling
                    ? null
                    : () => _showAnimationDemo(context),
            backgroundColor: _scrollController.isScrolling ? Colors.grey : null,
            child: Icon(
              _scrollController.isScrolling
                  ? Icons.hourglass_empty
                  : Icons.play_arrow,
            ),
          );
        },
      ),
    );
  }

  void _showAnimationDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Animation Demo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Text('Choose an animation type:'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AnimationButton(
                    controller: _scrollController,
                    label: 'Linear',
                    config: ScrollToConfig.fast,
                  ),
                  AnimationButton(
                    controller: _scrollController,
                    label: 'Fast',
                    config: ScrollToConfig.fast,
                  ),
                  AnimationButton(
                    controller: _scrollController,
                    label: 'Smooth',
                    config: ScrollToConfig.smooth,
                  ),
                  AnimationButton(
                    controller: _scrollController,
                    label: 'Bouncy',
                    config: ScrollToConfig.bouncy,
                  ),
                  AnimationButton(
                    controller: _scrollController,
                    label: 'Spring',
                    config: ScrollToConfig.spring,
                  ),
                  AnimationButton(
                    controller: _scrollController,
                    label: 'Elastic',
                    config: const ScrollToConfig(
                      duration: Duration(milliseconds: 1500),
                      animationType: ScrollAnimationType.elastic,
                      alignment: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class AnimationButton extends StatelessWidget {
  const AnimationButton({
    super.key,
    required this.controller,
    required this.label,
    required this.config,
  });

  final ScrollToController controller;
  final String label;
  final ScrollToConfig config;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        Navigator.pop(context);
        await controller.scrollToKey(5, config: config);
      },
      child: Text(label),
    );
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.index,
    required this.colors,
    required this.scrollToSection,
  });

  final int index;
  final List<Color> colors;
  final VoidCallback scrollToSection;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors[index],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            'Section ${index + 1}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'This is section ${index + 1}. Each section is automatically registered with the ScrollToController for smooth navigation',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          ElevatedButton(
            onPressed: scrollToSection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors[index],
            ),
            child: Text('Go to Section ${((index + 1) % colors.length) + 1}'),
          ),
        ],
      ),
    );
  }
}
