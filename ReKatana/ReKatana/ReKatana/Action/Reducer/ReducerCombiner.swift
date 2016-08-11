//
//  ReducerCombiner.swift
//  ReKatana
//
//  Created by Mauro Bolis on 11/08/16.
//  Copyright © 2016 BendingSpoons. All rights reserved.
//

import Foundation

protocol ReducerCombiner: Reducer {
  associatedtype StateType: State

  static var initialState: StateType { get }
  // TODO: we are forced to make it settable from outside because of the extension
  // we should add something in the documentation that says that it should never be done
  // and of course we should try to avoid this issue in the first place
  static var reducers: [String: AnyReducer.Type] { get set }
  
  static func addReducer<Payload>(_ reducer: AnyReducer.Type, forAction action: SyncActionCreator<Payload>) -> Void
  
  static func addReducer<Payload, CompletedPayload, ErrorPayload>(_ reducer: AnyReducer.Type, forAction action: AsyncActionCreator<Payload, CompletedPayload, ErrorPayload>) -> Void
}

extension ReducerCombiner {
  static func reduce(action: Action, state: StateType?) -> StateType {
    guard let s = state else {
      return initialState
    }
    
    let actionName = action.actionName
    
    if let reducer = reducers[actionName] {
      // TODO: should we behave differently here?
      // theoretically as! should always work unless the developer has mixed the reducers
      // a compile time it won't crash.. So developer.. if you have reached this because of an
      // esception.. you are adding reducers that manage a different type of state
      // then the comibe reducer
      return reducer._reduce(action: action, state: s) as! StateType
    }
    
    return s
  }
  
  static func addReducer<Payload>(_ reducer: AnyReducer.Type, forAction action: SyncActionCreator<Payload>) -> Void {
    self.reducers[action.actionName] = reducer
  }
  
  static func addReducer<Payload, CompletedPayload, ErrorPayload>(_ reducer: AnyReducer.Type, forAction action: AsyncActionCreator<Payload, CompletedPayload, ErrorPayload>) -> Void {
    self.reducers[action.actionName] = reducer
  }
}