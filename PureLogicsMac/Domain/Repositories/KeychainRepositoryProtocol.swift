//
//  KeychainRepositoryProtocol.swift
//  PureLogicsMac
//
//  Created by Apple on 12/08/2026.
//


protocol KeychainRepositoryProtocol: Sendable {
    func save(key: String, value: String) throws
    func get(key: String) -> String?
    func delete(key: String) throws
}
