//
//  GitClient.swift
//  GitReads

protocol GitClient {
    func searchRepositories(query: String) async -> Result<PaginatedResponse<GitRepoSummary>, Error>
    func getRepository(owner: String, name: String, ref: GitRef?) async -> Result<GitRepo, Error>
}

extension GitClient {
    func getRepository(
        owner: String,
        name: String,
        ref: GitRef? = nil
    ) async -> Result<GitRepo, Error> {
        await getRepository(owner: owner, name: name, ref: ref)
    }
}
