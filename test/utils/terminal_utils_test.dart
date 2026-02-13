import 'package:flutter_test/flutter_test.dart';
import 'package:zytra_terminal/utils/terminal_utils.dart';

void main() {
  group('TerminalUtils', () {
    group('sanitizeTitle', () {
      test('should return default title when input is null', () {
        expect(TerminalUtils.sanitizeTitle(null), TerminalUtils.defaultTitle);
      });

      test('should return default title when input is empty', () {
        expect(TerminalUtils.sanitizeTitle(''), TerminalUtils.defaultTitle);
      });

      test('should return default title when input is only whitespace', () {
        expect(TerminalUtils.sanitizeTitle('   '), TerminalUtils.defaultTitle);
      });

      test('should return input when valid', () {
        expect(TerminalUtils.sanitizeTitle('My Terminal'), 'My Terminal');
      });

      test('should trim whitespace from valid input', () {
        expect(TerminalUtils.sanitizeTitle('  My Terminal  '), 'My Terminal');
      });

      test('should remove control characters', () {
        const input = 'Title\x00\x07With\x1BControl';
        expect(TerminalUtils.sanitizeTitle(input), 'TitleWithControl');
      });

      test('should handle path-like titles', () {
        const input = '/home/user/projects/zytra';
        expect(TerminalUtils.sanitizeTitle(input), '/home/user/projects/zytra');
      });

      test('should handle user@host:path format', () {
        const input = 'user@linux: ~/projects';
        expect(TerminalUtils.sanitizeTitle(input), 'user@linux: ~/projects');
      });
    });
  });
}
