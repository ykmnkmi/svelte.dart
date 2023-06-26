import 'package:svelte_ast/src/ast.dart';

String nodeToString(Node node) {
  return switch (node) {
    IfBlock _ => '{#if} block',
    // ThenBlock _ => => '{:then} block',
    ElseBlock _ => '{:else} block',
    // PendingBlock _ || AwaitBlock _=> '{#await} block',
    // case 'CatchBlock': return '{:catch} block';
    EachBlock _ => '{#each} block',
    RawMustacheTag _ => '{@html} block',
    DebugTag _ => '{@debug} block',
    ConstTag _ => '{@const} tag',
    // case 'Element':
    // case 'InlineComponent':
    // case 'Slot':
    // case 'Title':
    // 	return `<${node.name}> tag`;
    _ => node.runtimeType.toString(),
  };
}
