import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/miru_storage.dart';

class DownloadUtils {
  static List<DownloadTask> tasks = [];
  static int maxTasks = 3;
  static void addTask(DownloadTask task) {
    tasks.add(task);
    if (tasks.length < maxTasks) {
      task.downloadContent();
    }
  }

  static void removeTask(DownloadTask task) {
    tasks.remove(task);
    if (tasks.length < maxTasks) {
      tasks[0].downloadContent();
    }
  }

  static Future<void> ensureInitialized() async {
    final value = MiruStorage.getSettingSync(SettingKey.maxConnection, String);
    maxTasks = int.parse(value);
  }
}

abstract class DownloadTask {
  void downloadContent();
}

class VideoDownlodTasks extends DownloadTask {
  VideoDownlodTasks(this.watchType, this.videoUrl, this.packageName);
  final String videoUrl;
  final String packageName;
  final ExtensionWatchBangumiType watchType;
  @override
  void downloadContent() {
    // handling hls content

    if (watchType.name == 'hls') {
      return;
    }

    // handling torrent and mp4 content

    return;
  }
}
