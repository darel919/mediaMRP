import 'package:redux/redux.dart';

// Action
class SelectItemAction {
  final String itemId;

  SelectItemAction(this.itemId);
}

// Reducer
String selectedItemReducer(String state, dynamic action) {
  if (action is SelectItemAction) {
    return action.itemId;
  }
  return state;
}

// Store
final store = Store<String>(selectedItemReducer, initialState: '');
