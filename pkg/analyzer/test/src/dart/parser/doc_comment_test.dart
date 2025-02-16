// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../diagnostics/parser_diagnostics.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DocCommentParserTest);
  });
}

@reflectiveTest
class DocCommentParserTest extends ParserDiagnosticsTest {
  test_codeSpan() {
    final parseResult = parseStringWithErrors(r'''
/// `a[i]` and [b].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    // TODO(srawlins): Parse code into its own node.
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /// `a[i]` and [b].
''');
  }

  test_codeSpan_legacy_blockComment() {
    // TODO(srawlins): I believe we should drop support for `[:` `:]`.
    final parseResult = parseStringWithErrors(r'''
/** [:xxx [a] yyy:] [b] zzz */
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a]');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /** [:xxx [a] yyy:] [b] zzz */
''');
  }

  test_codeSpan_unterminated_blockComment() {
    final parseResult = parseStringWithErrors(r'''
/** `a[i] and [b] */
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: i
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /** `a[i] and [b] */
''');
  }

  test_commentReference_blockComment() {
    final parseResult = parseStringWithErrors(r'''
/** [a]. */
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a]');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: a
  tokens
    /** [a]. */
''');
  }

  test_commentReference_empty() {
    final parseResult = parseStringWithErrors(r'''
/// [].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[]');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: <empty> <synthetic>
  tokens
    /// [].
''');
  }

  test_commentReference_multiple() {
    final parseResult = parseStringWithErrors(r'''
/// [a] and [b].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a]');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: a
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /// [a] and [b].
''');
  }

  test_commentReference_multiple_blockComment() {
    final parseResult = parseStringWithErrors(r'''
/** [a] and [b]. */
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a]');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: a
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /** [a] and [b]. */
''');
  }

  test_commentReference_new_prefixed() {
    final parseResult = parseStringWithErrors(r'''
/// [new a.A].
class B {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('new');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      newKeyword: new
      expression: PrefixedIdentifier
        prefix: SimpleIdentifier
          token: a
        period: .
        identifier: SimpleIdentifier
          token: A
  tokens
    /// [new a.A].
''');
  }

  test_commentReference_new_simple() {
    final parseResult = parseStringWithErrors(r'''
/// [new A].
class B {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('new');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      newKeyword: new
      expression: SimpleIdentifier
        token: A
  tokens
    /// [new A].
''');
  }

  test_commentReference_operator_withKeyword_notPrefixed() {
    final parseResult = parseStringWithErrors(r'''
/// [operator ==].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('==');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: ==
  tokens
    /// [operator ==].
''');
  }

  test_commentReference_operator_withKeyword_prefixed() {
    final parseResult = parseStringWithErrors(r'''
/// [Object.operator ==].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('==');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: PrefixedIdentifier
        prefix: SimpleIdentifier
          token: Object
        period: .
        identifier: SimpleIdentifier
          token: ==
  tokens
    /// [Object.operator ==].
''');
  }

  test_commentReference_operator_withoutKeyword_notPrefixed() {
    final parseResult = parseStringWithErrors(r'''
/// [==].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('==');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: ==
  tokens
    /// [==].
''');
  }

  test_commentReference_operator_withoutKeyword_prefixed() {
    final parseResult = parseStringWithErrors(r'''
/// [Object.==].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('==');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: PrefixedIdentifier
        prefix: SimpleIdentifier
          token: Object
        period: .
        identifier: SimpleIdentifier
          token: ==
  tokens
    /// [Object.==].
''');
  }

  test_commentReference_prefixedIdentifier() {
    final parseResult = parseStringWithErrors(r'''
/// [a.b].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a.b');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: PrefixedIdentifier
        prefix: SimpleIdentifier
          token: a
        period: .
        identifier: SimpleIdentifier
          token: b
  tokens
    /// [a.b].
''');
  }

  test_commentReference_simpleIdentifier() {
    final parseResult = parseStringWithErrors(r'''
/// [a].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a]');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: a
  tokens
    /// [a].
''');
  }

  test_commentReference_this() {
    final parseResult = parseStringWithErrors(r'''
/// [this].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('this');
    // TODO(srawlins): I think there is an intention to parse this as a comment
    // reference.
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// [this].
''');
  }

  test_fencedCodeBlock_blockComment() {
    final parseResult = parseStringWithErrors(r'''
/**
 * One.
 * ```
 * a[i] = b[i];
 * ```
 * Two.
 * ```dart
 * code;
 * ```
 * Three.
 */
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /**
 * One.
 * ```
 * a[i] = b[i];
 * ```
 * Two.
 * ```dart
 * code;
 * ```
 * Three.
 */
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 15
          length: 3
        MdCodeBlockLine
          offset: 22
          length: 12
        MdCodeBlockLine
          offset: 38
          length: 3
    MdCodeBlock
      infoString: dart
      lines
        MdCodeBlockLine
          offset: 53
          length: 7
        MdCodeBlockLine
          offset: 64
          length: 5
        MdCodeBlockLine
          offset: 73
          length: 3
''');
  }

  test_fencedCodeBlock_empty() {
    final parseResult = parseStringWithErrors(r'''
/// ```
/// ```
/// Text.
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('Text.');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// ```
    /// ```
    /// Text.
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 3
          length: 4
        MdCodeBlockLine
          offset: 11
          length: 4
''');
  }

  test_fencedCodeBlock_leadingSpaces() {
    final parseResult = parseStringWithErrors(r'''
///   ```
///   a[i] = b[i];
///   ```
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    assertParsedNodeText(node, r'''
Comment
  tokens
    ///   ```
    ///   a[i] = b[i];
    ///   ```
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 3
          length: 6
        MdCodeBlockLine
          offset: 13
          length: 15
        MdCodeBlockLine
          offset: 32
          length: 6
''');
  }

  test_fencedCodeBlock_moreThanThreeBackticks() {
    final parseResult = parseStringWithErrors(r'''
/// ````dart
/// A code block can contain multiple backticks, as long as it is fewer than
/// the amount in the opening:
/// ```
/// `````
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('A code');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// ````dart
    /// A code block can contain multiple backticks, as long as it is fewer than
    /// the amount in the opening:
    /// ```
    /// `````
  codeBlocks
    MdCodeBlock
      infoString: dart
      lines
        MdCodeBlockLine
          offset: 3
          length: 9
        MdCodeBlockLine
          offset: 16
          length: 73
        MdCodeBlockLine
          offset: 93
          length: 27
        MdCodeBlockLine
          offset: 124
          length: 4
        MdCodeBlockLine
          offset: 132
          length: 6
''');
  }

  test_fencedCodeBlock_noLeadingSpaces() {
    final parseResult = parseStringWithErrors(r'''
///```
///a[i] = b[i];
///```
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    assertParsedNodeText(node, r'''
Comment
  tokens
    ///```
    ///a[i] = b[i];
    ///```
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 3
          length: 3
        MdCodeBlockLine
          offset: 10
          length: 12
        MdCodeBlockLine
          offset: 26
          length: 3
''');
  }

  test_fencedCodeBlock_nonDocCommentLines() {
    final parseResult = parseStringWithErrors(r'''
/// One.
/// ```
// This is not part of the doc comment.
/// a[i] = b[i];

/// ```
/// Two.
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// One.
    /// ```
    /// a[i] = b[i];
    /// ```
    /// Two.
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 12
          length: 4
        MdCodeBlockLine
          offset: 60
          length: 13
        MdCodeBlockLine
          offset: 78
          length: 4
''');
  }

  test_fencedCodeBlock_nonTerminating() {
    final parseResult = parseStringWithErrors(r'''
/// One.
/// ```
/// a[i] = b[i];
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// One.
    /// ```
    /// a[i] = b[i];
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 12
          length: 4
        MdCodeBlockLine
          offset: 20
          length: 13
''');
  }

  test_fencedCodeBlock_nonZeroOffset() {
    final parseResult = parseStringWithErrors(r'''
int x = 0;

/// One.
/// ```
/// a[i] = b[i];
/// ```
/// Two.
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// One.
    /// ```
    /// a[i] = b[i];
    /// ```
    /// Two.
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 24
          length: 4
        MdCodeBlockLine
          offset: 32
          length: 13
        MdCodeBlockLine
          offset: 49
          length: 4
''');
  }

  test_fencedCodeBlock_precededByText() {
    final parseResult = parseStringWithErrors(r'''
/// One. ```
/// Two.
/// ```
/// Three.
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('Two.');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// One. ```
    /// Two.
    /// ```
    /// Three.
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 25
          length: 4
        MdCodeBlockLine
          offset: 33
          length: 7
''');
  }

  test_fencedCodeBlocks() {
    final parseResult = parseStringWithErrors(r'''
/// One.
/// ```
/// a[i] = b[i];
/// ```
/// Two.
/// ```dart
/// code;
/// ```
/// Three.
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// One.
    /// ```
    /// a[i] = b[i];
    /// ```
    /// Two.
    /// ```dart
    /// code;
    /// ```
    /// Three.
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 12
          length: 4
        MdCodeBlockLine
          offset: 20
          length: 13
        MdCodeBlockLine
          offset: 37
          length: 4
    MdCodeBlock
      infoString: dart
      lines
        MdCodeBlockLine
          offset: 54
          length: 8
        MdCodeBlockLine
          offset: 66
          length: 6
        MdCodeBlockLine
          offset: 76
          length: 4
''');
  }

  test_indentedCodeBlock_afterBlankLine() {
    final parseResult = parseStringWithErrors(r'''
/// Text.
///
///    a[i] = b[i];
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('Text');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// Text.
    ///
    ///    a[i] = b[i];
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 17
          length: 16
''');
  }

  test_indentedCodeBlock_afterTextLine_notCodeBlock() {
    final parseResult = parseStringWithErrors(r'''
/// Text.
///    a[i] = b[i];
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('Text');
    // TODO(srawlins): Parse an indented code block into its own node.
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: i
    CommentReference
      expression: SimpleIdentifier
        token: i
  tokens
    /// Text.
    ///    a[i] = b[i];
''');
  }

  test_indentedCodeBlock_firstLine() {
    final parseResult = parseStringWithErrors(r'''
///    a[i] = b[i];
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    // TODO(srawlins): Parse an indented code block into its own node.
    assertParsedNodeText(node, r'''
Comment
  tokens
    ///    a[i] = b[i];
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 3
          length: 16
''');
  }

  test_indentedCodeBlock_firstLine_blockComment() {
    final parseResult = parseStringWithErrors(r'''
/**
 *
 *     a[i] = b[i];
 * [c].
 */
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('a[i]');
    // TODO(srawlins): Parse an indented code block into its own node.
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: c
  tokens
    /**
 *
 *     a[i] = b[i];
 * [c].
 */
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 10
          length: 16
''');
  }

  test_indentedCodeBlock_withFencedCodeBlock() {
    final parseResult = parseStringWithErrors(r'''
/// Text.
///     ```
///     a[i] = b[i];
///     ```
///     More text.
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('Text');
    assertParsedNodeText(node, r'''
Comment
  tokens
    /// Text.
    ///     ```
    ///     a[i] = b[i];
    ///     ```
    ///     More text.
  codeBlocks
    MdCodeBlock
      infoString: <empty>
      lines
        MdCodeBlockLine
          offset: 13
          length: 8
        MdCodeBlockLine
          offset: 25
          length: 17
        MdCodeBlockLine
          offset: 46
          length: 8
''');
  }

  test_inlineLink() {
    final parseResult = parseStringWithErrors(r'''
/// [a](http://www.google.com) [b].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a]');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /// [a](http://www.google.com) [b].
''');
  }

  test_linkReference() {
    final parseResult = parseStringWithErrors(r'''
/// [a]: http://www.google.com Google [b]
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a]');
    // TODO(srawlins): Ideally this should not parse `[b]` as a comment
    // reference.
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /// [a]: http://www.google.com Google [b]
''');
  }

  test_onlyWhitespace() {
    final parseResult = parseStringWithErrors('''
///${"  "}
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('  ');
    assertParsedNodeText(node, '''
Comment
  tokens
    ///${"  "}
''');
  }

  test_referenceLink() {
    final parseResult = parseStringWithErrors(r'''
/// [a link][c] [b].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /// [a link][c] [b].
''');
  }

  test_referenceLink_multiline() {
    final parseResult = parseStringWithErrors(r'''
/// [a link split across multiple
/// lines][c] [b].
class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.comment('[a');
    assertParsedNodeText(node, r'''
Comment
  references
    CommentReference
      expression: SimpleIdentifier
        token: a
    CommentReference
      expression: SimpleIdentifier
        token: b
  tokens
    /// [a link split across multiple
    /// lines][c] [b].
''');
  }
}
