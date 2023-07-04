import 'dart:async';
import 'dart:developer' as d;

import 'package:flutter/material.dart' hide Route;
import 'package:get/get.dart';
import 'package:yao_core/src/main.dart';
import 'package:yao_core/src/manager/event.dart';
import 'dialog.dart';
import 'exception/noroute.dart';
import 'manager/middleware.dart';
import 'mvcs.dart';
import 'env.dart';

import 'manager/service.dart';
import 'navigator.dart';
import 'widget/error_retrier.dart';

void _log(message) {
  d.log(message, name: Env.pluginId);
}

class App with YaoRouterBase {
  final YaoLoader loader = YaoLoader();

  dynamic _session;
  void set session(dynamic session) => _session = session;
  dynamic get session => _session;

  String title = Env.appName;
  final YaoDialog dialog = YaoDialog();
  final YaoNavigator navigator = YaoNavigator();

  // ignore: non_constant_identifier_names
  YaoRouterBase Router() => YaoRouterBase();
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

  Widget _runTest() {
    Get.put(StartupController(this));
    return StartupView(this.title);
  }

  Future<Map<String, dynamic>?> wait(EitherType<String, YaoEvent> event) async {
    Completer<Map<String, dynamic>?> promise = Completer();
    this.on(event, (args) async {
      promise.complete(args);
    });
    return promise.future;
  }

  Future runWithTester(dynamic tester) {
    //ignore: argument_type_not_assignable, could_not_infer
    return Future.wait([
      Future.any([
        this.wait(EitherType(YaoEvent.appReady)),
        this.wait(EitherType(YaoEvent.appError))
      ]),
      tester.pumpWidget(this._runTest()) as Future
    ]);
  }

  void inject<T extends YaoService>(T instance, {String? tag}) {
    _serviceManager.add<T>(instance, tag: tag);
  }

  T put<T extends YaoControllerCustom>(T instance, {String? tag}) {
    return Get.put(instance, tag: tag);
  }

  T find<T extends YaoService>({String? tag}) {
    return _serviceManager.find<T>(tag: tag);
  }

  void on(EitherType<String, YaoEvent> name, EventCb cb) {
    _eventManager.on(name, cb);
  }

  void log(message) {
    _log(message);
  }
}

class YaoRouterBase {
  MiddlewareManager _middlewareManager = MiddlewareManager();

  void get(String route, RequestHandler reqHandler) {
    // _middlewareRepo.add(_transformRoute(route), reqHandler);
    _middlewareManager.add(route, reqHandler);
  }

  void use(dynamic routeOrReqHandler, [dynamic routerOrReqHandler]) {
    //TODO: maybe throw error when no match signature
    if (routeOrReqHandler is YaoRouter) {
      final String route = Route.of(routeOrReqHandler);
      final YaoRouter tmp = routeOrReqHandler;
      this.use(route, tmp.router);
    } else if (routeOrReqHandler is RequestHandler &&
        routerOrReqHandler == null) {
      _middlewareManager.add(Env.globalRequestHandlerId, routeOrReqHandler);
    } else if (routeOrReqHandler is String &&
        routerOrReqHandler is RequestHandler) {
      _middlewareManager.add(
          "${Env.spesificRequestHandlerId}$routeOrReqHandler",
          routerOrReqHandler);
    } else if (routeOrReqHandler is String &&
        routerOrReqHandler is YaoRouterBase) {
      YaoRouterBase router = routerOrReqHandler;

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
      // app.log("start");
      // await Future.delayed(Duration(seconds: 5));
      await app._serviceManager.run();
      await app._eventManager.emit(EitherType(YaoEvent.serviceReady));

      pages = app._middlewareManager.getPages();
      if (pages.isEmpty) {
        throw NoRouteException("Please provide at least one route !");
      }

      change(null, status: RxStatus.success());

      await app._eventManager.emit(EitherType(YaoEvent.appReady));
      // await Future.delayed(Duration(seconds: 5));
      // app.log("ready");
    } catch (err) {
      change(null, status: RxStatus.error(err.toString()));
      await app._eventManager
          .emit(EitherType(YaoEvent.appError), {"error": err.toString()});
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
            theme: ThemeData(
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorSchemeSeed: Color(0xFF369CF0),
            ),
            initialRoute: "/",
            getPages: controller.pages),
        onLoading: Builder(builder: (BuildContext context) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              // theme: ThemeData(scaffoldBackgroundColor: Colors.blue),
              home: Scaffold(
                  body: SafeArea(
                      child: Center(child: CircularProgressIndicator()))));
        }),
        onError: (err) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                body: SafeArea(
                    child:
                        (ErrorRetrier(err == null ? "" : err, () async {}))))));
  }
}
