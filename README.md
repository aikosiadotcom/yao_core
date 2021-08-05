# Yao Core

MVCS (Model-View-Controller-Service) core package used by yao framework [yao](https://pub.dev/packages/yao).

this package using:
1. [Get](https://pub.dev/packages/get) as an dependency injection
2. [Express](https://expressjs.com/) syntax

# Note

Still in development. Not stable yet.

# Usage

## Initialize

```
import 'package:yao_core/yao_core.dart';

final app = Yao();

```

## Route - View - Controller
```
app.get("/", (req, res) {
    res.render(HomepageView(), c: HomeController());
});
```

## Service

```
//inject
app.inject(MyService());

//get back
final service = app.find<MyService>();

```

## Event

```
app.on(EitherType(YaoEvent.ready),()async{
    app.log('ready');
});
```

## Run

```
app.run()
```