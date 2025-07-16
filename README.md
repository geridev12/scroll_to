# scroll_to

A Flutter package for smooth scrolling to specific widgets with customizable animations.

<img src="doc/showcase.gif" alt="ScrollTo Demo" width="350"/>

## Features

- 🎯 **Scroll to any widget** by ID with smooth animations
- ⚡ **Multiple animation types** - linear, ease, bounce, and more
- 🎮 **Easy-to-use controller** for managing scroll operations
- 📝 **Auto-wrapping ListView** for effortless list navigation
- 🔧 **Highly customizable** duration, easing, and alignment options
- 🐛 **Debug mode** for development and troubleshooting

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  scroll_to: ^0.1.0
```

Then run:
```bash
flutter pub get
```

## Usage

### Basic Setup

```dart
import 'package:scroll_to/scroll_to.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late ScrollToController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollToController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### Wrap widgets you want to scroll to

```dart
ScrollToWidget(
  id: 'section-1',
  controller: _scrollController,
  child: Container(
    height: 200,
    color: Colors.blue,
    child: Text('Section 1'),
  ),
)
```

### Scroll to a widget

```dart
// Simple scroll
_scrollController.scrollToKey('section-1');

// With custom animation
_scrollController.scrollToKey(
  'section-1',
  config: ScrollToConfig(
    duration: Duration(milliseconds: 800),
    animationType: ScrollAnimationType.easeInOut,
    alignment: 0.1, // 10% from top
  ),
);
```

### Quick shortcuts

```dart
// Scroll to top
_scrollController.scrollToTop();

// Scroll to bottom
_scrollController.scrollToBottom();
```

### Auto-wrapping ListView

For lists, use `ScrollToListView` to automatically wrap items:

```dart
ScrollToListView(
  controller: _scrollController,
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
)
```

## Configuration Options

| Property | Description | Default |
|----------|-------------|---------|
| `duration` | Animation duration | `500ms` |
| `animationType` | Easing curve | `easeInOut` |
| `alignment` | Target position (0.0 = top, 1.0 = bottom) | `0.0` |
| `paddingTop` | Extra padding from top | `0.0` |
| `debugMode` | Enable debug logging | `false` |

## Animation Types

- `linear` - Constant speed
- `easeIn` - Slow start, fast end
- `easeOut` - Fast start, slow end  
- `easeInOut` - Slow start and end
- `bouncy` - Bounce effect
- `elastic` - Elastic effect

## Example

Check out the `/example` folder for a complete demo app showing all features in action.

## Issues and Contributing

Found a bug or want to contribute? Visit our [GitHub repository](https://github.com/geridev12/scroll_to).

## License

This project is licensed under the MIT License.
