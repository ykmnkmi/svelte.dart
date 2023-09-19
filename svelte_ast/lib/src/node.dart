import 'package:svelte_ast/src/ast.dart';

String nodeToString(Node node) {
  return switch (node) {
    IfBlock() => '{#if} block',
    ThenBlock() => '{:then} block',
    ElseBlock() => '{:else} block',
    PendingBlock _ || AwaitBlock _ => '{#await} block',
    CatchBlock() => '{:catch} block',
    EachBlock() => '{#each} block',
    RawMustacheTag() => '{@html} block',
    DebugTag() => '{@debug} block',
    ConstTag() => '{@const} tag',
    Tag() => '<${node.name}> tag',
    _ => throw UnimplementedError(),
  };
}
