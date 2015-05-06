class CommitCounter
  def initialize input
    @usernames = input.to_s.split(/,\s*/).map(&:strip)
  end

  attr_reader :usernames

  def results
    self.usernames.each.with_object({}) do |username, memo|
      memo[username] = repos_for(username).sum{ |repo| commit_sum_for(repo) }
    end
  end

  def ordered_results
    self.results.sort{ |a,b| b.last <=> a.last }
  end

  def formatted_results
    return 'Results is empty!' if self.ordered_results.blank?

    output_lines = %w(Results:) + self.ordered_results.map do |username, repo_count|
      [username, repo_count].join(' - ')
    end

    output_lines.join("\n")
  end

  private
  def repos_for username
    Octokit.repos(username, type: :all)
  rescue Octokit::NotFound
    []
  end

  def commit_sum_for repo
    stat = Octokit.participation_stats(repo.full_name)
    (stat.try(:[], :owner) || []).sum
  end
end
