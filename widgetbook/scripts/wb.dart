#!/usr/bin/env dart

// Agent-facing helper for the miru Widgetbook.
//
// Wraps the three things an agent needs to inspect a story without ever
// tapping the widgetbook sidebar by hand:
//
//   dart run scripts/wb.dart list                  # every story path
//   dart run scripts/wb.dart select <path>         # navigate to a story
//   dart run scripts/wb.dart tree                  # render + widget tree
//   dart run scripts/wb.dart screenshot [out.png]  # capture the story
//
// `list` and `select` talk to the widgetbook through two files the
// StorySwitcher (lib/story_switcher.dart) keeps fresh:
//   /tmp/miru_wb_tree.json  — all leaf story paths (list)
//   /tmp/miru_wb_story      — the path to navigate to (select)
//
// `tree` and `screenshot` shell out to the marionette CLI bound to the
// widgetbook instance (`marionette -i miru-widgetbook ...`).
//
// Run from the widgetbook/ directory: `cd widgetbook && dart run scripts/wb.dart list`

import 'dart:convert';
import 'dart:io';

const _instance = 'miru-widgetbook';
const _storyFile = '/tmp/miru_wb_story';
const _treeFile = '/tmp/miru_wb_tree.json';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    _usage();
    exit(64);
  }
  switch (args.first) {
    case 'list':
      await _list();
    case 'select':
      await _select(args);
    case 'tree':
      await _tree();
    case 'screenshot':
      await _screenshot(args);
    case 'help':
    case '--help':
    case '-h':
      _usage();
    default:
      stderr.writeln('unknown command: ${args.first}');
      _usage();
      exit(64);
  }
}

Future<void> _list() async {
  final file = File(_treeFile);
  if (!file.existsSync()) {
    stderr.writeln(
      'no tree file at $_treeFile — is the widgetbook running '
      '(marionette -i $_instance doctor)?',
    );
    exit(1);
  }
  final raw = file.readAsStringSync();
  final paths = (jsonDecode('[$raw]') as List).cast<String>();
  stdout.writeln('${paths.length} stories:');
  for (final p in paths) {
    stdout.writeln('  $p');
  }
}

Future<void> _select(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('usage: wb.dart select <story-path>');
    exit(64);
  }
  final path = args.sublist(1).join(' ');
  await File(_storyFile).writeAsString('$path\n');
  // Give the switcher's 300ms poll a moment, then confirm.
  await Future<void>.delayed(const Duration(milliseconds: 700));
  stdout.writeln('selected: $path');
}

Future<void> _tree() async {
  final result = await Process.run('marionette', [
    '-i',
    _instance,
    'get-interactive-elements',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  stdout.writeln(result.stdout);
}

Future<void> _screenshot(List<String> args) async {
  final out = args.length > 1 ? args[1] : '/tmp/wb_shot.png';
  final result = await Process.run('marionette', [
    '-i',
    _instance,
    'take-screenshots',
    '-o',
    out,
  ]);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  stdout.writeln(result.stdout);
}

void _usage() {
  stdout.writeln('''
miru Widgetbook helper (agent-facing)

  dart run scripts/wb.dart list                  list every story path
  dart run scripts/wb.dart select <path>         navigate to a story
  dart run scripts/wb.dart tree                  dump render/widget tree
  dart run scripts/wb.dart screenshot [out.png]  capture the story

Requires the widgetbook running and registered with marionette as
"$_instance" (marionette -i $_instance doctor).
''');
}
