import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:toolbox/core/extension/context/dialog.dart';
import 'package:toolbox/core/extension/order.dart';
import 'package:toolbox/data/res/provider.dart';
import 'package:toolbox/data/res/store.dart';

import '../../../core/utils/misc.dart';
import '../../../data/model/server/server.dart';
import '../../../data/model/server/snippet.dart';
import '../../../data/res/ui.dart';
import '../../widget/tag.dart';
import '/core/route.dart';
import '/data/provider/snippet.dart';
import '/view/widget/round_rect_card.dart';

class SnippetListPage extends StatefulWidget {
  const SnippetListPage({Key? key}) : super(key: key);

  @override
  _SnippetListPageState createState() => _SnippetListPageState();
}

class _SnippetListPageState extends State<SnippetListPage> {
  late S _s;
  late MediaQueryData _media;

  String? _tag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _s = S.of(context)!;
    _media = MediaQuery.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'snippet',
        child: const Icon(Icons.add),
        onPressed: () => AppRoute.snippetEdit().go(context),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<SnippetProvider>(
      builder: (_, provider, __) {
        if (provider.snippets.isEmpty) {
          return Center(
            child: Text(_s.noSavedSnippet),
          );
        }

        final filtered = provider.snippets
            .where((e) => _tag == null || (e.tags?.contains(_tag) ?? false))
            .toList();

        return ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          itemCount: filtered.length,
          onReorder: (oldIdx, newIdx) => setState(() {
            provider.snippets.moveByItem(
              filtered,
              oldIdx,
              newIdx,
              onMove: (p0) {
                Stores.setting.snippetOrder.put(p0.map((e) => e.name).toList());
              },
            );
          }),
          header: TagSwitcher(
            tags: provider.tags,
            onTagChanged: (tag) => setState(() => _tag = tag),
            initTag: _tag,
            all: _s.all,
            width: _media.size.width,
          ),
          footer: UIs.height77,
          buildDefaultDragHandles: false,
          itemBuilder: (context, idx) {
            final snippet = filtered.elementAt(idx);
            return ReorderableDelayedDragStartListener(
              key: ValueKey(snippet.name),
              index: idx,
              child: _buildSnippetItem(snippet),
            );
          },
        );
      },
    );
  }

  Widget _buildSnippetItem(Snippet snippet) {
    return RoundRectCard(
      ListTile(
        contentPadding: const EdgeInsets.only(left: 23, right: 17),
        title: Text(
          snippet.name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          snippet.note ?? snippet.script,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          style: UIs.textGrey,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () =>
                  AppRoute.snippetEdit(snippet: snippet).go(context),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => _runSnippet(snippet),
              icon: const Icon(Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runSnippet(Snippet snippet) async {
    final servers = await showDialog<List<Server>>(
      context: context,
      builder: (_) => TagPicker<Server>(
        items: Providers.server.servers.values.toList(),
        tags: Providers.server.tags.toSet(),
      ),
    );
    if (servers == null) {
      return;
    }
    final ids = servers.map((e) => e.spi.id).toList();
    final results = await Providers.server.runSnippetsMulti(ids, [snippet]);
    if (results.isNotEmpty) {
      // SERVER_NAME: RESULT
      final result = Map.fromIterables(
        ids,
        results,
      ).entries.map((e) => '${e.key}:\n${e.value}').join('\n');
      context.showRoundDialog(
        title: Text(_s.result),
        child: Text(result),
        actions: [
          TextButton(
            onPressed: () => copy2Clipboard(result),
            child: Text(_s.copy),
          )
        ],
      );
    }
  }
}
