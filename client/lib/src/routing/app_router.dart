import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/presentation/chat_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/prompt/presentation/prompt_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/recepies/presentation/saved_recipes_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/home.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/main_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/trending.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_startup.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/presentation/entry_screen/entry_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/job_entries_screen/job_entries_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/edit_job_screen/edit_job_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/jobs_screen/jobs_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/onboarding/data/onboarding_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/go_router_refresh_stream.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/not_found_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:firebase_core/firebase_core.dart';

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _jobsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'jobs');
final _entriesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'entries');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _trendingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'trending');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');
final _recepiesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'recepies');
final _promptNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'prompt');

enum AppRoute {
  onboarding,
  signIn,
  jobs,
  job,
  addJob,
  editJob,
  entry,
  addEntry,
  editEntry,
  entries,
  profile,
  chat,
  prompt,
  recepies,
  trending,
  home
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final appStartupState = ref.watch(appStartupProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/signIn',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // Ensure Firebase is initialized
      // Access the real-time Firebase initialization status
      final isFirebaseInitialized = ref.watch(isFirebaseInitializedProvider);

      if (!isFirebaseInitialized) {
        await Firebase.initializeApp();
        // var t =  ref.watch(firebaseInitializationProvider);
// firebaseInit.when(
//         loading: () => const FirebaseLoadingScreen(),
//         error: (error, stack) => FirebaseErrorScreen(
//           error: error,
//           onRetry: () => ref.refresh(firebaseInitializationProvider),
//         ),
//         data: (firebaseApp) {
//           // FirebaseApp instance is now available
//           return HomeScreen(firebaseApp: firebaseApp);
//         },
        // ref.read(appStartupProvider.notifier).setFirebaseInitialized();
      }

      // If the app is still initializing, show the /startup route
      if (appStartupState.isLoading || appStartupState.hasError) {
        return '/startup';
      }

      final onboardingRepository =
          ref.read(onboardingRepositoryProvider).requireValue;
      final didCompleteOnboarding = onboardingRepository.isOnboardingComplete();
      final path = state.uri.path;

      if (!didCompleteOnboarding) {
        if (path != '/onboarding') {
          return '/onboarding';
        }
        return null;
      }

      final isLoggedIn = authRepository.currentUser != null;

      if (isLoggedIn) {
        if (path.startsWith('/startup') ||
            path.startsWith('/onboarding') ||
            path.startsWith('/signIn')) {
          return '/home';
        }
      } else {
        if (path.startsWith('/startup') ||
            path.startsWith('/onboarding') ||
            path.startsWith('/jobs') ||
            path.startsWith('/home') ||
            path.startsWith('/chat') ||
            path.startsWith('/entries') ||
            path.startsWith('/account')) {
          return '/signIn';
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/startup',
        pageBuilder: (context, state) => NoTransitionPage(
          child: AppStartupWidget(
            onLoaded: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/signIn',
        name: AppRoute.signIn.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomSignInScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) => NoTransitionPage(
          child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Home(),
                ),
                routes: [
                  GoRoute(
                    path: 'trending',
                    name: AppRoute.trending.name,
                    parentNavigatorKey: _homeNavigatorKey,
                    pageBuilder: (context, state) {
                      return const MaterialPage(
                        child: Trending(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _recepiesNavigatorKey,
            routes: [
              GoRoute(
                path: '/recepies',
                name: AppRoute.recepies.name,
                pageBuilder: (context, state) {
                  return const MaterialPage(
                    fullscreenDialog: false,
                    child: SavedRecipesScreen(
                      canScroll: true,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _promptNavigatorKey,
            routes: [
              GoRoute(
                path: '/prompt',
                name: AppRoute.prompt.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                    child: PromptScreen(
                  canScroll: true,
                )),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _jobsNavigatorKey,
            routes: [
              GoRoute(
                path: '/jobs',
                name: AppRoute.jobs.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: JobsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: AppRoute.addJob.name,
                    parentNavigatorKey: _jobsNavigatorKey,
                    pageBuilder: (context, state) {
                      return const MaterialPage(
                        fullscreenDialog: true,
                        child: EditJobScreen(),
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoute.job.name,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return MaterialPage(
                        child: JobEntriesScreen(jobId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'entries/add',
                        name: AppRoute.addEntry.name,
                        parentNavigatorKey: _jobsNavigatorKey,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id']!;
                          return MaterialPage(
                            fullscreenDialog: true,
                            child: EntryScreen(
                              jobId: jobId,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'entries/:eid',
                        name: AppRoute.entry.name,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id']!;
                          final entryId = state.pathParameters['eid']!;
                          final entry = state.extra as Entry?;
                          return MaterialPage(
                            child: EntryScreen(
                              jobId: jobId,
                              entryId: entryId,
                              entry: entry,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'edit',
                        name: AppRoute.editJob.name,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id'];
                          final job = state.extra as Job?;
                          return MaterialPage(
                            fullscreenDialog: true,
                            child: EditJobScreen(jobId: jobId, job: job),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _accountNavigatorKey,
            routes: [
              GoRoute(
                path: '/account',
                name: AppRoute.profile.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CustomProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => const NoTransitionPage(
      child: NotFoundScreen(),
    ),
  );
}
