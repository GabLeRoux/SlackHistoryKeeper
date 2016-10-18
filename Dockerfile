FROM google/dart

WORKDIR /slackhistorykeeper

ADD pubspec.* /slackhistorykeeper/
RUN pub get
ADD . /slackhistorykeeper/
# fixes docker symlinks
RUN pub get --offline
RUN dart tool/grind.dart get

EXPOSE 3000

CMD []
ENTRYPOINT ["/usr/bin/dart", "/slackhistorykeeper/backend/bin/main.dart"]