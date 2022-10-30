import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Version {
  late String name;
  late int size;
  late Uri downloadUri;
  late DateTime createdAt;
  late String body;
  late bool isBE; //todo

  late File folder;

  Version({
    required this.name,
    required this.size,
    required this.downloadUri,
    required this.createdAt,
    required this.body,
    required this.isBE
  }) {
    folder = File("${Platform.environment["APPDATA"]}\\MLauncher\\Versions\\$name");
  }

  factory Version.fromJson(Map<String, dynamic> data) {
    final name = data["name"] as String;
    final assets = data["assets"] as List<dynamic>;
    if (assets.isEmpty) throw Exception("empty assets");
    final size = assets[0]["size"] as int;
    final downloadUrl = Uri.parse(assets[0]["browser_download_url"]);
    final createdAt = DateTime.parse(data["created_at"]);
    final body = data["body"];
    return Version(
        name: name == "" ? "Build ${data['tag_name']}" : name,
        size: size,
        downloadUri: downloadUrl,
        createdAt: createdAt,
        body: body,
        isBE: name == "",
    );
  }
}

class VersionLoader {
  static Future<List<Version>> load() async {
    return await loadGithub();
  }

  static Future<List<Version>> loadGithub() async {
    List<Version> versionsList =
      await readRepositoriesReleases(Uri(scheme: "https", host: "api.github.com", path:"repos/anuken/Mindustry/releases", queryParameters: {"per_page": "100"}));
    versionsList.addAll(
      await readRepositoriesReleases(Uri(scheme: "https", host: "api.github.com", path: "repos/anuken/MindustryBuilds/releases", queryParameters: {"per_page": "100"}))
    );
    versionsList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    versionsList = versionsList.reversed.toList();
    return versionsList;
  }

  static Future<List<Version>> readRepositoriesReleases(Uri uri) async {
    final response = await http.get(uri);
    List<dynamic> jsonArray = jsonDecode(response.body);
    List<Version> versions = <Version>[];
    jsonArray.forEach((element) {
      try {
        versions.add(Version.fromJson(element));
      } on Exception {
        return;
      }
    });
    return versions;
  }
}