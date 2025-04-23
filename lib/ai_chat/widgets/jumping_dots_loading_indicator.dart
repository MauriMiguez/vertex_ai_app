import 'package:flutter/material.dart';

/// Jumping Dot.
///
/// [numberOfDots] number of dots,
/// [radius] radius of dots.
/// [innerPadding] padding between dots.
/// [animationDuration] animation duration in milliseconds
/// [color] color of dots.
/// [jumpColor] color of dots when jumping.
/// [verticalOffset] defines how much the animation will offset in the `y` axis.
class JumpingDotsLoadingIndicator extends StatefulWidget {
  JumpingDotsLoadingIndicator({
    super.key,
    this.numberOfDots = 3,
    this.radius = 10,
    this.innerPadding = 2.5,
    this.animationDuration = const Duration(milliseconds: 200),
    this.color = const Color(0xFF333333),
    this.jumpColor = const Color(0xFFaec1dd),
    this.verticalOffset = -2,
  }) : assert(
         verticalOffset.isFinite,
         'Non-finite values cannot be set as an animation offset.',
       ),
       assert(
         verticalOffset != 0,
         'Zero values (0) cannot be set as an animation offset.',
       );

  final int numberOfDots;
  final Color color;
  final Color jumpColor;
  final double radius;
  final double innerPadding;
  final Duration animationDuration;

  /// Defines how much the animation will offset negatively in the `y` axis.
  /// Can be either positive or negative, as it'll later be converted into its
  /// negative value.
  ///
  /// Non-finite or zero (0) values are not accepted.
  final double verticalOffset;

  @override
  State<JumpingDotsLoadingIndicator> createState() =>
      _JumpingDotsLoadingIndicatorState();
}

class _JumpingDotsLoadingIndicatorState
    extends State<JumpingDotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController>? _animationControllers;

  final List<Animation<double>> _animations = [];

  final List<Animation<Color?>> _colorAnimations = [];

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers!) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initAnimation() {
    _animationControllers =
        List.generate(widget.numberOfDots, (index) {
          return AnimationController(
            vsync: this,
            duration: widget.animationDuration,
          );
        }).toList();

    for (var i = 0; i < widget.numberOfDots; i++) {
      _animations.add(
        Tween<double>(
          begin: 0,
          end: -widget.verticalOffset.abs(), // Ensure the offset is negative.
        ).animate(_animationControllers![i]),
      );
      _colorAnimations.add(
        ColorTween(
          begin: widget.color,
          end: widget.jumpColor,
        ).animate(_animationControllers![i]),
      );
    }

    for (var i = 0; i < widget.numberOfDots; i++) {
      _animationControllers![i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationControllers![i].reverse();
          if (i != widget.numberOfDots - 1) {
            _animationControllers![i + 1].forward();
          }
        }
        if (i == widget.numberOfDots - 1 &&
            status == AnimationStatus.dismissed) {
          _animationControllers![0].forward();
        }
      });
    }
    _animationControllers!.first.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          List.generate(widget.numberOfDots, (index) {
            return AnimatedBuilder(
              animation: _animationControllers![index],
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.all(widget.innerPadding),
                  child: Transform.translate(
                    offset: Offset(0, _animations[index].value),
                    child: DotWidget(
                      color: _colorAnimations[index].value,
                      radius: widget.radius,
                    ),
                  ),
                );
              },
            );
          }).toList(),
    );
  }
}

class DotWidget extends StatelessWidget {
  const DotWidget({required this.color, required this.radius, super.key});

  final Color? color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      height: radius,
      width: radius,
    );
  }
}
