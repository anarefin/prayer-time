import 'dart:math';

/// Difficulty levels for CAPTCHA
enum CaptchaDifficulty {
  easy,   // Single digit (0-9)
  medium, // Double digit (10-99)
}

/// Service for generating and validating math CAPTCHA challenges
class CaptchaService {
  final Random _random = Random();
  
  // Store the current challenge
  int? _answer;
  String? _question;

  /// Generate a new CAPTCHA challenge
  CaptchaChallenge generateCaptcha({CaptchaDifficulty difficulty = CaptchaDifficulty.easy}) {
    final operation = _random.nextInt(3); // 0: addition, 1: subtraction, 2: multiplication
    
    int num1, num2, answer;
    String question;

    if (difficulty == CaptchaDifficulty.easy) {
      // Single digit numbers
      num1 = _random.nextInt(10); // 0-9
      num2 = _random.nextInt(10); // 0-9
    } else {
      // Double digit numbers (keep it reasonable)
      num1 = _random.nextInt(20) + 1; // 1-20
      num2 = _random.nextInt(20) + 1; // 1-20
    }

    switch (operation) {
      case 0: // Addition
        answer = num1 + num2;
        question = '$num1 + $num2 = ?';
        break;
      case 1: // Subtraction (ensure positive result)
        if (num1 < num2) {
          final temp = num1;
          num1 = num2;
          num2 = temp;
        }
        answer = num1 - num2;
        question = '$num1 - $num2 = ?';
        break;
      case 2: // Multiplication (only for easier numbers)
        if (difficulty == CaptchaDifficulty.medium) {
          // Use smaller numbers for multiplication
          num1 = _random.nextInt(10) + 1; // 1-10
          num2 = _random.nextInt(10) + 1; // 1-10
        }
        answer = num1 * num2;
        question = '$num1 × $num2 = ?';
        break;
      default:
        answer = num1 + num2;
        question = '$num1 + $num2 = ?';
    }

    _answer = answer;
    _question = question;

    return CaptchaChallenge(question: question, answer: answer);
  }

  /// Validate user's answer
  bool validateAnswer(String userAnswer) {
    if (_answer == null) {
      return false;
    }

    try {
      final parsedAnswer = int.parse(userAnswer.trim());
      return parsedAnswer == _answer;
    } catch (e) {
      return false;
    }
  }

  /// Get current question (for display purposes)
  String? get currentQuestion => _question;

  /// Clear current challenge
  void clearChallenge() {
    _answer = null;
    _question = null;
  }
}

/// Model class for CAPTCHA challenge
class CaptchaChallenge {
  final String question;
  final int answer;

  CaptchaChallenge({
    required this.question,
    required this.answer,
  });
}

