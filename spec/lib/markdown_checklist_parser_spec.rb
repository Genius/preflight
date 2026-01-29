require 'rails_helper'

RSpec.describe MarkdownChecklistParser do
  describe '.parse' do
    context 'with simple unchecked tasks' do
      it 'reports unchecked required tasks' do
        pr_body = <<~BODY
          - [ ] Task 1
          - [x] Task 2
          - [ ] Task 3
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(2)
        expect(result[:message]).to include('You should check these:')
        expect(result[:message]).to include('> - Task 1')
        expect(result[:message]).to include('> - Task 3')
        expect(result[:message]).not_to include('Task 2')
      end

      it 'returns empty string when all required tasks are checked' do
        pr_body = <<~BODY
          - [x] Task 1
          - [x] Task 2
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(0)
        expect(result[:message]).to eq('')
      end
    end

    context 'with optional tasks' do
      it 'does not report unchecked optional tasks' do
        pr_body = <<~BODY
          - [ ] Task 1 <!-- Optional -->
          - [ ] Task 2 <!-- Optional -->
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(0)
        expect(result[:message]).to eq('')
      end

      it 'reports only non-optional unchecked tasks' do
        pr_body = <<~BODY
          - [ ] Required task
          - [ ] Optional task <!-- Optional -->
          - [x] Checked task
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(1)
        expect(result[:message]).to include('You should check these:')
        expect(result[:message]).to include('> - Required task')
        expect(result[:message]).not_to include('Optional task')
      end
    end

    context 'with mixed checked and unchecked tasks' do
      it 'only counts unchecked required tasks' do
        pr_body = <<~BODY
          - [ ] Unchecked 1
          - [x] Checked 1
          - [ ] Unchecked 2
          - [x] Checked 2
          - [ ] Optional unchecked <!-- Optional -->
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(2)
        expect(result[:message]).to include('> - Unchecked 1')
        expect(result[:message]).to include('> - Unchecked 2')
        expect(result[:message]).not_to include('Checked')
        expect(result[:message]).not_to include('Optional unchecked')
      end
    end

    context 'with edge cases' do
      it 'handles empty string' do
        result = MarkdownChecklistParser.parse('')

        expect(result[:unchecked]).to eq(0)
        expect(result[:message]).to eq('')
      end

      it 'handles string with no tasks' do
        pr_body = <<~BODY
          This is just text
          No tasks here
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(0)
        expect(result[:message]).to eq('')
      end

      it 'handles single unchecked task' do
        pr_body = '- [ ] Single task'

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(1)
        expect(result[:message]).to include('You should check these:')
        expect(result[:message]).to include('> - Single task')
      end

      it 'handles single checked task' do
        pr_body = '- [x] Checked task'

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(0)
        expect(result[:message]).to eq('')
      end

      it 'handles tasks with special characters in title' do
        pr_body = '- [ ] Task with special chars: @#$%^&*()'

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(1)
        expect(result[:message]).to include('> - Task with special chars: @#$%^&*()')
      end

      it 'handles tasks with extra whitespace' do
        pr_body = '  - [ ]   Task with spaces  '

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(1)
        expect(result[:message]).to include('> - Task with spaces')
      end
    end

    context 'with uppercase X in checkbox' do
      it 'recognizes uppercase X as checked' do
        pr_body = <<~BODY
          - [X] Checked with uppercase
          - [ ] Unchecked task
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(1)
        expect(result[:message]).to include('> - Unchecked task')
        expect(result[:message]).not_to include('Checked with uppercase')
      end
    end

    context 'with non-task lines' do
      it 'ignores lines that are not tasks' do
        pr_body = <<~BODY
          # This is a header
          - [ ] Task 1
          Some regular text
          - [x] Task 2
          Another line
          - [ ] Task 3
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(2)
        expect(result[:message]).to include('> - Task 1')
        expect(result[:message]).to include('> - Task 3')
      end
    end

    context 'with multiple optional tasks' do
      it 'ignores all optional tasks regardless of checked status' do
        pr_body = <<~BODY
          - [ ] Optional 1 <!-- Optional -->
          - [x] Optional 2 <!-- Optional -->
          - [ ] Required task
        BODY

        result = MarkdownChecklistParser.parse(pr_body)

        expect(result[:unchecked]).to eq(1)
        expect(result[:message]).to include('You should check these:')
        expect(result[:message]).to include('> - Required task')
        expect(result[:message]).not_to include('Optional')
      end
    end
  end
end
