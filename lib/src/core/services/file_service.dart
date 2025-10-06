import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'api_service.dart';

/// Serviço simples para salvar arquivos temporários e retornar o path
class FileService {
  final ApiService _apiService;

  FileService({required ApiService apiService}) : _apiService = apiService;

  /// Faz download do arquivo via ApiService e salva em cache temporário
  Future<String> downloadToTemp(String endpoint, {String? filename}) async {
    final bytes = await _apiService.downloadBytes(endpoint);

    final tempDir = await getTemporaryDirectory();
    final name = filename ?? DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = p.join(tempDir.path, name);

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Remove arquivo local (silencioso)
  Future<void> removeFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // ignore
    }
  }
}
