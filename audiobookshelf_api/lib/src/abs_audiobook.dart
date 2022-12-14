import 'package:audiobookshelf_api/src/abs_track.dart';

import 'abs_utils.dart';

class AbsAudiobook {
  AbsAudiobook({
    this.id,
    this.ino,
    this.libraryId,
    this.folderId,
    this.media,
    this.tags,
    this.path,
    this.fullPath,
    this.addedAt,
    this.lastUpdate,
    this.duration,
    this.size,
    this.ebooks,
    this.numEbooks,
    this.numTracks,
    this.chapters,
    this.tracks,
    this.isMissing,
    this.isInvalid,
    this.hasMissingParts,
    this.hasInvalidParts,
  });

  String? id;
  String? ino;
  String? libraryId;
  String? folderId;
  Book? media;
  List<String>? tags;
  String? path;
  String? fullPath;
  DateTime? addedAt;
  DateTime? lastUpdate;
  Duration? duration;
  int? size;
  List<Ebook>? ebooks;
  int? numEbooks;
  int? numTracks;
  List<Chapter>? chapters;
  List<AbsTrack>? tracks;
  bool? isMissing;
  bool? isInvalid;
  int? hasMissingParts;
  int? hasInvalidParts;

  factory AbsAudiobook.fromJson(Map<String, dynamic> json) => AbsAudiobook(
        id: json["id"],
        ino: json["ino"],
        libraryId: json["libraryId"],
        folderId: json["folderId"],
        media: Book.fromJson(json["media"]["metadata"]),
        tags: List<String>.from(json["media"]["tags"].map((x) => x)),
        path: json["path"],
        fullPath: json["fullPath"],
        addedAt: AbsUtils.parseDateTime(json["addedAt"]),
        lastUpdate: AbsUtils.parseDateTime(json["lastUpdate"]),
        duration: AbsUtils.parseDurationFromSeconds(
          json["duration"]?.toDouble(),
        ),
        size: json["size"],
        ebooks: List<Ebook>.from(
            json["ebooks"]?.map((x) => Ebook.fromJson(x)) ?? []),
        numEbooks: json["numEbooks"],
        numTracks: json["numTracks"],
        chapters: json['media']['chapters'] == null
            ? []
            : [
                for (final chapter in json['media']['chapters'])
                  Chapter.fromJson(chapter)
              ],
        tracks: json['tracks'] == null
            ? []
            : [for (final t in json['tracks']) AbsTrack.fromMap(t)],
        isMissing: json["isMissing"],
        isInvalid: json["isInvalid"],
        hasMissingParts: json["hasMissingParts"],
        hasInvalidParts: json["hasInvalidParts"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ino": ino,
        "libraryId": libraryId,
        "folderId": folderId,
        "book": media?.toJson(),
        "tags": List<dynamic>.from(tags?.map((x) => x) ?? []),
        "path": path,
        "fullPath": fullPath,
        "addedAt": addedAt?.millisecondsSinceEpoch,
        "lastUpdate": lastUpdate?.millisecondsSinceEpoch,
        "duration": duration?.inMilliseconds,
        "size": size,
        "ebooks": List<dynamic>.from(ebooks?.map((x) => x.toJson()) ?? []),
        "numEbooks": numEbooks,
        "numTracks": numTracks,
        "chapters": List<dynamic>.from(chapters?.map((x) => x.toJson()) ?? []),
        "tracks": List<dynamic>.from(tracks?.map((x) => x.toMap()) ?? []),
        "isMissing": isMissing,
        "isInvalid": isInvalid,
        "hasMissingParts": hasMissingParts,
        "hasInvalidParts": hasInvalidParts,
      };
}

class Book {
  Book({
    this.title,
    this.subtitle,
    this.author,
    this.authorFl,
    this.authorLf,
    this.narrator,
    this.series,
    this.volumeNumber,
    this.publishYear,
    this.publisher,
    this.description,
    this.isbn,
    this.language,
    this.cover,
    this.coverFullPath,
    this.genres,
    this.lastUpdate,
    this.lastCoverSearch,
    this.lastCoverSearchTitle,
    this.lastCoverSearchAuthor,
  });

  String? title;
  String? subtitle;
  String? author;
  String? authorFl;
  String? authorLf;
  String? narrator;
  List<Series>? series;
  String? volumeNumber;
  String? publishYear;
  String? publisher;
  String? description;
  String? isbn;
  String? language;
  String? cover;
  String? coverFullPath;
  List<String>? genres;
  int? lastUpdate;
  dynamic lastCoverSearch;
  dynamic lastCoverSearchTitle;
  dynamic lastCoverSearchAuthor;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        title: json["title"],
        subtitle: json["subtitle"],
        author: json["author"],
        authorFl: json["authorFL"],
        authorLf: json["authorLF"],
        narrator: json["narrator"],
        series:
            json["series"]?.map<Series>((val) => Series.fromJson(val)).toList(),
        volumeNumber: json["volumeNumber"],
        publishYear: json["publishYear"],
        publisher: json["publisher"],
        description: json["description"],
        isbn: json["isbn"],
        language: json["language"],
        cover: json["cover"],
        coverFullPath: json["coverFullPath"],
        genres: List<String>.from(json["genres"].map((x) => x)),
        lastUpdate: json["lastUpdate"],
        lastCoverSearch: json["lastCoverSearch"],
        lastCoverSearchTitle: json["lastCoverSearchTitle"],
        lastCoverSearchAuthor: json["lastCoverSearchAuthor"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "subtitle": subtitle,
        "author": author,
        "authorFL": authorFl,
        "authorLF": authorLf,
        "narrator": narrator,
        "series": series,
        "volumeNumber": volumeNumber,
        "publishYear": publishYear,
        "publisher": publisher,
        "description": description,
        "isbn": isbn,
        "language": language,
        "cover": cover,
        "coverFullPath": coverFullPath,
        "genres": List<dynamic>.from(genres?.map((x) => x) ?? []),
        "lastUpdate": lastUpdate,
        "lastCoverSearch": lastCoverSearch,
        "lastCoverSearchTitle": lastCoverSearchTitle,
        "lastCoverSearchAuthor": lastCoverSearchAuthor,
      };
}

class Chapter {
  Chapter({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
  });

  int id;
  double start;
  double end;
  String title;

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json["id"],
        start: json["start"] is String
            ? double.parse(json['start'])
            : json['start'].toDouble(),
        end: json["end"] is String
            ? double.parse(json['end'])
            : json['end'].toDouble(),
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "start": start,
        "end": end,
        "title": title,
      };
}

class Ebook {
  Ebook({
    required this.ino,
    required this.filetype,
    required this.filename,
    required this.ext,
    required this.path,
    required this.fullPath,
    required this.addedAt,
  });

  String ino;
  String filetype;
  String filename;
  String ext;
  String path;
  String fullPath;
  int addedAt;

  factory Ebook.fromJson(Map<String, dynamic> json) => Ebook(
        ino: json["ino"],
        filetype: json["filetype"],
        filename: json["filename"],
        ext: json["ext"],
        path: json["path"],
        fullPath: json["fullPath"],
        addedAt: json["addedAt"],
      );

  Map<String, dynamic> toJson() => {
        "ino": ino,
        "filetype": filetype,
        "filename": filename,
        "ext": ext,
        "path": path,
        "fullPath": fullPath,
        "addedAt": addedAt,
      };
}

class Series {
  Series({
    required this.id,
    required this.name,
    required this.sequence,
  });

  String id;
  String name;
  String sequence;

  factory Series.fromJson(Map<String, dynamic> json) => Series(
        id: json["id"],
        name: json["name"],
        sequence: json["sequence"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "sequence": sequence,
      };
}
