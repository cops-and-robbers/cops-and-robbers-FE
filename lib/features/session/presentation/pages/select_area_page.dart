import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';

/// 구역 선택/확인 화면
///
/// 플레이그라운드와 감옥 구역 설정을 위한 진입점입니다.
class SelectAreaPage extends StatefulWidget {
  const SelectAreaPage({super.key});

  @override
  State<SelectAreaPage> createState() => _SelectAreaPageState();
}

class _SelectAreaPageState extends State<SelectAreaPage> {
  bool playgroundSet = false;
  bool prisonSet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('구역 설정')),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('플레이그라운드와 감옥 구역을 설정하세요', style: AppTextStyles.heading02),
              SizedBox(height: AppSpacing.vertical40),
              ElevatedButton(
                onPressed: () async {
                  await context.push(RoutePaths.setupPlaygroundPath);
                  setState(() {
                    playgroundSet = true;
                  });
                },
                child: Text(playgroundSet ? '플레이그라운드 설정 완료 ✓' : '플레이그라운드 설정'),
              ),
              SizedBox(height: AppSpacing.vertical12),
              ElevatedButton(
                onPressed: () async {
                  await context.push(RoutePaths.setupPrisonPath);
                  setState(() {
                    prisonSet = true;
                  });
                },
                child: Text(prisonSet ? '감옥 설정 완료 ✓' : '감옥 설정'),
              ),
              SizedBox(height: AppSpacing.vertical40),
              ElevatedButton(
                onPressed: (playgroundSet && prisonSet)
                    ? () => context.go(RoutePaths.sessionSettingsPath)
                    : null,
                child: const Text('다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
