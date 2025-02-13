import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;       // 控制背景和文字的淡入
  late AnimationController _breathingController;  // 控制文字“呼吸”闪动
  late Animation<double> _backgroundFade;         // 背景淡入
  late Animation<double> _textFade;               // 文字淡入
  late Animation<double> _breathingAnimation;     // 文字脉冲缩放

  @override
  void initState() {
    super.initState();

    // 1. 用于背景淡入 & 文字淡入的控制器
    //    这里设置成 5 秒，让背景淡得较慢
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // 背景淡入：0~100% 的时间都在做淡入（从黑到透明）
    _backgroundFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    // 文字淡入：示例设置在 20% ~ 40% 区间（即第 1 秒 ~ 第 2 秒之间）
    // 这样可以比背景稍早出现。想再早可调小 0.2，想更晚可调大或加长区间。
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.4, curve: Curves.easeIn),
      ),
    );

    // 启动淡入动画
    _fadeController.forward();

    // 2. 用于文字“呼吸”式闪动的控制器
    //    duration=2秒，repeat(reverse: true) 表示往返循环
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 文字缩放比从 1.0 ~ 1.1 往返呼吸
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 3. 预缓存图片，避免首次加载时闪烁或卡顿
    precacheImage(const AssetImage('assets/images/splash_image.png'), context);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ---- 底层：背景图 ----
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ---- 中层：黑色蒙层（用于背景淡入）----
          AnimatedBuilder(
            animation: _backgroundFade,
            builder: (context, child) {
              return Container(
                width: screenSize.width,
                height: screenSize.height,
                color: Colors.black.withOpacity(_backgroundFade.value),
              );
            },
          ),

          // ---- 顶层：日语文字（无背景容器），出现后做呼吸闪动 ----
          AnimatedBuilder(
            animation: Listenable.merge([_textFade, _breathingAnimation]),
            builder: (context, child) {
              return Align(
                // x=0, y=0.7 => 水平居中，垂直方向靠下
                alignment: const Alignment(0, 0.7),
                child: GestureDetector(
                  onTap: () {
                    // 点击后跳转到首页
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
                      ),
                    );
                  },
                  child: Opacity(
                    // 控制文字淡入
                    opacity: _textFade.value,
                    // 控制文字呼吸缩放
                    child: Transform.scale(
                      scale: _breathingAnimation.value,
                      child: const Text(
                        'さあ、旅を始めよう', // 日语：“来吧，开始旅行吧”
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
