import 'package:flutter/cupertino.dart';
import 'package:websafe_svg/websafe_svg.dart';

class QsSvgParams {
  final Alignment alignment;
  final Color? color;
  final BoxFit fit;
  final double? height;
  final String? package;
  final WidgetBuilder? placeholderBuilder;
  final double? width;

  const QsSvgParams({
    this.alignment = Alignment.center,
    this.color,
    this.fit = BoxFit.contain,
    this.height,
    this.package,
    this.placeholderBuilder,
    this.width,
  });
}

const _defParams = QsSvgParams();

Widget assetSvg(String path, {QsSvgParams params = _defParams}) {
  return WebsafeSvg.asset(
    path,
    alignment: params.alignment,
    color: params.color,
    fit: params.fit,
    height: params.height,
    package: params.package,
    placeholderBuilder: params.placeholderBuilder,
    width: params.width,
  );
}

Widget networkSvg(String path, {QsSvgParams params = _defParams}) {
  return WebsafeSvg.network(
    path,
    alignment: params.alignment,
    color: params.color,
    fit: params.fit,
    height: params.height,
    placeholderBuilder: params.placeholderBuilder,
    width: params.width,
  );
}
