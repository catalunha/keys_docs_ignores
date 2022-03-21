

## ToDo-Versão 5 com 2 Databases

1) Estrutura completa do projeto
```Dart
lib/app
├── data
│   ├── datasources
│   │   ├── firebase
│   │   └── hive
│   └── repositories
├── domain
│   ├── models
│   └── usecases
└── presentation
    ├── controllers
    ├── pages
    └── routes.dart
```

2) Repositorio e suas implementações com base em cada banco.
```
data
├── datasources
│   ├── firebase
│   │   ├── task
│   │   │   ├── task_repository_exception.dart
│   │   │   └── task_repository_firebase_impl.dart
│   ├── hive
│   │   ├── task
│   │   │   ├── task_repository_exception.dart
│   │   │   └── task_repository_hive_impl.dart
└── repositories
    ├── task_repository.dart
```
3) O uuid é necessario para separar usuarios. As demais funcões são padrao.
```Dart
abstract class TaskRepository {
  void setUserUuid(String uuid);
  Future<void> create(TaskModel taskModel);
  ...
}
```
4) No modelo MVVM seria o taskService. Que em cleanCode coloquei em domain. 
Mas apenas chama o repo a partir do controle
```
domain
├── models
│   ├── task
│   │   ├── task_model.dart
└── usecases
    ├── task
    │   ├── task_usecase.dart
    │   ├── task_usecase_exception.dart
    │   └── task_usecase_impl.dart
```
5) O exemplo do taskService ou taskUseCase
```Dart
class TaskUseCaseImp implements TaskUseCase {
  @override
  Future<void> create(TaskModel taskModel) {
    _taskRepository.setUserUuid(_userService.userModel.uuid);
    return _taskRepository.create(taskModel);
  }
...
}
```

6) O controller e o binding.
```
presentation/controllers/task
└── append
    ├── task_append_controller.dart
    └── task_append_bindings.dart
```
---> 7) Agora vem a escolha de qual implementaçaõ usar ?
```Dart
class TaskAppendBindings implements Bindings {
  @override
  void dependencies() {
    var userService = Get.find<UserService>();
    print('+++ Qual database do usuario: ${userService.userModel.database}');
    if (userService.userModel.database == 'firebase') {
      Get.put<TaskRepository>(
        TaskRepositoryFirebaseImp(firebaseFirestore: Get.find()),
      );
    } else {
      Get.put<TaskRepository>(
        TaskRepositoryHiveImp(),
      );
    }
    Get.put<TaskUseCase>(
      TaskUseCaseImp(taskRepository: Get.find(), userService: Get.find()),
    );
    Get.lazyPut<TaskAppendController>(
        () => TaskAppendController(taskUseCase: Get.find()));
  }
}
```
### Resposta do marcus
```Dart
static NetWorkPrint? instance;

 NetWorkPrint.();
  static NetWorkPrint get instance {
    instance ??= NetWorkPrisnt.();
    return _instance!;
  }
```

```Dart
class GeneralPrinterContorller extends GetxController {
PhysicalPrinter get physical => PhysicalPrinter.instance;
NetWorkPrint get network => NetWorkPrint.instance;
SunmiPrinterDevice get sunmi => SunmiPrinterDevice.instance;
ElginPrinterDevice get elgin => ElginPrinterDevice.instance;
  var _printerInstance;
  T printerInstance<T>() {
    return _printerInstance as T;
  }
  T? printer<T>(Map<String, dynamic>? printer) {
    if (printer?['impressora'] == null) {
      _printerInstance = null; // null; physical as T;
      return null;
    } else {
      if (printer?['impressora']['fabricante'] == 'M8_M10') {
        _printerInstance = elgin as T;
        return elgin as T;
      }
      if (printer?['impressora']['fabricante'] == 'SUNMI_50' || printer?['impressora']['fabricante'] == 'SUNMI_80') {
        if (printer?['impressora']['fabricante'] == 'SUNMI_50') {
          sunmi.paper = PaperSize.mm58;
        }
        _printerInstance = sunmi as T;
        return sunmi as T;
      }
      if (printer?['impressora']['local_device'] != null && printer?['impressora']['local_device'] != '') {
        physical.devicePort = printer?['impressora']['local_device'];
        _printerInstance = physical as T;
        return physical as T;
      } else {
        if (printer?['impressora']['impressora_rede'] != null && printer?['impressora']['impressora_rede'] != '') {
          if (printer?['impressora']['porta_rede'] == "" || printer?['impressora']['porta_rede'] == null) {
            network.port = 9100;
          } else {
            try {
              network.port = int.parse(printer?['impressora']['porta_rede']);
            } catch (_) {
              network.port = 9100;
            }
          }
          network.ip = printer?['impressora']['impressora_rede'];
          _printerInstance = network as T;
          return network as T;
        } else {
          _printerInstance = physical as T;
          return physical as T;
        }
      }
    }
  }
}

```
É uma instancia burra.
Depois vc especifica qual instancia correta com base no map.
```Dart
      Get.put<GeneralPrinterContorller>(
        GeneralPrinterContorller(),
      );
GeneralPrinterContorller _serial = Get.find<GeneralPrinterContorller>().printer(_empresaController.empresaHive.equipamentoHost);
      var _impressora = _serial.printerInstance();

```


```Dart

Future<bool> imprimirTef(String payloadTef) async {
    try {
      var _impressora = _serial.printerInstance();
      if (_impressora == null) {
        return false;
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(_impressora.paper ?? PaperSize.mm80, profile);
      List<int> _bytes = [];

      String _decoded = Utils.base64ToString(payloadTef.replaceAll('\n', ''));
      _bytes += generator.text(_decoded, styles: PosStyles(fontType: PosFontType.fontA, height: PosTextSize.size1, width: PosTextSize.size1));
      _bytes += generator.reset();
      await _impressora.printByte(_bytes);
      await _impressora.feed(3);
      await impressora.cut();
      return true;
    } catch () {
      return false;
    }
  }

```

Get.find(tag:firebase) por exemplo
