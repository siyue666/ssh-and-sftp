import 'package:flutter/material.dart';
import 'package:xterm/core.dart';

import '../model/ssh/virtual_key.dart';

var virtualKeys = [
  VirtualKey('Esc', key: TerminalKey.escape),
  VirtualKey('Alt', key: TerminalKey.alt, toggleable: true),
  VirtualKey('Home', key: TerminalKey.home),
  VirtualKey('Up', key: TerminalKey.arrowUp, icon: Icons.arrow_upward),
  VirtualKey('End', key: TerminalKey.end),
  // VirtualKey(
  //   'Del',
  //   key: TerminalKey.delete,
  // ),
  VirtualKey('Paste', func: VirtualKeyFunc.paste, icon: Icons.paste),
  VirtualKey('Tab', key: TerminalKey.tab),
  VirtualKey('Ctrl', key: TerminalKey.control, toggleable: true),
  VirtualKey('Left', key: TerminalKey.arrowLeft, icon: Icons.arrow_back),
  VirtualKey('Down', key: TerminalKey.arrowDown, icon: Icons.arrow_downward),
  VirtualKey('Right', key: TerminalKey.arrowRight, icon: Icons.arrow_forward),
  VirtualKey(
    'IME',
    func: VirtualKeyFunc.toggleIME,
    icon: Icons.keyboard_hide,
  ),
];