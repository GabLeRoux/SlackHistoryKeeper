import 'dart:async';

import 'package:di/di.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:slack_history_keeper_shared/models.dart';
import 'package:slack_history_keeper_shared/convert.dart';

import 'has_connection_pool.dart';
import 'mongo_db_pool.dart';

@Injectable()
class ChannelRepository extends HasConnectionPool {
  final ChannelDecoder channelDecoder = new ChannelDecoder();
  final ChannelEncoder channelEncoder = new ChannelEncoder();

  ChannelRepository(MongoDbPool connectionPool) : super(connectionPool);

  Future<List<Channel>> fetchChannels() async {
    var channels = <Channel>[];

    return executeWrappedCommand((Db db) async {
      var maps = db.collection("channels").find();

      await for (Map m in maps) {
        channels.add(channelDecoder.convert(m));
      }

      return channels;
    }) as List<Channel>;
  }

  Future insertChannels(List<Channel> channels) {
    channels.forEach((Channel c) => print("$c \n"));

    if (channels.isEmpty) return new Future.value();

    return executeWrappedCommand((Db db) async {
      return db.collection("channels").insertAll(
          channels.map((Channel c) => channelEncoder.convert(c)).toList(),
          writeConcern: new WriteConcern(fsync: true));
    });
  }
}
