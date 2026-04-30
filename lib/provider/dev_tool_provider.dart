import 'dart:async';
import 'package:miru_alpha/miru_core/event_service.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dev_tool_provider.g.dart';

class DevToolState {
  final List<proto.DevLogEvent> logs;
  final List<proto.DevNetworkEvent> requests;
  final bool show;
  final String? filterPackage;

  DevToolState({
    this.logs = const [],
    this.requests = const [],
    this.show = false,
    this.filterPackage,
  });

  DevToolState copyWith({
    List<proto.DevLogEvent>? logs,
    List<proto.DevNetworkEvent>? requests,
    bool? show,
    String? filterPackage,
  }) {
    return DevToolState(
      logs: logs ?? this.logs,
      requests: requests ?? this.requests,
      show: show ?? this.show,
      filterPackage: filterPackage ?? this.filterPackage,
    );
  }

  List<String> get availablePackages {
    final pkgs = <String>{};
    for (var l in logs) {
      pkgs.add(l.package);
    }
    for (var r in requests) {
      pkgs.add(r.package);
    }
    return pkgs.toList()..sort();
  }
}

@Riverpod(keepAlive: true)
class DevTool extends _$DevTool {
  StreamSubscription? _logSub;
  StreamSubscription? _netSub;

  @override
  DevToolState build() {
    _logSub = miruEventService.devLogStream.listen((event) {
      state = state.copyWith(logs: [event, ...state.logs]);
    });
    _netSub = miruEventService.devNetworkStream.listen((event) {
      state = state.copyWith(requests: [event, ...state.requests]);
    });

    ref.onDispose(() {
      _logSub?.cancel();
      _netSub?.cancel();
    });

    return DevToolState();
  }

  void toggle() {
    state = state.copyWith(show: !state.show);
  }

  void setShow(bool show) {
    state = state.copyWith(show: show);
  }

  void setFilterPackage(String? pkg) {
    state = state.copyWith(filterPackage: pkg);
  }

  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  void clearRequests() {
    state = state.copyWith(requests: []);
  }
}
