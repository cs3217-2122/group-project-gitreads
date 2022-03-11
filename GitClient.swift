//
//  Gitclient.swift
//  GitReads

protocol GitClient {
    func getRepository(owner: String, name: String) async -> Result<GitRepo, Error>
    func getRepositoryContent(owner: String, name: String, path: String) async -> Result<GitContent, Error>
}
