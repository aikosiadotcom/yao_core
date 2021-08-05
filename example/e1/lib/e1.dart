import 'package:flutter/material.dart';
import 'package:yao_core/yao_core.dart';

class TestRouteView extends YaoView<TestRouteController> {
  final String title;
  TestRouteView(this.title);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text(title),
              SizedBox(height: 10),
              Text(c.title.value),
              SizedBox(height: 10),
              ElevatedButton(onPressed: c.goto, child: Text(c.route))
            ])),
      ),
    );
  }
}

class TestRouteController extends YaoController {
  final title = "Test".obs;

  final String route;
  TestRouteController(this.route);

  void goto() {
    app.goto(this.route);
  }
}

class TestService1 extends YaoService {
  void test() {
    print('test service1');
  }

  @override
  Future<TestService1> run() async {
    print('run service1');
    return this;
  }
}

class TestService2 extends YaoService {
  void test() {
    print('test service2');
  }

  @override
  Future<TestService2> run() async {
    print('run service2');
    return this;
  }
}

class TestService3 extends YaoService {
  void test() {
    print('test service3');
  }

  @override
  Future<TestService3> run() async {
    print('run service3');
    return this;
  }
}

void main() async {
  final app = Yao();
  final log = app.Logger("XXXXXXX");
  app.inject(TestService1());
  app.inject(TestService2());
  app.on(EitherType(YaoEvent.ready_services), () async {
    print("yao");
    app.inject(TestService3());
  });

  /**with router */
  final router = app.Router();
  router.use((req, res) {
    log("global middleware at route birds ");
    res.next();
  });

  // define the home page route
  router.get('/', (req, res) {
    log('render birds');
    res.render(TestRouteView('Birds home page'),
        c: TestRouteController("/birds/about"));
  });

  router.use("/about", (req, res) {
    log("global middleware at route about");
    res.next();
  });
  // define the about route
  router.get('/about', (req, res) {
    log("render about");
    res.render(TestRouteView('About birds'), c: TestRouteController("/"));
  });

  app.get("/", (req, res) {
    log("render homepage");
    res.render(TestRouteView("home"), c: TestRouteController("/birds"));
  });
  app.use('/birds', router);

  /**without router */
  // app.use((req, res) {
  //   log("global middleware at route birds ");
  //   res.next();
  // });

  // // define the home page route
  // app.get('/', (req, res) {
  //   log('render birds');
  //   res.render(TestRouteView('Birds home page'),
  //       c: TestRouteController("/about"));
  // });

  // app.use("/about", (req, res) {
  //   log("global middleware at route about");
  // });
  // // define the about route
  // app.get('/about', (req, res) {
  //   log("render about");
  //   res.render(TestRouteView('About birds'), c: TestRouteController("/"));
  // });

  app.run();
}
