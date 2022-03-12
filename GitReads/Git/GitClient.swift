//
//  GitClient.swift
//  GitReads

protocol GitClient {
    func getRepository(owner: String, name: String) async -> Result<GitRepo, Error>
}
