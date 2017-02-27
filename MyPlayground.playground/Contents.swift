//: Playground - noun: a place where people can play

import UIKit
import ReSwift

import PlaygroundSupport

// see this SO answer for explanation
// - http://stackoverflow.com/questions/28352674/http-request-in-swift-not-working
//
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
//
//

struct AppState: StateType {
    var counter: Int = 0
    var loading: Bool = false
    var data: NSArray?
    var error: String?
}

// all of the actions that can be applied to the state
struct CounterActionIncrease: Action {}
struct CounterActionDecrease: Action {}
struct LoadUserData : Action {
    let queryString: String
    let results: Int
}
struct SetUserData : Action {
    let users: Any?
    let error:String?
}
struct CounterActionJump: Action {
    let jumpValue:Int
}

struct CounterReducer: Reducer {
    typealias ReducerStateType = AppState
    
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        // if no state has been provided, create the default state
        var state = state ?? AppState()
        
        switch action {
        case let action as CounterActionJump:
            state.counter += (action.jumpValue)
        case _ as CounterActionIncrease:
            state.counter += 1
        case _ as CounterActionDecrease:
            state.counter -= 1
        case  let action as LoadUserData:
            state = handleLoadDataAction(action: action, state: state)
        case let action as  SetUserData:
            state = handleSetUserDataAction(_action: action , _state: state)
        default:
            break
        }
        
        //print("Action= \(action)  State=\(state)")
        return state
    }
    
    func handleSetUserDataAction(_action:SetUserData, _state: AppState?)  -> AppState {
        var newState = _state ?? AppState()
        newState.data = _action.users as! NSArray?
        newState.loading = false
        newState.error = _action.error
        return newState 
    }
    
    func handleLoadDataAction(action: LoadUserData, state: AppState?) -> AppState {
        var newState = state ?? AppState()
        newState.loading = true
        
        let url = URL(string: "http://api.randomuser.me/?results=\(action.results)")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                mainStore.dispatch(SetUserData(users: [], error : error!.localizedDescription))
                return
            }
            guard let data = data else {
                print("Data is empty")
                mainStore.dispatch(SetUserData(users: [], error : "Data is Empty"))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let dict = json as? NSDictionary
                mainStore.dispatch(SetUserData(users: dict?["results"], error : nil))
            } catch let error  {
                mainStore.dispatch(SetUserData(users: [], error : error.localizedDescription ))
            }
        }
        
        task.resume()
        
        return newState 
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
    
    func loadData(count: Int = 1) {
        mainStore.dispatch(LoadUserData(queryString: "testing", results: count))
    }
    func jump() {
        mainStore.dispatch(CounterActionJump(jumpValue:-10));
    }
    

}


let me = test()

me.loadData(count:3)


PlaygroundPage.current.needsIndefiniteExecution = true

