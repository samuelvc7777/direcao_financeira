import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide RealtimeClient;

import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/bank_account_datasource.dart';
import '../../data/datasources/category_datasource.dart';
import '../../data/datasources/credit_card_datasource.dart';
import '../../data/datasources/costs_gains_settings_datasource.dart';
import '../../data/datasources/i_journey_datasource.dart';
import '../../data/datasources/i_ride_datasource.dart';
import '../../data/datasources/journey_local_datasource.dart';
import '../../data/datasources/journey_route_local_datasource.dart';
import '../../data/datasources/location_tracking_datasource.dart';
import '../../data/datasources/subscription_datasource.dart';
import '../../data/datasources/subscription_store_datasource.dart';
import '../../data/datasources/traffic_light_local_datasource.dart';
import '../../data/datasources/transaction_datasource.dart';
import '../../data/providers/nest/auth/nest_auth_remote_datasource.dart';
import '../../data/providers/nest/finance/nest_bank_account_remote_datasource.dart';
import '../../data/providers/nest/finance/nest_category_remote_datasource.dart';
import '../../data/providers/nest/finance/nest_credit_card_remote_datasource.dart';
import '../../data/providers/nest/finance/nest_transaction_remote_datasource.dart';
import '../../data/providers/nest/journey/nest_journey_remote_datasource.dart';
import '../../data/providers/nest/journey/nest_ride_remote_datasource.dart';
import '../../data/providers/nest/realtime/socket_io_realtime_client.dart';
import '../../data/providers/nest/subscription/nest_subscription_remote_datasource.dart';
import '../../data/providers/play_store/play_store_subscription_store_datasource.dart';
import '../../data/providers/supabase/auth/supabase_auth_remote_datasource.dart';
import '../../data/providers/supabase/costs_gains/supabase_costs_gains_remote_datasource.dart';
import '../../data/providers/supabase/finance/supabase_bank_account_remote_datasource.dart';
import '../../data/providers/supabase/finance/supabase_category_remote_datasource.dart';
import '../../data/providers/supabase/finance/supabase_credit_card_remote_datasource.dart';
import '../../data/providers/supabase/finance/supabase_transaction_remote_datasource.dart';
import '../../data/providers/supabase/journey/supabase_journey_remote_datasource.dart';
import '../../data/providers/supabase/journey/supabase_ride_remote_datasource.dart';
import '../../data/providers/supabase/realtime/supabase_realtime_client.dart';
import '../../data/providers/supabase/subscription/supabase_subscription_remote_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/bank_account_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/credit_card_repository.dart';
import '../../data/repositories/costs_gains_repository.dart';
import '../../data/repositories/journey_repository_impl.dart';
import '../../data/repositories/ride_repository_impl.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/traffic_light_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_bank_account_repository.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../domain/repositories/i_credit_card_repository.dart';
import '../../domain/repositories/i_costs_gains_repository.dart';
import '../../domain/repositories/i_journey_repository.dart';
import '../../domain/repositories/i_ride_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/repositories/i_traffic_light_repository.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../../domain/usecases/create_detected_ride_usecase.dart';
import '../../domain/usecases/costs_gains_settings_use_cases.dart';
import '../config/app_environment.dart';
import '../network/api_error_mapper.dart';
import '../network/api_request_logger.dart';
import '../network/realtime_client.dart';
import '../session/session_coordinator.dart';
import '../session/session_store.dart';

class ProviderBinding extends Bindings {
  ProviderBinding({required this.environment});

  final AppEnvironment environment;

  @override
  void dependencies() {
    switch (environment.backendProvider) {
      case BackendProviderKind.nest:
        _registerNestProvider();
        break;
      case BackendProviderKind.supabase:
        _registerSupabaseProvider();
        break;
    }
  }

  void _registerNestProvider() {
    final sessionStore = Get.find<SessionStore>();
    final apiRequestLogger = Get.find<ApiRequestLogger>();
    final dio = Dio(
      BaseOptions(
        baseUrl: environment.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          apiRequestLogger.logRequest(options);
          final token = sessionStore.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          apiRequestLogger.logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) {
          apiRequestLogger.logError(error);
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthEndpoint =
              path.contains('/auth/login') || path.contains('/auth/register');

          if (statusCode == 401 && !isAuthEndpoint) {
            Get.find<SessionCoordinator>().expireSession(
              message: 'Sua sessao expirou. Faca login novamente.',
            );
          }

          handler.next(error);
        },
      ),
    );

    Get.put(dio, permanent: true);

    Get.put<RealtimeClient>(
      SocketIoRealtimeClient(
        baseUrl: environment.apiBaseUrl,
        enableRealtime: environment.enableRealtime,
      ),
      permanent: true,
    );

    Get.put<IAuthRemoteDataSource>(
      NestAuthRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<IBankAccountDataSource>(
      NestBankAccountRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ICategoryDataSource>(
      NestCategoryRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ICreditCardDataSource>(
      NestCreditCardRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ISubscriptionRemoteDataSource>(
      NestSubscriptionRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ISubscriptionLocalDataSource>(
      SubscriptionLocalDataSource(userCache: Get.find()),
      permanent: true,
    );
    if (!Get.isRegistered<ISubscriptionStoreDataSource>()) {
      Get.put<ISubscriptionStoreDataSource>(
        PlayStoreSubscriptionStoreDataSource(),
        permanent: true,
      );
    }
    Get.put<ITransactionDataSource>(
      NestTransactionRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<IJourneyDataSource>(
      NestJourneyRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<IRideDataSource>(
      NestRideRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<IJourneyLocalDataSource>(
      JourneyLocalDataSourceImpl(storage: Get.find()),
      permanent: true,
    );
    Get.put<IJourneyRouteLocalDataSource>(
      JourneyRouteLocalDataSourceImpl(),
      permanent: true,
    );
    Get.put<ILocationTrackingDataSource>(
      LocationTrackingDataSourceImpl(routeLocalDataSource: Get.find()),
      permanent: true,
    );
    Get.put<ITrafficLightLocalDataSource>(
      TrafficLightLocalDataSourceImpl(storage: Get.find()),
      permanent: true,
    );

    Get.put<IAuthRepository>(
      AuthRepository(
        remoteDataSource: Get.find(),
        sessionStore: Get.find(),
        userCache: Get.find(),
        sessionCoordinator: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<IBankAccountRepository>(
      BankAccountRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ICategoryRepository>(
      CategoryRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ICreditCardRepository>(
      CreditCardRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ISubscriptionRepository>(
      SubscriptionRepository(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
        storeDataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ITransactionRepository>(
      TransactionRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<IJourneyRepository>(
      JourneyRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
        routeLocalDataSource: Get.find(),
        locationTrackingDataSource: Get.find(),
        realtimeClient: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<IRideRepository>(
      RideRepositoryImpl(
        Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<CreateDetectedRideUseCase>(
      CreateDetectedRideUseCase(Get.find<IRideRepository>()),
      permanent: true,
    );
    Get.put<ITrafficLightRepository>(
      TrafficLightRepositoryImpl(localDataSource: Get.find()),
      permanent: true,
    );
  }

  void _registerSupabaseProvider() {
    final supabaseClient = Get.isRegistered<SupabaseClient>()
        ? Get.find<SupabaseClient>()
        : Supabase.instance.client;
    Get.put<SupabaseClient>(supabaseClient, permanent: true);

    Get.put<RealtimeClient>(
      SupabaseRealtimeClient(
        client: supabaseClient,
        enableRealtime: environment.enableRealtime,
      ),
      permanent: true,
    );

    Get.put<IAuthRemoteDataSource>(
      SupabaseAuthRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<IBankAccountDataSource>(
      SupabaseBankAccountRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<ICategoryDataSource>(
      SupabaseCategoryRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<ICreditCardDataSource>(
      SupabaseCreditCardRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<ISubscriptionRemoteDataSource>(
      SupabaseSubscriptionRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<ISubscriptionLocalDataSource>(
      SubscriptionLocalDataSource(userCache: Get.find()),
      permanent: true,
    );
    if (!Get.isRegistered<ISubscriptionStoreDataSource>()) {
      Get.put<ISubscriptionStoreDataSource>(
        PlayStoreSubscriptionStoreDataSource(),
        permanent: true,
      );
    }
    Get.put<ITransactionDataSource>(
      SupabaseTransactionRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<IJourneyDataSource>(
      SupabaseJourneyRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<IRideDataSource>(
      SupabaseRideRemoteDataSource(client: supabaseClient),
      permanent: true,
    );
    Get.put<IJourneyLocalDataSource>(
      JourneyLocalDataSourceImpl(storage: Get.find()),
      permanent: true,
    );
    Get.put<IJourneyRouteLocalDataSource>(
      JourneyRouteLocalDataSourceImpl(),
      permanent: true,
    );
    Get.put<ILocationTrackingDataSource>(
      LocationTrackingDataSourceImpl(routeLocalDataSource: Get.find()),
      permanent: true,
    );
    Get.put<ITrafficLightLocalDataSource>(
      TrafficLightLocalDataSourceImpl(storage: Get.find()),
      permanent: true,
    );
    Get.put<ICostsGainsSettingsDataSource>(
      SupabaseCostsGainsRemoteDataSource(client: supabaseClient),
      permanent: true,
    );

    Get.put<IAuthRepository>(
      AuthRepository(
        remoteDataSource: Get.find(),
        sessionStore: Get.find(),
        userCache: Get.find(),
        sessionCoordinator: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<IBankAccountRepository>(
      BankAccountRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ICategoryRepository>(
      CategoryRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ICreditCardRepository>(
      CreditCardRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ISubscriptionRepository>(
      SubscriptionRepository(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
        storeDataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<ITransactionRepository>(
      TransactionRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<IJourneyRepository>(
      JourneyRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
        routeLocalDataSource: Get.find(),
        locationTrackingDataSource: Get.find(),
        realtimeClient: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<IRideRepository>(
      RideRepositoryImpl(
        Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<CreateDetectedRideUseCase>(
      CreateDetectedRideUseCase(Get.find<IRideRepository>()),
      permanent: true,
    );
    Get.put<ITrafficLightRepository>(
      TrafficLightRepositoryImpl(localDataSource: Get.find()),
      permanent: true,
    );
    Get.put<ICostsGainsRepository>(
      CostsGainsRepository(
        dataSource: Get.find(),
        apiErrorMapper: Get.find<ApiErrorMapper>(),
        apiRequestLogger: Get.find<ApiRequestLogger>(),
      ),
      permanent: true,
    );
    Get.put<GetCostsGainsSettingsUseCase>(
      GetCostsGainsSettingsUseCase(Get.find<ICostsGainsRepository>()),
      permanent: true,
    );
    Get.put<HasCostsGainsSettingsUseCase>(
      HasCostsGainsSettingsUseCase(Get.find<ICostsGainsRepository>()),
      permanent: true,
    );
    Get.put<SaveCostsGainsSettingsUseCase>(
      SaveCostsGainsSettingsUseCase(Get.find<ICostsGainsRepository>()),
      permanent: true,
    );
  }
}
