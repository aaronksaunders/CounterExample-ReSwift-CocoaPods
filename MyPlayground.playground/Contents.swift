//: Playground - noun: a place where people can play

import UIKit
import ReSwift


struct AppState: StateType {
    var counter: Int = 0
}

// all of the actions that can be applied to the state
struct CounterActionIncrease: Action {}
struct CounterActionDecrease: Action {}

struct CounterReducer: Reducer {
    typealias ReducerStateType = AppState
    
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        // if no state has been provided, create the default state
        var state = state ?? AppState()
        
        switch action {
        case _ as CounterActionIncrease:
            state.counter += 1
        case _ as CounterActionDecrease:
            state.counter -= 1
        default:
            break
        }
        
        return state
    }
    
}


let mainStore = Store<AppState>(
    reducer: CounterReducer(),
    state: nil
)

class test: StoreSubscriber {
    
    typealias StoreSubscriberStateType = AppState
    
    init() {
        mainStore.subscribe(self)
    }

    
    func newState(state: AppState) {
        print(mainStore.state)
    }
    
    func up() {
        mainStore.dispatch(CounterActionIncrease());
    }
    
    func down() {
        mainStore.dispatch(CounterActionDecrease());
    }

}


let me = test()

me.up()
me.up()
me.up()
me.down()


