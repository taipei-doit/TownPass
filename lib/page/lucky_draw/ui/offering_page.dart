import 'package:flutter/material.dart';
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

class OfferingPage extends StatefulWidget {
  const OfferingPage({super.key});

  @override
  State<OfferingPage> createState() => _OfferingPageState();
}

class _OfferingPageState extends State<OfferingPage> {
  final _images = [
    'assets/image/offering/apple.png',
    'assets/image/offering/banana.png',
    'assets/image/offering/grapes.png',
    'assets/image/offering/longan.png',
    'assets/image/offering/mango.png',
    'assets/image/offering/orange.png',
    'assets/image/offering/pineapple.png',
    'assets/image/offering/rose_apple.png',
    'assets/image/offering/wang.png',
  ];

  final List<_OfferedItem> _offeredItems = [];

  void _addOffering(String imagePath, Offset position, Offset velocity) {
    setState(() {
      _offeredItems.add(_OfferedItem(
        imagePath: imagePath,
        position: position,
        velocity: velocity,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuckyDrawAppBar(subtitle: '獻供'),
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: DragTarget<Map<String, dynamic>>(
                  onAcceptWithDetails: (details) {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final localPosition = box.globalToLocal(details.offset);
                    _addOffering(
                      details.data['imagePath'] as String,
                      localPosition,
                      details.data['velocity'] as Offset,
                    );
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? TPColors.primary500
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          if (_offeredItems.isEmpty)
                            const Center(
                              child: Text(
                                '拖曳供品到此處',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ..._offeredItems.map(
                            (item) => _AnimatedOfferedItem(
                              key: ValueKey(item),
                              item: item,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _images.length,
                  itemBuilder: (_, index) =>
                      _PreparedItem(imagePath: _images[index]),
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferedItem {
  final String imagePath;
  final Offset position;
  final Offset velocity;

  _OfferedItem({
    required this.imagePath,
    required this.position,
    required this.velocity,
  });
}

class _AnimatedOfferedItem extends StatefulWidget {
  const _AnimatedOfferedItem({super.key, required this.item});

  final _OfferedItem item;

  @override
  State<_AnimatedOfferedItem> createState() => _AnimatedOfferedItemState();
}

class _AnimatedOfferedItemState extends State<_AnimatedOfferedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    
    // 動畫持續時間（秒）
    const animationDuration = 0.8;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 計算根據速度的最終位置
    // 物理模型：使用減速運動公式
    // 移動距離 = 初速度 × 時間 × 減速因子
    // 減速因子：0.5 表示平均速度是初速度的一半（線性減速到0）
    final velocity = widget.item.velocity;
    const decelerationFactor = 0.6; // 平均速度係數
    
    // 最終移動距離 = 速度(px/s) × 動畫時間(s) × 減速因子
    final displacement = Offset(
      velocity.dx * animationDuration * decelerationFactor,
      velocity.dy * animationDuration * decelerationFactor,
    );
    
    final finalOffset = widget.item.position + displacement;

    _positionAnimation = Tween<Offset>(
      begin: widget.item.position,
      end: finalOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate, // 模擬減速效果
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx - 40,
          top: _positionAnimation.value.dy - 40,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              widget.item.imagePath,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class _PreparedItem extends StatefulWidget {
  const _PreparedItem({required this.imagePath});

  final String imagePath;

  @override
  State<_PreparedItem> createState() => _PreparedItemState();
}

class _VelocitySample {
  final Offset position;
  final DateTime time;

  _VelocitySample({required this.position, required this.time});
}

class _PreparedItemState extends State<_PreparedItem> {
  bool _isScaled = false;
  Offset _velocity = Offset.zero;
  final List<_VelocitySample> _velocitySamples = [];

  void _updateVelocity(Offset position) {
    final now = DateTime.now();
    _velocitySamples.add(_VelocitySample(position: position, time: now));
    
    // 只保留最近 100ms 的樣本
    _velocitySamples.removeWhere(
      (sample) => now.difference(sample.time).inMilliseconds > 100,
    );
    
    // 使用最近的樣本計算平均速度
    if (_velocitySamples.length >= 2) {
      final first = _velocitySamples.first;
      final last = _velocitySamples.last;
      final dt = last.time.difference(first.time).inMilliseconds / 1000.0;
      
      if (dt > 0) {
        final deltaPosition = last.position - first.position;
        // 只計算垂直方向的速度，水平方向設為 0 避免橫向亂飛
        _velocity = Offset(0, deltaPosition.dy / dt);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Map<String, dynamic>>(
      data: {
        'imagePath': widget.imagePath,
        'velocity': _velocity,
      },
      feedback: SizedBox(
        width: 120,
        height: 120,
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
        ),
      ),
      onDragStarted: () {
        setState(() => _isScaled = true);
        _velocitySamples.clear();
        _velocity = Offset.zero;
      },
      onDragUpdate: (details) {
        _updateVelocity(details.globalPosition);
      },
      onDragEnd: (_) => setState(() => _isScaled = false),
      delay: const Duration(milliseconds: 500),
      hapticFeedbackOnStart: true,
      child: AnimatedScale(
        scale: _isScaled ? 1.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
