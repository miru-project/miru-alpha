import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/download/ffmpeg_util.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:moon_design/moon_design.dart';
import 'package:encrypt/encrypt.dart' as enc;

extension FormatToString on Format {
  String showString() {
    final bitrateInfo =
        bitrate != null ? "${bitrate! ~/ 1000} kbps" : "unknown bitrate";
    final resolutionInfo =
        width != null && height != null
            ? "$width x $height"
            : "unknown resolution";

    return '$containerMimeType, $codecs, $bitrateInfo, $resolutionInfo';
  }
}

class DownloadUtils {
  static List<DownloadTask> tasks = [];
  static List<String> runningTaskIds = [];
  static int maxTasks = 3;
  static late ReceivePort receivePort;
  static final Dio dio = Dio();
  static final contextMap = <String, BuildContext>{};
  // Add a new task to the queue
  static void addTask(DownloadTask task, BuildContext context) {
    tasks.add(task);
    contextMap[task.id] = context;
    _processQueue();
  }

  // Remove a task and process the queue
  static void removeTask(DownloadTask task) {
    tasks.remove(task);
    contextMap.remove(task.id);
    runningTaskIds.remove(task.id);
    _processQueue();
  }

  // Process the queue, starting tasks until we reach maxTasks
  static void _processQueue() {
    // Filter for pending tasks (not yet running)
    final pendingTasks =
        tasks.where((task) => !runningTaskIds.contains(task.id)).toList();

    // Start tasks until we reach maxTasks running
    while (runningTaskIds.length < maxTasks && pendingTasks.isNotEmpty) {
      final task = pendingTasks.removeAt(0);
      _startTask(task);
    }
  }

  // Start a specific task
  static void _startTask(DownloadTask task) async {
    runningTaskIds.add(task.id);

    // For HLS tasks, perform manifest download on main isolate first
    if (task is VideoDownlodTasks && task.watchType.name == 'hls') {
      await task.prepareManifestsBeforeIsolate();
    }

    Isolate.spawn(task.downloadContent, receivePort.sendPort)
        .then((isolate) {
          // Store the isolate reference so we can kill it if needed
          // task.setIsolate(isolate);
        })
        .catchError((e) {
          debugPrint('Failed to start task ${task.id}: $e');
          runningTaskIds.remove(task.id);
          _processQueue(); // Try other tasks
        });
  }

  // Initialize the download system
  static Future<void> ensureInitialized() async {
    final value = MiruStorage.getSettingSync(SettingKey.maxConnection, String);
    maxTasks = int.parse(value);
    receivePort = ReceivePort();

    // Listen to isolate messages
    receivePort.listen((msg) {
      if (msg is IsolateMessage) {
        final taskId = msg.taskId;

        // Log all messages for debugging
        debugPrint(
          'Task $taskId: ${msg.status} (${msg.progress}%) - ${msg.message ?? ""}',
        );

        // Handle task completion
        if (msg.status == DownloadStatus.complete ||
            msg.status == DownloadStatus.error) {
          // Find the completed task by ID
          final taskIndex = tasks.indexWhere((task) => task.id == taskId);
          if (taskIndex >= 0) {
            final completedTask = tasks[taskIndex];
            removeTask(completedTask);
          }
        }
      } else {
        debugPrint('Received unknown message format: $msg');
      }
    });
  }

  static String filter(String path) {
    return path.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '').trim();
  }

  static String _getBaseUrl(String url) {
    // Find the last slash that's part of the path (not query params)
    int queryStart = url.indexOf('?');
    String pathUrl = queryStart >= 0 ? url.substring(0, queryStart) : url;

    // Get the directory part by removing everything after the last slash
    int lastSlash = pathUrl.lastIndexOf('/');
    if (lastSlash >= 0) {
      return pathUrl.substring(0, lastSlash + 1); // Include the slash
    }

    // If no slash found, return the original URL
    return url;
  }

  static String _resolveUrl(String base, String relative) {
    // If base doesn't end with a slash, add one
    if (!base.endsWith('/')) {
      base = '$base/';
    }

    // Handle '..' in relative paths
    if (relative.startsWith('../')) {
      var newBase = base.substring(
        0,
        base.lastIndexOf('/', base.length - 2) + 1,
      );
      return _resolveUrl(newBase, relative.substring(3));
    }

    // Handle './' in relative paths
    if (relative.startsWith('./')) {
      return _resolveUrl(base, relative.substring(2));
    }

    // Remove any leading slash in relative path
    if (relative.startsWith('/')) {
      relative = relative.substring(1);
    }

    return '$base$relative';
  }

  // Used by fetching m3u8 file
  static Future<List<String>> readLinesAndFetch(Uri url) async {
    try {
      final response = await dio.getUri(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        final String content = response.data.toString();
        return content.split('\n');
      } else {
        throw Exception('Failed to load file: HTTP ${response.statusCode}');
      }
    } catch (e) {
      logger.severe('Error reading lines with Dio: $e');
      rethrow;
    }
  }

  // Paser Master PlayList with variant selection
  static Future<HlsManifestResult?> prepareHlsManifests({
    required String videoUrl,
    required String downloadDir,
    required String taskId,
  }) async {
    try {
      Directory(downloadDir).createSync(recursive: true);
      final parser = HlsPlaylistParser.create();
      final masterPlaylistPath = "$downloadDir/master.m3u8";

      // Download the master m3u8 if it doesn't exist
      late final List<String> m3u8Lines;
      if (await File(masterPlaylistPath).exists()) {
        m3u8Lines = await File(masterPlaylistPath).readAsLines();
      } else {
        await dio.download(videoUrl, masterPlaylistPath);
        m3u8Lines = await File(masterPlaylistPath).readAsLines();
      }

      // Parse the master playlist
      final masterPlaylist = await parser.parse(Uri.parse(videoUrl), m3u8Lines);

      // If it's a master playlist, get the media playlist
      if (masterPlaylist is HlsMasterPlaylist) {
        if (masterPlaylist.variants.isEmpty) {
          throw Exception("Master playlist has no variants");
        }

        // final variant = masterPlaylist.variants.first;
        final chosenVarient = await showMoonDialog(
          contextMap[taskId]!,
          taskId,
          masterPlaylist,
        );
        final uri = chosenVarient?.url;
        if (uri == null) {
          throw Exception("No URL found in variant");
        }

        final mediaPlaylistPath = "$downloadDir/media.m3u8";

        // Download the media playlist
        if (!await File(mediaPlaylistPath).exists()) {
          final mediaM3u8Lines = await readLinesAndFetch(uri);
          await File(
            mediaPlaylistPath,
          ).writeAsString(mediaM3u8Lines.join('\n'));
        }

        // Parse the media playlist
        final mediaM3u8Lines = await File(mediaPlaylistPath).readAsLines();
        final parsedPlaylist = await parser.parse(uri, mediaM3u8Lines);

        if (parsedPlaylist is HlsMediaPlaylist) {
          return HlsManifestResult(
            mediaPlaylist: parsedPlaylist,
            masterPlaylistPath: masterPlaylistPath,
            mediaPlaylistPath: mediaPlaylistPath,
          );
        } else {
          // Not accepted : master -> master x N-> media
          throw Exception("Expected media playlist but got another master");
        }
      } else if (masterPlaylist is HlsMediaPlaylist) {
        // The "master" is actually a media playlist
        return HlsManifestResult(
          mediaPlaylist: masterPlaylist,
          masterPlaylistPath: masterPlaylistPath,
          mediaPlaylistPath: masterPlaylistPath,
        );
      }

      return null;
    } catch (e, stack) {
      logger.severe("Failed to prepare manifests: $e\n$stack");
      return null;
    }
  }

  static Future<Variant?> showMoonDialog(
    BuildContext context,
    String taskId,
    HlsMasterPlaylist masterPlaylist,
  ) async {
    Variant? chosenVarient;
    await showMoonModal(
      context: contextMap[taskId]!,
      builder:
          (context) => LayoutBuilder(
            builder:
                (context, constraints) => SizedBox(
                  width: 1000,
                  height: 500,
                  child: MoonModal(
                    decoration: BoxDecoration(
                      color: MoonColors.dark.goku,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color:
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.light
                                  ? MoonColors.light.goku.withValues(alpha: .2)
                                  : MoonColors.dark.goku.withValues(alpha: .2),
                        ),
                      ],
                    ),
                    child: Column(
                      children:
                          masterPlaylist.variants
                              .map(
                                (e) => MoonMenuItem(
                                  label: Text(e.url.path),
                                  content: Text(e.format.showString()),
                                  onTap: () {
                                    chosenVarient = e;
                                    Navigator.of(context).pop();
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
          ),
    );
    logger.info('Chosen variant: ${chosenVarient?.url.path}');
    return chosenVarient;
  }

  static Uint8List decryptSegment(
    Uint8List decryptKey,
    Uint8List cipher,
    Uint8List enciv,
  ) {
    // final keyFile = await File('/home/noonecare/Videos/mon.key').readAsBytes();
    final key = enc.Key(decryptKey);
    final iv = enc.IV(enciv);
    final encrypter = enc.Encrypter(
      enc.AES(key, mode: enc.AESMode.cbc, padding: null),
    );
    final encrypted = enc.Encrypted(cipher);

    final decrpted = Uint8List.fromList(
      encrypter.decryptBytes(encrypted, iv: iv),
    );
    return decrpted;
  }
}

// Add this class to store HLS manifest preparation results
class HlsManifestResult {
  final HlsMediaPlaylist mediaPlaylist;
  final String masterPlaylistPath;
  final String mediaPlaylistPath;

  HlsManifestResult({
    required this.mediaPlaylist,
    required this.masterPlaylistPath,
    required this.mediaPlaylistPath,
  });
}

abstract class DownloadTask {
  DownloadTask({Isolate? isolate, String? id}) : id = id ?? _generateUniqueId();

  final String id;
  // Isolate? isolate;

  // Generate a unique ID for the task
  static String _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Set isolate reference (used after spawn)
  // void setIsolate(Isolate isolate) {
  //   this.isolate = isolate;
  // }

  // Abstract method to be implemented by subclasses
  void downloadContent(SendPort sendPort);
}

class VideoDownlodTasks extends DownloadTask {
  VideoDownlodTasks({
    required this.watchType,
    required this.videoUrl,
    required this.packageName,
    required this.episodeName,
    required this.episodeGroupName,
    required this.videoName,
    // required this.context,
    super.id,
    // super.isolate,
  });

  final String videoUrl;
  final String packageName;
  final ExtensionWatchBangumiType watchType;
  final String episodeName;
  final String episodeGroupName;
  final String videoName;
  // final BuildContext context;
  final String _miruDownloadDir = MiruDirectory.getDownloadDirectory;
  final Dio dio = Dio();
  late String downloadDir;
  final List<String> _segmentPaths = [];
  // Store manifest data for passing to isolate
  String? masterPlaylistPath;
  String? mediaPlaylistPath;
  HlsMediaPlaylist? mediaPlaylist;
  bool manifestsPrepared = false;

  // Prepare and download HLS manifests before spawning isolate
  Future<void> prepareManifestsBeforeIsolate() async {
    if (watchType.name != 'hls' || manifestsPrepared) return;

    final fullName = "$videoName-$episodeGroupName-$episodeName-$packageName";
    downloadDir = ("$_miruDownloadDir/${DownloadUtils.filter(fullName)}");

    final result = await DownloadUtils.prepareHlsManifests(
      videoUrl: videoUrl,
      downloadDir: downloadDir,
      taskId: id,
    );

    if (result != null) {
      mediaPlaylist = result.mediaPlaylist;
      masterPlaylistPath = result.masterPlaylistPath;
      mediaPlaylistPath = result.mediaPlaylistPath;
      manifestsPrepared = true;
    }
  }

  @override
  void downloadContent(SendPort sendPort) async {
    try {
      final fullName = "$videoName-$episodeGroupName-$episodeName-$packageName";
      downloadDir = ("$_miruDownloadDir/${DownloadUtils.filter(fullName)}");
      Directory(downloadDir).createSync(recursive: true);

      if (watchType.name == 'hls') {
        FFMpegUtils.openlib();

        // Report start
        sendPort.send(
          IsolateMessage(0.0, DownloadStatus.downloading, taskId: id),
        );

        // If manifests were prepared in the main isolate
        if (manifestsPrepared && mediaPlaylist != null) {
          sendPort.send(
            IsolateMessage(
              10.0,
              DownloadStatus.downloading,
              message: "Starting segment downloads",
              taskId: id,
            ),
          );

          await downloadHlsSegments(mediaPlaylist!, sendPort);
          sendPort.send(
            IsolateMessage(100.0, DownloadStatus.complete, taskId: id),
          );
          return;
        }
        sendPort.send(IsolateMessage(100.0, DownloadStatus.error, taskId: id));
        throw Exception('failed to prepare manifest');
        // else {
        //   // Fall back to doing everything in the isolate if preparation failed
        //   late final List<String> m3u8Lines;
        //   final parser = HlsPlaylistParser.create();

        //   if (await File("$downloadDir/master.m3u8").exists()) {
        //     m3u8Lines = await File("$downloadDir/master.m3u8").readAsLines();
        //     sendPort.send(
        //       IsolateMessage(
        //         0.0,
        //         DownloadStatus.downloading,
        //         message: "Using cached m3u8",
        //         taskId: id,
        //       ),
        //     );
        //   } else {
        //     // Download m3u8
        //     sendPort.send(
        //       IsolateMessage(
        //         0.0,
        //         DownloadStatus.downloading,
        //         message: "Downloading m3u8",
        //         taskId: id,
        //       ),
        //     );
        //     await dio.download(videoUrl, "$downloadDir/master.m3u8");
        //     m3u8Lines = await File("$downloadDir/master.m3u8").readAsLines();
        //     sendPort.send(
        //       IsolateMessage(
        //         0.0,
        //         DownloadStatus.downloading,
        //         message: "m3u8 downloaded",
        //         taskId: id,
        //       ),
        //     );
        //   }

        //   final playlist = await parser.parse(Uri.parse(videoUrl), m3u8Lines);
        //   if (playlist is HlsMasterPlaylist) {
        //     await handleHlsMasterPlaylist(playlist, sendPort);
        //   } else if (playlist is HlsMediaPlaylist) {
        //     await downloadHlsSegments(playlist, sendPort);
        //   }
        // }

        // sendPort.send(
        //   IsolateMessage(100.0, DownloadStatus.complete, taskId: id),
        // );
        // return;
      } else if (watchType.name == 'mp4') {
        // Handle MP4 download
        await handleMp4Download(sendPort);
        return;
      } else {
        // Handle other formats
        sendPort.send(
          IsolateMessage(
            0.0,
            DownloadStatus.error,
            message: "Unsupported format: ${watchType.name}",
            taskId: id,
          ),
        );
        return;
      }
    } catch (e, stack) {
      logger.severe("Download error: $e\n$stack");
      sendPort.send(
        IsolateMessage(
          0.0,
          DownloadStatus.error,
          message: "Error: $e",
          taskId: id,
        ),
      );
    }
  }

  Future<void> handleMp4Download(SendPort sendPort) async {
    final outputPath = "$downloadDir/video.mp4";

    if (await File(outputPath).exists()) {
      sendPort.send(
        IsolateMessage(
          100.0,
          DownloadStatus.complete,
          message: "File already exists",
          taskId: id,
        ),
      );
      return;
    }

    try {
      sendPort.send(
        IsolateMessage(
          0.0,
          DownloadStatus.downloading,
          message: "Starting MP4 download",
          taskId: id,
        ),
      );

      await dio.download(
        videoUrl,
        outputPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total) * 100;
            sendPort.send(
              IsolateMessage(
                progress,
                DownloadStatus.downloading,
                message: "${progress.toStringAsFixed(1)}%",
                taskId: id,
              ),
            );
          }
        },
      );

      sendPort.send(
        IsolateMessage(
          100.0,
          DownloadStatus.complete,
          message: "MP4 download complete",
          taskId: id,
        ),
      );
    } catch (e) {
      sendPort.send(
        IsolateMessage(
          0.0,
          DownloadStatus.error,
          message: "MP4 download failed: $e",
          taskId: id,
        ),
      );
    }
  }

  Future<void> downloadHlsSegments(
    HlsMediaPlaylist playlist,
    SendPort sendPort,
  ) async {
    final segments = playlist.segments;
    final totalSegments = segments.length;
    final base = DownloadUtils._getBaseUrl(
      playlist.baseUri?.toString() ?? videoUrl,
    );

    sendPort.send(
      IsolateMessage(
        0.0,
        DownloadStatus.downloading,
        message: "Downloading $totalSegments segments",
        taskId: id,
      ),
    );
    // final List<String> downloadedKey = [];
    final Map<String, Uint8List> keyMap = {};

    // Segment loop which process Downloading, Decrypting and Saving

    for (var i = 0; i < totalSegments; i++) {
      final segment = segments[i];
      String? url = segment.url;
      if (url == null) {
        logger.severe('Segment URL is null');
        continue;
      }
      if (!url.startsWith('http')) {
        url = DownloadUtils._resolveUrl(base, url);
      }
      String? keyUri = segment.fullSegmentEncryptionKeyUri;

      final segmentPath = "$downloadDir/$i.ts";
      if (await File(segmentPath).exists()) {
        sendPort.send(
          IsolateMessage(
            ((i + 1) / totalSegments) * 100,
            DownloadStatus.downloading,
            message: "Using cached segment ${i + 1}/$totalSegments",
            taskId: id,
          ),
        );
        _segmentPaths.add(segmentPath);
        continue;
      }

      try {
        final response = await dio.download(url, segmentPath);

        if (response.statusCode != 200) {
          logger.severe('Error downloading segment: ${response.statusCode}');
          continue;
        }

        sendPort.send(
          IsolateMessage(
            ((i + 1) / totalSegments) * 100,
            DownloadStatus.downloading,
            message: "Downloaded segment ${i + 1}/$totalSegments",
            taskId: id,
          ),
        );
        if (keyUri != null) {
          // Only download and process key if not already done
          if (!keyMap.containsKey(keyUri)) {
            try {
              final keyUrl =
                  !keyUri.startsWith('http')
                      ? DownloadUtils._resolveUrl(base, keyUri)
                      : keyUri;

              // Get the key file name
              final keyFileName = keyUrl.split('/').last;
              final keyPath = "$downloadDir/$keyFileName";

              // Download key file
              logger.info('Downloading encryption key: $keyUrl');
              final keyResponse = await dio.get(
                keyUrl,
                options: Options(responseType: ResponseType.bytes),
              );

              if (keyResponse.statusCode == 200) {
                // Save key to file
                final keyBytes = keyResponse.data as Uint8List;
                await File(keyPath).writeAsBytes(keyBytes);

                // Store in map for future segments
                keyMap[keyUri] = keyBytes;
                // downloadedKey.add(keyUri);

                logger.info('Successfully downloaded key: $keyFileName');
              } else {
                logger.severe(
                  'Failed to download key: ${keyResponse.statusCode}',
                );
              }
            } catch (e) {
              logger.severe('Error downloading encryption key: $e');
            }
          }

          // Get key from map
          final key = keyMap[keyUri];
          if (key != null) {
            // Read downloaded segment
            final encryptedData = await File(segmentPath).readAsBytes();
            final Uint8List encIV = Uint8List(16);

            try {
              logger.info(
                'Decrypting segment $i with key length: ${key.length} bytes',
              );
              final decryptedData = DownloadUtils.decryptSegment(
                key,
                encryptedData,
                encIV,
              );

              // Save decrypted data back to the segment file
              await File(segmentPath).writeAsBytes(decryptedData);
              logger.info('Successfully decrypted segment $i');
            } catch (e) {
              logger.severe('Failed to decrypt segment $i: $e');
            }
          }
        }
        _segmentPaths.add(segmentPath);
      } catch (e) {
        logger.severe('Failed to download segment $i: $e');
        // Continue with next segment
      }
    }

    sendPort.send(
      IsolateMessage(
        100.0,
        DownloadStatus.converting,
        message: "Converting to MP4",
        taskId: id,
      ),
    );

    convertToMp4(totalSegments, downloadDir);
  }

  void convertToMp4(int slices, String containFolder) async {
    final input = List.generate(slices, (index) => '$containFolder/$index.ts');
    final output = '$containFolder/output.mp4';
    FFMpegUtils.combineTsToMp4(input, output);
  }

  // Future<void> handleHlsMasterPlaylist(
  //   HlsMasterPlaylist playlist,
  //   SendPort sendPort,
  // ) async {
  //   if (playlist.variants.isEmpty) {
  //     sendPort.send(
  //       IsolateMessage(
  //         0.0,
  //         DownloadStatus.error,
  //         message: "Master playlist has no variants",
  //         taskId: id,
  //       ),
  //     );
  //     return;
  //   }

  //   final variant = playlist.variants.first;
  //   final uri = variant.url;

  //   sendPort.send(
  //     IsolateMessage(
  //       12.0,
  //       DownloadStatus.downloading,
  //       message: "Processing master playlist variant",
  //       taskId: id,
  //     ),
  //   );

  //   try {
  //     final m3u8Lines = await DownloadUtils.readLinesAndFetch(uri);
  //     final playlistNew = await HlsPlaylistParser.create().parse(
  //       uri,
  //       m3u8Lines,
  //     );

  //     if (playlistNew is HlsMediaPlaylist) {
  //       await downloadHlsSegments(playlistNew, sendPort);
  //       return;
  //     }
  //     if (playlistNew is HlsMasterPlaylist) {
  //       await handleHlsMasterPlaylist(playlistNew, sendPort);
  //       return;
  //     }

  //     throw Exception('Unknown playlist type');
  //   } catch (e) {
  //     sendPort.send(
  //       IsolateMessage(
  //         0.0,
  //         DownloadStatus.error,
  //         message: "Error processing master playlist: $e",
  //         taskId: id,
  //       ),
  //     );
  //   }
  // }
}

class IsolateMessage {
  final double progress;
  final DownloadStatus status;
  final String? message;
  final String taskId;

  IsolateMessage(
    this.progress,
    this.status, {
    this.message,
    required this.taskId,
  });
}

enum DownloadStatus {
  //Download pause
  pause,

  //Download start
  downloading,

  //Download complete
  complete,

  //Download error
  error,

  //Video converting
  converting,
}
