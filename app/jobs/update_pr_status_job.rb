class UpdatePrStatusJob < ApplicationJob
  retry_on Octokit::Error, attempts: 15

  def perform(installation_id, repo, pr_number)
    client = GithubClient.for_installation(installation_id)
    pr = client.pull_request(repo.github_full_name, pr_number)

    merge_sha = pr[:merge_commit_sha]
    body = pr[:body]

    begin
      body_results = MarkdownChecklistParser.parse(body)

      desc = I18n.t('status_by_unchecked_count', count: body_results[:unchecked])

      if body_results[:unchecked] > 0
        status = :pending
      else
        status = :success
      end
    rescue Exception
      desc = I18n.t('parsing_error_status')
      status = :error
    end

    client.create_status(repo.github_full_name, merge_sha, status, context: I18n.t('check_name'), description: desc)
  end
end
