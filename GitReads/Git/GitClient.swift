//
//  GitClient.swift
//  GitReads

protocol GitClient {
    func searchRepositories(query: String) async -> Result<[GitRepoSummary], Error>
    func getRepository(owner: String, name: String, ref: GitRef?) async -> Result<GitRepo, Error>
}
