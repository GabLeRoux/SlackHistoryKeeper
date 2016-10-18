# slack_history_keeper

An application that scrapes Slack chat and saves history.

## Requirements
* Have [sass](https://github.com/sass/sass) installed. Can also be [sassc](https://github.com/sass/sassc). Just make sure to configure the transformer.
* Declare an environment variable called `SLACK_TOKEN` with a string value of your [Slack Api token](https://get.slack.help/hc/en-us/articles/215770388-Create-and-regenerate-API-tokens).
* Declare an environment variable called `SLACK_DB_URI` with the URI of your mongo database that will store the messages.

## Usage
* To get all dependencies, type `dart tool/grind.dart get`
* (Optional) To upgrade the project's dependencies, type `dart tool/grind.dart upgrade`
* To start the backend, `cd backend/` and `dart bin/main.dart`. This fetches and prints chat logs of all channels associated with the slack token provided. It also starts a REST Api exposing some end points used by the frontend.
* To start the front end, in another terminal, `cd frontend/` and `pub serve`.
* You can then access the app via Dartium @ `http://localhost:8080` or with Chrome (but it'll take longer to compile Dart code to JS) to the same address.

## Docker

This app can be used with [docker](https://www.docker.com/)! It uses the [google/dart-runtime docker image](https://hub.docker.com/r/google/dart-runtime/). See [Dockerfile](Dockerfile) for details.

### Build the image

    docker build -t pacane/slack-history-keeper .

### Run the image

    docker run -i -t pacane/slack-history-keeper -p 3000:3000 \
    -e SLACK_TOKEN="XXXX-XXXXXXXXXXX-XXXXXXXXXXX-XXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
    -e SLACK_DB_URI="mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]"

/!\ Close to solution, but not working yet!

### (Optional) Run mongodb in a docker container too

Using the [library/mongo image](https://hub.docker.com/_/mongo/):

    docker run --name some-mongo -d mongo

or

    docker run --name some-app --link slach-history-keeper-mongo:mongo -d pacane/slack-history-keeper
