import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/model/comic.dart';

class ComicItemWidget extends StatelessWidget {
  final Comic comic;

  const ComicItemWidget({Key key, @required this.comic})
      : assert(comic != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: comic.thumbnail,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      const Color(0xffFFAB00),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error,
                        color: const Color(0xffFFAB00),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Load image error',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      comic.title,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 14,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            comic.view,
                            style: Theme.of(context).textTheme.headline6.copyWith(
                                  fontSize: 13,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    for (var chapter in comic.lastChapters)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                chapter.chapterName,
                                style:
                                    Theme.of(context).textTheme.headline6.copyWith(
                                          fontSize: 12,
                                        ),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                chapter.time,
                                style:
                                    Theme.of(context).textTheme.headline6.copyWith(
                                          fontSize: 12,
                                        ),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      aspectRatio: 1 / 1.618,
    );
  }
}
