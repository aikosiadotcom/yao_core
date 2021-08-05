import 'dart:developer' as d;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yao_core/src/manager/event.dart';
import 'exception/noroute.dart';
import 'manager/middleware.dart';
import 'mvcs.dart';
import 'env.dart';

import 'manager/service.dart';
import 'widget/error_retrier.dart';

void _log(message) {
  d.log(message, name: Env.pluginId);
}

class App with YaoRouter {
  String title = Env.appName;

  // ignore: non_constant_identifier_names
  YaoRouter Router() => YaoRouter();
  // ignore: non_constant_identifier_names
  Function(String) Logger([String namespace = Env.pluginId]) {
    return (String message) => d.log(message, name: namespace);
  }

  final ServiceManager _serviceManager = ServiceManager();
  final EventManager _eventManager = EventManager();

  void run() {
    Get.put(StartupController(this));
    runApp(StartupView(this.title));
  }

  void inject<T extends YaoService>(T instance, {String? tag}) {
    _serviceManager.add<T>(instance, tag: tag);
  }

  T find<T extends YaoService>({String? tag}) {
    return _serviceManager.find<T>(tag: tag);
  }

  void on(EitherType<String, YaoEvent> name, EventCb cb) {
    _eventManager.on(name, cb);
  }

  void goto(String route) {
    // ioc.offNamed(_transformRoute(route));
    Get.offNamed(route);
  }

  void log(message) {
    _log(message);
  }
}

class YaoRouter {
  MiddlewareManager _middlewareManager = MiddlewareManager();

  void get(String route, RequestHandler reqHandler) {
    // _middlewareRepo.add(_transformRoute(route), reqHandler);
    _middlewareManager.add(route, reqHandler);
  }

  void use(dynamic routeOrReqHandler, [dynamic routerOrReqHandler]) {
    //TODO: maybe throw error when no match signature
    if (routeOrReqHandler is RequestHandler && routerOrReqHandler == null) {
      _middlewareManager.add(Env.globalRequestHandlerId, routeOrReqHandler);
    } else if (routeOrReqHandler is String &&
        routerOrReqHandler is RequestHandler) {
      _middlewareManager.add(
          "${Env.spesificRequestHandlerId}$routeOrReqHandler",
          routerOrReqHandler);
    } else if (routeOrReqHandler is String && routerOrReqHandler is YaoRouter) {
      YaoRouter router = routerOrReqHandler;

      List<RequestHandler> globalMiddlewares =
          router._middlewareManager.getGlobal();
      Map<String, List<RequestHandler>> localMiddlewares =
          router._middlewareManager.getLocal();
      Map<String, List<RequestHandler>> spesificMiddlewares =
          router._middlewareManager.getSpesific();

      for (final localMw in localMiddlewares.entries) {
        for (final reqHandler in localMw.value) {
          String route = routeOrReqHandler + localMw.key;
          //global dulu
          _middlewareManager.add(route, globalMiddlewares);

          //spesific
          for (final spesificMw in spesificMiddlewares.entries) {
            if (spesificMw.key.substring(1) == localMw.key) {
              _middlewareManager.add(route, spesificMw.value);
              break; //karena repo tidak mungkin mempunyai dua route yang sama
            }
          }

          //local
          _middlewareManager.add(route, reqHandler);
        }
      }

      // _middlewareRepo.debug();
    }
  }
}

class StartupController extends GetxController with StateMixin<bool> {
  late final List<GetPage> pages;
  final App app;

  StartupController(this.app);

  @override
  void onInit() async {
    try {
      // await Future.delayed(Duration(seconds: 10));
      await app._serviceManager.run();
      await app._eventManager.emit(EitherType(YaoEvent.ready_services));

      pages = app._middlewareManager.getPages();
      if (pages.isEmpty) {
        throw NoRouteException("Please provide at least one route !");
      }

      await app._eventManager.emit(EitherType(YaoEvent.ready));

      change(null, status: RxStatus.success());
    } catch (err) {
      change(null, status: RxStatus.error(err.toString()));
    }

    super.onInit();
  }
}

class StartupView extends GetView<StartupController> {
  final String title;

  StartupView(this.title);

  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (state) => GetMaterialApp(
            title: this.title,
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            getPages: controller.pages),
        onLoading: Builder(
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        ),
        onError: (err) => MaterialApp(
            home: Scaffold(
                body: SafeArea(
                    child:
                        (ErrorRetrier(err == null ? "" : err, () async {}))))));
  }
}
