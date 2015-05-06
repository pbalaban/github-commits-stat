describe CommitCounter do
  let(:counter){ unknown_counter }

  let(:valid_username){ 'pbalaban' }
  let(:valid_counter){ CommitCounter.new(valid_username) }

  let(:unknown_username){ 'unknown12345' }
  let(:unknown_counter){ CommitCounter.new(unknown_username) }

  let(:valid_stat){ { all: [1,2,3], owner: [2,3,4] } }
  let(:stat_without_owner){ { all: [1,2,3] } }

  let(:repo_mock){ mock = Minitest::Mock.new; mock.expect(:full_name, :any); mock }

  describe '#initialize' do
    it{ CommitCounter.new('test1  ,test2,    test3, test4').usernames.must_equal %w(test1 test2 test3 test4) }
    it{ CommitCounter.new('').usernames.must_equal [] }
    it{ CommitCounter.new(nil).usernames.must_equal [] }
    it{ CommitCounter.new(1).usernames.must_equal ['1'] }
  end

  it '#results' do
    fake_commit_sum = ->(arg){ arg.to_s[/\d+/, 0].to_i }
    fake_repos = ->(arg){ { 'user1' => [:sum1, :sum2, :sum3], 'user2' => [:sum2, :sum3, :sum4]  }[arg] }

    test_counter = CommitCounter.new('user1, user2')

    test_counter.stub(:commit_sum_for, fake_commit_sum) do
      test_counter.stub(:repos_for, fake_repos) do
        test_counter.results.must_equal('user1' => 6, 'user2' => 9)
      end
    end
  end

  it '#ordered_results' do
    counter.stub :results, { a: 2, b: 1, c: 4 } do
      counter.ordered_results.must_equal [[:c, 4], [:a, 2], [:b, 1]]
    end
  end

  describe '#formatted_results' do
    it 'handle empty input' do
      CommitCounter.new(nil).formatted_results.must_equal 'Results is empty!'
    end

    it 'correctly formating data' do
      counter.stub :results, { a: 2, b: 1, c: 4 } do
        counter.formatted_results.must_equal "Results:\nc - 4\na - 2\nb - 1"
      end
    end
  end

  describe 'private methods' do
    describe :repos_for do
      it{ unknown_counter.send(:repos_for, unknown_username).must_be_empty }
      it{ valid_counter.send(:repos_for, valid_username).wont_be_empty }
    end

    describe :commit_sum_for do
      it 'return zero when participation_stats is nil' do
        Octokit.stub :participation_stats, nil do
          counter.send(:commit_sum_for, repo_mock).must_equal 0
        end
      end

      it 'return zero when participation_stats have not :owner key' do
        Octokit.stub :participation_stats, stat_without_owner do
          counter.send(:commit_sum_for, repo_mock).must_equal 0
        end
      end

      it 'calculate sum of elements from :owner array' do
        Octokit.stub :participation_stats, valid_stat do
          counter.send(:commit_sum_for, repo_mock).must_equal 9
        end
      end
    end
  end
end
