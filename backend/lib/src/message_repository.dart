import 'dart:async';

import 'package:di/di.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:quiver/strings.dart';

import 'package:slack_history_keeper_backend/src/mongo_db_pool.dart';
import 'package:slack_history_keeper_shared/models.dart';
import 'package:slack_history_keeper_shared/convert.dart';

import 'has_connection_pool.dart';

@Injectable()
class MessageRepository extends HasConnectionPool {
  final MessageDecoder messageDecoder = new MessageDecoder();
  final MessageEncoder messageEncoder = new MessageEncoder();

  MessageRepository(MongoDbPool connectionPool) : super(connectionPool);

  Future<List<Message>> fetchMessages(
      {List<String> channelIds: const [], List<String> userIds: const []}) {
    return executeWrappedCommand((Db db) async {
      var maps =
          db.collection("messages").find(where..sortBy("ts", descending: true));

      var messages = <Message>[];
      await for (var map in maps) {
        messages.add(messageDecoder.convert(map));
      }

      return messages;
    }) as Future<List<Message>>;
  }

  Future<List<Message>> queryMessages(String queryString,
      {List<String> channelIds: const [], List<String> userIds: const []}) {
    return executeWrappedCommand((Db db) async {
      var query = where.sortBy("ts", descending: true);

      if (!isEmpty(queryString))
        query = query
          ..eq("\$text", {"\$search": queryString})
          ..metaTextScore("score")
          ..sortByMetaTextScore("score");
      if (channelIds.isNotEmpty) query = query.oneFrom("channelId", channelIds);
      if (userIds.isNotEmpty) query = query.oneFrom("user", userIds);

      var documents = db.collection("messages").find(query);
      var messages = <Message>[];
      await for (var d in documents) {
        messages.add(messageDecoder.convert(d));
      }

      return messages;
    }) as Future<List<Message>>;
  }

  Future<Message> getLatestMessage(String channelId) async {
    return executeWrappedCommand((Db db) async {
      Map fetched = await db.collection("messages").findOne(
          where.sortBy('ts', descending: true).eq("channelId", channelId));
      return fetched == null ? null : messageDecoder.convert(fetched);
    }) as Future<Message>;
  }

  Future insertMessages(List<Message> messages) {
    messages.forEach((Message m) => print("$m \n"));

    if (messages.isEmpty) return new Future.value();

    return executeWrappedCommand((Db db) async {
      return db.collection("messages").insertAll(
          messages.map((Message m) => messageEncoder.convert(m)).toList(),
          writeConcern: new WriteConcern(fsync: true));
    });
  }

  Future clearMessages() async {
    return executeWrappedCommand((Db db) async {
      return db.collection("messages").drop();
    });
  }

  Future createIndexOnText() {
    return executeWrappedCommand((Db db) async {
      return db.createIndex("messages", keys: {'text': 'text'});
    });
  }
}
