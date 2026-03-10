import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      AppUser? user = await _authService.signUp(event.email, event.password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthError('Signup failed'));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      AppUser? user = await _authService.login(event.email, event.password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthError('Login failed or email not verified'));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await _authService.logout();
      emit(AuthInitial());
    });
  }
}