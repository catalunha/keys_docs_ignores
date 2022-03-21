# Agradecimento

Este projeto só foi possivel devido a cooperação direto do Marcus Brasizza e do Rodrigo Rahman e da galera da Academia do Flutter http://academiadoflutter.com.br/

# Introdução

Nesta versão 05 o ToDo permite que o usuário decida em qual DataSource irá armazenar as informações. 
Conforme as opções a seguir. Apenas as 2 primeiras foram implementadas.
```Dart
enum DatasourcesEnum {
  hive,
  firebase,
  isar,
  couchbase,
  appwrite,
}
```
Mas vamos começar do começo. A estrutura das pastas
```
data
├── datasources
│   ├── datasources.dart
│   ├── firebase
│   │   ├── task
│   │   │   ├── task_repository_exception.dart
│   │   │   ├── task_repository_factory_firebase.dart
│   │   │   └── task_repository_firebase_impl.dart
│   ├── hive
│   │   ├── task
│   │   │   ├── task_repository_exception.dart
│   │   │   ├── task_repository_factory_hive.dart
│   │   │   └── task_repository_hive_impl.dart
└── repositories
    ├── factories
    │   └── task_repository_factory.dart
    ├── task_repository.dart
...
domain
├── models
│   ├── task
│   │   ├── task_model.dart
├── services
│   └── user_service.dart
└── usecases
    ├── task
    │   ├── task_usecase.dart
    │   ├── task_usecase_exception.dart
    │   └── task_usecase_impl.dart
...
presentation
├── controllers
│   ├── task
│   │   └── append
│   │       ├── task_append_controller.dart
│   │       └── task_append_dependencies.dart
├── pages
│   ├── task
│   │   └── append
│   │       ├── part
│   │       └── task_append_page.dart
└── routes.dart
```
A interface do repositorio
```Dart
abstract class TaskRepository {
  Future<void> create(TaskModel taskModel);
}
```
E sua implementação para Hive
```Dart
class TaskRepositoryHiveImp implements TaskRepository {
  static TaskRepositoryHiveImp? _instance;

  TaskRepositoryHiveImp._();
  static TaskRepositoryHiveImp get instance {
    _instance ??= TaskRepositoryHiveImp._();
    return _instance!;
  }

  String _userUuid = '';
  set userUuid(String uuid) {
    _userUuid = uuid;
  }

  @override
  Future<void> create(TaskModel taskModel) async {
    var box = await Hive.openBox(_userUuid);
    await box.put(taskModel.uuid, taskModel.toJson());
    await box.close();
  }
}
```
E sua implementação para Firebase
```Dart
class TaskRepositoryFirebaseImp implements TaskRepository {
  static TaskRepositoryFirebaseImp? _instance;

  TaskRepositoryFirebaseImp._();
  static TaskRepositoryFirebaseImp get instance {
    _instance ??= TaskRepositoryFirebaseImp._();
    return _instance!;
  }

  String _userUuid = '';
  set userUuid(String uuid) {
    _userUuid = uuid;
  }

  FirebaseFirestore? _firebaseFirestore;
  set firebaseFirestore(FirebaseFirestore firebaseFirestore) {
    _firebaseFirestore = firebaseFirestore;
  }

  @override
  Future<void> create(TaskModel taskModel) async {
    print('create firebase');
    try {
      CollectionReference docRef = _firebaseFirestore!
          .collection(UserModel.collection)
          .doc(_userUuid)
          .collection(TaskModel.collection);
      await docRef.doc(taskModel.uuid).set(taskModel.toMap());
    } catch (e) {
      throw TaskRepositoryException(
          message: 'Erro em TaskRepositoryImp.create');
    }
  }
}
```
Até ai tudo bem. Mas os detalhes são mostrados agora com o Factory para as respectivas instancias.
```Dart
abstract class TaskRepositoryFactory {
  TaskRepository produce();
}
```

```Dart
class TaskRepositoryFactoryHive implements TaskRepositoryFactory {
  UserService _userService;

  TaskRepositoryFactoryHive({
    required UserService userService,
  }) : _userService = userService;

  @override
  TaskRepository produce() {
    TaskRepositoryHiveImp taskRepositoryHiveImp =
        TaskRepositoryHiveImp.instance;
    taskRepositoryHiveImp.userUuid = _userService.userModel.uuid;
    return taskRepositoryHiveImp;
  }
}
```

```Dart
class TaskRepositoryFactoryFirebase implements TaskRepositoryFactory {
  final UserService _userService;
  final FirebaseFirestore _firebaseFirestore;

  TaskRepositoryFactoryFirebase({
    required UserService userService,
    required FirebaseFirestore firebaseFirestore,
  })  : _userService = userService,
        _firebaseFirestore = firebaseFirestore;

  @override
  TaskRepository produce() {
    TaskRepositoryFirebaseImp taskRepositoryHiveImp =
        TaskRepositoryFirebaseImp.instance;
    taskRepositoryHiveImp.userUuid = _userService.userModel.uuid;
    taskRepositoryHiveImp.firebaseFirestore = _firebaseFirestore;
    return taskRepositoryHiveImp;
  }
}
```
E como usar tudo isto.
Em algum controller no inicio do seu App decida qual RepositoryFactory irá ser usado. Passando os parametros necessarios para o construtor construir.
```Dart
...
      if (controller.userModel.database == DatasourcesEnum.firebase) {
        Get.lazyPut<TaskRepositoryFactory>(
          () => TaskRepositoryFactoryFirebase(
              userService: Get.find(), firebaseFirestore: Get.find()),
          fenix: true,
        );
      } else {
        Get.lazyPut<TaskRepositoryFactory>(
          () => TaskRepositoryFactoryHive(userService: Get.find()),
          fenix: true,
        );
      }
...
```
Depois disto é só alegria. 
Quando precisamos de uma instancia do datasource é só chamar a fábrica que ela te fornece o correto.
```Dart
class TaskAppendDependencies implements Bindings {
  @override
  void dependencies() {
    Get.put<TaskUseCase>(
      TaskUseCaseImp(
          taskRepositoryFactory: Get.find(), userService: Get.find()),
    );
    Get.lazyPut<TaskAppendController>(
        () => TaskAppendController(taskUseCase: Get.find()));
  }
}
```
Neste caso o TaskUseCase já se organiza para atender as chamadas do controller.
```Dart
class TaskUseCaseImp implements TaskUseCase {
  TaskRepositoryFactory _taskRepositoryFactory;
  UserService _userService;

  TaskUseCaseImp({
    required TaskRepositoryFactory taskRepositoryFactory,
    required UserService userService,
  })  : _taskRepositoryFactory = taskRepositoryFactory,
        _userService = userService {
    _database = _taskRepositoryFactory.produce();
  }
  var _database;

  @override
  Future<void> create(TaskModel taskModel) {
    return _database.create(taskModel);
  }
}
```
Agora é apenas usar no controller.
```Dart
class TaskAppendController extends GetxController
    with LoaderMixin, MessageMixin {
  TaskUseCase _taskUseCase;
  TaskAppendController({required TaskUseCase taskUseCase})
      : _taskUseCase = taskUseCase;
  Future<void> append(String description) async {
    ...
    await _taskUseCase.create(taskModel);
    ...
  }
}
```