import 'dart:io';

import 'package:test/test.dart';
import 'package:tree_sitter_language_pack/tree_sitter_language_pack.dart';
// The package's documented RustLib entry point is not exported publicly.
// ignore: implementation_imports
import 'package:tree_sitter_language_pack/src/tree_sitter_language_pack_bridge_generated/frb_generated.dart'
    show RustLib;

void main() {
  test('Tree-sitter extracts TypeScript imports and exports', () async {
    await RustLib.init();
    await TreeSitterLanguagePackBridge.init();
    final result = await TreeSitterLanguagePackBridge.process(
      "import { Helper } from './shared';\n"
      'export function render(value: Helper): string {\n'
      "  return 'rendered';\n"
      '}\n',
      config: const ProcessConfig(
        language: 'typescript',
        structure: true,
        imports: true,
        exports: true,
        comments: false,
        docstrings: false,
        symbols: false,
        diagnostics: true,
        dataExtraction: false,
        maxSourceBytes: 1024,
        parseTimeoutMs: 1500,
      ),
    );

    expect(result.imports.map((item) => item.source), contains('./shared'));
    expect(result.imports.single.items, contains('Helper'));
    expect(result.exports.map((item) => item.name), contains('render'));
    expect(result.metrics.errorCount, 0);
  }, skip: Platform.environment['RIPPLEMAP_RUN_NATIVE_PARSER_TESTS'] != 'true');
}
