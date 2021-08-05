import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yao_core/src/mixin/app.dart';
import '../env.dart';
import '../mvcs.dart';
import '../widget/empty_view.dart';

typedef RequestHandler = void Function(Request req, Response res);

class Request {
  String route = "";
  bool authenticated = false;

  void init({String route = "", bool authenticated = false}) {
    this.route = route;
    this.authenticated = authenticated;
  }
}

class Response {
  Widget widget = EmptyView();
  bool _next = false;
  bool get isNext => _next;
  String route = "";
  YaoController? controller;

  void render(Widget widget, {overrideable = false, YaoController? c}) {
    this.widget = widget;
    this.controller = c;
    if (overrideable == true) {
      _next = true;
    } else {
      _next = false;
    }
  }

  void next([String route = ""]) {
    _next = true;
    this.route = route;
  }
}

class DefaultBinding {
  DefaultBinding();

  static void init() {
    Get.put(Request());
    Get.put(Response());
  }

  static void dispose() {
    Get.delete<Request>();
    Get.delete<Response>();
  }
}

class Middleware extends GetMiddleware {
  List<RequestHandler> middlewares;
  Middleware(this.middlewares);

  @override
  RouteSettings? redirect(String? route) {
    DefaultBinding.dispose();
    DefaultBinding.init();

    Response resp = Get.find<Response>();
    Request req = Get.find<Request>();
    req.init(route: route != null ? route : "");
    for (final reqHandler in middlewares) {
      reqHandler(req, resp);
      if (!resp.isNext) {
        break;
      }

      /**restart next */
      resp._next = false;

      if (resp.route.isNotEmpty) {
        return RouteSettings(name: resp.route);
      }
    }

    Get.delete<YaoController>();
    final c = Get.find<Response>().controller;
    if (c != null) {
      Get.put(c);
    }

    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    return bindings;
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    return page;
  }

  @override
  Widget onPageBuilt(Widget page) {
    return page;
  }

  @override
  void onPageDispose() {
    // DefaultBinding.dispose();
  }
}

class MiddlewareManager with AppMixin {
  Map<String, List<RequestHandler>> middlewares = {};

  void add(String route, dynamic reqHandler) {
    if (reqHandler is RequestHandler) {
      if (middlewares.containsKey(route)) {
        middlewares[route]!.add(reqHandler);
      } else {
        middlewares.putIfAbsent(route, () => [reqHandler]);
      }
    } else if (reqHandler is List<RequestHandler>) {
      for (final hd in reqHandler) {
        add(route, hd);
      }
    }
  }

  List<GetPage> getPages() {
    List<GetPage> pages = [];
    List<RequestHandler> globalMiddlewares = this.getGlobal();
    Map<String, List<RequestHandler>> localMiddlewares = this.getLocal();
    Map<String, List<RequestHandler>> spesificMiddlewares = this.getSpesific();
    app.log(
        "route: ${localMiddlewares.length}, spesific: ${spesificMiddlewares.length}, global: ${globalMiddlewares.length}, total: ${middlewares.length}");

    for (final handler in localMiddlewares.entries) {
      List<RequestHandler> spesificHandler = [];
      //spesific
      for (final spesificMw in spesificMiddlewares.entries) {
        if (spesificMw.key.substring(1) == handler.key) {
          spesificHandler = spesificMw.value;
          break; //karena repo tidak mungkin mempunyai dua route yang sama
        }
      }

      List<RequestHandler> mws = [
        ...globalMiddlewares,
        ...spesificHandler,
        ...handler.value
      ];
      pages.add(GetPage(
          name: handler.key,
          page: () {
            Widget widget = Get.find<Response>().widget;
            if (widget is EmptyView) {}

            return widget;
          },
          // binding: BindingsBuilder(() {
          //   final c = Get.find<Response>().controller;
          //   if (c != null) {
          //     Get.put(c);
          //   }
          // }),
          middlewares: [Middleware(mws)]));
    }

    return pages;
  }

  void debug() {
    for (final entry in middlewares.entries) {
      print("${entry.key} ${entry.value.length}");
    }
  }
}

extension EMiddleware on MiddlewareManager {
  List<RequestHandler> getGlobal() {
    Map<String, List<RequestHandler>> _tmpGlobalMiddlewares =
        Map.from(middlewares)
          ..removeWhere((key, value) => key != Env.globalRequestHandlerId);
    List<RequestHandler> globalMiddlewares = [];
    for (final handler in _tmpGlobalMiddlewares.entries) {
      globalMiddlewares.addAll(handler.value);
    }

    return globalMiddlewares;
  }

  Map<String, List<RequestHandler>> getSpesific() {
    return Map.from(middlewares)
      ..removeWhere((key, value) =>
          key == Env.globalRequestHandlerId || !key.startsWith("~"));
  }

  Map<String, List<RequestHandler>> getLocal() {
    return Map.from(middlewares)
      ..removeWhere((key, value) =>
          key == Env.globalRequestHandlerId || key.startsWith("~"));
  }
}
