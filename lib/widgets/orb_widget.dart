import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrbWidget extends StatelessWidget {
  final bool isListening;
  final bool isSpeaking;
  final bool isProcessing;

  const OrbWidget({
    super.key,
    required this.isListening,
    required this.isSpeaking,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow Effect
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(
                      isListening || isSpeaking ? 0.4 : 0.1
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(
              target: isListening || isSpeaking ? 1 : 0,
            ).scaleXY(
              begin: 0.8,
              end: 1.4,
              duration: const Duration(milliseconds: 500),
            ),
            
            // Main Orb
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _getOrbColors(context),
                  stops: const [0.3, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getOrbShadowColor(context),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: _getOrbIcon(),
              ),
            ).animate(
              target: isListening || isSpeaking || isProcessing ? 1 : 0,
            ).pulse(
              duration: const Duration(milliseconds: 1200),
              infinite: true,
            ),
            
            // Status Text
            Positioned(
              bottom: 10,
              child: Column(
                children: [
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isListening)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Say "Zishu" to activate',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getOrbColors(BuildContext context) {
    if (isListening) {
      return [
        Colors.red.shade100,
        Colors.red.shade400,
        Colors.red.shade700,
      ];
    } else if (isSpeaking) {
      return [
        Colors.blue.shade100,
        Colors.blue.shade400,
        Colors.blue.shade700,
      ];
    } else if (isProcessing) {
      return [
        Colors.orange.shade100,
        Colors.orange.shade400,
        Colors.orange.shade700,
      ];
    }
    return [
      Colors.white,
      Colors.grey.shade300,
      Colors.grey.shade600,
    ];
  }

  Color _getOrbShadowColor(BuildContext context) {
    if (isListening) {
      return Colors.red.withOpacity(0.3);
    } else if (isSpeaking) {
      return Colors.blue.withOpacity(0.3);
    } else if (isProcessing) {
      return Colors.orange.withOpacity(0.3);
    }
    return Colors.grey.withOpacity(0.1);
  }

  Widget _getOrbIcon() {
    if (isListening) {
      return const Icon(Icons.mic, color: Colors.white, size: 44);
    } else if (isSpeaking) {
      return const Icon(Icons.volume_up, color: Colors.white, size: 44);
    } else if (isProcessing) {
      return const Icon(Icons.hourglass_empty, color: Colors.white, size: 44);
    }
    return const Icon(Icons.circle, color: Colors.grey, size: 44);
  }

  String _getStatusText() {
    if (isListening) return 'Listening... Say something';
    if (isSpeaking) return 'Speaking...';
    if (isProcessing) return 'Processing...';
    return 'Tap to speak or say "Zishu"';
  }
}
