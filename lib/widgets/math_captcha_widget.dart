import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/captcha_service.dart';

/// Widget for displaying and validating math CAPTCHA
class MathCaptchaWidget extends StatefulWidget {
  final CaptchaService captchaService;
  final Function(bool isValid) onValidationChanged;
  final CaptchaDifficulty difficulty;

  const MathCaptchaWidget({
    Key? key,
    required this.captchaService,
    required this.onValidationChanged,
    this.difficulty = CaptchaDifficulty.easy,
  }) : super(key: key);

  @override
  State<MathCaptchaWidget> createState() => _MathCaptchaWidgetState();
}

class _MathCaptchaWidgetState extends State<MathCaptchaWidget> {
  late TextEditingController _answerController;
  late CaptchaChallenge _currentChallenge;
  bool? _isValid;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _currentChallenge = widget.captchaService.generateCaptcha(
      difficulty: widget.difficulty,
    );
    
    // Listen to text changes for real-time validation
    _answerController.addListener(_validateAnswer);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _validateAnswer() {
    if (_answerController.text.isEmpty) {
      setState(() {
        _isValid = null;
      });
      widget.onValidationChanged(false);
      return;
    }

    final isValid = widget.captchaService.validateAnswer(_answerController.text);
    setState(() {
      _isValid = isValid;
    });
    widget.onValidationChanged(isValid);
  }

  void _regenerateChallenge() {
    setState(() {
      _currentChallenge = widget.captchaService.generateCaptcha(
        difficulty: widget.difficulty,
      );
      _answerController.clear();
      _isValid = null;
    });
    widget.onValidationChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Security Verification',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _currentChallenge.question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _regenerateChallenge,
                icon: Icon(
                  Icons.refresh,
                  color: Colors.blue.shade700,
                ),
                tooltip: 'Generate new problem',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.blue.shade300,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
            ],
            decoration: InputDecoration(
              labelText: 'Your Answer',
              hintText: 'Enter the result',
              prefixIcon: Icon(
                _isValid == null
                    ? Icons.edit
                    : _isValid!
                        ? Icons.check_circle
                        : Icons.cancel,
                color: _isValid == null
                    ? Colors.grey
                    : _isValid!
                        ? Colors.green
                        : Colors.red,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isValid == null
                      ? Colors.blue.shade300
                      : _isValid!
                          ? Colors.green
                          : Colors.red,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.blue.shade600,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please solve the math problem';
              }
              if (_isValid == false) {
                return 'Incorrect answer. Please try again.';
              }
              return null;
            },
          ),
          if (_isValid == true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Correct! You may proceed.',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else if (_isValid == false) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Incorrect. Please try again.',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

