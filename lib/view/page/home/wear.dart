import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolbox/core/extension/context/locale.dart';
import 'package:toolbox/data/model/server/server.dart';
import 'package:toolbox/data/provider/server.dart';
import 'package:toolbox/data/res/build_data.dart';
import 'package:toolbox/data/res/provider.dart';
import 'package:toolbox/data/res/store.dart';
import 'package:toolbox/data/res/url.dart';

final class WearHome extends StatefulWidget {
  const WearHome({super.key});

  @override
  State<WearHome> createState() => _WearHomeState();
}

final class _WearHomeState extends State<WearHome> with AfterLayoutMixin {
  late final _pageCtrl =
      PageController(initialPage: Pros.server.servers.isNotEmpty ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Consumer<ServerProvider>(builder: (_, pro, __) {
      if (pro.servers.isEmpty) {
        return const Center(child: Text('No server'));
      }
      return PageView.builder(
        controller: _pageCtrl,
        itemCount: pro.servers.length + 1,
        itemBuilder: (_, index) {
          if (index == 0) return _buildInit();

          final id = pro.serverOrder[index];
          final server = Pros.server.pick(id: id);
          if (server == null) return UIs.placeholder;
          return _buildEachSever(server);
        },
      );
    });
  }

  Widget _buildInit() {
    return Center(
      child: Column(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          UIs.height7,
          Text(l10n.restore)
        ],
      ),
    );
  }

  Widget _buildEachSever(Server srv) {
    final mem = () {
      final total = srv.status.mem.total;
      final used = srv.status.mem.total - srv.status.mem.avail;
      return '${used.bytes2Str} / ${total.bytes2Str}';
    }();
    final disk = () {
      final total = srv.status.diskUsage?.size.kb2Str;
      final used = srv.status.diskUsage?.used.kb2Str;
      return '$used / $total';
    }();
    final net = '↓ ${srv.status.netSpeed.cachedRealVals.speedIn}'
        '↑ ${srv.status.netSpeed.cachedRealVals.speedOut}';
    return Padding(
      padding: const EdgeInsets.all(7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(srv.spi.name, style: UIs.text15Bold),
          UIs.height7,
          KvRow(k: 'CPU', v: '${srv.status.cpu.usedPercent()}%'),
          KvRow(k: 'Mem', v: mem),
          KvRow(k: 'Disk', v: disk),
          KvRow(k: 'Net', v: net)
        ],
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    if (Stores.setting.autoCheckAppUpdate.fetch()) {
      AppUpdateIface.doUpdate(
        build: BuildData.build,
        url: '${Urls.cdnBase}/update.json',
        context: context,
      );
    }
    await Pros.server.load();
    await Pros.server.refresh();
  }
}