// Copyright 2023 Shinya Kato. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

import 'dart:async';

import 'package:actions_toolkit_dart/core.dart' as core;
import 'package:bluesky/bluesky.dart' as bsky;


Future<void> post() async {
  final service = _service;
  final retryCount = core.getInput(name: 'retry-count');

  final retryConfig = bsky.RetryConfig(
    maxAttempts: retryCount.isEmpty ? 5 : int.parse(retryCount),
  );

  final session = await bsky.createSession(
    service: service,
    identifier: core.getInput(
      name: 'identifier',
      options: core.InputOptions(
        required: true,
        trimWhitespace: true,
      ),
    ),
    password: core.getInput(
      name: 'password',
      options: core.InputOptions(
        required: true,
        trimWhitespace: true,
      ),
    ),
    retryConfig: retryConfig,
  );

  final bluesky = bsky.Bluesky.fromSession(
    session.data,
    service: service,
    retryConfig: retryConfig,
  );

  final imageURL = core.getInput(
      name: 'imageURL',
      options: core.InputOptions(required: false),
    )
  if (imageURL.isEmpty){


  final createdPost = await bluesky.feeds.createPost(
    text: core.getInput(
      name: 'text',
      options: core.InputOptions(required: true),
    ),
    embed:embedIMG,
  );
  }else{
    final response = await http.get(Uri.parse(imageURL));

    final file = File('dummy.jpg');
    file.writeAsBytesSync(response.bodyBytes);
    final blobData = await _getBlobData(bluesky, file);
    final header = getHeader(image);

    final createdPost = await bluesky.feeds.createPost(
      text: header,
      facets: getFacets(
        image,
        header,
      ),
      embed: bsky.Embed.images(
        data: bsky.EmbedImages(
          images: [
            bsky.Image(
              alt: "image.title",
              image: blobData.blob,
            )
          ],
        ),
      ),
    );
  }
  core.info(message: 'Sent a post successfully!');
  core.info(message: 'cid = [${createdPost.data.cid}]');
  core.info(message: 'uri = [${createdPost.data.uri}]');
}

String get _service {
  final service = core.getInput(
    name: 'service',
    options: core.InputOptions(trimWhitespace: true),
  );

  return service.isEmpty ? 'bsky.social' : service;
}
