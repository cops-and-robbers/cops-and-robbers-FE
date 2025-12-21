import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cops and Robbers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FontTestPage(),
    );
  }
}

class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pretendard Font Test'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pretendard 폰트 Weight 테스트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Thin (100)',
              style: TextStyle(fontFamily: 'Pretendard-Thin', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-Thin')),
            Divider(),
            Text(
              'ExtraLight (200)',
              style: TextStyle(fontFamily: 'Pretendard-ExtraLight', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-ExtraLight')),
            Divider(),
            Text(
              'Light (300)',
              style: TextStyle(fontFamily: 'Pretendard-Light', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-Light')),
            Divider(),
            Text(
              'Regular (400)',
              style: TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-Regular')),
            Divider(),
            Text(
              'Medium (500)',
              style: TextStyle(fontFamily: 'Pretendard-Medium', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-Medium')),
            Divider(),
            Text(
              'SemiBold (600)',
              style: TextStyle(fontFamily: 'Pretendard-SemiBold', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-SemiBold')),
            Divider(),
            Text(
              'Bold (700)',
              style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-Bold')),
            Divider(),
            Text(
              'ExtraBold (800)',
              style: TextStyle(fontFamily: 'Pretendard-ExtraBold', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-ExtraBold')),
            Divider(),
            Text(
              'Black (900)',
              style: TextStyle(fontFamily: 'Pretendard-Black', fontSize: 18),
            ),
            Text('경찰과 도둑 Cops and Robbers 1234567890',
                style: TextStyle(fontFamily: 'Pretendard-Black')),
          ],
        ),
      ),
    );
  }
}
