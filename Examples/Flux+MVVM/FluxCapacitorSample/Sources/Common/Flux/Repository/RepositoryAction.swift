//
//  RepositoryAction.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubKit
import RxSwift

final class RepositoryAction: Actionable {
    typealias DispatchValueType = Dispatcher.Repository
    
    private let session: ApiSessionType
    private var disposeBag = DisposeBag()
    
    init(session: ApiSessionType = ApiSession.shared) {
        self.session = session
    }
    
    func fetchRepositories(withUserId id: String, after: String?) {
        invoke(.isRepositoryFetching(true))
        let request = UserNodeRequest(id: id, after: after)
        session.send(request)
            .subscribe(onNext: { [weak self] in
                self?.invoke(.lastPageInfo($0.pageInfo))
                self?.invoke(.addRepositories($0.nodes))
                self?.invoke(.repositoryTotalCount($0.totalCount))
            }, onDisposed: { [weak self] in
                self?.invoke(.isRepositoryFetching(false))
            })
            .disposed(by: disposeBag)
    }
}