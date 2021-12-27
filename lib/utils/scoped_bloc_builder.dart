import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef Create<T> = T Function(BuildContext context);
typedef ScopedBlocWidgetBuilder<S, C extends Cubit<S>> = Widget Function(
    BuildContext context, S state, C cubit);
typedef Listener<S> = Function(BuildContext context, S state);
typedef ListenWhen<S> = bool Function(S previous, S current);

class ScopedBlocBuilder<C extends Cubit<S>, S> extends StatelessWidget {
  const ScopedBlocBuilder({
    Key? key,
    required this.create,
    required this.builder,
    required this.listener,
    required this.listenWhen,
  }) : super(key: key);

  final Create<C> create;
  final ScopedBlocWidgetBuilder<S, C> builder;
  final Listener<S> listener;
  final ListenWhen<S> listenWhen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: create,
      child: BlocConsumer<C, S>(
        listener: listener,
        listenWhen: listenWhen,
        builder: (context, state) {
          final cubit = BlocProvider.of<C>(context);
          return builder(context, state, cubit);
        },
      ),
    );
  }
}
