import 'package:flutter/material.dart';
import 'package:toolbox/core/extension/context/common.dart';
import 'package:toolbox/core/extension/context/dialog.dart';
import 'package:toolbox/data/res/ui.dart';
import 'package:toolbox/view/widget/input_field.dart';
import 'package:toolbox/view/widget/round_rect_card.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import '../../data/model/app/tag_pickable.dart';
import '../../data/res/color.dart';

const _kTagBtnHeight = 31.0;

class TagBtn extends StatelessWidget {
  final String content;
  final void Function() onTap;
  final bool isEnable;

  const TagBtn({
    super.key,
    required this.onTap,
    required this.isEnable,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return _wrap(
      Text(
        content,
        textAlign: TextAlign.center,
        textScaleFactor: 1.0,
        style: isEnable ? UIs.textSize13 : UIs.textSize13Grey,
      ),
      onTap: onTap,
    );
  }
}

class TagEditor extends StatefulWidget {
  final List<String> tags;
  final S s;
  final void Function(List<String>)? onChanged;
  final void Function(String old, String new_)? onRenameTag;
  final List<String> allTags;

  const TagEditor({
    super.key,
    required this.tags,
    required this.s,
    this.onChanged,
    this.onRenameTag,
    this.allTags = const <String>[],
  });

  @override
  State<StatefulWidget> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  @override
  Widget build(BuildContext context) {
    return RoundRectCard(ListTile(
      leading: const Icon(Icons.tag),
      title: _buildTags(widget.tags),
      trailing: InkWell(
        child: const Icon(Icons.add),
        onTap: () {
          _showAddTagDialog();
        },
      ),
    ));
  }

  Widget _buildTags(List<String> tags) {
    final suggestions = widget.allTags.where((e) => !tags.contains(e)).toList();
    final suggestionLen = suggestions.length;

    /// Add vertical divider if suggestions.length > 0
    final counts = tags.length + suggestionLen + (suggestionLen == 0 ? 0 : 1);
    if (counts == 0) return Text(widget.s.tag);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _kTagBtnHeight),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index < tags.length) {
            return _buildTagItem(tags[index]);
          } else if (index > tags.length) {
            return _buildTagItem(
              suggestions[index - tags.length - 1],
              isAdd: true,
            );
          }
          return const VerticalDivider();
        },
        itemCount: counts,
      ),
    );
  }

  Widget _buildTagItem(String tag, {bool isAdd = false}) {
    return _wrap(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '#$tag',
            textAlign: TextAlign.center,
            style: isAdd ? UIs.textSize13Grey : UIs.textSize13,
            textScaleFactor: 1.0,
          ),
          const SizedBox(width: 4.0),
          Icon(
            isAdd ? Icons.add_circle : Icons.cancel,
            size: 13.7,
          ),
        ],
      ),
      onTap: () {
        if (isAdd) {
          widget.tags.add(tag);
        } else {
          widget.tags.remove(tag);
        }
        widget.onChanged?.call(widget.tags);
        setState(() {});
      },
      onLongPress: () => _showRenameDialog(tag),
    );
  }

  void _showAddTagDialog() {
    final textEditingController = TextEditingController();
    context.showRoundDialog(
      title: Text(widget.s.add),
      child: Input(
        autoFocus: true,
        icon: Icons.tag,
        controller: textEditingController,
        hint: widget.s.tag,
      ),
      actions: [
        TextButton(
          onPressed: () {
            final tag = textEditingController.text;
            widget.tags.add(tag.trim());
            widget.onChanged?.call(widget.tags);
            context.pop();
          },
          child: Text(widget.s.add),
        ),
      ],
    );
  }

  void _showRenameDialog(String tag) {
    final textEditingController = TextEditingController(text: tag);
    context.showRoundDialog(
      title: Text(widget.s.rename),
      child: Input(
        autoFocus: true,
        icon: Icons.abc,
        controller: textEditingController,
        hint: widget.s.tag,
      ),
      actions: [
        TextButton(
          onPressed: () {
            final newTag = textEditingController.text.trim();
            if (newTag.isEmpty) return;
            widget.onRenameTag?.call(tag, newTag);
            context.pop();
            setState(() {});
          },
          child: Text(widget.s.rename),
        ),
      ],
    );
  }
}

class TagPicker<T extends TagPickable> extends StatefulWidget {
  final List<T> items;
  final Set<String> tags;

  const TagPicker({
    Key? key,
    required this.items,
    required this.tags,
  }) : super(key: key);

  @override
  _TagPickerState<T> createState() => _TagPickerState<T>();
}

class _TagPickerState<T extends TagPickable> extends State<TagPicker<T>> {
  late S _s;
  late MediaQueryData _media;
  final List<T> _selected = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _s = S.of(context)!;
    _media = MediaQuery.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.tags.isNotEmpty) {
      children.add(Text(_s.tag));
      children.add(UIs.height13);
      children.add(SizedBox(
        height: _kTagBtnHeight,
        width: _media.size.width * 0.7,
        child: _buildTags(),
      ));
    }
    if (widget.items.isNotEmpty) {
      children.add(Text(_s.all));
      children.add(UIs.height13);
      children.add(SizedBox(
        height: _kTagBtnHeight,
        width: _media.size.width * 0.7,
        child: _buildItems(),
      ));
    }
    final child = widget.tags.isEmpty && widget.items.isEmpty
        ? Text(_s.noOptions)
        : Column(mainAxisSize: MainAxisSize.min, children: children);
    return AlertDialog(
      title: Text(_s.choose),
      content: child,
      actions: [
        TextButton(
          onPressed: () => context.pop(_selected),
          child: Text(_s.ok),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.tags.length,
      itemBuilder: (_, idx) {
        final item = widget.tags.elementAt(idx);
        final isEnable =
            widget.items.where((ele) => ele.containsTag(item)).every(
                  (ele) => _selected.contains(ele),
                );
        return TagBtn(
          isEnable: isEnable,
          onTap: () {
            if (isEnable) {
              _selected.removeWhere(
                (ele) => ele.containsTag(item),
              );
            } else {
              _selected.addAll(widget.items.where(
                (ele) => ele.containsTag(item),
              ));
            }
            setState(() {});
          },
          content: item,
        );
      },
    );
  }

  Widget _buildItems() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final e = widget.items[index];
        return TagBtn(
          isEnable: _selected.contains(e),
          onTap: () {
            if (_selected.contains(e)) {
              _selected.remove(e);
            } else {
              _selected.add(e);
            }
            setState(() {});
          },
          content: e.tagName,
        );
      },
    );
  }
}

class TagSwitcher extends StatelessWidget {
  final List<String> tags;
  final double width;
  final void Function(String?) onTagChanged;
  final String? initTag;
  final String all;

  const TagSwitcher({
    Key? key,
    required this.tags,
    required this.width,
    required this.onTagChanged,
    required this.all,
    this.initTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return UIs.placeholder;
    final items = <String?>[null, ...tags];
    return Container(
      height: _kTagBtnHeight,
      width: width,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          return TagBtn(
            content: item == null ? all : '#$item',
            isEnable: initTag == item,
            onTap: () => onTagChanged(item),
          );
        },
        itemCount: items.length,
      ),
    );
  }
}

Widget _wrap(
  Widget child, {
  void Function()? onTap,
  void Function()? onLongPress,
}) {
  return Padding(
    padding: const EdgeInsets.all(3),
    child: ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: Material(
        color: primaryColor.withAlpha(20),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            /// Hard coded padding
            /// For centering the text
            padding: const EdgeInsets.fromLTRB(11.7, 2.7, 11.7, 0),
            child: child,
          ),
        ),
      ),
    ),
  );
}
