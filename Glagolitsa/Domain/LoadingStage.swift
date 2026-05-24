//
//  LoadingStage.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 23.03.2025.
//

enum LoadingStage {
    case idle
    case loadingFromServer
    case loadingFromServerError(Error?)
    case parsingData
    case savingToDatabase(Int)
}
